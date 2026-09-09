"I add one fresh Lane one partition level below an existing parent Lane.

If the parent has no child LaneSet I stage one and add the Lane to it. If the child LaneSet already exists I append the Lane there. I also stage the Lane CPShape in the root Process diagram. I never mutate the semantic model while assessing."
Class {
	#name : 'CPAtelierAddChildLane',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'parentLane',
		'lane',
		'bounds',
		'processMemento',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierAddChildLane class >> lane: aLane toParentLane: aParentLane bounds: aRectangle processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new
		lane: aLane;
		parentLane: aParentLane;
		bounds: aRectangle;
		processMemento: aMemento;
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierAddChildLane >> assess [
	| laneContext parentLaneMemento childDescription childLaneSet createsLaneSet laneSetMemento lanesDescription lanes proposedLanes diagram diagramContext elements proposedElements shape boundsDescription |
	parentLane ifNil: [ ^ self rejectedBecause: 'A parent Lane is required.' ].
	lane ifNil: [ ^ self rejectedBecause: 'A fresh child Lane is required.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Child Lane bounds are required.' ].
	parentLane == lane ifTrue: [ ^ self rejectedBecause: 'A Lane cannot contain itself.' ].

	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	parentLaneMemento := laneContext mementoForLane: parentLane.
	parentLaneMemento ifNil: [
		^ self rejectedBecause: 'The parent Lane is not in the staged Process Lane hierarchy.' ].
	childDescription := parentLaneMemento magritteDescription
		detect: [ :each | each handlesSelector: #childLaneSet ].
	childLaneSet := parentLaneMemento readUsing: childDescription.
	createsLaneSet := childLaneSet isNil.
	childLaneSet ifNil: [ childLaneSet := CPLaneSet new ].

	createsLaneSet
		ifTrue: [
			lanesDescription := childLaneSet magritteDescription
				detect: [ :each | each handlesSelector: #lanes ].
			lanes := OrderedCollection new ]
		ifFalse: [
			laneSetMemento := parentLaneMemento
				childMementoFor: childLaneSet
				inRelation: childDescription.
			lanesDescription := laneSetMemento magritteDescription
				detect: [ :each | each handlesSelector: #lanes ].
			lanes := laneSetMemento readUsing: lanesDescription ].
	lanes ifNil: [ ^ self rejectedBecause: 'The child LaneSet has no staged Lane collection.' ].
	(lanes identityIncludes: lane) ifTrue: [
		^ self rejectedBecause: 'The child Lane is already present in the child LaneSet.' ].
	proposedLanes := lanes asOrderedCollection copy.
	proposedLanes add: lane.
	[ lanesDescription validate: proposedLanes ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	shape := CPShape new modelElement: lane; bounds: bounds; yourself.
	boundsDescription := shape magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	[ boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The Process has no staged diagram.' ].
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	elements := diagramContext elements.
	elements ifNil: [ ^ self rejectedBecause: 'The Process diagram has no staged elements collection.' ].
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ diagramContext elementsDescription validate: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierAddChildLaneAssessment new
		parentLane: parentLane;
		lane: lane;
		laneSet: childLaneSet;
		shape: shape;
		createsLaneSet: createsLaneSet;
		proposedLanes: proposedLanes;
		proposedDiagramElements: proposedElements;
		yourself
]

{ #category : 'applying' }
CPAtelierAddChildLane >> applyAssessment: anAssessment [
	| laneContext parentLaneMemento childDescription laneSetMemento lanesDescription diagram diagramContext |
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	parentLaneMemento := laneContext mementoForLane: anAssessment parentLane.
	childDescription := parentLaneMemento magritteDescription
		detect: [ :each | each handlesSelector: #childLaneSet ].
	anAssessment createsLaneSet ifTrue: [
		parentLaneMemento write: anAssessment laneSet using: childDescription ].
	laneSetMemento := parentLaneMemento
		childMementoFor: anAssessment laneSet
		inRelation: childDescription.
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	laneSetMemento write: anAssessment proposedLanes using: lanesDescription.

	diagram := processMemento readUsing: diagramDescription.
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	diagramContext diagramMemento
		write: anAssessment proposedDiagramElements
		using: diagramContext elementsDescription
]

{ #category : 'private' }
CPAtelierAddChildLane >> rejectedBecause: aString [
	^ CPAtelierAddChildLaneAssessment new
		parentLane: parentLane;
		lane: lane;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierAddChildLane >> parentLane: anObject [ parentLane := anObject ]
{ #category : 'accessing' }
CPAtelierAddChildLane >> lane: anObject [ lane := anObject ]
{ #category : 'accessing' }
CPAtelierAddChildLane >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierAddChildLane >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierAddChildLane >> diagramDescription: aDescription [ diagramDescription := aDescription ]
