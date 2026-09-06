"I render and coordinate one BPMN flow-container editing surface inside the single enclosing Atelier editor.

For the root I render CPProcess. For an expanded Sub-Process, its CPProcessShapeElement hosts another instance of me configured for that CPSubProcess. The nested instance uses the same root memento, operation configuration, selection notification and diagram state; it is a Bloc child of the Sub-Process node, not another Atelier.

Each instance renders only the flow elements directly owned by its configured flow container. Natural Bloc containment therefore supplies nested movement and clipping. Each process surface owns its own local BPMN-DI coordinate space. Nested DI therefore remains unchanged when its hosting Sub-Process node moves."
Class {
	#name : 'CPProcessVisualElement',
	#superclass : 'BlElement',
	#instVars : [
		'memento',
		'flowContainer',
		'rootVisual',
		'parentProcessVisual',
		'hostShape',
		'diagramDescription',
		'diagramMemento',
		'elementsDescription',
		'shapeElementsByShape',
		'shapeElementsByModelElement',
		'edgeVisualsByEdge',
		'hoveredModelElement',
		'diagramElements',
		'selectedModelElement',
		'selectedModelElements',
		'selectionChangedBlock',
		'moveShapeOperationBlock',
		'transferFlowNodeOperationBlock',
		'moveShapesOperationBlock',
		'resizeShapeOperationBlock',
		'createFlowNodeOperationBlock',
		'replaceFlowNodeOperationBlock',
		'connectFlowNodesOperationBlock',
		'insertFlowNodeOperationBlock',
		'removeFlowNodeOperationBlock',
		'removeSequenceFlowOperationBlock',
		'reconnectSequenceFlowOperationBlock',
		'setEdgeWaypointsOperationBlock',
		'setShapeExpandedOperationBlock',
		'setEdgeLabelPlacementOperationBlock',
		'connectionSourceModelElement',
		'connectionTargetModelElement',
		'insertionTargetEdge'
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
	edgeVisualsByEdge := IdentityDictionary new.
	rootVisual := self.
	parentProcessVisual := nil.
	hostShape := nil.
	self
		layout: BlFrameLayout new;
		clipChildren: false;
		beFocusable.
	self installDiagramCursor.
	self installKeyboardHandler.
	self installPaletteDropHandler
]

