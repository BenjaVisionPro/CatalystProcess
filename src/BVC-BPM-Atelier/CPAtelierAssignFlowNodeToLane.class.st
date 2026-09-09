"I assign one FlowNode to one Lane within exactly one BPMN LaneSet partition.

BPMN permits a Process to have multiple LaneSets which partition the same FlowNodes
independently. I therefore remove the FlowNode only from sibling Lanes in the target
LaneSet and add it to the target Lane. I stage all changes through the existing Lane
mementos and do not mutate the committed semantic model while assessing."
Class {
	#name : 'CPAtelierAssignFlowNodeToLane',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNode',
		'targetLane',
		'processMemento'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierAssignFlowNodeToLane class >> flowNode: aFlowNode targetLane: aLane processMemento: aMemento [
	^ self new
		flowNode: aFlowNode;
		targetLane: aLane;
		processMemento: aMemento;
		yourself
]

{ #category : 'assessing' }
CPAtelierAssignFlowNodeToLane >> assess [
	| laneContext targetLaneSet lanes proposedByLane changed |
	flowNode ifNil: [ ^ self rejectedBecause: 'A FlowNode is required.' ].
	targetLane ifNil: [ ^ self rejectedBecause: 'A target Lane is required.' ].

	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	targetLaneSet := laneContext laneSetContainingLane: targetLane.
	targetLaneSet ifNil: [
		^ self rejectedBecause: 'The target Lane is not in the staged Process Lane hierarchy.' ].
	lanes := laneContext stagedLanesInLaneSet: targetLaneSet.
	(lanes identityIncludes: targetLane) ifFalse: [
		^ self rejectedBecause: 'The target Lane is not in its staged LaneSet.' ].

	proposedByLane := IdentityDictionary new.
	changed := false.
	lanes do: [ :aLane |
		| laneMemento description current proposed |
		laneMemento := laneContext mementoForLane: aLane.
		laneMemento ifNil: [
			^ self rejectedBecause: 'Every Lane in the target LaneSet requires a staged memento.' ].
		description := laneMemento magritteDescription
			detect: [ :each | each handlesSelector: #flowNodeRefs ].
		current := laneMemento readUsing: description.
		current ifNil: [
			^ self rejectedBecause: 'Every Lane in the target LaneSet requires staged flow-node references.' ].
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
		[ description validate: proposed ]
			on: MAValidationError
			do: [ :anException | ^ self rejectedBecause: anException printString ].
		proposedByLane at: aLane put: proposed ].

	changed ifFalse: [
		^ self rejectedBecause: 'The FlowNode is already assigned to the target Lane in this LaneSet.' ].
	^ CPAtelierAssignFlowNodeToLaneAssessment new
		flowNode: flowNode;
		targetLane: targetLane;
		laneSet: targetLaneSet;
		proposedFlowNodeRefsByLane: proposedByLane;
		yourself
]

{ #category : 'applying' }
CPAtelierAssignFlowNodeToLane >> applyAssessment: anAssessment [
	| laneContext |
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	anAssessment proposedFlowNodeRefsByLane keysAndValuesDo: [ :aLane :proposed |
		| laneMemento description |
		laneMemento := laneContext mementoForLane: aLane.
		description := laneMemento magritteDescription
			detect: [ :each | each handlesSelector: #flowNodeRefs ].
		laneMemento write: proposed using: description ]
]

{ #category : 'private' }
CPAtelierAssignFlowNodeToLane >> rejectedBecause: aString [
	^ CPAtelierAssignFlowNodeToLaneAssessment new
		flowNode: flowNode;
		targetLane: targetLane;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLane >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLane >> targetLane: anObject [ targetLane := anObject ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLane >> processMemento: aMemento [ processMemento := aMemento ]
