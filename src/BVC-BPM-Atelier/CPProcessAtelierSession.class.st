"I identify the transaction, semantic focus and active BPMN depiction for one Process Atelier editing session.

The canonical entry is document-rooted: CPDefinitions owns the transaction, the Process is the semantic focus and the Diagram is an explicitly chosen depiction. The Process-rooted constructor remains temporarily for legacy executable fixtures while they are migrated."
Class {
	#name : 'CPProcessAtelierSession',
	#superclass : 'Object',
	#instVars : [
		'rootMemento',
		'processMemento',
		'diagramContext',
		'documentContext',
		'collaborationContext'
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
		collaborationContext: (CPProcessCollaborationContext inRootMemento: aProcessMemento)
]

{ #category : 'instance creation' }
CPProcessAtelierSession class >> forDefinitions: aDefinitions process: aProcess diagram: aDiagram [
	^ self
		forDefinitionsMemento: (CFMaMemento model: aDefinitions)
		process: aProcess
		diagram: aDiagram
]

{ #category : 'instance creation' }
CPProcessAtelierSession class >> forDefinitionsMemento: aDefinitionsMemento process: aProcess diagram: aDiagram [
	| documentContext processMemento diagramContext collaborationContext |
	documentContext := CPDefinitionsMementoContext memento: aDefinitionsMemento.
	processMemento := documentContext mementoForRootElement: aProcess.
	diagramContext := aDiagram
		ifNil: [ nil ]
		ifNotNil: [ documentContext diagramContextFor: aDiagram ].
	collaborationContext := CPProcessCollaborationContext
		forProcessMemento: processMemento
		documentContext: documentContext
		diagramContext: diagramContext.
	^ self
		rootMemento: aDefinitionsMemento
		processMemento: processMemento
		diagramContext: diagramContext
		documentContext: documentContext
		collaborationContext: collaborationContext
]

{ #category : 'instance creation' }
CPProcessAtelierSession class >> rootMemento: aRootMemento processMemento: aProcessMemento diagramContext: aDiagramContext documentContext: aDocumentContext collaborationContext: aCollaborationContext [
	^ self new
		rootMemento: aRootMemento;
		processMemento: aProcessMemento;
		diagramContext: aDiagramContext;
		documentContext: aDocumentContext;
		collaborationContext: aCollaborationContext;
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


{ #category : 'accessing' }
CPProcessAtelierSession >> collaborationContext [
	^ collaborationContext
]

{ #category : 'accessing' }
CPProcessAtelierSession >> collaborationContext: aContext [
	collaborationContext := aContext
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
