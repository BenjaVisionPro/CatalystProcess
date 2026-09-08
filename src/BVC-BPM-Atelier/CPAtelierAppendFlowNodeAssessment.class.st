"I describe one assessment of atomically appending a fresh flow node and sequence flow after one staged source node."
Class {
	#name : 'CPAtelierAppendFlowNodeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'source',
		'flowNode',
		'shape',
		'sequenceFlow',
		'edge',
		'proposedFlowElements',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierAppendFlowNodeAssessment class >> source: aSource flowNode: aFlowNode shape: aShape sequenceFlow: aFlow edge: anEdge proposedFlowElements: someFlowElements proposedDiagramElements: someDiagramElements [
	^ self new
		source: aSource;
		flowNode: aFlowNode;
		shape: aShape;
		sequenceFlow: aFlow;
		edge: anEdge;
		proposedFlowElements: someFlowElements;
		proposedDiagramElements: someDiagramElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierAppendFlowNodeAssessment class >> source: aSource flowNode: aFlowNode rejectedBecause: aString [
	^ self new source: aSource; flowNode: aFlowNode; rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> source [ ^ source ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> source: anObject [ source := anObject ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> flowNode [ ^ flowNode ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> sequenceFlow [ ^ sequenceFlow ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> proposedFlowElements [ ^ proposedFlowElements ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierAppendFlowNodeAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
