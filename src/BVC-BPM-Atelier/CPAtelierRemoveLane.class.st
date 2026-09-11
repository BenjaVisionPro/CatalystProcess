"I remove one Lane from the staged Lane hierarchy.

Lane membership is partition metadata, not FlowNode ownership. I therefore remove the Lane (and any nested Lane hierarchy it owns) plus its BPMN DI shapes while preserving every Process FlowNode. When the removal empties a LaneSet I remove that LaneSet from its semantic parent. For a Collaboration-hosted Process I then reflow the surviving Lane hierarchy into the unchanged Participant bounds."
Class {
	#name : 'CPAtelierRemoveLane',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'lane',
		'processMemento',
		'diagramContext',
		'collaborationContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveLane class >> lane: aLane processMemento: aMemento diagramContext: aDiagramContext collaborationContext: aCollaborationContext [
	^ self new
		lane: aLane;
		processMemento: aMemento;
		diagramContext: aDiagramContext;
		collaborationContext: aCollaborationContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierRemoveLane >> assess [
	| laneContext laneSet laneSetMemento lanesDescription lanes proposedLanes removesLaneSet parentLane proposedLaneSets removedLanes elements removedDiagramElements proposedElements assessment |
	lane ifNil: [ ^ self rejectedBecause: 'A Lane is required.' ].
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	laneSet := laneContext laneSetContainingLane: lane.
	laneSet ifNil: [ ^ self rejectedBecause: 'The Lane is not present in the staged Process Lane hierarchy.' ].
	laneSetMemento := laneContext mementoForLaneSet: laneSet.
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	lanes := laneSetMemento readUsing: lanesDescription.
	proposedLanes := lanes species withAll: (lanes reject: [ :each | each == lane ]).
	removesLaneSet := proposedLanes isEmpty.
	parentLane := removesLaneSet ifTrue: [ laneContext parentLaneOfLaneSet: laneSet ] ifFalse: [ nil ].
	proposedLaneSets := nil.

	removesLaneSet
		ifTrue: [
			parentLane
				ifNil: [
					proposedLaneSets := laneContext stagedLaneSets species withAll:
						(laneContext stagedLaneSets reject: [ :each | each == laneSet ]).
					[ laneContext laneSetsDescription validate: proposedLaneSets ]
						on: MAValidationError
						do: [ :anException | ^ self rejectedBecause: anException printString ] ]
				ifNotNil: [
					| parentLaneMemento childDescription |
					parentLaneMemento := laneContext mementoForLane: parentLane.
					childDescription := parentLaneMemento magritteDescription
						detect: [ :each | each handlesSelector: #childLaneSet ].
					[ childDescription validate: nil ]
						on: MAValidationError
						do: [ :anException | ^ self rejectedBecause: anException printString ] ] ]
		ifFalse: [
			[ lanesDescription validate: proposedLanes ]
				on: MAValidationError
				do: [ :anException | ^ self rejectedBecause: anException printString ] ].

	removedLanes := OrderedCollection new.
	self addLane: lane andDescendantsUsing: laneContext to: removedLanes.
	elements := diagramContext elements.
	removedDiagramElements := elements select: [ :each |
		each isShape and: [ removedLanes identityIncludes: (diagramContext modelElementOf: each) ] ].
	removedLanes do: [ :aRemovedLane |
		((diagramContext shapesForModelElement: aRemovedLane) size = 1) ifFalse: [
			^ self rejectedBecause: 'Every removed Lane must have exactly one staged diagram shape.' ] ].
	proposedElements := elements species withAll:
		(elements reject: [ :each | removedDiagramElements identityIncludes: each ]).
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	assessment := CPAtelierRemoveLaneAssessment new
		lane: lane;
		laneSet: laneSet;
		parentLane: parentLane;
		removesLaneSet: removesLaneSet;
		proposedLanes: proposedLanes;
		proposedLaneSets: proposedLaneSets;
		removedLanes: removedLanes;
		removedDiagramElements: removedDiagramElements;
		proposedDiagramElements: proposedElements;
		yourself.
	^ assessment
]

{ #category : 'applying' }
CPAtelierRemoveLane >> applyAssessment: anAssessment [
	| laneContext laneSetMemento lanesDescription |
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	anAssessment removesLaneSet
		ifTrue: [
			anAssessment parentLane
				ifNil: [
					processMemento write: anAssessment proposedLaneSets using: laneContext laneSetsDescription.
					processMemento detachChildMementoFor: anAssessment laneSet inRelation: laneContext laneSetsDescription ]
				ifNotNil: [ :parentLane |
					| parentLaneMemento childDescription |
					parentLaneMemento := laneContext mementoForLane: parentLane.
					childDescription := parentLaneMemento magritteDescription
						detect: [ :each | each handlesSelector: #childLaneSet ].
					parentLaneMemento write: nil using: childDescription.
					parentLaneMemento detachChildMementoFor: anAssessment laneSet inRelation: childDescription ] ]
		ifFalse: [
			laneSetMemento := laneContext mementoForLaneSet: anAssessment laneSet.
			lanesDescription := laneSetMemento magritteDescription
				detect: [ :each | each handlesSelector: #lanes ].
			laneSetMemento write: anAssessment proposedLanes using: lanesDescription.
			laneSetMemento detachChildMementoFor: lane inRelation: lanesDescription ].

	diagramContext writeElements: anAssessment proposedDiagramElements.
	anAssessment removedDiagramElements do: [ :anElement |
		diagramContext detachElement: anElement ].
	self reflowSurvivingLanes
]

{ #category : 'private - staged state' }
CPAtelierRemoveLane >> addLane: aLane andDescendantsUsing: laneContext to: someLanes [
	someLanes add: aLane.
	(laneContext stagedChildLaneSetOf: aLane) ifNotNil: [ :childLaneSet |
		(laneContext stagedLanesInLaneSet: childLaneSet) do: [ :childLane |
			self addLane: childLane andDescendantsUsing: laneContext to: someLanes ] ]
]

{ #category : 'private - applying' }
CPAtelierRemoveLane >> reflowSurvivingLanes [
	| context participant participantShapes participantShape participantBounds reflowOperation |
	context := self stagedCollaborationContext.
	context ifNil: [ ^ self ].
	participant := context participantForProcess: processMemento model.
	participant ifNil: [ ^ self ].
	participantShapes := context diagramContext shapesForModelElement: participant.
	participantShapes size = 1 ifFalse: [ ^ self ].
	participantShape := participantShapes anyOne.
	participantBounds := context diagramContext boundsOf: participantShape.
	reflowOperation := CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: participantBounds
		processMemento: processMemento
		collaborationContext: context
		processDiagramContext: diagramContext.
	reflowOperation applyLaneReflowForParticipantBounds: participantBounds
]

{ #category : 'private - staged state' }
CPAtelierRemoveLane >> stagedCollaborationContext [
	^ collaborationContext
]

{ #category : 'private' }
CPAtelierRemoveLane >> rejectedBecause: aString [
	^ CPAtelierRemoveLaneAssessment new
		lane: lane;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierRemoveLane >> lane: anObject [ lane := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveLane >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierRemoveLane >> diagramContext: aContext [ diagramContext := aContext ]
{ #category : 'accessing' }
CPAtelierRemoveLane >> collaborationContext: aContext [ collaborationContext := aContext ]
