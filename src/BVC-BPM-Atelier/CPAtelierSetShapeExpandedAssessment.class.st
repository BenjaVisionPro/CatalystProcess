Class {
	#name : 'CPAtelierSetShapeExpandedAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'shape',
		'currentExpanded',
		'proposedExpanded',
		'currentBounds',
		'proposedBounds'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetShapeExpandedAssessment class >> shape: aShape currentExpanded: currentExpanded proposedExpanded: proposedExpanded currentBounds: currentBounds proposedBounds: proposedBounds [
	^ self new
		shape: aShape;
		currentExpanded: currentExpanded;
		proposedExpanded: proposedExpanded;
		currentBounds: currentBounds;
		proposedBounds: proposedBounds;
		yourself
]

{ #category : 'instance creation' }
CPAtelierSetShapeExpandedAssessment class >> shape: aShape currentExpanded: currentExpanded proposedExpanded: proposedExpanded currentBounds: currentBounds proposedBounds: proposedBounds rejectedBecause: aString [
	^ self new
		shape: aShape;
		currentExpanded: currentExpanded;
		proposedExpanded: proposedExpanded;
		currentBounds: currentBounds;
		proposedBounds: proposedBounds;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierSetShapeExpandedAssessment >> shape [ ^ shape ]

{ #category : 'accessing' }
CPAtelierSetShapeExpandedAssessment >> shape: anObject [ shape := anObject ]

{ #category : 'accessing' }
CPAtelierSetShapeExpandedAssessment >> currentExpanded [ ^ currentExpanded ]

{ #category : 'accessing' }
CPAtelierSetShapeExpandedAssessment >> currentExpanded: aBoolean [ currentExpanded := aBoolean ]

{ #category : 'accessing' }
CPAtelierSetShapeExpandedAssessment >> proposedExpanded [ ^ proposedExpanded ]

{ #category : 'accessing' }
CPAtelierSetShapeExpandedAssessment >> proposedExpanded: aBoolean [ proposedExpanded := aBoolean ]


{ #category : 'accessing' }
CPAtelierSetShapeExpandedAssessment >> currentBounds [ ^ currentBounds ]

{ #category : 'accessing' }
CPAtelierSetShapeExpandedAssessment >> currentBounds: aRectangle [ currentBounds := aRectangle ]

{ #category : 'accessing' }
CPAtelierSetShapeExpandedAssessment >> proposedBounds [ ^ proposedBounds ]

{ #category : 'accessing' }
CPAtelierSetShapeExpandedAssessment >> proposedBounds: aRectangle [ proposedBounds := aRectangle ]
