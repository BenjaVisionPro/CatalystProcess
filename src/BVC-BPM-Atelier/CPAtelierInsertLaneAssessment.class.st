"I describe one assessed insertion of a Lane before or after an existing Lane, including structural DI shifts, FlowNode movement, and optional Pool growth."
Class {
	#name : 'CPAtelierInsertLaneAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'lane',
		'laneSet',
		'shape',
		'proposedLanes',
		'proposedDiagramElements',
		'proposedLaneBoundsByShape',
		'flowNodeMoveOperation',
		'flowNodeMoveAssessment',
		'participantResizeOperation',
		'participantResizeAssessment'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> lane [ ^ lane ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> lane: anObject [ lane := anObject ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> laneSet [ ^ laneSet ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> laneSet: anObject [ laneSet := anObject ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> proposedLanes [ ^ proposedLanes ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> proposedLanes: aCollection [ proposedLanes := aCollection ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> proposedLaneBoundsByShape [ ^ proposedLaneBoundsByShape ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> proposedLaneBoundsByShape: aDictionary [ proposedLaneBoundsByShape := aDictionary ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> flowNodeMoveOperation [ ^ flowNodeMoveOperation ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> flowNodeMoveOperation: anOperation [ flowNodeMoveOperation := anOperation ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> flowNodeMoveAssessment [ ^ flowNodeMoveAssessment ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> flowNodeMoveAssessment: anAssessment [ flowNodeMoveAssessment := anAssessment ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> participantResizeOperation [ ^ participantResizeOperation ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> participantResizeOperation: anOperation [ participantResizeOperation := anOperation ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> participantResizeAssessment [ ^ participantResizeAssessment ]
{ #category : 'accessing' }
CPAtelierInsertLaneAssessment >> participantResizeAssessment: anAssessment [ participantResizeAssessment := anAssessment ]
