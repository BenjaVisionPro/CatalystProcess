Class {
	#name : 'CPAtelierSetEdgeWaypointsAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [ 'edge', 'currentWaypoints', 'proposedWaypoints' ],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetEdgeWaypointsAssessment class >> edge: anEdge currentWaypoints: currentWaypoints proposedWaypoints: proposedWaypoints [
	^ self new edge: anEdge; currentWaypoints: currentWaypoints; proposedWaypoints: proposedWaypoints; yourself
]

{ #category : 'instance creation' }
CPAtelierSetEdgeWaypointsAssessment class >> edge: anEdge currentWaypoints: currentWaypoints proposedWaypoints: proposedWaypoints rejectedBecause: aString [
	^ self new edge: anEdge; currentWaypoints: currentWaypoints; proposedWaypoints: proposedWaypoints; rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierSetEdgeWaypointsAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierSetEdgeWaypointsAssessment >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierSetEdgeWaypointsAssessment >> currentWaypoints [ ^ currentWaypoints ]
{ #category : 'accessing' }
CPAtelierSetEdgeWaypointsAssessment >> currentWaypoints: aCollection [ currentWaypoints := aCollection ]
{ #category : 'accessing' }
CPAtelierSetEdgeWaypointsAssessment >> proposedWaypoints [ ^ proposedWaypoints ]
{ #category : 'accessing' }
CPAtelierSetEdgeWaypointsAssessment >> proposedWaypoints: aCollection [ proposedWaypoints := aCollection ]
