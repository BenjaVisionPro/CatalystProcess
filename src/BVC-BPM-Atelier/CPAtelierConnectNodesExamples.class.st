"I pressure-test Foundation Atelier's orchestration boundary against a concrete BPM connection scenario: connecting two existing process nodes with a fresh edge."
Class {
	#name : 'CPAtelierConnectNodesExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Atelier-Examples',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - assessment' }
CPAtelierConnectNodesExamples >> assessmentDoesNotMutateDesignEditingStateOrFreshEdge [
	<gtExample>
	| fixture process memento source target edge operation assessment edgesDescription |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	source := fixture third.
	target := fixture fourth.
	edge := fixture fifth.
	edgesDescription := self edgesDescriptionIn: memento.
	operation := self connect: edge from: source to: target memento: memento.

	assessment := operation assess.

	self assert: assessment isApplicable.
	self assert: process edges isEmpty.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	self assert: edge sourceNode isNil.
	self assert: edge targetNode isNil.
	self assert: assessment proposedEdges size equals: 1.
	self assert: assessment proposedEdges first == edge.
	self assert: assessment sourceNode == source.
	self assert: assessment targetNode == target.
	^ assessment
]

{ #category : 'examples - transaction' }
CPAtelierConnectNodesExamples >> applyInitializesFreshEdgeAndStagesInsertion [
	<gtExample>
	| fixture process memento source target edge operation assessment edgesDescription |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	source := fixture third.
	target := fixture fourth.
	edge := fixture fifth.
	edgesDescription := self edgesDescriptionIn: memento.
	operation := self connect: edge from: source to: target memento: memento.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: edge sourceNode == source.
	self assert: edge targetNode == target.
	self assert: process edges isEmpty.
	self assert: (memento readUsing: edgesDescription) size equals: 1.
	self assert: (memento readUsing: edgesDescription) first == edge.
	^ memento
]

{ #category : 'examples - transaction' }
CPAtelierConnectNodesExamples >> commitIntroducesSameEdgeIdentity [
	<gtExample>
	| fixture process memento source target edge operation |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	source := fixture third.
	target := fixture fourth.
	edge := fixture fifth.
	operation := self connect: edge from: source to: target memento: memento.

	self assert: operation apply isApplicable.
	memento commit.

	self assert: process edges size equals: 1.
	self assert: process edges first == edge.
	self assert: process edges first sourceNode == source.
	self assert: process edges first targetNode == target.
	^ process
]

{ #category : 'examples - assessment' }
CPAtelierConnectNodesExamples >> applyReassessesCurrentStagedNodes [
	<gtExample>
	| fixture memento source target edge operation hoverAssessment nodesDescription stagedNodes applyAssessment edgesDescription |
	fixture := self fixture.
	memento := fixture second.
	source := fixture third.
	target := fixture fourth.
	edge := fixture fifth.
	nodesDescription := self nodesDescriptionIn: memento.
	edgesDescription := self edgesDescriptionIn: memento.
	operation := self connect: edge from: source to: target memento: memento.

	hoverAssessment := operation assess.
	self assert: hoverAssessment isApplicable.

	stagedNodes := (memento readUsing: nodesDescription)
		reject: [ :each | each == target ].
	memento write: stagedNodes using: nodesDescription.

	applyAssessment := operation apply.
	self assert: applyAssessment isApplicable not.
	self assert: applyAssessment rejectionMessage equals: 'The target node is not present in the process.'.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	self assert: edge sourceNode isNil.
	self assert: edge targetNode isNil.
	^ applyAssessment
]

{ #category : 'examples - transaction' }
CPAtelierConnectNodesExamples >> resetRemovesStagedInsertionWhileFreshInitializationRemainsDisposable [
	<gtExample>
	| fixture process memento source target edge operation edgesDescription |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	source := fixture third.
	target := fixture fourth.
	edge := fixture fifth.
	edgesDescription := self edgesDescriptionIn: memento.
	operation := self connect: edge from: source to: target memento: memento.

	self assert: operation apply isApplicable.
	self assert: edge sourceNode == source.
	self assert: edge targetNode == target.
	memento reset.

	self assert: process edges isEmpty.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	self assert: edge sourceNode == source.
	self assert: edge targetNode == target.
	^ edge
]

{ #category : 'private' }
CPAtelierConnectNodesExamples >> connect: anEdge from: aSourceNode to: aTargetNode memento: aMemento [
	^ CPAtelierConnectNodes
		edge: anEdge
		sourceNode: aSourceNode
		targetNode: aTargetNode
		processMemento: aMemento
		nodesDescription: (self nodesDescriptionIn: aMemento)
		edgesDescription: (self edgesDescriptionIn: aMemento)
		sourceNodeDescription: (self sourceNodeDescriptionFor: anEdge)
		targetNodeDescription: (self targetNodeDescriptionFor: anEdge)
]

{ #category : 'private' }
CPAtelierConnectNodesExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription
		detect: [ :each | each handlesSelector: aSelector ]
]

{ #category : 'private' }
CPAtelierConnectNodesExamples >> descriptionFor: aSelector on: anObject [
	^ anObject magritteDescription
		detect: [ :each | each handlesSelector: aSelector ]
]

{ #category : 'private' }
CPAtelierConnectNodesExamples >> edgesDescriptionIn: aMemento [
	^ self descriptionFor: #edges in: aMemento
]

{ #category : 'private' }
CPAtelierConnectNodesExamples >> fixture [
	| process source target memento edge |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new.
	target := CPUserTaskDesignNode new.
	process nodes: (OrderedCollection with: source with: target).
	memento := CFMaMemento model: process.
	edge := CPProcessDesignEdge new.
	^ { process. memento. source. target. edge }
]

{ #category : 'private' }
CPAtelierConnectNodesExamples >> nodesDescriptionIn: aMemento [
	^ self descriptionFor: #nodes in: aMemento
]

{ #category : 'private' }
CPAtelierConnectNodesExamples >> sourceNodeDescriptionFor: anEdge [
	^ self descriptionFor: #sourceNode on: anEdge
]

{ #category : 'private' }
CPAtelierConnectNodesExamples >> targetNodeDescriptionFor: anEdge [
	^ self descriptionFor: #targetNode on: anEdge
]
