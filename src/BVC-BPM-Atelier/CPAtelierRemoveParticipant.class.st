"I stage removal of one Participant from the edited Process's Collaboration.

In a document-rooted session I mutate the canonical Collaboration and Diagram owned by CPDefinitions. The legacy Process-rooted path remains temporarily for the old CPProcess>>asAtelier entry."
Class {
	#name : 'CPAtelierRemoveParticipant',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'participant',
		'processMemento',
		'documentContext',
		'collaborationContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveParticipant class >> participant: aParticipant processMemento: aMemento [
	^ self new participant: aParticipant; processMemento: aMemento; yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveParticipant class >> participant: aParticipant processMemento: aMemento documentContext: aDocumentContext collaborationContext: aCollaborationContext [
	^ self new
		participant: aParticipant;
		processMemento: aMemento;
		documentContext: aDocumentContext;
		collaborationContext: aCollaborationContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierRemoveParticipant >> assess [
	| context participants proposedParticipants removedMessageFlows removedDiagramElements proposedMessageFlows proposedElements removesCollaboration |
	participant ifNil: [ ^ self rejectedBecause: 'A Participant is required.' ].
	context := self stagedCollaborationContext.
	context ifNil: [ ^ self rejectedBecause: 'The Process has no staged definitional Collaboration.' ].
	participants := context participants.
	(participants identityIncludes: participant) ifFalse: [
		^ self rejectedBecause: 'The Participant is not present in the staged Collaboration.' ].

	(participants size > 1 and: [ (self stagedProcessRefOf: participant in: context) == processMemento model ]) ifTrue: [
		^ self rejectedBecause: 'The Participant that hosts the edited Process cannot be removed while other Participants remain.' ].

	removesCollaboration := participants size = 1.
	proposedParticipants := participants species withAll: (participants reject: [ :each | each == participant ]).
	removedMessageFlows := context messageFlows select: [ :each |
		(self endpoint: (self stagedSourceOf: each in: context) isRepresentedBy: participant in: context)
			or: [ self endpoint: (self stagedTargetOf: each in: context) isRepresentedBy: participant in: context ] ].
	proposedMessageFlows := context messageFlows species withAll:
		(context messageFlows reject: [ :each | removedMessageFlows identityIncludes: each ]).
	removedDiagramElements := context elements select: [ :each |
		| modelElement |
		modelElement := self stagedModelElementOf: each in: context.
		modelElement == participant or: [ removedMessageFlows identityIncludes: modelElement ] ].
	proposedElements := context elements species withAll:
		(context elements reject: [ :each | removedDiagramElements identityIncludes: each ]).

	removesCollaboration ifFalse: [
		[ context participantsDescription validate: proposedParticipants ]
			on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].
		[ context messageFlowsDescription validate: proposedMessageFlows ]
			on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].
		[ context diagramContext validateElements: proposedElements ]
			on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ] ].

	^ CPAtelierRemoveParticipantAssessment
		participant: participant
		removesCollaboration: removesCollaboration
		proposedParticipants: proposedParticipants
		proposedMessageFlows: proposedMessageFlows
		proposedDiagramElements: proposedElements
		removedMessageFlows: removedMessageFlows
		removedDiagramElements: removedDiagramElements
]

{ #category : 'applying' }
CPAtelierRemoveParticipant >> applyAssessment: anAssessment [
	documentContext
		ifNil: [ self applyLegacyAssessment: anAssessment ]
		ifNotNil: [ self applyDocumentAssessment: anAssessment ]
]

{ #category : 'private - applying' }
CPAtelierRemoveParticipant >> applyDocumentAssessment: anAssessment [
	| context collaborationDescription rootElements diagrams |
	context := self stagedCollaborationContext.
	anAssessment removesCollaboration ifTrue: [
		collaborationDescription := processMemento model definitionalCollaborationRefDescription.
		processMemento write: nil using: collaborationDescription.
		rootElements := documentContext rootElements species withAll:
			(documentContext rootElements reject: [ :each | each == context collaboration ]).
		diagrams := documentContext diagrams species withAll:
			(documentContext diagrams reject: [ :each | each == context diagram ]).
		documentContext
			writeRootElements: rootElements;
			writeDiagrams: diagrams;
			detachRootElement: context collaboration;
			detachDiagram: context diagram.
		^ self ].

	self applyRemovalAssessment: anAssessment in: context
]

{ #category : 'private - applying' }
CPAtelierRemoveParticipant >> applyLegacyAssessment: anAssessment [
	| context collaborationDescription |
	context := self stagedCollaborationContext.
	anAssessment removesCollaboration ifTrue: [
		collaborationDescription := processMemento model definitionalCollaborationRefDescription.
		processMemento write: nil using: collaborationDescription.
		processMemento detachChildMementoFor: context collaboration inRelation: collaborationDescription.
		^ self ].

	self applyRemovalAssessment: anAssessment in: context
]

{ #category : 'private - applying' }
CPAtelierRemoveParticipant >> applyRemovalAssessment: anAssessment in: context [
	context collaborationMemento
		write: anAssessment proposedParticipants using: context participantsDescription;
		write: anAssessment proposedMessageFlows using: context messageFlowsDescription.
	context diagramContext writeElements: anAssessment proposedDiagramElements.
	context collaborationMemento
		detachChildMementoFor: participant inRelation: context participantsDescription.
	anAssessment removedMessageFlows do: [ :aMessageFlow |
		context collaborationMemento detachChildMementoFor: aMessageFlow inRelation: context messageFlowsDescription ].
	anAssessment removedDiagramElements do: [ :anElement |
		context diagramContext detachElement: anElement ]
]

{ #category : 'private - staged state' }
CPAtelierRemoveParticipant >> stagedCollaborationContext [
	collaborationContext ifNotNil: [ ^ collaborationContext ].
	documentContext ifNotNil: [ ^ nil ].
	^ CPProcessCollaborationContext inRootMemento: processMemento
]

{ #category : 'private - staged state' }
CPAtelierRemoveParticipant >> stagedSourceOf: aMessageFlow in: context [
	^ context stagedSourceOf: aMessageFlow
]

{ #category : 'private - staged state' }
CPAtelierRemoveParticipant >> stagedTargetOf: aMessageFlow in: context [
	^ context stagedTargetOf: aMessageFlow
]

{ #category : 'private - staged state' }
CPAtelierRemoveParticipant >> stagedProcessRefOf: aParticipant in: context [
	^ context processRefOf: aParticipant
]

{ #category : 'private - staged state' }
CPAtelierRemoveParticipant >> stagedModelElementOf: aDiagramElement in: context [
	^ context diagramContext modelElementOf: aDiagramElement
]

{ #category : 'private - resolving' }
CPAtelierRemoveParticipant >> endpoint: anEndpoint isRepresentedBy: aParticipant in: context [
	^ (context participantForEndpoint: anEndpoint) == aParticipant
]

{ #category : 'private' }
CPAtelierRemoveParticipant >> rejectedBecause: aString [
	^ CPAtelierRemoveParticipantAssessment participant: participant rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierRemoveParticipant >> participant: anObject [ participant := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveParticipant >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierRemoveParticipant >> documentContext: aContext [ documentContext := aContext ]
{ #category : 'accessing' }
CPAtelierRemoveParticipant >> collaborationContext: aContext [ collaborationContext := aContext ]
