"I describe one Participant resize together with the Lane DI reflow required to keep every LaneSet covering the full Pool body."
Class {
	#name : 'CPAtelierResizeParticipantAssessment',
	#superclass : 'CPAtelierMoveShapeAssessment',
	#instVars : [
		'proposedLaneBoundsByShape',
		'proposedFlowNodeBoundsByShape',
		'flowNodeMoveOperations',
		'flowNodeMoveAssessments'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> proposedLaneBoundsByShape [
	^ proposedLaneBoundsByShape
]

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> proposedLaneBoundsByShape: aDictionary [
	proposedLaneBoundsByShape := aDictionary
]


{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> proposedFlowNodeBoundsByShape [
	^ proposedFlowNodeBoundsByShape
]

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> proposedFlowNodeBoundsByShape: aDictionary [
	proposedFlowNodeBoundsByShape := aDictionary
]

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> flowNodeMoveOperations [
	^ flowNodeMoveOperations
]

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> flowNodeMoveOperations: someOperations [
	flowNodeMoveOperations := someOperations asArray
]

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> flowNodeMoveAssessments [
	^ flowNodeMoveAssessments
]

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> flowNodeMoveAssessments: someAssessments [
	flowNodeMoveAssessments := someAssessments asArray
]
