"I describe one assessment of adding a CPSequenceFlow and its CPEdge depiction between two staged flow nodes."
Class {
	#name : 'CPAtelierConnectFlowNodesAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'source',
		'target',
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
CPAtelierConnectFlowNodesAssessment class >> source: aSource target: aTarget sequenceFlow: aFlow edge: anEdge proposedFlowElements: someFlowElements proposedDiagramElements: someDiagramElements [
	^ self new source: aSource; target: aTarget; sequenceFlow: aFlow; edge: anEdge; proposedFlowElements: someFlowElements; proposedDiagramElements: someDiagramElements; yourself
]
{ #category : 'instance creation' }
CPAtelierConnectFlowNodesAssessment class >> source: aSource target: aTarget rejectedBecause: aString [
	^ self new source: aSource; target: aTarget; rejectionMessage: aString; yourself
]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> source [ ^ source ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> source: anObject [ source := anObject ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> target [ ^ target ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> target: anObject [ target := anObject ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> sequenceFlow [ ^ sequenceFlow ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> proposedFlowElements [ ^ proposedFlowElements ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodesAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
