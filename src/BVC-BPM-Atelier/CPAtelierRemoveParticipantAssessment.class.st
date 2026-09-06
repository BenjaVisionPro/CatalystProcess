"I describe removal of one staged Participant, its Pool DI shape, and any incident MessageFlows."
Class {
	#name : 'CPAtelierRemoveParticipantAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'participant',
		'removesCollaboration',
		'proposedParticipants',
		'proposedMessageFlows',
		'proposedDiagramElements',
		'removedMessageFlows',
		'removedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveParticipantAssessment class >> participant: aParticipant removesCollaboration: aBoolean proposedParticipants: someParticipants proposedMessageFlows: someMessageFlows proposedDiagramElements: someElements removedMessageFlows: removedFlows removedDiagramElements: removedElements [
	^ self new
		participant: aParticipant;
		removesCollaboration: aBoolean;
		proposedParticipants: someParticipants;
		proposedMessageFlows: someMessageFlows;
		proposedDiagramElements: someElements;
		removedMessageFlows: removedFlows;
		removedDiagramElements: removedElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveParticipantAssessment class >> participant: aParticipant rejectedBecause: aString [
	^ self new participant: aParticipant; rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> participant [ ^ participant ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> participant: anObject [ participant := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> removesCollaboration [ ^ removesCollaboration ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> removesCollaboration: aBoolean [ removesCollaboration := aBoolean ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> proposedParticipants [ ^ proposedParticipants ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> proposedParticipants: aCollection [ proposedParticipants := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> proposedMessageFlows [ ^ proposedMessageFlows ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> proposedMessageFlows: aCollection [ proposedMessageFlows := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> removedMessageFlows [ ^ removedMessageFlows ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> removedMessageFlows: aCollection [ removedMessageFlows := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> removedDiagramElements [ ^ removedDiagramElements ]
{ #category : 'accessing' }
CPAtelierRemoveParticipantAssessment >> removedDiagramElements: aCollection [ removedDiagramElements := aCollection ]
