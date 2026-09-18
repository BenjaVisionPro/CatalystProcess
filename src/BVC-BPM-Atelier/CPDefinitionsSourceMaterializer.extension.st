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
	| context processSaves |
	context := CPDefinitionsMementoContext memento: aDefinitionsMemento.
	self validateSourceBackedRelationsIn: context.
	processSaves := OrderedCollection new.
	context rootElements do: [ :each |
		each class = CPProcess ifTrue: [
			| processMemento |
			processMemento := context mementoForRootElement: each.
			processMemento hasChangesToCommit ifTrue: [
				processSaves add: {
					processMemento.
					(self processSourceSaveForMemento: processMemento in: aSourceClass) } ] ] ].
	context diagrams do: [ :each |
		| diagramMemento |
		diagramMemento := context mementoForDiagram: each.
		diagramMemento hasChangesToCommit ifTrue: [
			self error: 'Atelier source saving does not yet support staged Diagram edits' ] ].
	processSaves do: [ :each |
		aSourceClass class compile: each second second ].
	^ processSaves collect: [ :each | each second first ]
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
	| process identifier pragma selector source |
	process := aProcessMemento model.
	identifier := process identifier.
	self validateProcessMementoForSourceSave: aProcessMemento.
	pragma := self
		localPragmaNamed: #process:
		identifier: identifier
		for: aSourceClass.
	selector := pragma
		ifNil: [ self initialSelectorFor: identifier in: aSourceClass ]
		ifNotNil: [ pragma methodSelector ].
	source := self
		processSourceForIdentifier: identifier
		label: (aProcessMemento readUsing: process labelDescription)
		selector: selector.
	^ { selector. source }
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer >> validateProcessMementoForSourceSave: aProcessMemento [
	| process |
	process := aProcessMemento model.
	(aProcessMemento readUsing: process flowElementsDescription) ifNotEmpty: [
		self error: 'Process source saving does not yet support flow elements' ].
	(aProcessMemento readUsing: process laneSetsDescription) ifNotEmpty: [
		self error: 'Process source saving does not yet support lane sets' ].
	(aProcessMemento readUsing: process propertiesDescription) ifNotEmpty: [
		self error: 'Process source saving does not yet support properties' ].
	(aProcessMemento readUsing: process ioSpecificationDescription) ifNotNil: [
		self error: 'Process source saving does not yet support input/output specifications' ].
	(aProcessMemento readUsing: process definitionalCollaborationRefDescription) ifNotNil: [
		self error: 'Process source saving does not yet support definitional collaborations' ]
]
