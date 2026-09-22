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
CPDefinitionsSourceMaterializer >> saveSourceChangesFromMemento: aDefinitionsMemento in: aSourceClass [
	| context definitions stagedRoots stagedDiagrams saves removals |
	context := CPDefinitionsMementoContext memento: aDefinitionsMemento.
	self validateSourceBackedRelationsIn: context.
	definitions := aDefinitionsMemento model.
	stagedRoots := context rootElements.
	stagedDiagrams := context diagrams.
	saves := OrderedCollection new.
	removals := OrderedCollection new.

	stagedRoots do: [ :each |
		| processMemento |
		processMemento := context mementoForRootElement: each.
		((definitions rootElements identityIncludes: each) not
			or: [ processMemento hasChangesToCommit ]) ifTrue: [
			saves add: (self processSourceSaveForMemento: processMemento in: aSourceClass) ] ].
	stagedDiagrams do: [ :each |
		| diagramMemento |
		diagramMemento := context mementoForDiagram: each.
		((definitions diagrams identityIncludes: each) not
			or: [ diagramMemento hasChangesToCommit ]) ifTrue: [
			saves add: (self diagramSourceSaveForMemento: diagramMemento in: aSourceClass) ] ].

	definitions diagrams do: [ :each |
		(stagedDiagrams identityIncludes: each) ifFalse: [
			| pragma |
			pragma := self localPragmaNamed: #diagram:process: identifier: each identifier for: aSourceClass.
			pragma ifNil: [
				(self inheritedPragmaNamed: #diagram:process: identifier: each identifier for: aSourceClass)
					ifNotNil: [ self error: 'An inherited Diagram cannot be deleted; specialise or revert it instead' ] ]
				ifNotNil: [ removals add: pragma methodSelector ] ] ].
	definitions rootElements do: [ :each |
		(stagedRoots identityIncludes: each) ifFalse: [
			| pragma |
			pragma := self localPragmaNamed: #process: identifier: each identifier for: aSourceClass.
			pragma ifNil: [
				(self inheritedPragmaNamed: #process: identifier: each identifier for: aSourceClass)
					ifNotNil: [ self error: 'An inherited Process cannot be deleted; specialise or revert it instead' ] ]
				ifNotNil: [
					(stagedDiagrams anySatisfy: [ :diagram | diagram plane modelElement == each ]) ifTrue: [
						self error: 'A Process cannot be deleted while a staged Diagram references it' ].
					removals add: pragma methodSelector ] ] ].

	"Prepare every source unit before mutating the source class."
	saves do: [ :each | aSourceClass class compiler source: each second; parse ].
	removals do: [ :selector | aSourceClass class removeSelector: selector ].
	saves do: [ :each | aSourceClass class compile: each second ].
	^ saves collect: [ :each | each first ]
]

{ #category : '*BVC-BPM-Atelier' }
CPDefinitionsSourceMaterializer >> validateSourceBackedRelationsIn: aDocumentContext [
	| definitions stagedRoots stagedDiagrams originalNonProcesses stagedNonProcesses |
	definitions := aDocumentContext definitionsMemento model.
	stagedRoots := aDocumentContext rootElements.
	stagedDiagrams := aDocumentContext diagrams.
	aDocumentContext validateRootElements: stagedRoots.
	aDocumentContext validateDiagrams: stagedDiagrams.
	originalNonProcesses := definitions rootElements reject: [ :each | each class = CPProcess ].
	stagedNonProcesses := stagedRoots reject: [ :each | each class = CPProcess ].
	(originalNonProcesses size = stagedNonProcesses size
		and: [ originalNonProcesses allSatisfy: [ :each | stagedNonProcesses identityIncludes: each ] ]) ifFalse: [
		self error: 'Source-backed structural editing currently supports Processes only' ].
	stagedDiagrams do: [ :each |
		(each plane modelElement notNil
			and: [ each plane modelElement class = CPProcess
			and: [ stagedRoots identityIncludes: each plane modelElement ] ]) ifFalse: [
			self error: 'Every source-backed Diagram must reference a staged Process' ] ]
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
