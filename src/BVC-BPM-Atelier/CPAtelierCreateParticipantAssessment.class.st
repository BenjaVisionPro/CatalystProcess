"I describe one assessment of adding a fresh BPMN Participant and its Pool CPShape to the staged definitional Collaboration."
Class {
	#name : 'CPAtelierCreateParticipantAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'participant',
		'shape',
		'collaboration',
		'diagram',
		'createsCollaboration',
		'referencesProcess',
		'proposedParticipants',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateParticipantAssessment class >> participant: aParticipant shape: aShape collaboration: aCollaboration diagram: aDiagram createsCollaboration: createsCollaboration referencesProcess: referencesProcess proposedParticipants: someParticipants proposedDiagramElements: someElements [
	^ self new
		participant: aParticipant;
		shape: aShape;
		collaboration: aCollaboration;
		diagram: aDiagram;
		createsCollaboration: createsCollaboration;
		referencesProcess: referencesProcess;
		proposedParticipants: someParticipants;
		proposedDiagramElements: someElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierCreateParticipantAssessment class >> participant: aParticipant rejectedBecause: aString [
	^ self new
		participant: aParticipant;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> participant [ ^ participant ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> participant: anObject [ participant := anObject ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> collaboration [ ^ collaboration ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> collaboration: anObject [ collaboration := anObject ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> diagram [ ^ diagram ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> diagram: anObject [ diagram := anObject ]
{ #category : 'testing' }
CPAtelierCreateParticipantAssessment >> createsCollaboration [ ^ createsCollaboration ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> createsCollaboration: aBoolean [ createsCollaboration := aBoolean ]
{ #category : 'testing' }
CPAtelierCreateParticipantAssessment >> referencesProcess [ ^ referencesProcess ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> referencesProcess: aBoolean [ referencesProcess := aBoolean ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> proposedParticipants [ ^ proposedParticipants ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> proposedParticipants: aCollection [ proposedParticipants := aCollection ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierCreateParticipantAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
