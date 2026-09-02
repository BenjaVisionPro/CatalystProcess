"I pressure-test Atelier removal against BPM's real remove-node semantic: removing a node also removes every incident edge while preserving unrelated graph structure."
Class {
	#name : 'CPAtelierRemoveNodeExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Atelier-Examples',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - assessment' }
CPAtelierRemoveNodeExamples >> assessmentDoesNotMutateStagedOrModelStructure [
	<gtExample>
	| fixture process memento middle nodesDescription edgesDescription operation assessment |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	middle := fixture fourth.
	nodesDescription := self nodesDescriptionIn: memento.
	edgesDescription := self edgesDescriptionIn: memento.
	operation := self remove: middle memento: memento nodes: nodesDescription edges: edgesDescription.

	assessment := operation assess.

	self assert: assessment isApplicable.
	self assert: assessment removedEdges size equals: 2.
	self assert: assessment proposedNodes size equals: 2.
	self assert: assessment proposedEdges size equals: 1.
	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 3.
	self assert: (memento readUsing: nodesDescription) size equals: 3.
	self assert: (memento readUsing: edgesDescription) size equals: 3.
	^ assessment
]

{ #category : 'examples - transaction' }
CPAtelierRemoveNodeExamples >> applyStagesNodeAndIncidentEdgeRemoval [
	<gtExample>
	| fixture process memento middle unrelatedEdge nodesDescription edgesDescription assessment |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	middle := fixture fourth.
	unrelatedEdge := fixture eighth.
	nodesDescription := self nodesDescriptionIn: memento.
	edgesDescription := self edgesDescriptionIn: memento.

	assessment := (self remove: middle memento: memento nodes: nodesDescription edges: edgesDescription) apply.

	self assert: assessment isApplicable.
	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 3.
	self assert: ((memento readUsing: nodesDescription) anySatisfy: [ :each | each == middle ]) not.
	self assert: (memento readUsing: edgesDescription) size equals: 1.
	self assert: (memento readUsing: edgesDescription) first == unrelatedEdge.
	^ memento
]

{ #category : 'examples - transaction' }
CPAtelierRemoveNodeExamples >> commitAppliesWholeRemovalAndPreservesUnrelatedEdgeIdentity [
	<gtExample>
	| fixture process memento middle unrelatedEdge nodesDescription edgesDescription |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	middle := fixture fourth.
	unrelatedEdge := fixture eighth.
	nodesDescription := self nodesDescriptionIn: memento.
	edgesDescription := self edgesDescriptionIn: memento.

	self assert: (self remove: middle memento: memento nodes: nodesDescription edges: edgesDescription) apply isApplicable.
	memento commit.

	self assert: process nodes size equals: 2.
	self assert: (process nodes anySatisfy: [ :each | each == middle ]) not.
	self assert: process edges size equals: 1.
	self assert: process edges first == unrelatedEdge.
	^ process
]

{ #category : 'examples - transaction' }
CPAtelierRemoveNodeExamples >> resetRestoresStagedNodeAndEdges [
	<gtExample>
	| fixture process memento middle nodesDescription edgesDescription |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	middle := fixture fourth.
	nodesDescription := self nodesDescriptionIn: memento.
	edgesDescription := self edgesDescriptionIn: memento.

	self assert: (self remove: middle memento: memento nodes: nodesDescription edges: edgesDescription) apply isApplicable.
	memento reset.

	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 3.
	self assert: (memento readUsing: nodesDescription) size equals: 3.
	self assert: (memento readUsing: edgesDescription) size equals: 3.
	^ memento
]

{ #category : 'examples - assessment' }
CPAtelierRemoveNodeExamples >> applyReassessesNewIncidentEdgeAddedAfterHover [
	<gtExample>
	| fixture memento first middle nodesDescription edgesDescription operation hoverAssessment newEdge stagedEdges applyAssessment |
	fixture := self fixture.
	memento := fixture second.
	first := fixture third.
	middle := fixture fourth.
	nodesDescription := self nodesDescriptionIn: memento.
	edgesDescription := self edgesDescriptionIn: memento.
	operation := self remove: middle memento: memento nodes: nodesDescription edges: edgesDescription.

	hoverAssessment := operation assess.
	self assert: hoverAssessment isApplicable.
	self assert: hoverAssessment removedEdges size equals: 2.

	newEdge := CPProcessDesignEdge new
		sourceNode: middle;
		targetNode: first;
		yourself.
	stagedEdges := (memento readUsing: edgesDescription) copyWith: newEdge.
	memento write: stagedEdges using: edgesDescription.

	applyAssessment := operation apply.
	self assert: applyAssessment isApplicable.
	self assert: applyAssessment removedEdges size equals: 3.
	self assert: (memento readUsing: edgesDescription) size equals: 1.
	self assert: ((memento readUsing: edgesDescription) anySatisfy: [ :each | each == newEdge ]) not.
	^ applyAssessment
]

{ #category : 'private' }
CPAtelierRemoveNodeExamples >> edgeFrom: source to: target [
	^ CPProcessDesignEdge new
		sourceNode: source;
		targetNode: target;
		yourself
]

{ #category : 'private' }
CPAtelierRemoveNodeExamples >> edgesDescriptionIn: aMemento [
	^ aMemento magritteDescription
		detect: [ :each | each handlesSelector: #edges ]
]

{ #category : 'private' }
CPAtelierRemoveNodeExamples >> fixture [
	| process first middle last firstToMiddle middleToLast firstToLast memento |
	process := CPProcessDesign new.
	first := CPUserTaskDesignNode new.
	middle := CPServiceTaskDesignNode new.
	last := CPUserTaskDesignNode new.
	firstToMiddle := self edgeFrom: first to: middle.
	middleToLast := self edgeFrom: middle to: last.
	firstToLast := self edgeFrom: first to: last.
	process
		nodes: (OrderedCollection with: first with: middle with: last);
		edges: (OrderedCollection with: firstToMiddle with: middleToLast with: firstToLast).
	memento := CFMaMemento model: process.
	^ { process. memento. first. middle. last. firstToMiddle. middleToLast. firstToLast }
]

{ #category : 'private' }
CPAtelierRemoveNodeExamples >> nodesDescriptionIn: aMemento [
	^ aMemento magritteDescription
		detect: [ :each | each handlesSelector: #nodes ]
]

{ #category : 'private' }
CPAtelierRemoveNodeExamples >> remove: aNode memento: aMemento nodes: nodesDescription edges: edgesDescription [
	^ CPAtelierRemoveNode
		node: aNode
		processMemento: aMemento
		nodesDescription: nodesDescription
		edgesDescription: edgesDescription
]
