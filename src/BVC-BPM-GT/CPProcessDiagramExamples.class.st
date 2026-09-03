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
	| process start task finish firstEdge secondEdge memento viewModel element diagram |
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
	element := CFMaFormRootElement new.
	viewModel initializeForm: element forMemento: memento.
	diagram := element
		allChildrenBreadthFirstDetect: [ :each | each isKindOf: CPProcessDiagramElement ]
		ifFound: [ :each | each ]
		ifNone: [ nil ].
	self assert: element class equals: CFMaFormRootElement.
	self assert: diagram isNotNil.
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
