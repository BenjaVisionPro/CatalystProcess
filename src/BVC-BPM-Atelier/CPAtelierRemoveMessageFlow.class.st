"I stage removal of one MessageFlow and its Collaboration DI edge."
Class {
	#name : 'CPAtelierRemoveMessageFlow',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'messageFlow',
		'processMemento'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveMessageFlow class >> messageFlow: aMessageFlow processMemento: aMemento [
	^ self new
		messageFlow: aMessageFlow;
		processMemento: aMemento;
		yourself
]

{ #category : 'assessing' }
CPAtelierRemoveMessageFlow >> assess [
	| context diagramContext proposedMessageFlows removedDiagramElements proposedElements |
	messageFlow ifNil: [
		^ CPAtelierRemoveMessageFlowAssessment rejectedBecause: 'A MessageFlow is required.' ].
	context := CPProcessCollaborationContext inRootMemento: processMemento.
	context ifNil: [
		^ CPAtelierRemoveMessageFlowAssessment rejectedBecause: 'The Process has no staged definitional Collaboration.' ].
	(context messageFlows identityIncludes: messageFlow) ifFalse: [
		^ CPAtelierRemoveMessageFlowAssessment rejectedBecause: 'The MessageFlow is not present in the staged Collaboration.' ].

	proposedMessageFlows := context messageFlows species withAll:
		(context messageFlows reject: [ :each | each == messageFlow ]).
	diagramContext := CPDiagramMementoContext
		diagram: context diagram
		memento: context diagramMemento
		elementsDescription: context elementsDescription.
	removedDiagramElements := context elements select: [ :each |
		(diagramContext modelElementOf: each) == messageFlow ].
	proposedElements := context elements species withAll:
		(context elements reject: [ :each | removedDiagramElements identityIncludes: each ]).

	[ context messageFlowsDescription validate: proposedMessageFlows ]
		on: MAValidationError do: [ :anException |
			^ CPAtelierRemoveMessageFlowAssessment rejectedBecause: anException printString ].
	[ context elementsDescription validate: proposedElements ]
		on: MAValidationError do: [ :anException |
			^ CPAtelierRemoveMessageFlowAssessment rejectedBecause: anException printString ].

	^ CPAtelierRemoveMessageFlowAssessment
		messageFlow: messageFlow
		proposedMessageFlows: proposedMessageFlows
		proposedDiagramElements: proposedElements
		removedDiagramElements: removedDiagramElements
]

{ #category : 'applying' }
CPAtelierRemoveMessageFlow >> applyAssessment: anAssessment [
	| context |
	context := CPProcessCollaborationContext inRootMemento: processMemento.
	context collaborationMemento
		write: anAssessment proposedMessageFlows
		using: context messageFlowsDescription.
	context diagramMemento
		write: anAssessment proposedDiagramElements
		using: context elementsDescription.
	context collaborationMemento
		detachChildMementoFor: messageFlow
		inRelation: context messageFlowsDescription.
	anAssessment removedDiagramElements do: [ :anElement |
		context diagramMemento
			detachChildMementoFor: anElement
			inRelation: context elementsDescription ]
]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlow >> messageFlow: anObject [
	messageFlow := anObject
]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlow >> processMemento: anObject [
	processMemento := anObject
]
