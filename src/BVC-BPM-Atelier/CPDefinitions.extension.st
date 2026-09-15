Extension { #name : 'CPDefinitions' }

{ #category : '*BVC-BPM-Atelier' }
CPDefinitions >> asAtelierForProcess: aProcess diagram: aDiagram [
	^ (CPProcessAtelierSession
		forDefinitions: self
		process: aProcess
		diagram: aDiagram) asViewModel
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitions >> asAtelierForProcess: aProcess [
	^ (CPProcessAtelierSession
		forDefinitions: self
		process: aProcess) asViewModel
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitions >> asAtelier [
	| rootMemento definitionsViewModel |
	rootMemento := CFMaMemento model: self.
	definitionsViewModel := CFAtelierViewModel
		forObject: self
		memento: rootMemento.
	CPDefinitionsAtelierCoordinator
		rootMemento: rootMemento
		viewModel: definitionsViewModel.
	^ definitionsViewModel
]
