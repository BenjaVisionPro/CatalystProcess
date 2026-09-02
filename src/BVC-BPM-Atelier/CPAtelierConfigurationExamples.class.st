"I prove that BPM installs its semantic node-removal operation through Atelier configuration without changing Atelier or Foundation presentation code."
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
