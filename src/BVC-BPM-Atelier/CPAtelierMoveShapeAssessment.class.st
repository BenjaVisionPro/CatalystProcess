"I describe one assessment of moving a CPShape in a CPDiagram.

I retain the authoritative staged bounds and proposed bounds. The associated operation also keeps the endpoint waypoints of incident sequence-flow edges aligned with the moved shape."
Class {
	#name : 'CPAtelierMoveShapeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'shape',
		'currentBounds',
		'proposedBounds'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierMoveShapeAssessment class >> shape: aShape currentBounds: currentBounds proposedBounds: proposedBounds [
	^ self new
		shape: aShape;
		currentBounds: currentBounds;
		proposedBounds: proposedBounds;
		yourself
]

{ #category : 'instance creation' }
CPAtelierMoveShapeAssessment class >> shape: aShape currentBounds: currentBounds proposedBounds: proposedBounds rejectedBecause: aString [
	^ self new
		shape: aShape;
		currentBounds: currentBounds;
		proposedBounds: proposedBounds;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierMoveShapeAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierMoveShapeAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierMoveShapeAssessment >> currentBounds [ ^ currentBounds ]
{ #category : 'accessing' }
CPAtelierMoveShapeAssessment >> currentBounds: aRectangle [ currentBounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierMoveShapeAssessment >> proposedBounds [ ^ proposedBounds ]
{ #category : 'accessing' }
CPAtelierMoveShapeAssessment >> proposedBounds: aRectangle [ proposedBounds := aRectangle ]
