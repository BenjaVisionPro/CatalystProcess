"I stage creation of one BPMN Participant and its Pool CPShape.

If the root Process has no staged definitional Collaboration, I establish one together with its Collaboration diagram. The first Participant that can represent the edited Process receives that processRef; later Participants are black boxes by default."
Class {
	#name : 'CPAtelierCreateParticipant',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'participant',
		'bounds',
		'processMemento'
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

{ #category : 'assessing' }
CPAtelierCreateParticipant >> assess [
	| context collaboration diagram participants elements createsCollaboration referencesProcess shape proposedParticipants proposedElements participantsDescription elementsDescription boundsDescription |
	participant ifNil: [ ^ self rejectedBecause: 'A Participant is required.' ].
	participant isParticipant ifFalse: [ ^ self rejectedBecause: 'Only a Participant can create a Pool.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Pool bounds are required.' ].

	context := CPProcessCollaborationContext inRootMemento: processMemento.
	createsCollaboration := context isNil.
	createsCollaboration
		ifTrue: [
			collaboration := CPCollaboration new label: 'Collaboration'; yourself.
			diagram := CPDiagram new.
			collaboration diagram: diagram.
			participants := OrderedCollection new.
			elements := diagram plane elements.
			participantsDescription := collaboration magritteDescription
				detect: [ :each | each handlesSelector: #participants ].
			elementsDescription := diagram plane elementsDescription ]
		ifFalse: [
			collaboration := context collaboration.
			diagram := context diagram.
			participants := context participants.
			elements := context elements.
			participantsDescription := context participantsDescription.
			elementsDescription := context elementsDescription ].

	(participants identityIncludes: participant) ifTrue: [
		^ self rejectedBecause: 'The Participant is already present in the Collaboration.' ].
	referencesProcess := context
		ifNil: [ true ]
		ifNotNil: [ (context participantForProcess: processMemento model) isNil ].

	shape := CPShape new
		modelElement: participant;
		bounds: bounds;
		yourself.
	boundsDescription := shape magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
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
	[ elementsDescription validate: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

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
	| collaborationDescription collaborationMemento participantsDescription participantMemento processRefDescription diagramDescription diagramContext |

	anAssessment createsCollaboration ifTrue: [
		collaborationDescription := processMemento magritteDescription
			detect: [ :each | each handlesSelector: #definitionalCollaborationRef ].
		processMemento
			write: anAssessment collaboration
			using: collaborationDescription.
		collaborationMemento := processMemento
			childMementoFor: anAssessment collaboration
			inRelation: collaborationDescription.
		diagramDescription := collaborationMemento magritteDescription
			detect: [ :each | each handlesSelector: #diagram ].
		collaborationMemento
			write: anAssessment diagram
			using: diagramDescription ]
	ifFalse: [
		collaborationMemento := (CPProcessCollaborationContext
			inRootMemento: processMemento) collaborationMemento.
		diagramDescription := collaborationMemento magritteDescription
			detect: [ :each | each handlesSelector: #diagram ] ].

	participantsDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #participants ].
	collaborationMemento
		write: anAssessment proposedParticipants
		using: participantsDescription.
	anAssessment referencesProcess ifTrue: [
		participantMemento := collaborationMemento
			childMementoFor: anAssessment participant
			inRelation: participantsDescription.
		processRefDescription := participantMemento magritteDescription
			detect: [ :each | each handlesSelector: #processRef ].
		participantMemento
			write: processMemento model
			using: processRefDescription ].

	diagramContext := CPDiagramMementoContext
		diagram: anAssessment diagram
		inMemento: collaborationMemento
		using: diagramDescription.
	diagramContext planeMemento
		write: anAssessment proposedDiagramElements
		using: diagramContext elementsDescription
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
