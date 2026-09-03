"I replace one process edge with one supplied edge while preserving BPM endpoint validity.

Generic relation replacement is not sufficient for a process edge because membership of its source and target nodes is a process-level editing invariant. Assessment therefore verifies both replacement endpoint identities against the current staged nodes before validating the complete proposed edges relation. I do not mutate the supplied edge."
Class {
	#name : 'CPAtelierReplaceEdge',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'edge',
		'replacementEdge',
		'processMemento',
		'nodesDescription',
		'edgesDescription'
	],
	#category : 'BVC-BPM-Atelier-Replacement',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Replacement'
}

{ #category : 'instance creation' }
CPAtelierReplaceEdge class >> edge: anEdge with: aReplacementEdge processMemento: aMemento nodesDescription: aNodesDescription edgesDescription: anEdgesDescription [
	^ self new
		edge: anEdge;
		replacementEdge: aReplacementEdge;
		processMemento: aMemento;
		nodesDescription: aNodesDescription;
		edgesDescription: anEdgesDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierReplaceEdge >> assess [
	| nodes edges sourceNode targetNode proposedEdges |
	nodes := processMemento readUsing: nodesDescription.
	edges := processMemento readUsing: edgesDescription.
	nodes ifNil: [ ^ self rejectedWithEdges: edges because: 'The process has no nodes collection.' ].
	edges ifNil: [ ^ self rejectedWithEdges: edges because: 'The process has no edges collection.' ].
	edgesDescription isReadOnly ifTrue: [ ^ self rejectedWithEdges: edges because: 'The edges relation is read-only.' ].
	edgesDescription isMultiple ifFalse: [ ^ self rejectedWithEdges: edges because: 'Process edge replacement requires a to-many edges relation.' ].
	(edge == replacementEdge) ifTrue: [ ^ self rejectedWithEdges: edges because: 'Replacement requires a different edge identity.' ].
	(edges count: [ :each | each == edge ]) = 1 ifFalse: [ ^ self rejectedWithEdges: edges because: 'The replaced edge must occur exactly once in the process.' ].
	(edges anySatisfy: [ :each | each == replacementEdge ]) ifTrue: [ ^ self rejectedWithEdges: edges because: 'The replacement edge is already present in the process.' ].

	sourceNode := replacementEdge sourceNode.
	targetNode := replacementEdge targetNode.
	(nodes anySatisfy: [ :each | each == sourceNode ]) ifFalse: [ ^ self rejectedWithEdges: edges because: 'The replacement edge source node is not present in the process.' ].
	(nodes anySatisfy: [ :each | each == targetNode ]) ifFalse: [ ^ self rejectedWithEdges: edges because: 'The replacement edge target node is not present in the process.' ].

	[ replacementEdge sourceNodeDescription validate: sourceNode ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedWithEdges: edges because: anException printString ].
	[ replacementEdge targetNodeDescription validate: targetNode ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedWithEdges: edges because: anException printString ].

	proposedEdges := edges species withAll: (edges collect: [ :each |
		each == edge ifTrue: [ replacementEdge ] ifFalse: [ each ] ]).
	[ edgesDescription validate: proposedEdges ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedWithEdges: edges because: anException printString ].

	^ CPAtelierReplaceEdgeAssessment
		edge: edge
		replacementEdge: replacementEdge
		edges: edges
		proposedEdges: proposedEdges
]

{ #category : 'applying' }
CPAtelierReplaceEdge >> applyAssessment: anAssessment [
	processMemento write: anAssessment proposedEdges using: edgesDescription.
	processMemento detachChildMementoFor: edge inRelation: edgesDescription.
	processMemento reattachDetachedChildMementoFor: replacementEdge inRelation: edgesDescription
]

{ #category : 'private' }
CPAtelierReplaceEdge >> rejectedWithEdges: someEdges because: aString [
	^ CPAtelierReplaceEdgeAssessment
		edge: edge
		replacementEdge: replacementEdge
		edges: someEdges
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierReplaceEdge >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierReplaceEdge >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierReplaceEdge >> replacementEdge [ ^ replacementEdge ]
{ #category : 'accessing' }
CPAtelierReplaceEdge >> replacementEdge: anObject [ replacementEdge := anObject ]
{ #category : 'accessing' }
CPAtelierReplaceEdge >> processMemento [ ^ processMemento ]
{ #category : 'accessing' }
CPAtelierReplaceEdge >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierReplaceEdge >> nodesDescription [ ^ nodesDescription ]
{ #category : 'accessing' }
CPAtelierReplaceEdge >> nodesDescription: aDescription [ nodesDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierReplaceEdge >> edgesDescription [ ^ edgesDescription ]
{ #category : 'accessing' }
CPAtelierReplaceEdge >> edgesDescription: aDescription [ edgesDescription := aDescription ]
