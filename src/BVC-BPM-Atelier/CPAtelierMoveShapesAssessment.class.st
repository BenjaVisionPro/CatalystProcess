"I describe one assessment of translating a set of CPShape instances together.

I retain the staged bounds for every participating shape, the proposed bounds, and the shared translation delta used to preserve their diagram routing as one group."
Class {
	#name : 'CPAtelierMoveShapesAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'currentBoundsByShape',
		'proposedBoundsByShape',
		'delta'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierMoveShapesAssessment class >> currentBoundsByShape: currentBounds proposedBoundsByShape: proposedBounds delta: aPoint [
	^ self new
		currentBoundsByShape: currentBounds;
		proposedBoundsByShape: proposedBounds;
		delta: aPoint;
		yourself
]

{ #category : 'instance creation' }
CPAtelierMoveShapesAssessment class >> currentBoundsByShape: currentBounds proposedBoundsByShape: proposedBounds delta: aPoint rejectedBecause: aString [
	^ self new
		currentBoundsByShape: currentBounds;
		proposedBoundsByShape: proposedBounds;
		delta: aPoint;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierMoveShapesAssessment >> currentBoundsByShape [ ^ currentBoundsByShape ]
{ #category : 'accessing' }
CPAtelierMoveShapesAssessment >> currentBoundsByShape: aDictionary [ currentBoundsByShape := aDictionary ]
{ #category : 'accessing' }
CPAtelierMoveShapesAssessment >> proposedBoundsByShape [ ^ proposedBoundsByShape ]
{ #category : 'accessing' }
CPAtelierMoveShapesAssessment >> proposedBoundsByShape: aDictionary [ proposedBoundsByShape := aDictionary ]
{ #category : 'accessing' }
CPAtelierMoveShapesAssessment >> delta [ ^ delta ]
{ #category : 'accessing' }
CPAtelierMoveShapesAssessment >> delta: aPoint [ delta := aPoint ]
