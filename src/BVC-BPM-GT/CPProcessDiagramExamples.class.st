Class {
	#name : 'CPProcessDiagramExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Examples',
	#package : 'BVC-BPM-GT',
	#tag : 'Examples'
}

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> processPresentationIncludesDiagramAndDetailForm [
	<gtExample>
	| process start task finish firstEdge secondEdge memento viewModel element presentation diagram |
	process := CPProcessDesign new label: 'Diagram pressure test'; yourself.
	start := CPStartEventDesignNode new label: 'Start'; position: 60 @ 170; yourself.
	task := CPUserTaskDesignNode new label: 'Review'; position: 250 @ 164; yourself.
	finish := CPEndEventDesignNode new label: 'Done'; position: 470 @ 170; yourself.
	firstEdge := CPProcessDesignEdge new sourceNode: start; targetNode: task; yourself.
	secondEdge := CPProcessDesignEdge new sourceNode: task; targetNode: finish; yourself.
	process
		nodes: (OrderedCollection with: start with: task with: finish);
		edges: (OrderedCollection with: firstEdge with: secondEdge).
	memento := CFMaMemento model: process.
	viewModel := CFMaViewModel forObject: process memento: memento.
	viewModel presentationDo: [ :aPresentation | presentation := aPresentation ].
	element := CFMaFormRootElement new.
	viewModel initializeForm: element forMemento: memento.
	diagram := presentation diagramElement.
	self assert: element class equals: CFMaFormRootElement.
	self assert: presentation class equals: CPProcessDesignPresentation.
	self assert: diagram isNotNil.
	self assert: presentation workspaceElement children size equals: 2.
	self assert: presentation workspaceElement children first == presentation canvasScrollElement.
	self assert: presentation workspaceElement children second == presentation detailPagerElement.
	self assert: presentation detailPagerModel paneModels size equals: 1.
	self assert: presentation detailPagerModel settings numberOfVisibleColumns equals: 1.
	self assert: presentation detailHostElement children isEmpty not.
	^ element
]


