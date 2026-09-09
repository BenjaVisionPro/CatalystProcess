"I resolve the staged LaneSet/Lane hierarchy for one root Process editing transaction.

I own traversal of the Process laneSets relation, including nested child LaneSets, so presentation and rendering share one staged semantic boundary without depending on visual elements."
Class {
	#name : 'CPProcessLaneContext',
	#superclass : 'Object',
	#instVars : [
		'processMemento',
		'laneSetsDescription'
	],
	#category : 'BVC-BPM-Magritte-Diagram',
	#package : 'BVC-BPM-Magritte',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessLaneContext class >> inRootMemento: aProcessMemento [
	| laneSetsDescription |
	laneSetsDescription := aProcessMemento magritteDescription
		detect: [ :each | each handlesSelector: #laneSets ].
	^ self new
		processMemento: aProcessMemento;
		laneSetsDescription: laneSetsDescription;
		yourself
]

{ #category : 'accessing' }
CPProcessLaneContext >> processMemento [ ^ processMemento ]

{ #category : 'accessing' }
CPProcessLaneContext >> processMemento: aMemento [ processMemento := aMemento ]

{ #category : 'accessing' }
CPProcessLaneContext >> laneSetsDescription [ ^ laneSetsDescription ]

{ #category : 'accessing' }
CPProcessLaneContext >> laneSetsDescription: aDescription [ laneSetsDescription := aDescription ]

{ #category : 'staged state' }
CPProcessLaneContext >> stagedLaneSets [
	^ processMemento readUsing: laneSetsDescription
]

{ #category : 'staged state' }
CPProcessLaneContext >> stagedLanes [
	| lanes |
	lanes := OrderedCollection new.
	self stagedLaneSets do: [ :aLaneSet |
		self
			addStagedLanesFrom: aLaneSet
			parentMemento: processMemento
			relation: laneSetsDescription
			to: lanes ].
	^ lanes
]

{ #category : 'resolving' }
CPProcessLaneContext >> mementoForLane: aLane [
	self stagedLaneSets do: [ :aLaneSet |
		(self
			mementoForLane: aLane
			inLaneSet: aLaneSet
			parentMemento: processMemento
			relation: laneSetsDescription) ifNotNil: [ :aLaneMemento |
				^ aLaneMemento ] ].
	^ nil
]

{ #category : 'private - staged state' }
CPProcessLaneContext >> addStagedLanesFrom: aLaneSet parentMemento: aParentMemento relation: aRelationDescription to: someLanes [
	| laneSetMemento lanesDescription stagedLanes |
	laneSetMemento := aParentMemento
		childMementoFor: aLaneSet
		inRelation: aRelationDescription.
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	stagedLanes := laneSetMemento readUsing: lanesDescription.
	stagedLanes do: [ :aLane |
		| laneMemento childLaneSetDescription childLaneSet |
		someLanes add: aLane.
		laneMemento := laneSetMemento
			childMementoFor: aLane
			inRelation: lanesDescription.
		childLaneSetDescription := laneMemento magritteDescription
			detect: [ :each | each handlesSelector: #childLaneSet ].
		childLaneSet := laneMemento readUsing: childLaneSetDescription.
		childLaneSet ifNotNil: [
			self
				addStagedLanesFrom: childLaneSet
				parentMemento: laneMemento
				relation: childLaneSetDescription
				to: someLanes ] ]
]

{ #category : 'private - resolving' }
CPProcessLaneContext >> mementoForLane: aLane inLaneSet: aLaneSet parentMemento: aParentMemento relation: aRelationDescription [
	| laneSetMemento lanesDescription stagedLanes |
	laneSetMemento := aParentMemento
		childMementoFor: aLaneSet
		inRelation: aRelationDescription.
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	stagedLanes := laneSetMemento readUsing: lanesDescription.
	(stagedLanes identityIncludes: aLane) ifTrue: [
		^ laneSetMemento childMementoFor: aLane inRelation: lanesDescription ].
	stagedLanes do: [ :eachLane |
		| laneMemento childLaneSetDescription childLaneSet |
		laneMemento := laneSetMemento childMementoFor: eachLane inRelation: lanesDescription.
		childLaneSetDescription := laneMemento magritteDescription
			detect: [ :each | each handlesSelector: #childLaneSet ].
		childLaneSet := laneMemento readUsing: childLaneSetDescription.
		childLaneSet ifNotNil: [
			(self
				mementoForLane: aLane
				inLaneSet: childLaneSet
				parentMemento: laneMemento
				relation: childLaneSetDescription) ifNotNil: [ :aLaneMemento |
					^ aLaneMemento ] ] ].
	^ nil
]
