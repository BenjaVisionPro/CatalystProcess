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
		'diagramElements',
		'selectedModelElement',
		'selectionChangedBlock',
		'moveShapeOperationBlock',
		'createFlowNodeOperationBlock',
		'connectFlowNodesOperationBlock',
		'connectionSourceModelElement',
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
	self installPaletteDrop.
	self
		layout: BlFrameLayout new;
		clipChildren: false
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
	| diagram elements shapes edges |
	self removeChildren.
	shapeElementsByShape removeAll.
	shapeElementsByModelElement removeAll.
	edgeElementsByEdge removeAll.
	externalLabelElementsByModelElement removeAll.
	diagram := memento readUsing: diagramDescription.
	diagram ifNil: [ ^ self ].

	diagramMemento := memento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	elements ifNil: [ ^ self ].
	diagramElements := elements.

	self extent: (self canvasExtentFor: elements).
	edges := elements select: #isEdge.
	shapes := elements select: #isShape.
	shapes do: [ :each | self addShapeFor: each ].
	edges do: [ :each | self addEdgeFor: each ]
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
	self addExternalLabelFor: modelElement bounds: bounds.
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
		label constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ].
		element addChild: label ].
	^ element
]

{ #category : 'private - shapes' }
CPProcessVisualElement >> geometryFor: aFlowNode bounds: bounds [
	aFlowNode isEvent ifTrue: [ ^ BlCircleGeometry new ].
	aFlowNode isActivity ifTrue: [ ^ BlRoundedRectangleGeometry cornerRadius: 8 ].
	^ BlRectangleGeometry new
]

{ #category : 'private - labels' }
CPProcessVisualElement >> addExternalLabelFor: aFlowNode bounds: bounds [
	| labelHost label |
	aFlowNode isEvent ifFalse: [ ^ self ].
	labelHost := BlElement new
		extent: bounds width @ 28;
		layout: BlFrameLayout new;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: bounds left @ (bounds bottom + 4);
		yourself.
	label := self newEditableLabelFor: aFlowNode.
	label constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	labelHost addChild: label.
	externalLabelElementsByModelElement at: aFlowNode put: labelHost.
	self addChild: labelHost
]

{ #category : 'private - labels' }
CPProcessVisualElement >> newEditableLabelFor: aFlowElement [
	| flowMemento description editor |
	flowMemento := memento childMementoFor: aFlowElement inRelation: flowElementsDescription.
	description := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #label ].

	editor := GtMagritteStringEditorElementStencilBuilder new
		memento: flowMemento;
		description: description;
		asElement.

	editor
		fitContent;
		padding: BlInsets empty;
		margin: BlInsets empty;
		background: Color transparent;
		border: BlBorder empty;
		addShortcut: (BlShortcutWithAction new
			name: 'Finish editing process label';
			description: 'Finishes in-place label editing and returns focus to the diagram.';
			combination: BlKeyCombination enter;
			overrideChildren: true;
			action: [ :anEvent |
				anEvent currentTarget loseFocus.
				anEvent consumed: true ];
			yourself);
		addAptitude: CFMaRowEditorAptitude new;
		addAptitude: (BrLazyStyleCommonAptitude new
			default: [ :aStyle |
				aStyle
					background: Color transparent;
					border: BlBorder empty;
					foreground: self theme typography titleForeground;
					fontSize: self theme typography titleFontSize ];
			hovered: [ :aStyle |
				aStyle
					background: Color transparent;
					border: BlBorder empty ];
			focused: [ :aStyle |
				aStyle
					background: Color transparent;
					border: BlBorder empty ]);
		yourself.

	^ editor
]

{ #category : 'private - edges' }
CPProcessVisualElement >> addEdgeFor: anEdge [
	| waypoints |
	waypoints := self stagedWaypointsOf: anEdge.
	waypoints size = 2
		ifTrue: [ self addStraightEdgeFor: anEdge ]
		ifFalse: [ self addEdgeFor: anEdge waypoints: waypoints ]
]

{ #category : 'private - edges' }
CPProcessVisualElement >> addStraightEdgeFor: anEdge [
	| sequenceFlow sourceElement targetElement line source target |
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	sourceElement := shapeElementsByModelElement at: source.
	targetElement := shapeElementsByModelElement at: target.

	line := BlLineElement new
		fromAnchor: ((self anchorClassFor: source)
			nearestTo: targetElement
			from: sourceElement);
		toAnchor: ((self anchorClassFor: target)
			nearestTo: sourceElement
			from: targetElement);
		border: (BlBorder paint: self shapeBorderColor width: 1.5);
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.
	line toHead: (BlArrowheadSimpleArrow new
		border: (BlBorder paint: self shapeBorderColor width: 1.5);
		yourself).
	line userData at: #processDiagramElement put: anEdge.
	line userData at: #processModelElement put: anEdge modelElement.
	edgeElementsByEdge at: anEdge put: { line }.
	self addChildFirst: line
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
		| line |
		line := self
			newLineFrom: (waypoints at: index)
			to: (waypoints at: index + 1)
			withArrowhead: index = pairCount.
		line userData at: #processDiagramElement put: anEdge.
		line userData at: #processModelElement put: anEdge modelElement.
		lines add: line.
		self addChildFirst: line ].
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
	anElement addEventHandler: (BlEventHandler
		on: BlClickEvent
		do: [ :anEvent |
			connectionSourceModelElement
				ifNotNil: [ self completeConnectionTo: aModelElement. anEvent consumed: true ]
				ifNil: [
					selectedModelElement := aModelElement.
					self updateSelectionAppearance.
					selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: aModelElement ].
					anEvent consumed: true ] ])
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
			width: (self borderWidthFor: aModelElement selected: isSelected)) ]
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
	self refresh.
	^ assessment
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> installPositioningOn: anElement for: aShape [
	| dragStartEventPosition dragStartElementPosition originalBounds dragStartLabelPosition |
	moveShapeOperationBlock ifNil: [ ^ self ].
	anElement
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				dragStartEventPosition := anEvent position.
				dragStartElementPosition := anElement position.
				originalBounds := self stagedBoundsOf: aShape.
				dragStartLabelPosition := (externalLabelElementsByModelElement
					at: aShape modelElement
					ifAbsent: [ nil ])
					ifNotNil: [ :aLabel | aLabel position ].
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				| proposedPosition delta |
				proposedPosition := dragStartElementPosition + anEvent position - dragStartEventPosition.
				anElement relocate: proposedPosition.
				delta := anElement position - dragStartElementPosition.
				dragStartLabelPosition ifNotNil: [
					(externalLabelElementsByModelElement at: aShape modelElement)
						relocate: dragStartLabelPosition + delta ].
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				| proposedBounds |
				anEvent consumed: true.
				proposedBounds := anElement position extent: originalBounds extent.
				self moveShape: aShape toBounds: proposedBounds ])
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
CPProcessVisualElement >> installPaletteDrop [
	self addEventHandler: (BlDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea | self acceptsPaletteDragItem: aDragItem ];
		whenDragLeftDo: [ :anEvent | activePaletteDragItem := nil ];
		whenDroppedDo: [ :anEvent | self dropPaletteEvent: anEvent ];
		yourself)
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
	assessment isApplicable ifTrue: [ activePaletteDragItem := aDragItem ].
	^ assessment isApplicable
]

