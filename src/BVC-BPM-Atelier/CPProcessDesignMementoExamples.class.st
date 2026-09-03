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
