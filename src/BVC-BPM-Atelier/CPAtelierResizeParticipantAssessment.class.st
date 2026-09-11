"I describe one Participant resize together with its proposed Lane bounds, FlowNode bounds, and Sequence Flow waypoints."
Class {
	#name : 'CPAtelierResizeParticipantAssessment',
	#superclass : 'CPAtelierMoveShapeAssessment',
	#instVars : [
		'proposedLaneBoundsByShape',
		'proposedFlowNodeBoundsByShape',
		'proposedWaypointsByEdge',
		'proposedCollaborationWaypointsByEdge'
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
CPAtelierResizeParticipantAssessment >> proposedWaypointsByEdge [
	^ proposedWaypointsByEdge
]

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> proposedWaypointsByEdge: aDictionary [
	proposedWaypointsByEdge := aDictionary
]


{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> proposedCollaborationWaypointsByEdge [
	^ proposedCollaborationWaypointsByEdge
]

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> proposedCollaborationWaypointsByEdge: aDictionary [
	proposedCollaborationWaypointsByEdge := aDictionary
]
