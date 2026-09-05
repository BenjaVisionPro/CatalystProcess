Class {
	#name : 'CPAtelierSetEdgeLabelBoundsAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'edge',
		'currentBounds',
		'proposedBounds'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetEdgeLabelBoundsAssessment class >> edge: anEdge currentBounds: currentBounds proposedBounds: proposedBounds [
	^ self new
		edge: anEdge;
		currentBounds: currentBounds;
		proposedBounds: proposedBounds;
		yourself
]

{ #category : 'instance creation' }
CPAtelierSetEdgeLabelBoundsAssessment class >> edge: anEdge currentBounds: currentBounds proposedBounds: proposedBounds rejectedBecause: aString [
	^ self new
		edge: anEdge;
		currentBounds: currentBounds;
		proposedBounds: proposedBounds;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierSetEdgeLabelBoundsAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelBoundsAssessment >> edge: anEdge [ edge := anEdge ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelBoundsAssessment >> currentBounds [ ^ currentBounds ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelBoundsAssessment >> currentBounds: aRectangle [ currentBounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelBoundsAssessment >> proposedBounds [ ^ proposedBounds ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelBoundsAssessment >> proposedBounds: aRectangle [ proposedBounds := aRectangle ]
