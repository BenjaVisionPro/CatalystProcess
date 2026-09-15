"I coordinate which Process editing session is hosted inside one Definitions-rooted Atelier.

CPDefinitions remains the Atelier object and transaction root. CPProcessAtelierSession remains the canonical Process + Diagram editing session. I only coordinate the currently hosted session and install its ordinary Process Atelier client into the stable Foundation Atelier host."
Class {
	#name : 'CPDefinitionsAtelierCoordinator',
	#superclass : 'Object',
	#instVars : [
		'rootMemento',
		'documentContext',
		'definitionsViewModel',
		'atelierElement',
		'currentSession',
		'currentViewModel',
		'observingDocument'
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
		initializeCurrentSession;
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
	documentContext := CPDefinitionsMementoContext memento: rootMemento.
	observingDocument := false
]

{ #category : 'private - initialization' }
CPDefinitionsAtelierCoordinator >> initializeCurrentSession [
	| process |
	process := documentContext rootElements
		detect: [ :each | each isProcessDefinition ]
		ifNone: [ ^ self ].
	self setCurrentProcess: process
]

{ #category : 'private - initialization' }
CPDefinitionsAtelierCoordinator >> configureViewModel [
	definitionsViewModel
		relationItemElementDo: [ :aRow :anObject :aDescription :aMemento |
			self
				configureRelationItem: aRow
				object: anObject
				description: aDescription ];
		workspaceElementFactory: [ :anAtelierElement |
			self atelierElement: anAtelierElement.
			self currentWorkspaceElement ].
	self configureViewModelPalette
]

{ #category : 'private - initialization' }
CPDefinitionsAtelierCoordinator >> atelierElement: anElement [
	atelierElement := anElement.
	self installDocumentObservation
]

{ #category : 'private - observing' }
CPDefinitionsAtelierCoordinator >> installDocumentObservation [
	observingDocument ifTrue: [ ^ self ].
	atelierElement ifNil: [ ^ self ].
	observingDocument := true.

	atelierElement withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink | self validateCurrentSession ].
		documentContext rootElementsObservable observe: anElementSink ].

	atelierElement withAsyncSinkDo: [ :anElementSink |
		anElementSink
			sink: AsyncPeekSink new;
			whenUpdate: [ :anElement :aSink | self validateCurrentSession ].
		documentContext diagramsObservable observe: anElementSink ]
]

{ #category : 'private - relations' }
CPDefinitionsAtelierCoordinator >> configureRelationItem: aRow object: anObject description: aDescription [
	aDescription accessor = rootMemento model rootElementsDescription accessor
		ifFalse: [ ^ self ].
	anObject isProcessDefinition ifFalse: [ ^ self ].
	aRow
		when: BlClickEvent
		do: [ :anEvent |
			anEvent modifiers isEmpty ifTrue: [
				self activateProcess: anObject ] ]
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
	diagram := diagrams size = 1
		ifTrue: [ diagrams first ]
		ifFalse: [ nil ].
	currentSession := CPProcessAtelierSession
		forDefinitionsMemento: rootMemento
		process: aProcess
		diagram: diagram.
	currentViewModel := currentSession asViewModel
]

{ #category : 'private - switching' }
CPDefinitionsAtelierCoordinator >> clearCurrentSession [
	currentSession := nil.
	currentViewModel := nil.
	self installCurrentClient
]

{ #category : 'private - switching' }
CPDefinitionsAtelierCoordinator >> validateCurrentSession [
	| process diagram |
	currentSession ifNil: [ ^ self ].
	process := self currentProcess.
	(documentContext rootElements identityIncludes: process) ifFalse: [
		^ self clearCurrentSession ].
	diagram := self currentDiagram.
	(diagram notNil and: [
		(documentContext diagrams identityIncludes: diagram) not ]) ifTrue: [
			currentSession := CPProcessAtelierSession
				forDefinitionsMemento: rootMemento
				process: process
				diagram: nil.
			currentViewModel := currentSession asViewModel.
			self installCurrentClient ]
]

{ #category : 'private - composition' }
CPDefinitionsAtelierCoordinator >> configureViewModelPalette [
	currentViewModel
		ifNil: [
			definitionsViewModel
				palette: nil;
				paletteElementFactory: nil ]
		ifNotNil: [
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
	self configureViewModelPalette.
	atelierElement ifNil: [ ^ self ].
	atelierElement workspaceElement: self currentWorkspaceElement.
	currentViewModel
		ifNil: [ atelierElement palette: nil elementFactory: nil ]
		ifNotNil: [
			atelierElement
				palette: currentViewModel palette
				elementFactory: currentViewModel paletteElementFactory ]
]
