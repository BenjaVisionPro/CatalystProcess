"I describe one assessment of reconnecting an existing staged CPSequenceFlow while preserving its identity and CPEdge."
Class {
	#name : 'CPAtelierReconnectSequenceFlowAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'sequenceFlow',
		'currentSource',
		'currentTarget',
		'proposedSource',
		'proposedTarget'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReconnectSequenceFlowAssessment class >> sequenceFlow: aSequenceFlow currentSource: aCurrentSource currentTarget: aCurrentTarget proposedSource: aProposedSource proposedTarget: aProposedTarget [
	^ self new
		sequenceFlow: aSequenceFlow;
		currentSource: aCurrentSource;
		currentTarget: aCurrentTarget;
		proposedSource: aProposedSource;
		proposedTarget: aProposedTarget;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReconnectSequenceFlowAssessment class >> sequenceFlow: aSequenceFlow rejectedBecause: aString [
	^ self new
		sequenceFlow: aSequenceFlow;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> sequenceFlow [ ^ sequenceFlow ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> sequenceFlow: anObject [ sequenceFlow := anObject ]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> currentSource [ ^ currentSource ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> currentSource: anObject [ currentSource := anObject ]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> currentTarget [ ^ currentTarget ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> currentTarget: anObject [ currentTarget := anObject ]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> proposedSource [ ^ proposedSource ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> proposedSource: anObject [ proposedSource := anObject ]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> proposedTarget [ ^ proposedTarget ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> proposedTarget: anObject [ proposedTarget := anObject ]
