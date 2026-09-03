"I describe one assessed replacement of a process node while preserving the process topology by retargeting every incident edge to the replacement node in staged edge child mementos."
Class {
	#name : 'CPAtelierReplaceNodeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'node',
		'replacementNode',
		'nodes',
		'proposedNodes',
		'incidentEdges'
	],
	#category : 'BVC-BPM-Atelier-Replacement',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Replacement'
}

{ #category : 'instance creation' }
CPAtelierReplaceNodeAssessment class >> node: aNode replacementNode: aReplacementNode nodes: nodes proposedNodes: proposedNodes incidentEdges: incidentEdges [
	^ self new
		node: aNode;
		replacementNode: aReplacementNode;
		nodes: nodes;
		proposedNodes: proposedNodes;
		incidentEdges: incidentEdges;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReplaceNodeAssessment class >> node: aNode replacementNode: aReplacementNode nodes: nodes rejectedBecause: aString [
	^ self new
		node: aNode;
		replacementNode: aReplacementNode;
		nodes: nodes;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierReplaceNodeAssessment >> node [ ^ node ]
{ #category : 'accessing' }
CPAtelierReplaceNodeAssessment >> node: anObject [ node := anObject ]
{ #category : 'accessing' }
CPAtelierReplaceNodeAssessment >> replacementNode [ ^ replacementNode ]
{ #category : 'accessing' }
CPAtelierReplaceNodeAssessment >> replacementNode: anObject [ replacementNode := anObject ]
{ #category : 'accessing' }
CPAtelierReplaceNodeAssessment >> nodes [ ^ nodes ]
{ #category : 'accessing' }
CPAtelierReplaceNodeAssessment >> nodes: aCollection [ nodes := aCollection ]
{ #category : 'accessing' }
CPAtelierReplaceNodeAssessment >> proposedNodes [ ^ proposedNodes ]
{ #category : 'accessing' }
CPAtelierReplaceNodeAssessment >> proposedNodes: aCollection [ proposedNodes := aCollection ]
{ #category : 'accessing' }
CPAtelierReplaceNodeAssessment >> incidentEdges [ ^ incidentEdges ]
{ #category : 'accessing' }
CPAtelierReplaceNodeAssessment >> incidentEdges: aCollection [ incidentEdges := aCollection ]
