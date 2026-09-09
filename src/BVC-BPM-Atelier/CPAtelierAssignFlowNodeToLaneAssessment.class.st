"I describe one staged BPMN Lane-partition reassignment.

The proposed references are scoped to one LaneSet. Other LaneSets may independently
partition the same FlowNode and are deliberately not changed."
Class {
	#name : 'CPAtelierAssignFlowNodeToLaneAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'flowNode',
		'targetLane',
		'laneSet',
		'proposedFlowNodeRefsByLane'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneAssessment >> flowNode [ ^ flowNode ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneAssessment >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneAssessment >> targetLane [ ^ targetLane ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneAssessment >> targetLane: anObject [ targetLane := anObject ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneAssessment >> laneSet [ ^ laneSet ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneAssessment >> laneSet: anObject [ laneSet := anObject ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneAssessment >> proposedFlowNodeRefsByLane [ ^ proposedFlowNodeRefsByLane ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneAssessment >> proposedFlowNodeRefsByLane: aDictionary [ proposedFlowNodeRefsByLane := aDictionary ]
