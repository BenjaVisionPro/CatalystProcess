Class {
	#name : 'CPProcessDesignMementoExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Atelier-Examples',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - lifecycle' }
CPProcessDesignMementoExamples >> changedCommitAdvancesUpdatedAt [
	<gtExample>
	| process marker memento nodesDescription node operation assessment |
	process := CPProcessDesign new.
	marker := Object new.
	process updatedAt: marker.
	memento := CPProcessDesignMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	node := CPUserTaskDesignNode new.
	operation := CPAtelierCreateNode
		node: node
		position: 120@80
		processMemento: memento
		nodesDescription: nodesDescription.
	assessment := operation apply.
	self assert: assessment isApplicable.
	self assert: process updatedAt == marker.
	memento commit.
	self assert: process updatedAt ~~ marker.
	self assert: process updatedAt class equals: DateAndTime.
	self assert: process nodes first == node.
	^ memento
]

{ #category : 'examples - lifecycle' }
CPProcessDesignMementoExamples >> unchangedCommitPreservesUpdatedAt [
	<gtExample>
	| process marker memento |
	process := CPProcessDesign new.
	memento := CPProcessDesignMemento model: process.
	memento commit.
	marker := process updatedAt.
	memento commit.
	self assert: process updatedAt == marker.
	^ memento
]

{ #category : 'examples - lifecycle' }
CPProcessDesignMementoExamples >> resetPreservesUpdatedAt [
	<gtExample>
	| process marker memento nodesDescription node operation assessment |
	process := CPProcessDesign new.
	marker := Object new.
	process updatedAt: marker.
	memento := CPProcessDesignMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	node := CPUserTaskDesignNode new.
	operation := CPAtelierCreateNode
		node: node
		position: 120@80
		processMemento: memento
		nodesDescription: nodesDescription.
	assessment := operation apply.
	self assert: assessment isApplicable.
	memento reset.
	self assert: process updatedAt == marker.
	self assert: process nodes isEmpty.
	^ memento
]

{ #category : 'examples - lifecycle' }
CPProcessDesignMementoExamples >> compoundAtelierEditingResetRestoresWholeProcessTransaction [
	<gtExample>
	| process start task finish edge1 edge2 marker memento configuration newNode newEdge nodesDescription edgesDescription assessment |
	process := CPProcessDesign new.
	start := CPStartEventDesignNode new position: 60 @ 170; yourself.
	task := CPUserTaskDesignNode new position: 250 @ 164; yourself.
	finish := CPEndEventDesignNode new position: 470 @ 170; yourself.
	edge1 := CPProcessDesignEdge new sourceNode: start; targetNode: task; yourself.
	edge2 := CPProcessDesignEdge new sourceNode: task; targetNode: finish; yourself.
	process nodes: (OrderedCollection with: start with: task with: finish); edges: (OrderedCollection with: edge1 with: edge2).
	marker := Object new.
	process updatedAt: marker.

	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	nodesDescription := configuration nodesDescription.
	edgesDescription := configuration edgesDescription.
	newNode := CPServiceTaskDesignNode new.

	assessment := (configuration createNodeOperationFor: newNode at: 360 @ 90 in: memento) apply.
	self assert: assessment isApplicable.
	assessment := (configuration positionNodeOperationFor: task at: 260 @ 230 in: memento) apply.
	self assert: assessment isApplicable.
	newEdge := CPProcessDesignEdge new.
	assessment := (configuration connectOperationFor: newEdge from: newNode to: finish in: memento) apply.
	self assert: assessment isApplicable.
	assessment := (configuration reconnectOperationFor: edge1 from: start to: newNode in: memento) apply.
	self assert: assessment isApplicable.
	assessment := (configuration removeEdgeOperationFor: edge2 in: memento) apply.
	self assert: assessment isApplicable.

	self assert: (memento readUsing: nodesDescription) size equals: 4.
	self assert: (memento readUsing: edgesDescription) size equals: 2.
	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 2.
	self assert: task position equals: 250 @ 164.
	self assert: edge1 targetNode == task.
	self assert: process updatedAt == marker.

	memento reset.

	self assert: (memento readUsing: nodesDescription) size equals: 3.
	self assert: (memento readUsing: edgesDescription) size equals: 2.
	self assert: ((memento readUsing: nodesDescription) anySatisfy: [ :each | each == newNode ]) not.
	self assert: ((memento readUsing: edgesDescription) anySatisfy: [ :each | each == newEdge ]) not.
	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 2.
	self assert: task position equals: 250 @ 164.
	self assert: edge1 targetNode == task.
	self assert: process updatedAt == marker.
	^ memento
]

{ #category : 'examples - lifecycle' }
CPProcessDesignMementoExamples >> compoundAtelierEditingCommitAppliesWholeProcessTransaction [
	<gtExample>
	| process start task finish edge1 edge2 marker memento configuration newNode newEdge nodesDescription edgesDescription assessment |
	process := CPProcessDesign new.
	start := CPStartEventDesignNode new position: 60 @ 170; yourself.
	task := CPUserTaskDesignNode new position: 250 @ 164; yourself.
	finish := CPEndEventDesignNode new position: 470 @ 170; yourself.
	edge1 := CPProcessDesignEdge new sourceNode: start; targetNode: task; yourself.
	edge2 := CPProcessDesignEdge new sourceNode: task; targetNode: finish; yourself.
	process nodes: (OrderedCollection with: start with: task with: finish); edges: (OrderedCollection with: edge1 with: edge2).
	marker := Object new.
	process updatedAt: marker.

	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	nodesDescription := configuration nodesDescription.
	edgesDescription := configuration edgesDescription.
	newNode := CPServiceTaskDesignNode new.

	assessment := (configuration createNodeOperationFor: newNode at: 360 @ 90 in: memento) apply.
	self assert: assessment isApplicable.
	assessment := (configuration positionNodeOperationFor: task at: 260 @ 230 in: memento) apply.
	self assert: assessment isApplicable.
	newEdge := CPProcessDesignEdge new.
	assessment := (configuration connectOperationFor: newEdge from: newNode to: finish in: memento) apply.
	self assert: assessment isApplicable.
	assessment := (configuration reconnectOperationFor: edge1 from: start to: newNode in: memento) apply.
	self assert: assessment isApplicable.
	assessment := (configuration removeEdgeOperationFor: edge2 in: memento) apply.
	self assert: assessment isApplicable.

	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 2.
	self assert: process updatedAt == marker.
	memento commit.

	self assert: process nodes size equals: 4.
	self assert: process edges size equals: 2.
	self assert: (process nodes anySatisfy: [ :each | each == newNode ]).
	self assert: (process edges anySatisfy: [ :each | each == newEdge ]).
	self assert: (process edges anySatisfy: [ :each | each == edge2 ]) not.
	self assert: task position equals: 260 @ 230.
	self assert: edge1 sourceNode == start.
	self assert: edge1 targetNode == newNode.
	self assert: newEdge sourceNode == newNode.
	self assert: newEdge targetNode == finish.
	self assert: process updatedAt ~~ marker.
	self assert: process updatedAt class equals: DateAndTime.
	self assert: (memento readUsing: nodesDescription) size equals: 4.
	self assert: (memento readUsing: edgesDescription) size equals: 2.
	^ memento
]


{ #category : 'examples - lifecycle' }
CPProcessDesignMementoExamples >> embeddedObjectsUseFoundationChildMementos [
	<gtExample>
	| process node memento nodesDescription childMemento |
	process := CPProcessDesign new.
	node := CPUserTaskDesignNode new.
	process nodes: (OrderedCollection with: node).
	memento := CPProcessDesignMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	childMemento := memento childMementoFor: node inRelation: nodesDescription.
	self assert: childMemento class equals: CFMaMemento.
	self assert: childMemento model == node.
	^ childMemento
]
