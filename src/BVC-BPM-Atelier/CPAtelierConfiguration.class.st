"I configure Foundation Atelier with BPM-specific editing semantics that are already proven by BPM operations.

I do not choose a presentation and I do not inspect object classes to discover behavior. The client gives me the process relation descriptions explicitly. When the exact nodes relation is the source of a remove intention, I translate that intention to CPAtelierRemoveNode so incident-edge semantics are preserved. Other relations retain Foundation Atelier's ordinary relation removal semantics."
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
	anAtelierViewModel removeOperationFor: [ :anObject :aSourceContext |
		self removeOperationFor: anObject from: aSourceContext ].
	^ anAtelierViewModel
]

{ #category : 'operations' }
CPAtelierConfiguration >> removeOperationFor: anObject from: aSourceContext [
	aSourceContext description == nodesDescription ifTrue: [
		^ CPAtelierRemoveNode
			node: anObject
			processMemento: aSourceContext memento
			nodesDescription: nodesDescription
			edgesDescription: edgesDescription ].
	^ CFAtelierRemove
		object: anObject
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
