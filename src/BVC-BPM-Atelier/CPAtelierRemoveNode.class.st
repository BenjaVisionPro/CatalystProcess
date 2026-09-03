"I coordinate one BPM editing intention: remove an existing process node and every incident edge from the current staged process design.

CPProcessDesign>>removeNode: establishes the BPM semantic that incident edges disappear with the node. I preserve that semantic through Magritte editing state rather than mutating the model directly. Assessment reads the current staged nodes and edges, derives both complete replacement relation values, validates them without mutation, and records the exact incident edges that would disappear. apply uses CFAtelierOperation's mandatory fresh reassessment before staging the relation writes.

When incident edges exist this is a compound staged operation, so affected auto-accepting descriptions are rejected rather than allowing a partially committed model mutation."
Class {
	#name : 'CPAtelierRemoveNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'node',
		'processMemento',
		'nodesDescription',
		'edgesDescription'
	],
	#category : 'BVC-BPM-Atelier-Removal',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Removal'
}

{ #category : 'instance creation' }
CPAtelierRemoveNode class >> node: aNode processMemento: aMemento nodesDescription: aNodesDescription edgesDescription: anEdgesDescription [
	^ self new
		node: aNode;
		processMemento: aMemento;
		nodesDescription: aNodesDescription;
		edgesDescription: anEdgesDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierRemoveNode >> assess [
	| nodes edges identityCount removedEdges proposedNodes proposedEdges |
	nodes := processMemento readUsing: nodesDescription.
	edges := processMemento readUsing: edgesDescription.

	nodes ifNil: [ ^ self rejectedWithNodes: nodes edges: edges because: 'The process has no nodes collection.' ].
	edges ifNil: [ ^ self rejectedWithNodes: nodes edges: edges because: 'The process has no edges collection.' ].
	nodesDescription isReadOnly
		ifTrue: [ ^ self rejectedWithNodes: nodes edges: edges because: 'The nodes relation is read-only.' ].
	(nodesDescription isMultiple and: [ edgesDescription isMultiple ])
		ifFalse: [ ^ self rejectedWithNodes: nodes edges: edges because: 'Node removal requires to-many nodes and edges relations.' ].

	identityCount := nodes count: [ :each | each == node ].
	identityCount = 1
		ifFalse: [ ^ self rejectedWithNodes: nodes edges: edges because: 'The removed node must occur exactly once in the process.' ].

	removedEdges := edges select: [ :each |
		(self stagedSourceNodeOf: each) == node
			or: [ (self stagedTargetNodeOf: each) == node ] ].
	removedEdges isEmpty ifFalse: [
		edgesDescription isReadOnly
			ifTrue: [ ^ self rejectedWithNodes: nodes edges: edges because: 'Incident edges cannot be removed because the edges relation is read-only.' ].
		(nodesDescription autoAccept or: [ edgesDescription autoAccept ])
			ifTrue: [ ^ self rejectedWithNodes: nodes edges: edges because: 'Removing a connected node requires staged nodes and edges relations; an affected relation is auto-accepting.' ] ].

	proposedNodes := nodes species withAll: (nodes reject: [ :each | each == node ]).
	proposedEdges := edges species withAll: (edges reject: [ :each |
		(self stagedSourceNodeOf: each) == node
			or: [ (self stagedTargetNodeOf: each) == node ] ]).

	[ nodesDescription validate: proposedNodes ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithNodes: nodes edges: edges because: anException printString ].
	[ edgesDescription validate: proposedEdges ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithNodes: nodes edges: edges because: anException printString ].

	^ CPAtelierRemoveNodeAssessment
		node: node
		nodes: nodes
		edges: edges
		proposedNodes: proposedNodes
		proposedEdges: proposedEdges
		removedEdges: removedEdges
]

{ #category : 'applying' }
CPAtelierRemoveNode >> applyAssessment: anAssessment [
	processMemento
		write: anAssessment proposedNodes
		using: nodesDescription.
	anAssessment removedEdges isEmpty ifFalse: [
		processMemento
			write: anAssessment proposedEdges
			using: edgesDescription ].
	processMemento detachChildMementoFor: node inRelation: nodesDescription.
	anAssessment removedEdges do: [ :anEdge |
		processMemento detachChildMementoFor: anEdge inRelation: edgesDescription ]
]

{ #category : 'accessing' }
CPAtelierRemoveNode >> edgesDescription [ ^ edgesDescription ]
{ #category : 'accessing' }
CPAtelierRemoveNode >> edgesDescription: aDescription [ edgesDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierRemoveNode >> node [ ^ node ]
{ #category : 'accessing' }
CPAtelierRemoveNode >> node: anObject [ node := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveNode >> nodesDescription [ ^ nodesDescription ]
{ #category : 'accessing' }
CPAtelierRemoveNode >> nodesDescription: aDescription [ nodesDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierRemoveNode >> processMemento [ ^ processMemento ]
{ #category : 'accessing' }
CPAtelierRemoveNode >> processMemento: aMemento [ processMemento := aMemento ]

{ #category : 'private' }
CPAtelierRemoveNode >> rejectedWithNodes: nodes edges: edges because: aString [
	^ CPAtelierRemoveNodeAssessment
		node: node
		nodes: nodes
		edges: edges
		rejectedBecause: aString
]

{ #category : 'private - staged edges' }
CPAtelierRemoveNode >> stagedSourceNodeOf: anEdge [
	(processMemento hasChildMementoFor: anEdge inRelation: edgesDescription) ifFalse: [ ^ anEdge sourceNode ].
	^ (processMemento childMementoFor: anEdge inRelation: edgesDescription)
		readUsing: anEdge sourceNodeDescription
]

{ #category : 'private - staged edges' }
CPAtelierRemoveNode >> stagedTargetNodeOf: anEdge [
	(processMemento hasChildMementoFor: anEdge inRelation: edgesDescription) ifFalse: [ ^ anEdge targetNode ].
	^ (processMemento childMementoFor: anEdge inRelation: edgesDescription)
		readUsing: anEdge targetNodeDescription
]
