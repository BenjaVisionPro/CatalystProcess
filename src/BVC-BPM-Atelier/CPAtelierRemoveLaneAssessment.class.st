"I describe removal of one staged Lane hierarchy and its BPMN DI shapes. FlowNodes referenced by removed Lanes remain in the Process."
Class {
	#name : 'CPAtelierRemoveLaneAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'lane',
		'laneSet',
		'parentLane',
		'removesLaneSet',
		'proposedLanes',
		'proposedLaneSets',
		'removedLanes',
		'removedDiagramElements',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> lane [ ^ lane ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> lane: anObject [ lane := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> laneSet [ ^ laneSet ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> laneSet: anObject [ laneSet := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> parentLane [ ^ parentLane ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> parentLane: anObject [ parentLane := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> removesLaneSet [ ^ removesLaneSet ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> removesLaneSet: aBoolean [ removesLaneSet := aBoolean ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> proposedLanes [ ^ proposedLanes ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> proposedLanes: aCollection [ proposedLanes := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> proposedLaneSets [ ^ proposedLaneSets ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> proposedLaneSets: aCollection [ proposedLaneSets := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> removedLanes [ ^ removedLanes ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> removedLanes: aCollection [ removedLanes := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> removedDiagramElements [ ^ removedDiagramElements ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> removedDiagramElements: aCollection [ removedDiagramElements := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierRemoveLaneAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
