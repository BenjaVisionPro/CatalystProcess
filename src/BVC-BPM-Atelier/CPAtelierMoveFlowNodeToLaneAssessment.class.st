"I describe one FlowNode drag that changes both BPMN-DI bounds and Lane partition membership.

Both underlying operations are assessed before either is applied."
Class {
	#name : 'CPAtelierMoveFlowNodeToLaneAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'moveOperation',
		'moveAssessment',
		'laneOperation',
		'laneAssessment'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLaneAssessment >> moveOperation [ ^ moveOperation ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLaneAssessment >> moveOperation: anObject [ moveOperation := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLaneAssessment >> moveAssessment [ ^ moveAssessment ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLaneAssessment >> moveAssessment: anObject [ moveAssessment := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLaneAssessment >> laneOperation [ ^ laneOperation ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLaneAssessment >> laneOperation: anObject [ laneOperation := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLaneAssessment >> laneAssessment [ ^ laneAssessment ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLaneAssessment >> laneAssessment: anObject [ laneAssessment := anObject ]
