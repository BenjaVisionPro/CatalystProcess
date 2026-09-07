"I describe one assessment of reconnecting an existing staged CPMessageFlow while preserving its semantic and Collaboration CPEdge identities."
Class {
	#name : 'CPAtelierReconnectMessageFlowAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'messageFlow',
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
CPAtelierReconnectMessageFlowAssessment class >> messageFlow: aMessageFlow currentSource: aCurrentSource currentTarget: aCurrentTarget proposedSource: aProposedSource proposedTarget: aProposedTarget [
	^ self new
		messageFlow: aMessageFlow;
		currentSource: aCurrentSource;
		currentTarget: aCurrentTarget;
		proposedSource: aProposedSource;
		proposedTarget: aProposedTarget;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReconnectMessageFlowAssessment class >> messageFlow: aMessageFlow rejectedBecause: aString [
	^ self new
		messageFlow: aMessageFlow;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierReconnectMessageFlowAssessment >> messageFlow [ ^ messageFlow ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlowAssessment >> messageFlow: anObject [ messageFlow := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlowAssessment >> currentSource [ ^ currentSource ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlowAssessment >> currentSource: anObject [ currentSource := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlowAssessment >> currentTarget [ ^ currentTarget ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlowAssessment >> currentTarget: anObject [ currentTarget := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlowAssessment >> proposedSource [ ^ proposedSource ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlowAssessment >> proposedSource: anObject [ proposedSource := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlowAssessment >> proposedTarget [ ^ proposedTarget ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlowAssessment >> proposedTarget: anObject [ proposedTarget := anObject ]
