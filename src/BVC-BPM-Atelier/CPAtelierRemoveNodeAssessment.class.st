"I describe one assessment of removing an existing process node together with every currently staged incident edge.

I retain the observed and proposed node/edge relation values so a BPM presentation can preview the exact structural consequence that was assessed. removedEdges are derived from the current staged edge value by identity of their source/target endpoints."
Class {
	#name : 'CPAtelierRemoveNodeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'node',
		'nodes',
		'edges',
		'proposedNodes',
		'proposedEdges',
		'removedEdges'
	],
	#category : 'BVC-BPM-Atelier-Removal',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Removal'
}

{ #category : 'instance creation' }
CPAtelierRemoveNodeAssessment class >> node: aNode nodes: nodes edges: edges proposedNodes: proposedNodes proposedEdges: proposedEdges removedEdges: removedEdges [
	^ self new
		node: aNode;
		nodes: nodes;
		edges: edges;
		proposedNodes: proposedNodes;
		proposedEdges: proposedEdges;
		removedEdges: removedEdges;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveNodeAssessment class >> node: aNode nodes: nodes edges: edges rejectedBecause: aString [
	^ self new
		node: aNode;
		nodes: nodes;
		edges: edges;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> edges [ ^ edges ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> edges: aCollection [ edges := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> node [ ^ node ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> node: anObject [ node := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> nodes [ ^ nodes ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> nodes: aCollection [ nodes := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> proposedEdges [ ^ proposedEdges ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> proposedEdges: aCollection [ proposedEdges := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> proposedNodes [ ^ proposedNodes ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> proposedNodes: aCollection [ proposedNodes := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> removedEdges [ ^ removedEdges ]
{ #category : 'accessing' }
CPAtelierRemoveNodeAssessment >> removedEdges: aCollection [ removedEdges := aCollection ]
