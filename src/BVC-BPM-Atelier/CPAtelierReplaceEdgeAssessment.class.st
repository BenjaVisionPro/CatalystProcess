"I describe one assessed BPM edge replacement."
Class {
	#name : 'CPAtelierReplaceEdgeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'edge',
		'replacementEdge',
		'edges',
		'proposedEdges'
	],
	#category : 'BVC-BPM-Atelier-Replacement',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Replacement'
}

{ #category : 'instance creation' }
CPAtelierReplaceEdgeAssessment class >> edge: anEdge replacementEdge: aReplacementEdge edges: someEdges proposedEdges: someProposedEdges [
	^ self new
		edge: anEdge;
		replacementEdge: aReplacementEdge;
		edges: someEdges;
		proposedEdges: someProposedEdges;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReplaceEdgeAssessment class >> edge: anEdge replacementEdge: aReplacementEdge edges: someEdges rejectedBecause: aString [
	^ self new
		edge: anEdge;
		replacementEdge: aReplacementEdge;
		edges: someEdges;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierReplaceEdgeAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierReplaceEdgeAssessment >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierReplaceEdgeAssessment >> replacementEdge [ ^ replacementEdge ]
{ #category : 'accessing' }
CPAtelierReplaceEdgeAssessment >> replacementEdge: anObject [ replacementEdge := anObject ]
{ #category : 'accessing' }
CPAtelierReplaceEdgeAssessment >> edges [ ^ edges ]
{ #category : 'accessing' }
CPAtelierReplaceEdgeAssessment >> edges: aCollection [ edges := aCollection ]
{ #category : 'accessing' }
CPAtelierReplaceEdgeAssessment >> proposedEdges [ ^ proposedEdges ]
{ #category : 'accessing' }
CPAtelierReplaceEdgeAssessment >> proposedEdges: aCollection [ proposedEdges := aCollection ]
