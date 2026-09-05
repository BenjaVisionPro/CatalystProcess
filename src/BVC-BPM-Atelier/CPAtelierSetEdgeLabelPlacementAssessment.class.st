Class {
	#name : 'CPAtelierSetEdgeLabelPlacementAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'edge',
		'currentPathPosition',
		'currentOffset',
		'proposedPathPosition',
		'proposedOffset'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetEdgeLabelPlacementAssessment class >> edge: anEdge currentPathPosition: currentPathPosition currentOffset: currentOffset proposedPathPosition: proposedPathPosition proposedOffset: proposedOffset [
	^ self new
		edge: anEdge;
		currentPathPosition: currentPathPosition;
		currentOffset: currentOffset;
		proposedPathPosition: proposedPathPosition;
		proposedOffset: proposedOffset;
		yourself
]

{ #category : 'instance creation' }
CPAtelierSetEdgeLabelPlacementAssessment class >> edge: anEdge currentPathPosition: currentPathPosition currentOffset: currentOffset proposedPathPosition: proposedPathPosition proposedOffset: proposedOffset rejectedBecause: aString [
	^ self new
		edge: anEdge;
		currentPathPosition: currentPathPosition;
		currentOffset: currentOffset;
		proposedPathPosition: proposedPathPosition;
		proposedOffset: proposedOffset;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> edge: anEdge [ edge := anEdge ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> currentPathPosition [ ^ currentPathPosition ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> currentPathPosition: aNumber [ currentPathPosition := aNumber ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> currentOffset [ ^ currentOffset ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> currentOffset: aNumber [ currentOffset := aNumber ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> proposedPathPosition [ ^ proposedPathPosition ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> proposedPathPosition: aNumber [ proposedPathPosition := aNumber ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> proposedOffset [ ^ proposedOffset ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> proposedOffset: aNumber [ proposedOffset := aNumber ]
