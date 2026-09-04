"I describe one assessment of removing a staged CPSequenceFlow together with every CPEdge that depicts it."
Class {
	#name : 'CPAtelierRemoveSequenceFlowAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'sequenceFlow',
		'proposedFlowElements',
		'proposedDiagramElements',
		'removedEdges'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveSequenceFlowAssessment class >> sequenceFlow: aSequenceFlow proposedFlowElements: someFlowElements proposedDiagramElements: someDiagramElements removedEdges: someEdges [
	^ self new
		sequenceFlow: aSequenceFlow;
		proposedFlowElements: someFlowElements;
		proposedDiagramElements: someDiagramElements;
		removedEdges: someEdges;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveSequenceFlowAssessment class >> sequenceFlow: aSequenceFlow rejectedBecause: aString [
	^ self new sequenceFlow: aSequenceFlow; rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierRemoveSequenceFlowAssessment >> sequenceFlow [ ^ sequenceFlow ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlowAssessment >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlowAssessment >> proposedFlowElements [ ^ proposedFlowElements ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlowAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlowAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlowAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlowAssessment >> removedEdges [ ^ removedEdges ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlowAssessment >> removedEdges: aCollection [ removedEdges := aCollection ]
