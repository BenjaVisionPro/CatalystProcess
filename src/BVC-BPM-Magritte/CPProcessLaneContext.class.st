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


{ #category : 'resolving' }
CPProcessLaneContext >> laneSetContainingLane: aLane [
	self stagedLaneSets do: [ :aLaneSet |
		(self laneSetContainingLane: aLane inLaneSet: aLaneSet) ifNotNil: [ :aResult |
			^ aResult ] ].
	^ nil
]

{ #category : 'resolving' }
CPProcessLaneContext >> mementoForLaneSet: aLaneSet [
	(self stagedLaneSets identityIncludes: aLaneSet) ifTrue: [
		^ processMemento
			childMementoFor: aLaneSet
			inRelation: laneSetsDescription ].
	self stagedLaneSets do: [ :aTopLevelLaneSet |
		(self
			mementoForLaneSet: aLaneSet
			inLaneSet: aTopLevelLaneSet
			parentMemento: processMemento
			relation: laneSetsDescription) ifNotNil: [ :aMemento |
				^ aMemento ] ].
	^ nil
]

{ #category : 'staged state' }
CPProcessLaneContext >> stagedLanesInLaneSet: aLaneSet [
	| laneSetMemento lanesDescription |
	laneSetMemento := self mementoForLaneSet: aLaneSet.
	laneSetMemento ifNil: [ ^ #() ].
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	^ laneSetMemento readUsing: lanesDescription
]

{ #category : 'staged state' }
CPProcessLaneContext >> stagedFlowNodeRefsOf: aLane [
	| laneMemento description |
	laneMemento := self mementoForLane: aLane.
	laneMemento ifNil: [ ^ #() ].
	description := laneMemento magritteDescription
		detect: [ :each | each handlesSelector: #flowNodeRefs ].
	^ laneMemento readUsing: description
]

{ #category : 'staged state' }
CPProcessLaneContext >> stagedChildLaneSetOf: aLane [
	| laneMemento description |
	laneMemento := self mementoForLane: aLane.
	laneMemento ifNil: [ ^ nil ].
	description := laneMemento magritteDescription
		detect: [ :each | each handlesSelector: #childLaneSet ].
	^ laneMemento readUsing: description
]

{ #category : 'private - resolving' }
CPProcessLaneContext >> laneSetContainingLane: aLane inLaneSet: aLaneSet [
	| lanes |
	lanes := self stagedLanesInLaneSet: aLaneSet.
	(lanes identityIncludes: aLane) ifTrue: [ ^ aLaneSet ].
	lanes do: [ :eachLane |
		(self stagedChildLaneSetOf: eachLane) ifNotNil: [ :aChildLaneSet |
			(self laneSetContainingLane: aLane inLaneSet: aChildLaneSet)
				ifNotNil: [ :aResult | ^ aResult ] ] ].
	^ nil
]

{ #category : 'private - resolving' }
CPProcessLaneContext >> mementoForLaneSet: aLaneSet inLaneSet: aCurrentLaneSet parentMemento: aParentMemento relation: aRelationDescription [
	| currentMemento lanesDescription lanes |
	currentMemento := aParentMemento
		childMementoFor: aCurrentLaneSet
		inRelation: aRelationDescription.
	lanesDescription := currentMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	lanes := currentMemento readUsing: lanesDescription.
	lanes do: [ :eachLane |
		| laneMemento childDescription childLaneSet |
		laneMemento := currentMemento
			childMementoFor: eachLane
			inRelation: lanesDescription.
		childDescription := laneMemento magritteDescription
			detect: [ :each | each handlesSelector: #childLaneSet ].
		childLaneSet := laneMemento readUsing: childDescription.
		childLaneSet ifNotNil: [
			childLaneSet == aLaneSet ifTrue: [
				^ laneMemento
					childMementoFor: childLaneSet
					inRelation: childDescription ].
			(self
				mementoForLaneSet: aLaneSet
				inLaneSet: childLaneSet
				parentMemento: laneMemento
				relation: childDescription) ifNotNil: [ :aMemento |
					^ aMemento ] ] ].
	^ nil
]




{ #category : 'resolving' }
CPProcessLaneContext >> topLevelLaneSetContainingLane: aLane [
	self stagedLaneSets do: [ :aLaneSet |
		(self laneSetContainingLane: aLane inLaneSet: aLaneSet) ifNotNil: [
			^ aLaneSet ] ].
	^ nil
]

{ #category : 'resolving' }
CPProcessLaneContext >> lanePathTo: aLane [
	self stagedLaneSets do: [ :aLaneSet |
		(self lanePathTo: aLane inLaneSet: aLaneSet) ifNotNil: [ :aPath |
			^ aPath ] ].
	^ #()
]

{ #category : 'private - resolving' }
CPProcessLaneContext >> lanePathTo: aLane inLaneSet: aLaneSet [
	(self stagedLanesInLaneSet: aLaneSet) do: [ :eachLane |
		eachLane == aLane ifTrue: [ ^ { eachLane } ].
		(self stagedChildLaneSetOf: eachLane) ifNotNil: [ :aChildLaneSet |
			(self lanePathTo: aLane inLaneSet: aChildLaneSet) ifNotNil: [ :aChildPath |
				^ { eachLane } , aChildPath ] ] ].
	^ nil
]

{ #category : 'staged state' }
CPProcessLaneContext >> stagedLanesInHierarchyRootedAt: aLaneSet [
	| lanes |
	lanes := OrderedCollection new.
	self addStagedLanesInHierarchyRootedAt: aLaneSet to: lanes.
	^ lanes
]

{ #category : 'private - staged state' }
CPProcessLaneContext >> addStagedLanesInHierarchyRootedAt: aLaneSet to: someLanes [
	(self stagedLanesInLaneSet: aLaneSet) do: [ :aLane |
		someLanes add: aLane.
		(self stagedChildLaneSetOf: aLane) ifNotNil: [ :aChildLaneSet |
			self addStagedLanesInHierarchyRootedAt: aChildLaneSet to: someLanes ] ]
]
