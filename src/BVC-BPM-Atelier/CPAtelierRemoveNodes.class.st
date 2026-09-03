"I coordinate one BPM editing intention: remove several existing process nodes and every edge incident to any of them from the current staged process design.

I am the multi-selection counterpart of CPAtelierRemoveNode. Assessment derives complete replacement node and edge collections and validates both before mutation. apply stages the complete relation writes only after CFAtelierOperation's fresh reassessment, so a multi-node delete is one semantic intention rather than a sequence of partially successful single-node deletes."
Class {
	#name : 'CPAtelierRemoveNodes',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'nodesToRemove',
		'processMemento',
		'nodesDescription',
		'edgesDescription'
	],
	#category : 'BVC-BPM-Atelier-Removal',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Removal'
}

{ #category : 'instance creation' }
CPAtelierRemoveNodes class >> nodes: someNodes processMemento: aMemento nodesDescription: aNodesDescription edgesDescription: anEdgesDescription [
	^ self new
		nodesToRemove: someNodes;
		processMemento: aMemento;
		nodesDescription: aNodesDescription;
		edgesDescription: anEdgesDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierRemoveNodes >> assess [
	| nodes edges removedEdges proposedNodes proposedEdges |
	nodes := processMemento readUsing: nodesDescription.
	edges := processMemento readUsing: edgesDescription.

	nodes ifNil: [ ^ self rejectedWithNodes: nodes edges: edges because: 'The process has no nodes collection.' ].
	edges ifNil: [ ^ self rejectedWithNodes: nodes edges: edges because: 'The process has no edges collection.' ].
	nodesToRemove ifEmpty: [ ^ self rejectedWithNodes: nodes edges: edges because: 'At least one process node is required for removal.' ].
	nodesDescription isReadOnly ifTrue: [ ^ self rejectedWithNodes: nodes edges: edges because: 'The nodes relation is read-only.' ].
	(nodesDescription isMultiple and: [ edgesDescription isMultiple ]) ifFalse: [
		^ self rejectedWithNodes: nodes edges: edges because: 'Node removal requires to-many nodes and edges relations.' ].
	(self hasDuplicateRequestedIdentity) ifTrue: [
		^ self rejectedWithNodes: nodes edges: edges because: 'Each removed process node identity may be requested only once.' ].
	nodesToRemove do: [ :aNode |
		(aNode isKindOf: CPProcessDesignNode) ifFalse: [
			^ self rejectedWithNodes: nodes edges: edges because: 'Every removed object must be a process design node.' ].
		(nodes count: [ :each | each == aNode ]) = 1 ifFalse: [
			^ self rejectedWithNodes: nodes edges: edges because: 'Every removed node must occur exactly once in the process.' ] ].

	removedEdges := edges select: [ :anEdge |
		nodesToRemove anySatisfy: [ :aNode |
			(self stagedSourceNodeOf: anEdge) == aNode
				or: [ (self stagedTargetNodeOf: anEdge) == aNode ] ] ].
	removedEdges isEmpty ifFalse: [
		edgesDescription isReadOnly ifTrue: [
			^ self rejectedWithNodes: nodes edges: edges because: 'Incident edges cannot be removed because the edges relation is read-only.' ].
		(nodesDescription autoAccept or: [ edgesDescription autoAccept ]) ifTrue: [
			^ self rejectedWithNodes: nodes edges: edges because: 'Removing connected nodes requires staged nodes and edges relations; an affected relation is auto-accepting.' ] ].

	proposedNodes := nodes species withAll: (nodes reject: [ :each |
		nodesToRemove anySatisfy: [ :aNode | each == aNode ] ]).
	proposedEdges := edges species withAll: (edges reject: [ :anEdge |
		nodesToRemove anySatisfy: [ :aNode |
			(self stagedSourceNodeOf: anEdge) == aNode
				or: [ (self stagedTargetNodeOf: anEdge) == aNode ] ] ]).

	[ nodesDescription validate: proposedNodes ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedWithNodes: nodes edges: edges because: anException printString ].
	[ edgesDescription validate: proposedEdges ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedWithNodes: nodes edges: edges because: anException printString ].

	^ CPAtelierRemoveNodesAssessment
		removedNodes: nodesToRemove
		nodes: nodes
		edges: edges
		proposedNodes: proposedNodes
		proposedEdges: proposedEdges
		removedEdges: removedEdges
]

{ #category : 'applying' }
CPAtelierRemoveNodes >> applyAssessment: anAssessment [
	processMemento write: anAssessment proposedNodes using: nodesDescription.
	anAssessment removedEdges isEmpty ifFalse: [
		processMemento write: anAssessment proposedEdges using: edgesDescription ].
	anAssessment removedNodes do: [ :aNode |
		processMemento detachChildMementoFor: aNode inRelation: nodesDescription ].
	anAssessment removedEdges do: [ :anEdge |
		processMemento detachChildMementoFor: anEdge inRelation: edgesDescription ]
]

{ #category : 'private' }
CPAtelierRemoveNodes >> hasDuplicateRequestedIdentity [
	nodesToRemove withIndexDo: [ :aNode :anIndex |
		(anIndex + 1 to: nodesToRemove size) do: [ :anotherIndex |
			(aNode == (nodesToRemove at: anotherIndex)) ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : 'accessing' }
CPAtelierRemoveNodes >> nodesToRemove [ ^ nodesToRemove ]
{ #category : 'accessing' }
CPAtelierRemoveNodes >> nodesToRemove: aCollection [ nodesToRemove := aCollection asArray ]
{ #category : 'accessing' }
CPAtelierRemoveNodes >> processMemento [ ^ processMemento ]
{ #category : 'accessing' }
CPAtelierRemoveNodes >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierRemoveNodes >> nodesDescription [ ^ nodesDescription ]
{ #category : 'accessing' }
CPAtelierRemoveNodes >> nodesDescription: aDescription [ nodesDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierRemoveNodes >> edgesDescription [ ^ edgesDescription ]
{ #category : 'accessing' }
CPAtelierRemoveNodes >> edgesDescription: aDescription [ edgesDescription := aDescription ]

{ #category : 'private' }
CPAtelierRemoveNodes >> rejectedWithNodes: nodes edges: edges because: aString [
	^ CPAtelierRemoveNodesAssessment
		removedNodes: nodesToRemove
		nodes: nodes
		edges: edges
		rejectedBecause: aString
]

{ #category : 'private - staged edges' }
CPAtelierRemoveNodes >> stagedSourceNodeOf: anEdge [
	(processMemento hasChildMementoFor: anEdge inRelation: edgesDescription) ifFalse: [ ^ anEdge sourceNode ].
	^ (processMemento childMementoFor: anEdge inRelation: edgesDescription)
		readUsing: anEdge sourceNodeDescription
]

{ #category : 'private - staged edges' }
CPAtelierRemoveNodes >> stagedTargetNodeOf: anEdge [
	(processMemento hasChildMementoFor: anEdge inRelation: edgesDescription) ifFalse: [ ^ anEdge targetNode ].
	^ (processMemento childMementoFor: anEdge inRelation: edgesDescription)
		readUsing: anEdge targetNodeDescription
]
