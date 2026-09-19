Extension { #name : 'CPDefinitionsSourceMaterializer' }

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer class >> open: aSourceClass [
	| definitions rootMemento definitionsViewModel |
	definitions := self materialize: aSourceClass.
	rootMemento := CPDefinitionsSourceMemento
		model: definitions
		sourceClass: aSourceClass.
	definitionsViewModel := CFAtelierViewModel
		forObject: definitions
		memento: rootMemento.
	CPDefinitionsAtelierCoordinator
		rootMemento: rootMemento
		viewModel: definitionsViewModel.
	^ definitionsViewModel
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer class >> saveMemento: aDefinitionsMemento in: aSourceClass [
	^ self new saveMemento: aDefinitionsMemento in: aSourceClass
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer >> saveMemento: aDefinitionsMemento in: aSourceClass [
	| selectors |
	selectors := self
		saveSourceChangesFromMemento: aDefinitionsMemento
		in: aSourceClass.
	aDefinitionsMemento commit.
	^ selectors
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer >> saveSourceChangesFromMemento: aDefinitionsMemento in: aSourceClass [
	| context saves |
	context := CPDefinitionsMementoContext memento: aDefinitionsMemento.
	self validateSourceBackedRelationsIn: context.
	saves := OrderedCollection new.
	context rootElements do: [ :each |
		each class = CPProcess ifTrue: [
			| processMemento |
			processMemento := context mementoForRootElement: each.
			processMemento hasChangesToCommit ifTrue: [
				saves add: (self processSourceSaveForMemento: processMemento in: aSourceClass) ] ] ].
	context diagrams do: [ :each |
		| diagramMemento |
		diagramMemento := context mementoForDiagram: each.
		diagramMemento hasChangesToCommit ifTrue: [
			saves add: (self diagramSourceSaveForMemento: diagramMemento in: aSourceClass) ] ].
	"Validate every staged source unit before mutating the class."
	saves do: [ :each | aSourceClass class compiler source: each second; parse ].
	saves do: [ :each | aSourceClass class compile: each second ].
	^ saves collect: [ :each | each first ]
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer >> validateSourceBackedRelationsIn: aDocumentContext [
	| definitions stagedRoots stagedDiagrams |
	definitions := aDocumentContext definitionsMemento model.
	stagedRoots := aDocumentContext rootElements.
	stagedDiagrams := aDocumentContext diagrams.
	(self sameIdentities: stagedRoots as: definitions rootElements) ifFalse: [
		self error: 'Atelier source saving does not yet support adding, removing, or reordering Definitions root elements' ].
	(self sameIdentities: stagedDiagrams as: definitions diagrams) ifFalse: [
		self error: 'Atelier source saving does not yet support adding, removing, or reordering Diagrams' ]
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer >> sameIdentities: left as: right [
	left size = right size ifFalse: [ ^ false ].
	1 to: left size do: [ :index |
		(left at: index) == (right at: index) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer >> processSourceSaveForMemento: aProcessMemento in: aSourceClass [
	| process stagedProcess identifier pragma selector source |
	process := aProcessMemento model.
	identifier := process identifier.
	self validateProcessMementoForSourceSave: aProcessMemento.
	stagedProcess := process copy.
	stagedProcess label: (aProcessMemento readUsing: process labelDescription).
	pragma := self
		localPragmaNamed: #process:
		identifier: identifier
		for: aSourceClass.
	selector := pragma
		ifNil: [ self initialSelectorFor: identifier in: aSourceClass ]
		ifNotNil: [ pragma methodSelector ].
	source := self
		processSourceFor: stagedProcess
		selector: selector.
	^ { selector. source }
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer >> validateProcessMementoForSourceSave: aProcessMemento [
	self validateProcessForSourceSave: aProcessMemento model
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer >> diagramSourceSaveForMemento: aDiagramMemento in: aSourceClass [
	| diagram processIdentifier pragma selector source |
	diagram := aDiagramMemento model.
	self validateDiagramForSourceSave: diagram.
	processIdentifier := diagram plane modelElement identifier.
	pragma := self
		localPragmaNamed: #diagram:process:
		identifier: diagram identifier
		for: aSourceClass.
	selector := pragma
		ifNil: [ self initialSelectorFor: diagram identifier in: aSourceClass ]
		ifNotNil: [ pragma methodSelector ].
	source := self
		diagramSourceFor: diagram
		processIdentifier: processIdentifier
		selector: selector.
	^ { selector. source }
]