{ #category : 'private - creation' }
CPProcessVisualElement >> dropPaletteEvent: anEvent [
	| dragItem candidate bounds assessment |
	anEvent domainObjects size = 1 ifFalse: [ activePaletteDragItem := nil. ^ self ].
	dragItem := activePaletteDragItem.
	activePaletteDragItem := nil.
	dragItem ifNil: [ ^ self ].
	candidate := dragItem domainObject.
	bounds := anEvent position extent: (self extentForModelElement: candidate).
	assessment := (createFlowNodeOperationBlock value: candidate value: bounds) apply.
	self refresh.
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
	| port |
	connectFlowNodesOperationBlock ifNil: [ ^ self ].
	port := BlElement new
		extent: 12 @ 12;
		geometry: BlCircleGeometry new;
		background: self selectionColor;
		border: (BlBorder paint: self shapeBorderColor width: 1.5);
		constraintsDo: [ :c | c frame horizontal alignRight. c frame vertical alignCenter ];
		yourself.
	port addEventHandler: (BlEventHandler on: BlClickEvent do: [ :anEvent | self beginConnectionFrom: aFlowNode. anEvent consumed: true ]).
	aNodeElement addChild: port
]

{ #category : 'private - connection' }
CPProcessVisualElement >> beginConnectionFrom: aFlowNode [
	connectionSourceModelElement := aFlowNode.
	self updateSelectionAppearance
]

{ #category : 'private - connection' }
CPProcessVisualElement >> completeConnectionTo: aFlowNode [
	| source assessment |
	source := connectionSourceModelElement.
	connectionSourceModelElement := nil.
	source ifNil: [ ^ self ].
	source == aFlowNode ifTrue: [ self updateSelectionAppearance. ^ self ].
	assessment := (connectFlowNodesOperationBlock value: source value: aFlowNode) apply.
	self refresh.
	^ assessment
]
