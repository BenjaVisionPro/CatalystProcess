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
		'moveParticipantShapeOperationBlock',
		'resizeParticipantShapeOperationBlock',
		'removeParticipantOperationBlock',
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
	| surfaceColor collaborationContext collaborationDiagram |
	diagramCameraInitialized := false.
	surfaceColor := self workspaceSurfaceColor.
	collaborationContext := self collaborationContext.
	collaborationDiagram := collaborationContext ifNotNil: [ :aContext | aContext diagram ].

	processDiagramElement := self
		newConfiguredProcessDiagramElementCollaborationHosted: collaborationDiagram notNil.

	collaborationDiagramElement := nil.
	diagramElement := collaborationDiagram
		ifNil: [ processDiagramElement ]
		ifNotNil: [
			collaborationDiagramElement := CPCollaborationVisualElement new
				connectMessageFlowOperationFor: connectMessageFlowOperationBlock;
				createParticipantOperationFor: createParticipantOperationBlock;
				moveParticipantShapeOperationFor: moveParticipantShapeOperationBlock;
				resizeParticipantShapeOperationFor: resizeParticipantShapeOperationBlock;
				removeParticipantDo: [ :aParticipant | self removeParticipant: aParticipant ];
				selectionChangedDo: [ :aModelElement | self collaborationSelectionChanged: aModelElement ];
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

{ #category : 'private - building' }
CPProcessPresentation >> newConfiguredProcessDiagramElementCollaborationHosted: aBoolean [
	| visual |
	visual := CPProcessVisualElement new.
	aBoolean ifTrue: [ visual beCollaborationHosted ].
	visual
		selectionChangedDo: [ :aModelElement | self processSelectionChanged: aModelElement ];
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
	^ visual
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
	| collaborationContext collaborationDiagram scrollable previousGraphViewportOrigin viewport newGraphContentOrigin targetScrollPosition scrollDelta |
	collaborationContext := self collaborationContext.
	collaborationContext ifNil: [ ^ self ].
	collaborationDiagram := collaborationContext diagram.

	collaborationDiagramElement ifNil: [
		"The first Pool changes presentation topology but must not change the
		user's camera. Work in BlScrollableElement coordinates and establish the
		target scrollPosition before Bloc's normal layout phase.

		Do not force a synchronous layout here. Bloc's documented production
		lifecycle defers layout to the frame. BlScrollableElement>>onLayout: then
		owns gap fixing and clamping against the newly measured content."
		scrollable := diagramScrollElement childNamed: #scrollable.
		previousGraphViewportOrigin := processDiagramElement diagramExtent = (0 @ 0)
			ifTrue: [ nil ]
			ifFalse: [
				scrollable scrollPosition + processDiagramElement cameraSlack ].
		viewport := diagramScrollElement extent max: 1 @ 1.

		processDiagramElement := self
			newConfiguredProcessDiagramElementCollaborationHosted: true.
		collaborationDiagramElement := CPCollaborationVisualElement new
			connectMessageFlowOperationFor: connectMessageFlowOperationBlock;
			createParticipantOperationFor: createParticipantOperationBlock;
			moveParticipantShapeOperationFor: moveParticipantShapeOperationBlock;
			resizeParticipantShapeOperationFor: resizeParticipantShapeOperationBlock;
			removeParticipantDo: [ :aParticipant | self removeParticipant: aParticipant ];
			refreshAfterGeometryChangeDo: [ self refreshCollaborationDiagramPreservingCamera ];
			selectionChangedDo: [ :aModelElement | self collaborationSelectionChanged: aModelElement ];
			processMemento: self memento
			processVisual: processDiagramElement;
			yourself.
		collaborationDiagramElement viewportExtent: viewport.
		diagramElement := collaborationDiagramElement.

		"BrScrollPane content replacement requests layout but does not reset the
		native scrollPosition. Install the desired native camera position now;
		the normal Bloc layout will measure the new content and retain it when it
		is within the new scroll bounds."
		diagramCameraInitialized := true.
		diagramScrollElement content: diagramElement.

		previousGraphViewportOrigin ifNotNil: [
			newGraphContentOrigin :=
				collaborationDiagramElement cameraSlack
					- collaborationDiagramElement diagramBounds origin
					+ (collaborationDiagramElement
						collaborationPointForProcessRootPoint:
							processDiagramElement diagramBounds origin).
			targetScrollPosition :=
				previousGraphViewportOrigin - newGraphContentOrigin.
			scrollDelta := targetScrollPosition - scrollable scrollPosition.
			scrollable scrollHorizontallyBy: scrollDelta x.
			scrollable scrollVerticallyBy: scrollDelta y ].
		^ self ].
	collaborationDiagramElement refresh
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> refreshCollaborationDiagramPreservingCamera [
	| scrollable oldScrollPosition oldNormalizationOffset newNormalizationOffset targetScrollPosition scrollDelta |
	collaborationDiagramElement ifNil: [ ^ self ].
	scrollable := diagramScrollElement childNamed: #scrollable.

	"Every Collaboration diagram point is rendered through this translation:
	 scrollPosition + cameraSlack - diagramBounds origin.
	 A geometry refresh may change both cameraSlack and diagramBounds. Preserve
	 that complete translation so resizing or moving a Pool never pans the
	 user's camera as a side effect."
	oldScrollPosition := scrollable scrollPosition.
	oldNormalizationOffset :=
		collaborationDiagramElement cameraSlack
			- collaborationDiagramElement diagramBounds origin.

	collaborationDiagramElement refresh.

	newNormalizationOffset :=
		collaborationDiagramElement cameraSlack
			- collaborationDiagramElement diagramBounds origin.
	targetScrollPosition :=
		oldScrollPosition + oldNormalizationOffset - newNormalizationOffset.
	scrollDelta := targetScrollPosition - scrollable scrollPosition.
	scrollable scrollHorizontallyBy: scrollDelta x.
	scrollable scrollVerticallyBy: scrollDelta y
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> removeParticipant: aParticipant [
	| operation assessment |
	removeParticipantOperationBlock ifNil: [ ^ self ].
	operation := removeParticipantOperationBlock value: aParticipant.
	assessment := operation assess.
	assessment isApplicable ifFalse: [ ^ assessment ].

	operation apply.
	self selectModelElement: nil.
	self stagedDefinitionalCollaboration
		ifNil: [ self restoreStandaloneProcessDiagramPreservingCamera ]
		ifNotNil: [ self refreshCollaborationDiagramPreservingCamera ].
	^ assessment
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> restoreStandaloneProcessDiagramPreservingCamera [
	| scrollable previousGraphViewportOrigin viewport targetScrollPosition scrollDelta |
	collaborationDiagramElement ifNil: [ ^ self ].
	scrollable := diagramScrollElement childNamed: #scrollable.
	previousGraphViewportOrigin :=
		scrollable scrollPosition
			+ collaborationDiagramElement cameraSlack
			- collaborationDiagramElement diagramBounds origin
			+ (collaborationDiagramElement
				collaborationPointForProcessRootPoint:
					processDiagramElement diagramBounds origin).
	viewport := diagramScrollElement extent max: 1 @ 1.

	processDiagramElement
		beStandalone;
		collaborationVisual: nil;
		viewportExtent: viewport.
	collaborationDiagramElement := nil.
	diagramElement := processDiagramElement.
	diagramCameraInitialized := true.
	diagramScrollElement content: diagramElement.

	targetScrollPosition :=
		previousGraphViewportOrigin - processDiagramElement cameraSlack.
	scrollDelta := targetScrollPosition - scrollable scrollPosition.
	scrollable scrollHorizontallyBy: scrollDelta x.
	scrollable scrollVerticallyBy: scrollDelta y
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> collaborationContext [
	^ CPProcessCollaborationContext inRootMemento: self memento
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> stagedDefinitionalCollaboration [
	^ self collaborationContext
		ifNil: [ nil ]
		ifNotNil: [ :aContext | aContext collaboration ]
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
CPProcessPresentation >> collaborationSelectionChanged: aModelElement [
	"Pool and Process-content selection are mutually exclusive. Selecting a Pool
	clears selection throughout the hosted Process tree, including expanded
	SubProcesses, before making the Pool the presentation selection."
	processDiagramElement ifNotNil: [
		processDiagramElement clearDiagramSelection ].
	self selectModelElement: aModelElement
]

{ #category : 'private - selection' }
CPProcessPresentation >> processSelectionChanged: aModelElement [
	"Process and Pool selection are mutually exclusive. A click inside a hosted
	Process transfers selection to the Process content, so the enclosing Pool
	must immediately lose its selected treatment."
	collaborationDiagramElement ifNotNil: [
		collaborationDiagramElement clearParticipantSelection ].
	self selectModelElement: aModelElement
]

{ #category : 'private - selection' }
CPProcessPresentation >> mementoForModelElement: aModelElement [
	| flowContext selectedMemento collaborationContext |
	aModelElement == self memento model ifTrue: [ ^ self memento ].

	flowContext := CPProcessFlowContainerContext rootFor: self memento.
	selectedMemento := flowContext mementoForFlowElement: aModelElement.
	selectedMemento ifNotNil: [ ^ selectedMemento ].

	collaborationContext := self collaborationContext.
	selectedMemento := collaborationContext ifNotNil: [ :aContext |
		aContext mementoForMember: aModelElement ].
	selectedMemento ifNotNil: [ ^ selectedMemento ].

	self error: 'Selected model element is not part of the staged Process, Sub-Process, or definitional Collaboration.'
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
			moveParticipantShapeOperationFor: moveParticipantShapeOperationBlock;
			resizeParticipantShapeOperationFor: resizeParticipantShapeOperationBlock;
			removeParticipantDo: [ :aParticipant | self removeParticipant: aParticipant ];
			refreshAfterGeometryChangeDo: [ self refreshCollaborationDiagramPreservingCamera ];
			selectionChangedDo: [ :aModelElement | self collaborationSelectionChanged: aModelElement ];
			refresh ]
]
{ #category : 'configuration' }
CPProcessPresentation >> createFlowNodeOperationFor: aBlock [ createFlowNodeOperationBlock := aBlock ]

{ #category : 'configuration' }
CPProcessPresentation >> createParticipantOperationFor: aBlock [
	createParticipantOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessPresentation >> moveParticipantShapeOperationFor: aBlock [
	moveParticipantShapeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessPresentation >> resizeParticipantShapeOperationFor: aBlock [
	resizeParticipantShapeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessPresentation >> removeParticipantOperationFor: aBlock [
	removeParticipantOperationBlock := aBlock
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
