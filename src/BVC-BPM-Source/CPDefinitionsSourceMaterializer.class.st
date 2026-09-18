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

{ #category : 'opening' }
CPDefinitionsSourceMaterializer class >> open: aSourceClass [
	^ (self materialize: aSourceClass) asAtelier
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
