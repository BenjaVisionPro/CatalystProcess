"I describe one assessment of removing a staged CPFlowNode, its CPShape, and every incident CPSequenceFlow/CPEdge."
Class {
	#name : 'CPAtelierRemoveFlowNodeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'flowNode',
		'removedFlowNodes',
		'removedSequenceFlows',
		'removedDiagramElements',
		'proposedFlowElements',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveFlowNodeAssessment class >> flowNode: aFlowNode removedFlowNodes: someFlowNodes removedSequenceFlows: someFlows removedDiagramElements: someDiagramElements proposedFlowElements: someFlowElements proposedDiagramElements: proposedDiagramElements [
	^ self new
		flowNode: aFlowNode;
		removedFlowNodes: someFlowNodes;
		removedSequenceFlows: someFlows;
		removedDiagramElements: someDiagramElements;
		proposedFlowElements: someFlowElements;
		proposedDiagramElements: proposedDiagramElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveFlowNodeAssessment class >> flowNode: aFlowNode rejectedBecause: aString [
	^ self new flowNode: aFlowNode; rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> flowNode [ ^ flowNode ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> removedFlowNodes [ ^ removedFlowNodes ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> removedFlowNodes: aCollection [ removedFlowNodes := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> removedSequenceFlows [ ^ removedSequenceFlows ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> removedSequenceFlows: aCollection [ removedSequenceFlows := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> removedDiagramElements [ ^ removedDiagramElements ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> removedDiagramElements: aCollection [ removedDiagramElements := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> proposedFlowElements [ ^ proposedFlowElements ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNodeAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
