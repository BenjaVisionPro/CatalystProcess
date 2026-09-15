"I coordinate the Process currently shown inside one Definitions-rooted Atelier.

CPDefinitions remains the transaction and Atelier root. CPProcessAtelierSession owns the Process/Diagram editing session. I only translate Process-row activation into replacement of the existing Atelier workspace and palette."
Class {
	#name : 'CPDefinitionsAtelierCoordinator',
	#superclass : 'Object',
	#instVars : [
		'rootMemento',
		'documentContext',
		'definitionsViewModel',
		'atelierElement',
		'currentSession',
		'currentViewModel'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

{ #category : 'instance creation' }
CPDefinitionsAtelierCoordinator class >> rootMemento: aRootMemento viewModel: aViewModel [
	^ self new
		rootMemento: aRootMemento;
		definitionsViewModel: aViewModel;
		initializeDocumentContext;
		initializeCurrentProcess;
		configureViewModel;
		yourself
]

{ #category : 'private - initialization' }
CPDefinitionsAtelierCoordinator >> rootMemento: aMemento [
	rootMemento := aMemento
]

{ #category : 'private - initialization' }
CPDefinitionsAtelierCoordinator >> definitionsViewModel: aViewModel [
	definitionsViewModel := aViewModel
]

{ #category : 'private - initialization' }
CPDefinitionsAtelierCoordinator >> initializeDocumentContext [
	documentContext := CPDefinitionsMementoContext memento: rootMemento
]

{ #category : 'private - initialization' }
CPDefinitionsAtelierCoordinator >> initializeCurrentProcess [
	| process |
	process := documentContext rootElements
		detect: [ :each | each isProcessDefinition ]
		ifNone: [ ^ self ].
	self setCurrentProcess: process
]

{ #category : 'private - initialization' }
CPDefinitionsAtelierCoordinator >> configureViewModel [
	definitionsViewModel
		presentationDo: [ :aPresentation |
			aPresentation relationItemElementDo: [ :aRow :anObject :aDescription :aMemento |
				self
					configureRelationItem: aRow
					object: anObject
					description: aDescription
					presentation: aPresentation ] ];
		workspaceElementFactory: [ :anAtelierElement |
			atelierElement := anAtelierElement.
			self currentWorkspaceElement ].
	self configureViewModelPalette
]

{ #category : 'private - relations' }
CPDefinitionsAtelierCoordinator >> configureRelationItem: aRow object: anObject description: aDescription presentation: aPresentation [
	aDescription accessor = rootMemento model rootElementsDescription accessor ifFalse: [ ^ self ].
	anObject isProcessDefinition ifFalse: [ ^ self ].

	self currentProcess == anObject ifTrue: [
		aPresentation selectRelationElement: aRow for: aDescription ].

	aRow when: BlClickEvent do: [ :anEvent |
		self activateProcess: anObject.
		aPresentation selectRelationElement: aRow for: aDescription ]
]

{ #category : 'accessing' }
CPDefinitionsAtelierCoordinator >> currentSession [
	^ currentSession
]

{ #category : 'accessing' }
CPDefinitionsAtelierCoordinator >> currentProcess [
	^ currentSession ifNotNil: [ currentSession processMemento model ]
]

{ #category : 'accessing' }
CPDefinitionsAtelierCoordinator >> currentDiagram [
	^ currentSession ifNotNil: [
		currentSession diagramContext ifNotNil: [ :aContext | aContext diagram ] ]
]

{ #category : 'switching' }
CPDefinitionsAtelierCoordinator >> activateProcess: aProcess [
	self currentProcess == aProcess ifTrue: [ ^ currentSession ].
	(documentContext rootElements identityIncludes: aProcess) ifFalse: [ ^ nil ].
	aProcess isProcessDefinition ifFalse: [ ^ nil ].
	self setCurrentProcess: aProcess.
	self installCurrentClient.
	^ currentSession
]

{ #category : 'switching' }
CPDefinitionsAtelierCoordinator >> activateDiagram: aDiagram [
	| process diagrams |
	process := self currentProcess.
	process ifNil: [ ^ nil ].
	diagrams := documentContext diagramsForProcess: process.
	(diagrams identityIncludes: aDiagram) ifFalse: [ ^ nil ].
	currentSession := CPProcessAtelierSession
		forDefinitionsMemento: rootMemento
		process: process
		diagram: aDiagram.
	currentViewModel := currentSession asViewModel.
	self installCurrentClient.
	^ currentSession
]

{ #category : 'private - switching' }
CPDefinitionsAtelierCoordinator >> setCurrentProcess: aProcess [
	| diagrams diagram |
	diagrams := documentContext diagramsForProcess: aProcess.
	diagram := diagrams size = 1 ifTrue: [ diagrams first ] ifFalse: [ nil ].
	currentSession := CPProcessAtelierSession
		forDefinitionsMemento: rootMemento
		process: aProcess
		diagram: diagram.
	currentViewModel := currentSession asViewModel
]

{ #category : 'private - composition' }
CPDefinitionsAtelierCoordinator >> configureViewModelPalette [
	currentViewModel ifNotNil: [
		definitionsViewModel
			palette: currentViewModel palette;
			paletteElementFactory: currentViewModel paletteElementFactory ]
]

{ #category : 'private - composition' }
CPDefinitionsAtelierCoordinator >> currentWorkspaceElement [
	^ currentViewModel ifNotNil: [
		currentViewModel asWorkspaceElementIn: atelierElement ]
]

{ #category : 'private - composition' }
CPDefinitionsAtelierCoordinator >> installCurrentClient [
	atelierElement ifNil: [ ^ self ].
	atelierElement workspaceElement: self currentWorkspaceElement.
	currentViewModel ifNotNil: [
		atelierElement
			palette: currentViewModel palette
			elementFactory: currentViewModel paletteElementFactory ]
]
