"I identify the transaction, semantic focus and active BPMN depiction for one Process Atelier editing session.

A document-rooted session carries a CPDefinitionsMementoContext, one Process child memento and one explicitly chosen depiction. The legacy Process-rooted constructor remains only while CPProcess>>asAtelier still uses the old entry shape."
Class {
	#name : 'CPProcessAtelierSession',
	#superclass : 'Object',
	#instVars : [
		'rootMemento',
		'processMemento',
		'diagramContext',
		'documentContext'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

{ #category : 'instance creation - legacy' }
CPProcessAtelierSession class >> forProcessMemento: aProcessMemento [
	| diagramDescription diagram diagramContext |
	diagramDescription := aProcessMemento model diagramDescription.
	diagram := aProcessMemento readUsing: diagramDescription.
	diagramContext := diagram ifNil: [ nil ] ifNotNil: [
		CPDiagramMementoContext
			diagram: diagram
			inMemento: aProcessMemento
			using: diagramDescription ].
	^ self
		rootMemento: aProcessMemento
		processMemento: aProcessMemento
		diagramContext: diagramContext
		documentContext: nil
]

{ #category : 'instance creation' }
CPProcessAtelierSession class >> forDefinitionsMemento: aDefinitionsMemento process: aProcess diagram: aDiagram [
	| documentContext |
	documentContext := CPDefinitionsMementoContext memento: aDefinitionsMemento.
	^ self
		rootMemento: aDefinitionsMemento
		processMemento: (documentContext mementoForRootElement: aProcess)
		diagramContext: (aDiagram
			ifNil: [ nil ]
			ifNotNil: [ documentContext diagramContextFor: aDiagram ])
		documentContext: documentContext
]

{ #category : 'instance creation' }
CPProcessAtelierSession class >> rootMemento: aRootMemento processMemento: aProcessMemento diagramContext: aDiagramContext documentContext: aDocumentContext [
	^ self new
		rootMemento: aRootMemento;
		processMemento: aProcessMemento;
		diagramContext: aDiagramContext;
		documentContext: aDocumentContext;
		yourself
]

{ #category : 'accessing' }
CPProcessAtelierSession >> rootMemento [
	^ rootMemento
]

{ #category : 'accessing' }
CPProcessAtelierSession >> rootMemento: aMemento [
	rootMemento := aMemento
]

{ #category : 'accessing' }
CPProcessAtelierSession >> processMemento [
	^ processMemento
]

{ #category : 'accessing' }
CPProcessAtelierSession >> processMemento: aMemento [
	processMemento := aMemento
]

{ #category : 'accessing' }
CPProcessAtelierSession >> diagramContext [
	^ diagramContext
]

{ #category : 'accessing' }
CPProcessAtelierSession >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]

{ #category : 'accessing' }
CPProcessAtelierSession >> documentContext [
	^ documentContext
]

{ #category : 'accessing' }
CPProcessAtelierSession >> documentContext: aDocumentContext [
	documentContext := aDocumentContext
]


{ #category : 'converting' }
CPProcessAtelierSession >> asViewModel [
	| viewModel |
	viewModel := CFAtelierViewModel
		forObject: processMemento model
		memento: processMemento.
	viewModel configuration: (CPProcessAtelierConfiguration forSession: self).
	^ viewModel
]
