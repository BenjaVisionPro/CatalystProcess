"I describe one assessment of connecting two existing process design nodes with a fresh edge.

I am deliberately BPM-specific. I retain the observed nodes and edges, the proposed edges collection, the fresh edge, and the source and target nodes so a BPM presentation can preview exactly what was assessed. I do not mutate the design, memento, or fresh edge."
Class {
	#name : 'CPAtelierConnectNodesAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'nodes',
		'edges',
		'proposedEdges',
		'edge',
		'sourceNode',
		'targetNode'
	],
	#category : 'BVC-BPM-Atelier-Connection',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
CPAtelierConnectNodesAssessment class >> nodes: nodes edges: edges proposedEdges: proposedEdges edge: anEdge sourceNode: aSourceNode targetNode: aTargetNode [
	^ self new
		nodes: nodes;
		edges: edges;
		proposedEdges: proposedEdges;
		edge: anEdge;
		sourceNode: aSourceNode;
		targetNode: aTargetNode;
		yourself
]

{ #category : 'instance creation' }
CPAtelierConnectNodesAssessment class >> nodes: nodes edges: edges edge: anEdge sourceNode: aSourceNode targetNode: aTargetNode rejectedBecause: aString [
	^ self new
		nodes: nodes;
		edges: edges;
		edge: anEdge;
		sourceNode: aSourceNode;
		targetNode: aTargetNode;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> edges [ ^ edges ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> edges: aCollection [ edges := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> nodes [ ^ nodes ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> nodes: aCollection [ nodes := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> proposedEdges [ ^ proposedEdges ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> proposedEdges: aCollection [ proposedEdges := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> sourceNode [ ^ sourceNode ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> sourceNode: anObject [ sourceNode := anObject ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> targetNode [ ^ targetNode ]
{ #category : 'accessing' }
CPAtelierConnectNodesAssessment >> targetNode: anObject [ targetNode := anObject ]
