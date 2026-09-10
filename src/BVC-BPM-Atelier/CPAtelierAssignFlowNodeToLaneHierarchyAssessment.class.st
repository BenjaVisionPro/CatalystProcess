"I describe the staged Lane-reference state for one FlowNode within one visible
nested Lane hierarchy. The proposed map covers every Lane beneath one top-level
LaneSet so application can update the hierarchy atomically while leaving any
independent top-level LaneSets untouched."
Class {
	#name : 'CPAtelierAssignFlowNodeToLaneHierarchyAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'flowNode',
		'targetLane',
		'rootLaneSet',
		'targetLanePath',
		'proposedFlowNodeRefsByLane'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchyAssessment >> flowNode [ ^ flowNode ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchyAssessment >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchyAssessment >> targetLane [ ^ targetLane ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchyAssessment >> targetLane: anObject [ targetLane := anObject ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchyAssessment >> rootLaneSet [ ^ rootLaneSet ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchyAssessment >> rootLaneSet: anObject [ rootLaneSet := anObject ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchyAssessment >> targetLanePath [ ^ targetLanePath ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchyAssessment >> targetLanePath: aCollection [ targetLanePath := aCollection ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchyAssessment >> proposedFlowNodeRefsByLane [ ^ proposedFlowNodeRefsByLane ]
{ #category : 'accessing' }
CPAtelierAssignFlowNodeToLaneHierarchyAssessment >> proposedFlowNodeRefsByLane: aDictionary [ proposedFlowNodeRefsByLane := aDictionary ]
