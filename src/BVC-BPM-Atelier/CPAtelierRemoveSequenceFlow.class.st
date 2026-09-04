"I stage removal of one CPSequenceFlow and its diagram depiction from a CPProcess transaction."
Class {
	#name : 'CPAtelierRemoveSequenceFlow',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'sequenceFlow',
		'processMemento',
		'flowElementsDescription',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveSequenceFlow class >> sequenceFlow: aSequenceFlow processMemento: aMemento flowElementsDescription: aFlowElementsDescription diagramDescription: aDiagramDescription [
	^ self new
		sequenceFlow: aSequenceFlow;
		processMemento: aMemento;
		flowElementsDescription: aFlowElementsDescription;
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierRemoveSequenceFlow >> assess [
	| flowElements proposedFlowElements diagram diagramMemento elementsDescription elements removedEdges proposedElements |
	sequenceFlow ifNil: [ ^ self rejectedBecause: 'A sequence flow is required.' ].
	flowElements := processMemento readUsing: flowElementsDescription.
	flowElements ifNil: [ ^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	(flowElements identityIncludes: sequenceFlow) ifFalse: [ ^ self rejectedBecause: 'The sequence flow does not belong to the staged process.' ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].
	removedEdges := elements select: [ :each | each isEdge and: [ each modelElement == sequenceFlow ] ].
	removedEdges isEmpty ifTrue: [ ^ self rejectedBecause: 'The sequence flow has no staged diagram edge.' ].

	proposedFlowElements := flowElements species withAll: (flowElements reject: [ :each | each == sequenceFlow ]).
	proposedElements := elements species withAll: (elements reject: [ :each | removedEdges identityIncludes: each ]).
	[ flowElementsDescription validate: proposedFlowElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	[ elementsDescription validate: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierRemoveSequenceFlowAssessment
		sequenceFlow: sequenceFlow
		proposedFlowElements: proposedFlowElements
		proposedDiagramElements: proposedElements
		removedEdges: removedEdges
]

{ #category : 'applying' }
CPAtelierRemoveSequenceFlow >> applyAssessment: anAssessment [
	| diagram diagramMemento elementsDescription |
	processMemento write: anAssessment proposedFlowElements using: flowElementsDescription.
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription detect: [ :each | each handlesSelector: #elements ].
	diagramMemento write: anAssessment proposedDiagramElements using: elementsDescription.
	processMemento detachChildMementoFor: sequenceFlow inRelation: flowElementsDescription.
	anAssessment removedEdges do: [ :anEdge |
		diagramMemento detachChildMementoFor: anEdge inRelation: elementsDescription ]
]

{ #category : 'private' }
CPAtelierRemoveSequenceFlow >> rejectedBecause: aString [
	^ CPAtelierRemoveSequenceFlowAssessment sequenceFlow: sequenceFlow rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierRemoveSequenceFlow >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlow >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlow >> flowElementsDescription: aDescription [ flowElementsDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlow >> diagramDescription: aDescription [ diagramDescription := aDescription ]
