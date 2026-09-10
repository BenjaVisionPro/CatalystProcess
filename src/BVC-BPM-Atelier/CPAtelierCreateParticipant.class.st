"I stage creation of one BPMN Participant and its Pool CPShape.

In a document-rooted session I create a missing Collaboration and its Diagram as siblings owned by CPDefinitions, while Process.definitionalCollaborationRef remains a reference. The legacy Process-rooted path remains temporarily for the old CPProcess>>asAtelier entry."
Class {
	#name : 'CPAtelierCreateParticipant',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'participant',
		'bounds',
		'processMemento',
		'documentContext',
		'collaborationContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateParticipant class >> participant: aParticipant bounds: aRectangle processMemento: aMemento [
	^ self new
		participant: aParticipant;
		bounds: aRectangle;
		processMemento: aMemento;
		yourself
]

{ #category : 'instance creation' }
CPAtelierCreateParticipant class >> participant: aParticipant bounds: aRectangle processMemento: aMemento documentContext: aDocumentContext collaborationContext: aCollaborationContext [
	^ self new
		participant: aParticipant;
		bounds: aRectangle;
		processMemento: aMemento;
		documentContext: aDocumentContext;
		collaborationContext: aCollaborationContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierCreateParticipant >> assess [
	| context collaboration diagram participants elements createsCollaboration referencesProcess shape proposedParticipants proposedElements participantsDescription planeElementsDescription boundsDescription proposedRootElements proposedDiagrams |
	participant ifNil: [ ^ self rejectedBecause: 'A Participant is required.' ].
	participant isParticipant ifFalse: [ ^ self rejectedBecause: 'Only a Participant can create a Pool.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Pool bounds are required.' ].

	context := self stagedCollaborationContext.
	createsCollaboration := context isNil.
	createsCollaboration
		ifTrue: [
			collaboration := CPCollaboration new label: 'Collaboration'; yourself.
			diagram := CPDiagram new.
			diagram plane modelElement: collaboration.
			documentContext ifNil: [ collaboration diagram: diagram ].
			participants := OrderedCollection new.
			elements := diagram plane elements.
			participantsDescription := collaboration participantsDescription.
			planeElementsDescription := diagram plane elementsDescription ]
		ifFalse: [
			collaboration := context collaboration.
			diagram := context diagram.
			participants := context participants.
			elements := context elements.
			participantsDescription := context participantsDescription.
			planeElementsDescription := nil ].

	(participants identityIncludes: participant) ifTrue: [
		^ self rejectedBecause: 'The Participant is already present in the Collaboration.' ].
	referencesProcess := context
		ifNil: [ true ]
		ifNotNil: [ (context participantForProcess: processMemento model) isNil ].

	shape := CPShape new
		modelElement: participant;
		bounds: bounds;
		yourself.
	boundsDescription := shape boundsDescription.
	[ boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedParticipants := participants asOrderedCollection copy.
	proposedParticipants add: participant.
	[ participantsDescription validate: proposedParticipants ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ createsCollaboration
		ifTrue: [ planeElementsDescription validate: proposedElements ]
		ifFalse: [ context diagramContext validateElements: proposedElements ] ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	(createsCollaboration and: [ documentContext notNil ]) ifTrue: [
		proposedRootElements := documentContext rootElements asOrderedCollection copy.
		proposedRootElements add: collaboration.
		proposedDiagrams := documentContext diagrams asOrderedCollection copy.
		proposedDiagrams add: diagram.
		[ documentContext validateRootElements: proposedRootElements ]
			on: MAValidationError
			do: [ :anException | ^ self rejectedBecause: anException printString ].
		[ documentContext validateDiagrams: proposedDiagrams ]
			on: MAValidationError
			do: [ :anException | ^ self rejectedBecause: anException printString ] ].

	^ CPAtelierCreateParticipantAssessment
		participant: participant
		shape: shape
		collaboration: collaboration
		diagram: diagram
		createsCollaboration: createsCollaboration
		referencesProcess: referencesProcess
		proposedParticipants: proposedParticipants
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierCreateParticipant >> applyAssessment: anAssessment [
	documentContext
		ifNil: [ self applyLegacyAssessment: anAssessment ]
		ifNotNil: [ self applyDocumentAssessment: anAssessment ]
]

{ #category : 'private - applying' }
CPAtelierCreateParticipant >> applyDocumentAssessment: anAssessment [
	| collaborationMemento participantsDescription participantMemento processRefDescription diagramContext collaborationDescription rootElements diagrams |
	collaborationDescription := processMemento model definitionalCollaborationRefDescription.

	anAssessment createsCollaboration ifTrue: [
		rootElements := documentContext rootElements asOrderedCollection copy.
		rootElements add: anAssessment collaboration.
		diagrams := documentContext diagrams asOrderedCollection copy.
		diagrams add: anAssessment diagram.
		documentContext
			writeRootElements: rootElements;
			writeDiagrams: diagrams.
		processMemento write: anAssessment collaboration using: collaborationDescription ].

	collaborationMemento := documentContext mementoForRootElement: anAssessment collaboration.
	participantsDescription := anAssessment collaboration participantsDescription.
	collaborationMemento
		write: anAssessment proposedParticipants
		using: participantsDescription.
	anAssessment referencesProcess ifTrue: [
		participantMemento := collaborationMemento
			childMementoFor: anAssessment participant
			inRelation: participantsDescription.
		processRefDescription := anAssessment participant processRefDescription.
		participantMemento
			write: processMemento model
			using: processRefDescription ].

	diagramContext := documentContext diagramContextFor: anAssessment diagram.
	diagramContext writeElements: anAssessment proposedDiagramElements
]

{ #category : 'private - applying' }
CPAtelierCreateParticipant >> applyLegacyAssessment: anAssessment [
	| collaborationDescription collaborationMemento participantsDescription participantMemento processRefDescription diagramDescription diagramContext |

	anAssessment createsCollaboration ifTrue: [
		collaborationDescription := processMemento model definitionalCollaborationRefDescription.
		processMemento
			write: anAssessment collaboration
			using: collaborationDescription.
		collaborationMemento := processMemento
			childMementoFor: anAssessment collaboration
			inRelation: collaborationDescription.
		diagramDescription := anAssessment collaboration diagramDescription.
		collaborationMemento
			write: anAssessment diagram
			using: diagramDescription ]
	ifFalse: [
		collaborationMemento := self stagedCollaborationContext collaborationMemento.
		diagramDescription := anAssessment collaboration diagramDescription ].

	participantsDescription := anAssessment collaboration participantsDescription.
	collaborationMemento
		write: anAssessment proposedParticipants
		using: participantsDescription.
	anAssessment referencesProcess ifTrue: [
		participantMemento := collaborationMemento
			childMementoFor: anAssessment participant
			inRelation: participantsDescription.
		processRefDescription := anAssessment participant processRefDescription.
		participantMemento
			write: processMemento model
			using: processRefDescription ].

	diagramContext := CPDiagramMementoContext
		diagram: anAssessment diagram
		inMemento: collaborationMemento
		using: diagramDescription.
	diagramContext writeElements: anAssessment proposedDiagramElements
]

{ #category : 'private - staged state' }
CPAtelierCreateParticipant >> stagedCollaborationContext [
	collaborationContext ifNotNil: [ ^ collaborationContext ].
	documentContext ifNotNil: [ ^ nil ].
	^ CPProcessCollaborationContext inRootMemento: processMemento
]

{ #category : 'private' }
CPAtelierCreateParticipant >> rejectedBecause: aString [
	^ CPAtelierCreateParticipantAssessment
		participant: participant
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierCreateParticipant >> participant: anObject [ participant := anObject ]
{ #category : 'accessing' }
CPAtelierCreateParticipant >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierCreateParticipant >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierCreateParticipant >> documentContext: aContext [ documentContext := aContext ]
{ #category : 'accessing' }
CPAtelierCreateParticipant >> collaborationContext: aContext [ collaborationContext := aContext ]
