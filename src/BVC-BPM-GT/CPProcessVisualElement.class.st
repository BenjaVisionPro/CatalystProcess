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
		'selectedModelElements',
		'selectionChangedBlock',
		'moveShapeOperationBlock',
		'resizeShapeOperationBlock',
		'createFlowNodeOperationBlock',
		'replaceFlowNodeOperationBlock',
		'connectFlowNodesOperationBlock',
		'insertFlowNodeOperationBlock',
		'removeFlowNodeOperationBlock',
		'removeSequenceFlowOperationBlock',
		'reconnectSequenceFlowOperationBlock',
		'setEdgeWaypointsOperationBlock',
		'connectionSourceModelElement',
		'reconnectHandleElementsByEdge',
		'bendpointHandleElementsByEdge',
		'resizeHandleElementsByShape',
		'activePaletteDragItem'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessVisualElement >> initialize [
	super initialize.
	selectedModelElements := IdentitySet new.
	shapeElementsByShape := IdentityDictionary new.
	shapeElementsByModelElement := IdentityDictionary new.
	edgeElementsByEdge := IdentityDictionary new.
	externalLabelElementsByModelElement := IdentityDictionary new.
	connectionPortElementsByModelElement := IdentityDictionary new.
	reconnectHandleElementsByEdge := IdentityDictionary new.
	bendpointHandleElementsByEdge := IdentityDictionary new.
	resizeHandleElementsByShape := IdentityDictionary new.
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
	bendpointHandleElementsByEdge removeAll.
	resizeHandleElementsByShape removeAll.
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
	self bringReconnectHandlesToFront.
	self bringBendpointHandlesToFront.
	self bringResizeHandlesToFront.
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
CPProcessVisualElement >> stagedModelElementOf: aShape [
	| shapeMemento description |
	shapeMemento := diagramMemento childMementoFor: aShape inRelation: elementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
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
	modelElement := self stagedModelElementOf: aShape.
	modelElement ifNil: [ ^ self ].
	element := self newShapeElementFor: modelElement bounds: bounds.
	element
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: bounds origin.
	element userData at: #processDiagramElement put: aShape.
	element userData at: #processModelElement put: modelElement.
	self installSelectionOn: element for: modelElement.
	self installPositioningOn: element for: aShape.
	self installReplacementOn: element for: modelElement shape: aShape.
	self installConnectionOn: element for: modelElement.
	self installTaskTypePopupOn: element for: modelElement shape: aShape.
	self installGatewayTypePopupOn: element for: modelElement shape: aShape.
	self installIntermediateEventTypePopupOn: element for: modelElement shape: aShape.
	self installStartEventTypePopupOn: element for: modelElement shape: aShape.
	self installEndEventTypePopupOn: element for: modelElement shape: aShape.
	self
		installResizeHandleFor: aShape
		modelElement: modelElement
		shapeElement: element
		bounds: bounds.
	shapeElementsByShape at: aShape put: element.
	shapeElementsByModelElement at: modelElement put: element.
	self addChild: element.
	self addExternalLabelFor: modelElement bounds: bounds shape: aShape shapeElement: element.
	self updateSelectionAppearance
]

{ #category : 'private - type selection' }
CPProcessVisualElement >> installTaskTypePopupOn: aShapeElement for: aFlowNode shape: aShape [
	aFlowNode isActivity ifFalse: [ ^ self ].
	self
		installTypePopupOn: aShapeElement
		for: aFlowNode
		shape: aShape
		selection: (CPTaskTypeSelection typeClass: aFlowNode class)
		iconExtent: 24 @ 24
		configure: [ :anElement |
			anElement constraintsDo: [ :c |
				c frame horizontal alignLeft.
				c frame vertical alignTop.
				c margin: (BlInsets top: 6 left: 6) ] ]
]

{ #category : 'private - type selection' }
CPProcessVisualElement >> installStartEventTypePopupOn: aShapeElement for: aFlowNode shape: aShape [
	aFlowNode isStartEvent ifFalse: [ ^ self ].
	self
		installTypePopupOn: aShapeElement
		for: aFlowNode
		shape: aShape
		selection: (CPStartEventTypeSelection typeClass: aFlowNode class)
		iconExtent: 22 @ 22
		configure: [ :anElement | anElement constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ] ]
]

{ #category : 'private - type selection' }
CPProcessVisualElement >> installEndEventTypePopupOn: aShapeElement for: aFlowNode shape: aShape [
	aFlowNode isEndEvent ifFalse: [ ^ self ].
	self
		installTypePopupOn: aShapeElement
		for: aFlowNode
		shape: aShape
		selection: (CPEndEventTypeSelection typeClass: aFlowNode class)
		iconExtent: 22 @ 22
		configure: [ :anElement | anElement constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ] ]
]

{ #category : 'private - type selection' }
CPProcessVisualElement >> installIntermediateEventTypePopupOn: aShapeElement for: aFlowNode shape: aShape [
	aFlowNode isIntermediateEvent ifFalse: [ ^ self ].
	self
		installTypePopupOn: aShapeElement
		for: aFlowNode
		shape: aShape
		selection: (CPIntermediateEventTypeSelection typeClass: aFlowNode class)
		iconExtent: 22 @ 22
		configure: [ :anElement |
			anElement constraintsDo: [ :c |
				c frame horizontal alignCenter.
				c frame vertical alignCenter ] ]
]

{ #category : 'private - type selection' }
CPProcessVisualElement >> installGatewayTypePopupOn: aShapeElement for: aFlowNode shape: aShape [
	aFlowNode isGateway ifFalse: [ ^ self ].
	self
		installTypePopupOn: aShapeElement
		for: aFlowNode
		shape: aShape
		selection: (CPGatewayTypeSelection typeClass: aFlowNode class)
		iconExtent: 28 @ 28
		configure: [ :anElement |
			anElement constraintsDo: [ :c |
				c frame horizontal alignCenter.
				c frame vertical alignCenter ] ]
]

{ #category : 'private - type selection' }
CPProcessVisualElement >> installTypePopupOn: aShapeElement for: aFlowNode shape: aShape selection: aSelection iconExtent: anExtent configure: aConfigureBlock [
	| aSelectionMemento aDescription aPresentation aPopup anIconBlock aVisibleIcon aVisibleHost |
	aSelectionMemento := CFMaMemento model: aSelection.
	aDescription := aSelectionMemento magritteDescription
		detect: [ :each | each handlesSelector: #typeClass ].
	aPresentation := CFMaDetailPresentation new
		memento: aSelectionMemento;
		form: aShapeElement;
		yourself.
	anIconBlock := aDescription blocOptionIconStencil.
	aPopup := aPresentation
		newPopupUsing: aDescription
		values: aDescription options
		display: [ :aClass | aSelection typeLabelFor: aClass ]
		icon: anIconBlock.

	aVisibleIcon := anIconBlock value: aFlowNode class.
	aVisibleIcon constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	aVisibleHost := BlElement new
		extent: anExtent;
		layout: BlFrameLayout new;
		addChild: aVisibleIcon;
		yourself.
	aConfigureBlock value: aVisibleHost.
	aShapeElement addChild: aVisibleHost.

	aPopup
		opacity: 0.0;
		extent: anExtent.
	aConfigureBlock value: aPopup.
	aPopup
		when: BrDropdownIsHidden
		do: [ :anEvent |
			| selectedClass |
			selectedClass := aSelectionMemento readUsing: aDescription.
			selectedClass == aFlowNode class ifFalse: [
				aShapeElement enqueueTask: (BlTaskAction new action: [
					self
						replaceFlowNode: aFlowNode
						withClass: selectedClass
						shape: aShape ]) ] ].
	aShapeElement addChild: aPopup
]

{ #category : 'private - type selection' }
CPProcessVisualElement >> replaceFlowNode: aFlowNode withClass: aFlowNodeClass shape: aShape [
	| replacement proposedBounds assessment |
	replaceFlowNodeOperationBlock ifNil: [ ^ nil ].
	replacement := aFlowNodeClass new.
	proposedBounds := self stagedBoundsOf: aShape.

	assessment := (replaceFlowNodeOperationBlock
		value: aFlowNode
		value: replacement
		value: proposedBounds) apply.

	assessment isApplicable ifTrue: [
		selectedModelElements removeAll.
		selectedModelElements add: replacement.
		selectedModelElement := replacement.
		self refresh.
		self updateSelectionAppearance.
		selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: replacement ] ].
	^ assessment
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

	aFlowNode isIntermediateEvent ifTrue: [
		| innerRing |
		innerRing := BlElement new
			extent: bounds extent - (8 @ 8);
			geometry: BlCircleGeometry new;
			background: Color transparent;
			border: (BlBorder paint: self shapeBorderColor width: 1.5);
			constraintsDo: [ :c |
				c frame horizontal alignCenter.
				c frame vertical alignCenter ];
			preventMeAndChildrenMouseEvents;
			yourself.
		element addChild: innerRing ].

	^ element
]

{ #category : 'private - shapes' }
CPProcessVisualElement >> geometryFor: aFlowNode bounds: bounds [
	aFlowNode isEvent ifTrue: [ ^ BlCircleGeometry new ].
	aFlowNode isActivity ifTrue: [ ^ BlRoundedRectangleGeometry cornerRadius: 8 ].
	aFlowNode isGateway ifTrue: [
		^ BlPolygonGeometry vertices: {
			bounds width / 2 @ 0.
			bounds width @ (bounds height / 2).
			bounds width / 2 @ bounds height.
			0 @ (bounds height / 2) } ].
	^ BlRectangleGeometry new
]

{ #category : 'private - labels' }
CPProcessVisualElement >> addExternalLabelFor: aFlowNode bounds: bounds shape: aShape shapeElement: aShapeElement [
	| labelHost label labelWidth |
	(aFlowNode isEvent or: [ aFlowNode isGateway ]) ifFalse: [ ^ self ].
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
	self installReconnectHandlesFor: anEdge.
	self installBendpointHandlesFor: anEdge
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
	self installPaletteInsertionOn: selectionLine for: anEdge.

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

{ #category : 'private - layout' }
CPProcessVisualElement >> bringReconnectHandlesToFront [
	reconnectHandleElementsByEdge valuesDo: [ :someHandles |
		someHandles do: [ :aHandle |
			aHandle removeFromParent.
			self addChild: aHandle ] ]
]

{ #category : 'private - edges' }
CPProcessVisualElement >> anchorClassFor: aFlowNode [
	aFlowNode isEvent ifTrue: [ ^ BlNearestPositionEllipseAnchor ].
	aFlowNode isGateway ifTrue: [ ^ CPNearestPositionDiamondAnchor ].
	^ BlNearestPositionBoundsAnchor
]

{ #category : 'private - edges' }
CPProcessVisualElement >> addEdgeFor: anEdge waypoints: waypoints [
	| sequenceFlow source target sourceElement targetElement interiorPoints
	  sourceReference targetReference pairCount lines |
	waypoints size < 3 ifTrue: [ ^ self addStraightEdgeFor: anEdge ].
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	sourceElement := shapeElementsByModelElement at: source.
	targetElement := shapeElementsByModelElement at: target.
	interiorPoints := waypoints copyFrom: 2 to: waypoints size - 1.

	sourceReference := self anchorReferenceElementAt: interiorPoints first.
	targetReference := self anchorReferenceElementAt: interiorPoints last.
	self addChild: sourceReference.
	self addChild: targetReference.

	lines := OrderedCollection new.
	pairCount := interiorPoints size + 1.
	1 to: pairCount do: [ :index |
		| fromAnchor toAnchor line selectionLine |
		index = 1
			ifTrue: [
				fromAnchor := (self anchorClassFor: source)
					nearestTo: sourceReference
					from: sourceElement.
				toAnchor := BlAbsolutePositionAnchor position: interiorPoints first ]
			ifFalse: [
				index = pairCount
					ifTrue: [
						fromAnchor := BlAbsolutePositionAnchor position: interiorPoints last.
						toAnchor := (self anchorClassFor: target)
							nearestTo: targetReference
							from: targetElement ]
					ifFalse: [
						fromAnchor := BlAbsolutePositionAnchor position: (interiorPoints at: index - 1).
						toAnchor := BlAbsolutePositionAnchor position: (interiorPoints at: index) ] ].

		selectionLine := BlLineElement new
			fromAnchor: fromAnchor;
			toAnchor: toAnchor;
			border: (BlBorder paint: Color transparent width: 6);
			constraintsDo: [ :c | c ignoreByLayout ];
			yourself.
		selectionLine userData at: #processDiagramElement put: anEdge.
		selectionLine userData at: #processModelElement put: anEdge modelElement.
		self installEdgeSelectionOn: selectionLine for: anEdge.
	self installPaletteInsertionOn: selectionLine for: anEdge.

		line := BlLineElement new
			fromAnchor: fromAnchor;
			toAnchor: toAnchor;
			border: (BlBorder paint: self shapeBorderColor width: 1.5);
			constraintsDo: [ :c | c ignoreByLayout ];
			yourself.
		index = pairCount ifTrue: [
			line toHead: (BlArrowheadSimpleArrow new
				border: (BlBorder paint: self shapeBorderColor width: 1.5)) ].
		line userData at: #processDiagramElement put: anEdge.
		line userData at: #processModelElement put: anEdge modelElement.
		self installEdgeSelectionOn: line for: anEdge.
		lines add: line.
		self addChild: selectionLine.
		self addChild: line ].
	edgeElementsByEdge at: anEdge put: lines
]

{ #category : 'private - edges' }
CPProcessVisualElement >> anchorReferenceElementAt: aPoint [
	^ BlElement new
		extent: 1 @ 1;
		background: Color transparent;
		preventMeAndChildrenMouseEvents;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: aPoint;
		yourself
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
						anEvent modifiers isShift
							ifTrue: [ self toggleSelectionOf: aModelElement ]
							ifFalse: [ self selectOnly: aModelElement ].
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

{ #category : 'private - selection' }
CPProcessVisualElement >> selectOnly: aModelElement [
	selectedModelElements removeAll.
	selectedModelElements add: aModelElement.
	selectedModelElement := aModelElement.
	self updateSelectionAppearance.
	selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: aModelElement ]
]

{ #category : 'private - selection' }
CPProcessVisualElement >> toggleSelectionOf: aModelElement [
	(selectedModelElements includes: aModelElement)
		ifTrue: [
			selectedModelElements remove: aModelElement.
			selectedModelElement == aModelElement ifTrue: [
				selectedModelElement := selectedModelElements
					ifEmpty: [ nil ]
					ifNotEmpty: [ selectedModelElements anyOne ] ] ]
		ifFalse: [
			selectedModelElements add: aModelElement.
			selectedModelElement := aModelElement ].
	self updateSelectionAppearance.
	selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: selectedModelElement ]
]

{ #category : 'selection' }
CPProcessVisualElement >> selectedModelElements [
	^ selectedModelElements copy
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
		isSelected := (selectedModelElements includes: aModelElement) or: [ aModelElement == connectionSourceModelElement ].
		anElement border: (BlBorder
			paint: (isSelected
				ifTrue: [ self selectionColor ]
				ifFalse: [ self shapeBorderColor ])
			width: (self borderWidthFor: aModelElement selected: isSelected)) ].
	edgeElementsByEdge keysAndValuesDo: [ :anEdge :someLines |
		| isSelected |
		isSelected := selectedModelElements includes: anEdge modelElement.
		someLines do: [ :aLine |
			aLine border: (BlBorder
				paint: (isSelected ifTrue: [ self selectionColor ] ifFalse: [ self shapeBorderColor ])
				width: (isSelected ifTrue: [ 3 ] ifFalse: [ 1.5 ])) ] ].
	self updateReconnectHandlePositions.
	reconnectHandleElementsByEdge keysAndValuesDo: [ :anEdge :someHandles |
		| visibility |
		visibility := anEdge modelElement == selectedModelElement
			ifTrue: [ BlVisibility visible ]
			ifFalse: [ BlVisibility hidden ].
		someHandles do: [ :aHandle | aHandle visibility: visibility ] ].
	bendpointHandleElementsByEdge keysAndValuesDo: [ :anEdge :someHandles |
		| visibility |
		visibility := anEdge modelElement == selectedModelElement
			ifTrue: [ BlVisibility visible ]
			ifFalse: [ BlVisibility hidden ].
		someHandles do: [ :aHandle | aHandle visibility: visibility ] ].
	resizeHandleElementsByShape keysAndValuesDo: [ :aShape :aHandle |
		| modelElement |
		modelElement := self stagedModelElementOf: aShape.
		aHandle visibility: ((modelElement == selectedModelElement)
			ifTrue: [ BlVisibility visible ]
			ifFalse: [ BlVisibility hidden ]) ].
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

{ #category : 'configuration' }
CPProcessVisualElement >> resizeShapeOperationFor: aBlock [
	resizeShapeOperationBlock := aBlock
]

{ #category : 'operations' }
CPProcessVisualElement >> resizeShape: aShape toBounds: aRectangle [
	| assessment |
	resizeShapeOperationBlock ifNil: [ ^ nil ].
	assessment := (resizeShapeOperationBlock value: aShape value: aRectangle) apply.
	assessment isApplicable ifFalse: [ self refresh ].
	^ assessment
]

{ #category : 'private - resizing' }
CPProcessVisualElement >> installResizeHandleFor: aShape modelElement: aModelElement shapeElement: aShapeElement bounds: initialBounds [
	| handle handleExtent isDragging dragStartEventPosition dragStartExtent minimumExtent |
	resizeShapeOperationBlock ifNil: [ ^ self ].
	aModelElement isActivity ifFalse: [ ^ self ].

	handleExtent := 9 @ 9.
	minimumExtent := self extentForModelElement: aModelElement.
	isDragging := false.
	handle := BlElement new
		extent: handleExtent;
		geometry: BlRectangleGeometry new;
		background: Color white;
		border: (BlBorder paint: self selectionColor width: 1.5);
		visibility: BlVisibility hidden;
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.

	self
		positionResizeHandle: handle
		forBounds: initialBounds
		handleExtent: handleExtent.

	handle
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent | anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				isDragging := true.
				dragStartEventPosition := anEvent position.
				dragStartExtent := aShapeElement extent.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| delta proposedExtent |
					delta := anEvent position - dragStartEventPosition.
					proposedExtent :=
						((dragStartExtent x + delta x) max: minimumExtent x)
						@ ((dragStartExtent y + delta y) max: minimumExtent y).
					aShapeElement extent: proposedExtent.
					self
						positionResizeHandle: handle
						forShapeElement: aShapeElement
						handleExtent: handleExtent.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| currentBounds proposedBounds |
					isDragging := false.
					currentBounds := self stagedBoundsOf: aShape.
					proposedBounds := currentBounds origin extent: aShapeElement extent.
					self resizeShape: aShape toBounds: proposedBounds.
					anEvent consumed: true ] ]).

	resizeHandleElementsByShape at: aShape put: handle.
	self addChild: handle
]

{ #category : 'private - resizing' }
CPProcessVisualElement >> positionResizeHandle: aHandle forBounds: aRectangle handleExtent: handleExtent [
	aHandle relocate:
		aRectangle bottomRight - (handleExtent / 2)
]

{ #category : 'private - resizing' }
CPProcessVisualElement >> positionResizeHandle: aHandle forShapeElement: aShapeElement handleExtent: handleExtent [
	aHandle relocate:
		aShapeElement position
			+ aShapeElement extent
			- (handleExtent / 2)
]

{ #category : 'private - layout' }
CPProcessVisualElement >> bringResizeHandlesToFront [
	resizeHandleElementsByShape valuesDo: [ :aHandle |
		aHandle removeFromParent.
		self addChild: aHandle ]
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
	| dragStartEventPosition dragStartElementPosition originalBounds dragStartLabelPosition draggedModelElement isDragging |
	moveShapeOperationBlock ifNil: [ ^ self ].
	isDragging := false.
	anInteractionElement
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				dragStartEventPosition := anEvent position.
				dragStartElementPosition := aShapeElement position.
				originalBounds := self stagedBoundsOf: aShape.
				draggedModelElement := self stagedModelElementOf: aShape.
				dragStartLabelPosition := (externalLabelElementsByModelElement
					at: draggedModelElement
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
						(externalLabelElementsByModelElement at: draggedModelElement)
							relocate: dragStartLabelPosition + delta ].
					(resizeHandleElementsByShape
						at: aShape
						ifAbsent: [ nil ])
						ifNotNil: [ :aResizeHandle |
							self
								positionResizeHandle: aResizeHandle
								forShapeElement: aShapeElement
								handleExtent: 9 @ 9 ].
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
CPProcessVisualElement >> insertFlowNodeOperationFor: aBlock [
	insertFlowNodeOperationBlock := aBlock
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> installPaletteInsertionOn: anEdgeElement for: anEdge [
	insertFlowNodeOperationBlock ifNil: [ ^ self ].
	anEdgeElement addEventHandler: (CPProcessPaletteDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea |
			self acceptsPaletteDragItem: aDragItem insertingInto: anEdge ];
		whenDroppedDo: [ :anEvent |
			self dropPaletteEvent: anEvent insertingInto: anEdge ];
		yourself)
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> acceptsPaletteDragItem: aDragItem insertingInto: anEdge [
	| sourceElement candidate proposedBounds assessment |
	insertFlowNodeOperationBlock ifNil: [ ^ false ].
	sourceElement := aDragItem sourceElement.
	sourceElement ifNil: [ ^ false ].
	(sourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	candidate := aDragItem domainObject.
	proposedBounds := 0 @ 0 extent: (self extentForModelElement: candidate).
	assessment := (insertFlowNodeOperationBlock
		value: anEdge modelElement
		value: candidate
		value: proposedBounds) assess.
	^ assessment isApplicable
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> dropPaletteEvent: anEvent insertingInto: anEdge [
	| dragItem candidate elementExtent origin bounds assessment |
	anEvent items size = 1 ifFalse: [ ^ self ].
	dragItem := anEvent items first.
	candidate := dragItem domainObject.
	elementExtent := self extentForModelElement: candidate.
	origin :=
		((anEvent position x - (elementExtent x / 2)) max: 0)
		@ ((anEvent position y - (elementExtent y / 2)) max: 0).
	bounds := origin extent: elementExtent.
	assessment := (insertFlowNodeOperationBlock
		value: anEdge modelElement
		value: candidate
		value: bounds) apply.
	assessment isApplicable ifTrue: [
		selectedModelElements removeAll.
		selectedModelElements add: candidate.
		selectedModelElement := candidate.
		self refresh.
		self updateSelectionAppearance.
		selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: candidate ] ].
	^ assessment
]

{ #category : 'configuration' }
CPProcessVisualElement >> replaceFlowNodeOperationFor: aBlock [ replaceFlowNodeOperationBlock := aBlock ]
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

{ #category : 'private - replacement' }
CPProcessVisualElement >> installReplacementOn: aNodeElement for: aFlowNode shape: aShape [
	replaceFlowNodeOperationBlock ifNil: [ ^ self ].
	aNodeElement addEventHandler: (CPProcessPaletteDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea |
			self acceptsPaletteDragItem: aDragItem replacing: aFlowNode shape: aShape ];
		whenDroppedDo: [ :anEvent |
			self dropPaletteEvent: anEvent replacing: aFlowNode shape: aShape ];
		yourself)
]

{ #category : 'private - replacement' }
CPProcessVisualElement >> acceptsPaletteDragItem: aDragItem replacing: aFlowNode shape: aShape [
	| sourceElement candidate proposedBounds assessment |
	replaceFlowNodeOperationBlock ifNil: [ ^ false ].
	aFlowNode == selectedModelElement ifFalse: [ ^ false ].
	sourceElement := aDragItem sourceElement.
	sourceElement ifNil: [ ^ false ].
	(sourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	candidate := aDragItem domainObject.
	candidate class = aFlowNode class ifTrue: [ ^ false ].
	proposedBounds := self replacementBoundsFor: candidate shape: aShape.
	assessment := (replaceFlowNodeOperationBlock
		value: aFlowNode
		value: candidate
		value: proposedBounds) assess.
	^ assessment isApplicable
]

{ #category : 'private - replacement' }
CPProcessVisualElement >> dropPaletteEvent: anEvent replacing: aFlowNode shape: aShape [
	| dragItem candidate proposedBounds assessment |
	anEvent items size = 1 ifFalse: [ ^ self ].
	dragItem := anEvent items first.
	candidate := dragItem domainObject.
	proposedBounds := self replacementBoundsFor: candidate shape: aShape.
	assessment := (replaceFlowNodeOperationBlock
		value: aFlowNode
		value: candidate
		value: proposedBounds) apply.
	assessment isApplicable ifTrue: [
		selectedModelElements removeAll.
		selectedModelElements add: candidate.
		selectedModelElement := candidate.
		self refresh.
		self updateSelectionAppearance.
		selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: candidate ] ].
	^ assessment
]

{ #category : 'private - replacement' }
CPProcessVisualElement >> replacementBoundsFor: aFlowNode shape: aShape [
	| currentBounds replacementExtent replacementOrigin |
	currentBounds := self stagedBoundsOf: aShape.
	replacementExtent := self extentForModelElement: aFlowNode.
	replacementOrigin := currentBounds center - (replacementExtent / 2).
	^ replacementOrigin extent: replacementExtent
]

{ #category : 'private - shapes' }
CPProcessVisualElement >> extentForModelElement: aFlowNode [
	aFlowNode isEvent ifTrue: [ ^ 42 @ 42 ].
	aFlowNode isActivity ifTrue: [ ^ 132 @ 54 ].
	aFlowNode isGateway ifTrue: [ ^ 54 @ 54 ].
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

{ #category : 'configuration' }
CPProcessVisualElement >> setEdgeWaypointsOperationFor: aBlock [
	setEdgeWaypointsOperationBlock := aBlock
]

{ #category : 'operations' }
CPProcessVisualElement >> setWaypoints: somePoints forEdge: anEdge [
	| assessment |
	setEdgeWaypointsOperationBlock ifNil: [ ^ nil ].
	assessment := (setEdgeWaypointsOperationBlock value: anEdge value: somePoints) apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateSelectionAppearance ].
	^ assessment
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> installBendpointHandlesFor: anEdge [
	| waypoints handles |
	setEdgeWaypointsOperationBlock ifNil: [ ^ self ].
	waypoints := self stagedWaypointsOf: anEdge.
	waypoints size < 2 ifTrue: [ ^ self ].
	handles := OrderedCollection new.

	"Existing intermediate waypoints are direct manipulation handles."
	2 to: waypoints size - 1 do: [ :index |
		handles add: (self
			newBendpointHandleFor: anEdge
			waypointIndex: index
			at: (waypoints at: index)
			inserting: false) ].

	"Every segment gets a midpoint insertion handle. The insertion index is
	the index the new waypoint will occupy."
	1 to: waypoints size - 1 do: [ :index |
		handles add: (self
			newBendpointHandleFor: anEdge
			waypointIndex: index + 1
			at: ((waypoints at: index) + (waypoints at: index + 1)) / 2
			inserting: true) ].

	bendpointHandleElementsByEdge at: anEdge put: handles.
	handles do: [ :aHandle | self addChild: aHandle ]
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> newBendpointHandleFor: anEdge waypointIndex: waypointIndex at: aPoint inserting: insertsWaypoint [
	| handle handleExtent dragStartEventPosition dragStartHandlePosition isDragging previewLines |
	isDragging := false.
	previewLines := #().
	handleExtent := insertsWaypoint ifTrue: [ 7 @ 7 ] ifFalse: [ 9 @ 9 ].
	handle := BlElement new
		extent: handleExtent;
		geometry: BlRectangleGeometry new;
		background: Color white;
		border: (BlBorder
			paint: self selectionColor
			width: (insertsWaypoint ifTrue: [ 1 ] ifFalse: [ 1.5 ]));
		visibility: BlVisibility hidden;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: aPoint - (handleExtent / 2);
		yourself.
	handle
		addEventHandler: (BlEventHandler on: BlClickEvent do: [ :anEvent | anEvent consumed: true ]).
	insertsWaypoint ifFalse: [
		handle addEventHandler: (BlEventHandler
			on: BlDoubleClickEvent
			do: [ :anEvent |
				| waypoints proposed |
				waypoints := (self stagedWaypointsOf: anEdge) asOrderedCollection.
				waypoints size > 2 ifTrue: [
					proposed := waypoints copy.
					proposed removeAt: waypointIndex.
					self setWaypoints: proposed forEdge: anEdge ].
				anEvent consumed: true ]) ].
	handle
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				dragStartEventPosition := anEvent position.
				dragStartHandlePosition := handle position.
				isDragging := true.
				(edgeElementsByEdge at: anEdge ifAbsent: [ #() ])
					do: [ :aLine | aLine visibility: BlVisibility hidden ].
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| newPoint proposed |
					handle relocate: dragStartHandlePosition + anEvent position - dragStartEventPosition.
					newPoint := handle position + (handle extent / 2).
					proposed := self
						previewWaypointsFor: anEdge
						waypointIndex: waypointIndex
						at: newPoint
						inserting: insertsWaypoint.
					previewLines do: [ :aLine | aLine removeFromParent ].
					previewLines := self newPreviewLinesFor: anEdge waypoints: proposed.
					previewLines do: [ :aLine | self addChild: aLine ].
					self
						positionReconnectHandlesFor: anEdge
						usingWaypoints: proposed.
					self bringReconnectHandlesToFront.
					self bringBendpointHandlesToFront.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| newPoint proposed |
					isDragging := false.
					newPoint := handle position + (handle extent / 2).
					proposed := self
						previewWaypointsFor: anEdge
						waypointIndex: waypointIndex
						at: newPoint
						inserting: insertsWaypoint.
					previewLines do: [ :aLine | aLine removeFromParent ].
					previewLines := #().
					(edgeElementsByEdge at: anEdge ifAbsent: [ #() ])
						do: [ :aLine | aLine visibility: BlVisibility visible ].
					self setWaypoints: proposed forEdge: anEdge.
					anEvent consumed: true ] ]).
	^ handle
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> previewWaypointsFor: anEdge waypointIndex: waypointIndex at: aPoint inserting: insertsWaypoint [
	| proposed |
	proposed := (self stagedWaypointsOf: anEdge) asOrderedCollection copy.
	insertsWaypoint ifTrue: [
		proposed add: aPoint afterIndex: waypointIndex - 1.
		^ proposed ].
	proposed at: waypointIndex put: aPoint.
	^ proposed
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> newPreviewLinesFor: anEdge waypoints: someWaypoints [
	| sequenceFlow source target sourceElement targetElement interiorPoints
	  sourceReference targetReference pairCount lines |
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	sourceElement := shapeElementsByModelElement at: source.
	targetElement := shapeElementsByModelElement at: target.
	interiorPoints := someWaypoints copyFrom: 2 to: someWaypoints size - 1.

	sourceReference := self anchorReferenceElementAt: interiorPoints first.
	targetReference := self anchorReferenceElementAt: interiorPoints last.
	self addChild: sourceReference.
	self addChild: targetReference.

	lines := OrderedCollection new.
	pairCount := interiorPoints size + 1.
	1 to: pairCount do: [ :index |
		| fromAnchor toAnchor line |
		index = 1
			ifTrue: [
				fromAnchor := (self anchorClassFor: source)
					nearestTo: sourceReference
					from: sourceElement.
				toAnchor := BlAbsolutePositionAnchor position: interiorPoints first ]
			ifFalse: [
				index = pairCount
					ifTrue: [
						fromAnchor := BlAbsolutePositionAnchor position: interiorPoints last.
						toAnchor := (self anchorClassFor: target)
							nearestTo: targetReference
							from: targetElement ]
					ifFalse: [
						fromAnchor := BlAbsolutePositionAnchor position: (interiorPoints at: index - 1).
						toAnchor := BlAbsolutePositionAnchor position: (interiorPoints at: index) ] ].
		line := BlLineElement new
			fromAnchor: fromAnchor;
			toAnchor: toAnchor;
			border: (BlBorder paint: self selectionColor width: 3);
			constraintsDo: [ :c | c ignoreByLayout ];
			yourself.
		index = pairCount ifTrue: [
			line toHead: (BlArrowheadSimpleArrow new
				border: (BlBorder paint: self selectionColor width: 3)) ].
		lines add: line ].
	^ lines
]

{ #category : 'private - layout' }
CPProcessVisualElement >> bringBendpointHandlesToFront [
	bendpointHandleElementsByEdge valuesDo: [ :someHandles |
		someHandles do: [ :aHandle |
			aHandle removeFromParent.
			self addChild: aHandle ] ]
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> installReconnectHandlesFor: anEdge [
	| sequenceFlow source target sourceElement targetElement lines sourceLine targetLine sourceHandle targetHandle |
	reconnectSequenceFlowOperationBlock ifNil: [ ^ self ].
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	sourceElement := shapeElementsByModelElement at: source ifAbsent: [ ^ self ].
	targetElement := shapeElementsByModelElement at: target ifAbsent: [ ^ self ].
	lines := edgeElementsByEdge at: anEdge ifAbsent: [ ^ self ].
	lines ifEmpty: [ ^ self ].
	sourceLine := lines first.
	targetLine := lines last.

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
	self addChild: sourceHandle.
	self addChild: targetHandle
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> newReconnectHandleFor: aSequenceFlow movingSource: movesSource owner: ownerElement other: otherElement [
	| handle isDragging previewLine previewCursor |
	isDragging := false.
	handle := BlElement new
		extent: 10 @ 10;
		geometry: BlCircleGeometry new;
		background: Color white;
		border: (BlBorder paint: self selectionColor width: 2);
		visibility: BlVisibility hidden;
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.

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
CPProcessVisualElement >> updateReconnectHandlePositions [
	reconnectHandleElementsByEdge keysAndValuesDo: [ :anEdge :someHandles |
		self
			positionReconnectHandlesFor: anEdge
			fromLines: (edgeElementsByEdge at: anEdge ifAbsent: [ #() ]) ]
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> positionReconnectHandlesFor: anEdge fromLines: someLines [
	| handles firstLine lastLine sourcePoint targetPoint |
	someLines ifEmpty: [ ^ self ].
	handles := reconnectHandleElementsByEdge at: anEdge ifAbsent: [ ^ self ].
	handles ifEmpty: [ ^ self ].

	firstLine := someLines first.
	lastLine := someLines last.
	sourcePoint := firstLine fromAnchor
		positionForAnchoredElement: firstLine
		within: self.
	targetPoint := lastLine toAnchor
		positionForAnchoredElement: lastLine
		within: self.

	self positionReconnectHandle: handles first at: sourcePoint.
	self positionReconnectHandle: handles last at: targetPoint
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> positionReconnectHandlesFor: anEdge usingWaypoints: someWaypoints [
	| handles sequenceFlow source target sourceElement targetElement interiorPoints sourcePoint targetPoint |
	someWaypoints size < 3 ifTrue: [ ^ self ].
	handles := reconnectHandleElementsByEdge at: anEdge ifAbsent: [ ^ self ].
	handles ifEmpty: [ ^ self ].

	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	sourceElement := shapeElementsByModelElement at: source ifAbsent: [ ^ self ].
	targetElement := shapeElementsByModelElement at: target ifAbsent: [ ^ self ].
	interiorPoints := someWaypoints copyFrom: 2 to: someWaypoints size - 1.

	sourcePoint := self
		dockingPointFor: source
		element: sourceElement
		toward: interiorPoints first.
	targetPoint := self
		dockingPointFor: target
		element: targetElement
		toward: interiorPoints last.

	self positionReconnectHandle: handles first at: sourcePoint.
	self positionReconnectHandle: handles last at: targetPoint
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> dockingPointFor: aFlowNode element: aNodeElement toward: aPoint [
	^ aFlowNode isEvent
		ifTrue: [ self ellipseDockingPointFor: aNodeElement toward: aPoint ]
		ifFalse: [ self boundsDockingPointFor: aNodeElement toward: aPoint ]
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> boundsDockingPointFor: aNodeElement toward: aPoint [
	| bounds center direction scaleX scaleY scale |
	bounds := aNodeElement bounds inParent: self.
	center := bounds center.
	direction := aPoint - center.
	direction isZero ifTrue: [ ^ center ].

	scaleX := direction x isZero
		ifTrue: [ Float infinity ]
		ifFalse: [ (bounds width / 2.0) / direction x abs ].
	scaleY := direction y isZero
		ifTrue: [ Float infinity ]
		ifFalse: [ (bounds height / 2.0) / direction y abs ].
	scale := scaleX min: scaleY.
	^ center + (direction * scale)
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> ellipseDockingPointFor: aNodeElement toward: aPoint [
	| bounds center direction major minor metric k intersection |
	bounds := aNodeElement bounds inParent: self.
	center := bounds center.
	direction := aPoint - center.
	direction isZero ifTrue: [ ^ center ].

	major := bounds width / 2.0.
	minor := bounds height / 2.0.
	metric := ((major * major * direction y * direction y)
		+ (minor * minor * direction x * direction x)) sqrt.
	metric isZero ifTrue: [ ^ center ].
	k := (major * minor) / metric.
	intersection := (k * direction x) @ (k * direction y).
	^ center + intersection
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> positionReconnectHandle: aHandle at: anEndpoint [
	aHandle relocate: anEndpoint - (aHandle extent / 2)
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
				anEvent modifiers isShift
					ifTrue: [ self toggleSelectionOf: anEdge modelElement ]
					ifFalse: [ self selectOnly: anEdge modelElement ].
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
	| selectedNodes selectedFlows edgeForFlow assessments rejected |
	selectedModelElements isEmpty ifTrue: [ ^ self ].

	selectedNodes := selectedModelElements select: [ :each |
		shapeElementsByModelElement includesKey: each ].
	selectedFlows := selectedModelElements select: [ :each |
		edgeForFlow := edgeElementsByEdge keys
			detect: [ :anEdge | anEdge modelElement == each ]
			ifNone: [ nil ].
		edgeForFlow notNil and: [
			selectedNodes noneSatisfy: [ :aNode |
				self edge: edgeForFlow isIncidentTo: aNode ] ] ].

	assessments := OrderedCollection new.
	selectedNodes do: [ :aNode |
		removeFlowNodeOperationBlock ifNotNil: [
			assessments add: (removeFlowNodeOperationBlock value: aNode) ] ].
	selectedFlows do: [ :aFlow |
		removeSequenceFlowOperationBlock ifNotNil: [
			assessments add: (removeSequenceFlowOperationBlock value: aFlow) ] ].

	rejected := assessments
		detect: [ :anOperation | anOperation assess isApplicable not ]
		ifNone: [ nil ].
	rejected ifNotNil: [ ^ rejected assess ].

	assessments do: [ :anOperation | anOperation apply ].
	selectedModelElements removeAll.
	selectedModelElement := nil.
	connectionSourceModelElement := nil.
	selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: nil ].
	self refresh
]

{ #category : 'private - interaction' }
CPProcessVisualElement >> cancelInteraction [
	connectionSourceModelElement ifNotNil: [
		connectionSourceModelElement := nil.
		self updateSelectionAppearance.
		^ self ].
	selectedModelElements removeAll.
	selectedModelElement := nil.
	self updateSelectionAppearance.
	selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: nil ]
]
