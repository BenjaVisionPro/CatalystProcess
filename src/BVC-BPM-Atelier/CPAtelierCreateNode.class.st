"I coordinate one BPM editing intention: introduce a fresh CPProcessDesignNode into a CPProcessDesign at a requested persistent position.

The fresh node is supplied by the BPM client; I do not own construction policy or palettes. Assessment reads the current staged nodes collection, derives and validates the complete proposed relation value, and does not mutate either the process or the fresh candidate. apply reassesses immediately before execution, initializes the still-disposable fresh node, then stages one ordinary Magritte relation write.

I intentionally do not define a generic Atelier creation/factory abstraction."
Class {
	#name : 'CPAtelierCreateNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'node',
		'position',
		'processMemento',
		'nodesDescription',
		'insertionIndex'
	],
	#category : 'BVC-BPM-Atelier-Creation',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Creation'
}

{ #category : 'instance creation' }
CPAtelierCreateNode class >> node: aNode position: aPoint processMemento: aMemento nodesDescription: aDescription [
	^ self new
		node: aNode;
		position: aPoint;
		processMemento: aMemento;
		nodesDescription: aDescription;
		yourself
]

{ #category : 'instance creation' }
CPAtelierCreateNode class >> node: aNode position: aPoint processMemento: aMemento nodesDescription: aDescription at: anIndex [
	^ self new
		node: aNode;
		position: aPoint;
		processMemento: aMemento;
		nodesDescription: aDescription;
		insertionIndex: anIndex;
		yourself
]

{ #category : 'assessing' }
CPAtelierCreateNode >> assess [
	| nodes proposedNodes effectiveIndex |
	nodes := processMemento readUsing: nodesDescription.

	node ifNil: [ ^ self rejectedWithNodes: nodes because: 'A fresh process node is required.' ].
	(node isKindOf: CPProcessDesignNode)
		ifFalse: [ ^ self rejectedWithNodes: nodes because: 'The candidate is not a process design node.' ].
	nodesDescription isReadOnly
		ifTrue: [ ^ self rejectedWithNodes: nodes because: 'The process nodes relation is read-only.' ].
	nodes ifNil: [ ^ self rejectedWithNodes: nodes because: 'The process nodes relation has no collection value.' ].
	nodesDescription isMultiple
		ifFalse: [ ^ self rejectedWithNodes: nodes because: 'Process nodes must be represented by a to-many relation description.' ].
	(nodes anySatisfy: [ :each | each == node ])
		ifTrue: [ ^ self rejectedWithNodes: nodes because: 'The candidate node is already present in the process.' ].

	nodesDescription isOrdered
		ifTrue: [
			insertionIndex ifNil: [ effectiveIndex := nodes size + 1 ] ifNotNil: [
				(insertionIndex between: 1 and: nodes size + 1)
					ifFalse: [ ^ self rejectedWithNodes: nodes because: 'The insertion index is outside the process nodes relation.' ].
				effectiveIndex := insertionIndex ] ]
		ifFalse: [
			insertionIndex ifNotNil: [ ^ self rejectedWithNodes: nodes because: 'An unordered process nodes relation does not accept an insertion index.' ].
			effectiveIndex := nodes size + 1 ].

	proposedNodes := nodes species withAll: nodes.
	proposedNodes add: node beforeIndex: effectiveIndex.

	[ nodesDescription validate: proposedNodes ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedWithNodes: nodes because: anException printString ].

	^ CPAtelierCreateNodeAssessment
		nodes: nodes
		proposedNodes: proposedNodes
		node: node
		position: position
]

{ #category : 'applying' }
CPAtelierCreateNode >> applyAssessment: anAssessment [
	position ifNotNil: [ node position: position ].
	processMemento
		write: anAssessment proposedNodes
		using: nodesDescription
]

{ #category : 'accessing' }
CPAtelierCreateNode >> node [ ^ node ]
{ #category : 'accessing' }
CPAtelierCreateNode >> node: anObject [ node := anObject ]
{ #category : 'accessing' }
CPAtelierCreateNode >> nodesDescription [ ^ nodesDescription ]
{ #category : 'accessing' }
CPAtelierCreateNode >> nodesDescription: aDescription [ nodesDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierCreateNode >> position [ ^ position ]
{ #category : 'accessing' }
CPAtelierCreateNode >> position: aPoint [ position := aPoint ]
{ #category : 'accessing' }
CPAtelierCreateNode >> processMemento [ ^ processMemento ]
{ #category : 'accessing' }
CPAtelierCreateNode >> processMemento: aMemento [ processMemento := aMemento ]

{ #category : 'accessing' }
CPAtelierCreateNode >> insertionIndex [ ^ insertionIndex ]
{ #category : 'accessing' }
CPAtelierCreateNode >> insertionIndex: anInteger [ insertionIndex := anInteger ]

{ #category : 'private' }
CPAtelierCreateNode >> rejectedWithNodes: nodes because: aString [
	^ CPAtelierCreateNodeAssessment
		nodes: nodes
		node: node
		position: position
		rejectedBecause: aString
]
