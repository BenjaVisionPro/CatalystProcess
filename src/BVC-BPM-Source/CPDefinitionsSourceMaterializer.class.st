Class {
	#name : 'CPDefinitionsSourceMaterializer',
	#superclass : 'Object',
	#category : 'BVC-BPM-BPMN-Source',
	#package : 'BVC-BPM-Source',
	#tag : 'Source'
}

{ #category : 'materializing' }
CPDefinitionsSourceMaterializer class >> materialize: aSourceClass [
	^ self new materialize: aSourceClass
]

{ #category : 'materializing' }
CPDefinitionsSourceMaterializer >> materialize: aSourceClass [
	| definitions processesByIdentifier |
	definitions := aSourceClass definitions.
	definitions class = CPDefinitions ifFalse: [
		self error: 'The definitions method must answer a CPDefinitions' ].

	processesByIdentifier := Dictionary new.
	(self effectivePragmasNamed: #process: for: aSourceClass)
		do: [ :aPragma |
			| process identifier |
			identifier := aPragma argumentAt: 1.
			process := aPragma methodClass instanceSide perform: aPragma methodSelector.
			self validateProcess: process identifier: identifier.
			processesByIdentifier at: identifier put: process.
			definitions addRootElement: process ].

	(self effectivePragmasNamed: #diagram:process: for: aSourceClass)
		do: [ :aPragma |
			| diagram diagramIdentifier processIdentifier process |
			diagramIdentifier := aPragma argumentAt: 1.
			processIdentifier := aPragma argumentAt: 2.
			process := processesByIdentifier
				at: processIdentifier
				ifAbsent: [ self error: 'Diagram references a Process that is not present in these Definitions' ].
			diagram := aPragma methodClass instanceSide perform: aPragma methodSelector.
			self validateDiagram: diagram identifier: diagramIdentifier.
			diagram plane modelElement: process.
			definitions addDiagram: diagram ].

	^ definitions
]

{ #category : 'private - discovering' }
CPDefinitionsSourceMaterializer >> effectivePragmasNamed: aPragmaSelector for: aSourceClass [
	| effective |
	effective := Dictionary new.
	(Pragma allNamed: aPragmaSelector) do: [ :aPragma |
		| sourceClass identifier existing |
		aPragma methodClass isMeta ifTrue: [
			sourceClass := aPragma methodClass instanceSide.
			(self sourceClass: sourceClass participatesIn: aSourceClass) ifTrue: [
				identifier := aPragma argumentAt: 1.
				existing := effective at: identifier ifAbsent: [ nil ].
				existing
					ifNil: [ effective at: identifier put: aPragma ]
					ifNotNil: [
						| sourceDistance existingDistance |
						sourceDistance := self distanceFrom: aSourceClass to: sourceClass.
						existingDistance := self distanceFrom: aSourceClass to: existing methodClass instanceSide.
						sourceDistance = existingDistance ifTrue: [
							self error: 'A source class cannot declare the same model identity more than once' ].
						sourceDistance < existingDistance ifTrue: [
							effective at: identifier put: aPragma ] ] ] ] ].
	^ (effective values asSortedCollection: [ :left :right |
		(left argumentAt: 1) asString < (right argumentAt: 1) asString ]) asOrderedCollection
]

{ #category : 'private - discovering' }
CPDefinitionsSourceMaterializer >> sourceClass: aSourceClass participatesIn: aTargetClass [
	| current |
	current := aTargetClass.
	[ current notNil ] whileTrue: [
		current == aSourceClass ifTrue: [ ^ true ].
		current := current superclass ].
	^ false
]

{ #category : 'private - discovering' }
CPDefinitionsSourceMaterializer >> distanceFrom: aTargetClass to: anAncestorClass [
	| current distance |
	current := aTargetClass.
	distance := 0.
	[ current notNil ] whileTrue: [
		current == anAncestorClass ifTrue: [ ^ distance ].
		current := current superclass.
		distance := distance + 1 ].
	self error: 'Source class is not in the target class hierarchy'
]

{ #category : 'private - validating' }
CPDefinitionsSourceMaterializer >> validateProcess: aProcess identifier: anIdentifier [
	aProcess class = CPProcess ifFalse: [
		self error: 'A process source method must answer a CPProcess' ].
	aProcess identifier = anIdentifier ifFalse: [
		self error: 'Process pragma identity must match the CPProcess identifier' ]
]

{ #category : 'private - validating' }
CPDefinitionsSourceMaterializer >> validateDiagram: aDiagram identifier: anIdentifier [
	aDiagram class = CPDiagram ifFalse: [
		self error: 'A diagram source method must answer a CPDiagram' ].
	aDiagram identifier = anIdentifier ifFalse: [
		self error: 'Diagram pragma identity must match the CPDiagram identifier' ]
]

{ #category : 'querying - processes' }
CPDefinitionsSourceMaterializer class >> isInheritedProcess: anIdentifier in: aSourceClass [
	^ self new isInheritedProcess: anIdentifier in: aSourceClass
]

{ #category : 'querying - processes' }
CPDefinitionsSourceMaterializer class >> isLocalProcess: anIdentifier in: aSourceClass [
	^ self new isLocalProcess: anIdentifier in: aSourceClass
]

{ #category : 'querying - processes' }
CPDefinitionsSourceMaterializer class >> isSpecialisedProcess: anIdentifier in: aSourceClass [
	^ self new isSpecialisedProcess: anIdentifier in: aSourceClass
]

{ #category : 'querying - diagrams' }
CPDefinitionsSourceMaterializer class >> isInheritedDiagram: anIdentifier in: aSourceClass [
	^ self new isInheritedDiagram: anIdentifier in: aSourceClass
]

{ #category : 'querying - diagrams' }
CPDefinitionsSourceMaterializer class >> isLocalDiagram: anIdentifier in: aSourceClass [
	^ self new isLocalDiagram: anIdentifier in: aSourceClass
]

{ #category : 'querying - diagrams' }
CPDefinitionsSourceMaterializer class >> isSpecialisedDiagram: anIdentifier in: aSourceClass [
	^ self new isSpecialisedDiagram: anIdentifier in: aSourceClass
]

{ #category : 'querying - processes' }
CPDefinitionsSourceMaterializer >> isInheritedProcess: anIdentifier in: aSourceClass [
	| pragma |
	pragma := self effectivePragmaNamed: #process: identifier: anIdentifier for: aSourceClass.
	^ pragma methodClass instanceSide ~~ aSourceClass
]

{ #category : 'querying - processes' }
CPDefinitionsSourceMaterializer >> isLocalProcess: anIdentifier in: aSourceClass [
	| pragma |
	pragma := self effectivePragmaNamed: #process: identifier: anIdentifier for: aSourceClass.
	^ pragma methodClass instanceSide == aSourceClass
		and: [ (self inheritedPragmaNamed: #process: identifier: anIdentifier for: aSourceClass) isNil ]
]

{ #category : 'querying - processes' }
CPDefinitionsSourceMaterializer >> isSpecialisedProcess: anIdentifier in: aSourceClass [
	| pragma |
	pragma := self effectivePragmaNamed: #process: identifier: anIdentifier for: aSourceClass.
	^ pragma methodClass instanceSide == aSourceClass
		and: [ (self inheritedPragmaNamed: #process: identifier: anIdentifier for: aSourceClass) notNil ]
]

{ #category : 'querying - diagrams' }
CPDefinitionsSourceMaterializer >> isInheritedDiagram: anIdentifier in: aSourceClass [
	| pragma |
	pragma := self effectivePragmaNamed: #diagram:process: identifier: anIdentifier for: aSourceClass.
	^ pragma methodClass instanceSide ~~ aSourceClass
]

{ #category : 'querying - diagrams' }
CPDefinitionsSourceMaterializer >> isLocalDiagram: anIdentifier in: aSourceClass [
	| pragma |
	pragma := self effectivePragmaNamed: #diagram:process: identifier: anIdentifier for: aSourceClass.
	^ pragma methodClass instanceSide == aSourceClass
		and: [ (self inheritedPragmaNamed: #diagram:process: identifier: anIdentifier for: aSourceClass) isNil ]
]

{ #category : 'querying - diagrams' }
CPDefinitionsSourceMaterializer >> isSpecialisedDiagram: anIdentifier in: aSourceClass [
	| pragma |
	pragma := self effectivePragmaNamed: #diagram:process: identifier: anIdentifier for: aSourceClass.
	^ pragma methodClass instanceSide == aSourceClass
		and: [ (self inheritedPragmaNamed: #diagram:process: identifier: anIdentifier for: aSourceClass) notNil ]
]

{ #category : 'private - discovering' }
CPDefinitionsSourceMaterializer >> effectivePragmaNamed: aPragmaSelector identifier: anIdentifier for: aSourceClass [
	^ (self effectivePragmasNamed: aPragmaSelector for: aSourceClass)
		detect: [ :each | (each argumentAt: 1) = anIdentifier ]
		ifNone: [ self error: 'No source method declares that model identity' ]
]

{ #category : 'private - discovering' }
CPDefinitionsSourceMaterializer >> inheritedPragmaNamed: aPragmaSelector identifier: anIdentifier for: aSourceClass [
	| superclass |
	superclass := aSourceClass superclass.
	superclass ifNil: [ ^ nil ].
	^ (self effectivePragmasNamed: aPragmaSelector for: superclass)
		detect: [ :each | (each argumentAt: 1) = anIdentifier ]
		ifNone: [ nil ]
]

{ #category : 'saving - processes' }
CPDefinitionsSourceMaterializer class >> saveProcess: aProcess in: aSourceClass [
	^ self new saveProcess: aProcess in: aSourceClass
]

{ #category : 'saving - processes' }
CPDefinitionsSourceMaterializer >> saveProcess: aProcess in: aSourceClass [
	| pragma selector source |
	self validateMutableSourceClass: aSourceClass.
	self validateProcessForSourceSave: aProcess.
	pragma := self
		localPragmaNamed: #process:
		identifier: aProcess identifier
		for: aSourceClass.
	selector := pragma
		ifNil: [ self initialSelectorFor: aProcess identifier in: aSourceClass ]
		ifNotNil: [ pragma methodSelector ].
	source := self processSourceFor: aProcess selector: selector.
	aSourceClass class compile: source.
	^ selector
]

{ #category : 'private - saving' }
CPDefinitionsSourceMaterializer >> localPragmaNamed: aPragmaSelector identifier: anIdentifier for: aSourceClass [
	| matches |
	matches := (Pragma allNamed: aPragmaSelector) select: [ :aPragma |
		aPragma methodClass isMeta
			and: [ aPragma methodClass instanceSide == aSourceClass
			and: [ (aPragma argumentAt: 1) = anIdentifier ] ] ].
	matches size > 1 ifTrue: [
		self error: 'A source class cannot declare the same model identity more than once' ].
	^ matches ifEmpty: [ nil ] ifNotEmpty: [ matches first ]
]

{ #category : 'private - saving' }
CPDefinitionsSourceMaterializer >> initialSelectorFor: anIdentifier in: aSourceClass [
	| selector |
	selector := anIdentifier asString asSymbol.
	(aSourceClass class includesSelector: selector) ifTrue: [
		self error: 'The initial source selector is already in use' ].
	^ selector
]

{ #category : 'private - saving' }
CPDefinitionsSourceMaterializer >> processSourceFor: aProcess selector: aSelector [
	^ self
		processSourceForIdentifier: aProcess identifier
		label: aProcess label
		selector: aSelector
]

{ #category : 'private - validating' }
CPDefinitionsSourceMaterializer >> validateProcessForSourceSave: aProcess [
	self validateProcess: aProcess identifier: aProcess identifier.
	aProcess flowElements ifNotEmpty: [
		self error: 'Process source saving does not yet support flow elements' ].
	aProcess laneSets ifNotEmpty: [
		self error: 'Process source saving does not yet support lane sets' ].
	aProcess properties ifNotEmpty: [
		self error: 'Process source saving does not yet support properties' ].
	aProcess ioSpecification ifNotNil: [
		self error: 'Process source saving does not yet support input/output specifications' ].
	aProcess definitionalCollaborationRef ifNotNil: [
		self error: 'Process source saving does not yet support definitional collaborations' ]
]

{ #category : 'reverting - processes' }
CPDefinitionsSourceMaterializer class >> revertProcess: anIdentifier in: aSourceClass [
	^ self new revertProcess: anIdentifier in: aSourceClass
]

{ #category : 'reverting - processes' }
CPDefinitionsSourceMaterializer >> revertProcess: anIdentifier in: aSourceClass [
	| localPragma inheritedPragma selector |
	self validateMutableSourceClass: aSourceClass.
	localPragma := self
		localPragmaNamed: #process:
		identifier: anIdentifier
		for: aSourceClass.
	localPragma ifNil: [
		self error: 'There is no local Process contribution to revert' ].
	inheritedPragma := self
		inheritedPragmaNamed: #process:
		identifier: anIdentifier
		for: aSourceClass.
	inheritedPragma ifNil: [
		self error: 'A local Process without an inherited contribution cannot be reverted' ].
	selector := localPragma methodSelector.
	aSourceClass class removeSelector: selector.
	^ selector
]


{ #category : 'saving - diagrams' }
CPDefinitionsSourceMaterializer class >> saveDiagram: aDiagram in: aSourceClass [
	^ self new saveDiagram: aDiagram in: aSourceClass
]

{ #category : 'saving - diagrams' }
CPDefinitionsSourceMaterializer >> saveDiagram: aDiagram in: aSourceClass [
	| pragma selector source processIdentifier |
	self validateMutableSourceClass: aSourceClass.
	self validateDiagramForSourceSave: aDiagram.
	processIdentifier := aDiagram plane modelElement identifier.
	pragma := self
		localPragmaNamed: #diagram:process:
		identifier: aDiagram identifier
		for: aSourceClass.
	selector := pragma
		ifNil: [ self initialSelectorFor: aDiagram identifier in: aSourceClass ]
		ifNotNil: [ pragma methodSelector ].
	source := self
		diagramSourceFor: aDiagram
		processIdentifier: processIdentifier
		selector: selector.
	aSourceClass class compile: source.
	^ selector
]

{ #category : 'private - saving' }
CPDefinitionsSourceMaterializer >> diagramSourceFor: aDiagram processIdentifier: aProcessIdentifier selector: aSelector [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: aSelector asString;
			cr;
			tab;
			nextPutAll: '<diagram: ';
			nextPutAll: aDiagram identifier storeString;
			nextPutAll: ' process: ';
			nextPutAll: aProcessIdentifier storeString;
			nextPutAll: '>';
			cr;
			tab;
			nextPutAll: '^ CPDiagram identifier: ';
			nextPutAll: aDiagram identifier storeString ]
]

{ #category : 'private - validating' }
CPDefinitionsSourceMaterializer >> validateDiagramForSourceSave: aDiagram [
	| modelElement |
	self validateDiagram: aDiagram identifier: aDiagram identifier.
	aDiagram labelStyles ifNotEmpty: [
		self error: 'Diagram source saving does not yet support label styles' ].
	aDiagram plane elements ifNotEmpty: [
		self error: 'Diagram source saving does not yet support diagram elements' ].
	modelElement := aDiagram plane modelElement.
	modelElement ifNil: [
		self error: 'A source-backed Diagram must depict a Process' ].
	modelElement class = CPProcess ifFalse: [
		self error: 'Diagram source saving currently supports Process diagrams only' ]
]

{ #category : 'reverting - diagrams' }
CPDefinitionsSourceMaterializer class >> revertDiagram: anIdentifier in: aSourceClass [
	^ self new revertDiagram: anIdentifier in: aSourceClass
]

{ #category : 'reverting - diagrams' }
CPDefinitionsSourceMaterializer >> revertDiagram: anIdentifier in: aSourceClass [
	| localPragma inheritedPragma selector |
	self validateMutableSourceClass: aSourceClass.
	localPragma := self
		localPragmaNamed: #diagram:process:
		identifier: anIdentifier
		for: aSourceClass.
	localPragma ifNil: [
		self error: 'There is no local Diagram contribution to revert' ].
	inheritedPragma := self
		inheritedPragmaNamed: #diagram:process:
		identifier: anIdentifier
		for: aSourceClass.
	inheritedPragma ifNil: [
		self error: 'A local Diagram without an inherited contribution cannot be reverted' ].
	selector := localPragma methodSelector.
	aSourceClass class removeSelector: selector.
	^ selector
]

{ #category : 'private - saving' }
CPDefinitionsSourceMaterializer >> processSourceForIdentifier: anIdentifier label: aLabel selector: aSelector [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: aSelector asString;
			cr;
			tab;
			nextPutAll: '<process: ';
			nextPutAll: anIdentifier storeString;
			nextPutAll: '>';
			cr;
			tab;
			nextPutAll: '^ (CPProcess identifier: ';
			nextPutAll: anIdentifier storeString;
			nextPutAll: ')';
			cr;
			tab;
			tab;
			nextPutAll: 'label: ';
			nextPutAll: aLabel storeString;
			nextPutAll: ';';
			cr;
			tab;
			tab;
			nextPutAll: 'yourself' ]
]



{ #category : 'private - validating' }
CPDefinitionsSourceMaterializer >> validateMutableSourceClass: aSourceClass [
	(self isPublishedVersion: aSourceClass) ifTrue: [
		self error: 'Published Definition versions are immutable' ]
]

{ #category : 'querying - versions' }
CPDefinitionsSourceMaterializer class >> isPublishedVersion: aSourceClass [
	^ self new isPublishedVersion: aSourceClass
]

{ #category : 'querying - versions' }
CPDefinitionsSourceMaterializer >> isPublishedVersion: aSourceClass [
	^ (Pragma allNamed: #publishedVersion)
		anySatisfy: [ :aPragma |
			aPragma methodClass isMeta
				and: [ aPragma methodClass instanceSide == aSourceClass ] ]
]

{ #category : 'querying - versions' }
CPDefinitionsSourceMaterializer class >> versionOf: aSourceClass [
	^ self new versionOf: aSourceClass
]

{ #category : 'querying - versions' }
CPDefinitionsSourceMaterializer >> versionOf: aSourceClass [
	(self isPublishedVersion: aSourceClass) ifFalse: [
		self error: 'The Definition class is not a published version' ].
	^ aSourceClass versionOf
]

{ #category : 'publishing' }
CPDefinitionsSourceMaterializer class >> publish: aSourceClass [
	^ self new publish: aSourceClass
]

{ #category : 'publishing' }
CPDefinitionsSourceMaterializer >> publish: aSourceClass [
	| version publishedClass |
	(self isPublishedVersion: aSourceClass) ifTrue: [
		self error: 'A published Definition version cannot be published again' ].

	"Materialise first so publication cannot snapshot invalid source."
	self materialize: aSourceClass.
	version := self nextVersionFor: aSourceClass.
	publishedClass := self
		installPublishedClassFor: aSourceClass
		version: version.

	self compileDefinitionsFrom: aSourceClass into: publishedClass.
	(self effectivePragmasNamed: #process: for: aSourceClass)
		do: [ :each | publishedClass class compile: each method sourceCode ].
	(self effectivePragmasNamed: #diagram:process: for: aSourceClass)
		do: [ :each | publishedClass class compile: each method sourceCode ].
	publishedClass class compile: (self versionSourceFor: version).
	publishedClass class compile: (self versionOfSourceFor: aSourceClass).

	"The snapshot must stand on its own and materialise successfully."
	self materialize: publishedClass.
	^ publishedClass
]

{ #category : 'private - publishing' }
CPDefinitionsSourceMaterializer >> nextVersionFor: aSourceClass [
	| versions |
	versions := (Pragma allNamed: #publishedVersion)
		collect: [ :aPragma | aPragma methodClass instanceSide ]
		thenSelect: [ :each |
			each ~~ aSourceClass
				and: [ each versionOf = aSourceClass ] ].
	^ versions
		ifEmpty: [ 1 ]
		ifNotEmpty: [ (versions collect: #version) max + 1 ]
]

{ #category : 'private - publishing' }
CPDefinitionsSourceMaterializer >> installPublishedClassFor: aSourceClass version: anInteger [
	| className |
	className := (aSourceClass name , 'V' , anInteger asString) asSymbol.
	(Smalltalk includesKey: className) ifTrue: [
		self error: 'The published Definition class already exists' ].
	^ (Object << className
		slots: {};
		package: aSourceClass package name) install
]

{ #category : 'private - publishing' }
CPDefinitionsSourceMaterializer >> compileDefinitionsFrom: aSourceClass into: aPublishedClass [
	| current method |
	current := aSourceClass.
	method := nil.
	[ current notNil and: [ method isNil ] ] whileTrue: [
		method := current class methodDict at: #definitions ifAbsent: [ nil ].
		current := current superclass ].
	method ifNil: [ self error: 'A source-backed Definition class must define or inherit definitions' ].
	aPublishedClass class compile: method sourceCode
]

{ #category : 'private - publishing' }
CPDefinitionsSourceMaterializer >> versionSourceFor: anInteger [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'version'; cr;
			tab; nextPutAll: '<publishedVersion>'; cr;
			tab; nextPutAll: '^ '; nextPutAll: anInteger asString ]
]

{ #category : 'private - publishing' }
CPDefinitionsSourceMaterializer >> versionOfSourceFor: aSourceClass [
	^ String streamContents: [ :stream |
		stream
			nextPutAll: 'versionOf'; cr;
			tab; nextPutAll: '^ '; nextPutAll: aSourceClass name ]
]
