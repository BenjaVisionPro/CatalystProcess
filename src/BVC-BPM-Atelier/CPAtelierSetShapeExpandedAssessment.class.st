Class {
	#name : 'CPAtelierSetShapeExpandedAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'shape',
		'currentExpanded',
		'proposedExpanded'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetShapeExpandedAssessment class >> shape: aShape currentExpanded: currentExpanded proposedExpanded: proposedExpanded [
	^ self new
		shape: aShape;
		currentExpanded: currentExpanded;
		proposedExpanded: proposedExpanded;
		yourself
]

{ #category : 'instance creation' }
CPAtelierSetShapeExpandedAssessment class >> shape: aShape currentExpanded: currentExpanded proposedExpanded: proposedExpanded rejectedBecause: aString [
	^ self new
		shape: aShape;
		currentExpanded: currentExpanded;
		proposedExpanded: proposedExpanded;
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
