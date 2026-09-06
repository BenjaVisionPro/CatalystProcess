"I coordinate a staged bounds change for one Collaboration Participant CPShape.

My concrete subclasses define whether the change is a move or a resize. I resolve the definitional Collaboration through CPProcessCollaborationContext, validate the proposed bounds through Magritte, stage the Participant shape bounds, and translate the endpoint waypoint of each MessageFlow represented by that Participant."
Class {
	#name : 'CPAtelierParticipantShapeBoundsOperation',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'shape',
		'bounds',
		'processMemento'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierParticipantShapeBoundsOperation class >> shape: aShape bounds: aRectangle processMemento: aMemento [
	^ self new
		shape: aShape;
		bounds: aRectangle;
		processMemento: aMemento;
		yourself
]

{ #category : 'assessing' }
CPAtelierParticipantShapeBoundsOperation >> assess [
	| context elements occurrences shapeMemento boundsDescription modelElementDescription participant currentBounds |
	shape ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'A Participant diagram shape is required.' ].
	bounds ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'Participant diagram bounds are required.' ].
	context := CPProcessCollaborationContext inRootMemento: processMemento.
	context ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'The Process has no staged definitional Collaboration diagram.' ].
	elements := context elements.
	occurrences := elements count: [ :each | each == shape ].
	occurrences = 1 ifFalse: [
		^ self rejectedWithCurrentBounds: nil because: 'The Participant shape must occur exactly once in the Collaboration diagram.' ].
	shapeMemento := context diagramMemento childMementoFor: shape inRelation: context elementsDescription.
	modelElementDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	participant := shapeMemento readUsing: modelElementDescription.
	(participant notNil and: [ participant isParticipant ]) ifFalse: [
		^ self rejectedWithCurrentBounds: nil because: 'The diagram shape must depict a Participant.' ].
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	currentBounds := shapeMemento readUsing: boundsDescription.
	currentBounds = bounds ifTrue: [
		^ self rejectedWithCurrentBounds: currentBounds because: 'The Participant shape already has the requested bounds.' ].
	[ boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithCurrentBounds: currentBounds because: anException printString ].
	^ CPAtelierMoveShapeAssessment
		shape: shape
		currentBounds: currentBounds
		proposedBounds: bounds
]

{ #category : 'applying' }
CPAtelierParticipantShapeBoundsOperation >> applyAssessment: anAssessment [
	| context shapeMemento boundsDescription modelElementDescription participant delta |
	context := CPProcessCollaborationContext inRootMemento: processMemento.
	shapeMemento := context diagramMemento childMementoFor: shape inRelation: context elementsDescription.
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	modelElementDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	participant := shapeMemento readUsing: modelElementDescription.
	delta := self
		endpointDeltaFrom: anAssessment currentBounds
		to: anAssessment proposedBounds.
	shapeMemento write: anAssessment proposedBounds using: boundsDescription.
	context elements do: [ :each |
		each isEdge ifTrue: [
			self
				translateEndpointOfMessageFlowEdge: each
				representedBy: participant
				by: delta
				in: context ] ]
]

{ #category : 'private - applying' }
CPAtelierParticipantShapeBoundsOperation >> translateEndpointOfMessageFlowEdge: anEdge representedBy: aParticipant by: delta in: context [
	| edgeMemento modelElementDescription messageFlow source target waypointsDescription waypoints translated changed |
	edgeMemento := context diagramMemento childMementoFor: anEdge inRelation: context elementsDescription.
	modelElementDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	messageFlow := edgeMemento readUsing: modelElementDescription.
	(messageFlow notNil and: [ context messageFlows identityIncludes: messageFlow ]) ifFalse: [ ^ self ].
	source := self stagedSourceOf: messageFlow in: context.
	target := self stagedTargetOf: messageFlow in: context.
	waypointsDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	waypoints := edgeMemento readUsing: waypointsDescription.
	waypoints ifEmpty: [ ^ self ].
	translated := waypoints asOrderedCollection copy.
	changed := false.
	(self endpoint: source isRepresentedBy: aParticipant in: context) ifTrue: [
		translated at: 1 put: translated first + delta.
		changed := true ].
	(self endpoint: target isRepresentedBy: aParticipant in: context) ifTrue: [
		translated at: translated size put: translated last + delta.
		changed := true ].
	changed ifTrue: [ edgeMemento write: translated using: waypointsDescription ]
]

{ #category : 'private - staged state' }
CPAtelierParticipantShapeBoundsOperation >> stagedSourceOf: aMessageFlow in: context [
	| memento description |
	memento := context collaborationMemento
		childMementoFor: aMessageFlow
		inRelation: context messageFlowsDescription.
	description := memento magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	^ memento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierParticipantShapeBoundsOperation >> stagedTargetOf: aMessageFlow in: context [
	| memento description |
	memento := context collaborationMemento
		childMementoFor: aMessageFlow
		inRelation: context messageFlowsDescription.
	description := memento magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	^ memento readUsing: description
]

{ #category : 'private - resolving' }
CPAtelierParticipantShapeBoundsOperation >> endpoint: anEndpoint isRepresentedBy: aParticipant in: context [
	| process participantMemento processRefDescription |
	anEndpoint ifNil: [ ^ false ].
	anEndpoint == aParticipant ifTrue: [ ^ true ].
	anEndpoint isParticipant ifTrue: [ ^ false ].
	process := anEndpoint owningProcess.
	process ifNil: [ ^ false ].
	participantMemento := context collaborationMemento
		childMementoFor: aParticipant
		inRelation: context participantsDescription.
	processRefDescription := participantMemento magritteDescription
		detect: [ :each | each handlesSelector: #processRef ].
	^ (participantMemento readUsing: processRefDescription) == process
]

{ #category : 'private - subclass responsibility' }
CPAtelierParticipantShapeBoundsOperation >> endpointDeltaFrom: currentBounds to: proposedBounds [
	self subclassResponsibility
]

{ #category : 'private' }
CPAtelierParticipantShapeBoundsOperation >> rejectedWithCurrentBounds: aRectangle because: aString [
	^ CPAtelierMoveShapeAssessment
		shape: shape
		currentBounds: aRectangle
		proposedBounds: bounds
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierParticipantShapeBoundsOperation >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierParticipantShapeBoundsOperation >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierParticipantShapeBoundsOperation >> processMemento: aMemento [ processMemento := aMemento ]