{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> diagramNodeRemovalUsesProcessSemantics [
	<gtExample>
	| process node other edge memento nodesDescription edgesDescription configuration diagram assessment |
	process := CPProcessDesign new.
	node := CPUserTaskDesignNode new position: 80 @ 120; yourself.
	other := CPEndEventDesignNode new position: 300 @ 120; yourself.
	edge := CPProcessDesignEdge new sourceNode: node; targetNode: other; yourself.
	process
		nodes: (OrderedCollection with: node with: other);
		edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	diagram := CPProcessDiagramElement new
		removeNodeOperationFor: [ :aNode | configuration removeNodeOperationFor: aNode in: memento ];
		memento: memento.

	assessment := diagram removeNode: node.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: nodesDescription) size equals: 1.
	self assert: (memento readUsing: nodesDescription) first == other.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	self assert: process nodes size equals: 2.
	self assert: process edges size equals: 1.
	^ diagram
]

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> diagramEdgeRemovalUsesRelationSemantics [
	<gtExample>
	| process source target edge memento nodesDescription edgesDescription configuration diagram assessment |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new position: 80 @ 120; yourself.
	target := CPEndEventDesignNode new position: 300 @ 120; yourself.
	edge := CPProcessDesignEdge new sourceNode: source; targetNode: target; yourself.
	process
		nodes: (OrderedCollection with: source with: target);
		edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	diagram := CPProcessDiagramElement new
		removeEdgeOperationFor: [ :anEdge | configuration removeEdgeOperationFor: anEdge in: memento ];
		memento: memento.

	assessment := diagram removeEdge: edge.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	self assert: (memento readUsing: nodesDescription) size equals: 2.
	self assert: process edges size equals: 1.
	^ diagram
]

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> diagramRefreshPreservesNodePresentationIdentity [
	<gtExample>
	| process node memento nodesDescription edgesDescription configuration diagram elementBefore assessment elementAfter |
	process := CPProcessDesign new.
	node := CPUserTaskDesignNode new position: 80 @ 120; yourself.
	process nodes: (OrderedCollection with: node); edges: OrderedCollection new.
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	diagram := CPProcessDiagramElement new
		positionNodeOperationFor: [ :aNode :aPoint | configuration positionNodeOperationFor: aNode at: aPoint in: memento ];
		memento: memento.
	elementBefore := diagram nodeElementFor: node.

	assessment := diagram positionNode: node at: 220 @ 180.
	elementAfter := diagram nodeElementFor: node.

	self assert: assessment isApplicable.
	self assert: elementBefore == elementAfter.
	self assert: (diagram stagedPositionOf: node ifAbsent: [ nil ]) equals: 220 @ 180.
	self assert: node position equals: 80 @ 120.
	^ diagram
]

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> diagramRefreshPreservesEdgePresentationIdentity [
	<gtExample>
	| process source oldTarget newTarget edge memento nodesDescription edgesDescription configuration diagram elementBefore assessment elementAfter |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new position: 80 @ 120; yourself.
	oldTarget := CPUserTaskDesignNode new position: 280 @ 120; yourself.
	newTarget := CPEndEventDesignNode new position: 480 @ 120; yourself.
	edge := CPProcessDesignEdge new sourceNode: source; targetNode: oldTarget; yourself.
	process
		nodes: (OrderedCollection with: source with: oldTarget with: newTarget);
		edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	diagram := CPProcessDiagramElement new
		reconnectEdgeOperationFor: [ :anEdge :aSource :aTarget | configuration reconnectOperationFor: anEdge from: aSource to: aTarget in: memento ];
		memento: memento.
	elementBefore := diagram edgeElementFor: edge.

	assessment := diagram reconnectEdge: edge from: source to: newTarget.
	elementAfter := diagram edgeElementFor: edge.

	self assert: assessment isApplicable.
	self assert: elementBefore == elementAfter.
	self assert: edge targetNode == oldTarget.
	^ diagram
]

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> rejectedDiagramConnectionLeavesStagedTopologyUnchanged [
	<gtExample>
	| process source target outsider memento nodesDescription edgesDescription configuration diagram assessment |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new position: 80 @ 120; yourself.
	target := CPEndEventDesignNode new position: 300 @ 120; yourself.
	outsider := CPUserTaskDesignNode new position: 500 @ 120; yourself.
	process
		nodes: (OrderedCollection with: source with: target);
		edges: OrderedCollection new.
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	diagram := CPProcessDiagramElement new
		connectNodeOperationFor: [ :aSource :aTarget | configuration connectOperationFrom: aSource to: aTarget in: memento ];
		memento: memento.

	assessment := diagram connectNode: source to: outsider.

	self assert: assessment isApplicable not.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	self assert: process edges isEmpty.
	^ diagram
]

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> rejectedDiagramReconnectLeavesStagedEndpointUnchanged [
	<gtExample>
	| process source target outsider edge memento nodesDescription edgesDescription configuration diagram assessment |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new position: 80 @ 120; yourself.
	target := CPEndEventDesignNode new position: 300 @ 120; yourself.
	outsider := CPUserTaskDesignNode new position: 500 @ 120; yourself.
	edge := CPProcessDesignEdge new sourceNode: source; targetNode: target; yourself.
	process
		nodes: (OrderedCollection with: source with: target);
		edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	diagram := CPProcessDiagramElement new
		reconnectEdgeOperationFor: [ :anEdge :aSource :aTarget | configuration reconnectOperationFor: anEdge from: aSource to: aTarget in: memento ];
		memento: memento.

	assessment := diagram reconnectEdge: edge from: source to: outsider.

	self assert: assessment isApplicable not.
	self assert: (diagram stagedTargetOf: edge) == target.
	self assert: edge targetNode == target.
	^ diagram
]

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> diagramMultiNodeRemovalUsesOneProcessIntention [
	<gtExample>
	| process first second survivor firstEdge secondEdge memento nodesDescription edgesDescription configuration diagram assessment |
	process := CPProcessDesign new.
	first := CPStartEventDesignNode new position: 80 @ 120; yourself.
	second := CPUserTaskDesignNode new position: 280 @ 120; yourself.
	survivor := CPEndEventDesignNode new position: 480 @ 120; yourself.
	firstEdge := CPProcessDesignEdge new sourceNode: first; targetNode: second; yourself.
	secondEdge := CPProcessDesignEdge new sourceNode: second; targetNode: survivor; yourself.
	process
		nodes: (OrderedCollection with: first with: second with: survivor);
		edges: (OrderedCollection with: firstEdge with: secondEdge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	diagram := CPProcessDiagramElement new
		removeNodeOperationFor: [ :aNode | configuration removeNodeOperationFor: aNode in: memento ];
		removeNodesOperationFor: [ :someNodes | configuration removeNodesOperationFor: someNodes in: memento ];
		memento: memento.

	diagram selectNode: first adding: false.
	diagram selectNode: second adding: true.
	assessment := diagram removeSelection.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: nodesDescription) size equals: 1.
	self assert: (memento readUsing: nodesDescription) first == survivor.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 2.
	^ diagram
]

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> cancelArmedConnectionLeavesTopologyUnchanged [
	<gtExample>
	| process source target memento nodesDescription edgesDescription configuration diagram |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new position: 80 @ 120; yourself.
	target := CPEndEventDesignNode new position: 300 @ 120; yourself.
	process
		nodes: (OrderedCollection with: source with: target);
		edges: OrderedCollection new.
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	diagram := CPProcessDiagramElement new
		connectNodeOperationFor: [ :aSource :aTarget | configuration connectOperationFrom: aSource to: aTarget in: memento ];
		memento: memento.

	diagram beginConnectionFrom: source.
	diagram cancelInteraction.
	diagram completeConnectionTo: target.

	self assert: (memento readUsing: edgesDescription) isEmpty.
	self assert: process edges isEmpty.
	^ diagram
]

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> startingReconnectCancelsArmedConnection [
	<gtExample>
	| process source target replacementTarget edge memento nodesDescription edgesDescription configuration diagram |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new position: 80 @ 120; yourself.
	target := CPUserTaskDesignNode new position: 280 @ 120; yourself.
	replacementTarget := CPEndEventDesignNode new position: 480 @ 120; yourself.
	edge := CPProcessDesignEdge new sourceNode: source; targetNode: target; yourself.
	process
		nodes: (OrderedCollection with: source with: target with: replacementTarget);
		edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	diagram := CPProcessDiagramElement new
		connectNodeOperationFor: [ :aSource :aTarget | configuration connectOperationFrom: aSource to: aTarget in: memento ];
		reconnectEdgeOperationFor: [ :anEdge :aSource :aTarget | configuration reconnectOperationFor: anEdge from: aSource to: aTarget in: memento ];
		memento: memento.

	diagram beginConnectionFrom: source.
	diagram beginReconnectTargetOf: edge.
	diagram completeReconnectionTo: replacementTarget.

	self assert: (memento readUsing: edgesDescription) size equals: 1.
	self assert: (diagram stagedTargetOf: edge) == replacementTarget.
	self assert: edge targetNode == target.
	^ diagram
]

{ #category : 'examples - diagram' }
CPProcessDiagramExamples >> escapeStyleCancellationPreservesSelectionBeforeClearingIt [
	<gtExample>
	| process source target memento nodesDescription edgesDescription configuration diagram |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new position: 80 @ 120; yourself.
	target := CPEndEventDesignNode new position: 300 @ 120; yourself.
	process
		nodes: (OrderedCollection with: source with: target);
		edges: OrderedCollection new.
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	diagram := CPProcessDiagramElement new
		connectNodeOperationFor: [ :aSource :aTarget | configuration connectOperationFrom: aSource to: aTarget in: memento ];
		memento: memento.

	diagram selectNode: target.
	diagram beginConnectionFrom: source.
	diagram cancelInteraction.
	self assert: (diagram nodeElementFor: target) border width equals: 2.5.

	diagram cancelInteraction.
	self assert: (diagram nodeElementFor: target) border width equals: 1.5.
	^ diagram
]
