"
I describe one assessed reorder of an existing Lane within its current staged LaneSet.

The assessment carries the semantic Lane order plus every BPMN-DI mutation needed
to keep the Lane subtree, its assigned FlowNodes, attached Boundary Events and
connected edge endpoints consistent with that order.
"
Class {
	#name : 'CPAtelierReorderLaneAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'lane',
		'laneSet',
		'proposedLanes',
		'proposedLaneBoundsByShape',
		'proposedFlowNodeBoundsByShape',
		'proposedWaypointsByEdge'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> lane [ ^ lane ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> lane: anObject [ lane := anObject ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> laneSet [ ^ laneSet ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> laneSet: anObject [ laneSet := anObject ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> proposedLanes [ ^ proposedLanes ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> proposedLanes: aCollection [ proposedLanes := aCollection ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> proposedLaneBoundsByShape [ ^ proposedLaneBoundsByShape ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> proposedLaneBoundsByShape: aDictionary [ proposedLaneBoundsByShape := aDictionary ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> proposedFlowNodeBoundsByShape [ ^ proposedFlowNodeBoundsByShape ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> proposedFlowNodeBoundsByShape: aDictionary [ proposedFlowNodeBoundsByShape := aDictionary ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> proposedWaypointsByEdge [ ^ proposedWaypointsByEdge ]
{ #category : 'accessing' }
CPAtelierReorderLaneAssessment >> proposedWaypointsByEdge: aDictionary [ proposedWaypointsByEdge := aDictionary ]
