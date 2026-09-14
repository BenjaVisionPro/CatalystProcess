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
	| rootMemento documentContext process definitionsViewModel |
	rootMemento := CFMaMemento model: self.
	documentContext := CPDefinitionsMementoContext memento: rootMemento.
	process := documentContext rootElements
		detect: [ :each | each isProcessDefinition ]
		ifNone: [
			^ CFAtelierViewModel
				forObject: self
				memento: rootMemento ].

	definitionsViewModel := CFAtelierViewModel
		forObject: self
		memento: rootMemento.
	self
		showProcess: process
		inAtelierViewModel: definitionsViewModel
		rootMemento: rootMemento
		documentContext: documentContext.
	definitionsViewModel presentationDo: [ :aPresentation |
		aPresentation relationActivateDo: [ :anObject :aDescription :aMemento :anElement |
			anObject isProcessDefinition ifTrue: [
				self
					showProcess: anObject
					inAtelierViewModel: definitionsViewModel
					rootMemento: rootMemento
					documentContext: documentContext ] ] ].
	^ definitionsViewModel
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitions >> showProcess: aProcess inAtelierViewModel: definitionsViewModel rootMemento: rootMemento documentContext: documentContext [
	| diagrams diagram session processViewModel |
	diagrams := documentContext diagramsForProcess: aProcess.
	diagram := diagrams
		ifEmpty: [ nil ]
		ifNotEmpty: [ diagrams first ].
	session := CPProcessAtelierSession
		forDefinitionsMemento: rootMemento
		process: aProcess
		diagram: diagram.
	processViewModel := session asViewModel.
	definitionsViewModel
		palette: processViewModel palette;
		paletteElementFactory: processViewModel paletteElementFactory;
		workspaceElementFactory: [ :anAtelierElement |
			processViewModel asWorkspaceElementIn: anAtelierElement ].
	^ processViewModel
]
