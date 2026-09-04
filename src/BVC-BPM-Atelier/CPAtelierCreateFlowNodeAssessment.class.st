"I describe one assessment of adding a fresh flow node and its depiction to a staged CPProcess."
Class {
	#name : 'CPAtelierCreateFlowNodeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'flowNode',
		'shape',
		'proposedFlowElements',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateFlowNodeAssessment class >> flowNode: aFlowNode shape: aShape proposedFlowElements: someFlowElements proposedDiagramElements: someDiagramElements [
	^ self new
		flowNode: aFlowNode;
		shape: aShape;
		proposedFlowElements: someFlowElements;
		proposedDiagramElements: someDiagramElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierCreateFlowNodeAssessment class >> flowNode: aFlowNode rejectedBecause: aString [
	^ self new flowNode: aFlowNode; rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierCreateFlowNodeAssessment >> flowNode [ ^ flowNode ]
{ #category : 'accessing' }
CPAtelierCreateFlowNodeAssessment >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierCreateFlowNodeAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierCreateFlowNodeAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierCreateFlowNodeAssessment >> proposedFlowElements [ ^ proposedFlowElements ]
{ #category : 'accessing' }
CPAtelierCreateFlowNodeAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierCreateFlowNodeAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierCreateFlowNodeAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
