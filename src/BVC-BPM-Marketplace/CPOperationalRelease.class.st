"I am an immutable operational selection of one published Definitions version and the implementation bindings needed to execute it. I sit above BPMN: BPMN owns business semantics; I record deployment-time choices without changing the published model."
Class {
	#name : 'CPOperationalRelease',
	#superclass : 'CFLabelledObject',
	#instVars : [ 'publishedDefinition', 'definitions', 'operationBindings', 'released' ],
	#category : 'BVC-BPM-Marketplace-Domain',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Domain'
}

{ #category : 'initialization' }
CPOperationalRelease >> initialize [
	super initialize.
	operationBindings := OrderedCollection new.
	released := false
]

{ #category : 'accessing' }
CPOperationalRelease >> publishedDefinition [
	^ publishedDefinition
]

{ #category : 'configuration' }
CPOperationalRelease >> publishedDefinition: aDefinitionSourceClass [
	self assertMutable.
	(CPDefinitionsSourceMaterializer isPublishedVersion: aDefinitionSourceClass) ifFalse: [
		self error: 'An Operational Release requires an immutable published Definition version.' ].
	publishedDefinition := aDefinitionSourceClass
]

{ #category : 'accessing' }
CPOperationalRelease >> definitions [
	^ definitions
]

{ #category : 'configuration' }
CPOperationalRelease >> definitions: aDefinitions [
	self assertMutable.
	aDefinitions ifNil: [ self error: 'An Operational Release requires materialized Definitions.' ].
	definitions := aDefinitions
]

{ #category : 'accessing' }
CPOperationalRelease >> operationBindings [
	^ operationBindings copy
]

{ #category : 'configuration' }
CPOperationalRelease >> bindOperation: anOperation to: anImplementation [
	| existing |
	self assertMutable.
	self assertOperationBelongsToRelease: anOperation.
	existing := operationBindings detect: [ :each | each operation == anOperation ] ifNone: [ nil ].
	existing ifNotNil: [ self error: 'This Operation already has an implementation binding in the Operational Release.' ].
	^ operationBindings add: (CPOperationImplementationBinding operation: anOperation implementation: anImplementation)
]

{ #category : 'resolution' }
CPOperationalRelease >> implementationForOperation: anOperation [
	| binding |
	self isReleased ifFalse: [ self error: 'Operation implementations can only be resolved from a released Operational Release.' ].
	binding := operationBindings detect: [ :each | each operation == anOperation ] ifNone: [
		self error: 'The Operational Release has no implementation binding for this Operation.' ].
	^ binding implementation
]

{ #category : 'lifecycle' }
CPOperationalRelease >> release [
	publishedDefinition ifNil: [ self error: 'An Operational Release requires a published Definition version.' ].
	definitions ifNil: [ self error: 'An Operational Release requires materialized Definitions.' ].
	released := true.
	^ self
]

{ #category : 'testing' }
CPOperationalRelease >> isReleased [
	^ released
]

{ #category : 'private' }
CPOperationalRelease >> assertMutable [
	released ifTrue: [ self error: 'A released Operational Release is immutable.' ]
]

{ #category : 'private' }
CPOperationalRelease >> assertOperationBelongsToRelease: anOperation [
	definitions ifNil: [ self error: 'Materialized Definitions must be assigned before binding Operations.' ].
	(definitions rootElements anySatisfy: [ :each |
		each class = CPInterface and: [ each operations identityIncludes: anOperation ] ]) ifFalse: [
		self error: 'The Operation does not belong to this Operational Release Definitions.' ]
]
