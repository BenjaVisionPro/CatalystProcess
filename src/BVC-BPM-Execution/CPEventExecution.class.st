Class {
	#name : 'CPEventExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'scope',
		'consumedFlowActivation',
		'producedFlowActivations',
		'occurrence',
		'occurrences',
		'thrownOccurrences',
		'itemValues'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPEventExecution >> initialize [
	super initialize.
	producedFlowActivations := OrderedCollection new.
	thrownOccurrences := OrderedCollection new.
	itemValues := IdentityDictionary new
]

{ #category : 'accessing' }
CPEventExecution >> definition [ ^ definition ]
{ #category : 'accessing' }
CPEventExecution >> definition: anEvent [ definition := anEvent ]
{ #category : 'accessing' }
CPEventExecution >> scope [ ^ scope ]
{ #category : 'accessing' }
CPEventExecution >> scope: anExecutionScope [ scope := anExecutionScope ]
{ #category : 'accessing' }
CPEventExecution >> consumedFlowActivation [ ^ consumedFlowActivation ]
{ #category : 'accessing' }
CPEventExecution >> producedFlowActivations [ ^ producedFlowActivations ]
{ #category : 'accessing' }
CPEventExecution >> occurrence [ ^ occurrence ]
{ #category : 'accessing' }
CPEventExecution >> occurrence: anOccurrence [ occurrence := anOccurrence ]

{ #category : 'control flow' }
CPEventExecution >> consumeFlowActivation: anActivation [
	consumedFlowActivation ifNotNil: [ self error: 'An Event execution can consume only one incoming control-flow activation.' ].
	anActivation consumeBy: self.
	consumedFlowActivation := anActivation.
	^ anActivation
]

{ #category : 'control flow' }
CPEventExecution >> recordProducedFlowActivation: anActivation [
	anActivation producedBy == self ifFalse: [ self error: 'The control-flow activation was not produced by this Event execution.' ].
	producedFlowActivations add: anActivation.
	^ anActivation
]

{ #category : 'testing' }
CPEventExecution >> isBoundaryEventExecution [ ^ false ]

{ #category : 'testing' }
CPEventExecution >> isPendingWork [
	^ false
]

{ #category : 'lifecycle' }
CPEventExecution >> terminatePendingWork [
	^ self
]

{ #category : 'testing' }
CPEventExecution >> isCompensationExecution [
	^ false
]

{ #category : 'testing' }
CPEventExecution >> isCompensationThrowEventExecution [
	^ false
]

{ #category : 'testing' }
CPEventExecution >> isErrorEndEventExecution [
	^ false
]


{ #category : 'testing' }
CPEventExecution >> isErrorPropagationExecution [
	^ false
]

{ #category : 'data' }
CPEventExecution >> ownsItemValueFor: anItemAwareElement [
	definition isCatchEvent ifTrue: [ ^ definition dataOutputs identityIncludes: anItemAwareElement ].
	definition isThrowEvent ifTrue: [ ^ definition dataInputs identityIncludes: anItemAwareElement ].
	^ false
]

{ #category : 'data' }
CPEventExecution >> itemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Event execution.' ].
	^ itemValues at: anItemAwareElement ifAbsent: [ nil ]
]

{ #category : 'data' }
CPEventExecution >> itemValueFor: anItemAwareElement put: aValue [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Event execution.' ].
	itemValues at: anItemAwareElement put: aValue.
	^ aValue
]

{ #category : 'accessing' }
CPEventExecution >> occurrences [ ^ occurrences ]

{ #category : 'accessing' }
CPEventExecution >> occurrences: aCollection [ occurrences := aCollection ]

{ #category : 'data' }
CPEventExecution >> populateParallelMultipleCatchEventDataFrom: aCollection [
	| outputs |
	definition isParallelMultipleStartEvent ifFalse: [ self error: 'Parallel Multiple catch data requires a Parallel Multiple Start Event.' ].
	outputs := definition dataOutputs.
	outputs ifNotEmpty: [
		outputs size = definition eventDefinitions size ifFalse: [ self error: 'A Parallel Multiple Start Event requires one Data Output for each Event Definition.' ].
		aCollection do: [ :eachOccurrence |
			| matchingDefinition definitionIndex |
			matchingDefinition := definition eventDefinitionMatchingInstantiationOccurrence: eachOccurrence.
			matchingDefinition ifNil: [ self error: 'An occurrence does not match a Parallel Multiple Start Event definition.' ].
			definitionIndex := definition eventDefinitions indexOf: matchingDefinition.
			self itemValueFor: (outputs at: definitionIndex) put: eachOccurrence payload ] ].
	self executeCatchDataOutputAssociations.
	^ self
]

{ #category : 'data' }
CPEventExecution >> executeCatchDataOutputAssociations [
	definition dataOutputAssociations do: [ :association |
		| value transformation |
		association assignments do: [ :assignment |
			assignment fromExpression ifNil: [ self error: 'An Event Data Association Assignment requires a from Expression.' ].
			assignment toExpression ifNil: [ self error: 'An Event Data Association Assignment requires a to Expression.' ] ].
		(association transformation isNil and: [ association assignments isEmpty ]) ifTrue: [
			association sourceRefs size = 1 ifFalse: [ self error: 'An Event Data Association without transformation or assignments requires exactly one source.' ] ].
		association targetRef ifNil: [ self error: 'An Event Data Association requires a target.' ].
		association sourceRefs do: [ :each |
			(self ownsItemValueFor: each) ifFalse: [ self error: 'The Event Data Association source does not belong to this Event execution.' ] ].
		transformation := association transformation.
		transformation ifNotNil: [ :transformation |
				value := self scope environment
					evaluateExpression: transformation
					in: self scope
					forEventExecution: self.
				self scope accessibleItemValueFor: association targetRef put: value ].
		transformation ifNil: [
				association assignments ifEmpty: [
					value := self itemValueFor: association sourceRefs first.
					self scope accessibleItemValueFor: association targetRef put: value ] ].
		association assignments do: [ :assignment |
			self scope environment
				executeAssignment: assignment
				in: self scope
				forEventExecution: self ] ].
	^ self
]

{ #category : 'data' }
CPEventExecution >> populateCatchEventDataFrom: anOccurrence [
	| outputs |
	definition isCatchEvent ifFalse: [ self error: 'Only a Catch Event can receive occurrence data.' ].
	outputs := definition dataOutputs.
	outputs isEmpty ifTrue: [ ^ self ].
	outputs size = 1
		ifTrue: [ self itemValueFor: outputs first put: anOccurrence payload ]
		ifFalse: [
			| matchingDefinition definitionIndex |
			definition isStartEvent ifFalse: [
				self error: 'A multiple Catch Event requires occurrence-to-EventDefinition data mapping.' ].
			outputs size = definition eventDefinitions size ifFalse: [
				self error: 'A Multiple Start Event requires one Data Output for each Event Definition.' ].
			matchingDefinition := definition eventDefinitionMatchingInstantiationOccurrence: anOccurrence.
			matchingDefinition ifNil: [ self error: 'The occurrence does not match a Start Event definition.' ].
			definitionIndex := definition eventDefinitions indexOf: matchingDefinition.
			self itemValueFor: (outputs at: definitionIndex) put: anOccurrence payload ].
	self executeCatchDataOutputAssociations.
	^ self
]

{ #category : 'data' }
CPEventExecution >> prepareThrowData [
	definition isThrowEvent ifFalse: [ self error: 'Only a Throw Event can prepare throw data.' ].
	definition dataInputAssociations do: [ :association |
		| value transformation |
		association assignments do: [ :assignment |
			assignment fromExpression ifNil: [ self error: 'An Event Data Association Assignment requires a from Expression.' ].
			assignment toExpression ifNil: [ self error: 'An Event Data Association Assignment requires a to Expression.' ] ].
		(association transformation isNil and: [ association assignments isEmpty ]) ifTrue: [
			association sourceRefs size = 1 ifFalse: [ self error: 'An Event Data Association without transformation or assignments requires exactly one source.' ] ].
		association targetRef ifNil: [ self error: 'An Event Data Association requires a target.' ].
		(self ownsItemValueFor: association targetRef) ifFalse: [ self error: 'A Throw Event Data Association target must belong to this Event execution.' ].
		(association sourceRefs allSatisfy: [ :each | self scope accessibleItemValueAvailableFor: each ]) ifFalse: [
			self error: 'A Throw Event Data Association source is unavailable.' ].
		transformation := association transformation.
		transformation ifNotNil: [ :transformation |
				value := self scope environment
					evaluateExpression: transformation
					in: self scope
					forEventExecution: self.
				self itemValueFor: association targetRef put: value ].
		transformation ifNil: [
				association assignments ifEmpty: [
					value := self scope accessibleItemValueFor: association sourceRefs first.
					self itemValueFor: association targetRef put: value ] ].
		association assignments do: [ :assignment |
			self scope environment
				executeAssignment: assignment
				in: self scope
				forEventExecution: self ] ].
	^ self
]



{ #category : 'accessing' }
CPEventExecution >> thrownOccurrences [ ^ thrownOccurrences ]

{ #category : 'data' }
CPEventExecution >> prepareThrownOccurrences [
	| definitions inputs |
	definition isThrowEvent ifFalse: [ self error: 'Only a Throw Event can prepare thrown occurrences.' ].
	definitions := definition eventDefinitions.
	inputs := definition dataInputs.
	definitions withIndexDo: [ :eventDefinition :index |
		| resultDefinition thrownOccurrence |
		resultDefinition := eventDefinition resultDefinition.
		resultDefinition ifNotNil: [
			thrownOccurrence := CPExecutionOccurrence new
				occurrenceIdentifier: UUID new asString;
				definition: resultDefinition;
				yourself.
			index <= inputs size ifTrue: [
				(self hasItemValueFor: (inputs at: index)) ifFalse: [
					self error: 'A Throw Event Data Input is unavailable for its corresponding Event Definition.' ].
				thrownOccurrence payload: (self itemValueFor: (inputs at: index)) ].
			thrownOccurrences add: thrownOccurrence ] ].
	^ thrownOccurrences
]


{ #category : 'data' }
CPEventExecution >> hasItemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Event execution.' ].
	^ itemValues includesKey: anItemAwareElement
]
