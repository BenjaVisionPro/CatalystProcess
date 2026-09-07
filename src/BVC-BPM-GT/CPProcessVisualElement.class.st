"I render and coordinate one BPMN flow-container editing surface inside the single enclosing Atelier editor.

For the root I render CPProcess. For an expanded Sub-Process, its CPProcessShapeElement hosts another instance of me configured for that CPSubProcess. The nested instance uses the same root memento, editing collaborator, authoritative DI selection and diagram state; it is a Bloc child of the Sub-Process node, not another Atelier.

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
		'diagramContext',
		'planeGeometry',
		'diagramViewport',
		'shapeElementsByShape',
		'shapeElementsByModelElement',
		'edgeVisualsByEdge',
		'hoveredModelElement',
		'diagramElements',
		'diagramSelection',
		'selectionChangedBlock',
		'diagramEditing',
		'diagramElementsRemovedBlock',
		'connectionSourceModelElement',
		'connectionTargetModelElement',
		'insertionTargetEdge',
		'boundaryEventPaletteTargetModelElement',
		'collaborationHosted',
		'collaborationVisual',
		'collaborationChangedBlock',
		'viewportExtent',
		'diagramLayer'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessVisualElement >> initialize [
	super initialize.
	diagramEditing := CPReadOnlyProcessDiagramEditing new.
	diagramSelection := CPDiagramSelection new.
	shapeElementsByShape := IdentityDictionary new.
	shapeElementsByModelElement := IdentityDictionary new.
	edgeVisualsByEdge := IdentityDictionary new.
	boundaryEventPaletteTargetModelElement := nil.
	rootVisual := self.
	parentProcessVisual := nil.
	hostShape := nil.
	collaborationHosted := false.
	collaborationVisual := nil.
	viewportExtent := 1280 @ 700.
	planeGeometry := CPDiagramPlaneGeometry new.
	diagramViewport := CPDiagramViewport
		viewportExtent: viewportExtent
		diagramExtent: planeGeometry diagramExtent.
	diagramLayer := nil.
	self
		layout: BlFrameLayout new;
		clipChildren: false;
		beFocusable.
	self installDiagramCursor.
	self installKeyboardHandler.
	self installPaletteDropHandler
]


