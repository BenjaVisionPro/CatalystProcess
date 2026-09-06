"I am the visual Magritte presentation for a CPProcess.

I compose the Process diagram with Foundation Detail for the currently selected semantic object. Both presentations edit the same CFMaMemento transaction: the diagram uses the root Process memento and Detail uses that root memento or the appropriate embedded child memento."
Class {
	#name : 'CPProcessPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'diagramElement',
		'collaborationDiagramElement',
		'processDiagramElement',
		'diagramScrollElement',
		'detailHostElement',
		'detailScrollElement',
		'workspaceElement',
		'selectedModelElement',
		'moveShapeOperationBlock',
		'transferFlowNodeOperationBlock',
		'transferFlowNodesOperationBlock',
		'moveShapesOperationBlock',
		'resizeShapeOperationBlock',
		'createFlowNodeOperationBlock',
		'createParticipantOperationBlock',
		'replaceFlowNodeOperationBlock',
		'connectFlowNodesOperationBlock',
		'connectMessageFlowOperationBlock',
		'insertFlowNodeOperationBlock',
		'removeFlowNodeOperationBlock',
		'removeSequenceFlowOperationBlock',
		'reconnectSequenceFlowOperationBlock',
		'setEdgeWaypointsOperationBlock',
		'setShapeExpandedOperationBlock',
		'setEdgeLabelPlacementOperationBlock',
		'diagramCameraInitialized'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'private - building' }
CPProcessPresentation >> prepareHostElement [
	| surfaceColor collaboration collaborationDiagram |
	diagramCameraInitialized := false.
	surfaceColor := self workspaceSurfaceColor.
	collaboration := self stagedDefinitionalCollaboration.
	collaborationDiagram := collaboration ifNotNil: [
		self stagedDiagramOfDefinitionalCollaboration: collaboration ].

	processDiagramElement := CPProcessVisualElement new.
	collaborationDiagram ifNotNil: [
		processDiagramElement beCollaborationHosted ].
	processDiagramElement
		selectionChangedDo: [ :aModelElement | self selectModelElement: aModelElement ];
		moveShapeOperationFor: moveShapeOperationBlock;
		transferFlowNodeOperationFor: transferFlowNodeOperationBlock;
		transferFlowNodesOperationFor: transferFlowNodesOperationBlock;
		moveShapesOperationFor: moveShapesOperationBlock;
		resizeShapeOperationFor: resizeShapeOperationBlock;
		createFlowNodeOperationFor: createFlowNodeOperationBlock;
		createParticipantOperationFor: createParticipantOperationBlock;
		collaborationChangedDo: [ self ensureCollaborationDiagramPresentation ];
		replaceFlowNodeOperationFor: replaceFlowNodeOperationBlock;
		connectFlowNodesOperationFor: connectFlowNodesOperationBlock;
		insertFlowNodeOperationFor: insertFlowNodeOperationBlock;
		removeFlowNodeOperationFor: removeFlowNodeOperationBlock;
		removeSequenceFlowOperationFor: removeSequenceFlowOperationBlock;
		reconnectSequenceFlowOperationFor: reconnectSequenceFlowOperationBlock;
		setEdgeWaypointsOperationFor: setEdgeWaypointsOperationBlock;
		setShapeExpandedOperationFor: setShapeExpandedOperationBlock;
		setEdgeLabelPlacementOperationFor: setEdgeLabelPlacementOperationBlock;
		memento: self memento.

	collaborationDiagramElement := nil.
	diagramElement := collaborationDiagram
		ifNil: [ processDiagramElement ]
		ifNotNil: [
			collaborationDiagramElement := CPCollaborationVisualElement new
				connectMessageFlowOperationFor: connectMessageFlowOperationBlock;
				createParticipantOperationFor: createParticipantOperationBlock;
				processMemento: self memento
				processVisual: processDiagramElement;
				yourself.
			collaborationDiagramElement ].

	diagramScrollElement := BrScrollPane new
		background: surfaceColor;
		allowMeAndChildrenMouseEvents;
		aptitude: BrScrollPaneAptitude
			+ BrGlamorousWithHorizontalScrollbarAptitude
			+ BrGlamorousWithVerticalScrollbarAptitude;
		hMatchParent;
		vMatchParent;
		content: diagramElement;
		yourself.
	diagramScrollElement addEventHandler: (BlEventHandler
		on: BlElementExtentChangedEvent
		do: [ :anEvent | self updateDiagramViewportExtent ]).

	detailHostElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 0;
		padding: BlInsets empty;
		background: surfaceColor;
		yourself.

	detailScrollElement := BrScrollPane new
		background: surfaceColor;
		allowMeAndChildrenMouseEvents;
		aptitude: BrScrollPaneAptitude + BrGlamorousWithVerticalScrollbarAptitude;
		hExact: 380;
		vMatchParent;
		content: detailHostElement;
		yourself.

	workspaceElement := BrHorizontalPane new
		background: surfaceColor;
		hMatchParent;
		vMatchParent;
		cellSpacing: 0;
		addChild: diagramScrollElement;
		addChild: detailScrollElement;
		yourself.

	self hostElement
		background: surfaceColor;
		hMatchParent;
		vMatchParent;
		addChild: workspaceElement.

	selectedModelElement := nil
]

