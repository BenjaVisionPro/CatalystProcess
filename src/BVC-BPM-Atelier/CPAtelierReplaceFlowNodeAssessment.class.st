"I describe one assessed replacement of a staged CPFlowNode. The semantic node identity changes while the existing CPShape, incident CPSequenceFlow objects and CPEdge objects remain the same."
Class {
	#name : 'CPAtelierReplaceFlowNodeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'flowNode',
		'replacementNode',
		'incidentSequenceFlows',
		'shape',
		'proposedFlowElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReplaceFlowNodeAssessment class >> flowNode: aFlowNode replacementNode: aReplacementNode incidentSequenceFlows: someSequenceFlows shape: aShape proposedFlowElements: someFlowElements [
	^ self new
		flowNode: aFlowNode;
		replacementNode: aReplacementNode;
		incidentSequenceFlows: someSequenceFlows;
		shape: aShape;
		proposedFlowElements: someFlowElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReplaceFlowNodeAssessment class >> flowNode: aFlowNode replacementNode: aReplacementNode rejectedBecause: aString [
	^ self new
		flowNode: aFlowNode;
		replacementNode: aReplacementNode;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierReplaceFlowNodeAssessment >> flowNode [ ^ flowNode ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNodeAssessment >> flowNode: anObject [ flowNode := anObject ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNodeAssessment >> replacementNode [ ^ replacementNode ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNodeAssessment >> replacementNode: anObject [ replacementNode := anObject ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNodeAssessment >> incidentSequenceFlows [ ^ incidentSequenceFlows ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNodeAssessment >> incidentSequenceFlows: aCollection [ incidentSequenceFlows := aCollection ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNodeAssessment >> shape [ ^ shape ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNodeAssessment >> shape: anObject [ shape := anObject ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNodeAssessment >> proposedFlowElements [ ^ proposedFlowElements ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNodeAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]
