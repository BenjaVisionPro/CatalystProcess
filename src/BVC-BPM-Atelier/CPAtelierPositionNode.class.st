"I coordinate one BPM diagram intention: reposition an existing process design node.

The process nodes relation establishes membership. Assessment reads the node's authoritative staged position when child editing state already exists, otherwise its model position, and validates the requested Point through the node's Magritte position description. Assessment does not create child editing state. Apply reassesses immediately before execution and stages the position through the node's child memento in the same Process transaction.

I am deliberately distinct from CFAtelierMove, which means structural movement between relations."
Class {
	#name : 'CPAtelierPositionNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'node',
		'position',
		'processMemento',
		'nodesDescription'
	],
	#category : 'BVC-BPM-Atelier-Positioning',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Positioning'
}

{ #category : 'instance creation' }
CPAtelierPositionNode class >> node: aNode position: aPoint processMemento: aMemento nodesDescription: aDescription [
	^ self new
		node: aNode;
		position: aPoint;
		processMemento: aMemento;
		nodesDescription: aDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierPositionNode >> assess [
	| nodes currentPosition positionDescription occurrences |
	nodes := processMemento readUsing: nodesDescription.
	node ifNil: [ ^ self rejectedWithCurrentPosition: nil because: 'A process node is required.' ].
	position ifNil: [ ^ self rejectedWithCurrentPosition: nil because: 'A diagram position is required.' ].
	nodes ifNil: [ ^ self rejectedWithCurrentPosition: nil because: 'The process nodes relation has no collection value.' ].
	occurrences := nodes count: [ :each | each == node ].
	occurrences = 1 ifFalse: [ ^ self rejectedWithCurrentPosition: nil because: 'The node must occur exactly once in the process.' ].

	currentPosition := self currentPosition.
	currentPosition = position ifTrue: [
		^ self rejectedWithCurrentPosition: currentPosition because: 'The node is already at the requested position.' ].
	positionDescription := node positionDescription.
	positionDescription isReadOnly ifTrue: [
		^ self rejectedWithCurrentPosition: currentPosition because: 'The node position is read-only.' ].
	[ positionDescription validate: position ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithCurrentPosition: currentPosition because: anException printString ].

	^ CPAtelierPositionNodeAssessment
		node: node
		currentPosition: currentPosition
		proposedPosition: position
]

{ #category : 'applying' }
CPAtelierPositionNode >> applyAssessment: anAssessment [
	(processMemento childMementoFor: node inRelation: nodesDescription)
		write: anAssessment proposedPosition
		using: node positionDescription
]

{ #category : 'private' }
CPAtelierPositionNode >> currentPosition [
	(processMemento hasChildMementoFor: node inRelation: nodesDescription)
		ifFalse: [ ^ node position ].
	^ (processMemento childMementoFor: node inRelation: nodesDescription)
		readUsing: node positionDescription
]

{ #category : 'private' }
CPAtelierPositionNode >> rejectedWithCurrentPosition: aPoint because: aString [
	^ CPAtelierPositionNodeAssessment
		node: node
		currentPosition: aPoint
		proposedPosition: position
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierPositionNode >> node [ ^ node ]
{ #category : 'accessing' }
CPAtelierPositionNode >> node: anObject [ node := anObject ]
{ #category : 'accessing' }
CPAtelierPositionNode >> position [ ^ position ]
{ #category : 'accessing' }
CPAtelierPositionNode >> position: aPoint [ position := aPoint ]
{ #category : 'accessing' }
CPAtelierPositionNode >> processMemento [ ^ processMemento ]
{ #category : 'accessing' }
CPAtelierPositionNode >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierPositionNode >> nodesDescription [ ^ nodesDescription ]
{ #category : 'accessing' }
CPAtelierPositionNode >> nodesDescription: aDescription [ nodesDescription := aDescription ]