{ #category : 'private - layout' }
CPProcessPresentation >> updateDiagramViewportExtent [
	| viewport |
	diagramElement ifNil: [ ^ self ].
	viewport := diagramScrollElement extent.
	diagramElement viewportExtent: viewport.
	(diagramCameraInitialized not and: [ viewport x > 1 and: [ viewport y > 1 ] ]) ifTrue: [
		diagramCameraInitialized := true.
		diagramScrollElement enqueueTask: (BlTaskAction new action: [
			diagramScrollElement scrollBy: diagramElement cameraSlack / 2 ]) ]
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> ensureCollaborationDiagramPresentation [
	| collaboration collaborationDiagram |
	collaboration := self stagedDefinitionalCollaboration.
	collaboration ifNil: [ ^ self ].
	collaborationDiagram := self stagedDiagramOfDefinitionalCollaboration: collaboration.
	collaborationDiagram ifNil: [ ^ self ].

	collaborationDiagramElement ifNil: [
		collaborationDiagramElement := CPCollaborationVisualElement new
			connectMessageFlowOperationFor: connectMessageFlowOperationBlock;
			createParticipantOperationFor: createParticipantOperationBlock;
			processMemento: self memento
			processVisual: processDiagramElement;
			yourself.
		diagramElement := collaborationDiagramElement.
		diagramCameraInitialized := false.
		diagramScrollElement content: diagramElement.
		self updateDiagramViewportExtent.
		^ self ].
	collaborationDiagramElement refresh
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> stagedDefinitionalCollaboration [
	| description |
	description := self memento magritteDescription
		detect: [ :each | each handlesSelector: #definitionalCollaborationRef ].
	^ self memento readUsing: description
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> stagedDiagramOfDefinitionalCollaboration: aCollaboration [
	| collaborationDescription collaborationMemento diagramDescription |
	collaborationDescription := self memento magritteDescription
		detect: [ :each | each handlesSelector: #definitionalCollaborationRef ].
	collaborationMemento := self memento
		childMementoFor: aCollaboration
		inRelation: collaborationDescription.
	diagramDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	^ collaborationMemento readUsing: diagramDescription
]


{ #category : 'private - selection' }
CPProcessPresentation >> selectModelElement: aModelElement [
	| selectedMemento detailElement |
	selectedModelElement := aModelElement.
	aModelElement ifNil: [
		detailHostElement removeChildren.
		^ self ].
	selectedMemento := self mementoForModelElement: aModelElement.
	detailElement := self
		newDetailElementFor: aModelElement
		memento: selectedMemento.
	detailHostElement
		removeChildren;
		addChild: detailElement
]

{ #category : 'private - selection' }
CPProcessPresentation >> mementoForModelElement: aModelElement [
	| selectedMemento |
	aModelElement == self memento model ifTrue: [ ^ self memento ].
	selectedMemento := self
		mementoForFlowElement: aModelElement
		inContainerMemento: self memento.
	selectedMemento ifNil: [
		self error: 'Selected model element is not part of the staged Process/Sub-Process hierarchy.' ].
	^ selectedMemento
]

{ #category : 'private - selection' }
CPProcessPresentation >> mementoForFlowElement: aFlowElement inContainerMemento: aContainerMemento [
	| relationDescription stagedFlowElements |
	relationDescription := aContainerMemento magritteDescription
		detect: [ :each | each handlesSelector: #flowElements ].
	stagedFlowElements := aContainerMemento readUsing: relationDescription.

	(stagedFlowElements identityIncludes: aFlowElement) ifTrue: [
		^ aContainerMemento
			childMementoFor: aFlowElement
			inRelation: relationDescription ].

	stagedFlowElements do: [ :each |
		each isSubProcess ifTrue: [
			| subProcessMemento nestedMemento |
			subProcessMemento := aContainerMemento
				childMementoFor: each
				inRelation: relationDescription.
			nestedMemento := self
				mementoForFlowElement: aFlowElement
				inContainerMemento: subProcessMemento.
			nestedMemento ifNotNil: [ ^ nestedMemento ] ] ].

	^ nil
]

{ #category : 'private - selection' }
CPProcessPresentation >> newDetailElementFor: aModelElement memento: aMemento [
	| viewModel |
	viewModel := CFMaViewModel forObject: aModelElement memento: aMemento.
	viewModel
		ignoreImplicitActions;
		elementBuilderDo: [ CFMaDetailPresentation new ].
	^ viewModel asElement
]

{ #category : 'private - theme' }
CPProcessPresentation >> resolvedThemeColor: aThemeableColor [
	^ aThemeableColor blocResolveColorForTheme: self hostElement theme
]

{ #category : 'private - theme' }
CPProcessPresentation >> workspaceSurfaceColor [
	^ self resolvedThemeColor: self hostElement theme surfaces baseBackground
]

{ #category : 'visiting-description' }
CPProcessPresentation >> visitContainer: aDescription [
	"The Process diagram is the visual representation of the root description.
	Its semantic descriptions remain available to the memento and to complementary
	presentations such as Foundation Detail."
	aDescription == self objectDescription ifTrue: [ ^ self ].
	^ super visitContainer: aDescription
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> diagramElement [
	^ diagramElement
]


{ #category : 'accessing - testing' }
CPProcessPresentation >> collaborationDiagramElement [
	^ collaborationDiagramElement
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> processDiagramElement [
	^ processDiagramElement
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> detailHostElement [
	^ detailHostElement
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> selectedModelElement [
	^ selectedModelElement
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> workspaceElement [
	^ workspaceElement
]

{ #category : 'configuration' }
CPProcessPresentation >> moveShapeOperationFor: aBlock [
	moveShapeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessPresentation >> moveShapesOperationFor: aBlock [
	moveShapesOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessPresentation >> synchronizeEditingConfiguration [
	processDiagramElement ifNil: [ ^ self ].
	processDiagramElement
		moveShapeOperationFor: moveShapeOperationBlock;
		transferFlowNodeOperationFor: transferFlowNodeOperationBlock;
		transferFlowNodesOperationFor: transferFlowNodesOperationBlock;
		moveShapesOperationFor: moveShapesOperationBlock;
		resizeShapeOperationFor: resizeShapeOperationBlock;
		createFlowNodeOperationFor: createFlowNodeOperationBlock;
		createParticipantOperationFor: createParticipantOperationBlock;
		replaceFlowNodeOperationFor: replaceFlowNodeOperationBlock;
		connectFlowNodesOperationFor: connectFlowNodesOperationBlock;
		insertFlowNodeOperationFor: insertFlowNodeOperationBlock;
		removeFlowNodeOperationFor: removeFlowNodeOperationBlock;
		removeSequenceFlowOperationFor: removeSequenceFlowOperationBlock;
		reconnectSequenceFlowOperationFor: reconnectSequenceFlowOperationBlock;
		setEdgeWaypointsOperationFor: setEdgeWaypointsOperationBlock;
		setShapeExpandedOperationFor: setShapeExpandedOperationBlock;
		setEdgeLabelPlacementOperationFor: setEdgeLabelPlacementOperationBlock.
	processDiagramElement refresh.
	collaborationDiagramElement ifNotNil: [
		collaborationDiagramElement
			connectMessageFlowOperationFor: connectMessageFlowOperationBlock;
			createParticipantOperationFor: createParticipantOperationBlock;
			refresh ]
]
{ #category : 'configuration' }
CPProcessPresentation >> createFlowNodeOperationFor: aBlock [ createFlowNodeOperationBlock := aBlock ]

{ #category : 'configuration' }
CPProcessPresentation >> createParticipantOperationFor: aBlock [
	createParticipantOperationBlock := aBlock
]
{ #category : 'configuration' }
CPProcessPresentation >> replaceFlowNodeOperationFor: aBlock [ replaceFlowNodeOperationBlock := aBlock ]

{ #category : 'configuration' }
CPProcessPresentation >> connectFlowNodesOperationFor: aBlock [ connectFlowNodesOperationBlock := aBlock ]

{ #category : 'configuration' }
CPProcessPresentation >> connectMessageFlowOperationFor: aBlock [
	connectMessageFlowOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessPresentation >> removeFlowNodeOperationFor: aBlock [ removeFlowNodeOperationBlock := aBlock ]

{ #category : 'configuration' }
CPProcessPresentation >> removeSequenceFlowOperationFor: aBlock [ removeSequenceFlowOperationBlock := aBlock ]


{ #category : 'configuration' }
CPProcessPresentation >> reconnectSequenceFlowOperationFor: aBlock [
	reconnectSequenceFlowOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessPresentation >> setEdgeWaypointsOperationFor: aBlock [
	setEdgeWaypointsOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessPresentation >> insertFlowNodeOperationFor: aBlock [
	insertFlowNodeOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessPresentation >> resizeShapeOperationFor: aBlock [
	resizeShapeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessPresentation >> setEdgeLabelPlacementOperationFor: aBlock [
	setEdgeLabelPlacementOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessPresentation >> setShapeExpandedOperationFor: aBlock [
	setShapeExpandedOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessPresentation >> transferFlowNodeOperationFor: aBlock [
	transferFlowNodeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessPresentation >> transferFlowNodesOperationFor: aBlock [
	transferFlowNodesOperationBlock := aBlock
]