{ #category : 'configuration' }
CPProcessVisualElement >> diagramEditing: anEditing [
	diagramEditing := anEditing
]

{ #category : 'accessing' }
CPProcessVisualElement >> diagramEditing [
	^ diagramEditing
]

{ #category : 'configuration' }
CPProcessVisualElement >> beCollaborationHosted [
	collaborationHosted := true.
	self constraintsDo: [ :c |
		c minWidth: 0.
		c minHeight: 0 ]
]

{ #category : 'configuration' }
CPProcessVisualElement >> beStandalone [
	collaborationHosted := false.
	self refresh
]

{ #category : 'testing' }
CPProcessVisualElement >> isCollaborationHosted [
	^ collaborationHosted
]

{ #category : 'configuration' }
CPProcessVisualElement >> collaborationVisual: aCollaborationVisual [
	collaborationVisual := aCollaborationVisual.
	self refresh
]

{ #category : 'accessing - collaboration' }
CPProcessVisualElement >> collaborationVisual [
	^ collaborationVisual
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

{ #category : 'accessing - presentation' }
CPProcessVisualElement >> canvasExtent [
	^ diagramViewport canvasExtent
]

{ #category : 'accessing - presentation' }
CPProcessVisualElement >> viewportExtent [
	^ viewportExtent
]

{ #category : 'accessing - presentation' }
CPProcessVisualElement >> diagramExtent [
	^ planeGeometry diagramExtent
]

{ #category : 'configuration' }
CPProcessVisualElement >> viewportExtent: anExtent [
	viewportExtent := anExtent max: 1 @ 1.
	self updateCanvasExtent
]

{ #category : 'private - layout' }
CPProcessVisualElement >> updateCanvasExtent [
	(parentProcessVisual isNil and: [ collaborationHosted not ])
		ifTrue: [
			diagramViewport := CPDiagramViewport
				viewportExtent: viewportExtent
				diagramExtent: planeGeometry diagramExtent.
			self constraintsDo: [ :c |
				c horizontal exact: diagramViewport canvasExtent x.
				c vertical exact: diagramViewport canvasExtent y ].
			self updateDiagramLayerGeometry ]
		ifFalse: [
			diagramViewport := CPDiagramViewport
				viewportExtent: viewportExtent
				diagramExtent: 0 @ 0.
			self constraintsDo: [ :c |
				c horizontal matchParent.
				c vertical matchParent ].
			self updateDiagramLayerGeometry ]
]

{ #category : 'private - layout' }
CPProcessVisualElement >> updateDiagramLayerGeometry [
	| layerOrigin |
	diagramLayer ifNil: [ ^ self ].
	planeGeometry ifNil: [ ^ self ].
	layerOrigin := self diagramContentOffset.
	diagramLayer
		constraintsDo: [ :c | c ignoreByLayout ];
		extent: planeGeometry layerExtent;
		relocate: layerOrigin
]

{ #category : 'accessing - presentation' }
CPProcessVisualElement >> cameraSlack [
	^ diagramViewport cameraSlack
]


{ #category : 'geometry' }
CPProcessVisualElement >> diagramContentOffset [
	^ (collaborationHosted
		ifTrue: [ self hostedDiagramInset ]
		ifFalse: [ diagramViewport cameraSlack ])
		+ planeGeometry normalizationOffset
]


{ #category : 'geometry' }
CPProcessVisualElement >> diagramBoundsOriginInContent [
	^ self diagramContentOffset + planeGeometry diagramBounds origin
]

{ #category : 'accessing - presentation' }
CPProcessVisualElement >> diagramBounds [
	^ planeGeometry diagramBounds
]

{ #category : 'accessing - presentation' }
CPProcessVisualElement >> hostedDiagramInset [
	^ 24 @ 24
]

{ #category : 'private - coordinates' }
CPProcessVisualElement >> diagramPointForGlobalPoint: aGlobalPoint [
	^ diagramLayer
		ifNil: [ self globalPointToLocal: aGlobalPoint ]
		ifNotNil: [ diagramLayer globalPointToLocal: aGlobalPoint ]
]

{ #category : 'private - building' }
CPProcessVisualElement >> addDiagramChild: anElement [
	diagramLayer
		ifNil: [ self addChild: anElement ]
		ifNotNil: [ diagramLayer addChild: anElement ]
]

{ #category : 'private - building' }
CPProcessVisualElement >> addDiagramChildFirst: anElement [
	diagramLayer
		ifNil: [ self addChildFirst: anElement ]
		ifNotNil: [ diagramLayer addChildFirst: anElement ]
]

{ #category : 'private - coordinates' }
CPProcessVisualElement >> diagramPresentationParent [
	^ diagramLayer ifNil: [ self ]
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
CPProcessVisualElement >> hostShape [
	^ hostShape
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
	| diagram elements shapes edges |
	self removeChildren.
	shapeElementsByShape removeAll.
	shapeElementsByModelElement removeAll.
	edgeVisualsByEdge removeAll.
	hoveredModelElement := nil.
	insertionTargetEdge := nil.
	connectionTargetModelElement := nil.
	boundaryEventPaletteTargetModelElement := nil.
	diagram := memento readUsing: diagramDescription.
	diagram ifNil: [ ^ self ].

	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: memento
		using: diagramDescription.
	elements := diagramContext elements.
	elements ifNil: [ ^ self ].
	diagramElements := elements.

	edges := elements select: [ :each |
		each isEdge and: [ self shouldRenderDiagramElement: each ] ].
	shapes := elements select: [ :each |
		each isShape and: [ self shouldRenderDiagramElement: each ] ].
	planeGeometry := CPDiagramPlaneGeometry
		shapes: shapes
		edges: edges
		context: diagramContext.
	diagramLayer := parentProcessVisual isNil
		ifTrue: [ BlElement new layout: BlFrameLayout new; clipChildren: false; yourself ]
		ifFalse: [ nil ].
	diagramLayer ifNotNil: [ self addChild: diagramLayer ].
	self updateCanvasExtent.
	self addPaletteDropSurface.
	shapes do: [ :each | self addShapeFor: each ].
	edges do: [ :each | self addEdgeFor: each ].
	self bringNodeInteractionSurfacesToFront.
	self bringReconnectHandlesToFront.
	self bringBendpointHandlesToFront.
	self bringResizeHandlesToFront.
	self updateDiagramAppearance
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
CPProcessVisualElement >> visualContainingDiagramElement: aDiagramElement [
	(diagramElements notNil and: [ diagramElements identityIncludes: aDiagramElement ])
		ifTrue: [ ^ self ].
	shapeElementsByModelElement valuesDo: [ :aShapeElement |
		aShapeElement nestedProcessVisual ifNotNil: [ :aNestedVisual |
			(aNestedVisual visualContainingDiagramElement: aDiagramElement)
				ifNotNil: [ :anOwner | ^ anOwner ] ] ].
	^ nil
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

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedBoundsOf: aShape [
	^ diagramContext boundsOf: aShape
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedModelElementOf: aShape [
	^ diagramContext modelElementOf: aShape
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedWaypointsOf: anEdge [
	^ diagramContext waypointsOf: anEdge
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedLabelSegmentIndexOf: anEdge [
	^ diagramContext labelSegmentIndexOf: anEdge
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedLabelSegmentPositionOf: anEdge [
	^ diagramContext labelSegmentPositionOf: anEdge
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedLabelOffsetOf: anEdge [
	^ diagramContext labelOffsetOf: anEdge
]


{ #category : 'private - shapes' }
CPProcessVisualElement >> addShapeFor: aShape [
	| bounds modelElement element |
	bounds := self stagedBoundsOf: aShape.
	bounds ifNil: [ ^ self ].
	modelElement := self stagedModelElementOf: aShape.
	modelElement ifNil: [ ^ self ].
	modelElement isBoundaryEvent ifTrue: [
		bounds := self
			displayBoundsForBoundaryEvent: modelElement
			stagedBounds: bounds ].
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
		shapeElement: element.
	shapeElementsByShape at: aShape put: element.
	shapeElementsByModelElement at: modelElement put: element.
	self addDiagramChild: element.
	(modelElement isSubProcess and: [ self stagedExpandedOf: aShape ]) ifTrue: [
		self
			installNestedProcessVisualIn: element
			for: modelElement.
		self
			installExpandedSubProcessBorderInteractionOn: element
			for: modelElement
			shape: aShape ].
	self addExternalLabelFor: modelElement bounds: bounds shape: aShape shapeElement: element.
	modelElement isBoundaryEvent ifTrue: [
		self addBoundaryEventHoverLabelFor: modelElement bounds: bounds shapeElement: element ].
	self updateDiagramAppearance
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
	aFlowNode isBoundaryEvent ifTrue: [ ^ self ].
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
	| replacement proposedBounds operation assessment |
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	replacement := aFlowNodeClass new.
	proposedBounds := self stagedBoundsOf: aShape.

	operation := diagramEditing
		replaceShape: aShape
		with: replacement
		bounds: proposedBounds.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.

	assessment isApplicable ifTrue: [
		diagramSelection selectOnly: aShape.
		self refresh.
		self updateDiagramAppearance.
		selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: diagramSelection soleDiagramElement ] ].
	^ assessment
]

{ #category : 'private - dragging' }
CPProcessVisualElement >> newDragProxyFor: aFlowNode shape: aShape bounds: bounds [
	| proxy |
	proxy := self
		newShapeElementFor: aFlowNode
		shape: aShape
		bounds: bounds.
	proxy
		preventMeAndChildrenMouseEvents;
		bringResizeHandlesToFront.
	^ proxy
]

{ #category : 'private - dragging' }
CPProcessVisualElement >> newDragProxyLabelFor: aFlowNode bounds: bounds [
	| labelHost label labelWidth |
	(aFlowNode isEvent or: [ aFlowNode isGateway ]) ifFalse: [ ^ nil ].
	labelWidth := 180.
	labelHost := BlElement new
		clipChildren: false;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal exact: labelWidth.
			c vertical fitContent ];
		yourself.
	label := self newEditableLabelFor: aFlowNode.
	label
		hFitContentLimited;
		vFitContent;
		constraintsDo: [ :c |
			c maxWidth: labelWidth.
			c frame horizontal alignCenter.
			c frame vertical alignCenter ].
	labelHost
		addChild: label;
		preventMeAndChildrenMouseEvents.
	^ labelHost
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
	aFlowNode isBoundaryEvent ifTrue: [
		element boundaryInterrupting: (self stagedCancelActivityOf: aFlowNode) ].
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
	self addDiagramChild: labelHost.
	self installLabelEditingOn: labelHost label: label.
	self installEdgeSelectionOn: labelHost for: anEdge.
	self installEdgeLabelPositioningOn: labelHost for: anEdge.
	self positionEdgeLabelFor: anEdge
]

{ #category : 'private - labels' }
CPProcessVisualElement >> installEdgeLabelPositioningOn: aLabelHost for: anEdge [
	| isDragging lastPlacement |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
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
						nearestPlacementTo: (self diagramPointForGlobalPoint: anEvent position).
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
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	assessment := (diagramEditing
		setLabelSegmentIndex: aSegmentIndex
		segmentPosition: aSegmentPosition
		offset: anOffset
		forEdge: anEdge) apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateDiagramAppearance ].
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
			sourceBounds := sourceElement bounds inParent: self diagramPresentationParent.
			targetBounds := targetElement bounds inParent: self diagramPresentationParent ]
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
	aFlowNode isBoundaryEvent ifTrue: [ ^ self ].
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
	self addDiagramChild: labelHost.
	self installLabelEditingOn: labelHost label: label.
	self installSelectionOn: labelHost for: aFlowNode.
	aFlowNode isBoundaryEvent
		ifTrue: [ self installBoundaryEventPositioningFrom: labelHost moving: aShapeElement for: aShape ]
		ifFalse: [ self installPositioningFrom: labelHost moving: aShapeElement for: aShape ]
]

{ #category : 'private - labels' }
CPProcessVisualElement >> addBoundaryEventHoverLabelFor: aBoundaryEvent bounds: eventBounds shapeElement: aShapeElement [
	| attachedActivity attachedShape activityBounds labelHost label labelExtent |
	attachedActivity := self stagedAttachedActivityOf: aBoundaryEvent.
	attachedActivity ifNil: [ ^ self ].
	attachedShape := self diagramShapeForModelElement: attachedActivity.
	attachedShape ifNil: [ ^ self ].
	activityBounds := self stagedBoundsOf: attachedShape.
	activityBounds ifNil: [ ^ self ].
	labelExtent := 180 @ 44.
	labelHost := BlElement new
		extent: labelExtent;
		clipChildren: false;
		layout: BlFrameLayout new;
		visibility: BlVisibility hidden;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: (self
			boundaryEventHoverLabelOriginForEventBounds: eventBounds
			activityBounds: activityBounds
			labelExtent: labelExtent);
		yourself.
	label := self newEditableLabelFor: aBoundaryEvent.
	label
		hFitContentLimited;
		vFitContent;
		constraintsDo: [ :c |
			c maxWidth: labelExtent x.
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		preventMeAndChildrenMouseEvents.
	labelHost
		addChild: label;
		preventMeAndChildrenMouseEvents.
	aShapeElement externalLabelHost: labelHost.
	self addDiagramChild: labelHost.
	aShapeElement
		addEventHandler: (BlEventHandler
			on: BlMouseEnterEvent
			do: [ :anEvent | labelHost visibility: BlVisibility visible ]);
		addEventHandler: (BlEventHandler
			on: BlMouseLeaveEvent
			do: [ :anEvent | labelHost visibility: BlVisibility hidden ])
]

{ #category : 'private - labels' }
CPProcessVisualElement >> boundaryEventHoverLabelOriginForEventBounds: eventBounds activityBounds: activityBounds labelExtent: labelExtent [
	| center gap distanceTop distanceBottom distanceLeft distanceRight minimumDistance |
	center := eventBounds center.
	gap := 6.
	distanceTop := (center y - activityBounds top) abs.
	distanceBottom := (center y - activityBounds bottom) abs.
	distanceLeft := (center x - activityBounds left) abs.
	distanceRight := (center x - activityBounds right) abs.
	minimumDistance := { distanceTop. distanceBottom. distanceLeft. distanceRight } min.
	minimumDistance = distanceTop ifTrue: [
		^ (center x - (labelExtent x / 2)) @ (activityBounds top - gap - labelExtent y) ].
	minimumDistance = distanceBottom ifTrue: [
		^ (center x - (labelExtent x / 2)) @ (activityBounds bottom + gap) ].
	minimumDistance = distanceLeft ifTrue: [
		^ (activityBounds left - gap - labelExtent x) @ (center y - (labelExtent y / 2)) ].
	^ (activityBounds right + gap) @ (center y - (labelExtent y / 2))
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
		addTo: self diagramPresentationParent.
	edgeVisualsByEdge at: anEdge put: edgeVisual
]

{ #category : 'private - layout' }
CPProcessVisualElement >> bringNodeInteractionSurfacesToFront [
	shapeElementsByShape valuesDo: [ :anElement |
		anElement removeFromParent.
		self addDiagramChild: anElement ].
	shapeElementsByModelElement valuesDo: [ :aShapeElement |
		aShapeElement bringExternalLabelToFrontIn: self diagramPresentationParent ].
	edgeVisualsByEdge valuesDo: [ :anEdgeVisual |
		anEdgeVisual bringLabelToFrontIn: self diagramPresentationParent ]
]

{ #category : 'private - layout' }
CPProcessVisualElement >> bringReconnectHandlesToFront [
	edgeVisualsByEdge valuesDo: [ :anEdgeVisual |
		anEdgeVisual bringReconnectHandlesToFrontIn: self diagramPresentationParent ]
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
	self addDiagramChild: sourceReference.
	self addDiagramChild: targetReference.

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
			addTo: self diagramPresentationParent ].
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
	^ (self stagedSourceOf: sequenceFlow) == aModelElement
		or: [ (self stagedTargetOf: sequenceFlow) == aModelElement ]
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
	(self diagramElementForModelElement: aModelElement)
		ifNotNil: [ :aDiagramElement | self selectOnlyDiagramElement: aDiagramElement ]
]


{ #category : 'private - selection' }
CPProcessVisualElement >> toggleSelectionOf: aModelElement [
	(self diagramElementForModelElement: aModelElement)
		ifNotNil: [ :aDiagramElement | self toggleSelectionOfDiagramElement: aDiagramElement ]
]


{ #category : 'selection' }
CPProcessVisualElement >> selectedModelElements [
	^ diagramSelection diagramElements collect: [ :each |
		self stagedModelElementOf: each ]
]


{ #category : 'selection' }
CPProcessVisualElement >> selectedModelElement [
	^ diagramSelection soleDiagramElement
		ifNil: [ nil ]
		ifNotNil: [ :each | self stagedModelElementOf: each ]
]


{ #category : 'configuration' }
CPProcessVisualElement >> diagramElementsRemovedDo: aBlock [
	diagramElementsRemovedBlock := aBlock
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
	shapeElementsByShape keysAndValuesDo: [ :aShape :anElement |
		anElement
			selected: (diagramSelection includes: aShape)
			selectionColor: self selectionColor
			normalColor: self shapeBorderColor ].
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		anEdgeVisual
			selected: (diagramSelection includes: anEdge)
			insertionTarget: false
			selectionColor: self selectionColor
			normalColor: self shapeBorderColor ].
	self updateReconnectHandlePositions.
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		anEdgeVisual reconnectHandlesVisible:
			(anEdge == diagramSelection soleDiagramElement) ].
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		anEdgeVisual bendpointHandlesVisible:
			(anEdge == diagramSelection soleDiagramElement) ]
]


{ #category : 'private - interaction' }
CPProcessVisualElement >> updateTransientInteractionAppearance [
	shapeElementsByModelElement keysAndValuesDo: [ :aModelElement :anElement |
		| isEmphasized |
		isEmphasized := (diagramSelection includes: anElement diagramShape)
			or: [ aModelElement == connectionSourceModelElement
			or: [ aModelElement == connectionTargetModelElement
			or: [ aModelElement == boundaryEventPaletteTargetModelElement ] ] ].
		anElement
			selected: isEmphasized
			selectionColor: self selectionColor
			normalColor: self shapeBorderColor ].
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		anEdgeVisual
			selected: (diagramSelection includes: anEdge)
			insertionTarget: anEdge == insertionTargetEdge
			selectionColor: self selectionColor
			normalColor: self shapeBorderColor ]
]


{ #category : 'private - interaction' }
CPProcessVisualElement >> updateDiagramAppearance [
	self updateSelectionAppearance.
	self updateTransientInteractionAppearance.
	self updateConnectionPortVisibility
]

{ #category : 'operations' }
CPProcessVisualElement >> resizeShape: aShape toBounds: aRectangle [
	| assessment operation |
	operation := diagramEditing resizeShape: aShape toBounds: aRectangle.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable ifFalse: [ self refresh ].
	^ assessment
]

{ #category : 'private - resizing' }
CPProcessVisualElement >> installResizeHandleFor: aShape modelElement: aModelElement shapeElement: aShapeElement [
	| handles |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	aModelElement isActivity ifFalse: [ ^ self ].
	handles := aShapeElement
		installResizeHandleMinimumExtent: (self extentForModelElement: aModelElement)
		stagedBounds: [ self stagedBoundsOf: aShape ]
		resize: [ :proposedBounds | self resizeShape: aShape toBounds: proposedBounds ]
		geometryChanged: [ :proposedBounds |
			self
				updateAttachedBoundaryEventGeometryForActivity: aModelElement
				proposedBounds: proposedBounds.
			self updateIncidentEdgeLabelsFor: aModelElement.
			self updateIncidentReconnectHandlesFor: aModelElement ].
	handles do: [ :aHandle | aShapeElement addChild: aHandle ]
]

{ #category : 'private - resizing' }
CPProcessVisualElement >> updateAttachedBoundaryEventGeometryForActivity: anActivity proposedBounds: proposedActivityBounds [
	| flowContext currentActivityBounds |
	flowContext := CPProcessFlowContainerContext
		containingFlowElement: anActivity
		inRootMemento: memento.
	flowContext ifNil: [ ^ self ].
	currentActivityBounds := self stagedBoundsOf: (self diagramShapeForModelElement: anActivity).
	(flowContext attachedBoundaryEventsFor: anActivity) do: [ :aBoundaryEvent |
		| boundaryShape boundaryElement currentBoundaryBounds proposedBoundaryBounds |
		boundaryShape := self diagramShapeForModelElement: aBoundaryEvent.
		boundaryShape ifNotNil: [
			boundaryElement := shapeElementsByShape at: boundaryShape ifAbsent: [ nil ].
			boundaryElement ifNotNil: [
				currentBoundaryBounds := self
					displayBoundsForBoundaryEvent: aBoundaryEvent
					stagedBounds: (self stagedBoundsOf: boundaryShape).
				proposedBoundaryBounds := self
					boundaryEventBounds: currentBoundaryBounds
					fromActivityBounds: currentActivityBounds
					toActivityBounds: proposedActivityBounds.
				boundaryElement externalLabelHost ifNotNil: [ :aLabel |
					aLabel relocate: (self
						boundaryEventHoverLabelOriginForEventBounds: proposedBoundaryBounds
						activityBounds: proposedActivityBounds
						labelExtent: aLabel extent) ].
				boundaryElement relocate: proposedBoundaryBounds origin.
				self updateIncidentEdgeLabelsFor: aBoundaryEvent.
				self updateIncidentReconnectHandlesFor: aBoundaryEvent ] ] ]
]

{ #category : 'private - geometry' }
CPProcessVisualElement >> boundaryEventBounds: eventBounds fromActivityBounds: currentActivityBounds toActivityBounds: proposedActivityBounds [
	| center leftDistance rightDistance topDistance bottomDistance minimum verticalSide ratio proposedCenter |
	center := eventBounds center.
	leftDistance := (center x - currentActivityBounds left) abs.
	rightDistance := (center x - currentActivityBounds right) abs.
	topDistance := (center y - currentActivityBounds top) abs.
	bottomDistance := (center y - currentActivityBounds bottom) abs.
	minimum := { leftDistance. rightDistance. topDistance. bottomDistance } min.
	verticalSide := leftDistance = minimum or: [ rightDistance = minimum ].
	verticalSide
		ifTrue: [
			ratio := currentActivityBounds height isZero
				ifTrue: [ 0.5 ]
				ifFalse: [ (center y - currentActivityBounds top) / currentActivityBounds height ].
			ratio := (ratio max: 0) min: 1.
			proposedCenter := ((leftDistance = minimum)
				ifTrue: [ proposedActivityBounds left ]
				ifFalse: [ proposedActivityBounds right ])
				@ (proposedActivityBounds top + (proposedActivityBounds height * ratio)) ]
		ifFalse: [
			ratio := currentActivityBounds width isZero
				ifTrue: [ 0.5 ]
				ifFalse: [ (center x - currentActivityBounds left) / currentActivityBounds width ].
			ratio := (ratio max: 0) min: 1.
			proposedCenter := (proposedActivityBounds left + (proposedActivityBounds width * ratio))
				@ ((topDistance = minimum)
					ifTrue: [ proposedActivityBounds top ]
					ifFalse: [ proposedActivityBounds bottom ]) ].
	^ (proposedCenter - (eventBounds extent / 2)) extent: eventBounds extent
]

{ #category : 'private - layout' }
CPProcessVisualElement >> bringResizeHandlesToFront [
	shapeElementsByShape valuesDo: [ :aShapeElement |
		aShapeElement bringResizeHandlesToFront ]
]

{ #category : 'operations' }
CPProcessVisualElement >> moveShape: aShape toBounds: aRectangle [
	| assessment modelElement constrainedBounds boundsByShape |
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	modelElement := self stagedModelElementOf: aShape.
	constrainedBounds := modelElement
		ifNil: [ aRectangle ]
		ifNotNil: [ self constrainedBounds: aRectangle forFlowElement: modelElement ].
	boundsByShape := IdentityDictionary new
		at: aShape put: constrainedBounds;
		yourself.
	assessment := (diagramEditing
		moveShapes: boundsByShape
		toProcessHostedBy: hostShape
		waypointsByEdge: IdentityDictionary new) apply.
	assessment isApplicable ifFalse: [ self refresh ].
	^ assessment
]

{ #category : 'operations' }
CPProcessVisualElement >> moveShapesToBounds: boundsByShape [
	| assessment |
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	assessment := (diagramEditing
		moveShapes: boundsByShape
		toProcessHostedBy: hostShape
		waypointsByEdge: IdentityDictionary new) apply.
	self refresh.
	^ assessment
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> insertionTargetEdge: anEdge [
	insertionTargetEdge == anEdge ifTrue: [ ^ self ].
	insertionTargetEdge := anEdge.
	self updateDiagramAppearance
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> clearInsertionTarget [
	self insertionTargetEdge: nil
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> insertionEdgeAtGlobalPoint: aGlobalPoint for: aFlowNode [
	| candidates localPoint |
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	candidates := OrderedCollection new.
	edgeVisualsByEdge keysAndValuesDo: [ :anEdge :anEdgeVisual |
		((self stagedSourceOf: anEdge modelElement) == aFlowNode
			or: [ (self stagedTargetOf: anEdge modelElement) == aFlowNode ])
			ifFalse: [
				(anEdgeVisual containsGlobalPoint: aGlobalPoint)
					ifTrue: [ candidates add: anEdge ] ] ].
	candidates ifEmpty: [ ^ nil ].
	candidates size = 1 ifTrue: [ ^ candidates first ].

	localPoint := self diagramPointForGlobalPoint: aGlobalPoint.
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
	| operation assessment constrainedBounds |
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	constrainedBounds := self constrainedBounds: proposedBounds forFlowContainer: flowContainer.
	operation := diagramEditing
		insertFlowNode: aFlowNode
		intoEdge: anEdge
		bounds: constrainedBounds.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable
		ifTrue: [
			diagramSelection selectOnly: aShape.
			self refresh.
			self updateDiagramAppearance.
			selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: aShape ] ]
		ifFalse: [
			self moveShape: aShape toBounds: proposedBounds ].
	^ assessment
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> installPositioningOn: anElement for: aShape [
	| modelElement |
	modelElement := self stagedModelElementOf: aShape.
	(modelElement notNil and: [ modelElement isBoundaryEvent ]) ifTrue: [
		^ self installBoundaryEventPositioningFrom: anElement moving: anElement for: aShape ].
	self installPositioningFrom: anElement moving: anElement for: aShape
]














{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedAttachedActivityOf: aBoundaryEvent [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aBoundaryEvent
		inRootMemento: memento.
	^ context ifNotNil: [ context stagedAttachedToOf: aBoundaryEvent ]
]

{ #category : 'private - geometry' }
CPProcessVisualElement >> displayBoundsForBoundaryEvent: aBoundaryEvent stagedBounds: stagedBounds [
	| attachedActivity attachedActivityShape attachedActivityElement activityBounds center extent |
	extent := self extentForModelElement: aBoundaryEvent.
	center := stagedBounds center.
	attachedActivity := self stagedAttachedActivityOf: aBoundaryEvent.
	attachedActivity ifNil: [ ^ (center - (extent / 2)) extent: extent ].
	attachedActivityShape := self diagramShapeForModelElement: attachedActivity.
	attachedActivityShape ifNil: [ ^ (center - (extent / 2)) extent: extent ].
	attachedActivityElement := shapeElementsByModelElement
		at: attachedActivity
		ifAbsent: [ nil ].
	activityBounds := attachedActivityElement
		ifNil: [ self stagedBoundsOf: attachedActivityShape ]
		ifNotNil: [ attachedActivityElement position extent: attachedActivityElement extent ].
	center := self nearestPointOnBoundaryOf: activityBounds to: center.
	^ (center - (extent / 2)) extent: extent
]

{ #category : 'private - geometry' }
CPProcessVisualElement >> boundaryEventBounds: eventBounds constrainedToActivityBounds: activityBounds nearCenter: aPoint [
	| center |
	center := self nearestPointOnBoundaryOf: activityBounds to: aPoint.
	^ (center - (eventBounds extent / 2)) extent: eventBounds extent
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> installBoundaryEventPositioningFrom: anInteractionElement moving: aShapeElement for: aShape [
	| boundaryEvent attachedActivity attachedActivityShape dragStartBounds dragStartLabelPosition snappedBounds candidateActivityShape |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	boundaryEvent := self stagedModelElementOf: aShape.
	attachedActivity := self stagedAttachedActivityOf: boundaryEvent.
	attachedActivity ifNil: [ ^ self ].
	attachedActivityShape := self diagramShapeForModelElement: attachedActivity.
	attachedActivityShape ifNil: [ ^ self ].
	snappedBounds := self
		displayBoundsForBoundaryEvent: boundaryEvent
		stagedBounds: (self stagedBoundsOf: aShape).
	candidateActivityShape := attachedActivityShape.
	aShapeElement
		installPositioningFrom: anInteractionElement
		stagedBounds: [ self
			displayBoundsForBoundaryEvent: boundaryEvent
			stagedBounds: (self stagedBoundsOf: aShape) ]
		dragStarted: [ :anEvent :originalBounds |
			dragStartBounds := originalBounds.
			dragStartLabelPosition := aShapeElement externalLabelHost
				ifNotNil: [ :aLabel | aLabel position ].
			candidateActivityShape := attachedActivityShape.
			self clearInsertionTarget ]
		dragStartPosition: [ dragStartBounds origin ]
		dragged: [ :anEvent :delta |
			| candidateBounds targetActivityShape targetActivityBounds |
			candidateBounds := dragStartBounds translateBy: delta.
			targetActivityShape := self activityShapeAtDiagramPoint:
				(self diagramPointForGlobalPoint: anEvent position).
			targetActivityShape ifNil: [ targetActivityShape := attachedActivityShape ].
			candidateActivityShape := targetActivityShape.
			targetActivityBounds := self stagedBoundsOf: targetActivityShape.
			snappedBounds := self
				boundaryEventBounds: dragStartBounds
				constrainedToActivityBounds: targetActivityBounds
				nearCenter: candidateBounds center.
			aShapeElement relocate: snappedBounds origin.
			dragStartLabelPosition ifNotNil: [
				aShapeElement externalLabelHost relocate: (self
					boundaryEventHoverLabelOriginForEventBounds: snappedBounds
					activityBounds: targetActivityBounds
					labelExtent: aShapeElement externalLabelHost extent) ].
			self updateIncidentEdgeLabelsFor: boundaryEvent.
			self updateIncidentReconnectHandlesFor: boundaryEvent ]
		dragEnded: [ :anEvent :proposedBounds :delta |
			| operation assessment |
			candidateActivityShape ifNil: [ candidateActivityShape := attachedActivityShape ].
			candidateActivityShape == attachedActivityShape
				ifTrue: [
					| boundsByShape |
					boundsByShape := IdentityDictionary new
						at: aShape put: snappedBounds;
						yourself.
					operation := diagramEditing
						moveShapes: boundsByShape
						toProcessHostedBy: hostShape
						waypointsByEdge: IdentityDictionary new ]
				ifFalse: [
					operation := diagramEditing
						reattachBoundaryEvent: aShape
						toActivityShape: candidateActivityShape
						bounds: snappedBounds ].
			operation
				ifNil: [ self refresh ]
				ifNotNil: [
					assessment := operation apply.
					self refresh ] ]
]

{ #category : 'private - positioning' }
CPProcessVisualElement >> selectedShapeEntriesForGroupDragIncluding: draggedModelElement [
	| entries draggedShape |
	draggedShape := self diagramShapeForModelElement: draggedModelElement.
	(draggedShape notNil and: [ diagramSelection includes: draggedShape ]) ifFalse: [ ^ #() ].
	entries := OrderedCollection new.
	shapeElementsByShape keysAndValuesDo: [ :aShape :anElement |
		| modelElement |
		modelElement := self stagedModelElementOf: aShape.
		(diagramSelection includes: aShape) ifTrue: [
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
CPProcessVisualElement >> internalEdgesForMovedModelElements: movedModelElements [
	^ edgeVisualsByEdge keys select: [ :anEdge |
		| sequenceFlow |
		sequenceFlow := anEdge modelElement.
		(movedModelElements includes: (self stagedSourceOf: sequenceFlow))
			and: [ movedModelElements includes: (self stagedTargetOf: sequenceFlow) ] ]
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
	references do: [ :each | self addDiagramChild: each ].

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
		self addDiagramChild: line ].
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
	| dragStartLabelPosition draggedModelElement groupEntries groupMode groupPreviews internalBentEdges movedModelElements dragPresentations dragSourcePosition |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	groupMode := false.
	groupEntries := #().
	groupPreviews := IdentityDictionary new.
	internalBentEdges := #().
	movedModelElements := IdentitySet new.
	dragPresentations := IdentityDictionary new.
	dragSourcePosition := nil.
	aShapeElement
		installPositioningFrom: anInteractionElement
		stagedBounds: [ self stagedBoundsOf: aShape ]
		dragStarted: [ :anEvent :originalBounds |
			| elementsToPresent singleLabelPosition |
			self clearInsertionTarget.
			draggedModelElement := self stagedModelElementOf: aShape.
			groupEntries := self selectedShapeEntriesForGroupDragIncluding: draggedModelElement.
			groupMode := groupEntries size > 1.
			movedModelElements := IdentitySet new.
			groupMode
				ifTrue: [
					groupEntries do: [ :entry | movedModelElements add: entry second ] ]
				ifFalse: [
					movedModelElements add: draggedModelElement ].
			singleLabelPosition := aShapeElement externalLabelHost
				ifNotNil: [ :aLabel | aLabel position ].
			elementsToPresent := groupMode
				ifTrue: [ groupEntries collect: [ :entry | entry third ] ]
				ifFalse: [ { aShapeElement } ].
			dragPresentations := IdentityDictionary new.
			elementsToPresent do: [ :anElement |
				| entry modelElement shape bounds localLabelPosition rootShapePosition rootLabelPosition proxy proxyLabel presentation |
				groupMode
					ifTrue: [
						entry := groupEntries detect: [ :each | each third == anElement ].
						shape := entry first.
						modelElement := entry second.
						bounds := entry fourth.
						localLabelPosition := entry sixth ]
					ifFalse: [
						shape := aShape.
						modelElement := draggedModelElement.
						bounds := originalBounds.
						localLabelPosition := singleLabelPosition ].
				rootShapePosition := self rootDiagramPointForLocalPoint: bounds origin.
				rootLabelPosition := localLabelPosition ifNotNil: [
					self rootDiagramPointForLocalPoint: localLabelPosition ].
				proxy := self newDragProxyFor: modelElement shape: shape bounds: bounds.
				proxyLabel := self newDragProxyLabelFor: modelElement bounds: bounds.
				presentation := (CPProcessDragPresentation
					sourceElement: anElement
					proxyElement: proxy
					proxyLabel: proxyLabel)
						beginIn: rootVisual
						shapeAt: rootShapePosition
						labelAt: rootLabelPosition.
				dragPresentations at: anElement put: presentation ].
			dragSourcePosition := originalBounds origin.
			dragStartLabelPosition := singleLabelPosition.
			groupMode ifTrue: [
				internalBentEdges := self internalBentEdgesForMovedModelElements: movedModelElements.
				internalBentEdges do: [ :anEdge |
					(self lineElementsForEdge: anEdge)
						do: [ :aLine | aLine visibility: BlVisibility hidden ] ] ] ]
		dragStartPosition: [ dragSourcePosition ]
		dragged: [ :anEvent :delta |
			dragPresentations valuesDo: [ :aPresentation |
				aPresentation moveBy: delta ].
			groupMode
				ifTrue: [
					groupEntries do: [ :entry |
						| element bounds label |
						element := entry third.
						bounds := entry fourth.
						label := entry fifth.
						element relocate: bounds origin + delta.
						label ifNotNil: [ label relocate: entry sixth + delta ] ].
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
					self bringBendpointHandlesToFront ]
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
			dragPresentations valuesDo: [ :aPresentation |
				aPresentation finish ].
			groupMode
				ifTrue: [
					| rootPoint targetVisual |
					self removeGroupMovePreviews: groupPreviews.
					groupPreviews := IdentityDictionary new.
					internalBentEdges do: [ :anEdge |
						(self lineElementsForEdge: anEdge)
							do: [ :aLine | aLine visibility: BlVisibility visible ] ].
					rootPoint := self rootDiagramPointForLocalPoint: proposedBounds center.
					targetVisual := rootVisual
						processVisualAtRootDiagramPoint: rootPoint
						excluding: draggedModelElement.
					self
						moveGroupEntries: groupEntries
						movedModelElements: movedModelElements
						delta: delta
						to: targetVisual ]
				ifFalse: [
					| insertionEdge |
					insertionEdge := self
						insertionEdgeAtGlobalPoint: anEvent position
						for: draggedModelElement.
					self clearInsertionTarget.
					insertionEdge
						ifNil: [
							| targetVisual targetBounds constrainedBounds rootPoint boundsByShape assessment |
							rootPoint := self rootDiagramPointForLocalPoint: proposedBounds center.
							targetVisual := rootVisual
								processVisualAtRootDiagramPoint: rootPoint
								excluding: draggedModelElement.
							targetBounds := targetVisual
								boundsCenteredAtRootDiagramPoint: rootPoint
								extent: proposedBounds extent.
							constrainedBounds := targetVisual
								constrainedBounds: targetBounds
								forFlowContainer: targetVisual flowContainer.
							boundsByShape := IdentityDictionary new
								at: aShape put: constrainedBounds;
								yourself.
							assessment := (diagramEditing
								moveShapes: boundsByShape
								toProcessHostedBy: targetVisual hostShape
								waypointsByEdge: IdentityDictionary new) apply.
							targetVisual == self
								ifTrue: [ assessment isApplicable ifFalse: [ self refresh ] ]
								ifFalse: [ self refreshEditor ] ]
						ifNotNil: [
							self
								insertExistingFlowNode: draggedModelElement
								shape: aShape
								intoEdge: insertionEdge
								atBounds: proposedBounds ] ] ]
]
{ #category : 'private - containment' }
CPProcessVisualElement >> moveGroupEntries: groupEntries movedModelElements: movedModelElements delta: delta to: targetVisual [
	| boundsByShape waypointsByEdge internalEdges assessment |
	boundsByShape := IdentityDictionary new.
	groupEntries do: [ :entry |
		| sourceBounds sourceCenter rootCenter targetCenter |
		sourceBounds := entry fourth translateBy: delta.
		sourceCenter := sourceBounds center.
		rootCenter := self rootDiagramPointForLocalPoint: sourceCenter.
		targetCenter := targetVisual localPointForRootDiagramPoint: rootCenter.
		boundsByShape
			at: entry first
			put: (targetCenter - (sourceBounds extent / 2) extent: sourceBounds extent) ].

	internalEdges := self internalEdgesForMovedModelElements: movedModelElements.
	waypointsByEdge := IdentityDictionary new.
	internalEdges do: [ :anEdge |
		| proposed |
		proposed := (self translatedWaypointsOf: anEdge by: delta)
			collect: [ :aPoint |
				targetVisual localPointForRootDiagramPoint:
					(self rootDiagramPointForLocalPoint: aPoint) ].
		waypointsByEdge at: anEdge put: proposed asOrderedCollection ].

	assessment := (diagramEditing
		moveShapes: boundsByShape
		toProcessHostedBy: targetVisual hostShape
		waypointsByEdge: waypointsByEdge) apply.
	targetVisual == self
		ifTrue: [ self refresh ]
		ifFalse: [ self refreshEditor ].
	^ assessment
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
CPProcessVisualElement >> stagedCancelActivityOf: aBoundaryEvent [
	| eventMemento description |
	eventMemento := self flowElementMementoFor: aBoundaryEvent.
	eventMemento ifNil: [ ^ aBoundaryEvent cancelActivity ].
	description := eventMemento magritteDescription detect: [ :each | each handlesSelector: #cancelActivity ].
	^ eventMemento readUsing: description
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedSourceOf: aSequenceFlow [
	| context |
	context := self flowContainerContextContaining: aSequenceFlow.
	context ifNil: [
		self error: 'Sequence flow is not present in the staged Process/Sub-Process hierarchy.' ].
	^ context stagedSourceOf: aSequenceFlow
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> stagedTargetOf: aSequenceFlow [
	| context |
	context := self flowContainerContextContaining: aSequenceFlow.
	context ifNil: [
		self error: 'Sequence flow is not present in the staged Process/Sub-Process hierarchy.' ].
	^ context stagedTargetOf: aSequenceFlow
]

{ #category : 'configuration' }
CPProcessVisualElement >> collaborationChangedDo: aBlock [
	collaborationChangedBlock := aBlock
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> installPaletteInsertionOn: anEdgeElement for: anEdge [
	diagramEditing allowsEditing ifFalse: [ ^ self ].
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
	| sourceElement candidate proposedBounds operation assessment |
	diagramEditing allowsEditing ifFalse: [ ^ false ].
	sourceElement := aDragItem sourceElement.
	sourceElement ifNil: [ ^ false ].
	(sourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	candidate := aDragItem domainObject.
	candidate isParticipant ifTrue: [ ^ false ].
	proposedBounds := 0 @ 0 extent: (self extentForModelElement: candidate).
	operation := diagramEditing
		insertFlowNode: candidate
		intoEdge: anEdge
		bounds: proposedBounds.
	operation ifNil: [ ^ false ].
	assessment := operation assess.
	^ assessment isApplicable
]

{ #category : 'private - insertion' }
CPProcessVisualElement >> dropPaletteEvent: anEvent insertingInto: anEdge [
	| dragItem candidate elementExtent dropPoint origin bounds operation assessment |
	anEvent items size = 1 ifFalse: [ ^ self ].
	dragItem := anEvent items first.
	candidate := dragItem domainObject.
	elementExtent := self extentForModelElement: candidate.
	dropPoint := self diagramPointForGlobalPoint:
		(anEvent currentTarget localPointToGlobal: anEvent position).
	origin :=
		((dropPoint x - (elementExtent x / 2)) max: 0)
		@ ((dropPoint y - (elementExtent y / 2)) max: 0).
	bounds := origin extent: elementExtent.
	bounds := self
		constrainedBounds: bounds
		forFlowContainer: flowContainer.
	operation := diagramEditing
		insertFlowNode: candidate
		intoEdge: anEdge
		bounds: bounds.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable ifTrue: [
		self refresh.
		(self diagramShapeForModelElement: candidate) ifNotNil: [ :aShape |
			diagramSelection selectOnly: aShape ].
		self updateDiagramAppearance.
		selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: diagramSelection soleDiagramElement ] ].
	^ assessment
]

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
CPProcessVisualElement >> updateMarqueeSelectionFor: aRectangle baseSelection: someDiagramElements [
	| selectedDiagramElements |
	selectedDiagramElements := OrderedCollection withAll: someDiagramElements.

	shapeElementsByShape keysDo: [ :aShape |
		| bounds |
		bounds := self stagedBoundsOf: aShape.
		(bounds intersects: aRectangle)
			ifTrue: [
				(selectedDiagramElements identityIncludes: aShape) ifFalse: [
					selectedDiagramElements add: aShape ] ] ].

	edgeVisualsByEdge keysDo: [ :anEdge |
		(self edge: anEdge enclosedByRectangle: aRectangle)
			ifTrue: [
				(selectedDiagramElements identityIncludes: anEdge) ifFalse: [
					selectedDiagramElements add: anEdge ] ] ].

	diagramSelection replaceWith: selectedDiagramElements.
	self updateDiagramAppearance
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
CPProcessVisualElement >> edge: anEdge enclosedByRectangle: aRectangle [
	| points |
	points := self
		renderedPathPointsFor: anEdge
		waypoints: (self stagedWaypointsOf: anEdge)
		usingLiveBounds: false.
	^ points notEmpty and: [
		points allSatisfy: [ :aPoint |
			self rectangle: aRectangle containsPointIncludingBoundary: aPoint ] ]
]


{ #category : 'private - selection' }
CPProcessVisualElement >> rectangle: aRectangle containsPointIncludingBoundary: aPoint [
	^ aRectangle left <= aPoint x
		and: [ aPoint x <= aRectangle right
		and: [ aRectangle top <= aPoint y
		and: [ aPoint y <= aRectangle bottom ] ] ]
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
CPProcessVisualElement >> isBoundaryEventPaletteDragItem: aDragItem [
	| candidate |
	candidate := aDragItem domainObject.
	candidate isParticipant ifTrue: [ ^ false ].
	^ candidate isBoundaryEvent
]

{ #category : 'private - creation' }
CPProcessVisualElement >> acceptsBoundaryEventPaletteDragItem: aDragItem attachedToShape: anActivityShape [
	| sourceElement candidate activityBounds extent proposedBounds operation assessment |
	sourceElement := aDragItem sourceElement.
	sourceElement ifNil: [ ^ false ].
	(sourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	candidate := aDragItem domainObject.
	candidate isBoundaryEvent ifFalse: [ ^ false ].
	activityBounds := self stagedBoundsOf: anActivityShape.
	extent := self extentForModelElement: candidate.
	proposedBounds := ((self nearestPointOnBoundaryOf: activityBounds to: activityBounds center) - (extent / 2)) extent: extent.
	operation := diagramEditing
		createBoundaryEvent: candidate
		attachedToShape: anActivityShape
		bounds: proposedBounds.
	operation ifNil: [ ^ false ].
	assessment := operation assess.
	^ assessment isApplicable
]

{ #category : 'private - interaction' }
CPProcessVisualElement >> boundaryEventPaletteTargetModelElement: aModelElement [
	boundaryEventPaletteTargetModelElement == aModelElement ifTrue: [ ^ self ].
	boundaryEventPaletteTargetModelElement := aModelElement.
	self updateDiagramAppearance
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
	| dropSurface isMarqueeDragging marqueeOrigin marqueeElement marqueeBaseSelection |
	isMarqueeDragging := false.
	marqueeOrigin := nil.
	marqueeElement := nil.
	marqueeBaseSelection := #().
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
				marqueeOrigin := self diagramPointForGlobalPoint: anEvent position.
				connectionSourceModelElement := nil.
				connectionTargetModelElement := nil.
				insertionTargetEdge := nil.
				marqueeBaseSelection := anEvent modifiers isShift
					ifTrue: [ diagramSelection diagramElements ]
					ifFalse: [ #() ].
				anEvent modifiers isShift ifFalse: [
					diagramSelection clear ].
				marqueeElement := self newSelectionMarqueeElement.
				marqueeElement
					relocate: marqueeOrigin;
					extent: 0 @ 0.
				self addDiagramChild: marqueeElement.
				self updateDiagramAppearance.
				self requestFocus.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isMarqueeDragging ifTrue: [
					| corner rectangle |
					corner := self diagramPointForGlobalPoint: anEvent position.
					rectangle := Rectangle encompassing: { marqueeOrigin. corner }.
					marqueeElement
						relocate: rectangle origin;
						extent: rectangle extent.
					self
						updateMarqueeSelectionFor: rectangle
						baseSelection: marqueeBaseSelection.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isMarqueeDragging ifTrue: [
					| corner rectangle |
					isMarqueeDragging := false.
					corner := self diagramPointForGlobalPoint: anEvent position.
					rectangle := Rectangle encompassing: { marqueeOrigin. corner }.
					self
						updateMarqueeSelectionFor: rectangle
						baseSelection: marqueeBaseSelection.
					marqueeElement ifNotNil: [ marqueeElement removeFromParent ].
					marqueeElement := nil.
					marqueeOrigin := nil.
					marqueeBaseSelection := #().
					selectionChangedBlock ifNotNil: [
						:aBlock | aBlock value: diagramSelection soleDiagramElement ].
					anEvent consumed: true ] ]);
		yourself.
	self addChildFirst: dropSurface
]


{ #category : 'private - creation' }
CPProcessVisualElement >> acceptsPaletteDragItem: aDragItem [
	| sourceElement candidate proposedBounds operation assessment |
	sourceElement := aDragItem sourceElement.
	sourceElement ifNil: [ ^ false ].
	(sourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	candidate := aDragItem domainObject.

	candidate isParticipant ifTrue: [
		parentProcessVisual ifNotNil: [ ^ false ].
		collaborationVisual ifNotNil: [ ^ false ].
		proposedBounds := self firstParticipantBoundsCenteredAt: 0 @ 0.
		operation := diagramEditing
			createParticipant: candidate
			bounds: proposedBounds.
		operation ifNil: [ ^ false ].
		assessment := operation assess.
		^ assessment isApplicable ].

	candidate isBoundaryEvent ifTrue: [
		^ shapeElementsByModelElement keys anySatisfy: [ :each | each isActivity ] ].

	proposedBounds := 0 @ 0 extent: (self extentForModelElement: candidate).
	operation := diagramEditing
		createFlowNode: candidate
		bounds: proposedBounds
		inProcessHostedBy: hostShape.
	operation ifNil: [ ^ false ].
	assessment := operation assess.
	^ assessment isApplicable
]
{ #category : 'private - creation' }
CPProcessVisualElement >> dropPaletteEvent: anEvent [
	| dragItem globalPoint rootPoint targetVisual |
	anEvent items size = 1 ifFalse: [ ^ self ].
	dragItem := anEvent items first.
	globalPoint := anEvent currentTarget
		localPointToGlobal: anEvent position.
	rootPoint := rootVisual diagramPointForGlobalPoint: globalPoint.
	targetVisual := rootVisual
		processVisualAtRootDiagramPoint: rootPoint
		excluding: nil.
	^ targetVisual
		createPaletteItem: dragItem
		atRootDiagramPoint: rootPoint
]

{ #category : 'private - creation' }
CPProcessVisualElement >> createPaletteItem: aDragItem atRootDiagramPoint: aRootPoint [
	| candidate elementExtent bounds operation assessment |
	candidate := aDragItem domainObject.
	candidate isParticipant ifTrue: [
		^ self createParticipantPaletteItem: candidate atRootDiagramPoint: aRootPoint ].
	candidate isBoundaryEvent ifTrue: [ ^ self createBoundaryEventPaletteItem: candidate atRootDiagramPoint: aRootPoint ].

	elementExtent := self extentForModelElement: candidate.
	bounds := self
		boundsCenteredAtRootDiagramPoint: aRootPoint
		extent: elementExtent.
	bounds := self constrainedBounds: bounds forFlowContainer: flowContainer.
	operation := diagramEditing
		createFlowNode: candidate
		bounds: bounds
		inProcessHostedBy: hostShape.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable ifTrue: [
		self refreshEditor.
		(rootVisual diagramElementForModelElementInTree: candidate) ifNotNil: [ :aShape |
			diagramSelection selectOnly: aShape ].
		rootVisual updateSelectionAppearanceRecursively.
		selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: diagramSelection soleDiagramElement ] ].
	^ assessment
]
{ #category : 'private - creation' }
CPProcessVisualElement >> createBoundaryEventPaletteItem: aBoundaryEvent atRootDiagramPoint: aRootPoint [
	| localPoint activityShape activityBounds extent boundaryBounds operation assessment |
	localPoint := self localPointForRootDiagramPoint: aRootPoint.
	activityShape := self activityShapeAtDiagramPoint: localPoint.
	activityShape ifNil: [ ^ nil ].
	activityBounds := self stagedBoundsOf: activityShape.
	extent := self extentForModelElement: aBoundaryEvent.
	boundaryBounds := ((self nearestPointOnBoundaryOf: activityBounds to: localPoint) - (extent / 2)) extent: extent.
	operation := diagramEditing
		createBoundaryEvent: aBoundaryEvent
		attachedToShape: activityShape
		bounds: boundaryBounds.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable ifTrue: [
		self refreshEditor.
		(rootVisual diagramElementForModelElementInTree: aBoundaryEvent) ifNotNil: [ :aShape |
			diagramSelection selectOnly: aShape ].
		rootVisual updateSelectionAppearanceRecursively.
		selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: diagramSelection soleDiagramElement ] ].
	^ assessment
]

{ #category : 'private - creation' }
CPProcessVisualElement >> activityShapeAtDiagramPoint: aPoint [
	| candidates |
	candidates := OrderedCollection new.
	shapeElementsByShape keysDo: [ :aShape |
		| modelElement bounds |
		modelElement := self stagedModelElementOf: aShape.
		(modelElement notNil and: [ modelElement isActivity ]) ifTrue: [
			bounds := self stagedBoundsOf: aShape.
			(bounds containsPoint: aPoint) ifTrue: [ candidates add: aShape ] ] ].
	candidates ifEmpty: [ ^ nil ].
	^ candidates detectMin: [ :aShape |
		| extent |
		extent := (self stagedBoundsOf: aShape) extent.
		extent x * extent y ]
]

{ #category : 'private - geometry' }
CPProcessVisualElement >> nearestPointOnBoundaryOf: aRectangle to: aPoint [
	| clampedX clampedY distances minimum |
	clampedX := (aPoint x max: aRectangle left) min: aRectangle right.
	clampedY := (aPoint y max: aRectangle top) min: aRectangle bottom.
	distances := {
		{ (aPoint x - aRectangle left) abs. aRectangle left @ clampedY }.
		{ (aPoint x - aRectangle right) abs. aRectangle right @ clampedY }.
		{ (aPoint y - aRectangle top) abs. clampedX @ aRectangle top }.
		{ (aPoint y - aRectangle bottom) abs. clampedX @ aRectangle bottom } }.
	minimum := distances detectMin: [ :each | each first ].
	^ minimum second
]

{ #category : 'private - creation' }
CPProcessVisualElement >> createParticipantPaletteItem: aParticipant atRootDiagramPoint: aRootPoint [
	| bounds operation assessment |
	bounds := self firstParticipantBoundsCenteredAt: aRootPoint.
	operation := diagramEditing
		createParticipant: aParticipant
		bounds: bounds.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable ifTrue: [
		collaborationChangedBlock ifNotNil: [ :aBlock | aBlock value ] ].
	^ assessment
]
{ #category : 'private - creation' }
CPProcessVisualElement >> firstParticipantBoundsCenteredAt: aRootPoint [
	| inset horizontalMargin extent origin |
	planeGeometry diagramExtent = (0 @ 0) ifTrue: [
		origin := (aRootPoint - (self defaultParticipantExtent / 2)) max: 0 @ 0.
		^ origin extent: self defaultParticipantExtent ].
	inset := self hostedDiagramInset.
	horizontalMargin := CPParticipantShapeElement processContentOriginOffset x + (inset x * 2).
	extent := planeGeometry diagramExtent + (horizontalMargin @ (inset y * 2)).

	"The Collaboration plane is a different BPMNPlane from the Process plane.
	The first Pool therefore derives its size from the Process graph, but never
	borrows the Process DI origin as a Collaboration coordinate. The camera
	positions the new Collaboration presentation; the hosted Process visual
	normalizes its own DI bounds inside the Pool."
	origin := 0 @ 0.
	^ origin extent: extent
]

{ #category : 'private - creation' }
CPProcessVisualElement >> defaultParticipantExtent [
	^ 620 @ 230
]
{ #category : 'private - replacement' }
CPProcessVisualElement >> installReplacementOnShape: aShapeElement for: aFlowNode shape: aShape [
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	aFlowNode isActivity
		ifTrue: [
			self
				installActivityPaletteDropOn: aShapeElement
				for: aFlowNode
				shape: aShape ]
		ifFalse: [
			aShapeElement
				installPaletteReplacementAccepting: [ :aDragItem |
					self acceptsPaletteDragItem: aDragItem replacing: aFlowNode shape: aShape ]
				dropped: [ :anEvent |
					self dropPaletteEvent: anEvent replacing: aFlowNode shape: aShape ] ]
]

{ #category : 'private - creation' }
CPProcessVisualElement >> installActivityPaletteDropOn: anActivityElement for: anActivity shape: anActivityShape [
	anActivityElement addEventHandler: (CPProcessPaletteDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea |
			(self isBoundaryEventPaletteDragItem: aDragItem)
				ifTrue: [
					self
						acceptsBoundaryEventPaletteDragItem: aDragItem
						attachedToShape: anActivityShape ]
				ifFalse: [
					self
						acceptsPaletteDragItem: aDragItem
						replacing: anActivity
						shape: anActivityShape ] ];
		whenDragEnteredDo: [ :anEvent |
			(anEvent mayAcceptItems and: [
				anEvent items size = 1 and: [
					self isBoundaryEventPaletteDragItem: anEvent items first ] ]) ifTrue: [
				self boundaryEventPaletteTargetModelElement: anActivity ] ];
		whenDragLeftDo: [ :anEvent |
			boundaryEventPaletteTargetModelElement == anActivity ifTrue: [
				self boundaryEventPaletteTargetModelElement: nil ] ];
		whenDroppedDo: [ :anEvent |
			boundaryEventPaletteTargetModelElement == anActivity ifTrue: [
				self boundaryEventPaletteTargetModelElement: nil ].
			anEvent items size = 1 ifTrue: [
				(self isBoundaryEventPaletteDragItem: anEvent items first)
					ifTrue: [ self dropPaletteEvent: anEvent ]
					ifFalse: [
						self
							dropPaletteEvent: anEvent
							replacing: anActivity
							shape: anActivityShape ] ] ];
		yourself)
]

{ #category : 'private - replacement' }
CPProcessVisualElement >> acceptsPaletteDragItem: aDragItem replacing: aFlowNode shape: aShape [
	| sourceElement candidate proposedBounds operation assessment |
	diagramEditing allowsEditing ifFalse: [ ^ false ].
	aFlowNode == self selectedModelElement ifFalse: [ ^ false ].
	sourceElement := aDragItem sourceElement.
	sourceElement ifNil: [ ^ false ].
	(sourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	candidate := aDragItem domainObject.
	candidate isParticipant ifTrue: [ ^ false ].
	candidate isBoundaryEvent ifTrue: [ ^ false ].
	candidate class = aFlowNode class ifTrue: [ ^ false ].
	proposedBounds := self replacementBoundsFor: candidate shape: aShape.
	operation := diagramEditing
		replaceShape: aShape
		with: candidate
		bounds: proposedBounds.
	operation ifNil: [ ^ false ].
	assessment := operation assess.
	^ assessment isApplicable
]

{ #category : 'private - replacement' }
CPProcessVisualElement >> dropPaletteEvent: anEvent replacing: aFlowNode shape: aShape [
	| dragItem candidate proposedBounds operation assessment |
	anEvent items size = 1 ifFalse: [ ^ self ].
	dragItem := anEvent items first.
	candidate := dragItem domainObject.
	proposedBounds := self replacementBoundsFor: candidate shape: aShape.
	operation := diagramEditing
		replaceShape: aShape
		with: candidate
		bounds: proposedBounds.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable ifTrue: [
		diagramSelection selectOnly: aShape.
		self refresh.
		self updateDiagramAppearance.
		selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: diagramSelection soleDiagramElement ] ].
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
	aFlowNode isBoundaryEvent ifTrue: [ ^ 32 @ 32 ].
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
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	(aFlowNode isEndEvent and: [ collaborationVisual isNil ]) ifTrue: [ ^ self ].
	aNodeElement
		installConnectionPortSelectionColor: self selectionColor
		borderColor: self shapeBorderColor
		beginConnection: [ self beginConnectionFrom: aFlowNode ]
		dragStarted: [ :anEvent |
			collaborationVisual
				ifNotNil: [
					collaborationVisual
						beginConnectionDragFrom: aFlowNode
						sourceVisual: self
						event: anEvent ]
				ifNil: [
					| localPoint |
					connectionSourceModelElement := aFlowNode.
					self clearConnectionTarget.
					localPoint := self diagramPointForGlobalPoint: anEvent position.
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
					self addDiagramChild: previewCursor.
					self addDiagramChildFirst: previewLine.
					self updateDiagramAppearance ] ]
		dragged: [ :anEvent |
			collaborationVisual
				ifNotNil: [
					collaborationVisual
						updateConnectionDragFrom: aFlowNode
						sourceVisual: self
						event: anEvent ]
				ifNil: [
					| target |
					previewCursor relocate: (self diagramPointForGlobalPoint: anEvent position).
					target := self
						validConnectionTargetAtGlobalPoint: anEvent position
						from: aFlowNode.
					self connectionTargetModelElement: target.
					self
						updateConnectionPreviewLine: previewLine
						cursor: previewCursor
						source: aFlowNode
						sourceElement: aNodeElement
						target: target ] ]
		dragEnded: [ :anEvent |
			collaborationVisual
				ifNotNil: [
					collaborationVisual
						endConnectionDragFrom: aFlowNode
						sourceVisual: self
						event: anEvent ]
				ifNil: [
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
						ifNil: [ self updateDiagramAppearance ] ] ]
]
{ #category : 'private - connection' }
CPProcessVisualElement >> isValidConnectionTarget: aTarget from: aSource [
	| sourceShape targetShape operation assessment |
	diagramEditing allowsEditing ifFalse: [ ^ false ].
	aSource == aTarget ifTrue: [ ^ false ].
	sourceShape := self diagramShapeForModelElement: aSource.
	targetShape := self diagramShapeForModelElement: aTarget.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [ ^ false ].
	operation := diagramEditing
		connectFrom: sourceShape
		to: targetShape
		waypoints: nil.
	operation ifNil: [ ^ false ].
	assessment := operation assess.
	^ assessment isApplicable
]

{ #category : 'collaboration connection' }
CPProcessVisualElement >> sequenceFlowTargetAtGlobalPoint: aPoint from: aSource [
	^ self
		validConnectionTargetAtGlobalPoint: aPoint
		from: aSource
]

{ #category : 'collaboration connection' }
CPProcessVisualElement >> messageFlowEndpointAtGlobalPoint: aPoint excluding: anEndpoint [
	| candidate |
	candidate := self connectionTargetAtGlobalPoint: aPoint excluding: anEndpoint.
	candidate ifNil: [ ^ nil ].
	^ candidate canBeMessageFlowEndpoint
		ifTrue: [ candidate ]
		ifFalse: [ nil ]
]


{ #category : 'collaboration connection' }
CPProcessVisualElement >> connectSequenceFlowFrom: aSource to: aTarget [
	^ self connectFrom: aSource to: aTarget
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
	self updateDiagramAppearance
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
	| sourceShape targetShape operation assessment |
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	sourceShape := self diagramShapeForModelElement: aSource.
	targetShape := self diagramShapeForModelElement: aTarget.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [ ^ nil ].
	operation := diagramEditing
		connectFrom: sourceShape
		to: targetShape
		waypoints: nil.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateDiagramAppearance ].
	^ assessment
]

{ #category : 'private - connection' }
CPProcessVisualElement >> updateConnectionPortVisibility [
	shapeElementsByModelElement keysAndValuesDo: [ :aFlowNode :aShapeElement |
		aShapeElement connectionPortVisible:
			(aFlowNode == hoveredModelElement
				or: [ aFlowNode == self selectedModelElement
				or: [ aFlowNode == connectionSourceModelElement ] ]) ]
]

{ #category : 'private - connection' }
CPProcessVisualElement >> beginConnectionFrom: aFlowNode [
	connectionSourceModelElement := aFlowNode.
	self clearConnectionTarget.
	self updateDiagramAppearance
]

{ #category : 'private - connection' }
CPProcessVisualElement >> completeConnectionTo: aFlowNode [
	| source |
	source := connectionSourceModelElement.
	connectionSourceModelElement := nil.
	self clearConnectionTarget.
	self updateConnectionPortVisibility.
	source ifNil: [ ^ self ].
	source == aFlowNode ifTrue: [ self updateDiagramAppearance. ^ self ].
	^ self connectFrom: source to: aFlowNode
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
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
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

	assessment := (diagramEditing setWaypoints: somePoints forEdge: anEdge) apply.
	assessment isApplicable
		ifTrue: [
			topologyChanges ifTrue: [
				segmentPlacement := (self
					edgeLabelPathFor: anEdge
					waypoints: somePoints
					usingLiveBounds: true)
					segmentPlacementAtFraction: pathFraction.
				offset := (self stagedLabelOffsetOf: anEdge) ifNil: [ -14.0 ].
				placementAssessment := (diagramEditing
					setLabelSegmentIndex: segmentPlacement first
					segmentPosition: segmentPlacement second
					offset: offset
					forEdge: anEdge) apply ].
			self refresh ]
		ifFalse: [ self updateDiagramAppearance ].
	^ assessment
]

{ #category : 'private - bendpoints' }
CPProcessVisualElement >> installBendpointInsertionOn: anEdgeElement for: anEdge segmentIndex: aSegmentIndex [
	| isDragging dragStartEventPosition insertedPoint previewLines labelPathFraction labelPath segmentIndex segmentPosition |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	isDragging := false.
	previewLines := #().

	anEdgeElement
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				isDragging := true.
				dragStartEventPosition := anEvent position.
				insertedPoint := self diagramPointForGlobalPoint: anEvent position.
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
					previewLines do: [ :aLine | self addDiagramChild: aLine ].
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
	diagramEditing allowsEditing ifFalse: [ ^ self ].
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
	handles do: [ :aHandle | self addDiagramChild: aHandle ]
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
			previewLines do: [ :aLine | self addDiagramChild: aLine ].
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
	self addDiagramChild: sourceReference.
	self addDiagramChild: targetReference.

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
		anEdgeVisual bringBendpointHandlesToFrontIn: self diagramPresentationParent ]
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> installReconnectHandlesFor: anEdge [
	| sequenceFlow source target lines sourceLine targetLine sourceHandle targetHandle |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	sequenceFlow := anEdge modelElement.
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	(shapeElementsByModelElement includesKey: source) ifFalse: [ ^ self ].
	(shapeElementsByModelElement includesKey: target) ifFalse: [ ^ self ].
	edgeVisualsByEdge at: anEdge ifAbsent: [ ^ self ].
	lines := self lineElementsForEdge: anEdge.
	lines ifEmpty: [ ^ self ].
	sourceLine := lines first.
	targetLine := lines last.

	sourceHandle := self
		newReconnectHandleFor: sequenceFlow
		movingSource: true.
	targetHandle := self
		newReconnectHandleFor: sequenceFlow
		movingSource: false.

	(edgeVisualsByEdge at: anEdge)
		reconnectHandles: { sourceHandle. targetHandle }.
	self addDiagramChild: sourceHandle.
	self addDiagramChild: targetHandle
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
	| candidate operation assessment |
	candidate := self
		connectionTargetAtGlobalPoint: aPoint
		excluding: nil.
	candidate ifNil: [ ^ nil ].
	diagramEditing allowsEditing ifFalse: [ ^ nil ].

	operation := self
		reconnectOperationFor: aSequenceFlow
		movingSource: movesSource
		candidate: candidate.
	operation ifNil: [ ^ nil ].
	assessment := operation assess.
	^ assessment isApplicable
		ifTrue: [ candidate ]
		ifFalse: [ nil ]
]

{ #category : 'private - reconnecting' }
CPProcessVisualElement >> newReconnectHandleFor: aSequenceFlow movingSource: movesSource [
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
				self addDiagramChild: adjacentReference.
				lines := edgeVisual lineElements.
				lines ifNotEmpty: [
					hiddenTerminalLine := movesSource
						ifTrue: [ lines first ]
						ifFalse: [ lines last ].
					hiddenTerminalLine visibility: BlVisibility hidden ] ].
			localPoint := self diagramPointForGlobalPoint: anEvent position.
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
			self addDiagramChild: previewCursor.
			self addDiagramChildFirst: previewLine ]
		dragged: [ :anEvent :handle |
			| candidate |
			previewCursor relocate: (self diagramPointForGlobalPoint: anEvent position).
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
				within: self diagramPresentationParent.
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
				within: self diagramPresentationParent ]
		ifFalse: [
			aPreviewLine toAnchor
				positionForAnchoredElement: aPreviewLine
				within: self diagramPresentationParent ].
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
		within: self diagramPresentationParent.
	targetPoint := lastLine toAnchor
		positionForAnchoredElement: lastLine
		within: self diagramPresentationParent.

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
		bounds: (aNodeElement bounds inParent: self diagramPresentationParent)
		toward: aPoint
]




{ #category : 'private - reconnecting' }
CPProcessVisualElement >> reconnectOperationFor: aSequenceFlow movingSource: movesSource candidate: aCandidate [
	| edge source target sourceShape targetShape |
	edge := self
		edgeForSequenceFlow: aSequenceFlow
		ifFound: [ :anEdge | anEdge ]
		ifNone: [ ^ nil ].
	source := self stagedSourceOf: aSequenceFlow.
	target := self stagedTargetOf: aSequenceFlow.
	movesSource
		ifTrue: [ source := aCandidate ]
		ifFalse: [ target := aCandidate ].
	sourceShape := self diagramShapeForModelElement: source.
	targetShape := self diagramShapeForModelElement: target.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [ ^ nil ].
	^ diagramEditing
		reconnectEdge: edge
		sourceShape: sourceShape
		targetShape: targetShape
		waypoints: (self
			proposedReconnectWaypointsFor: edge
			source: source
			target: target)
]


{ #category : 'private - reconnecting' }
CPProcessVisualElement >> proposedReconnectWaypointsFor: anEdge source: aSource target: aTarget [
	| waypoints sourceShape targetShape sourceBounds targetBounds |
	waypoints := (self stagedWaypointsOf: anEdge) asOrderedCollection copy.
	waypoints size < 2 ifTrue: [ ^ waypoints ].
	sourceShape := self diagramShapeForModelElement: aSource.
	targetShape := self diagramShapeForModelElement: aTarget.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [ ^ waypoints ].
	sourceBounds := self stagedBoundsOf: sourceShape.
	targetBounds := self stagedBoundsOf: targetShape.
	waypoints
		at: 1 put: sourceBounds center;
		at: waypoints size put: targetBounds center.
	^ waypoints species withAll: waypoints
]


{ #category : 'private - reconnecting' }
CPProcessVisualElement >> reconnectSequenceFlow: aSequenceFlow source: aSource target: aTarget [
	| edge sourceShape targetShape operation assessment |
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	edge := self
		edgeForSequenceFlow: aSequenceFlow
		ifFound: [ :anEdge | anEdge ]
		ifNone: [ ^ nil ].
	sourceShape := self diagramShapeForModelElement: aSource.
	targetShape := self diagramShapeForModelElement: aTarget.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [ ^ nil ].
	operation := diagramEditing
		reconnectEdge: edge
		sourceShape: sourceShape
		targetShape: targetShape
		waypoints: (self
			proposedReconnectWaypointsFor: edge
			source: aSource
			target: aTarget).
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateDiagramAppearance ].
	^ assessment
]

{ #category : 'private - selection' }
CPProcessVisualElement >> installEdgeSelectionOn: aLine for: anEdge [
	aLine
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent |
				connectionSourceModelElement ifNil: [
					anEvent modifiers isShift
						ifTrue: [ self toggleSelectionOfDiagramElement: anEdge ]
						ifFalse: [ self selectOnlyDiagramElement: anEdge ].
					self requestFocus.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDoubleClickEvent
			do: [ :anEvent |
				connectionSourceModelElement ifNil: [
					self selectOnlyDiagramElement: anEdge.
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
	| diagramElements operation assessment |
	diagramSelection isEmpty ifTrue: [ ^ self ].
	diagramElements := diagramSelection diagramElements.
	operation := diagramEditing remove: diagramElements.
	operation ifNil: [ ^ self ].
	assessment := operation assess.
	assessment isApplicable ifFalse: [ ^ assessment ].
	operation apply.

	diagramSelection clear.
	connectionSourceModelElement := nil.
	connectionTargetModelElement := nil.
	insertionTargetEdge := nil.
	selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: nil ].
	diagramElementsRemovedBlock
		ifNil: [ self refresh ]
		ifNotNil: [ :aBlock | aBlock value: diagramElements ].
	^ assessment
]


{ #category : 'selection' }
CPProcessVisualElement >> clearDiagramSelection [
	"Clear the shared Process-tree selection without reporting a new selection upward."
	diagramSelection clear.
	rootVisual updateSelectionAppearanceRecursively
]


{ #category : 'private - selection' }
CPProcessVisualElement >> clearLocalSelection [
	connectionSourceModelElement := nil.
	connectionTargetModelElement := nil.
	insertionTargetEdge := nil.
	boundaryEventPaletteTargetModelElement := nil.
	diagramSelection clear.
	rootVisual updateSelectionAppearanceRecursively
]


{ #category : 'private - interaction' }
CPProcessVisualElement >> clearInteractionAndSelection [
	connectionSourceModelElement := nil.
	connectionTargetModelElement := nil.
	insertionTargetEdge := nil.
	boundaryEventPaletteTargetModelElement := nil.
	diagramSelection clear.
	rootVisual updateSelectionAppearanceRecursively.
	selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: nil ]
]


{ #category : 'private - interaction' }
CPProcessVisualElement >> cancelInteraction [
	(self hasActiveTransientInteraction) ifFalse: [ ^ self ].
	connectionSourceModelElement := nil.
	connectionTargetModelElement := nil.
	insertionTargetEdge := nil.
	boundaryEventPaletteTargetModelElement := nil.
	self updateDiagramAppearance
]


{ #category : 'private - interaction' }
CPProcessVisualElement >> hasActiveTransientInteraction [
	^ connectionSourceModelElement notNil
		or: [ connectionTargetModelElement notNil
		or: [ insertionTargetEdge notNil
		or: [ boundaryEventPaletteTargetModelElement notNil ] ] ]
]

{ #category : 'private - labels' }
CPProcessVisualElement >> edgeLabelHostFor: anEdge ifAbsent: aBlock [
	| edgeVisual |
	edgeVisual := edgeVisualsByEdge at: anEdge ifAbsent: [ ^ aBlock value ].
	^ edgeVisual labelHost ifNil: [ aBlock value ]
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
CPProcessVisualElement >> flowContainerContextContaining: aFlowElement [
	^ CPProcessFlowContainerContext
		containingFlowElement: aFlowElement
		inRootMemento: memento
]

{ #category : 'private - staged state' }
CPProcessVisualElement >> flowElementMementoFor: aFlowElement [
	^ (self flowContainerContextContaining: aFlowElement)
		ifNotNil: [ :aContext | aContext childMementoFor: aFlowElement ]
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
	^ diagramContext expandedOf: aShape
]



{ #category : 'accessing - testing' }
CPProcessVisualElement >> shapeElementsByModelElement [
	^ shapeElementsByModelElement
]



{ #category : 'private - subprocess' }
CPProcessVisualElement >> installNestedProcessVisualIn: aShapeElement for: aSubProcess [
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
		diagramSelection: diagramSelection;
		selectionChangedDo: selectionChangedBlock;
		diagramElementsRemovedDo: diagramElementsRemovedBlock;
		diagramEditing: diagramEditing
]

{ #category : 'private - subprocess' }
CPProcessVisualElement >> installSubProcessExpansionOn: aShapeElement for: aFlowNode shape: aShape [
	aFlowNode isSubProcess ifFalse: [ ^ self ].
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	aShapeElement installSubProcessExpansion: [ :isExpanded |
		self setShape: aShape expanded: isExpanded ]
]

{ #category : 'operations' }
CPProcessVisualElement >> setShape: aShape expanded: aBoolean [
	| assessment |
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	assessment := (diagramEditing setShape: aShape expanded: aBoolean) apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateDiagramAppearance ].
	^ assessment
]


{ #category : 'selection' }
CPProcessVisualElement >> diagramSelection [
	^ diagramSelection
]

{ #category : 'configuration' }
CPProcessVisualElement >> diagramSelection: aDiagramSelection [
	diagramSelection := aDiagramSelection
]

{ #category : 'selection' }
CPProcessVisualElement >> diagramElementsInTree [
	| elements |
	elements := OrderedCollection new.
	diagramElements ifNotNil: [ elements addAll: diagramElements ].
	shapeElementsByModelElement valuesDo: [ :aShapeElement |
		aShapeElement nestedProcessVisual ifNotNil: [ :aNestedVisual |
			elements addAll: aNestedVisual diagramElementsInTree ] ].
	^ elements
]


{ #category : 'selection' }
CPProcessVisualElement >> selectedDiagramElements [
	^ diagramSelection diagramElements
]


{ #category : 'selection' }
CPProcessVisualElement >> stagedModelElementOfDiagramElement: aDiagramElement [
	| owner |
	owner := rootVisual visualContainingDiagramElement: aDiagramElement.
	^ owner ifNotNil: [ :aVisual | aVisual stagedModelElementOf: aDiagramElement ]
]

{ #category : 'private - selection' }
CPProcessVisualElement >> diagramElementForModelElement: aModelElement [
	(shapeElementsByModelElement at: aModelElement ifAbsent: [ nil ])
		ifNotNil: [ :aShapeElement | ^ aShapeElement diagramShape ].
	^ edgeVisualsByEdge keys
		detect: [ :anEdge | (self stagedModelElementOf: anEdge) == aModelElement ]
		ifNone: [ nil ]
]

{ #category : 'private - selection' }
CPProcessVisualElement >> diagramElementForModelElementInTree: aModelElement [
	(self diagramElementForModelElement: aModelElement)
		ifNotNil: [ :aDiagramElement | ^ aDiagramElement ].
	shapeElementsByModelElement valuesDo: [ :aShapeElement |
		aShapeElement nestedProcessVisual ifNotNil: [ :aNestedVisual |
			(aNestedVisual diagramElementForModelElementInTree: aModelElement)
				ifNotNil: [ :aDiagramElement | ^ aDiagramElement ] ] ].
	^ nil
]

{ #category : 'private - selection' }
CPProcessVisualElement >> selectOnlyDiagramElement: aDiagramElement [
	diagramSelection selectOnly: aDiagramElement.
	rootVisual updateSelectionAppearanceRecursively.
	selectionChangedBlock ifNotNil: [ :aBlock |
		aBlock value: diagramSelection soleDiagramElement ]
]

{ #category : 'private - selection' }
CPProcessVisualElement >> toggleSelectionOfDiagramElement: aDiagramElement [
	diagramSelection toggle: aDiagramElement.
	rootVisual updateSelectionAppearanceRecursively.
	selectionChangedBlock ifNotNil: [ :aBlock |
		aBlock value: diagramSelection soleDiagramElement ]
]

{ #category : 'private - selection' }
CPProcessVisualElement >> updateSelectionAppearanceRecursively [
	self updateDiagramAppearance.
	shapeElementsByModelElement valuesDo: [ :aShapeElement |
		aShapeElement nestedProcessVisual ifNotNil: [ :aNestedVisual |
			aNestedVisual updateSelectionAppearanceRecursively ] ]
]

