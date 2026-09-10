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
