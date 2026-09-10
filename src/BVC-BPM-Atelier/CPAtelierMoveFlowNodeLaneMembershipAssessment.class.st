"I describe one staged FlowNode Lane-membership move from an explicit source Lane to an explicit target Lane."
Class {
	#name : 'CPAtelierMoveFlowNodeLaneMembershipAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'flowNode',
		'sourceLane',
		'targetLane',
		'proposedFlowNodeRefsByLane'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembershipAssessment >> flowNode [ ^ flowNode ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembershipAssessment >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembershipAssessment >> sourceLane [ ^ sourceLane ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembershipAssessment >> sourceLane: anObject [ sourceLane := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembershipAssessment >> targetLane [ ^ targetLane ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembershipAssessment >> targetLane: anObject [ targetLane := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembershipAssessment >> proposedFlowNodeRefsByLane [ ^ proposedFlowNodeRefsByLane ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeLaneMembershipAssessment >> proposedFlowNodeRefsByLane: anObject [ proposedFlowNodeRefsByLane := anObject ]
