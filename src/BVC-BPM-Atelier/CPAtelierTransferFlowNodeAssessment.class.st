Class {
	#name : 'CPAtelierTransferFlowNodeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'flowNode',
		'shape',
		'sourceContainer',
		'targetContainer',
		'proposedSourceFlowElements',
		'proposedTargetFlowElements',
		'currentBounds',
		'proposedBounds',
		'stagedLabel',
		'stagedNestedFlowElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierTransferFlowNodeAssessment class >> flowNode: aFlowNode shape: aShape sourceContainer: aSourceContainer targetContainer: aTargetContainer proposedSourceFlowElements: sourceElements proposedTargetFlowElements: targetElements currentBounds: currentBounds proposedBounds: proposedBounds stagedLabel: aLabel stagedNestedFlowElements: nestedElements [
	^ self new
		flowNode: aFlowNode;
		shape: aShape;
		sourceContainer: aSourceContainer;
		targetContainer: aTargetContainer;
		proposedSourceFlowElements: sourceElements;
		proposedTargetFlowElements: targetElements;
		currentBounds: currentBounds;
		proposedBounds: proposedBounds;
		stagedLabel: aLabel;
		stagedNestedFlowElements: nestedElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierTransferFlowNodeAssessment class >> flowNode: aFlowNode rejectedBecause: aString [
	^ self new flowNode: aFlowNode; rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> flowNode [ ^ flowNode ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> sourceContainer [ ^ sourceContainer ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> sourceContainer: anObject [ sourceContainer := anObject ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> targetContainer [ ^ targetContainer ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> targetContainer: anObject [ targetContainer := anObject ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> proposedSourceFlowElements [ ^ proposedSourceFlowElements ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> proposedSourceFlowElements: aCollection [ proposedSourceFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> proposedTargetFlowElements [ ^ proposedTargetFlowElements ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> proposedTargetFlowElements: aCollection [ proposedTargetFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> currentBounds [ ^ currentBounds ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> currentBounds: aRectangle [ currentBounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> proposedBounds [ ^ proposedBounds ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> proposedBounds: aRectangle [ proposedBounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> stagedLabel [ ^ stagedLabel ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> stagedLabel: anObject [ stagedLabel := anObject ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> stagedNestedFlowElements [ ^ stagedNestedFlowElements ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodeAssessment >> stagedNestedFlowElements: aCollection [ stagedNestedFlowElements := aCollection ]
