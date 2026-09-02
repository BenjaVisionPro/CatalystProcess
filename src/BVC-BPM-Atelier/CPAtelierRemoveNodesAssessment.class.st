"I describe one assessment of removing several existing process nodes together with every currently staged edge incident to any removed node."
Class {
	#name : 'CPAtelierRemoveNodesAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'removedNodes',
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
CPAtelierRemoveNodesAssessment class >> removedNodes: someNodes nodes: nodes edges: edges proposedNodes: proposedNodes proposedEdges: proposedEdges removedEdges: removedEdges [
	^ self new
		removedNodes: someNodes;
		nodes: nodes;
		edges: edges;
		proposedNodes: proposedNodes;
		proposedEdges: proposedEdges;
		removedEdges: removedEdges;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveNodesAssessment class >> removedNodes: someNodes nodes: nodes edges: edges rejectedBecause: aString [
	^ self new
		removedNodes: someNodes;
		nodes: nodes;
		edges: edges;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> removedNodes [ ^ removedNodes ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> removedNodes: aCollection [ removedNodes := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> nodes [ ^ nodes ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> nodes: aCollection [ nodes := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> edges [ ^ edges ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> edges: aCollection [ edges := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> proposedNodes [ ^ proposedNodes ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> proposedNodes: aCollection [ proposedNodes := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> proposedEdges [ ^ proposedEdges ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> proposedEdges: aCollection [ proposedEdges := aCollection ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> removedEdges [ ^ removedEdges ]
{ #category : 'accessing' }
CPAtelierRemoveNodesAssessment >> removedEdges: aCollection [ removedEdges := aCollection ]
