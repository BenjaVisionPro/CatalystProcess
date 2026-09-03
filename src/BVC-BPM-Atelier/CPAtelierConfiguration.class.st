"I configure Foundation Atelier with BPM-specific editing semantics that are already proven by BPM operations.

I do not choose a presentation and I do not inspect object classes to discover behavior. The client gives me the process relation descriptions explicitly. For the exact nodes relation I translate fresh insertion to CPAtelierCreateNode and removal to CPAtelierRemoveNode or CPAtelierRemoveNodes, preserving BPM semantics. I also provide the explicit BPM connection intention that creates CPAtelierConnectNodes from a fresh edge plus the two endpoint identities. Other relations retain Foundation Atelier's ordinary relation operations."
Class {
	#name : 'CPAtelierConfiguration',
	#superclass : 'CFAtelierConfiguration',
	#instVars : [
		'nodesDescription',
		'edgesDescription'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

{ #category : 'instance creation' }
CPAtelierConfiguration class >> nodesDescription: aNodesDescription edgesDescription: anEdgesDescription [
	^ self new
		nodesDescription: aNodesDescription;
		edgesDescription: anEdgesDescription;
		yourself
]

{ #category : 'applying' }
CPAtelierConfiguration >> applyEditingTo: anAtelierViewModel [
	super applyEditingTo: anAtelierViewModel.
	anAtelierViewModel
		insertOperationFor: [ :candidate :aMemento :aDescription :anIndex |
			self insertOperationFor: candidate into: aMemento description: aDescription at: anIndex ];
		removeOperationFor: [ :someObjects :aSourceContext |
			self removeOperationFor: someObjects from: aSourceContext ].
	^ anAtelierViewModel
]



{ #category : 'operations' }
CPAtelierConfiguration >> connectOperationFor: anEdge from: aSourceNode to: aTargetNode in: aProcessMemento [
	^ CPAtelierConnectNodes
		edge: anEdge
		sourceNode: aSourceNode
		targetNode: aTargetNode
		processMemento: aProcessMemento
		nodesDescription: nodesDescription
		edgesDescription: edgesDescription
		sourceNodeDescription: anEdge sourceNodeDescription
		targetNodeDescription: anEdge targetNodeDescription
]

{ #category : 'operations' }
CPAtelierConfiguration >> insertOperationFor: aCandidate into: aMemento description: aDescription at: anIndex [
	aDescription == nodesDescription ifTrue: [
		^ CPAtelierCreateNode
			node: aCandidate
			position: nil
			processMemento: aMemento
			nodesDescription: nodesDescription
			at: anIndex ].
	anIndex ifNil: [
		^ CFAtelierInsert
			object: aCandidate
			memento: aMemento
			description: aDescription ].
	^ CFAtelierInsert
		object: aCandidate
		memento: aMemento
		description: aDescription
		at: anIndex
]

{ #category : 'operations' }
CPAtelierConfiguration >> removeOperationFor: someObjects from: aSourceContext [
	aSourceContext description == nodesDescription ifTrue: [
		someObjects size = 1 ifTrue: [
			^ CPAtelierRemoveNode
				node: someObjects first
				processMemento: aSourceContext memento
				nodesDescription: nodesDescription
				edgesDescription: edgesDescription ].
		^ CPAtelierRemoveNodes
			nodes: someObjects
			processMemento: aSourceContext memento
			nodesDescription: nodesDescription
			edgesDescription: edgesDescription ].
	^ CFAtelierRemove
		objects: someObjects
		memento: aSourceContext memento
		description: aSourceContext description
]

{ #category : 'accessing' }
CPAtelierConfiguration >> nodesDescription [
	^ nodesDescription
]

{ #category : 'accessing' }
CPAtelierConfiguration >> nodesDescription: aDescription [
	nodesDescription := aDescription
]

{ #category : 'accessing' }
CPAtelierConfiguration >> edgesDescription [
	^ edgesDescription
]

{ #category : 'accessing' }
CPAtelierConfiguration >> edgesDescription: aDescription [
	edgesDescription := aDescription
]
