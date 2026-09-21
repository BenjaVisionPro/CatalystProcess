Class {
	#name : 'CPMultiInstanceActivityExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'activityExecution',
		'index',
		'itemValues',
		'itemValueProducers',
		'selectedInputSet',
		'selectedOutputSet',
		'subScope',
		'activityItemValuesSnapshot',
		'scopeItemValuesSnapshot',
		'thrownOccurrences',
		'externalInvocation',
		'messageSubscription',
		'receivedOccurrence',
		'messageDispatch',
		'userTaskWorkItem',
		'manualTaskResourceAssignments',
		'completed',
		'cancelled'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPMultiInstanceActivityExecution >> initialize [
	super initialize.
	itemValues := IdentityDictionary new.
	itemValueProducers := IdentityDictionary new.
	thrownOccurrences := OrderedCollection new.
	completed := false.
	cancelled := false
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> activityExecution [
	^ activityExecution
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> activityExecution: anActivityExecution [
	activityExecution := anActivityExecution
]


{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> modeledActivityExecution [
	^ activityExecution
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> scope [
	^ activityExecution scope
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> subScope [
	^ subScope
]

{ #category : 'building' }
CPMultiInstanceActivityExecution >> createSubScopeFor: aScopeDefinition [
	subScope ifNotNil: [ self error: 'A Multi-Instance Activity instance can own only one execution scope.' ].
	^ CPExecutionScope for: aScopeDefinition ownedBy: self
]

{ #category : 'building' }
CPMultiInstanceActivityExecution >> attachSubScope: anExecutionScope [
	subScope ifNotNil: [ self error: 'A Multi-Instance Activity instance already owns an execution scope.' ].
	anExecutionScope owningActivity ifNotNil: [ self error: 'The execution scope is already owned by an Activity execution.' ].
	self scope ifNil: [ self error: 'The Multi-Instance Activity execution must belong to a scope before its instance can own a child scope.' ].
	anExecutionScope owningActivity: self.
	self scope addChildScope: anExecutionScope.
	subScope := anExecutionScope.
	^ anExecutionScope
]

{ #category : 'sub-process' }
CPMultiInstanceActivityExecution >> subProcessScopeDidComplete: anExecutionScope [
	anExecutionScope == subScope ifFalse: [ self error: 'The completed Sub-Process scope does not belong to this Multi-Instance Activity instance.' ].
	activityExecution isActive ifFalse: [ self error: 'Only an instance of an Active Multi-Instance Activity can complete its Sub-Process scope.' ].
	self isActive ifFalse: [ self error: 'Only an active Multi-Instance Activity instance can complete its Sub-Process scope.' ].
	self complete.
	^ self
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> index [
	^ index
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> index: anInteger [
	index := anInteger
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> ownsItemValueFor: anItemAwareElement [
	| definition loop specification |
	definition := activityExecution definition.
	loop := definition loopCharacteristics.
	(loop inputDataItem == anItemAwareElement
		or: [ loop outputDataItem == anItemAwareElement ]) ifTrue: [ ^ true ].
	(definition properties identityIncludes: anItemAwareElement) ifTrue: [ ^ true ].
	specification := definition ioSpecification.
	specification ifNil: [ ^ false ].
	((specification dataInputs identityIncludes: anItemAwareElement)
		and: [ loop loopDataInputRef ~~ anItemAwareElement ]) ifTrue: [ ^ true ].
	^ (specification dataOutputs identityIncludes: anItemAwareElement)
		and: [ loop loopDataOutputRef ~~ anItemAwareElement ]
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> hasItemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Multi-Instance Activity instance.' ].
	^ itemValues includesKey: anItemAwareElement
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> itemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Multi-Instance Activity instance.' ].
	^ itemValues at: anItemAwareElement ifAbsent: [ nil ]
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> itemValueFor: anItemAwareElement put: aValue [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Multi-Instance Activity instance.' ].
	itemValues at: anItemAwareElement put: aValue.
	^ aValue
]


{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> selectedInputSet [
	^ selectedInputSet
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> selectedOutputSet [
	^ selectedOutputSet
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> isOuterMultiInstanceItemValueFor: anItemAwareElement [
	| loop |
	loop := activityExecution definition loopCharacteristics.
	^ loop loopDataInputRef == anItemAwareElement
		or: [ loop loopDataOutputRef == anItemAwareElement ]
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> accessibleItemValueAvailableFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [
		^ self hasItemValueFor: anItemAwareElement ].
	(self isOuterMultiInstanceItemValueFor: anItemAwareElement) ifTrue: [
		^ activityExecution accessibleItemValueAvailableFor: anItemAwareElement ].
	^ self scope accessibleItemValueAvailableFor: anItemAwareElement
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> accessibleItemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [
		^ self itemValueFor: anItemAwareElement ].
	(self isOuterMultiInstanceItemValueFor: anItemAwareElement) ifTrue: [
		^ activityExecution accessibleItemValueFor: anItemAwareElement ].
	^ self scope accessibleItemValueFor: anItemAwareElement
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> accessibleItemValueFor: anItemAwareElement put: aValue [
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [
		^ self itemValueFor: anItemAwareElement put: aValue ].
	(self isOuterMultiInstanceItemValueFor: anItemAwareElement) ifTrue: [
		^ activityExecution accessibleItemValueFor: anItemAwareElement put: aValue ].
	^ self scope accessibleItemValueFor: anItemAwareElement put: aValue
]

{ #category : 'data - provenance' }
CPMultiInstanceActivityExecution >> itemValueProducerFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Multi-Instance Activity instance.' ].
	^ itemValueProducers at: anItemAwareElement ifAbsent: [ nil ]
]

{ #category : 'data - provenance' }
CPMultiInstanceActivityExecution >> accessibleItemValueProducerFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [
		^ self itemValueProducerFor: anItemAwareElement ].
	(self isOuterMultiInstanceItemValueFor: anItemAwareElement) ifTrue: [
		^ activityExecution accessibleItemValueProducerFor: anItemAwareElement ].
	^ self scope accessibleItemValueProducerFor: anItemAwareElement
]

{ #category : 'data - provenance' }
CPMultiInstanceActivityExecution >> itemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Multi-Instance Activity instance.' ].
	itemValues at: anItemAwareElement put: aValue.
	itemValueProducers at: anItemAwareElement put: anActivityExecution.
	^ aValue
]

{ #category : 'data - provenance' }
CPMultiInstanceActivityExecution >> accessibleItemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution [
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [
		^ self itemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution ].
	(self isOuterMultiInstanceItemValueFor: anItemAwareElement) ifTrue: [
		^ activityExecution accessibleItemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution ].
	^ self scope accessibleItemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> canExecuteDataAssociation: aDataAssociation [
	| definition |
	definition := activityExecution definition.
	((definition dataInputAssociations identityIncludes: aDataAssociation)
		or: [ definition dataOutputAssociations identityIncludes: aDataAssociation ]) ifFalse: [
		self error: 'The Data Association does not belong to this Activity.' ].
	aDataAssociation assignments ifNotEmpty: [
		self error: 'Data Association assignments are not yet executable.' ].
	aDataAssociation transformation ifNil: [
		aDataAssociation sourceRefs size = 1 ifFalse: [
			self error: 'A Data Association without transformation or assignments requires exactly one source.' ] ].
	aDataAssociation targetRef ifNil: [
		self error: 'A Data Association requires a target.' ].
	^ aDataAssociation sourceRefs allSatisfy: [ :each |
		self accessibleItemValueAvailableFor: each ]
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> executeDataAssociation: aDataAssociation [
	| definition value |
	definition := activityExecution definition.
	(self canExecuteDataAssociation: aDataAssociation) ifFalse: [ ^ false ].
	aDataAssociation sourceRefs do: [ :each |
		| producer |
		producer := self accessibleItemValueProducerFor: each.
		producer ifNotNil: [ activityExecution recordDataDependencyOn: producer ] ].
	value := aDataAssociation transformation
		ifNil: [ self accessibleItemValueFor: aDataAssociation sourceRefs first ]
		ifNotNil: [ :transformation |
			self scope environment
				evaluateExpression: transformation
				in: self scope
				forActivityExecution: self ].
	(definition dataOutputAssociations identityIncludes: aDataAssociation)
		ifTrue: [ self accessibleItemValueFor: aDataAssociation targetRef put: value producedBy: activityExecution ]
		ifFalse: [ self accessibleItemValueFor: aDataAssociation targetRef put: value ].
	^ true
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> dataInputAssociationsTargeting: aDataInput [
	^ activityExecution definition dataInputAssociations select: [ :each |
		each targetRef == aDataInput ]
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> inputSetIsAvailable: anInputSet [
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
CPMultiInstanceActivityExecution >> firstAvailableInputSet [
	activityExecution definition ioSpecification ifNil: [ ^ nil ].
	activityExecution definition ioSpecification inputSets do: [ :each |
		(self inputSetIsAvailable: each) ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> prepareInputs [
	| inputSet associations |
	activityExecution definition ioSpecification ifNil: [ ^ true ].
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

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> dataOutputAssociationsSourcedBy: aDataOutput [
	^ activityExecution definition dataOutputAssociations select: [ :each |
		each sourceRefs identityIncludes: aDataOutput ]
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> outputSetIsAvailable: anOutputSet [
	| requiredOutputs |
	requiredOutputs := anOutputSet dataOutputRefs reject: [ :each |
		anOutputSet optionalOutputRefs identityIncludes: each ].
	^ requiredOutputs allSatisfy: [ :eachOutput |
		self hasItemValueFor: eachOutput ]
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> firstAvailableOutputSet [
	activityExecution definition ioSpecification ifNil: [ ^ nil ].
	activityExecution definition ioSpecification outputSets do: [ :each |
		(self outputSetIsAvailable: each) ifTrue: [ ^ each ] ].
	^ nil
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> selectedInputSetAllowsOutputSet: anOutputSet [
	selectedInputSet ifNil: [ ^ true ].
	selectedInputSet outputSetRefs ifNotEmpty: [
		(selectedInputSet outputSetRefs identityIncludes: anOutputSet) ifFalse: [ ^ false ] ].
	anOutputSet inputSetRefs ifNotEmpty: [
		(anOutputSet inputSetRefs identityIncludes: selectedInputSet) ifFalse: [ ^ false ] ].
	^ true
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> prepareOutputs [
	| outputSet associations |
	activityExecution definition ioSpecification ifNil: [ ^ true ].
	outputSet := self firstAvailableOutputSet.
	outputSet ifNil: [ self error: 'The Multi-Instance Activity instance has no available OutputSet.' ].
	(self selectedInputSetAllowsOutputSet: outputSet) ifFalse: [
		self error: 'The selected OutputSet is not compatible with the InputSet used to start the Multi-Instance Activity instance.' ].
	selectedOutputSet := outputSet.
	outputSet dataOutputRefs do: [ :eachOutput |
		(self hasItemValueFor: eachOutput) ifTrue: [
			associations := self dataOutputAssociationsSourcedBy: eachOutput.
			associations do: [ :each | self executeDataAssociation: each ] ] ].
	^ true
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> hasPerInstanceInputAssociations [
	^ activityExecution definition dataInputAssociations anySatisfy: [ :each |
		self ownsItemValueFor: each targetRef ]
]

{ #category : 'data associations' }
CPMultiInstanceActivityExecution >> hasPerInstanceOutputAssociations [
	^ activityExecution definition dataOutputAssociations anySatisfy: [ :each |
		each sourceRefs anySatisfy: [ :source | self ownsItemValueFor: source ] ]
]



{ #category : 'external work' }
CPMultiInstanceActivityExecution >> externalInvocation [
	^ externalInvocation
]

{ #category : 'external work' }
CPMultiInstanceActivityExecution >> prepareExternalInvocationIdentifiedBy: anIdentifier [
	| implementation inputs input |
	self isActive ifFalse: [ self error: 'Only an active Multi-Instance Activity instance can prepare external work.' ].
	externalInvocation ifNotNil: [ self error: 'A Multi-Instance Activity instance can prepare external work only once.' ].
	implementation := activityExecution resolvedImplementation.
	implementation ifNil: [ self error: 'A Multi-Instance Service Task requires a resolved implementation before preparing external work.' ].
	externalInvocation := CPExternalInvocation new
		invocationIdentifier: anIdentifier;
		activityExecution: self;
		implementation: implementation;
		yourself.
	selectedInputSet ifNil: [ ^ externalInvocation ].
	inputs := selectedInputSet dataInputRefs select: [ :each | self ownsItemValueFor: each ].
	inputs ifEmpty: [ ^ externalInvocation ].
	inputs size = 1 ifFalse: [
		self error: 'A Multi-Instance Service Task Operation input requires exactly one per-instance Data Input.' ].
	input := inputs first.
	(self hasItemValueFor: input) ifFalse: [
		self error: 'The Multi-Instance Service Task Data Input is unavailable for external invocation.' ].
	externalInvocation inputValue: (self itemValueFor: input).
	^ externalInvocation
]

{ #category : 'external work' }
CPMultiInstanceActivityExecution >> populateSingleDataOutputFromOccurrence: anOccurrence [
	| specification loop outputs |
	specification := activityExecution definition ioSpecification.
	specification ifNil: [ ^ self ].
	loop := activityExecution definition loopCharacteristics.
	outputs := specification dataOutputs select: [ :each |
		loop loopDataOutputRef ~~ each and: [ self ownsItemValueFor: each ] ].
	outputs ifEmpty: [ ^ self ].
	outputs size = 1 ifFalse: [
		self error: 'This Multi-Instance Activity result requires exactly one per-instance Data Output.' ].
	self itemValueFor: outputs first put: anOccurrence payload.
	^ self
]


{ #category : 'messages' }
CPMultiInstanceActivityExecution >> messageSubscription [
	^ messageSubscription
]

{ #category : 'messages' }
CPMultiInstanceActivityExecution >> messageSubscription: aMessageSubscription [
	messageSubscription := aMessageSubscription
]

{ #category : 'messages' }
CPMultiInstanceActivityExecution >> receivedOccurrence [
	^ receivedOccurrence
]

{ #category : 'messages' }
CPMultiInstanceActivityExecution >> isWaitingForMessage [
	^ self isActive
		and: [ receivedOccurrence isNil
		and: [ messageSubscription notNil
		and: [ messageSubscription isCancelled not ] ] ]
]

{ #category : 'messages' }
CPMultiInstanceActivityExecution >> acceptMessageSubscription: aSubscription occurrence: anOccurrence [
	messageSubscription == aSubscription ifFalse: [
		self error: 'The Message subscription does not belong to this Multi-Instance Activity instance.' ].
	^ self scope triggerMultiInstanceReceiveTaskExecution: self with: anOccurrence
]

{ #category : 'messages' }
CPMultiInstanceActivityExecution >> acceptReceivedOccurrence: anOccurrence [
	self isWaitingForMessage ifFalse: [
		self error: 'Only a waiting Multi-Instance Receive Task instance can accept a message occurrence.' ].
	receivedOccurrence := anOccurrence.
	^ anOccurrence
]

{ #category : 'lifecycle' }
CPMultiInstanceActivityExecution >> isCompleted [
	^ completed
]

{ #category : 'lifecycle' }
CPMultiInstanceActivityExecution >> complete [
	completed ifTrue: [ self error: 'A Multi-Instance Activity instance cannot complete twice.' ].
	cancelled ifTrue: [ self error: 'A cancelled Multi-Instance Activity instance cannot complete.' ].
	self hasPerInstanceOutputAssociations ifTrue: [ self prepareOutputs ].
	activityExecution prepareMultiInstanceActivityExecutionCompletion: self.
	activityExecution definition isSubProcess ifTrue: [ self captureCompensationDataSnapshot ].
	completed := true.
	activityExecution multiInstanceActivityExecutionDidComplete: self.
	^ self
]


{ #category : 'lifecycle' }
CPMultiInstanceActivityExecution >> isCancelled [
	^ cancelled
]

{ #category : 'lifecycle' }
CPMultiInstanceActivityExecution >> isActive [
	^ completed not and: [ cancelled not ]
]

{ #category : 'lifecycle' }
CPMultiInstanceActivityExecution >> cancel [
	self isActive ifFalse: [ self error: 'Only an active Multi-Instance Activity instance can be cancelled.' ].
	subScope ifNotNil: [ subScope terminateRemainingWork ].
	(messageSubscription notNil and: [ messageSubscription isWaiting ]) ifTrue: [
		messageSubscription cancel ].
	cancelled := true.
	^ self
]


{ #category : 'data - snapshot' }
CPMultiInstanceActivityExecution >> captureCompensationDataSnapshot [
	subScope ifNil: [
		self error: 'A Multi-Instance SubProcess instance requires its execution scope before completion.' ].
	activityItemValuesSnapshot ifNotNil: [
		self error: 'A Multi-Instance SubProcess instance completion snapshot can only be captured once.' ].
	activityItemValuesSnapshot := itemValues copy.
	scopeItemValuesSnapshot := subScope itemValuesSnapshot.
	^ self
]

{ #category : 'data - snapshot' }
CPMultiInstanceActivityExecution >> restoreCompensationDataSnapshot [
	activityItemValuesSnapshot ifNil: [
		self error: 'A Multi-Instance SubProcess instance requires completion snapshot data for compensation.' ].
	itemValues := activityItemValuesSnapshot copy.
	subScope restoreItemValuesFromSnapshot: scopeItemValuesSnapshot.
	^ self
]

{ #category : 'multi-instance - runtime attributes' }
CPMultiInstanceActivityExecution >> loopCounter [
	^ index
]


{ #category : 'multi-instance - events' }
CPMultiInstanceActivityExecution >> thrownOccurrences [
	^ thrownOccurrences
]

{ #category : 'multi-instance - events' }
CPMultiInstanceActivityExecution >> recordThrownOccurrence: anOccurrence [
	thrownOccurrences add: anOccurrence.
	^ anOccurrence
]


{ #category : 'messages' }
CPMultiInstanceActivityExecution >> messageDispatch [ ^ messageDispatch ]

{ #category : 'messages' }
CPMultiInstanceActivityExecution >> prepareMessageDispatch [
	| definition specification loop inputs input |
	self isActive ifFalse: [ self error: 'Only an active Multi-Instance Send Task instance can prepare a Message dispatch.' ].
	messageDispatch ifNotNil: [ self error: 'A Multi-Instance Send Task instance can prepare only one Message dispatch.' ].
	definition := activityExecution definition.
	definition messageRef ifNil: [ self error: 'A Send Task requires a Message.' ].
	messageDispatch := CPMessageDispatch new
		message: definition messageRef;
		activityExecution: self;
		yourself.
	specification := definition ioSpecification.
	specification ifNil: [ ^ messageDispatch ].
	loop := definition loopCharacteristics.
	inputs := specification dataInputs select: [ :each |
		loop loopDataInputRef ~~ each and: [ self ownsItemValueFor: each ] ].
	inputs ifEmpty: [ ^ messageDispatch ].
	inputs size = 1 ifFalse: [
		self error: 'A Multi-Instance Send Task Message input requires at most one per-instance Data Input.' ].
	input := inputs first.
	(self hasItemValueFor: input) ifFalse: [
		self error: 'The Multi-Instance Send Task Data Input is unavailable for the Message dispatch.' ].
	messageDispatch payload: (self itemValueFor: input).
	^ messageDispatch
]


{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> userTaskWorkItem [
    ^ userTaskWorkItem
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> userTaskWorkItem: aWorkItem [
    userTaskWorkItem ifNotNil: [ self error: 'A Multi-Instance User Task instance can have only one work item.' ].
    userTaskWorkItem := aWorkItem
]


{ #category : 'user task - assignment' }
CPMultiInstanceActivityExecution >> userTaskActualOwner [
    userTaskWorkItem ifNil: [ ^ nil ].
    ^ userTaskWorkItem actualOwner
]

{ #category : 'user task - assignment' }
CPMultiInstanceActivityExecution >> claimUserTaskBy: anOwnerIdentifier [
    userTaskWorkItem ifNil: [ self error: 'The Multi-Instance User Task instance has no distributed work item.' ].
    ^ userTaskWorkItem claimBy: anOwnerIdentifier
]

{ #category : 'user task - assignment' }
CPMultiInstanceActivityExecution >> userTaskPriority [
    userTaskWorkItem ifNil: [ ^ nil ].
    ^ userTaskWorkItem taskPriority
]

{ #category : 'user task - assignment' }
CPMultiInstanceActivityExecution >> userTaskPriority: anInteger [
    userTaskWorkItem ifNil: [ self error: 'The Multi-Instance User Task instance has no distributed work item.' ].
    ^ userTaskWorkItem taskPriority: anInteger
]


{ #category : 'assignment' }
CPMultiInstanceActivityExecution >> manualTaskResourceAssignments [
	^ manualTaskResourceAssignments ifNil: [ #() ]
]

{ #category : 'assignment' }
CPMultiInstanceActivityExecution >> manualTaskResourceAssignments: aCollection [
	manualTaskResourceAssignments ifNotNil: [
		self error: 'A Multi-Instance Manual Task instance can resolve its resource assignments only once.' ].
	manualTaskResourceAssignments := aCollection asOrderedCollection.
	^ manualTaskResourceAssignments
]

{ #category : 'work items' }
CPMultiInstanceActivityExecution >> completeUserTaskWorkInScope: anExecutionScope [
    ^ anExecutionScope completeMultiInstanceUserTaskExecution: self
]

{ #category : 'external work' }
CPMultiInstanceActivityExecution >> completeServiceInvocationWithOccurrence: anOccurrence inScope: anExecutionScope [
	^ anExecutionScope completeMultiInstanceServiceTaskExecution: self withResultOccurrence: anOccurrence
]

{ #category : 'external work' }
CPMultiInstanceActivityExecution >> faultServiceInvocationWithOccurrence: anOccurrence inScope: anExecutionScope [
	^ anExecutionScope faultMultiInstanceServiceTaskExecution: self withErrorOccurrence: anOccurrence
]
