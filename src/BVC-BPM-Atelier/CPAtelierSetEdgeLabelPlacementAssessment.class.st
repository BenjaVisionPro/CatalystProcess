Class {
	#name : 'CPAtelierSetEdgeLabelPlacementAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'edge',
		'currentSegmentIndex',
		'currentSegmentPosition',
		'currentOffset',
		'proposedSegmentIndex',
		'proposedSegmentPosition',
		'proposedOffset'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetEdgeLabelPlacementAssessment class >> edge: anEdge currentSegmentIndex: currentSegmentIndex currentSegmentPosition: currentSegmentPosition currentOffset: currentOffset proposedSegmentIndex: proposedSegmentIndex proposedSegmentPosition: proposedSegmentPosition proposedOffset: proposedOffset [
	^ self new
		edge: anEdge;
		currentSegmentIndex: currentSegmentIndex;
		currentSegmentPosition: currentSegmentPosition;
		currentOffset: currentOffset;
		proposedSegmentIndex: proposedSegmentIndex;
		proposedSegmentPosition: proposedSegmentPosition;
		proposedOffset: proposedOffset;
		yourself
]

{ #category : 'instance creation' }
CPAtelierSetEdgeLabelPlacementAssessment class >> edge: anEdge currentSegmentIndex: currentSegmentIndex currentSegmentPosition: currentSegmentPosition currentOffset: currentOffset proposedSegmentIndex: proposedSegmentIndex proposedSegmentPosition: proposedSegmentPosition proposedOffset: proposedOffset rejectedBecause: aString [
	^ self new
		edge: anEdge;
		currentSegmentIndex: currentSegmentIndex;
		currentSegmentPosition: currentSegmentPosition;
		currentOffset: currentOffset;
		proposedSegmentIndex: proposedSegmentIndex;
		proposedSegmentPosition: proposedSegmentPosition;
		proposedOffset: proposedOffset;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> edge: anEdge [ edge := anEdge ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> currentSegmentIndex [ ^ currentSegmentIndex ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> currentSegmentIndex: anInteger [ currentSegmentIndex := anInteger ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> currentSegmentPosition [ ^ currentSegmentPosition ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> currentSegmentPosition: aNumber [ currentSegmentPosition := aNumber ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> currentOffset [ ^ currentOffset ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> currentOffset: aNumber [ currentOffset := aNumber ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> proposedSegmentIndex [ ^ proposedSegmentIndex ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> proposedSegmentIndex: anInteger [ proposedSegmentIndex := anInteger ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> proposedSegmentPosition [ ^ proposedSegmentPosition ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> proposedSegmentPosition: aNumber [ proposedSegmentPosition := aNumber ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> proposedOffset [ ^ proposedOffset ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacementAssessment >> proposedOffset: aNumber [ proposedOffset := aNumber ]
