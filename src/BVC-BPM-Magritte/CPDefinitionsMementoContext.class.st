"I provide staged document access to one CPDefinitions transaction.

I own the memento/description pairing for Definitions root elements and diagrams. Semantic and depiction collaborators ask me for exact staged children rather than rediscovering document structure from Magritte descriptions."
Class {
	#name : 'CPDefinitionsMementoContext',
	#superclass : 'Object',
	#instVars : [
		'definitionsMemento',
		'rootElementsDescription',
		'diagramsDescription'
	],
	#category : 'BVC-BPM-Magritte-Document',
	#package : 'BVC-BPM-Magritte',
	#tag : 'Document'
}

{ #category : 'instance creation' }
CPDefinitionsMementoContext class >> memento: aDefinitionsMemento [
	^ self new
		definitionsMemento: aDefinitionsMemento;
		rootElementsDescription: aDefinitionsMemento model rootElementsDescription;
		diagramsDescription: aDefinitionsMemento model diagramsDescription;
		yourself
]

{ #category : 'accessing' }
CPDefinitionsMementoContext >> definitionsMemento [
	^ definitionsMemento
]

{ #category : 'private - initialization' }
CPDefinitionsMementoContext >> definitionsMemento: aMemento [
	definitionsMemento := aMemento
]

{ #category : 'private - initialization' }
CPDefinitionsMementoContext >> rootElementsDescription: aDescription [
	rootElementsDescription := aDescription
]

{ #category : 'private - initialization' }
CPDefinitionsMementoContext >> diagramsDescription: aDescription [
	diagramsDescription := aDescription
]

{ #category : 'staged state' }
CPDefinitionsMementoContext >> rootElements [
	^ definitionsMemento readUsing: rootElementsDescription
]

{ #category : 'staged state' }
CPDefinitionsMementoContext >> diagrams [
	^ definitionsMemento readUsing: diagramsDescription
]

{ #category : 'staged state' }
CPDefinitionsMementoContext >> mementoForRootElement: aRootElement [
	^ definitionsMemento
		childMementoFor: aRootElement
		inRelation: rootElementsDescription
]

{ #category : 'staged state' }
CPDefinitionsMementoContext >> mementoForDiagram: aDiagram [
	^ definitionsMemento
		childMementoFor: aDiagram
		inRelation: diagramsDescription
]

{ #category : 'staged state' }
CPDefinitionsMementoContext >> diagramContextFor: aDiagram [
	^ CPDiagramMementoContext
		diagram: aDiagram
		inMemento: definitionsMemento
		using: diagramsDescription
]

{ #category : 'resolving' }
CPDefinitionsMementoContext >> diagramsDepicting: aModelElement [
	^ self diagrams select: [ :each |
		(self diagramContextFor: each) planeModelElement == aModelElement ]
]


{ #category : 'resolving' }
CPDefinitionsMementoContext >> diagramsForProcess: aProcess [
	| depictedElements collaboration |
	depictedElements := OrderedCollection with: aProcess.
	collaboration := aProcess definitionalCollaborationRef.
	collaboration ifNotNil: [ depictedElements add: collaboration ].
	^ self diagrams select: [ :each |
		depictedElements identityIncludes: (self diagramContextFor: each) planeModelElement ]
]


{ #category : 'validation' }
CPDefinitionsMementoContext >> validateRootElements: aCollection [
	^ rootElementsDescription validate: aCollection
]

{ #category : 'validation' }
CPDefinitionsMementoContext >> validateDiagrams: aCollection [
	^ diagramsDescription validate: aCollection
]

{ #category : 'staged state' }
CPDefinitionsMementoContext >> writeRootElements: aCollection [
	definitionsMemento write: aCollection using: rootElementsDescription
]

{ #category : 'staged state' }
CPDefinitionsMementoContext >> writeDiagrams: aCollection [
	definitionsMemento write: aCollection using: diagramsDescription
]

{ #category : 'staged state' }
CPDefinitionsMementoContext >> detachRootElement: aRootElement [
	definitionsMemento detachChildMementoFor: aRootElement inRelation: rootElementsDescription
]

{ #category : 'staged state' }
CPDefinitionsMementoContext >> detachDiagram: aDiagram [
	definitionsMemento detachChildMementoFor: aDiagram inRelation: diagramsDescription
]
