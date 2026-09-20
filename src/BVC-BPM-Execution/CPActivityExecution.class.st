Class {
	#name : 'CPActivityExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'scope',
		'subScope',
		'consumedFlowActivations',
		'state',
		'itemValues'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'instance creation' }
CPActivityExecution class >> for: anActivity in: anExecutionScope [
	^ anExecutionScope addActivityExecution: (self new
		definition: anActivity;
		yourself)
]

{ #category : 'initialization' }
CPActivityExecution >> initialize [
	super initialize.
	consumedFlowActivations := OrderedCollection new.
	state := CPActivityReadyState new.
	itemValues := IdentityDictionary new
]

{ #category : 'accessing' }
CPActivityExecution >> definition [ ^ definition ]
{ #category : 'accessing' }
CPActivityExecution >> definition: anActivity [ definition := anActivity ]
{ #category : 'accessing' }
CPActivityExecution >> scope [ ^ scope ]
{ #category : 'accessing' }
CPActivityExecution >> scope: anExecutionScope [ scope := anExecutionScope ]
{ #category : 'accessing' }
CPActivityExecution >> subScope [ ^ subScope ]
{ #category : 'accessing' }
CPActivityExecution >> state [ ^ state ]
{ #category : 'accessing' }
CPActivityExecution >> consumedFlowActivations [ ^ consumedFlowActivations ]


{ #category : 'data' }
CPActivityExecution >> ownsItemValueFor: anItemAwareElement [
	(definition properties identityIncludes: anItemAwareElement) ifTrue: [ ^ true ].
	definition ioSpecification ifNil: [ ^ false ].
	(definition ioSpecification dataInputs identityIncludes: anItemAwareElement) ifTrue: [ ^ true ].
	^ definition ioSpecification dataOutputs identityIncludes: anItemAwareElement
]

{ #category : 'data' }
CPActivityExecution >> accessibleItemValueAvailableFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [
		^ self hasItemValueFor: anItemAwareElement ].
	^ scope accessibleItemValueAvailableFor: anItemAwareElement
]

{ #category : 'data' }
CPActivityExecution >> hasItemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Activity execution.' ].
	^ itemValues includesKey: anItemAwareElement
]


{ #category : 'data associations' }
CPActivityExecution >> canExecuteDataAssociation: aDataAssociation [
	| source |
	((definition dataInputAssociations identityIncludes: aDataAssociation)
		or: [ definition dataOutputAssociations identityIncludes: aDataAssociation ]) ifFalse: [
		self error: 'The Data Association does not belong to this Activity.' ].
	aDataAssociation transformation ifNotNil: [
		self error: 'Data Association transformations are not yet executable.' ].
	aDataAssociation assignments ifNotEmpty: [
		self error: 'Data Association assignments are not yet executable.' ].
	aDataAssociation sourceRefs size = 1 ifFalse: [
		self error: 'A Data Association without transformation or assignments requires exactly one source.' ].
	aDataAssociation targetRef ifNil: [
		self error: 'A Data Association requires a target.' ].
	source := aDataAssociation sourceRefs first.
	^ self accessibleItemValueAvailableFor: source
]

{ #category : 'data associations' }
CPActivityExecution >> dataInputAssociationsTargeting: aDataInput [
	^ definition dataInputAssociations select: [ :each |
		each targetRef == aDataInput ]
]

{ #category : 'data associations' }
CPActivityExecution >> inputSetIsAvailable: anInputSet [
	| requiredInputs associations |
	requiredInputs := anInputSet dataInputRefs reject: [ :each |
		(anInputSet optionalInputRefs identityIncludes: each)
			or: [ anInputSet whileExecutingInputRefs identityIncludes: each ] ].
	requiredInputs do: [ :eachInput |
		associations := self dataInputAssociationsTargeting: eachInput.
		associations ifEmpty: [
			(self hasItemValueFor: eachInput) ifFalse: [ ^ false ] ].
		(associations allSatisfy: [ :each | self canExecuteDataAssociation: each ]) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'data associations' }
CPActivityExecution >> firstAvailableInputSet [
	definition ioSpecification ifNil: [ ^ nil ].
	definition ioSpecification inputSets do: [ :each |
		(self inputSetIsAvailable: each) ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : 'data associations' }
CPActivityExecution >> prepareInputs [
	| inputSet associations |
	definition ioSpecification ifNil: [ ^ true ].
	inputSet := self firstAvailableInputSet.
	inputSet ifNil: [ ^ false ].
	inputSet dataInputRefs do: [ :eachInput |
		associations := self dataInputAssociationsTargeting: eachInput.
		associations do: [ :each |
			(self canExecuteDataAssociation: each)
				ifTrue: [ self executeDataAssociation: each ] ] ].
	^ true
]

{ #category : 'data associations' }
CPActivityExecution >> executeDataAssociation: aDataAssociation [
	| source |
	((definition dataInputAssociations identityIncludes: aDataAssociation)
		or: [ definition dataOutputAssociations identityIncludes: aDataAssociation ]) ifFalse: [
		self error: 'The Data Association does not belong to this Activity.' ].
	aDataAssociation transformation ifNotNil: [
		self error: 'Data Association transformations are not yet executable.' ].
	aDataAssociation assignments ifNotEmpty: [
		self error: 'Data Association assignments are not yet executable.' ].
	aDataAssociation sourceRefs size = 1 ifFalse: [
		self error: 'A Data Association without transformation or assignments requires exactly one source.' ].
	aDataAssociation targetRef ifNil: [
		self error: 'A Data Association requires a target.' ].
	source := aDataAssociation sourceRefs first.
	(self accessibleItemValueAvailableFor: source) ifFalse: [ ^ false ].
	self accessibleItemValueFor: aDataAssociation targetRef put: (self accessibleItemValueFor: source).
	^ true
]

{ #category : 'data' }
CPActivityExecution >> accessibleItemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [
		^ self itemValueFor: anItemAwareElement ].
	^ scope accessibleItemValueFor: anItemAwareElement
]

{ #category : 'data' }
CPActivityExecution >> accessibleItemValueFor: anItemAwareElement put: aValue [
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [
		^ self itemValueFor: anItemAwareElement put: aValue ].
	^ scope accessibleItemValueFor: anItemAwareElement put: aValue
]

{ #category : 'data' }
CPActivityExecution >> itemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Activity execution.' ].
	^ itemValues at: anItemAwareElement ifAbsent: [ nil ]
]

{ #category : 'data' }
CPActivityExecution >> itemValueFor: anItemAwareElement put: aValue [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Activity execution.' ].
	itemValues at: anItemAwareElement put: aValue.
	^ aValue
]

{ #category : 'control flow' }
CPActivityExecution >> consumeFlowActivation: anActivation [
	anActivation consumeBy: self.
	consumedFlowActivations add: anActivation.
	^ anActivation
]

{ #category : 'building' }
CPActivityExecution >> createSubScopeFor: aScopeDefinition [
	subScope ifNotNil: [ self error: 'An Activity execution can own only one execution scope.' ].
	^ CPExecutionScope for: aScopeDefinition ownedBy: self
]

{ #category : 'building' }
CPActivityExecution >> attachSubScope: anExecutionScope [
	subScope ifNotNil: [ self error: 'An Activity execution already owns an execution scope.' ].
	anExecutionScope owningActivity ifNotNil: [ self error: 'The execution scope is already owned by an Activity execution.' ].
	scope ifNil: [ self error: 'The Activity execution must belong to a scope before it can own a child scope.' ].
	anExecutionScope owningActivity: self.
	scope addChildScope: anExecutionScope.
	subScope := anExecutionScope.
	^ anExecutionScope
]

{ #category : 'testing' }
CPActivityExecution >> isReady [ ^ state class = CPActivityReadyState ]
{ #category : 'testing' }
CPActivityExecution >> isActive [ ^ state class = CPActivityActiveState ]
{ #category : 'testing' }
CPActivityExecution >> isCompleting [ ^ state class = CPActivityCompletingState ]
{ #category : 'testing' }
CPActivityExecution >> isCompleted [ ^ state class = CPActivityCompletedState ]
{ #category : 'testing' }
CPActivityExecution >> isFinal [ ^ state isFinal ]

{ #category : 'lifecycle' }
CPActivityExecution >> prepareForActivation [
	self isReady ifFalse: [ self error: 'Only a Ready Activity can prepare for activation.' ].
	^ self prepareInputs
]

{ #category : 'lifecycle' }
CPActivityExecution >> activate [
	self isReady ifFalse: [ self error: 'Only a Ready Activity can become Active.' ].
	state := CPActivityActiveState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> withdraw [
	(self isReady or: [ self isActive ]) ifFalse: [ self error: 'Only a Ready or Active Activity can be Withdrawn.' ].
	state := CPActivityWithdrawnState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> fail [
	self isActive ifFalse: [ self error: 'Only an Active Activity can fail.' ].
	state := CPActivityFailedState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> beginCompletion [
	self isActive ifFalse: [ self error: 'Only an Active Activity can begin completion.' ].
	state := CPActivityCompletingState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> complete [
	self isCompleting ifFalse: [ self error: 'Only a Completing Activity can become Completed.' ].
	state := CPActivityCompletedState new.
	scope ifNotNil: [ scope activityExecutionDidComplete: self ]
]
{ #category : 'lifecycle' }
CPActivityExecution >> beginFailure [
	self isActive ifFalse: [ self error: 'Only an Active Activity can begin failure handling.' ].
	state := CPActivityFailingState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> finishFailure [
	state class = CPActivityFailingState ifFalse: [ self error: 'Only a Failing Activity can become Failed.' ].
	state := CPActivityFailedState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> beginTermination [
	(self isActive or: [ self isCompleting ]) ifFalse: [ self error: 'Only an Active or Completing Activity can begin termination.' ].
	state := CPActivityTerminatingState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> finishTermination [
	state class = CPActivityTerminatingState ifFalse: [ self error: 'Only a Terminating Activity can become Terminated.' ].
	state := CPActivityTerminatedState new
]
