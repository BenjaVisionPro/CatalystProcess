"I coordinate one BPM editing intention: connect two existing CPProcessDesignNode objects with a fresh CPProcessDesignEdge.

The fresh edge is supplied by the BPM client; I do not own construction policy. Assessment reads the current staged nodes and edges, requires both endpoint identities to still belong to the staged process, derives and validates the complete proposed edges relation value, and validates each proposed endpoint against the edge's Magritte descriptions without mutating the fresh edge. apply reassesses immediately before execution, initializes the still-disposable fresh edge, then stages one ordinary Magritte relation write.

I intentionally do not define a generic Atelier connection or creation abstraction."
Class {
	#name : 'CPAtelierConnectNodes',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'edge',
		'sourceNode',
		'targetNode',
		'processMemento',
		'nodesDescription',
		'edgesDescription',
		'sourceNodeDescription',
		'targetNodeDescription'
	],
	#category : 'BVC-BPM-Atelier-Connection',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
CPAtelierConnectNodes class >> edge: anEdge sourceNode: aSourceNode targetNode: aTargetNode processMemento: aMemento nodesDescription: aNodesDescription edgesDescription: anEdgesDescription sourceNodeDescription: aSourceDescription targetNodeDescription: aTargetDescription [
	^ self new
		edge: anEdge;
		sourceNode: aSourceNode;
		targetNode: aTargetNode;
		processMemento: aMemento;
		nodesDescription: aNodesDescription;
		edgesDescription: anEdgesDescription;
		sourceNodeDescription: aSourceDescription;
		targetNodeDescription: aTargetDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierConnectNodes >> assess [
	| nodes edges proposedEdges |
	nodes := processMemento readUsing: nodesDescription.
	edges := processMemento readUsing: edgesDescription.

	(self includesIdentity: sourceNode in: nodes) ifFalse: [
		^ self rejectedWithNodes: nodes edges: edges because: 'The source node is not present in the process.' ].
	(self includesIdentity: targetNode in: nodes) ifFalse: [
		^ self rejectedWithNodes: nodes edges: edges because: 'The target node is not present in the process.' ].
	(self includesIdentity: edge in: edges) ifTrue: [
		^ self rejectedWithNodes: nodes edges: edges because: 'The candidate edge is already present in the process.' ].

	[ sourceNodeDescription validate: sourceNode ]
		on: Error
		do: [ :anException |
			^ self rejectedWithNodes: nodes edges: edges because: anException printString ].
	[ targetNodeDescription validate: targetNode ]
		on: Error
		do: [ :anException |
			^ self rejectedWithNodes: nodes edges: edges because: anException printString ].

	proposedEdges := edges copyWith: edge.
	[ edgesDescription validate: proposedEdges ]
		on: Error
		do: [ :anException |
			^ self rejectedWithNodes: nodes edges: edges because: anException printString ].

	^ CPAtelierConnectNodesAssessment
		nodes: nodes
		edges: edges
		proposedEdges: proposedEdges
		edge: edge
		sourceNode: sourceNode
		targetNode: targetNode
]

{ #category : 'applying' }
CPAtelierConnectNodes >> applyAssessment: anAssessment [
	edge
		sourceNode: sourceNode;
		targetNode: targetNode.
	processMemento
		write: anAssessment proposedEdges
		using: edgesDescription
]

{ #category : 'accessing' }
CPAtelierConnectNodes >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> edgesDescription [ ^ edgesDescription ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> edgesDescription: aDescription [ edgesDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> nodesDescription [ ^ nodesDescription ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> nodesDescription: aDescription [ nodesDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> processMemento [ ^ processMemento ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> sourceNode [ ^ sourceNode ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> sourceNode: anObject [ sourceNode := anObject ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> sourceNodeDescription [ ^ sourceNodeDescription ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> sourceNodeDescription: aDescription [ sourceNodeDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> targetNode [ ^ targetNode ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> targetNode: anObject [ targetNode := anObject ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> targetNodeDescription [ ^ targetNodeDescription ]
{ #category : 'accessing' }
CPAtelierConnectNodes >> targetNodeDescription: aDescription [ targetNodeDescription := aDescription ]

{ #category : 'private' }
CPAtelierConnectNodes >> includesIdentity: anObject in: aCollection [
	^ aCollection anySatisfy: [ :each | each == anObject ]
]

{ #category : 'private' }
CPAtelierConnectNodes >> rejectedWithNodes: nodes edges: edges because: aString [
	^ CPAtelierConnectNodesAssessment
		nodes: nodes
		edges: edges
		edge: edge
		sourceNode: sourceNode
		targetNode: targetNode
		rejectedBecause: aString
]