{ #category : 'accessing' }
CPProcessVisualElement >> memento: aMemento [
	^ self
		memento: aMemento
		flowContainer: aMemento model
]

{ #category : 'accessing' }
CPProcessVisualElement >> memento: aMemento flowContainer: aFlowContainer [
	memento := aMemento.
	flowContainer := aFlowContainer.
	diagramDescription := memento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	self refresh
]

{ #category : 'accessing' }
CPProcessVisualElement >> flowContainer [
	^ flowContainer
]

{ #category : 'accessing' }
CPProcessVisualElement >> rootVisual [
	^ rootVisual
]

{ #category : 'accessing' }
CPProcessVisualElement >> rootVisual: aProcessVisual [
	rootVisual := aProcessVisual
]


{ #category : 'accessing' }
CPProcessVisualElement >> parentProcessVisual: aProcessVisual [
	parentProcessVisual := aProcessVisual
]


{ #category : 'accessing' }
CPProcessVisualElement >> hostShape: aShape [
	hostShape := aShape
]

{ #category : 'private - containment' }
CPProcessVisualElement >> rootDiagramPointForLocalPoint: aPoint [
	parentProcessVisual ifNil: [ ^ aPoint ].
	^ parentProcessVisual rootDiagramPointForLocalPoint:
		((parentProcessVisual stagedBoundsOf: hostShape) origin + aPoint)
]

{ #category : 'private - containment' }
CPProcessVisualElement >> localPointForRootDiagramPoint: aPoint [
	| hostOrigin |
	parentProcessVisual ifNil: [ ^ aPoint ].
	hostOrigin := parentProcessVisual
		rootDiagramPointForLocalPoint: (parentProcessVisual stagedBoundsOf: hostShape) origin.
	^ aPoint - hostOrigin
]

{ #category : 'updating' }
CPProcessVisualElement >> refreshEditor [
	rootVisual refresh
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
	edgeVisualsByEdge removeAll.
	hoveredModelElement := nil.
	insertionTargetEdge := nil.
	connectionTargetModelElement := nil.
	diagram := memento readUsing: diagramDescription.
	diagram ifNil: [ ^ self ].

	diagramMemento := memento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	elements ifNil: [ ^ self ].
	diagramElements := elements.

	edges := elements select: [ :each |
		each isEdge and: [ self shouldRenderDiagramElement: each ] ].
	shapes := elements select: [ :each |
		each isShape and: [ self shouldRenderDiagramElement: each ] ].
	contentExtent := self canvasExtentFor: shapes.
	self constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent.
		parentProcessVisual ifNil: [
			c minWidth: contentExtent x.
			c minHeight: contentExtent y ] ].
	self addPaletteDropSurface.
	shapes do: [ :each | self addShapeFor: each ].
	edges do: [ :each | self addEdgeFor: each ].
	self bringNodeInteractionSurfacesToFront.
	self bringReconnectHandlesToFront.
	self bringBendpointHandlesToFront.
	self bringResizeHandlesToFront.
	self updateConnectionPortVisibility
]



{ #category : 'private - visibility' }
CPProcessVisualElement >> shouldRenderDiagramElement: aDiagramElement [
	| modelElement context |
	modelElement := aDiagramElement isShape
		ifTrue: [ self stagedModelElementOf: aDiagramElement ]
		ifFalse: [ aDiagramElement modelElement ].
	modelElement ifNil: [ ^ false ].
	context := CPProcessFlowContainerContext
		containingFlowElement: modelElement
		inRootMemento: memento.
	^ context notNil and: [ context container == flowContainer ]
]


{ #category : 'private - visibility' }
CPProcessVisualElement >> diagramShapeForModelElement: aModelElement [
	| matches |
	matches := diagramElements select: [ :each |
		each isShape and: [
			(self stagedModelElementOf: each) == aModelElement ] ].
	^ matches size = 1
		ifTrue: [ matches first ]
		ifFalse: [ nil ]
]

{ #category : 'private - visibility' }
CPProcessVisualElement >> nestingDepthOfDiagramShape: aShape [
	| modelElement |
	modelElement := self stagedModelElementOf: aShape.
	modelElement ifNil: [ ^ 0 ].
	^ self
		nestingDepthOfFlowElement: modelElement
		inContainerContext: (CPProcessFlowContainerContext rootFor: memento)
		depth: 0
]

{ #category : 'private - visibility' }
CPProcessVisualElement >> nestingDepthOfFlowElement: aFlowElement inContainerContext: aContext depth: aDepth [
	| stagedFlowElements nestedDepth |
	stagedFlowElements := aContext stagedFlowElements.
	(stagedFlowElements identityIncludes: aFlowElement) ifTrue: [ ^ aDepth ].

	stagedFlowElements do: [ :each |
		each isSubProcess ifTrue: [
			nestedDepth := self
				nestingDepthOfFlowElement: aFlowElement
				inContainerContext: (aContext childContextForSubProcess: each)
				depth: aDepth + 1.
			nestedDepth ifNotNil: [ ^ nestedDepth ] ] ].
	^ nil
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
CPProcessVisualElement >> stagedLabelSegmentIndexOf: anEdge [
	| edgeMemento description |
	edgeMemento := diagramMemento childMementoFor: anEdge inRelation: elementsDescription.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelSegmentIndex ].
	^ edgeMemento readUsing: description
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedLabelSegmentPositionOf: anEdge [
	| edgeMemento description |
	edgeMemento := diagramMemento childMementoFor: anEdge inRelation: elementsDescription.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelSegmentPosition ].
	^ edgeMemento readUsing: description
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedLabelOffsetOf: anEdge [
	| edgeMemento description |
	edgeMemento := diagramMemento childMementoFor: anEdge inRelation: elementsDescription.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelOffset ].
	^ edgeMemento readUsing: description
]


{ #category : 'private - shapes' }
CPProcessVisualElement >> addShapeFor: aShape [
	| bounds modelElement element |
	bounds := self stagedBoundsOf: aShape.
	bounds ifNil: [ ^ self ].
	modelElement := self stagedModelElementOf: aShape.
	modelElement ifNil: [ ^ self ].
	element := self newShapeElementFor: modelElement shape: aShape bounds: bounds.
	element installBodyCursor.
	element
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: bounds origin.
	self installSelectionOn: element for: modelElement.
	self installPositioningOn: element for: aShape.
	(modelElement isSubProcess and: [ self stagedExpandedOf: aShape ]) ifFalse: [
		self installReplacementOnShape: element for: modelElement shape: aShape ].
	self installConnectionOn: element for: modelElement.
	self installTaskTypePopupOn: element for: modelElement shape: aShape.
	self installSubProcessTypePopupOn: element for: modelElement shape: aShape.
	self installSubProcessExpansionOn: element for: modelElement shape: aShape.
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
	(modelElement isSubProcess and: [ self stagedExpandedOf: aShape ]) ifTrue: [
		self
			installNestedProcessVisualIn: element
			for: modelElement
			bounds: bounds.
		self
			installExpandedSubProcessBorderInteractionOn: element
			for: modelElement
			shape: aShape ].
	self addExternalLabelFor: modelElement bounds: bounds shape: aShape shapeElement: element.
	self updateSelectionAppearance
]

{ #category : 'private - type selection' }
CPProcessVisualElement >> installTaskTypePopupOn: aShapeElement for: aFlowNode shape: aShape [
	aFlowNode isTask ifFalse: [ ^ self ].
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
	| aSelectionMemento aDescription aPresentation aPopup anIconBlock aVisibleIcon |
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
	aShapeElement
		installTypePopup: aPopup
		visibleIcon: aVisibleIcon
		iconExtent: anExtent
		configure: aConfigureBlock
		selectedClass: [ aSelectionMemento readUsing: aDescription ]
		replacementSelected: [ :selectedClass |
			self
				replaceFlowNode: aFlowNode
				withClass: selectedClass
				shape: aShape ]
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
		value: proposedBounds
		value: (self stagedFlowContainerContaining: aFlowNode)) apply.

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
CPProcessVisualElement >> newShapeElementFor: aFlowNode shape: aShape bounds: bounds [
	| element label |
	label := aFlowNode isActivity
		ifTrue: [ self newEditableLabelFor: aFlowNode ]
		ifFalse: [ nil ].
	element := CPProcessShapeElement new.
	element
		shape: aShape
		modelElement: aFlowNode
		bounds: bounds
		background: self shapeBackgroundColor
		borderColor: self shapeBorderColor
		label: label
		expanded: (self stagedExpandedOf: aShape).
	label ifNotNil: [ self installLabelEditingOn: element label: label ].
	^ element
]

{ #category : 'private - labels' }
CPProcessVisualElement >> addExternalLabelForEdge: anEdge [
	| labelHost label |
	labelHost := BlElement new
		clipChildren: false;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal exact: 180.
			c vertical fitContent.
			c ignoreByLayout ];
		yourself.
	label := self newEditableLabelFor: anEdge modelElement.
	label hFitContentLimited.
	label vFitContent.
	label constraintsDo: [ :c |
		c maxWidth: 180.
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	labelHost addChild: label.
	(edgeVisualsByEdge at: anEdge) labelHost: labelHost.
	self addChild: labelHost.
	self installLabelEditingOn: labelHost label: label.
	self installEdgeSelectionOn: labelHost for: anEdge.
	self installEdgeLabelPositioningOn: labelHost for: anEdge.
	self positionEdgeLabelFor: anEdge
]

{ #category : 'private - labels' }
CPProcessVisualElement >> installEdgeLabelPositioningOn: aLabelHost for: anEdge [
	| isDragging lastPlacement |
	setEdgeLabelPlacementOperationBlock ifNil: [ ^ self ].
	isDragging := false.
	lastPlacement := nil.
	aLabelHost
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				isDragging := true.
				lastPlacement := nil.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					lastPlacement := (self
						edgeLabelPathFor: anEdge
						waypoints: (self stagedWaypointsOf: anEdge)
						usingLiveBounds: true)
						nearestPlacementTo: (self globalPointToLocal: anEvent position).
					self
						positionEdgeLabelFor: anEdge
						centeredAt: lastPlacement fourth.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					isDragging := false.
					lastPlacement ifNotNil: [
						self
							setLabelSegmentIndex: lastPlacement first
							segmentPosition: lastPlacement second
							offset: lastPlacement third
							forEdge: anEdge ].
					anEvent consumed: true ] ])
]

{ #category : 'operations' }
CPProcessVisualElement >> setLabelSegmentIndex: aSegmentIndex segmentPosition: aSegmentPosition offset: anOffset forEdge: anEdge [
	| assessment |
	setEdgeLabelPlacementOperationBlock ifNil: [ ^ nil ].
	assessment := (setEdgeLabelPlacementOperationBlock
		value: anEdge
		value: aSegmentIndex
		value: aSegmentPosition
		value: anOffset) apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateSelectionAppearance ].
	^ assessment
]


{ #category : 'private - labels' }
CPProcessVisualElement >> labelPlacementFor: anEdge segmentIndex: aSegmentIndex segmentPosition: aSegmentPosition offset: anOffset waypoints: someWaypoints usingLiveBounds: useLiveBounds [
	^ (self
		edgeLabelPathFor: anEdge
		waypoints: someWaypoints
		usingLiveBounds: useLiveBounds)
		placementAtSegmentIndex: aSegmentIndex
		segmentPosition: aSegmentPosition
		offset: anOffset
]



{ #category : 'private - labels' }
CPProcessVisualElement >> renderedPathPointsFor: anEdge waypoints: someWaypoints usingLiveBounds: useLiveBounds [
	| sequenceFlow source target sourceBounds targetBounds sourcePoint targetPoint points |
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	useLiveBounds
		ifTrue: [
			| sourceElement targetElement |
			sourceElement := self shapeElementForModelElement: source.
			targetElement := self shapeElementForModelElement: target.
			(sourceElement isNil or: [ targetElement isNil ]) ifTrue: [ ^ someWaypoints ].
			sourceBounds := sourceElement bounds inParent: self.
			targetBounds := targetElement bounds inParent: self ]
		ifFalse: [
			sourceBounds := self stagedBoundsOf: (self shapeForModelElement: source).
			targetBounds := self stagedBoundsOf: (self shapeForModelElement: target) ].

	someWaypoints size = 2 ifTrue: [
		sourcePoint := self
			dockingPointFor: source
			bounds: sourceBounds
			toward: targetBounds center.
		targetPoint := self
			dockingPointFor: target
			bounds: targetBounds
			toward: sourceBounds center.
		^ { sourcePoint. targetPoint } ].

	sourcePoint := self
		dockingPointFor: source
		bounds: sourceBounds
		toward: (someWaypoints at: 2).
	targetPoint := self
		dockingPointFor: target
		bounds: targetBounds
		toward: (someWaypoints at: someWaypoints size - 1).
	points := OrderedCollection new.
	points add: sourcePoint.
	2 to: someWaypoints size - 1 do: [ :index |
		points add: (someWaypoints at: index) ].
	points add: targetPoint.
	^ points
]


{ #category : 'private - labels' }
CPProcessVisualElement >> edgeLabelPathFor: anEdge waypoints: someWaypoints usingLiveBounds: useLiveBounds [
	^ CPProcessEdgeLabelPath points: (self
		renderedPathPointsFor: anEdge
		waypoints: someWaypoints
		usingLiveBounds: useLiveBounds)
]

{ #category : 'private - labels' }
CPProcessVisualElement >> positionEdgeLabelFor: anEdge centeredAt: aPoint [
	| edgeVisual |
	edgeVisual := edgeVisualsByEdge at: anEdge ifAbsent: [ ^ self ].
	edgeVisual positionLabelCenteredAt: aPoint
]

{ #category : 'private - labels' }
CPProcessVisualElement >> positionEdgeLabelFor: anEdge [
	| labelHost waypoints segmentIndex segmentPosition offset placement |
	labelHost := self edgeLabelHostFor: anEdge ifAbsent: [ ^ self ].
	waypoints := self stagedWaypointsOf: anEdge.
	segmentIndex := (self stagedLabelSegmentIndexOf: anEdge)
		ifNil: [ (self edgeLabelPathFor: anEdge waypoints: waypoints usingLiveBounds: false) defaultSegmentIndex ].
	segmentPosition := (self stagedLabelSegmentPositionOf: anEdge) ifNil: [ 0.5 ].
	offset := (self stagedLabelOffsetOf: anEdge) ifNil: [ -14.0 ].
	placement := self
		labelPlacementFor: anEdge
		segmentIndex: segmentIndex
		segmentPosition: segmentPosition
		offset: offset
		waypoints: waypoints
		usingLiveBounds: false.
	self
		positionEdgeLabelFor: anEdge
		centeredAt: placement first
]


{ #category : 'private - staged state' }
CPProcessVisualElement >> shapeForModelElement: aFlowNode [
	^ diagramElements
		detect: [ :each |
			each isShape and: [
				(self stagedModelElementOf: each) == aFlowNode ] ]
]

{ #category : 'private - labels' }
CPProcessVisualElement >> dockingPointFor: aFlowNode bounds: bounds toward: aPoint [
	aFlowNode isEvent ifTrue: [
		^ self ellipseDockingPointForBounds: bounds toward: aPoint ].
	aFlowNode isGateway ifTrue: [
		^ self diamondDockingPointForBounds: bounds toward: aPoint ].
	^ self boundsDockingPointForBounds: bounds toward: aPoint
]

{ #category : 'private - labels' }
CPProcessVisualElement >> boundsDockingPointForBounds: bounds toward: aPoint [
	| center direction scaleX scaleY scale |
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

{ #category : 'private - labels' }
CPProcessVisualElement >> ellipseDockingPointForBounds: bounds toward: aPoint [
	| center direction major minor metric scale |
	center := bounds center.
	direction := aPoint - center.
	direction isZero ifTrue: [ ^ center ].

	major := bounds width / 2.0.
	minor := bounds height / 2.0.
	metric := ((major * major * direction y * direction y)
		+ (minor * minor * direction x * direction x)) sqrt.
	metric isZero ifTrue: [ ^ center ].
	scale := (major * minor) / metric.
	^ center + ((scale * direction x) @ (scale * direction y))
]

{ #category : 'private - labels' }
CPProcessVisualElement >> diamondDockingPointForBounds: bounds toward: aPoint [
	| center direction halfWidth halfHeight denominator scale |
	center := bounds center.
	direction := aPoint - center.
	direction isZero ifTrue: [ ^ center ].

	halfWidth := bounds width / 2.0.
	halfHeight := bounds height / 2.0.
	denominator := (direction x abs / halfWidth)
		+ (direction y abs / halfHeight).
	denominator isZero ifTrue: [ ^ center ].
	scale := 1.0 / denominator.
	^ center + (direction * scale)
]


{ #category : 'private - labels' }
CPProcessVisualElement >> positionEdgeLabelFor: anEdge usingWaypoints: someWaypoints [
	| labelHost segmentIndex segmentPosition offset placement |
	labelHost := self edgeLabelHostFor: anEdge ifAbsent: [ ^ self ].
	segmentIndex := (self stagedLabelSegmentIndexOf: anEdge)
		ifNil: [ (self edgeLabelPathFor: anEdge waypoints: someWaypoints usingLiveBounds: true) defaultSegmentIndex ].
	segmentIndex := segmentIndex min: someWaypoints size - 1.
	segmentPosition := (self stagedLabelSegmentPositionOf: anEdge) ifNil: [ 0.5 ].
	offset := (self stagedLabelOffsetOf: anEdge) ifNil: [ -14.0 ].
	placement := self
		labelPlacementFor: anEdge
		segmentIndex: segmentIndex
		segmentPosition: segmentPosition
		offset: offset
		waypoints: someWaypoints
		usingLiveBounds: true.
	self
		positionEdgeLabelFor: anEdge
		centeredAt: placement first
]


{ #category : 'private - reconnecting' }
CPProcessVisualElement >> updateIncidentReconnectHandlesFor: aModelElement [
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		(anEdgeVisual reconnectHandles isEmpty not
			and: [ self edge: anEdge isIncidentTo: aModelElement ]) ifTrue: [
			self
				positionReconnectHandlesFor: anEdge
				fromLines: anEdgeVisual lineElements ] ]
]

{ #category : 'private - labels' }
CPProcessVisualElement >> updateIncidentEdgeLabelsFor: aModelElement [
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		(anEdgeVisual hasLabelHost
			and: [ self edge: anEdge isIncidentTo: aModelElement ]) ifTrue: [
			self positionLiveEdgeLabelFor: anEdge ] ]
]

{ #category : 'private - labels' }
CPProcessVisualElement >> positionLiveEdgeLabelFor: anEdge [
	| labelHost waypoints segmentIndex segmentPosition offset placement |
	labelHost := self edgeLabelHostFor: anEdge ifAbsent: [ ^ self ].
	waypoints := self stagedWaypointsOf: anEdge.
	segmentIndex := (self stagedLabelSegmentIndexOf: anEdge)
		ifNil: [ (self edgeLabelPathFor: anEdge waypoints: waypoints usingLiveBounds: true) defaultSegmentIndex ].
	segmentPosition := (self stagedLabelSegmentPositionOf: anEdge) ifNil: [ 0.5 ].
	offset := (self stagedLabelOffsetOf: anEdge) ifNil: [ -14.0 ].
	placement := self
		labelPlacementFor: anEdge
		segmentIndex: segmentIndex
		segmentPosition: segmentPosition
		offset: offset
		waypoints: waypoints
		usingLiveBounds: true.
	self
		positionEdgeLabelFor: anEdge
		centeredAt: placement first
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
	aShapeElement externalLabelHost: labelHost.
	self addChild: labelHost.
	self installLabelEditingOn: labelHost label: label.
	self installSelectionOn: labelHost for: aFlowNode.
	self installPositioningFrom: labelHost moving: aShapeElement for: aShape
]

{ #category : 'private - labels' }
CPProcessVisualElement >> newEditableLabelFor: aFlowElement [
	| flowMemento description label |
	flowMemento := self flowElementMementoFor: aFlowElement.
	flowMemento ifNil: [
		self error: 'Flow element is not present in the staged Process/Sub-Process hierarchy.' ].
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
			self finishEditingLabel: label ];
		when: BrEditorCancelWish
		do: [ :aWish |
			GtMagritteBuilderUtility
				writeText: label text
				using: description
				memento: flowMemento
				element: label.
			self finishEditingLabel: label ].

	label preventMeAndChildrenMouseEvents.
	^ label
]

{ #category : 'private - labels' }
CPProcessVisualElement >> finishEditingLabel: anEditableLabel [
	anEditableLabel preventMeAndChildrenMouseEvents.
	anEditableLabel loseFocus.
	self enqueueTask: (BlTaskAction new action: [
		self requestFocus ])
]

{ #category : 'private - labels' }
CPProcessVisualElement >> installLabelEditingOn: anInteractionElement label: anEditableLabel [
	anInteractionElement addEventHandler: (BlEventHandler
		on: BlDoubleClickEvent
		do: [ :anEvent |
			self beginEditingLabel: anEditableLabel.
			anEvent consumed: true ])
]

{ #category : 'private - labels' }
CPProcessVisualElement >> beginEditingLabel: anEditableLabel [
	anEditableLabel allowMeAndChildrenMouseEvents.
	anEditableLabel switchToEditor.
	anEditableLabel enqueueTask: (BlTaskAction new action: [
		anEditableLabel requestFocus ])
]

{ #category : 'private - labels' }
CPProcessVisualElement >> beginEditingLabelForEdge: anEdge [
	| labelHost label |
	labelHost := self edgeLabelHostFor: anEdge ifAbsent: [ ^ self ].
	labelHost children isEmpty ifTrue: [ ^ self ].
	label := labelHost children first.
	self beginEditingLabel: label
]

{ #category : 'private - edges' }
CPProcessVisualElement >> addEdgeFor: anEdge [
	| waypoints |
	waypoints := self stagedWaypointsOf: anEdge.
	waypoints size = 2
		ifTrue: [ self addStraightEdgeFor: anEdge ]
		ifFalse: [ self addEdgeFor: anEdge waypoints: waypoints ].
	self addExternalLabelForEdge: anEdge.
	self installReconnectHandlesFor: anEdge.
	self installBendpointHandlesFor: anEdge
]

{ #category : 'private - shapes' }
CPProcessVisualElement >> shapeElementForModelElement: aFlowNode [
	| local nested |
	local := shapeElementsByModelElement at: aFlowNode ifAbsent: [ nil ].
	local ifNotNil: [ ^ local ].
	shapeElementsByModelElement keysAndValuesDo: [ :aModelElement :aShapeElement |
		(aModelElement isSubProcess and: [ aShapeElement nestedProcessVisual notNil ]) ifTrue: [
			nested := aShapeElement nestedProcessVisual
				shapeElementForModelElement: aFlowNode.
			nested ifNotNil: [ ^ nested ] ] ].
	^ nil
]

{ #category : 'private - edges' }
CPProcessVisualElement >> addStraightEdgeFor: anEdge [
	| sequenceFlow sourceElement targetElement source target sourceAnchor targetAnchor edgeVisual |
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	sourceElement := self shapeElementForModelElement: source.
	targetElement := self shapeElementForModelElement: target.
	(sourceElement isNil or: [ targetElement isNil ]) ifTrue: [ ^ self ].
	sourceAnchor := (self anchorClassFor: source)
		nearestTo: targetElement
		from: sourceElement.
	targetAnchor := (self anchorClassFor: target)
		nearestTo: sourceElement
		from: targetElement.

	edgeVisual := CPProcessEdgeVisual new edge: anEdge.
	edgeVisual
		addSegmentFrom: sourceAnchor
		to: targetAnchor
		arrowhead: true
		color: self shapeBorderColor
		segmentIndex: 1
		installInteraction: [ :anElement :aSegmentIndex |
			self installEdgeSelectionOn: anElement for: anEdge.
			self installPaletteInsertionOn: anElement for: anEdge.
			self
				installBendpointInsertionOn: anElement
				for: anEdge
				segmentIndex: aSegmentIndex ]
		addTo: self.
	edgeVisualsByEdge at: anEdge put: edgeVisual
]

{ #category : 'private - layout' }
CPProcessVisualElement >> bringNodeInteractionSurfacesToFront [
	shapeElementsByShape valuesDo: [ :anElement |
		anElement removeFromParent.
		self addChild: anElement ].
	shapeElementsByModelElement valuesDo: [ :aShapeElement |
		aShapeElement bringExternalLabelToFrontIn: self ].
	edgeVisualsByEdge valuesDo: [ :anEdgeVisual |
		anEdgeVisual bringLabelToFrontIn: self ]
]

{ #category : 'private - layout' }
CPProcessVisualElement >> bringReconnectHandlesToFront [
	edgeVisualsByEdge valuesDo: [ :anEdgeVisual |
		anEdgeVisual bringReconnectHandlesToFrontIn: self ]
]

{ #category : 'private - edges' }
CPProcessVisualElement >> lineElementsForEdge: anEdge [
	^ (edgeVisualsByEdge at: anEdge ifAbsent: [ ^ #() ]) lineElements
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
	  sourceReference targetReference pairCount edgeVisual |
	waypoints size < 3 ifTrue: [ ^ self addStraightEdgeFor: anEdge ].
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	sourceElement := self shapeElementForModelElement: source.
	targetElement := self shapeElementForModelElement: target.
	(sourceElement isNil or: [ targetElement isNil ]) ifTrue: [ ^ self ].
	interiorPoints := waypoints copyFrom: 2 to: waypoints size - 1.

	sourceReference := self anchorReferenceElementAt: interiorPoints first.
	targetReference := self anchorReferenceElementAt: interiorPoints last.
	self addChild: sourceReference.
	self addChild: targetReference.

	edgeVisual := CPProcessEdgeVisual new edge: anEdge.
	pairCount := interiorPoints size + 1.
	1 to: pairCount do: [ :index |
		| fromAnchor toAnchor |
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

		edgeVisual
			addSegmentFrom: fromAnchor
			to: toAnchor
			arrowhead: index = pairCount
			color: self shapeBorderColor
			segmentIndex: index
			installInteraction: [ :anElement :aSegmentIndex |
				self installEdgeSelectionOn: anElement for: anEdge.
				self installPaletteInsertionOn: anElement for: anEdge.
				self
					installBendpointInsertionOn: anElement
					for: anEdge
					segmentIndex: aSegmentIndex ]
			addTo: self ].
	edgeVisualsByEdge at: anEdge put: edgeVisual
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
CPProcessVisualElement >> edge: anEdge isIncidentTo: aModelElement [
	| sequenceFlow |
	sequenceFlow := anEdge modelElement.
	^ sequenceFlow sourceRef == aModelElement
		or: [ sequenceFlow targetRef == aModelElement ]
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
				connectionSourceModelElement
					ifNotNil: [ :aSource |
						(self isValidConnectionTarget: aModelElement from: aSource)
							ifTrue: [ self connectionTargetModelElement: aModelElement ]
							ifFalse: [ self clearConnectionTarget ] ]
					ifNil: [ self updateConnectionPortVisibility ] ]);
		addEventHandler: (BlEventHandler
			on: BlMouseLeaveEvent
			do: [ :anEvent |
				hoveredModelElement == aModelElement ifTrue: [ hoveredModelElement := nil ].
				connectionTargetModelElement == aModelElement
					ifTrue: [ self clearConnectionTarget ]
					ifFalse: [ self updateConnectionPortVisibility ] ])
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
		isSelected := (selectedModelElements includes: aModelElement)
			or: [ aModelElement == connectionSourceModelElement
			or: [ aModelElement == connectionTargetModelElement ] ].
		anElement
			selected: isSelected
			selectionColor: self selectionColor
			normalColor: self shapeBorderColor ].
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		anEdgeVisual
			selected: (selectedModelElements includes: anEdge modelElement)
			insertionTarget: anEdge == insertionTargetEdge
			selectionColor: self selectionColor
			normalColor: self shapeBorderColor ].
	self updateReconnectHandlePositions.
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		anEdgeVisual reconnectHandlesVisible:
			(anEdge modelElement == selectedModelElement) ].
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		anEdgeVisual bendpointHandlesVisible:
			(anEdge modelElement == selectedModelElement) ].
	self updateConnectionPortVisibility
]

{ #category : 'configuration' }
CPProcessVisualElement >> moveShapeOperationFor: aBlock [
	"The block receives the CPShape and proposed bounds and answers the Process Atelier operation for that diagram intention."
	moveShapeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessVisualElement >> moveShapesOperationFor: aBlock [
	moveShapesOperationBlock := aBlock
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
	| handles |
	resizeShapeOperationBlock ifNil: [ ^ self ].
	aModelElement isActivity ifFalse: [ ^ self ].
	handles := aShapeElement
		installResizeHandleMinimumExtent: (self extentForModelElement: aModelElement)
		stagedBounds: [ self stagedBoundsOf: aShape ]
		resize: [ :proposedBounds | self resizeShape: aShape toBounds: proposedBounds ]
		geometryChanged: [
			self updateIncidentEdgeLabelsFor: aModelElement.
			self updateIncidentReconnectHandlesFor: aModelElement ].
	handles do: [ :aHandle | aShapeElement addChild: aHandle ]
]

{ #category : 'private - layout' }
CPProcessVisualElement >> bringResizeHandlesToFront [
	shapeElementsByShape valuesDo: [ :aShapeElement |
		aShapeElement bringResizeHandlesToFront ]
]

{ #category : 'operations' }
CPProcessVisualElement >> moveShape: aShape toBounds: aRectangle [
	| assessment modelElement constrainedBounds |
	moveShapeOperationBlock ifNil: [ ^ nil ].
	modelElement := self stagedModelElementOf: aShape.
	constrainedBounds := modelElement
		ifNil: [ aRectangle ]
		ifNotNil: [ self constrainedBounds: aRectangle forFlowElement: modelElement ].
	assessment := (moveShapeOperationBlock value: aShape value: constrainedBounds) apply.
	assessment isApplicable ifFalse: [ self refresh ].
	^ assessment
]

{ #category : 'operations' }
CPProcessVisualElement >> moveShapesToBounds: boundsByShape [
	| assessment |
	moveShapesOperationBlock ifNil: [ ^ nil ].
	assessment := (moveShapesOperationBlock value: boundsByShape) apply.
	self refresh.
	^ assessment
]


{ #category : 'private - insertion' }
CPProcessVisualElement >> insertionTargetEdge: anEdge [
	insertionTargetEdge == anEdge ifTrue: [ ^ self ].
	insertionTargetEdge := anEdge.
	self updateSelectionAppearance
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> clearInsertionTarget [
	self insertionTargetEdge: nil
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> insertionEdgeAtGlobalPoint: aGlobalPoint for: aFlowNode [
	| candidates localPoint |
	insertFlowNodeOperationBlock ifNil: [ ^ nil ].
	candidates := OrderedCollection new.
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		((self stagedSourceOf: anEdge modelElement) == aFlowNode
			or: [ (self stagedTargetOf: anEdge modelElement) == aFlowNode ])
			ifFalse: [
				(anEdgeVisual containsGlobalPoint: aGlobalPoint)
					ifTrue: [ candidates add: anEdge ] ] ].
	candidates ifEmpty: [ ^ nil ].
	candidates size = 1 ifTrue: [ ^ candidates first ].

	localPoint := self globalPointToLocal: aGlobalPoint.
	^ candidates
		detectMin: [ :anEdge |
			self distanceFrom: localPoint toRenderedEdge: anEdge ]
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> distanceFrom: aPoint toRenderedEdge: anEdge [
	| points bestDistance |
	points := self
		renderedPathPointsFor: anEdge
		waypoints: (self stagedWaypointsOf: anEdge)
		usingLiveBounds: true.
	bestDistance := Float infinity.
	1 to: points size - 1 do: [ :index |
		| start finish vector lengthSquared parameter projected |
		start := points at: index.
		finish := points at: index + 1.
		vector := finish - start.
		lengthSquared := vector dotProduct: vector.
		lengthSquared isZero
			ifTrue: [
				bestDistance := bestDistance min: (aPoint - start) r ]
			ifFalse: [
				parameter := ((aPoint - start) dotProduct: vector) / lengthSquared.
				parameter := (parameter max: 0.0) min: 1.0.
				projected := start + (vector * parameter).
				bestDistance := bestDistance min: (aPoint - projected) r ] ].
	^ bestDistance
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> insertExistingFlowNode: aFlowNode shape: aShape intoEdge: anEdge atBounds: proposedBounds [
	| assessment constrainedBounds flowContainer |
	insertFlowNodeOperationBlock ifNil: [ ^ nil ].
	flowContainer := self stagedFlowContainerContaining: anEdge modelElement.
	constrainedBounds := self constrainedBounds: proposedBounds forFlowContainer: flowContainer.
	assessment := (insertFlowNodeOperationBlock
		value: anEdge modelElement
		value: aFlowNode
		value: constrainedBounds
		value: (self stagedFlowContainerContaining: anEdge modelElement)) apply.
	assessment isApplicable
		ifTrue: [
			selectedModelElements removeAll.
			selectedModelElements add: aFlowNode.
			selectedModelElement := aFlowNode.
			self refresh.
			self updateSelectionAppearance.
			selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: aFlowNode ] ]
		ifFalse: [
			self moveShape: aShape toBounds: proposedBounds ].
	^ assessment
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> installPositioningOn: anElement for: aShape [
	self installPositioningFrom: anElement moving: anElement for: aShape
]













{ #category : 'private - positioning' }
CPProcessVisualElement >> moveShapeOrSubProcess: aShape modelElement: aFlowNode toBounds: proposedBounds delta: delta [
	^ self moveShape: aShape toBounds: proposedBounds
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> selectedShapeEntriesForGroupDragIncluding: draggedModelElement [
	| entries |
	(selectedModelElements includes: draggedModelElement) ifFalse: [ ^ #() ].
	entries := OrderedCollection new.
	shapeElementsByShape keysAndValuesDo: [ :aShape :anElement |
		| modelElement |
		modelElement := self stagedModelElementOf: aShape.
		(selectedModelElements includes: modelElement) ifTrue: [
			| label |
			label := anElement externalLabelHost.
			entries add: {
				aShape.
				modelElement.
				anElement.
				self stagedBoundsOf: aShape.
				label.
				(label ifNotNil: [ label position ])
			} ] ].
	^ entries
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> internalBentEdgesForMovedModelElements: movedModelElements [
	^ edgeVisualsByEdge keys select: [ :anEdge |
		| sequenceFlow |
		sequenceFlow := anEdge modelElement.
		(movedModelElements includes: (self stagedSourceOf: sequenceFlow))
			and: [
				(movedModelElements includes: (self stagedTargetOf: sequenceFlow))
					and: [ (self stagedWaypointsOf: anEdge) size > 2 ] ] ]
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> translatedWaypointsOf: anEdge by: delta [
	^ (self stagedWaypointsOf: anEdge) collect: [ :aPoint | aPoint + delta ]
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> newGroupMovePreviewFor: anEdge waypoints: someWaypoints [
	| sequenceFlow source target sourceElement targetElement interiorPoints sourceReference targetReference lines pairCount references |
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	sourceElement := shapeElementsByModelElement at: source.
	targetElement := shapeElementsByModelElement at: target.
	interiorPoints := someWaypoints copyFrom: 2 to: someWaypoints size - 1.
	sourceReference := self anchorReferenceElementAt: interiorPoints first.
	targetReference := self anchorReferenceElementAt: interiorPoints last.
	references := { sourceReference. targetReference }.
	references do: [ :each | self addChild: each ].

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
			border: (BlBorder paint: self shapeBorderColor width: 1.5);
			constraintsDo: [ :c | c ignoreByLayout ];
			yourself.
		index = pairCount ifTrue: [
			line toHead: (BlArrowheadSimpleArrow new
				border: (BlBorder paint: self shapeBorderColor width: 1.5)) ].
		lines add: line.
		self addChild: line ].
	^ { lines. references }
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> removeGroupMovePreviews: previews [
	previews valuesDo: [ :preview |
		preview first do: [ :aLine | aLine removeFromParent ].
		preview second do: [ :aReference | aReference removeFromParent ] ]
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> installPositioningFrom: anInteractionElement moving: aShapeElement for: aShape [
	| dragStartLabelPosition draggedModelElement groupEntries groupMode groupPreviews internalBentEdges movedModelElements |
	moveShapeOperationBlock ifNil: [ ^ self ].
	groupMode := false.
	groupEntries := #().
	groupPreviews := IdentityDictionary new.
	internalBentEdges := #().
	movedModelElements := IdentitySet new.
	aShapeElement
		installPositioningFrom: anInteractionElement
		stagedBounds: [ self stagedBoundsOf: aShape ]
		dragStarted: [ :anEvent :originalBounds |
			self clearInsertionTarget.
			draggedModelElement := self stagedModelElementOf: aShape.
			dragStartLabelPosition := aShapeElement externalLabelHost
				ifNotNil: [ :aLabel | aLabel position ].
			groupEntries := self selectedShapeEntriesForGroupDragIncluding: draggedModelElement.
			groupMode := moveShapesOperationBlock notNil and: [ groupEntries size > 1 ].
			movedModelElements := IdentitySet new.
			groupEntries do: [ :entry | movedModelElements add: entry second ].
			groupMode ifTrue: [
				internalBentEdges := self internalBentEdgesForMovedModelElements: movedModelElements.
				internalBentEdges do: [ :anEdge |
					(self lineElementsForEdge: anEdge)
						do: [ :aLine | aLine visibility: BlVisibility hidden ] ] ] ]
		dragged: [ :anEvent :delta |
			groupMode
				ifTrue: [
					groupEntries do: [ :entry |
						| element bounds label |
						element := entry third.
						bounds := entry fourth.
						label := entry fifth.
						element relocate: bounds origin + delta.
						label ifNotNil: [ label relocate: entry sixth + delta ].
						element bringResizeHandlesToFront ].
					self removeGroupMovePreviews: groupPreviews.
					groupPreviews := IdentityDictionary new.
					internalBentEdges do: [ :anEdge |
						| proposed preview |
						proposed := self translatedWaypointsOf: anEdge by: delta.
						preview := self newGroupMovePreviewFor: anEdge waypoints: proposed.
						groupPreviews at: anEdge put: preview ].
					movedModelElements do: [ :modelElement |
						self updateIncidentEdgeLabelsFor: modelElement.
						self updateIncidentReconnectHandlesFor: modelElement ].
					internalBentEdges do: [ :anEdge |
						| proposed |
						proposed := self translatedWaypointsOf: anEdge by: delta.
						self positionEdgeLabelFor: anEdge usingWaypoints: proposed.
						self positionReconnectHandlesFor: anEdge usingWaypoints: proposed.
						self positionBendpointHandlesFor: anEdge usingWaypoints: proposed ].
					self bringReconnectHandlesToFront.
					self bringBendpointHandlesToFront.
					self bringResizeHandlesToFront ]
				ifFalse: [
					dragStartLabelPosition ifNotNil: [
						aShapeElement externalLabelHost
						relocate: dragStartLabelPosition + delta ].
					self updateIncidentEdgeLabelsFor: draggedModelElement.
					self updateIncidentReconnectHandlesFor: draggedModelElement.
					self insertionTargetEdge: (self
						insertionEdgeAtGlobalPoint: anEvent position
						for: draggedModelElement).
					self updateConnectionPortVisibility ] ]
		dragEnded: [ :anEvent :proposedBounds :delta |
			groupMode
				ifTrue: [
					| boundsByShape |
					self removeGroupMovePreviews: groupPreviews.
					groupPreviews := IdentityDictionary new.
					internalBentEdges do: [ :anEdge |
						(self lineElementsForEdge: anEdge)
							do: [ :aLine | aLine visibility: BlVisibility visible ] ].
					boundsByShape := IdentityDictionary new.
					groupEntries do: [ :entry |
						boundsByShape
							at: entry first
							put: (entry fourth translateBy: delta) ].
					self moveShapesToBounds: boundsByShape ]
				ifFalse: [
					| insertionEdge |
					insertionEdge := self
						insertionEdgeAtGlobalPoint: anEvent position
						for: draggedModelElement.
					self clearInsertionTarget.
					insertionEdge
						ifNil: [
							| currentContainer targetVisual targetContainer targetBounds rootPoint |
							currentContainer := self stagedFlowContainerContaining: draggedModelElement.
							rootPoint := self rootDiagramPointForLocalPoint: proposedBounds center.
							targetVisual := rootVisual
								processVisualAtRootDiagramPoint: rootPoint
								excluding: draggedModelElement.
							targetContainer := targetVisual flowContainer.
							(currentContainer notNil
								and: [ targetContainer ~~ currentContainer
								and: [ transferFlowNodeOperationBlock notNil ] ])
								ifTrue: [
									targetBounds := targetVisual
										boundsCenteredAtRootDiagramPoint: rootPoint
										extent: proposedBounds extent.
									targetVisual
										transferFlowNode: draggedModelElement
										shape: aShape
										toContainer: targetContainer
										bounds: targetBounds ]
								ifFalse: [
									self
										moveShapeOrSubProcess: aShape
										modelElement: draggedModelElement
										toBounds: proposedBounds
										delta: delta ] ]
						ifNotNil: [
							self
								insertExistingFlowNode: draggedModelElement
								shape: aShape
								intoEdge: insertionEdge
								atBounds: proposedBounds ] ] ]
]

{ #category : 'private - cursor' }
CPProcessVisualElement >> installDiagramCursor [
	self
		addEventHandler: (BlEventHandler
			on: BlMouseEnterEvent
			do: [ :anEvent |
				anEvent target == anEvent currentTarget ifTrue: [
					anEvent currentTarget space ifNotNil: [ :aSpace |
						aSpace currentCursor: BlCursor default ] ] ])
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
	flowMemento := self flowElementMementoFor: aSequenceFlow.
	flowMemento ifNil: [
		self error: 'Sequence flow is not present in the staged Process/Sub-Process hierarchy.' ].
	description := flowMemento magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedTargetOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := self flowElementMementoFor: aSequenceFlow.
	flowMemento ifNil: [
		self error: 'Sequence flow is not present in the staged Process/Sub-Process hierarchy.' ].
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
		whenDragEnteredDo: [ :anEvent |
			self insertionTargetEdge: anEdge ];
		whenDragLeftDo: [ :anEvent |
			anEdge == insertionTargetEdge ifTrue: [ self clearInsertionTarget ] ];
		whenDroppedDo: [ :anEvent |
			self clearInsertionTarget.
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
		value: proposedBounds
		value: (self stagedFlowContainerContaining: anEdge modelElement)) assess.
	^ assessment isApplicable
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> dropPaletteEvent: anEvent insertingInto: anEdge [
	| dragItem candidate elementExtent dropPoint origin bounds assessment |
	anEvent items size = 1 ifFalse: [ ^ self ].
	dragItem := anEvent items first.
	candidate := dragItem domainObject.
	elementExtent := self extentForModelElement: candidate.
	dropPoint := self globalPointToLocal:
		(anEvent currentTarget localPointToGlobal: anEvent position).
	origin :=
		((dropPoint x - (elementExtent x / 2)) max: 0)
		@ ((dropPoint y - (elementExtent y / 2)) max: 0).
	bounds := origin extent: elementExtent.
	bounds := self
		constrainedBounds: bounds
		forFlowContainer: (self stagedFlowContainerContaining: anEdge modelElement).
	assessment := (insertFlowNodeOperationBlock
		value: anEdge modelElement
		value: candidate
		value: bounds
		value: (self stagedFlowContainerContaining: anEdge modelElement)) apply.
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

{ #category : 'private - selection' }
CPProcessVisualElement >> newSelectionMarqueeElement [
	^ BlElement new
		geometry: BlRectangleGeometry new;
		background: (self selectionColor alpha: 0.08);
		border: (BlBorder paint: (self selectionColor alpha: 0.8) width: 1.5);
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMouseEvents;
		yourself
]

{ #category : 'private - selection' }
CPProcessVisualElement >> updateMarqueeSelectionFor: aRectangle [
	selectedModelElements removeAll.

	shapeElementsByModelElement keysAndValuesDo: [ :aModelElement :anElement |
		((anElement bounds inParent: self) asRectangle intersects: aRectangle)
			ifTrue: [ selectedModelElements add: aModelElement ] ].

	edgeVisualsByEdge keysDo: [ :anEdge |
		(self edge: anEdge intersectsRectangle: aRectangle)
			ifTrue: [ selectedModelElements add: anEdge modelElement ] ].

	selectedModelElement := selectedModelElements size = 1
		ifTrue: [ selectedModelElements anyOne ]
		ifFalse: [ nil ].
	self updateSelectionAppearance
]

{ #category : 'private - selection' }
CPProcessVisualElement >> edge: anEdge intersectsRectangle: aRectangle [
	| points |
	points := self
		renderedPathPointsFor: anEdge
		waypoints: (self stagedWaypointsOf: anEdge)
		usingLiveBounds: true.
	1 to: points size - 1 do: [ :index |
		(self
			segmentFrom: (points at: index)
			to: (points at: index + 1)
			intersectsRectangle: aRectangle)
				ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'private - selection' }
CPProcessVisualElement >> segmentFrom: aStart to: anEnd intersectsRectangle: aRectangle [
	| segment top right bottom left |
	((aRectangle containsPoint: aStart)
		or: [ aRectangle containsPoint: anEnd ])
			ifTrue: [ ^ true ].

	segment := BlLineGeometry new
		from: aStart to: anEnd;
		yourself.
	top := BlLineGeometry new
		from: aRectangle topLeft to: aRectangle topRight;
		yourself.
	right := BlLineGeometry new
		from: aRectangle topRight to: aRectangle bottomRight;
		yourself.
	bottom := BlLineGeometry new
		from: aRectangle bottomRight to: aRectangle bottomLeft;
		yourself.
	left := BlLineGeometry new
		from: aRectangle bottomLeft to: aRectangle topLeft;
		yourself.

	^ (segment intersectionWith: top) notNil
		or: [ (segment intersectionWith: right) notNil
		or: [ (segment intersectionWith: bottom) notNil
		or: [ (segment intersectionWith: left) notNil ] ] ]
]



{ #category : 'private - containment geometry' }
CPProcessVisualElement >> constrainedBounds: aRectangle forFlowContainer: aFlowContainer [
	^ aRectangle
]

{ #category : 'private - containment geometry' }
CPProcessVisualElement >> constrainedBounds: aRectangle forFlowElement: aFlowElement [
	^ aRectangle
]



{ #category : 'private - creation' }
CPProcessVisualElement >> installPaletteDropHandler [
	self addEventHandler: (CPProcessPaletteDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea |
			self acceptsPaletteDragItem: aDragItem ];
		whenDroppedDo: [ :anEvent |
			self dropPaletteEvent: anEvent ];
		yourself)
]

{ #category : 'private - creation' }
CPProcessVisualElement >> addPaletteDropSurface [
	| dropSurface isMarqueeDragging marqueeOrigin marqueeElement |
	isMarqueeDragging := false.
	marqueeOrigin := nil.
	marqueeElement := nil.
	dropSurface := BlElement new
		geometry: BlRectangleGeometry new;
		background: Color transparent;
		constraintsDo: [ :c |
			c ignoreByLayout.
			c horizontal matchParent.
			c vertical matchParent ];
		relocate: 0 @ 0;
		yourself.
	dropSurface
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent |
				parentProcessVisual
					ifNil: [ self clearInteractionAndSelection ]
					ifNotNil: [
						self clearLocalSelection.
						parentProcessVisual selectOnly: flowContainer ].
				self requestFocus.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				isMarqueeDragging := true.
				marqueeOrigin := self globalPointToLocal: anEvent position.
				connectionSourceModelElement := nil.
				connectionTargetModelElement := nil.
				insertionTargetEdge := nil.
				selectedModelElements removeAll.
				selectedModelElement := nil.
				marqueeElement := self newSelectionMarqueeElement.
				marqueeElement
					relocate: marqueeOrigin;
					extent: 0 @ 0.
				self addChild: marqueeElement.
				self updateSelectionAppearance.
				self requestFocus.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isMarqueeDragging ifTrue: [
					| corner rectangle |
					corner := self globalPointToLocal: anEvent position.
					rectangle := Rectangle encompassing: { marqueeOrigin. corner }.
					marqueeElement
						relocate: rectangle origin;
						extent: rectangle extent.
					self updateMarqueeSelectionFor: rectangle.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isMarqueeDragging ifTrue: [
					| corner rectangle |
					isMarqueeDragging := false.
					corner := self globalPointToLocal: anEvent position.
					rectangle := Rectangle encompassing: { marqueeOrigin. corner }.
					self updateMarqueeSelectionFor: rectangle.
					marqueeElement ifNotNil: [ marqueeElement removeFromParent ].
					marqueeElement := nil.
					marqueeOrigin := nil.
					selectionChangedBlock ifNotNil: [
						:aBlock | aBlock value: selectedModelElement ].
					anEvent consumed: true ] ]);
		yourself.
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
	assessment := (createFlowNodeOperationBlock value: candidate value: proposedBounds value: flowContainer) assess.
	^ assessment isApplicable
]

{ #category : 'private - creation' }
CPProcessVisualElement >> dropPaletteEvent: anEvent [
	| dragItem globalPoint rootPoint targetVisual |
	anEvent items size = 1 ifFalse: [ ^ self ].
	dragItem := anEvent items first.
	globalPoint := anEvent currentTarget
		localPointToGlobal: anEvent position.
	rootPoint := rootVisual globalPointToLocal: globalPoint.
	targetVisual := rootVisual
		processVisualAtRootDiagramPoint: rootPoint
		excluding: nil.
	^ targetVisual
		createPaletteItem: dragItem
		atRootDiagramPoint: rootPoint
]

{ #category : 'private - creation' }
CPProcessVisualElement >> createPaletteItem: aDragItem atRootDiagramPoint: aRootPoint [
	| candidate elementExtent bounds assessment |
	candidate := aDragItem domainObject.
	elementExtent := self extentForModelElement: candidate.
	bounds := self
		boundsCenteredAtRootDiagramPoint: aRootPoint
		extent: elementExtent.
	bounds := self constrainedBounds: bounds forFlowContainer: flowContainer.
	assessment := (createFlowNodeOperationBlock
		value: candidate
		value: bounds
		value: flowContainer) apply.
	assessment isApplicable ifTrue: [
		selectedModelElements removeAll.
		selectedModelElements add: candidate.
		selectedModelElement := candidate.
		self refreshEditor.
		selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: candidate ] ].
	^ assessment
]
{ #category : 'private - replacement' }
CPProcessVisualElement >> installReplacementOnShape: aShapeElement for: aFlowNode shape: aShape [
	replaceFlowNodeOperationBlock ifNil: [ ^ self ].
	aShapeElement
		installPaletteReplacementAccepting: [ :aDragItem |
			self acceptsPaletteDragItem: aDragItem replacing: aFlowNode shape: aShape ]
		dropped: [ :anEvent |
			self dropPaletteEvent: anEvent replacing: aFlowNode shape: aShape ]
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
		value: proposedBounds
		value: (self stagedFlowContainerContaining: aFlowNode)) assess.
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
		value: proposedBounds
		value: (self stagedFlowContainerContaining: aFlowNode)) apply.
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
CPProcessVisualElement >> updateConnectionPreviewLine: aLine cursor: aCursor source: aSource sourceElement: aSourceElement target: aTarget [
	| targetElement |
	aTarget
		ifNil: [
			aLine
				fromAnchor: ((self anchorClassFor: aSource)
					nearestTo: aCursor
					from: aSourceElement);
				toAnchor: (BlNearestPositionBoundsAnchor
					nearestTo: aSourceElement
					from: aCursor) ]
		ifNotNil: [
			targetElement := shapeElementsByModelElement at: aTarget.
			aLine
				fromAnchor: ((self anchorClassFor: aSource)
					nearestTo: targetElement
					from: aSourceElement);
				toAnchor: ((self anchorClassFor: aTarget)
					nearestTo: aSourceElement
					from: targetElement) ]
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> updateReconnectPreviewLine: aLine cursor: aCursor sequenceFlow: aSequenceFlow movingSource: movesSource target: aCandidate adjacentReference: adjacentReference [
	| source target sourceElement targetElement candidateElement |
	source := self stagedSourceOf: aSequenceFlow.
	target := self stagedTargetOf: aSequenceFlow.
	sourceElement := shapeElementsByModelElement at: source.
	targetElement := shapeElementsByModelElement at: target.

	adjacentReference
		ifNotNil: [
			aCandidate
				ifNil: [
					movesSource
						ifTrue: [
							aLine
								fromAnchor: (BlNearestPositionBoundsAnchor
									nearestTo: adjacentReference
									from: aCursor);
								toAnchor: (BlAbsolutePositionAnchor
									position: adjacentReference position) ]
						ifFalse: [
							aLine
								fromAnchor: (BlAbsolutePositionAnchor
									position: adjacentReference position);
								toAnchor: (BlNearestPositionBoundsAnchor
									nearestTo: adjacentReference
									from: aCursor) ] ]
				ifNotNil: [
					candidateElement := shapeElementsByModelElement at: aCandidate.
					movesSource
						ifTrue: [
							aLine
								fromAnchor: ((self anchorClassFor: aCandidate)
									nearestTo: adjacentReference
									from: candidateElement);
								toAnchor: (BlAbsolutePositionAnchor
									position: adjacentReference position) ]
						ifFalse: [
							aLine
								fromAnchor: (BlAbsolutePositionAnchor
									position: adjacentReference position);
								toAnchor: ((self anchorClassFor: aCandidate)
									nearestTo: adjacentReference
									from: candidateElement) ] ].
			^ self ].

	aCandidate
		ifNil: [
			movesSource
				ifTrue: [
					aLine
						fromAnchor: (BlNearestPositionBoundsAnchor
							nearestTo: targetElement
							from: aCursor);
						toAnchor: ((self anchorClassFor: target)
							nearestTo: aCursor
							from: targetElement) ]
				ifFalse: [
					aLine
						fromAnchor: ((self anchorClassFor: source)
							nearestTo: aCursor
							from: sourceElement);
						toAnchor: (BlNearestPositionBoundsAnchor
							nearestTo: sourceElement
							from: aCursor) ] ]
		ifNotNil: [
			candidateElement := shapeElementsByModelElement at: aCandidate.
			movesSource
				ifTrue: [
					aLine
						fromAnchor: ((self anchorClassFor: aCandidate)
							nearestTo: targetElement
							from: candidateElement);
						toAnchor: ((self anchorClassFor: target)
							nearestTo: candidateElement
							from: targetElement) ]
				ifFalse: [
					aLine
						fromAnchor: ((self anchorClassFor: source)
							nearestTo: candidateElement
							from: sourceElement);
						toAnchor: ((self anchorClassFor: aCandidate)
							nearestTo: sourceElement
							from: candidateElement) ] ]
]

{ #category : 'private - connection' }
CPProcessVisualElement >> installConnectionOn: aNodeElement for: aFlowNode [
	| previewLine previewCursor |
	connectFlowNodesOperationBlock ifNil: [ ^ self ].
	aFlowNode isEndEvent ifTrue: [ ^ self ].
	aNodeElement
		installConnectionPortSelectionColor: self selectionColor
		borderColor: self shapeBorderColor
		beginConnection: [ self beginConnectionFrom: aFlowNode ]
		dragStarted: [ :anEvent |
			| localPoint |
			connectionSourceModelElement := aFlowNode.
			self clearConnectionTarget.
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
			self updateSelectionAppearance ]
		dragged: [ :anEvent |
			| target |
			previewCursor relocate: (self globalPointToLocal: anEvent position).
			target := self
				validConnectionTargetAtGlobalPoint: anEvent position
				from: aFlowNode.
			self connectionTargetModelElement: target.
			self
				updateConnectionPreviewLine: previewLine
				cursor: previewCursor
				source: aFlowNode
				sourceElement: aNodeElement
				target: target ]
		dragEnded: [ :anEvent |
			| target |
			previewLine ifNotNil: [ previewLine removeFromParent ].
			previewCursor ifNotNil: [ previewCursor removeFromParent ].
			previewLine := nil.
			previewCursor := nil.
			target := self
				validConnectionTargetAtGlobalPoint: anEvent position
				from: aFlowNode.
			connectionSourceModelElement := nil.
			self clearConnectionTarget.
			target
				ifNotNil: [ self connectFrom: aFlowNode to: target ]
				ifNil: [ self updateSelectionAppearance ] ]
]
{ #category : 'private - connection' }
CPProcessVisualElement >> isValidConnectionTarget: aTarget from: aSource [
	| sourceContainer targetContainer assessment |
	connectFlowNodesOperationBlock ifNil: [ ^ false ].
	aSource == aTarget ifTrue: [ ^ false ].
	sourceContainer := self stagedFlowContainerContaining: aSource.
	targetContainer := self stagedFlowContainerContaining: aTarget.
	(sourceContainer isNil or: [ sourceContainer ~~ targetContainer ]) ifTrue: [ ^ false ].
	assessment := (connectFlowNodesOperationBlock
		value: aSource
		value: aTarget
		value: sourceContainer) assess.
	^ assessment isApplicable
]

{ #category : 'private - connection' }
CPProcessVisualElement >> validConnectionTargetAtGlobalPoint: aPoint from: aSource [
	| candidate |
	candidate := self
		connectionTargetAtGlobalPoint: aPoint
		excluding: aSource.
	candidate ifNil: [ ^ nil ].
	^ (self isValidConnectionTarget: candidate from: aSource)
		ifTrue: [ candidate ]
		ifFalse: [ nil ]
]

{ #category : 'private - connection' }
CPProcessVisualElement >> connectionTargetModelElement: aFlowNode [
	connectionTargetModelElement == aFlowNode ifTrue: [ ^ self ].
	connectionTargetModelElement := aFlowNode.
	self updateSelectionAppearance
]

{ #category : 'private - connection' }
CPProcessVisualElement >> clearConnectionTarget [
	self connectionTargetModelElement: nil
]

{ #category : 'private - connection' }
CPProcessVisualElement >> connectionTargetAtGlobalPoint: aPoint excluding: aFlowNode [
	| candidates |
	candidates := OrderedCollection new.
	shapeElementsByModelElement keysAndValuesDo: [ :aCandidate :anElement |
		aCandidate == aFlowNode ifFalse: [
			(anElement geometryBoundsInSpace containsPoint: aPoint) ifTrue: [
				| shape bounds |
				shape := anElement diagramShape.
				bounds := self stagedBoundsOf: shape.
				candidates add: {
					aCandidate.
					(self nestingDepthOfDiagramShape: shape).
					bounds } ] ] ].
	candidates ifEmpty: [ ^ nil ].
	^ self preferredConnectionTargetFrom: candidates
]

{ #category : 'private - connection' }
CPProcessVisualElement >> preferredConnectionTargetFrom: candidates [
	^ (candidates
		inject: candidates first
		into: [ :best :each |
			each second > best second
				ifTrue: [ each ]
				ifFalse: [
					(each second = best second
						and: [ (each third width * each third height) < (best third width * best third height) ])
							ifTrue: [ each ]
							ifFalse: [ best ] ] ]) first
]

{ #category : 'private - connection' }
CPProcessVisualElement >> connectFrom: aSource to: aTarget [
	| sourceContainer targetContainer assessment |
	connectFlowNodesOperationBlock ifNil: [ ^ nil ].
	sourceContainer := self stagedFlowContainerContaining: aSource.
	targetContainer := self stagedFlowContainerContaining: aTarget.
	(sourceContainer isNil or: [ sourceContainer ~~ targetContainer ]) ifTrue: [ ^ nil ].
	assessment := (connectFlowNodesOperationBlock
		value: aSource
		value: aTarget
		value: sourceContainer) apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateSelectionAppearance ].
	^ assessment
]

{ #category : 'private - connection' }
CPProcessVisualElement >> updateConnectionPortVisibility [
	shapeElementsByModelElement keysAndValuesDo: [ :aFlowNode :aShapeElement |
		aShapeElement connectionPortVisible:
			(aFlowNode == hoveredModelElement
				or: [ aFlowNode == selectedModelElement
				or: [ aFlowNode == connectionSourceModelElement ] ]) ]
]

{ #category : 'private - connection' }
CPProcessVisualElement >> beginConnectionFrom: aFlowNode [
	connectionSourceModelElement := aFlowNode.
	self clearConnectionTarget.
	self updateSelectionAppearance
]

{ #category : 'private - connection' }
CPProcessVisualElement >> completeConnectionTo: aFlowNode [
	| source |
	source := connectionSourceModelElement.
	connectionSourceModelElement := nil.
	self clearConnectionTarget.
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

{ #category : 'configuration' }
CPProcessVisualElement >> setEdgeLabelPlacementOperationFor: aBlock [
	setEdgeLabelPlacementOperationBlock := aBlock
]



{ #category : 'private - labels' }
CPProcessVisualElement >> positionEdgeLabelFor: anEdge pathFraction: aPathFraction waypoints: someWaypoints [
	| labelHost offset segmentPlacement placement |
	labelHost := self edgeLabelHostFor: anEdge ifAbsent: [ ^ self ].
	offset := (self stagedLabelOffsetOf: anEdge) ifNil: [ -14.0 ].
	segmentPlacement := (self
		edgeLabelPathFor: anEdge
		waypoints: someWaypoints
		usingLiveBounds: true)
		segmentPlacementAtFraction: aPathFraction.
	placement := self
		labelPlacementFor: anEdge
		segmentIndex: segmentPlacement first
		segmentPosition: segmentPlacement second
		offset: offset
		waypoints: someWaypoints
		usingLiveBounds: true.
	self
		positionEdgeLabelFor: anEdge
		centeredAt: placement first
]

{ #category : 'operations' }
CPProcessVisualElement >> setWaypoints: somePoints forEdge: anEdge [
	| assessment currentWaypoints topologyChanges pathFraction segmentPlacement offset placementAssessment |
	setEdgeWaypointsOperationBlock ifNil: [ ^ nil ].
	currentWaypoints := self stagedWaypointsOf: anEdge.
	topologyChanges := currentWaypoints size ~= somePoints size.
	topologyChanges ifTrue: [
		| labelPath segmentIndex segmentPosition |
		labelPath := self
			edgeLabelPathFor: anEdge
			waypoints: currentWaypoints
			usingLiveBounds: true.
		segmentIndex := (self stagedLabelSegmentIndexOf: anEdge) ifNil: [ labelPath defaultSegmentIndex ].
		segmentPosition := (self stagedLabelSegmentPositionOf: anEdge) ifNil: [ 0.5 ].
		pathFraction := labelPath
			pathFractionForSegmentIndex: segmentIndex
			segmentPosition: segmentPosition ].

	assessment := (setEdgeWaypointsOperationBlock value: anEdge value: somePoints) apply.
	assessment isApplicable
		ifTrue: [
			topologyChanges ifTrue: [
				segmentPlacement := (self
					edgeLabelPathFor: anEdge
					waypoints: somePoints
					usingLiveBounds: true)
					segmentPlacementAtFraction: pathFraction.
				offset := (self stagedLabelOffsetOf: anEdge) ifNil: [ -14.0 ].
				setEdgeLabelPlacementOperationBlock ifNotNil: [
					placementAssessment := (setEdgeLabelPlacementOperationBlock
						value: anEdge
						value: segmentPlacement first
						value: segmentPlacement second
						value: offset) apply ] ].
			self refresh ]
		ifFalse: [ self updateSelectionAppearance ].
	^ assessment
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> installBendpointInsertionOn: anEdgeElement for: anEdge segmentIndex: aSegmentIndex [
	| isDragging dragStartEventPosition insertedPoint previewLines labelPathFraction labelPath segmentIndex segmentPosition |
	setEdgeWaypointsOperationBlock ifNil: [ ^ self ].
	isDragging := false.
	previewLines := #().

	anEdgeElement
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				isDragging := true.
				dragStartEventPosition := anEvent position.
				insertedPoint := self globalPointToLocal: anEvent position.
				labelPath := self
					edgeLabelPathFor: anEdge
					waypoints: (self stagedWaypointsOf: anEdge)
					usingLiveBounds: true.
				segmentIndex := (self stagedLabelSegmentIndexOf: anEdge) ifNil: [ labelPath defaultSegmentIndex ].
				segmentPosition := (self stagedLabelSegmentPositionOf: anEdge) ifNil: [ 0.5 ].
				labelPathFraction := labelPath
					pathFractionForSegmentIndex: segmentIndex
					segmentPosition: segmentPosition.
				(self lineElementsForEdge: anEdge)
					do: [ :aLine | aLine visibility: BlVisibility hidden ].
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| currentPoint proposed |
					currentPoint := insertedPoint
						+ (anEvent position - dragStartEventPosition).
					proposed := self
						waypointsFor: anEdge
						inserting: currentPoint
						afterSegment: aSegmentIndex.
					previewLines do: [ :aLine | aLine removeFromParent ].
					previewLines := self newPreviewLinesFor: anEdge waypoints: proposed.
					previewLines do: [ :aLine | self addChild: aLine ].
					self
						positionEdgeLabelFor: anEdge
						pathFraction: labelPathFraction
						waypoints: proposed.
					self
						positionReconnectHandlesFor: anEdge
						usingWaypoints: proposed.
					self bringReconnectHandlesToFront.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| currentPoint proposed |
					isDragging := false.
					currentPoint := insertedPoint
						+ (anEvent position - dragStartEventPosition).
					proposed := self
						waypointsFor: anEdge
						inserting: currentPoint
						afterSegment: aSegmentIndex.
					previewLines do: [ :aLine | aLine removeFromParent ].
					previewLines := #().
					(self lineElementsForEdge: anEdge)
						do: [ :aLine | aLine visibility: BlVisibility visible ].
					self setWaypoints: proposed forEdge: anEdge.
					anEvent consumed: true ] ])
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> waypointsFor: anEdge inserting: aPoint afterSegment: aSegmentIndex [
	| waypoints proposed insertionIndex |
	waypoints := self stagedWaypointsOf: anEdge.
	proposed := waypoints asOrderedCollection copy.
	insertionIndex := aSegmentIndex + 1.
	proposed add: aPoint beforeIndex: insertionIndex.
	^ proposed
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> positionBendpointHandlesFor: anEdge usingWaypoints: someWaypoints [
	| edgeVisual |
	edgeVisual := edgeVisualsByEdge at: anEdge ifAbsent: [ ^ self ].
	edgeVisual positionBendpointHandlesUsingWaypoints: someWaypoints
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> installBendpointHandlesFor: anEdge [
	| waypoints handles |
	setEdgeWaypointsOperationBlock ifNil: [ ^ self ].
	waypoints := self stagedWaypointsOf: anEdge.
	waypoints size < 3 ifTrue: [
		(edgeVisualsByEdge at: anEdge ifAbsent: [ ^ self ])
			bendpointHandles: #().
		^ self ].
	handles := OrderedCollection new.

	2 to: waypoints size - 1 do: [ :index |
		handles add: (self
			newBendpointHandleFor: anEdge
			waypointIndex: index
			at: (waypoints at: index)) ].

	(edgeVisualsByEdge at: anEdge)
		bendpointHandles: handles.
	handles do: [ :aHandle | self addChild: aHandle ]
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> newBendpointHandleFor: anEdge waypointIndex: waypointIndex at: aPoint [
	| edgeVisual previewLines |
	edgeVisual := edgeVisualsByEdge at: anEdge.
	previewLines := #().
	^ edgeVisual
		newBendpointHandleAt: aPoint
		waypointIndex: waypointIndex
		selectionColor: self selectionColor
		removeRequested: [ :anIndex |
			| waypoints proposed |
			waypoints := (self stagedWaypointsOf: anEdge) asOrderedCollection.
			waypoints size > 2 ifTrue: [
				proposed := waypoints copy.
				proposed removeAt: anIndex.
				self setWaypoints: proposed forEdge: anEdge ] ]
		dragStarted: [ :anEvent | ]
		dragged: [ :anEvent :newPoint |
			| proposed |
			proposed := self
				previewWaypointsFor: anEdge
				waypointIndex: waypointIndex
				at: newPoint.
			previewLines do: [ :aLine | aLine removeFromParent ].
			previewLines := self newPreviewLinesFor: anEdge waypoints: proposed.
			previewLines do: [ :aLine | self addChild: aLine ].
			self positionEdgeLabelFor: anEdge usingWaypoints: proposed.
			self
				positionReconnectHandlesFor: anEdge
				usingWaypoints: proposed.
			self bringReconnectHandlesToFront.
			self bringBendpointHandlesToFront ]
		dragEnded: [ :anEvent :newPoint |
			| proposed |
			proposed := self
				previewWaypointsFor: anEdge
				waypointIndex: waypointIndex
				at: newPoint.
			previewLines do: [ :aLine | aLine removeFromParent ].
			previewLines := #().
			self setWaypoints: proposed forEdge: anEdge ]
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> previewWaypointsFor: anEdge waypointIndex: waypointIndex at: aPoint [
	| proposed |
	proposed := (self stagedWaypointsOf: anEdge) asOrderedCollection copy.
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
	edgeVisualsByEdge valuesDo: [ :anEdgeVisual |
		anEdgeVisual bringBendpointHandlesToFrontIn: self ]
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
	edgeVisualsByEdge at: anEdge ifAbsent: [ ^ self ].
	lines := self lineElementsForEdge: anEdge.
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

	(edgeVisualsByEdge at: anEdge)
		reconnectHandles: { sourceHandle. targetHandle }.
	self addChild: sourceHandle.
	self addChild: targetHandle
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> edgeForSequenceFlow: aSequenceFlow ifFound: aFoundBlock ifNone: aNoneBlock [
	edgeVisualsByEdge keysDo: [ :anEdge |
		anEdge modelElement == aSequenceFlow ifTrue: [
			^ aFoundBlock value: anEdge ] ].
	^ aNoneBlock value
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> validReconnectTargetAtGlobalPoint: aPoint for: aSequenceFlow movingSource: movesSource [
	| candidate source target assessment |
	candidate := self
		connectionTargetAtGlobalPoint: aPoint
		excluding: nil.
	candidate ifNil: [ ^ nil ].
	reconnectSequenceFlowOperationBlock ifNil: [ ^ nil ].

	source := self stagedSourceOf: aSequenceFlow.
	target := self stagedTargetOf: aSequenceFlow.
	movesSource
		ifTrue: [ source := candidate ]
		ifFalse: [ target := candidate ].

	assessment := (reconnectSequenceFlowOperationBlock
		value: aSequenceFlow
		value: source
		value: target
		value: (self stagedFlowContainerContaining: aSequenceFlow)) assess.
	^ assessment isApplicable
		ifTrue: [ candidate ]
		ifFalse: [ nil ]
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> newReconnectHandleFor: aSequenceFlow movingSource: movesSource owner: ownerElement other: otherElement [
	| edgeVisual previewLine previewCursor adjacentReference hiddenTerminalLine reconnectEdge |
	edgeVisual := self
		edgeForSequenceFlow: aSequenceFlow
		ifFound: [ :anEdge | edgeVisualsByEdge at: anEdge ]
		ifNone: [ ^ nil ].
	^ edgeVisual
		newReconnectHandleMovingSource: movesSource
		selectionColor: self selectionColor
		dragStarted: [ :anEvent :handle |
			| localPoint waypoints lines adjacentPoint |
			self clearConnectionTarget.
			adjacentReference := nil.
			hiddenTerminalLine := nil.
			reconnectEdge := edgeVisual diagramEdge.
			waypoints := self stagedWaypointsOf: reconnectEdge.
			waypoints size >= 3 ifTrue: [
				adjacentPoint := movesSource
					ifTrue: [ waypoints second ]
					ifFalse: [ waypoints at: waypoints size - 1 ].
				adjacentReference := self anchorReferenceElementAt: adjacentPoint.
				self addChild: adjacentReference.
				lines := edgeVisual lineElements.
				lines ifNotEmpty: [
					hiddenTerminalLine := movesSource
						ifTrue: [ lines first ]
						ifFalse: [ lines last ].
					hiddenTerminalLine visibility: BlVisibility hidden ] ].
			localPoint := self globalPointToLocal: anEvent position.
			previewCursor := BlElement new
				extent: 1 @ 1;
				background: Color transparent;
				constraintsDo: [ :c | c ignoreByLayout ];
				relocate: localPoint;
				yourself.
			previewLine := BlLineElement new
				border: (BlBorder paint: self selectionColor width: 1.5);
				constraintsDo: [ :c | c ignoreByLayout ];
				yourself.
			self
				updateReconnectPreviewLine: previewLine
				cursor: previewCursor
				sequenceFlow: aSequenceFlow
				movingSource: movesSource
				target: nil
				adjacentReference: adjacentReference.
			movesSource ifFalse: [
				previewLine toHead: (BlArrowheadSimpleArrow new
					border: (BlBorder paint: self selectionColor width: 1.5)) ].
			self addChild: previewCursor.
			self addChildFirst: previewLine ]
		dragged: [ :anEvent :handle |
			| candidate |
			previewCursor relocate: (self globalPointToLocal: anEvent position).
			candidate := self
				validReconnectTargetAtGlobalPoint: anEvent position
				for: aSequenceFlow
				movingSource: movesSource.
			self connectionTargetModelElement: candidate.
			self
				updateReconnectPreviewLine: previewLine
				cursor: previewCursor
				sequenceFlow: aSequenceFlow
				movingSource: movesSource
				target: candidate
				adjacentReference: adjacentReference.
			edgeVisual
				positionReconnectHandle: handle
				fromPreviewLine: previewLine
				movingSource: movesSource
				within: self.
			self
				positionEdgeLabelForReconnectPreview: reconnectEdge
				line: previewLine
				movingSource: movesSource ]
		dragEnded: [ :anEvent :handle |
			| candidate source target |
			previewLine ifNotNil: [ previewLine removeFromParent ].
			previewCursor ifNotNil: [ previewCursor removeFromParent ].
			adjacentReference ifNotNil: [ adjacentReference removeFromParent ].
			hiddenTerminalLine ifNotNil: [
				hiddenTerminalLine visibility: BlVisibility visible ].
			previewLine := nil.
			previewCursor := nil.
			adjacentReference := nil.
			hiddenTerminalLine := nil.
			self positionEdgeLabelFor: reconnectEdge.
			candidate := self
				validReconnectTargetAtGlobalPoint: anEvent position
				for: aSequenceFlow
				movingSource: movesSource.
			self clearConnectionTarget.
			candidate
				ifNotNil: [
					source := self stagedSourceOf: aSequenceFlow.
					target := self stagedTargetOf: aSequenceFlow.
					movesSource
						ifTrue: [ source := candidate ]
						ifFalse: [ target := candidate ].
					self
						reconnectSequenceFlow: aSequenceFlow
						source: source
						target: target ]
				ifNil: [
					self
						positionReconnectHandlesFor: reconnectEdge
						fromLines: edgeVisual lineElements ] ]
]


{ #category : 'private - reconnecting' }
CPProcessVisualElement >> positionEdgeLabelForReconnectPreview: anEdge line: aPreviewLine movingSource: movesSource [
	| labelHost waypoints points endpoint segmentIndex segmentPosition offset placement labelPath |
	labelHost := self edgeLabelHostFor: anEdge ifAbsent: [ ^ self ].
	waypoints := self stagedWaypointsOf: anEdge.
	points := (self
		renderedPathPointsFor: anEdge
		waypoints: waypoints
		usingLiveBounds: true) asOrderedCollection copy.

	endpoint := movesSource
		ifTrue: [
			aPreviewLine fromAnchor
				positionForAnchoredElement: aPreviewLine
				within: self ]
		ifFalse: [
			aPreviewLine toAnchor
				positionForAnchoredElement: aPreviewLine
				within: self ].
	movesSource
		ifTrue: [ points at: 1 put: endpoint ]
		ifFalse: [ points at: points size put: endpoint ].

	labelPath := CPProcessEdgeLabelPath points: points.
	segmentIndex := (self stagedLabelSegmentIndexOf: anEdge) ifNil: [ labelPath defaultSegmentIndex ].
	segmentPosition := (self stagedLabelSegmentPositionOf: anEdge) ifNil: [ 0.5 ].
	offset := (self stagedLabelOffsetOf: anEdge) ifNil: [ -14.0 ].
	placement := labelPath
		placementAtSegmentIndex: segmentIndex
		segmentPosition: segmentPosition
		offset: offset.
	self
		positionEdgeLabelFor: anEdge
		centeredAt: placement first
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> updateReconnectHandlePositions [
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		anEdgeVisual reconnectHandles isEmpty ifFalse: [
			self
				positionReconnectHandlesFor: anEdge
				fromLines: anEdgeVisual lineElements ] ]
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> positionReconnectHandlesFor: anEdge fromLines: someLines [
	| edgeVisual firstLine lastLine sourcePoint targetPoint |
	someLines ifEmpty: [ ^ self ].
	edgeVisual := edgeVisualsByEdge at: anEdge ifAbsent: [ ^ self ].
	edgeVisual reconnectHandles isEmpty ifTrue: [ ^ self ].

	firstLine := someLines first.
	lastLine := someLines last.
	sourcePoint := firstLine fromAnchor
		positionForAnchoredElement: firstLine
		within: self.
	targetPoint := lastLine toAnchor
		positionForAnchoredElement: lastLine
		within: self.

	edgeVisual
		positionReconnectHandlesAtSource: sourcePoint
		target: targetPoint
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> positionReconnectHandlesFor: anEdge usingWaypoints: someWaypoints [
	| edgeVisual sequenceFlow source target sourceElement targetElement interiorPoints sourcePoint targetPoint |
	someWaypoints size < 3 ifTrue: [ ^ self ].
	edgeVisual := edgeVisualsByEdge at: anEdge ifAbsent: [ ^ self ].
	edgeVisual reconnectHandles isEmpty ifTrue: [ ^ self ].

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

	edgeVisual
		positionReconnectHandlesAtSource: sourcePoint
		target: targetPoint
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> dockingPointFor: aFlowNode element: aNodeElement toward: aPoint [
	^ self
		dockingPointFor: aFlowNode
		bounds: (aNodeElement bounds inParent: self)
		toward: aPoint
]




{ #category : 'private - reconnecting' }
CPProcessVisualElement >> reconnectSequenceFlow: aSequenceFlow source: aSource target: aTarget [
	| assessment |
	reconnectSequenceFlowOperationBlock ifNil: [ ^ nil ].
	assessment := (reconnectSequenceFlowOperationBlock
		value: aSequenceFlow
		value: aSource
		value: aTarget
		value: (self stagedFlowContainerContaining: aSequenceFlow)) apply.
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
	aLine
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent |
				connectionSourceModelElement ifNil: [
					anEvent modifiers isShift
						ifTrue: [ self toggleSelectionOf: anEdge modelElement ]
						ifFalse: [ self selectOnly: anEdge modelElement ].
					self requestFocus.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDoubleClickEvent
			do: [ :anEvent |
				connectionSourceModelElement ifNil: [
					self selectOnly: anEdge modelElement.
					self beginEditingLabelForEdge: anEdge.
					anEvent consumed: true ] ])
]

{ #category : 'private - installing' }
CPProcessVisualElement >> installKeyboardHandler [
	self addEventHandler: (BlEventHandler
		on: BlKeyDownEvent
		do: [ :anEvent |
			(anEvent target == self
				and: [
					anEvent key = BlKeyboardKey delete
						or: [ anEvent key = BlKeyboardKey backspace ] ])
				ifTrue: [
					self removeSelection.
					anEvent consumed: true ].
			(anEvent target == self
				and: [ anEvent key = BlKeyboardKey escape ])
				ifTrue: [
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
		edgeForFlow := edgeVisualsByEdge keys
			detect: [ :anEdge | anEdge modelElement == each ]
			ifNone: [ nil ].
		edgeForFlow notNil and: [
			selectedNodes noneSatisfy: [ :aNode |
				self edge: edgeForFlow isIncidentTo: aNode ] ] ].

	assessments := OrderedCollection new.
	selectedNodes do: [ :aNode |
		removeFlowNodeOperationBlock ifNotNil: [
			assessments add: (removeFlowNodeOperationBlock
				value: aNode
				value: (self stagedFlowContainerContaining: aNode)) ] ].
	selectedFlows do: [ :aFlow |
		removeSequenceFlowOperationBlock ifNotNil: [
			assessments add: (removeSequenceFlowOperationBlock
				value: aFlow
				value: (self stagedFlowContainerContaining: aFlow)) ] ].

	rejected := assessments
		detect: [ :anOperation | anOperation assess isApplicable not ]
		ifNone: [ nil ].
	rejected ifNotNil: [ ^ rejected assess ].

	assessments do: [ :anOperation | anOperation apply ].
	selectedModelElements removeAll.
	selectedModelElement := nil.
	connectionSourceModelElement := nil.
	connectionTargetModelElement := nil.
	insertionTargetEdge := nil.
	selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: nil ].
	self refresh
]

{ #category : 'private - selection' }
CPProcessVisualElement >> clearLocalSelection [
	connectionSourceModelElement := nil.
	connectionTargetModelElement := nil.
	insertionTargetEdge := nil.
	selectedModelElements removeAll.
	selectedModelElement := nil.
	self updateSelectionAppearance
]

{ #category : 'private - interaction' }
CPProcessVisualElement >> clearInteractionAndSelection [
	connectionSourceModelElement := nil.
	connectionTargetModelElement := nil.
	insertionTargetEdge := nil.
	selectedModelElements removeAll.
	selectedModelElement := nil.
	self updateSelectionAppearance.
	selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: nil ]
]

{ #category : 'private - interaction' }
CPProcessVisualElement >> cancelInteraction [
	connectionSourceModelElement ifNotNil: [
		connectionSourceModelElement := nil.
		connectionTargetModelElement := nil.
		insertionTargetEdge := nil.
		self updateSelectionAppearance.
		^ self ].
	self clearInteractionAndSelection
]

{ #category : 'private - labels' }
CPProcessVisualElement >> edgeLabelHostFor: anEdge ifAbsent: aBlock [
	| edgeVisual |
	edgeVisual := edgeVisualsByEdge at: anEdge ifAbsent: [ ^ aBlock value ].
	^ edgeVisual labelHost ifNil: [ aBlock value ]
]



{ #category : 'configuration' }
CPProcessVisualElement >> setShapeExpandedOperationFor: aBlock [
	setShapeExpandedOperationBlock := aBlock
]

{ #category : 'private - type selection' }
CPProcessVisualElement >> installSubProcessTypePopupOn: aShapeElement for: aFlowNode shape: aShape [
	aFlowNode isSubProcess ifFalse: [ ^ self ].
	(self stagedExpandedOf: aShape) ifTrue: [ ^ self ].
	self
		installTypePopupOn: aShapeElement
		for: aFlowNode
		shape: aShape
		selection: (CPSubProcessTypeSelection typeClass: aFlowNode class)
		iconExtent: 14 @ 14
		configure: [ :anElement |
			anElement constraintsDo: [ :c |
				c frame horizontal alignCenter.
				c frame vertical alignBottom.
				c margin: (BlInsets bottom: 4 right: 34) ] ]
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> flowElementMementoFor: aFlowElement [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aFlowElement
		inRootMemento: memento.
	^ context ifNotNil: [ context childMementoFor: aFlowElement ]
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedFlowContainerContaining: aFlowElement [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aFlowElement
		inRootMemento: memento.
	^ context ifNotNil: [ context container ]
]


{ #category : 'private - containment' }
CPProcessVisualElement >> processVisualAtRootDiagramPoint: aRootPoint excluding: anExcludedFlowElement [
	| localPoint candidates target |
	localPoint := self localPointForRootDiagramPoint: aRootPoint.
	candidates := OrderedCollection new.
	shapeElementsByModelElement keysAndValuesDo: [ :aModelElement :aShapeElement |
		(aModelElement isSubProcess
			and: [ aModelElement ~~ anExcludedFlowElement
			and: [ aShapeElement nestedProcessVisual notNil ] ]) ifTrue: [
				| bounds |
				bounds := self stagedBoundsOf: aShapeElement diagramShape.
				(bounds containsPoint: localPoint) ifTrue: [
					candidates add: { aModelElement. aShapeElement. bounds } ] ] ].
	candidates ifEmpty: [ ^ self ].
	target := candidates
		inject: candidates first
		into: [ :smallest :each |
			(each third width * each third height)
				< (smallest third width * smallest third height)
					ifTrue: [ each ]
					ifFalse: [ smallest ] ].
	^ target second nestedProcessVisual
		processVisualAtRootDiagramPoint: aRootPoint
		excluding: anExcludedFlowElement
]

{ #category : 'private - containment' }
CPProcessVisualElement >> targetProcessVisualForLocalPoint: aLocalPoint excluding: anExcludedFlowElement [
	| rootPoint |
	rootPoint := self rootDiagramPointForLocalPoint: aLocalPoint.
	^ rootVisual
		processVisualAtRootDiagramPoint: rootPoint
		excluding: anExcludedFlowElement
]

{ #category : 'private - containment' }
CPProcessVisualElement >> boundsCenteredAtRootDiagramPoint: aRootPoint extent: anExtent [
	| localCenter |
	localCenter := self localPointForRootDiagramPoint: aRootPoint.
	^ (localCenter - (anExtent / 2)) extent: anExtent
]



{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedExpandedOf: aShape [
	| shapeMemento description |
	shapeMemento := diagramMemento childMementoFor: aShape inRelation: elementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #isExpanded ].
	^ shapeMemento readUsing: description
]



{ #category : 'accessing - testing' }
CPProcessVisualElement >> shapeElementsByModelElement [
	^ shapeElementsByModelElement
]



{ #category : 'private - subprocess' }
CPProcessVisualElement >> installNestedProcessVisualIn: aShapeElement for: aSubProcess bounds: aRectangle [
	| nestedVisual |
	nestedVisual := CPProcessVisualElement new.
	self configureNestedProcessVisual: nestedVisual.
	nestedVisual
		parentProcessVisual: self;
		hostShape: aShapeElement diagramShape.
	aShapeElement hostNestedProcessVisual: nestedVisual.
	nestedVisual
		memento: memento
		flowContainer: aSubProcess
]

{ #category : 'private - subprocess' }
CPProcessVisualElement >> installExpandedSubProcessBorderInteractionOn: aShapeElement for: aFlowNode shape: aShape [
	aShapeElement subProcessBorderInteractionElements do: [ :borderElement |
		self installSelectionOn: borderElement for: aFlowNode.
		self
			installPositioningFrom: borderElement
			moving: aShapeElement
			for: aShape ]
]


{ #category : 'private - subprocess' }
CPProcessVisualElement >> configureNestedProcessVisual: aVisual [
	aVisual
		rootVisual: rootVisual;
		selectionChangedDo: selectionChangedBlock;
		moveShapeOperationFor: moveShapeOperationBlock;
		transferFlowNodeOperationFor: transferFlowNodeOperationBlock;
		moveShapesOperationFor: moveShapesOperationBlock;
		resizeShapeOperationFor: resizeShapeOperationBlock;
		createFlowNodeOperationFor: createFlowNodeOperationBlock;
		replaceFlowNodeOperationFor: replaceFlowNodeOperationBlock;
		connectFlowNodesOperationFor: connectFlowNodesOperationBlock;
		insertFlowNodeOperationFor: insertFlowNodeOperationBlock;
		removeFlowNodeOperationFor: removeFlowNodeOperationBlock;
		removeSequenceFlowOperationFor: removeSequenceFlowOperationBlock;
		reconnectSequenceFlowOperationFor: reconnectSequenceFlowOperationBlock;
		setEdgeWaypointsOperationFor: setEdgeWaypointsOperationBlock;
		setShapeExpandedOperationFor: setShapeExpandedOperationBlock;
		setEdgeLabelPlacementOperationFor: setEdgeLabelPlacementOperationBlock
]

{ #category : 'private - subprocess' }
CPProcessVisualElement >> installSubProcessExpansionOn: aShapeElement for: aFlowNode shape: aShape [
	aFlowNode isSubProcess ifFalse: [ ^ self ].
	setShapeExpandedOperationBlock ifNil: [ ^ self ].
	aShapeElement installSubProcessExpansion: [ :isExpanded |
		self setShape: aShape expanded: isExpanded ]
]

{ #category : 'operations' }
CPProcessVisualElement >> setShape: aShape expanded: aBoolean [
	| assessment |
	setShapeExpandedOperationBlock ifNil: [ ^ nil ].
	assessment := (setShapeExpandedOperationBlock
		value: aShape
		value: aBoolean) apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateSelectionAppearance ].
	^ assessment
]



{ #category : 'configuration' }
CPProcessVisualElement >> transferFlowNodeOperationFor: aBlock [
	transferFlowNodeOperationBlock := aBlock
]


{ #category : 'operations' }
CPProcessVisualElement >> transferFlowNode: aFlowNode shape: aShape toContainer: aFlowContainer bounds: aRectangle [
	| assessment constrainedBounds |
	transferFlowNodeOperationBlock ifNil: [ ^ nil ].
	constrainedBounds := self constrainedBounds: aRectangle forFlowContainer: aFlowContainer.
	assessment := (transferFlowNodeOperationBlock
		value: aFlowNode
		value: aFlowContainer
		value: constrainedBounds) apply.
	assessment isApplicable
		ifTrue: [ self refreshEditor ]
		ifFalse: [ self refresh ].
	^ assessment
]
