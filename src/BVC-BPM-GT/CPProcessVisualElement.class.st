"I render one CPProcess diagram directly with Bloc.

The Process model owns semantic and diagram-depiction state. Bloc owns visual geometry. I read the staged Magritte state through the supplied memento and retain the represented Process objects on the Bloc elements so interaction can resolve directly back to domain objects."
Class {
	#name : 'CPProcessVisualElement',
	#superclass : 'BlElement',
	#instVars : [
		'memento',
		'diagramDescription',
		'flowElementsDescription',
		'diagramMemento',
		'elementsDescription',
		'shapeElementsByShape',
		'shapeElementsByModelElement',
		'edgeElementsByEdge',
		'externalLabelElementsByModelElement',
		'connectionPortElementsByModelElement',
		'hoveredModelElement',
		'diagramElements',
		'selectedModelElement',
		'selectionChangedBlock',
		'moveShapeOperationBlock',
		'createFlowNodeOperationBlock',
		'connectFlowNodesOperationBlock',
		'removeFlowNodeOperationBlock',
		'removeSequenceFlowOperationBlock',
		'reconnectSequenceFlowOperationBlock',
		'connectionSourceModelElement',
		'reconnectHandleElementsByEdge',
		'activePaletteDragItem'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessVisualElement >> initialize [
	super initialize.
	shapeElementsByShape := IdentityDictionary new.
	shapeElementsByModelElement := IdentityDictionary new.
	edgeElementsByEdge := IdentityDictionary new.
	externalLabelElementsByModelElement := IdentityDictionary new.
	connectionPortElementsByModelElement := IdentityDictionary new.
	reconnectHandleElementsByEdge := IdentityDictionary new.
	self
		layout: BlFrameLayout new;
		clipChildren: false;
		beFocusable.
	self installKeyboardHandler
]

{ #category : 'accessing' }
CPProcessVisualElement >> memento: aMemento [
	memento := aMemento.
	diagramDescription := memento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	flowElementsDescription := memento magritteDescription
		detect: [ :each | each handlesSelector: #flowElements ].
	self refresh
]

{ #category : 'accessing' }
CPProcessVisualElement >> memento [
	^ memento
]

{ #category : 'updating' }
CPProcessVisualElement >> refresh [
	| diagram elements shapes edges contentExtent |
	self removeChildren.
	shapeElementsByShape removeAll.
	shapeElementsByModelElement removeAll.
	edgeElementsByEdge removeAll.
	externalLabelElementsByModelElement removeAll.
	connectionPortElementsByModelElement removeAll.
	reconnectHandleElementsByEdge removeAll.
	hoveredModelElement := nil.
	diagram := memento readUsing: diagramDescription.
	diagram ifNil: [ ^ self ].

	diagramMemento := memento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	elements ifNil: [ ^ self ].
	diagramElements := elements.

	contentExtent := self canvasExtentFor: elements.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent.
		c minWidth: contentExtent x.
		c minHeight: contentExtent y ].
	self addPaletteDropSurface.
	edges := elements select: #isEdge.
	shapes := elements select: #isShape.
	shapes do: [ :each | self addShapeFor: each ].
	edges do: [ :each | self addEdgeFor: each ].
	self bringNodeInteractionSurfacesToFront.
	self updateConnectionPortVisibility
]

{ #category : 'private - layout' }
CPProcessVisualElement >> canvasExtentFor: someDiagramElements [
	| maximumX maximumY |
	maximumX := 640.
	maximumY := 260.
	someDiagramElements do: [ :each |
		each isShape ifTrue: [
			| bounds |
			bounds := self stagedBoundsOf: each.
			bounds ifNotNil: [
				maximumX := maximumX max: bounds right + 80.
				maximumY := maximumY max: bounds bottom + 80 ] ].
		each isEdge ifTrue: [
			(self stagedWaypointsOf: each) do: [ :aPoint |
				maximumX := maximumX max: aPoint x + 80.
				maximumY := maximumY max: aPoint y + 80 ] ] ].
	^ maximumX @ maximumY
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedBoundsOf: aShape [
	| shapeMemento description |
	shapeMemento := diagramMemento childMementoFor: aShape inRelation: elementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	^ shapeMemento readUsing: description
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedWaypointsOf: anEdge [
	| edgeMemento description |
	edgeMemento := diagramMemento childMementoFor: anEdge inRelation: elementsDescription.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	^ (edgeMemento readUsing: description) ifNil: [ #() ]
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedLabelOf: aFlowElement [
	| flowElements flowMemento description |
	flowElements := memento readUsing: flowElementsDescription.
	(flowElements identityIncludes: aFlowElement) ifFalse: [ ^ aFlowElement label ].
	flowMemento := memento childMementoFor: aFlowElement inRelation: flowElementsDescription.
	description := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #label ].
	^ flowMemento readUsing: description
]

{ #category : 'private - shapes' }
CPProcessVisualElement >> addShapeFor: aShape [
	| bounds modelElement element |
	bounds := self stagedBoundsOf: aShape.
	bounds ifNil: [ ^ self ].
	modelElement := aShape modelElement.
	element := self newShapeElementFor: modelElement bounds: bounds.
	element
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: bounds origin.
	element userData at: #processDiagramElement put: aShape.
	element userData at: #processModelElement put: modelElement.
	self installSelectionOn: element for: modelElement.
	self installPositioningOn: element for: aShape.
	self installConnectionOn: element for: modelElement.
	shapeElementsByShape at: aShape put: element.
	shapeElementsByModelElement at: modelElement put: element.
	self addChild: element.
	self addExternalLabelFor: modelElement bounds: bounds shape: aShape shapeElement: element.
	self updateSelectionAppearance
]

{ #category : 'private - shapes' }
CPProcessVisualElement >> newShapeElementFor: aFlowNode bounds: bounds [
	| element label |
	element := BlElement new
		extent: bounds extent;
		geometry: (self geometryFor: aFlowNode bounds: bounds);
		background: self shapeBackgroundColor;
		border: (BlBorder
			paint: self shapeBorderColor
			width: (aFlowNode isEndEvent ifTrue: [ 3 ] ifFalse: [ 1.5 ]));
		layout: BlFrameLayout new;
		yourself.

	aFlowNode isActivity ifTrue: [
		label := self newEditableLabelFor: aFlowNode.
		label hFitContentLimited.
		label vFitContent.
		label constraintsDo: [ :c |
			c maxWidth: (bounds width - 20 max: 1).
			c frame horizontal alignCenter.
			c frame vertical alignCenter ].
		element addChild: label.
		self installLabelEditingOn: element label: label ].
	^ element
]

{ #category : 'private - shapes' }
CPProcessVisualElement >> geometryFor: aFlowNode bounds: bounds [
	aFlowNode isEvent ifTrue: [ ^ BlCircleGeometry new ].
	aFlowNode isActivity ifTrue: [ ^ BlRoundedRectangleGeometry cornerRadius: 8 ].
	^ BlRectangleGeometry new
]

{ #category : 'private - labels' }
CPProcessVisualElement >> addExternalLabelFor: aFlowNode bounds: bounds shape: aShape shapeElement: aShapeElement [
	| labelHost label labelWidth |
	aFlowNode isEvent ifFalse: [ ^ self ].
	labelWidth := 180.
	labelHost := BlElement new
		clipChildren: false;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal exact: labelWidth.
			c vertical fitContent.
			c ignoreByLayout ];
		relocate: (bounds center x - (labelWidth / 2)) @ (bounds bottom + 4);
		yourself.
	label := self newEditableLabelFor: aFlowNode.
	label hFitContentLimited.
	label vFitContent.
	label constraintsDo: [ :c |
		c maxWidth: labelWidth.
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	labelHost addChild: label.
	externalLabelElementsByModelElement at: aFlowNode put: labelHost.
	self addChild: labelHost.
	self installLabelEditingOn: labelHost label: label.
	self installSelectionOn: labelHost for: aFlowNode.
	self installPositioningFrom: labelHost moving: aShapeElement for: aShape
]

{ #category : 'private - labels' }
CPProcessVisualElement >> newEditableLabelFor: aFlowElement [
	| flowMemento description label |
	flowMemento := memento childMementoFor: aFlowElement inRelation: flowElementsDescription.
	description := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #label ].

	label := CFEditableLabel new
		aptitude: CPProcessLabelAptitude new;
		text: ((flowMemento readUsing: description) ifNil: [ '' ]);
		padding: BlInsets empty;
		margin: BlInsets empty;
		background: Color transparent;
		border: BlBorder empty;
		yourself.

	label editor
		when: BrTextEditorModifiedEvent
		do: [ :anEvent |
			GtMagritteBuilderUtility
				writeText: anEvent text
				using: description
				memento: flowMemento
				element: label ].

	label
		when: BrEditorAcceptWish
		do: [ :aWish |
			label preventMeAndChildrenMouseEvents.
			label loseFocus ];
		when: BrEditorCancelWish
		do: [ :aWish |
			GtMagritteBuilderUtility
				writeText: label text
				using: description
				memento: flowMemento
				element: label.
			label preventMeAndChildrenMouseEvents.
			label loseFocus ].

	label preventMeAndChildrenMouseEvents.
	^ label
]

{ #category : 'private - labels' }
CPProcessVisualElement >> installLabelEditingOn: anInteractionElement label: anEditableLabel [
	anInteractionElement addEventHandler: (BlEventHandler
		on: BlDoubleClickEvent
		do: [ :anEvent |
			anEditableLabel allowMeAndChildrenMouseEvents.
			anEditableLabel switchToEditor.
			anEditableLabel requestFocus.
			anEvent consumed: true ])
]

{ #category : 'private - edges' }
CPProcessVisualElement >> addEdgeFor: anEdge [
	| waypoints |
	waypoints := self stagedWaypointsOf: anEdge.
	waypoints size = 2
		ifTrue: [ self addStraightEdgeFor: anEdge ]
		ifFalse: [ self addEdgeFor: anEdge waypoints: waypoints ].
	self installReconnectHandlesFor: anEdge
]

{ #category : 'private - edges' }
CPProcessVisualElement >> addStraightEdgeFor: anEdge [
	| sequenceFlow sourceElement targetElement line selectionLine source target sourceAnchor targetAnchor |
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	sourceElement := shapeElementsByModelElement at: source.
	targetElement := shapeElementsByModelElement at: target.
	sourceAnchor := (self anchorClassFor: source)
		nearestTo: targetElement
		from: sourceElement.
	targetAnchor := (self anchorClassFor: target)
		nearestTo: sourceElement
		from: targetElement.

	selectionLine := BlLineElement new
		fromAnchor: sourceAnchor;
		toAnchor: targetAnchor;
		border: (BlBorder paint: Color transparent width: 6);
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.
	selectionLine userData at: #processDiagramElement put: anEdge.
	selectionLine userData at: #processModelElement put: anEdge modelElement.
	self installEdgeSelectionOn: selectionLine for: anEdge.

	line := BlLineElement new
		fromAnchor: sourceAnchor;
		toAnchor: targetAnchor;
		border: (BlBorder paint: self shapeBorderColor width: 1.5);
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.
	line toHead: (BlArrowheadSimpleArrow new
		border: (BlBorder paint: self shapeBorderColor width: 1.5);
		yourself).
	line userData at: #processDiagramElement put: anEdge.
	line userData at: #processModelElement put: anEdge modelElement.
	self installEdgeSelectionOn: line for: anEdge.
	edgeElementsByEdge at: anEdge put: { line }.
	self addChild: selectionLine.
	self addChild: line
]

{ #category : 'private - layout' }
CPProcessVisualElement >> bringNodeInteractionSurfacesToFront [
	shapeElementsByShape valuesDo: [ :anElement |
		anElement removeFromParent.
		self addChild: anElement ].
	externalLabelElementsByModelElement valuesDo: [ :anElement |
		anElement removeFromParent.
		self addChild: anElement ]
]

{ #category : 'private - edges' }
CPProcessVisualElement >> anchorClassFor: aFlowNode [
	^ aFlowNode isEvent
		ifTrue: [ BlNearestPositionEllipseAnchor ]
		ifFalse: [ BlNearestPositionBoundsAnchor ]
]

{ #category : 'private - edges' }
CPProcessVisualElement >> addEdgeFor: anEdge waypoints: waypoints [
	| pairCount lines |
	waypoints size < 2 ifTrue: [ ^ self ].
	lines := OrderedCollection new.
	pairCount := waypoints size - 1.
	1 to: pairCount do: [ :index |
		| line selectionLine startPoint endPoint |
		startPoint := waypoints at: index.
		endPoint := waypoints at: index + 1.

		selectionLine := BlLineElement new
			fromAnchor: (BlAbsolutePositionAnchor position: startPoint);
			toAnchor: (BlAbsolutePositionAnchor position: endPoint);
			border: (BlBorder paint: Color transparent width: 6);
			constraintsDo: [ :c | c ignoreByLayout ];
			yourself.
		selectionLine userData at: #processDiagramElement put: anEdge.
		selectionLine userData at: #processModelElement put: anEdge modelElement.
		self installEdgeSelectionOn: selectionLine for: anEdge.

		line := self
			newLineFrom: startPoint
			to: endPoint
			withArrowhead: index = pairCount.
		line userData at: #processDiagramElement put: anEdge.
		line userData at: #processModelElement put: anEdge modelElement.
		self installEdgeSelectionOn: line for: anEdge.
		lines add: line.
		self addChild: selectionLine.
		self addChild: line ].
	edgeElementsByEdge at: anEdge put: lines
]

{ #category : 'private - edges' }
CPProcessVisualElement >> newLineFrom: aStartPoint to: anEndPoint withArrowhead: hasArrowhead [
	| line |
	line := BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: aStartPoint);
		toAnchor: (BlAbsolutePositionAnchor position: anEndPoint);
		border: (BlBorder paint: self shapeBorderColor width: 1.5);
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.
	hasArrowhead ifTrue: [
		line toHead: (BlArrowheadSimpleArrow new
			border: (BlBorder paint: self shapeBorderColor width: 1.5)) ].
	^ line
]

{ #category : 'private - edges' }
CPProcessVisualElement >> edge: anEdge isIncidentTo: aModelElement [
	| sequenceFlow |
	sequenceFlow := anEdge modelElement.
	^ sequenceFlow sourceRef == aModelElement
		or: [ sequenceFlow targetRef == aModelElement ]
]

{ #category : 'private - edges' }
CPProcessVisualElement >> removeRenderedEdgeFor: anEdge [
	(edgeElementsByEdge removeKey: anEdge ifAbsent: [ #() ])
		do: [ :aLine | aLine removeFromParent ]
]

{ #category : 'private - selection' }
CPProcessVisualElement >> installSelectionOn: anElement for: aModelElement [
	anElement
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent |
				connectionSourceModelElement
					ifNotNil: [ self completeConnectionTo: aModelElement. anEvent consumed: true ]
					ifNil: [
						selectedModelElement := aModelElement.
						self updateSelectionAppearance.
						selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: aModelElement ].
						self requestFocus.
						anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlMouseEnterEvent
			do: [ :anEvent |
				hoveredModelElement := aModelElement.
				self updateConnectionPortVisibility ]);
		addEventHandler: (BlEventHandler
			on: BlMouseLeaveEvent
			do: [ :anEvent |
				hoveredModelElement == aModelElement ifTrue: [ hoveredModelElement := nil ].
				self updateConnectionPortVisibility ])
]

{ #category : 'selection' }
CPProcessVisualElement >> selectedModelElement [
	^ selectedModelElement
]

{ #category : 'selection' }
CPProcessVisualElement >> selectionChangedDo: aBlock [
	selectionChangedBlock := aBlock
]

{ #category : 'accessing - testing' }
CPProcessVisualElement >> shapeElementFor: aShape [
	^ shapeElementsByShape at: aShape
]


{ #category : 'private - selection' }
CPProcessVisualElement >> updateSelectionAppearance [
	shapeElementsByModelElement keysAndValuesDo: [ :aModelElement :anElement |
		| isSelected |
		isSelected := aModelElement == selectedModelElement or: [ aModelElement == connectionSourceModelElement ].
		anElement border: (BlBorder
			paint: (isSelected
				ifTrue: [ self selectionColor ]
				ifFalse: [ self shapeBorderColor ])
			width: (self borderWidthFor: aModelElement selected: isSelected)) ].
	edgeElementsByEdge keysAndValuesDo: [ :anEdge :someLines |
		| isSelected |
		isSelected := anEdge modelElement == selectedModelElement.
		someLines do: [ :aLine |
			aLine border: (BlBorder
				paint: (isSelected ifTrue: [ self selectionColor ] ifFalse: [ self shapeBorderColor ])
				width: (isSelected ifTrue: [ 3 ] ifFalse: [ 1.5 ])) ] ].
	reconnectHandleElementsByEdge keysAndValuesDo: [ :anEdge :someHandles |
		| visibility |
		visibility := anEdge modelElement == selectedModelElement
			ifTrue: [ BlVisibility visible ]
			ifFalse: [ BlVisibility hidden ].
		someHandles do: [ :aHandle | aHandle visibility: visibility ] ].
	self updateConnectionPortVisibility
]

{ #category : 'private - selection' }
CPProcessVisualElement >> borderWidthFor: aModelElement selected: isSelected [
	isSelected ifTrue: [ ^ aModelElement isEndEvent ifTrue: [ 4.5 ] ifFalse: [ 3 ] ].
	^ aModelElement isEndEvent ifTrue: [ 3 ] ifFalse: [ 1.5 ]
]

{ #category : 'configuration' }
CPProcessVisualElement >> moveShapeOperationFor: aBlock [
	"The block receives the CPShape and proposed bounds and answers the Process Atelier operation for that diagram intention."
	moveShapeOperationBlock := aBlock
]

{ #category : 'operations' }
CPProcessVisualElement >> moveShape: aShape toBounds: aRectangle [
	| assessment |
	moveShapeOperationBlock ifNil: [ ^ nil ].
	assessment := (moveShapeOperationBlock value: aShape value: aRectangle) apply.
	assessment isApplicable ifFalse: [ self refresh ].
	^ assessment
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> installPositioningOn: anElement for: aShape [
	self installPositioningFrom: anElement moving: anElement for: aShape
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> installPositioningFrom: anInteractionElement moving: aShapeElement for: aShape [
	| dragStartEventPosition dragStartElementPosition originalBounds dragStartLabelPosition isDragging |
	moveShapeOperationBlock ifNil: [ ^ self ].
	isDragging := false.
	anInteractionElement
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				dragStartEventPosition := anEvent position.
				dragStartElementPosition := aShapeElement position.
				originalBounds := self stagedBoundsOf: aShape.
				dragStartLabelPosition := (externalLabelElementsByModelElement
					at: aShape modelElement
					ifAbsent: [ nil ])
					ifNotNil: [ :aLabel | aLabel position ].
				isDragging := true.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| proposedPosition delta |
					proposedPosition := dragStartElementPosition + anEvent position - dragStartEventPosition.
					aShapeElement relocate: proposedPosition.
					delta := aShapeElement position - dragStartElementPosition.
					dragStartLabelPosition ifNotNil: [
						(externalLabelElementsByModelElement at: aShape modelElement)
							relocate: dragStartLabelPosition + delta ].
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| proposedBounds |
					proposedBounds := aShapeElement position extent: originalBounds extent.
					isDragging := false.
					anEvent consumed: true.
					self moveShape: aShape toBounds: proposedBounds ] ])
]

{ #category : 'private - theme' }
CPProcessVisualElement >> shapeBackgroundColor [
	^ self resolvedThemeColor: self theme surfaces cardTint
]

{ #category : 'private - theme' }
CPProcessVisualElement >> shapeBorderColor [
	^ self resolvedThemeColor: self theme typography primaryForeground
]

{ #category : 'private - theme' }
CPProcessVisualElement >> selectionColor [
	^ self theme item selectedColor
]

{ #category : 'private - theme' }
CPProcessVisualElement >> resolvedThemeColor: aThemeableColor [
	^ aThemeableColor blocResolveColorForTheme: self theme
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedSourceOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := memento childMementoFor: aSequenceFlow inRelation: flowElementsDescription.
	description := flowMemento magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedTargetOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := memento childMementoFor: aSequenceFlow inRelation: flowElementsDescription.
	description := flowMemento magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	^ flowMemento readUsing: description
]

{ #category : 'configuration' }
CPProcessVisualElement >> createFlowNodeOperationFor: aBlock [ createFlowNodeOperationBlock := aBlock ]
{ #category : 'configuration' }
CPProcessVisualElement >> connectFlowNodesOperationFor: aBlock [ connectFlowNodesOperationBlock := aBlock ]

{ #category : 'private - creation' }
CPProcessVisualElement >> addPaletteDropSurface [
	| dropSurface |
	dropSurface := BlElement new
		geometry: BlRectangleGeometry new;
		background: Color transparent;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c horizontal matchParent.
			c vertical matchParent ];
		relocate: 0 @ 0;
		yourself.
	dropSurface addEventHandler: (BlDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea | self acceptsPaletteDragItem: aDragItem ];
		whenDroppedDo: [ :anEvent | self dropPaletteEvent: anEvent ];
		yourself).
	self addChild: dropSurface
]

{ #category : 'private - creation' }
CPProcessVisualElement >> acceptsPaletteDragItem: aDragItem [
	| sourceElement candidate proposedBounds assessment |
	createFlowNodeOperationBlock ifNil: [ ^ false ].
	sourceElement := aDragItem sourceElement.
	sourceElement ifNil: [ ^ false ].
	(sourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	candidate := aDragItem domainObject.
	proposedBounds := 0 @ 0 extent: (self extentForModelElement: candidate).
	assessment := (createFlowNodeOperationBlock value: candidate value: proposedBounds) assess.
	^ assessment isApplicable
]

{ #category : 'private - creation' }
CPProcessVisualElement >> dropPaletteEvent: anEvent [
	| dragItem candidate elementExtent origin bounds assessment |
	anEvent items size = 1 ifFalse: [ ^ self ].
	dragItem := anEvent items first.
	candidate := dragItem domainObject.
	elementExtent := self extentForModelElement: candidate.
	origin :=
		((anEvent position x - (elementExtent x / 2)) max: 0)
		@ ((anEvent position y - (elementExtent y / 2)) max: 0).
	bounds := origin extent: elementExtent.
	assessment := (createFlowNodeOperationBlock value: candidate value: bounds) apply.
	assessment isApplicable ifTrue: [ self refresh ].
	^ assessment
]

{ #category : 'private - shapes' }
CPProcessVisualElement >> extentForModelElement: aFlowNode [
	aFlowNode isEvent ifTrue: [ ^ 42 @ 42 ].
	aFlowNode isActivity ifTrue: [ ^ 132 @ 54 ].
	^ 54 @ 54
]

{ #category : 'private - connection' }
CPProcessVisualElement >> installConnectionOn: aNodeElement for: aFlowNode [
	| port isDragging didDrag previewLine previewCursor |
	connectFlowNodesOperationBlock ifNil: [ ^ self ].
	aFlowNode isEndEvent ifTrue: [ ^ self ].
	isDragging := false.
	didDrag := false.
	port := BlElement new
		extent: 12 @ 12;
		geometry: BlCircleGeometry new;
		background: self selectionColor;
		border: (BlBorder paint: self shapeBorderColor width: 1.5);
		visibility: BlVisibility hidden;
		constraintsDo: [ :c | c frame horizontal alignRight. c frame vertical alignCenter ];
		yourself.
	port
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent |
				didDrag
					ifTrue: [ didDrag := false ]
					ifFalse: [ self beginConnectionFrom: aFlowNode ].
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				| localPoint |
				isDragging := true.
				didDrag := true.
				connectionSourceModelElement := aFlowNode.
				localPoint := self globalPointToLocal: anEvent position.
				previewCursor := BlElement new
					extent: 1 @ 1;
					background: Color transparent;
					constraintsDo: [ :c | c ignoreByLayout ];
					relocate: localPoint;
					yourself.
				previewLine := BlLineElement new
					fromAnchor: ((self anchorClassFor: aFlowNode)
						nearestTo: previewCursor
						from: aNodeElement);
					toAnchor: (BlNearestPositionBoundsAnchor
						nearestTo: aNodeElement
						from: previewCursor);
					border: (BlBorder paint: self selectionColor width: 1.5);
					constraintsDo: [ :c | c ignoreByLayout ];
					yourself.
				previewLine toHead: (BlArrowheadSimpleArrow new
					border: (BlBorder paint: self selectionColor width: 1.5)).
				self addChild: previewCursor.
				self addChildFirst: previewLine.
				self updateSelectionAppearance.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					previewCursor relocate: (self globalPointToLocal: anEvent position).
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| target |
					isDragging := false.
					previewLine ifNotNil: [ previewLine removeFromParent ].
					previewCursor ifNotNil: [ previewCursor removeFromParent ].
					previewLine := nil.
					previewCursor := nil.
					target := self
						connectionTargetAtGlobalPoint: anEvent position
						excluding: aFlowNode.
					connectionSourceModelElement := nil.
					target
						ifNotNil: [ self connectFrom: aFlowNode to: target ]
						ifNil: [ self updateSelectionAppearance ].
					anEvent consumed: true ] ]).
	connectionPortElementsByModelElement at: aFlowNode put: port.
	aNodeElement addChild: port
]

{ #category : 'private - connection' }
CPProcessVisualElement >> connectionTargetAtGlobalPoint: aPoint excluding: aFlowNode [
	shapeElementsByModelElement keysAndValuesDo: [ :aCandidate :anElement |
		aCandidate == aFlowNode ifFalse: [
			(anElement geometryBoundsInSpace containsPoint: aPoint)
				ifTrue: [ ^ aCandidate ] ] ].
	^ nil
]

{ #category : 'private - connection' }
CPProcessVisualElement >> connectFrom: aSource to: aTarget [
	| assessment |
	connectFlowNodesOperationBlock ifNil: [ ^ nil ].
	assessment := (connectFlowNodesOperationBlock value: aSource value: aTarget) apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateSelectionAppearance ].
	^ assessment
]

{ #category : 'private - connection' }
CPProcessVisualElement >> updateConnectionPortVisibility [
	connectionPortElementsByModelElement keysAndValuesDo: [ :aFlowNode :aPort |
		aPort visibility: ((aFlowNode == hoveredModelElement
			or: [ aFlowNode == selectedModelElement
			or: [ aFlowNode == connectionSourceModelElement ] ])
			ifTrue: [ BlVisibility visible ]
			ifFalse: [ BlVisibility hidden ]) ]
]

{ #category : 'private - connection' }
CPProcessVisualElement >> beginConnectionFrom: aFlowNode [
	connectionSourceModelElement := aFlowNode.
	self updateSelectionAppearance
]

{ #category : 'private - connection' }
CPProcessVisualElement >> completeConnectionTo: aFlowNode [
	| source |
	source := connectionSourceModelElement.
	connectionSourceModelElement := nil.
	self updateConnectionPortVisibility.
	source ifNil: [ ^ self ].
	source == aFlowNode ifTrue: [ self updateSelectionAppearance. ^ self ].
	^ self connectFrom: source to: aFlowNode
]



{ #category : 'configuration' }
CPProcessVisualElement >> reconnectSequenceFlowOperationFor: aBlock [
	reconnectSequenceFlowOperationBlock := aBlock
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> installReconnectHandlesFor: anEdge [
	| sequenceFlow source target sourceElement targetElement sourceHandle targetHandle |
	reconnectSequenceFlowOperationBlock ifNil: [ ^ self ].
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	sourceElement := shapeElementsByModelElement at: source ifAbsent: [ ^ self ].
	targetElement := shapeElementsByModelElement at: target ifAbsent: [ ^ self ].

	sourceHandle := self
		newReconnectHandleFor: sequenceFlow
		movingSource: true
		owner: sourceElement
		other: targetElement.
	targetHandle := self
		newReconnectHandleFor: sequenceFlow
		movingSource: false
		owner: targetElement
		other: sourceElement.

	reconnectHandleElementsByEdge
		at: anEdge
		put: { sourceHandle. targetHandle }.
	sourceElement addChild: sourceHandle.
	targetElement addChild: targetHandle
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> newReconnectHandleFor: aSequenceFlow movingSource: movesSource owner: ownerElement other: otherElement [
	| handle isDragging previewLine previewCursor |
	isDragging := false.
	handle := BlElement new
		extent: 12 @ 12;
		geometry: BlCircleGeometry new;
		background: self selectionColor;
		border: (BlBorder paint: self shapeBorderColor width: 1.5);
		visibility: BlVisibility hidden;
		yourself.
	self
		positionReconnectHandle: handle
		on: ownerElement
		toward: otherElement.

	handle
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent | anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				| source target localPoint |
				isDragging := true.
				source := self stagedSourceOf: aSequenceFlow.
				target := self stagedTargetOf: aSequenceFlow.
				localPoint := self globalPointToLocal: anEvent position.
				previewCursor := BlElement new
					extent: 1 @ 1;
					background: Color transparent;
					constraintsDo: [ :c | c ignoreByLayout ];
					relocate: localPoint;
					yourself.
				previewLine := movesSource
					ifTrue: [
						BlLineElement new
							fromAnchor: (BlNearestPositionBoundsAnchor
								nearestTo: otherElement
								from: previewCursor);
							toAnchor: ((self anchorClassFor: target)
								nearestTo: previewCursor
								from: otherElement);
							border: (BlBorder paint: self selectionColor width: 1.5);
							constraintsDo: [ :c | c ignoreByLayout ];
							yourself ]
					ifFalse: [
						BlLineElement new
							fromAnchor: ((self anchorClassFor: source)
								nearestTo: previewCursor
								from: otherElement);
							toAnchor: (BlNearestPositionBoundsAnchor
								nearestTo: otherElement
								from: previewCursor);
							border: (BlBorder paint: self selectionColor width: 1.5);
							constraintsDo: [ :c | c ignoreByLayout ];
							yourself ].
				previewLine toHead: (BlArrowheadSimpleArrow new
					border: (BlBorder paint: self selectionColor width: 1.5)).
				self addChild: previewCursor.
				self addChildFirst: previewLine.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					previewCursor relocate: (self globalPointToLocal: anEvent position).
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| candidate source target |
					isDragging := false.
					previewLine ifNotNil: [ previewLine removeFromParent ].
					previewCursor ifNotNil: [ previewCursor removeFromParent ].
					previewLine := nil.
					previewCursor := nil.
					candidate := self
						connectionTargetAtGlobalPoint: anEvent position
						excluding: nil.
					candidate ifNotNil: [
						source := self stagedSourceOf: aSequenceFlow.
						target := self stagedTargetOf: aSequenceFlow.
						movesSource
							ifTrue: [ source := candidate ]
							ifFalse: [ target := candidate ].
						self
							reconnectSequenceFlow: aSequenceFlow
							source: source
							target: target ].
					anEvent consumed: true ] ]).
	^ handle
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> positionReconnectHandle: aHandle on: ownerElement toward: otherElement [
	| ownerCenter otherCenter delta |
	ownerCenter := ownerElement position + (ownerElement extent / 2).
	otherCenter := otherElement position + (otherElement extent / 2).
	delta := otherCenter - ownerCenter.
	aHandle constraintsDo: [ :c |
		delta x abs >= delta y abs
			ifTrue: [
				delta x >= 0
					ifTrue: [ c frame horizontal alignRight ]
					ifFalse: [ c frame horizontal alignLeft ].
				c frame vertical alignCenter ]
			ifFalse: [
				c frame horizontal alignCenter.
				delta y >= 0
					ifTrue: [ c frame vertical alignBottom ]
					ifFalse: [ c frame vertical alignTop ] ] ]
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> reconnectSequenceFlow: aSequenceFlow source: aSource target: aTarget [
	| assessment |
	reconnectSequenceFlowOperationBlock ifNil: [ ^ nil ].
	assessment := (reconnectSequenceFlowOperationBlock
		value: aSequenceFlow
		value: aSource
		value: aTarget) apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateSelectionAppearance ].
	^ assessment
]

{ #category : 'configuration' }
CPProcessVisualElement >> removeFlowNodeOperationFor: aBlock [ removeFlowNodeOperationBlock := aBlock ]

{ #category : 'configuration' }
CPProcessVisualElement >> removeSequenceFlowOperationFor: aBlock [ removeSequenceFlowOperationBlock := aBlock ]

{ #category : 'private - selection' }
CPProcessVisualElement >> installEdgeSelectionOn: aLine for: anEdge [
	aLine addEventHandler: (BlEventHandler
		on: BlClickEvent
		do: [ :anEvent |
			connectionSourceModelElement ifNil: [
				selectedModelElement := anEdge modelElement.
				self updateSelectionAppearance.
				selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: anEdge modelElement ].
				self requestFocus.
				anEvent consumed: true ] ])
]

{ #category : 'private - installing' }
CPProcessVisualElement >> installKeyboardHandler [
	self addEventHandler: (BlEventHandler
		on: BlKeyDownEvent
		do: [ :anEvent |
			(anEvent key = BlKeyboardKey delete or: [ anEvent key = BlKeyboardKey backspace ]) ifTrue: [
				self removeSelection.
				anEvent consumed: true ].
			anEvent key = BlKeyboardKey escape ifTrue: [
				self cancelInteraction.
				anEvent consumed: true ] ])
]

{ #category : 'private - removal' }
CPProcessVisualElement >> removeSelection [
	| selectedShape selectedEdge operation assessment |
	selectedModelElement ifNil: [ ^ self ].
	selectedShape := shapeElementsByModelElement at: selectedModelElement ifAbsent: [ nil ].
	selectedShape ifNotNil: [
		removeFlowNodeOperationBlock ifNil: [ ^ self ].
		operation := removeFlowNodeOperationBlock value: selectedModelElement ].
	selectedShape ifNil: [
		selectedEdge := edgeElementsByEdge keys detect: [ :each | each modelElement == selectedModelElement ] ifNone: [ nil ].
		selectedEdge ifNil: [ ^ self ].
		removeSequenceFlowOperationBlock ifNil: [ ^ self ].
		operation := removeSequenceFlowOperationBlock value: selectedModelElement ].
	assessment := operation apply.
	assessment isApplicable ifTrue: [
		selectedModelElement := nil.
		connectionSourceModelElement := nil.
		selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: nil ].
		self refresh ].
	^ assessment
]

{ #category : 'private - interaction' }
CPProcessVisualElement >> cancelInteraction [
	connectionSourceModelElement ifNotNil: [
		connectionSourceModelElement := nil.
		self updateSelectionAppearance.
		^ self ].
	selectedModelElement := nil.
	self updateSelectionAppearance.
	selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: nil ]
]
