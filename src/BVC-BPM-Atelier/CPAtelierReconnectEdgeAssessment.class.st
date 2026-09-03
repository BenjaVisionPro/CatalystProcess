"I describe one assessment of reconnecting an existing process edge to a supplied pair of endpoint identities.

I retain the edge's authoritative staged endpoints and the proposed endpoints so a BPM presentation can preview the exact reconnection intention. I do not create child editing state during assessment."
Class {
	#name : 'CPAtelierReconnectEdgeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'edge',
		'currentSourceNode',
		'currentTargetNode',
		'proposedSourceNode',
		'proposedTargetNode'
	],
	#category : 'BVC-BPM-Atelier-Connection',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
CPAtelierReconnectEdgeAssessment class >> edge: anEdge currentSourceNode: aCurrentSourceNode currentTargetNode: aCurrentTargetNode proposedSourceNode: aProposedSourceNode proposedTargetNode: aProposedTargetNode [
	^ self new
		edge: anEdge;
		currentSourceNode: aCurrentSourceNode;
		currentTargetNode: aCurrentTargetNode;
		proposedSourceNode: aProposedSourceNode;
		proposedTargetNode: aProposedTargetNode;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReconnectEdgeAssessment class >> edge: anEdge currentSourceNode: aCurrentSourceNode currentTargetNode: aCurrentTargetNode proposedSourceNode: aProposedSourceNode proposedTargetNode: aProposedTargetNode rejectedBecause: aString [
	^ self new
		edge: anEdge;
		currentSourceNode: aCurrentSourceNode;
		currentTargetNode: aCurrentTargetNode;
		proposedSourceNode: aProposedSourceNode;
		proposedTargetNode: aProposedTargetNode;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierReconnectEdgeAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierReconnectEdgeAssessment >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectEdgeAssessment >> currentSourceNode [ ^ currentSourceNode ]
{ #category : 'accessing' }
CPAtelierReconnectEdgeAssessment >> currentSourceNode: anObject [ currentSourceNode := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectEdgeAssessment >> currentTargetNode [ ^ currentTargetNode ]
{ #category : 'accessing' }
CPAtelierReconnectEdgeAssessment >> currentTargetNode: anObject [ currentTargetNode := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectEdgeAssessment >> proposedSourceNode [ ^ proposedSourceNode ]
{ #category : 'accessing' }
CPAtelierReconnectEdgeAssessment >> proposedSourceNode: anObject [ proposedSourceNode := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectEdgeAssessment >> proposedTargetNode [ ^ proposedTargetNode ]
{ #category : 'accessing' }
CPAtelierReconnectEdgeAssessment >> proposedTargetNode: anObject [ proposedTargetNode := anObject ]
