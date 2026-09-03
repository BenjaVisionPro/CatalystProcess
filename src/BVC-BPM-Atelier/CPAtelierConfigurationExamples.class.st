"I prove that BPM installs its proven domain editing intentions through Atelier configuration without changing Atelier or Foundation presentation code. Node insertion and removal translate at the exact process relations; connection creation remains an explicit BPM intention because its source and target endpoints come from the BPM interaction rather than generic relation insertion."
Class {
	#name : 'CPAtelierConfigurationExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Atelier-Examples',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> nodeRemovalUsesProcessSemanticOperation [
	<gtExample>
	| process node other edge memento nodesDescription edgesDescription configuration context operation assessment |
	process := CPProcessDesign new.
	node := CPUserTaskDesignNode new.
	other := CPServiceTaskDesignNode new.
	edge := CPProcessDesignEdge new
		sourceNode: node;
		targetNode: other;
		yourself.
	process
		nodes: (OrderedCollection with: node with: other);
		edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration
		nodesDescription: nodesDescription
		edgesDescription: edgesDescription.
	context := CFAtelierRelationDragContext
		memento: memento
		description: nodesDescription.

	operation := configuration removeOperationFor: { node } from: context.
	assessment := operation assess.

	self assert: operation class equals: CPAtelierRemoveNode.
	self assert: assessment isApplicable.
	self assert: assessment removedEdges size equals: 1.
	self assert: process nodes size equals: 2.
	self assert: process edges size equals: 1.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> otherRelationRemovalKeepsGenericAtelierSemantics [
	<gtExample>
	| process edge memento nodesDescription edgesDescription configuration context operation assessment |
	process := CPProcessDesign new.
	edge := CPProcessDesignEdge new.
	process edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration
		nodesDescription: nodesDescription
		edgesDescription: edgesDescription.
	context := CFAtelierRelationDragContext
		memento: memento
		description: edgesDescription.

	operation := configuration removeOperationFor: { edge } from: context.
	assessment := operation assess.

	self assert: operation class equals: CFAtelierRemove.
	self assert: assessment isApplicable.
	self assert: process edges size equals: 1.
	self assert: (memento readUsing: edgesDescription) size equals: 1.
	^ operation
]


{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> multiNodeRemovalUsesOneProcessSemanticOperation [
	<gtExample>
	| process first second third firstEdge secondEdge memento nodesDescription edgesDescription configuration context operation assessment |
	process := CPProcessDesign new.
	first := CPUserTaskDesignNode new.
	second := CPServiceTaskDesignNode new.
	third := CPUserTaskDesignNode new.
	firstEdge := CPProcessDesignEdge new sourceNode: first; targetNode: second; yourself.
	secondEdge := CPProcessDesignEdge new sourceNode: second; targetNode: third; yourself.
	process
		nodes: (OrderedCollection with: first with: second with: third);
		edges: (OrderedCollection with: firstEdge with: secondEdge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	context := CFAtelierRelationDragContext memento: memento description: nodesDescription.

	operation := configuration removeOperationFor: { first. third } from: context.
	assessment := operation apply.

	self assert: operation class equals: CPAtelierRemoveNodes.
	self assert: assessment isApplicable.
	self assert: assessment removedEdges size equals: 2.
	self assert: (memento readUsing: nodesDescription) size equals: 1.
	self assert: (memento readUsing: nodesDescription) first == second.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 2.
	^ operation
]


{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> nodeInsertionUsesProcessCreateOperation [
	<gtExample>
	| process first candidate memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	first := CPUserTaskDesignNode new.
	candidate := CPServiceTaskDesignNode new position: 240@120; yourself.
	process nodes: (OrderedCollection with: first).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		insertOperationFor: candidate
		into: memento
		description: nodesDescription
		at: nil.
	assessment := operation apply.

	self assert: operation class equals: CPAtelierCreateNode.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: nodesDescription) first == first.
	self assert: (memento readUsing: nodesDescription) second == candidate.
	self assert: candidate position equals: 240@120.
	self assert: process nodes size equals: 1.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> nonNodeInsertionKeepsGenericAtelierSemantics [
	<gtExample>
	| process edge memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	edge := CPProcessDesignEdge new.
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		insertOperationFor: edge
		into: memento
		description: edgesDescription
		at: nil.
	assessment := operation assess.

	self assert: operation class equals: CFAtelierInsert.
	self assert: assessment isApplicable.
	self assert: process edges isEmpty.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	^ operation
]


{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> connectionUsesProcessConnectOperation [
	<gtExample>
	| process source target edge memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new.
	target := CPUserTaskDesignNode new.
	edge := CPProcessDesignEdge new.
	process nodes: (OrderedCollection with: source with: target).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		connectOperationFor: edge
		from: source
		to: target
		in: memento.
	assessment := operation assess.

	self assert: operation class equals: CPAtelierConnectNodes.
	self assert: assessment isApplicable.
	self assert: operation edge == edge.
	self assert: operation sourceNode == source.
	self assert: operation targetNode == target.
	self assert: operation processMemento == memento.
	self assert: operation nodesDescription == nodesDescription.
	self assert: operation edgesDescription == edgesDescription.
	self assert: process edges isEmpty.
	self assert: edge sourceNode isNil.
	self assert: edge targetNode isNil.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> connectionApplyStagesOneProcessEdgeWithExactEndpoints [
	<gtExample>
	| process source target edge memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new.
	target := CPServiceTaskDesignNode new.
	edge := CPProcessDesignEdge new.
	process nodes: (OrderedCollection with: source with: target).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		connectOperationFor: edge
		from: source
		to: target
		in: memento.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: edgesDescription) size equals: 1.
	self assert: (memento readUsing: edgesDescription) first == edge.
	self assert: edge sourceNode == source.
	self assert: edge targetNode == target.
	self assert: process edges isEmpty.
	^ operation
]

{ #category : 'examples - entry' }
CPAtelierConfigurationExamples >> processAtelierEntryInstallsProcessPalette [
	<gtExample>
	| process atelier palette |
	process := CPProcessDesign new.
	atelier := process asAtelier.
	palette := atelier palette.

	self assert: palette items size equals: 6.
	self assert: palette items first label equals: 'Start event'.
	self assert: palette items second label equals: 'End event'.
	self assert: palette items third label equals: 'User task'.
	self assert: palette items fourth label equals: 'Service task'.
	self assert: palette items fifth label equals: 'Exclusive gateway'.
	self assert: palette items sixth label equals: 'Parallel gateway'.
	^ atelier
]

{ #category : 'examples - entry' }
CPAtelierConfigurationExamples >> processNodePaletteMaterializesFreshIdentities [
	<gtExample>
	| palette first second |
	palette := CPAtelierConfiguration processNodePalette.
	first := palette items third materialize.
	second := palette items third materialize.

	self assert: first class equals: CPUserTaskDesignNode.
	self assert: second class equals: CPUserTaskDesignNode.
	self assert: first ~~ second.
	^ palette
]

{ #category : 'examples - interactive' }
CPAtelierConfigurationExamples >> interactiveProcessAtelier [
	<gtExample>
	| process start task finish edge1 edge2 atelier element |
	process := CPProcessDesign new
		label: 'Interactive Atelier process';
		yourself.
	start := CPStartEventDesignNode new
		label: 'Start';
		yourself.
	task := CPUserTaskDesignNode new
		label: 'Review request';
		yourself.
	finish := CPEndEventDesignNode new
		label: 'Done';
		yourself.
	edge1 := CPProcessDesignEdge new
		label: 'Start to review';
		sourceNode: start;
		targetNode: task;
		yourself.
	edge2 := CPProcessDesignEdge new
		label: 'Review to done';
		sourceNode: task;
		targetNode: finish;
		yourself.
	process
		addNode: start;
		addNode: task;
		addNode: finish;
		addEdge: edge1;
		addEdge: edge2.

	atelier := process asAtelier.
	element := atelier asElement.

	self assert: atelier palette items size equals: 6.
	self assert: atelier memento model == process.
	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 2.
	^ element
]
