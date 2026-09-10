"I stage removal of one MessageFlow and its Collaboration DI edge."
Class {
	#name : 'CPAtelierRemoveMessageFlow',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'messageFlow',
		'processMemento',
		'collaborationContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveMessageFlow class >> messageFlow: aMessageFlow processMemento: aMemento [
	^ self messageFlow: aMessageFlow processMemento: aMemento collaborationContext: nil
]

{ #category : 'instance creation' }
CPAtelierRemoveMessageFlow class >> messageFlow: aMessageFlow processMemento: aMemento collaborationContext: aCollaborationContext [
	^ self new messageFlow: aMessageFlow; processMemento: aMemento; collaborationContext: aCollaborationContext; yourself
]

{ #category : 'assessing' }
CPAtelierRemoveMessageFlow >> assess [
	| context diagramContext proposedMessageFlows removedDiagramElements proposedElements |
	messageFlow ifNil: [
		^ CPAtelierRemoveMessageFlowAssessment rejectedBecause: 'A MessageFlow is required.' ].
	context := self stagedCollaborationContext.
	context ifNil: [
		^ CPAtelierRemoveMessageFlowAssessment rejectedBecause: 'The Process has no staged definitional Collaboration.' ].
	(context messageFlows identityIncludes: messageFlow) ifFalse: [
		^ CPAtelierRemoveMessageFlowAssessment rejectedBecause: 'The MessageFlow is not present in the staged Collaboration.' ].

	proposedMessageFlows := context messageFlows species withAll:
		(context messageFlows reject: [ :each | each == messageFlow ]).
	diagramContext := context diagramContext.
	removedDiagramElements := context elements select: [ :each |
		(diagramContext modelElementOf: each) == messageFlow ].
	proposedElements := context elements species withAll:
		(context elements reject: [ :each | removedDiagramElements identityIncludes: each ]).

	[ context messageFlowsDescription validate: proposedMessageFlows ]
		on: MAValidationError do: [ :anException |
			^ CPAtelierRemoveMessageFlowAssessment rejectedBecause: anException printString ].
	[ context diagramContext validateElements: proposedElements ]
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
	context := self stagedCollaborationContext.
	context collaborationMemento
		write: anAssessment proposedMessageFlows
		using: context messageFlowsDescription.
	context diagramContext writeElements: anAssessment proposedDiagramElements.
	context collaborationMemento
		detachChildMementoFor: messageFlow
		inRelation: context messageFlowsDescription.
	anAssessment removedDiagramElements do: [ :anElement |
		context diagramContext detachElement: anElement ]
]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlow >> messageFlow: anObject [
	messageFlow := anObject
]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlow >> processMemento: anObject [
	processMemento := anObject
]

{ #category : 'private - staged state' }
CPAtelierRemoveMessageFlow >> stagedCollaborationContext [
	collaborationContext ifNotNil: [ ^ collaborationContext ].
	^ CPProcessCollaborationContext inRootMemento: processMemento
]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlow >> collaborationContext: aContext [ collaborationContext := aContext ]
