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
	| rootMemento documentContext process definitionsViewModel currentProcessElement |
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
		aPresentation relationItemElementDo: [ :anElement :anObject :aDescription :aMemento |
			aDescription accessor = self rootElementsDescription accessor ifTrue: [
				anObject == process ifTrue: [
					currentProcessElement := anElement.
					aPresentation
						selectRelationElement: currentProcessElement
						for: aDescription ].
				anElement
					when: BlClickEvent
					do: [ :anEvent |
						(anEvent modifiers isEmpty and: [ anObject isProcessDefinition ])
							ifTrue: [
								process := anObject.
								currentProcessElement := anElement.
								aPresentation
									selectRelationElement: currentProcessElement
									for: aDescription.
								self
									showProcess: process
									inAtelierViewModel: definitionsViewModel
									rootMemento: rootMemento
									documentContext: documentContext.
								definitionsViewModel asElement ]
							ifFalse: [
								currentProcessElement ifNotNil: [
									aPresentation
										selectRelationElement: currentProcessElement
										for: aDescription ] ] ] ] ] ].
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
