"I move one FlowNode's membership from an explicit source Lane to an explicit target Lane.

Assignment and movement have different semantics. CPAtelierAssignFlowNodeToLane changes only
the target LaneSet partition so independent LaneSets remain independent. A visual drag,
however, leaves one visible Lane and enters another, including across a nested LaneSet
boundary. I therefore remove the FlowNode from the source LaneSet partition and assign it
to the target LaneSet partition atomically in staged Lane mementos."
Class {
	#name : 'CPAtelierMoveFlowNodeLaneMembership',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNode',
		'sourceLane',
		'targetLane',
		'processMemento'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierMoveFlowNodeLaneMembership class >> flowNode: aFlowNode sourceLane: aSourceLane targetLane: aTargetLane processMemento: aMemento [
	^ self new
		flowNode: aFlowNode;
		sourceLane: aSourceLane;
		targetLane: aTargetLane;
		processMemento: aMemento;
		yourself
]

{ #category : 'assessing' }
CPAtelierMoveFlowNodeLaneMembership >> assess [
	| laneContext sourceLaneSet targetLaneSet proposedByLane changed |
	flowNode ifNil: [ ^ self rejectedBecause: 'A FlowNode is required.' ].
	(sourceLane isNil and: [ targetLane isNil ]) ifTrue: [
		^ self rejectedBecause: 'A source Lane or target Lane is required.' ].
	sourceLane == targetLane ifTrue: [
		^ self rejectedBecause: 'Source and target Lane must differ.' ].

	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	sourceLaneSet := sourceLane ifNotNil: [ laneContext laneSetContainingLane: sourceLane ].
	targetLaneSet := targetLane ifNotNil: [ laneContext laneSetContainingLane: targetLane ].
	(sourceLane notNil and: [ sourceLaneSet isNil ]) ifTrue: [
		^ self rejectedBecause: 'The source Lane is not in the staged Process Lane hierarchy.' ].
	(targetLane notNil and: [ targetLaneSet isNil ]) ifTrue: [
		^ self rejectedBecause: 'The target Lane is not in the staged Process Lane hierarchy.' ].
	(sourceLane notNil and: [
		((laneContext stagedFlowNodeRefsOf: sourceLane) identityIncludes: flowNode) not ]) ifTrue: [
		^ self rejectedBecause: 'The FlowNode is not assigned to the source Lane in staged state.' ].

	proposedByLane := IdentityDictionary new.
	changed := false.

	"Leaving a Lane means leaving its LaneSet partition. If source and target share a
	 LaneSet, the target rewrite below performs that partition change once."
	(sourceLaneSet notNil and: [ sourceLaneSet ~~ targetLaneSet ]) ifTrue: [
		(laneContext stagedLanesInLaneSet: sourceLaneSet) do: [ :aLane |
			| current proposed |
			current := laneContext stagedFlowNodeRefsOf: aLane.
			proposed := current asOrderedCollection copy.
			(proposed identityIncludes: flowNode) ifTrue: [
				proposed remove: flowNode.
				changed := true ].
			(self validate: proposed forLane: aLane in: laneContext)
				ifFalse: [ ^ self rejectedBecause: 'The proposed source Lane membership is invalid.' ].
			proposedByLane at: aLane put: proposed ] ].

	targetLaneSet ifNotNil: [
		(laneContext stagedLanesInLaneSet: targetLaneSet) do: [ :aLane |
			| current proposed |
			current := laneContext stagedFlowNodeRefsOf: aLane.
			proposed := current asOrderedCollection copy.
			aLane == targetLane
				ifTrue: [
					(proposed identityIncludes: flowNode) ifFalse: [
						proposed add: flowNode.
						changed := true ] ]
				ifFalse: [
					(proposed identityIncludes: flowNode) ifTrue: [
						proposed remove: flowNode.
						changed := true ] ].
			(self validate: proposed forLane: aLane in: laneContext)
				ifFalse: [ ^ self rejectedBecause: 'The proposed target Lane membership is invalid.' ].
			proposedByLane at: aLane put: proposed ] ].

	changed ifFalse: [
		^ self rejectedBecause: 'The Lane membership would not change.' ].
	^ CPAtelierMoveFlowNodeLaneMembershipAssessment new
		flowNode: flowNode;
		sourceLane: sourceLane;
		targetLane: targetLane;
		proposedFlowNodeRefsByLane: proposedByLane;
		yourself
]

{ #category : 'applying' }
CPAtelierMoveFlowNodeLaneMembership >> applyAssessment: anAssessment [
	| laneContext |
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	anAssessment proposedFlowNodeRefsByLane keysAndValuesDo: [ :aLane :proposed |
		| laneMemento description |
		laneMemento := laneContext mementoForLane: aLane.
		description := laneMemento magritteDescription
			detect: [ :each | each handlesSelector: #flowNodeRefs ].
		laneMemento write: proposed using: description ]
]

{ #category : 'private - validation' }
CPAtelierMoveFlowNodeLaneMembership >> validate: proposed forLane: aLane in: laneContext [
	| laneMemento description |
	laneMemento := laneContext mementoForLane: aLane.
	laneMemento ifNil: [ ^ false ].
	description := laneMemento magritteDescription
		detect: [ :each | each handlesSelector: #flowNodeRefs ].
	[ description validate: proposed ]
		on: MAValidationError
		do: [ :anException | ^ false ].
	^ true
]

{ #category : 'private' }
CPAtelierMoveFlowNodeLaneMembership >> rejectedBecause: aString [
	^ CPAtelierMoveFlowNodeLaneMembershipAssessment new
		flowNode: flowNode;
		sourceLane: sourceLane;
		targetLane: targetLane;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembership >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembership >> sourceLane: anObject [ sourceLane := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembership >> targetLane: anObject [ targetLane := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembership >> processMemento: aMemento [ processMemento := aMemento ]
