Class {
	#name : 'CPActivityExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'scope',
		'subScope',
		'consumedFlowActivations',
		'state',
		'itemValues',
		'itemValueProducers',
		'dataDependencies',
		'selectedInputSet',
		'selectedOutputSet',
		'loopCounter',
		'standardLoopIterations',
		'multiInstanceCardinality',
		'multiInstanceInputItems',
		'multiInstanceActivityExecutions'
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
	itemValues := IdentityDictionary new.
	itemValueProducers := IdentityDictionary new.
	dataDependencies := OrderedCollection new.
	loopCounter := 0.
	standardLoopIterations := OrderedCollection new.
	multiInstanceCardinality := nil.
	multiInstanceInputItems := nil.
	multiInstanceActivityExecutions := OrderedCollection new
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
{ #category : 'accessing' }
CPActivityExecution >> selectedInputSet [ ^ selectedInputSet ]
{ #category : 'accessing' }
CPActivityExecution >> selectedOutputSet [ ^ selectedOutputSet ]


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
	selectedInputSet := inputSet.
	inputSet dataInputRefs do: [ :eachInput |
		associations := self dataInputAssociationsTargeting: eachInput.
		associations do: [ :each |
			(self canExecuteDataAssociation: each)
				ifTrue: [ self executeDataAssociation: each ] ] ].
	^ true
]



{ #category : 'data' }
CPActivityExecution >> populateSingleDataOutputFromOccurrence: anOccurrence [
	| outputs |
	definition ioSpecification ifNil: [ ^ self ].
	outputs := definition ioSpecification dataOutputs.
	outputs ifEmpty: [ ^ self ].
	outputs size = 1 ifFalse: [
		self error: 'This Activity result requires exactly one Data Output.' ].
	self itemValueFor: outputs first put: anOccurrence payload.
	^ self
]


{ #category : 'data associations' }
CPActivityExecution >> dataOutputAssociationsSourcedBy: aDataOutput [
	^ definition dataOutputAssociations select: [ :each |
		each sourceRefs identityIncludes: aDataOutput ]
]

{ #category : 'data associations' }
CPActivityExecution >> outputSetIsAvailable: anOutputSet [
	| requiredOutputs |
	requiredOutputs := anOutputSet dataOutputRefs reject: [ :each |
		anOutputSet optionalOutputRefs identityIncludes: each ].
	^ requiredOutputs allSatisfy: [ :eachOutput |
		self hasItemValueFor: eachOutput ]
]

{ #category : 'data associations' }
CPActivityExecution >> firstAvailableOutputSet [
	definition ioSpecification ifNil: [ ^ nil ].
	definition ioSpecification outputSets do: [ :each |
		(self outputSetIsAvailable: each) ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : 'data associations' }
CPActivityExecution >> selectedInputSetAllowsOutputSet: anOutputSet [
	selectedInputSet ifNil: [ ^ true ].
	selectedInputSet outputSetRefs ifNotEmpty: [
		(selectedInputSet outputSetRefs identityIncludes: anOutputSet) ifFalse: [ ^ false ] ].
	anOutputSet inputSetRefs ifNotEmpty: [
		(anOutputSet inputSetRefs identityIncludes: selectedInputSet) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'data associations' }
CPActivityExecution >> prepareOutputs [
	| outputSet associations |
	definition ioSpecification ifNil: [ ^ true ].
	outputSet := self firstAvailableOutputSet.
	outputSet ifNil: [ self error: 'The Activity has no available OutputSet.' ].
	(self selectedInputSetAllowsOutputSet: outputSet) ifFalse: [
		self error: 'The selected OutputSet is not compatible with the InputSet used to start the Activity.' ].
	selectedOutputSet := outputSet.
	outputSet dataOutputRefs do: [ :eachOutput |
		(self hasItemValueFor: eachOutput) ifTrue: [
			associations := self dataOutputAssociationsSourcedBy: eachOutput.
			associations do: [ :each | self executeDataAssociation: each ] ] ].
	^ true
]

{ #category : 'data associations' }
CPActivityExecution >> executeDataAssociation: aDataAssociation [
	| source producer value |
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
	producer := self accessibleItemValueProducerFor: source.
	producer ifNotNil: [ self recordDataDependencyOn: producer ].
	value := self accessibleItemValueFor: source.
	(definition dataOutputAssociations identityIncludes: aDataAssociation)
		ifTrue: [ self accessibleItemValueFor: aDataAssociation targetRef put: value producedBy: self ]
		ifFalse: [ self accessibleItemValueFor: aDataAssociation targetRef put: value ].
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

{ #category : 'data - provenance' }
CPActivityExecution >> accessibleItemValueProducerFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [
		^ self itemValueProducerFor: anItemAwareElement ].
	^ scope accessibleItemValueProducerFor: anItemAwareElement
]

{ #category : 'data - provenance' }
CPActivityExecution >> accessibleItemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution [
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [
		^ self itemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution ].
	^ scope accessibleItemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution
]

{ #category : 'data - provenance' }
CPActivityExecution >> itemValueProducerFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Activity execution.' ].
	^ itemValueProducers at: anItemAwareElement ifAbsent: [ nil ]
]

{ #category : 'data - provenance' }
CPActivityExecution >> itemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Activity execution.' ].
	itemValues at: anItemAwareElement put: aValue.
	itemValueProducers at: anItemAwareElement put: anActivityExecution.
	^ aValue
]

{ #category : 'data - provenance' }
CPActivityExecution >> recordDataDependencyOn: anActivityExecution [
	anActivityExecution == self ifTrue: [ ^ self ].
	(dataDependencies identityIncludes: anActivityExecution) ifFalse: [
		dataDependencies add: anActivityExecution ].
	^ self
]

{ #category : 'data - provenance' }
CPActivityExecution >> hasDataDependencyOn: anActivityExecution [
	^ dataDependencies identityIncludes: anActivityExecution
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
	itemValueProducers at: anItemAwareElement put: nil.
	^ aValue
]


{ #category : 'data - snapshot' }
CPActivityExecution >> itemValuesSnapshot [
	^ itemValues copy
]

{ #category : 'data - snapshot' }
CPActivityExecution >> restoreItemValuesFromSnapshot: aDictionary [
	itemValues := aDictionary copy.
	itemValueProducers := IdentityDictionary new.
	^ self
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



{ #category : 'looping' }
CPActivityExecution >> loopCounter [
	^ loopCounter
]

{ #category : 'looping' }
CPActivityExecution >> standardLoopMayBeginNextIteration [
	| loop maximum condition |
	loop := definition loopCharacteristics.
	loop ifNil: [ ^ true ].
	loop isStandardLoop ifFalse: [
		self error: 'This execution decision applies only to BPMN Standard Loop characteristics.' ].
	maximum := loop loopMaximum.
	(maximum notNil and: [ loopCounter >= maximum ]) ifTrue: [ ^ false ].
	(loopCounter = 0 and: [ loop testBefore not ]) ifTrue: [ ^ true ].
	condition := loop loopCondition.
	condition ifNil: [
		self error: 'An executable Standard Loop requires a loopCondition.' ].
	^ scope environment evaluateExpression: condition in: scope forActivityExecution: self
]

{ #category : 'looping' }
CPActivityExecution >> recordStandardLoopIterationCompletion [
	| loop |
	loop := definition loopCharacteristics.
	(loop notNil and: [ loop isStandardLoop ]) ifFalse: [
		self error: 'Only a BPMN Standard Loop execution can complete a loop iteration.' ].
	loopCounter := loopCounter + 1.
	^ loopCounter
]



{ #category : 'looping' }
CPActivityExecution >> standardLoopIterations [
	^ standardLoopIterations
]

{ #category : 'looping' }
CPActivityExecution >> activeStandardLoopIteration [
	^ standardLoopIterations
		detect: [ :each | each isActive ]
		ifNone: [ nil ]
]

{ #category : 'looping' }
CPActivityExecution >> beginStandardLoopIteration [
	| iteration |
	self isActive ifFalse: [ self error: 'Only an Active Activity can begin a Standard Loop iteration.' ].
	(self activeStandardLoopIteration notNil) ifTrue: [
		self error: 'A Standard Loop Activity can execute only one iteration at a time.' ].
	self standardLoopMayBeginNextIteration ifFalse: [
		self error: 'The Standard Loop conditions do not permit another iteration.' ].
	iteration := CPStandardLoopIterationExecution new
		activityExecution: self;
		index: loopCounter + 1;
		activate;
		yourself.
	standardLoopIterations add: iteration.
	^ iteration
]

{ #category : 'looping' }
CPActivityExecution >> completeStandardLoopIteration: anIteration [
	(standardLoopIterations identityIncludes: anIteration) ifFalse: [
		self error: 'The Standard Loop iteration does not belong to this Activity execution.' ].
	anIteration isActive ifFalse: [
		self error: 'Only an Active Standard Loop iteration can complete.' ].
	anIteration complete.
	self recordStandardLoopIterationCompletion.
	^ anIteration
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
	self prepareOutputs.
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


{ #category : 'multi-instance' }
CPActivityExecution >> multiInstanceCardinality [
	^ multiInstanceCardinality
]

{ #category : 'multi-instance' }
CPActivityExecution >> initializeMultiInstanceCardinality [
	| loop expression cardinality loopDataInput collection |
	multiInstanceCardinality ifNotNil: [ ^ multiInstanceCardinality ].
	loop := definition loopCharacteristics.
	(loop notNil and: [ loop isMultiInstance ]) ifFalse: [
		self error: 'Only a BPMN Multi-Instance Activity can initialize instance cardinality.' ].
	expression := loop loopCardinality.
	expression ifNotNil: [
		cardinality := scope environment
			evaluateExpression: expression
			in: scope
			forActivityExecution: self.
		(cardinality isInteger and: [ cardinality >= 0 ]) ifFalse: [
			self error: 'A Multi-Instance loopCardinality must evaluate to a non-negative integer.' ].
		multiInstanceCardinality := cardinality.
		^ multiInstanceCardinality ].
	loopDataInput := loop loopDataInputRef.
	loopDataInput ifNil: [
		self error: 'A Multi-Instance Activity requires loopCardinality or loopDataInputRef.' ].
	loopDataInput isCollection ifFalse: [
		self error: 'A Multi-Instance loopDataInputRef must reference collection-valued data.' ].
	(self accessibleItemValueAvailableFor: loopDataInput) ifFalse: [
		self error: 'The Multi-Instance loopDataInputRef value is unavailable.' ].
	collection := self accessibleItemValueFor: loopDataInput.
	multiInstanceInputItems := OrderedCollection withAll: collection.
	multiInstanceCardinality := multiInstanceInputItems size.
	^ multiInstanceCardinality
]

{ #category : 'multi-instance' }
CPActivityExecution >> multiInstanceInputItems [
	^ multiInstanceInputItems
]


{ #category : 'multi-instance' }
CPActivityExecution >> multiInstanceActivityExecutions [
	^ multiInstanceActivityExecutions
]

{ #category : 'multi-instance' }
CPActivityExecution >> beginMultiInstanceActivityExecutionAt: anIndex [
	| loop instance |
	self initializeMultiInstanceCardinality.
	(anIndex between: 1 and: multiInstanceCardinality) ifFalse: [
		self error: 'A Multi-Instance Activity instance index is outside the initialized cardinality.' ].
	(multiInstanceActivityExecutions anySatisfy: [ :each | each index = anIndex ]) ifTrue: [
		self error: 'A Multi-Instance Activity instance already exists for this index.' ].
	loop := definition loopCharacteristics.
	instance := CPMultiInstanceActivityExecution new
		activityExecution: self;
		index: anIndex;
		yourself.
	(loop inputDataItem notNil and: [ multiInstanceInputItems notNil ]) ifTrue: [
		instance itemValueFor: loop inputDataItem put: (multiInstanceInputItems at: anIndex) ].
	multiInstanceActivityExecutions add: instance.
	^ instance
]


{ #category : 'multi-instance' }
CPActivityExecution >> beginMultiInstanceActivityExecutions [
	| loop |
	self initializeMultiInstanceCardinality.
	loop := definition loopCharacteristics.
	multiInstanceCardinality = 0 ifTrue: [ ^ multiInstanceActivityExecutions ].
	loop isSequential ifTrue: [
		self beginMultiInstanceActivityExecutionAt: 1.
		^ multiInstanceActivityExecutions ].
	1 to: multiInstanceCardinality do: [ :index |
		self beginMultiInstanceActivityExecutionAt: index ].
	^ multiInstanceActivityExecutions
]

{ #category : 'multi-instance' }
CPActivityExecution >> multiInstanceActivityExecutionDidComplete: anInstance [
	| loop nextIndex |
	(multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
		self error: 'The completed Multi-Instance Activity instance does not belong to this Activity execution.' ].
	loop := definition loopCharacteristics.
	(self multiInstanceCompletionConditionSatisfied) ifTrue: [
		self cancelRemainingMultiInstanceActivityExecutions.
		self completeMultiInstanceActivityExecution.
		^ anInstance ].
	self multiInstanceCompletedCount = multiInstanceCardinality ifTrue: [
		self completeMultiInstanceActivityExecution.
		^ anInstance ].
	loop isSequential ifTrue: [
		nextIndex := anInstance index + 1.
		nextIndex <= multiInstanceCardinality ifTrue: [
			self beginMultiInstanceActivityExecutionAt: nextIndex ] ].
	^ anInstance
]

{ #category : 'multi-instance' }
CPActivityExecution >> multiInstanceCompletionConditionSatisfied [
	| condition |
	condition := definition loopCharacteristics completionCondition.
	condition ifNil: [ ^ false ].
	^ scope environment
		evaluateExpression: condition
		in: scope
		forActivityExecution: self
]

{ #category : 'multi-instance' }
CPActivityExecution >> cancelRemainingMultiInstanceActivityExecutions [
	multiInstanceActivityExecutions do: [ :each |
		each isActive ifTrue: [ each cancel ] ].
]

{ #category : 'multi-instance' }
CPActivityExecution >> completeMultiInstanceActivityExecution [
	self isActive ifFalse: [ self error: 'Only an Active Multi-Instance Activity can complete.' ].
	self beginCompletion.
	self complete.
	^ self
]

{ #category : 'multi-instance' }
CPActivityExecution >> multiInstanceCompletedCount [
	^ multiInstanceActivityExecutions count: [ :each | each isCompleted ]
]


{ #category : 'multi-instance' }
CPActivityExecution >> multiInstanceActiveCount [
	^ multiInstanceActivityExecutions count: [ :each | each isActive ]
]

{ #category : 'multi-instance' }
CPActivityExecution >> multiInstanceCancelledCount [
	^ multiInstanceActivityExecutions count: [ :each | each isCancelled ]
]
