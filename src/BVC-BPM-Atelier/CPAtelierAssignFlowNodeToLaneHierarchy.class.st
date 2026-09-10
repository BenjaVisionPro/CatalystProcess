"I synchronize one FlowNode's references across one nested BPMN Lane hierarchy.

A FlowNode placed inside a nested Lane is referenced by each containing Lane on
the path from the top-level Lane to the deepest target Lane. Lanes elsewhere in
that same hierarchy must not reference it. Independent top-level LaneSets remain
untouched because BPMN permits them to partition the Process independently.

I stage every affected Lane through CPProcessLaneContext and never mutate the
committed semantic model while assessing."
Class {
	#name : 'CPAtelierAssignFlowNodeToLaneHierarchy',
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
CPAtelierAssignFlowNodeToLaneHierarchy class >> flowNode: aFlowNode targetLane: aLane processMemento: aMemento [
	^ self new
		flowNode: aFlowNode;
		targetLane: aLane;
		processMemento: aMemento;
		yourself
]

{ #category : 'assessing' }
CPAtelierAssignFlowNodeToLaneHierarchy >> assess [
	| laneContext rootLaneSet targetPath lanes proposedByLane |
	flowNode ifNil: [ ^ self rejectedBecause: 'A FlowNode is required.' ].
	targetLane ifNil: [ ^ self rejectedBecause: 'A target Lane is required.' ].

	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	rootLaneSet := laneContext topLevelLaneSetContainingLane: targetLane.
	rootLaneSet ifNil: [
		^ self rejectedBecause: 'The target Lane is not in the staged Process Lane hierarchy.' ].
	targetPath := laneContext lanePathTo: targetLane.
	targetPath ifEmpty: [
		^ self rejectedBecause: 'The target Lane has no staged Lane path.' ].
	lanes := laneContext stagedLanesInHierarchyRootedAt: rootLaneSet.
	proposedByLane := IdentityDictionary new.

	lanes do: [ :aLane |
		| laneMemento description current proposed shouldReference |
		laneMemento := laneContext mementoForLane: aLane.
		laneMemento ifNil: [
			^ self rejectedBecause: 'Every Lane in the target hierarchy requires a staged memento.' ].
		description := laneMemento magritteDescription
			detect: [ :each | each handlesSelector: #flowNodeRefs ].
		current := laneMemento readUsing: description.
		current ifNil: [
			^ self rejectedBecause: 'Every Lane in the target hierarchy requires staged flow-node references.' ].
		proposed := current asOrderedCollection copy.
		shouldReference := targetPath identityIncludes: aLane.
		shouldReference
			ifTrue: [
				(proposed identityIncludes: flowNode) ifFalse: [ proposed add: flowNode ] ]
			ifFalse: [
				(proposed identityIncludes: flowNode) ifTrue: [ proposed remove: flowNode ] ].
		[ description validate: proposed ]
			on: MAValidationError
			do: [ :anException | ^ self rejectedBecause: anException printString ].
		proposedByLane at: aLane put: proposed ].

	^ CPAtelierAssignFlowNodeToLaneHierarchyAssessment new
		flowNode: flowNode;
		targetLane: targetLane;
		rootLaneSet: rootLaneSet;
		targetLanePath: targetPath;
		proposedFlowNodeRefsByLane: proposedByLane;
		yourself
]

{ #category : 'applying' }
CPAtelierAssignFlowNodeToLaneHierarchy >> applyAssessment: anAssessment [
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
CPAtelierAssignFlowNodeToLaneHierarchy >> rejectedBecause: aString [
	^ CPAtelierAssignFlowNodeToLaneHierarchyAssessment new
		flowNode: flowNode;
		targetLane: targetLane;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchy >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchy >> targetLane: anObject [ targetLane := anObject ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchy >> processMemento: aMemento [ processMemento := aMemento ]
