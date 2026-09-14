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
	| rootMemento documentContext process diagrams diagram session processViewModel definitionsViewModel |
	rootMemento := CFMaMemento model: self.
	documentContext := CPDefinitionsMementoContext memento: rootMemento.
	process := documentContext rootElements
		detect: [ :each | each isProcessDefinition ]
		ifNone: [
			^ CFAtelierViewModel
				forObject: self
				memento: rootMemento ].
	diagrams := documentContext diagramsForProcess: process.
	diagram := diagrams
		ifEmpty: [ nil ]
		ifNotEmpty: [ diagrams first ].
	session := CPProcessAtelierSession
		forDefinitionsMemento: rootMemento
		process: process
		diagram: diagram.
	processViewModel := session asViewModel.

	definitionsViewModel := CFAtelierViewModel
		forObject: self
		memento: rootMemento.
	definitionsViewModel
		palette: processViewModel palette;
		paletteElementFactory: processViewModel paletteElementFactory;
		workspaceElementFactory: [ :anAtelierElement |
			processViewModel asWorkspaceElementIn: anAtelierElement ].
	^ definitionsViewModel
]

