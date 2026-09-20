Class {
	#name : 'CPEventExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'scope',
		'consumedFlowActivation',
		'producedFlowActivations',
		'occurrence',
		'itemValues'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPEventExecution >> initialize [
	super initialize.
	producedFlowActivations := OrderedCollection new.
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

{ #category : 'data' }
CPEventExecution >> populateCatchEventDataFrom: anOccurrence [
	| outputs |
	definition isCatchEvent ifFalse: [ self error: 'Only a Catch Event can receive occurrence data.' ].
	outputs := definition dataOutputs.
	outputs isEmpty ifTrue: [ ^ self ].
	outputs size = 1 ifFalse: [
		self error: 'A single Event occurrence requires exactly one corresponding Data Output.' ].
	self itemValueFor: outputs first put: anOccurrence payload.
	definition dataOutputAssociations do: [ :association |
		| source |
		association transformation ifNotNil: [ self error: 'Event Data Association transformations are not yet executable.' ].
		association assignments ifNotEmpty: [ self error: 'Event Data Association assignments are not yet executable.' ].
		association sourceRefs size = 1 ifFalse: [ self error: 'An Event Data Association without transformation or assignments requires exactly one source.' ].
		association targetRef ifNil: [ self error: 'An Event Data Association requires a target.' ].
		source := association sourceRefs first.
		(self ownsItemValueFor: source) ifFalse: [ self error: 'The Event Data Association source does not belong to this Event execution.' ].
		self scope accessibleItemValueFor: association targetRef put: (self itemValueFor: source) ].
	^ self
]
