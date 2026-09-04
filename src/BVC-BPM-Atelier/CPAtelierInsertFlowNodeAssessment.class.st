Class {
	#name : 'CPAtelierInsertFlowNodeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'sequenceFlow',
		'flowNode',
		'shape',
		'firstSequenceFlow',
		'secondSequenceFlow',
		'firstEdge',
		'secondEdge',
		'removedEdge',
		'proposedFlowElements',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierInsertFlowNodeAssessment class >> sequenceFlow: oldFlow flowNode: aFlowNode shape: aShape firstSequenceFlow: firstFlow secondSequenceFlow: secondFlow firstEdge: firstEdge secondEdge: secondEdge removedEdge: oldEdge proposedFlowElements: someFlowElements proposedDiagramElements: someElements [
	^ self new
		sequenceFlow: oldFlow;
		flowNode: aFlowNode;
		shape: aShape;
		firstSequenceFlow: firstFlow;
		secondSequenceFlow: secondFlow;
		firstEdge: firstEdge;
		secondEdge: secondEdge;
		removedEdge: oldEdge;
		proposedFlowElements: someFlowElements;
		proposedDiagramElements: someElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierInsertFlowNodeAssessment class >> sequenceFlow: oldFlow flowNode: aFlowNode rejectedBecause: aString [
	^ self new
		sequenceFlow: oldFlow;
		flowNode: aFlowNode;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> sequenceFlow [ ^ sequenceFlow ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> flowNode [ ^ flowNode ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> firstSequenceFlow [ ^ firstSequenceFlow ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> firstSequenceFlow: anObject [ firstSequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> secondSequenceFlow [ ^ secondSequenceFlow ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> secondSequenceFlow: anObject [ secondSequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> firstEdge [ ^ firstEdge ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> firstEdge: anObject [ firstEdge := anObject ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> secondEdge [ ^ secondEdge ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> secondEdge: anObject [ secondEdge := anObject ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> removedEdge [ ^ removedEdge ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> removedEdge: anObject [ removedEdge := anObject ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> proposedFlowElements [ ^ proposedFlowElements ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierInsertFlowNodeAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
