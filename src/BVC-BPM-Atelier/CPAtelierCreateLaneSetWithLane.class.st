"I stage creation of a fresh top-level BPMN LaneSet containing one supplied Lane and its CPShape.

Unlike CPAtelierCreateLane, I always create a distinct top-level LaneSet. This is the semantic operation used when the Pool structural tool is dropped on the Participant header."
Class {
	#name : 'CPAtelierCreateLaneSetWithLane',
	#superclass : 'CPAtelierCreateLane',
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateLaneSetWithLane class >> lane: aLane bounds: aRectangle processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		lane: aLane;
		bounds: aRectangle;
		processMemento: aMemento;
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierCreateLaneSetWithLane >> assess [
	| laneSetsDescription laneSets laneSet lanesDescription proposedLaneSets proposedLanes shape boundsDescription diagram diagramContext elements proposedElements participantResizeOperation participantResizeAssessment assessment |
	lane ifNil: [ ^ self rejectedBecause: 'A Lane is required.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Lane bounds are required.' ].
	laneSetsDescription := processMemento magritteDescription
		detect: [ :each | each handlesSelector: #laneSets ].
	laneSets := processMemento readUsing: laneSetsDescription.
	laneSets ifNil: [ ^ self rejectedBecause: 'The Process has no staged LaneSet collection.' ].

	laneSet := CPLaneSet new.
	lanesDescription := laneSet magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	proposedLaneSets := laneSets asOrderedCollection copy.
	proposedLaneSets add: laneSet.
	[ laneSetsDescription validate: proposedLaneSets ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	proposedLanes := OrderedCollection with: lane.
	[ lanesDescription validate: proposedLanes ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	shape := CPShape new modelElement: lane; bounds: bounds; yourself.
	boundsDescription := shape magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	[ boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [ ^ self rejectedBecause: 'The Process has no staged diagram.' ].
	elements := diagramContext elements.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	participantResizeOperation := laneSets isEmpty
		ifTrue: [ self participantResizeOperationForFirstLane ]
		ifFalse: [ nil ].
	participantResizeOperation
		ifNil: [ participantResizeAssessment := nil ]
		ifNotNil: [
			participantResizeAssessment := participantResizeOperation assess.
			participantResizeAssessment isApplicable ifFalse: [
				^ self rejectedBecause: participantResizeAssessment rejectionMessage ] ].
	assessment := CPAtelierCreateLaneAssessment
		lane: lane
		laneSet: laneSet
		shape: shape
		createsLaneSet: true
		proposedLaneSets: proposedLaneSets
		proposedLanes: proposedLanes
		proposedDiagramElements: proposedElements.
	assessment
		participantResizeOperation: participantResizeOperation;
		participantResizeAssessment: participantResizeAssessment.
	^ assessment
]

