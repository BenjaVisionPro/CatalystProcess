"I pressure-test Foundation Atelier's orchestration boundary against the first concrete BPM creation scenario: a fresh task node dropped onto a process design."
Class {
	#name : 'CPAtelierCreateNodeExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Atelier-Examples',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - assessment' }
CPAtelierCreateNodeExamples >> assessmentDoesNotMutateDesignEditingStateOrFreshNode [
	<gtExample>
	| fixture process memento node description operation assessment |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	node := fixture third.
	description := self nodesDescriptionIn: memento.
	operation := self create: node at: 120@80 memento: memento description: description.

	assessment := operation assess.

	self assert: assessment isApplicable.
	self assert: process nodes isEmpty.
	self assert: (memento readUsing: description) isEmpty.
	self assert: node position isNil.
	self assert: assessment proposedNodes size equals: 1.
	self assert: assessment proposedNodes first == node.
	self assert: assessment position equals: 120@80.
	^ assessment
]

{ #category : 'examples - transaction' }
CPAtelierCreateNodeExamples >> applyInitializesFreshNodeAndStagesInsertion [
	<gtExample>
	| fixture process memento node description operation assessment |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	node := fixture third.
	description := self nodesDescriptionIn: memento.
	operation := self create: node at: 120@80 memento: memento description: description.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: node position equals: 120@80.
	self assert: process nodes isEmpty.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: (memento readUsing: description) first == node.
	^ memento
]

{ #category : 'examples - transaction' }
CPAtelierCreateNodeExamples >> commitIntroducesSameNodeIdentity [
	<gtExample>
	| fixture process memento node description operation |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	node := fixture third.
	description := self nodesDescriptionIn: memento.
	operation := self create: node at: 120@80 memento: memento description: description.

	self assert: operation apply isApplicable.
	memento commit.

	self assert: process nodes size equals: 1.
	self assert: process nodes first == node.
	self assert: process nodes first position equals: 120@80.
	^ process
]

{ #category : 'examples - assessment' }
CPAtelierCreateNodeExamples >> applyReassessesCurrentStagedState [
	<gtExample>
	| fixture memento node description operation hoverAssessment stagedNodes applyAssessment |
	fixture := self fixture.
	memento := fixture second.
	node := fixture third.
	description := self nodesDescriptionIn: memento.
	operation := self create: node at: 120@80 memento: memento description: description.

	hoverAssessment := operation assess.
	self assert: hoverAssessment isApplicable.

	stagedNodes := (memento readUsing: description) copyWith: node.
	memento write: stagedNodes using: description.

	applyAssessment := operation apply.
	self assert: applyAssessment isApplicable not.
	self assert: applyAssessment rejectionMessage equals: 'The candidate node is already present in the process.'.
	self assert: (memento readUsing: description) size equals: 1.
	self assert: node position isNil.
	^ applyAssessment
]

{ #category : 'examples - transaction' }
CPAtelierCreateNodeExamples >> resetRemovesStagedInsertionWhileFreshInitializationRemainsDisposable [
	<gtExample>
	| fixture process memento node description operation |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	node := fixture third.
	description := self nodesDescriptionIn: memento.
	operation := self create: node at: 120@80 memento: memento description: description.

	self assert: operation apply isApplicable.
	self assert: node position equals: 120@80.
	memento reset.

	self assert: process nodes isEmpty.
	self assert: (memento readUsing: description) isEmpty.
	self assert: node position equals: 120@80.
	^ node
]

{ #category : 'private' }
CPAtelierCreateNodeExamples >> create: aNode at: aPoint memento: aMemento description: aDescription [
	^ CPAtelierCreateNode
		node: aNode
		position: aPoint
		processMemento: aMemento
		nodesDescription: aDescription
]

{ #category : 'private' }
CPAtelierCreateNodeExamples >> fixture [
	| process memento node |
	process := CPProcessDesign new.
	memento := CFMaMemento model: process.
	node := CPUserTaskDesignNode new.
	^ { process. memento. node }
]

{ #category : 'private' }
CPAtelierCreateNodeExamples >> nodesDescriptionIn: aMemento [
	^ aMemento magritteDescription
		detect: [ :each | each handlesSelector: #nodes ]
]

{ #category : 'examples - supply' }
CPAtelierCreateNodeExamples >> factoryProviderMaterializesCandidateBeforeOperation [
	<gtExample>
	| fixture process memento provider node description operation hoverAssessment applyAssessment |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	provider := CFAtelierFactoryProvider factory: [ CPUserTaskDesignNode new ].
	node := provider materialize.
	description := self nodesDescriptionIn: memento.
	operation := self create: node at: 120@80 memento: memento description: description.

	hoverAssessment := operation assess.
	self assert: hoverAssessment isApplicable.
	self assert: hoverAssessment node == node.

	applyAssessment := operation apply.
	self assert: applyAssessment isApplicable.
	self assert: applyAssessment node == node.
	self assert: (memento readUsing: description) first == node.
	self assert: process nodes isEmpty.
	^ applyAssessment
]
