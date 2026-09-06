"I describe one assessment of adding a CPMessageFlow and its Collaboration-owned CPEdge."
Class {
	#name : 'CPAtelierConnectMessageFlowAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'source',
		'target',
		'messageFlow',
		'edge',
		'proposedMessageFlows',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierConnectMessageFlowAssessment class >> source: aSource target: aTarget messageFlow: aMessageFlow edge: anEdge proposedMessageFlows: someMessageFlows proposedDiagramElements: someDiagramElements [
	^ self new
		source: aSource;
		target: aTarget;
		messageFlow: aMessageFlow;
		edge: anEdge;
		proposedMessageFlows: someMessageFlows;
		proposedDiagramElements: someDiagramElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierConnectMessageFlowAssessment class >> source: aSource target: aTarget rejectedBecause: aString [
	^ self new
		source: aSource;
		target: aTarget;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> source [ ^ source ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> source: anObject [ source := anObject ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> target [ ^ target ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> target: anObject [ target := anObject ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> messageFlow [ ^ messageFlow ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> messageFlow: anObject [ messageFlow := anObject ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> proposedMessageFlows [ ^ proposedMessageFlows ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> proposedMessageFlows: aCollection [ proposedMessageFlows := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlowAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
