"I reconnect one existing process edge while preserving its identity.

This is a diagram editing intention, not edge replacement. Assessment requires the edge to still occur exactly once in the staged process, reads any already-staged endpoints without creating child editing state, verifies both proposed endpoint identities still belong to the staged nodes relation, and validates them through the edge's Magritte descriptions. apply stages endpoint changes through the edge's existing child memento in the same Process transaction."
Class {
	#name : 'CPAtelierReconnectEdge',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'edge',
		'sourceNode',
		'targetNode',
		'processMemento',
		'nodesDescription',
		'edgesDescription'
	],
	#category : 'BVC-BPM-Atelier-Connection',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Connection'
}

{ #category : 'instance creation' }
CPAtelierReconnectEdge class >> edge: anEdge sourceNode: aSourceNode targetNode: aTargetNode processMemento: aMemento nodesDescription: aNodesDescription edgesDescription: anEdgesDescription [
	^ self new
		edge: anEdge;
		sourceNode: aSourceNode;
		targetNode: aTargetNode;
		processMemento: aMemento;
		nodesDescription: aNodesDescription;
		edgesDescription: anEdgesDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierReconnectEdge >> assess [
	| nodes edges currentSource currentTarget sourceDescription targetDescription |
	nodes := processMemento readUsing: nodesDescription.
	edges := processMemento readUsing: edgesDescription.
	nodes ifNil: [ ^ self rejectedWithCurrentSource: nil target: nil because: 'The process has no nodes collection.' ].
	edges ifNil: [ ^ self rejectedWithCurrentSource: nil target: nil because: 'The process has no edges collection.' ].
	(edges count: [ :each | each == edge ]) = 1 ifFalse: [
		^ self rejectedWithCurrentSource: nil target: nil because: 'The reconnected edge must occur exactly once in the process.' ].

	currentSource := self stagedSourceNode.
	currentTarget := self stagedTargetNode.
	(currentSource == sourceNode and: [ currentTarget == targetNode ]) ifTrue: [
		^ self rejectedWithCurrentSource: currentSource target: currentTarget because: 'The edge already has those endpoints.' ].
	(nodes anySatisfy: [ :each | each == sourceNode ]) ifFalse: [
		^ self rejectedWithCurrentSource: currentSource target: currentTarget because: 'The source node is not present in the process.' ].
	(nodes anySatisfy: [ :each | each == targetNode ]) ifFalse: [
		^ self rejectedWithCurrentSource: currentSource target: currentTarget because: 'The target node is not present in the process.' ].

	sourceDescription := edge sourceNodeDescription.
	targetDescription := edge targetNodeDescription.
	sourceDescription isReadOnly ifTrue: [
		^ self rejectedWithCurrentSource: currentSource target: currentTarget because: 'The edge source is read-only.' ].
	targetDescription isReadOnly ifTrue: [
		^ self rejectedWithCurrentSource: currentSource target: currentTarget because: 'The edge target is read-only.' ].
	[ sourceDescription validate: sourceNode ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedWithCurrentSource: currentSource target: currentTarget because: anException printString ].
	[ targetDescription validate: targetNode ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedWithCurrentSource: currentSource target: currentTarget because: anException printString ].

	^ CPAtelierReconnectEdgeAssessment
		edge: edge
		currentSourceNode: currentSource
		currentTargetNode: currentTarget
		proposedSourceNode: sourceNode
		proposedTargetNode: targetNode
]

{ #category : 'applying' }
CPAtelierReconnectEdge >> applyAssessment: anAssessment [
	| edgeMemento |
	edgeMemento := processMemento childMementoFor: edge inRelation: edgesDescription.
	edgeMemento write: anAssessment proposedSourceNode using: edge sourceNodeDescription.
	edgeMemento write: anAssessment proposedTargetNode using: edge targetNodeDescription
]

{ #category : 'private - staged edge' }
CPAtelierReconnectEdge >> stagedSourceNode [
	(processMemento hasChildMementoFor: edge inRelation: edgesDescription) ifFalse: [ ^ edge sourceNode ].
	^ (processMemento childMementoFor: edge inRelation: edgesDescription)
		readUsing: edge sourceNodeDescription
]

{ #category : 'private - staged edge' }
CPAtelierReconnectEdge >> stagedTargetNode [
	(processMemento hasChildMementoFor: edge inRelation: edgesDescription) ifFalse: [ ^ edge targetNode ].
	^ (processMemento childMementoFor: edge inRelation: edgesDescription)
		readUsing: edge targetNodeDescription
]

{ #category : 'private' }
CPAtelierReconnectEdge >> rejectedWithCurrentSource: aSourceNode target: aTargetNode because: aString [
	^ CPAtelierReconnectEdgeAssessment
		edge: edge
		currentSourceNode: aSourceNode
		currentTargetNode: aTargetNode
		proposedSourceNode: sourceNode
		proposedTargetNode: targetNode
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierReconnectEdge >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> sourceNode [ ^ sourceNode ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> sourceNode: anObject [ sourceNode := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> targetNode [ ^ targetNode ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> targetNode: anObject [ targetNode := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> processMemento [ ^ processMemento ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> nodesDescription [ ^ nodesDescription ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> nodesDescription: aDescription [ nodesDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> edgesDescription [ ^ edgesDescription ]
{ #category : 'accessing' }
CPAtelierReconnectEdge >> edgesDescription: aDescription [ edgesDescription := aDescription ]
