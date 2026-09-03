"I replace one existing process node with one supplied node while preserving every incident edge identity and retargeting its endpoint from the old node to the replacement node.

The nodes relation and edge endpoint edits all remain staged in the same CFMaMemento transaction. Assessment derives and validates the complete proposed nodes value and validates each affected endpoint without mutating either process or edge models. apply uses CFAtelierOperation's fresh reassessment, stages the nodes replacement, then stages endpoint changes through the existing edge child mementos."
Class {
	#name : 'CPAtelierReplaceNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'node',
		'replacementNode',
		'processMemento',
		'nodesDescription',
		'edgesDescription'
	],
	#category : 'BVC-BPM-Atelier-Replacement',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Replacement'
}

{ #category : 'instance creation' }
CPAtelierReplaceNode class >> node: aNode with: aReplacementNode processMemento: aMemento nodesDescription: aNodesDescription edgesDescription: anEdgesDescription [
	^ self new
		node: aNode;
		replacementNode: aReplacementNode;
		processMemento: aMemento;
		nodesDescription: aNodesDescription;
		edgesDescription: anEdgesDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierReplaceNode >> assess [
	| nodes edges proposedNodes incidentEdges sourceDescription targetDescription |
	nodes := processMemento readUsing: nodesDescription.
	edges := processMemento readUsing: edgesDescription.
	nodes ifNil: [ ^ self rejectedWithNodes: nodes because: 'The process has no nodes collection.' ].
	edges ifNil: [ ^ self rejectedWithNodes: nodes because: 'The process has no edges collection.' ].
	nodesDescription isReadOnly ifTrue: [ ^ self rejectedWithNodes: nodes because: 'The nodes relation is read-only.' ].
	nodesDescription isMultiple ifFalse: [ ^ self rejectedWithNodes: nodes because: 'Process node replacement requires a to-many nodes relation.' ].
	(node == replacementNode) ifTrue: [ ^ self rejectedWithNodes: nodes because: 'Replacement requires a different node identity.' ].
	(nodes count: [ :each | each == node ]) = 1 ifFalse: [ ^ self rejectedWithNodes: nodes because: 'The replaced node must occur exactly once in the process.' ].
	(nodes anySatisfy: [ :each | each == replacementNode ]) ifTrue: [ ^ self rejectedWithNodes: nodes because: 'The replacement node is already present in the process.' ].

	proposedNodes := nodes species withAll: (nodes collect: [ :each | each == node ifTrue: [ replacementNode ] ifFalse: [ each ] ]).
	[ nodesDescription validate: proposedNodes ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedWithNodes: nodes because: anException printString ].

	incidentEdges := edges select: [ :each | each sourceNode == node or: [ each targetNode == node ] ].
	incidentEdges isEmpty ifFalse: [
		(nodesDescription autoAccept or: [ edgesDescription autoAccept ]) ifTrue: [
			^ self rejectedWithNodes: nodes because: 'Replacing a connected node requires staged node and edge editing state; an affected relation is auto-accepting.' ] ].

	incidentEdges do: [ :anEdge |
		sourceDescription := anEdge sourceNodeDescription.
		targetDescription := anEdge targetNodeDescription.
		(anEdge sourceNode == node) ifTrue: [
			sourceDescription isReadOnly ifTrue: [ ^ self rejectedWithNodes: nodes because: 'An incident edge source is read-only.' ].
			[ sourceDescription validate: replacementNode ]
				on: MAValidationError
				do: [ :anException | ^ self rejectedWithNodes: nodes because: anException printString ] ].
		(anEdge targetNode == node) ifTrue: [
			targetDescription isReadOnly ifTrue: [ ^ self rejectedWithNodes: nodes because: 'An incident edge target is read-only.' ].
			[ targetDescription validate: replacementNode ]
				on: MAValidationError
				do: [ :anException | ^ self rejectedWithNodes: nodes because: anException printString ] ] ].

	^ CPAtelierReplaceNodeAssessment
		node: node
		replacementNode: replacementNode
		nodes: nodes
		proposedNodes: proposedNodes
		incidentEdges: incidentEdges
]

{ #category : 'applying' }
CPAtelierReplaceNode >> applyAssessment: anAssessment [
	processMemento write: anAssessment proposedNodes using: nodesDescription.
	anAssessment incidentEdges do: [ :anEdge |
		| edgeMemento |
		edgeMemento := processMemento childMementoFor: anEdge inRelation: edgesDescription.
		(anEdge sourceNode == node) ifTrue: [ edgeMemento write: replacementNode using: anEdge sourceNodeDescription ].
		(anEdge targetNode == node) ifTrue: [ edgeMemento write: replacementNode using: anEdge targetNodeDescription ] ].
	processMemento detachChildMementoFor: node inRelation: nodesDescription.
	processMemento reattachDetachedChildMementoFor: replacementNode inRelation: nodesDescription
]

{ #category : 'accessing' }
CPAtelierReplaceNode >> node [ ^ node ]
{ #category : 'accessing' }
CPAtelierReplaceNode >> node: anObject [ node := anObject ]
{ #category : 'accessing' }
CPAtelierReplaceNode >> replacementNode [ ^ replacementNode ]
{ #category : 'accessing' }
CPAtelierReplaceNode >> replacementNode: anObject [ replacementNode := anObject ]
{ #category : 'accessing' }
CPAtelierReplaceNode >> processMemento [ ^ processMemento ]
{ #category : 'accessing' }
CPAtelierReplaceNode >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierReplaceNode >> nodesDescription [ ^ nodesDescription ]
{ #category : 'accessing' }
CPAtelierReplaceNode >> nodesDescription: aDescription [ nodesDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierReplaceNode >> edgesDescription [ ^ edgesDescription ]
{ #category : 'accessing' }
CPAtelierReplaceNode >> edgesDescription: aDescription [ edgesDescription := aDescription ]

{ #category : 'private' }
CPAtelierReplaceNode >> rejectedWithNodes: nodes because: aString [
	^ CPAtelierReplaceNodeAssessment node: node replacementNode: replacementNode nodes: nodes rejectedBecause: aString
]
