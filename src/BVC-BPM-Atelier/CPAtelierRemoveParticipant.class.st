"I stage removal of one Participant from the root Process's definitional Collaboration.

I remove its Pool CPShape and every incident MessageFlow/CPEdge. Removing the sole Participant also removes the definitional Collaboration so the edited Process returns to its standalone diagram. I reject removal of the Participant that hosts the edited Process while other Participants remain, because that would leave the Process invisible in the Collaboration presentation."
Class {
	#name : 'CPAtelierRemoveParticipant',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'participant',
		'processMemento'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveParticipant class >> participant: aParticipant processMemento: aMemento [
	^ self new participant: aParticipant; processMemento: aMemento; yourself
]

{ #category : 'assessing' }
CPAtelierRemoveParticipant >> assess [
	| context participants proposedParticipants removedMessageFlows removedDiagramElements proposedMessageFlows proposedElements removesCollaboration |
	participant ifNil: [ ^ self rejectedBecause: 'A Participant is required.' ].
	context := CPProcessCollaborationContext inRootMemento: processMemento.
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
		[ context elementsDescription validate: proposedElements ]
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
	| context collaborationDescription |
	context := CPProcessCollaborationContext inRootMemento: processMemento.
	anAssessment removesCollaboration ifTrue: [
		collaborationDescription := processMemento magritteDescription
			detect: [ :each | each handlesSelector: #definitionalCollaborationRef ].
		processMemento write: nil using: collaborationDescription.
		processMemento detachChildMementoFor: context collaboration inRelation: collaborationDescription.
		^ self ].

	context collaborationMemento
		write: anAssessment proposedParticipants using: context participantsDescription;
		write: anAssessment proposedMessageFlows using: context messageFlowsDescription.
	context diagramMemento
		write: anAssessment proposedDiagramElements using: context elementsDescription.
	context collaborationMemento
		detachChildMementoFor: participant inRelation: context participantsDescription.
	anAssessment removedMessageFlows do: [ :aMessageFlow |
		context collaborationMemento detachChildMementoFor: aMessageFlow inRelation: context messageFlowsDescription ].
	anAssessment removedDiagramElements do: [ :anElement |
		context diagramMemento detachChildMementoFor: anElement inRelation: context elementsDescription ]
]

{ #category : 'private - staged state' }
CPAtelierRemoveParticipant >> stagedSourceOf: aMessageFlow in: context [
	| memento description |
	memento := context collaborationMemento childMementoFor: aMessageFlow inRelation: context messageFlowsDescription.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	^ memento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierRemoveParticipant >> stagedTargetOf: aMessageFlow in: context [
	| memento description |
	memento := context collaborationMemento childMementoFor: aMessageFlow inRelation: context messageFlowsDescription.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	^ memento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierRemoveParticipant >> stagedProcessRefOf: aParticipant in: context [
	| memento description |
	memento := context collaborationMemento childMementoFor: aParticipant inRelation: context participantsDescription.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #processRef ].
	^ memento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierRemoveParticipant >> stagedModelElementOf: aDiagramElement in: context [
	| memento description |
	memento := context diagramMemento childMementoFor: aDiagramElement inRelation: context elementsDescription.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #modelElement ].
	^ memento readUsing: description
]

{ #category : 'private - resolving' }
CPAtelierRemoveParticipant >> endpoint: anEndpoint isRepresentedBy: aParticipant in: context [
	| process |
	anEndpoint ifNil: [ ^ false ].
	anEndpoint == aParticipant ifTrue: [ ^ true ].
	anEndpoint isParticipant ifTrue: [ ^ false ].
	process := anEndpoint owningProcess.
	process ifNil: [ ^ false ].
	^ (self stagedProcessRefOf: aParticipant in: context) == process
]

{ #category : 'private' }
CPAtelierRemoveParticipant >> rejectedBecause: aString [
	^ CPAtelierRemoveParticipantAssessment participant: participant rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierRemoveParticipant >> participant: anObject [ participant := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveParticipant >> processMemento: aMemento [ processMemento := aMemento ]
