Class {
	#name : 'CPStandardLoopIterationExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'activityExecution',
		'index',
		'active',
		'completed',
		'terminated',
		'messageDispatch',
		'messageSubscription',
		'receivedOccurrence',
		'externalInvocation',
		'userTaskWorkItem',
		'manualTaskResourceAssignments',
		'subScope'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPStandardLoopIterationExecution >> initialize [
	super initialize.
	active := false.
	completed := false.
	terminated := false
]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> activityExecution [ ^ activityExecution ]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> activityExecution: anActivityExecution [ activityExecution := anActivityExecution ]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> scope [ ^ activityExecution scope ]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> subScope [ ^ subScope ]

{ #category : 'building' }
CPStandardLoopIterationExecution >> createSubScopeFor: aScopeDefinition [
	subScope ifNotNil: [ self error: 'A Standard Loop iteration can own only one execution scope.' ].
	^ CPExecutionScope for: aScopeDefinition ownedBy: self
]

{ #category : 'building' }
CPStandardLoopIterationExecution >> attachSubScope: anExecutionScope [
	subScope ifNotNil: [ self error: 'A Standard Loop iteration already owns an execution scope.' ].
	anExecutionScope owningActivity ifNotNil: [ self error: 'The execution scope is already owned by an Activity execution.' ].
	self scope ifNil: [ self error: 'The Standard Loop iteration must belong to an Activity execution scope before it can own a child scope.' ].
	anExecutionScope owningActivity: self.
	self scope addChildScope: anExecutionScope.
	subScope := anExecutionScope.
	^ anExecutionScope
]

{ #category : 'data' }
CPStandardLoopIterationExecution >> ownsItemValueFor: anItemAwareElement [
	^ activityExecution ownsItemValueFor: anItemAwareElement
]

{ #category : 'data' }
CPStandardLoopIterationExecution >> hasItemValueFor: anItemAwareElement [
	^ activityExecution hasItemValueFor: anItemAwareElement
]

{ #category : 'data' }
CPStandardLoopIterationExecution >> itemValueFor: anItemAwareElement [
	^ activityExecution itemValueFor: anItemAwareElement
]

{ #category : 'data' }
CPStandardLoopIterationExecution >> itemValueFor: anItemAwareElement put: aValue [
	^ activityExecution itemValueFor: anItemAwareElement put: aValue
]

{ #category : 'data - provenance' }
CPStandardLoopIterationExecution >> itemValueProducerFor: anItemAwareElement [
	^ activityExecution itemValueProducerFor: anItemAwareElement
]

{ #category : 'data - provenance' }
CPStandardLoopIterationExecution >> itemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution [
	^ activityExecution itemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution
]

{ #category : 'sub-process' }
CPStandardLoopIterationExecution >> subProcessScopeDidComplete: anExecutionScope [
	anExecutionScope == subScope ifFalse: [ self error: 'The completed Sub-Process scope does not belong to this Standard Loop iteration.' ].
	activityExecution isActive ifFalse: [ self error: 'Only an iteration of an Active Standard Loop Activity can complete its Sub-Process scope.' ].
	self isActive ifFalse: [ self error: 'Only an Active Standard Loop iteration can complete its Sub-Process scope.' ].
	^ activityExecution scope completeStandardLoopIteration: self of: activityExecution
]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> index [ ^ index ]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> index: anInteger [ index := anInteger ]

{ #category : 'standard loop - runtime attributes' }
CPStandardLoopIterationExecution >> loopCounter [
	^ index
]

{ #category : 'testing' }
CPStandardLoopIterationExecution >> isActive [ ^ active ]

{ #category : 'testing' }
CPStandardLoopIterationExecution >> isCompleted [ ^ completed ]

{ #category : 'testing' }
CPStandardLoopIterationExecution >> isTerminated [ ^ terminated ]

{ #category : 'lifecycle' }
CPStandardLoopIterationExecution >> activate [
	(active or: [ completed or: [ terminated ] ]) ifTrue: [ self error: 'A Standard Loop iteration can be activated only once.' ].
	active := true
]

{ #category : 'lifecycle' }
CPStandardLoopIterationExecution >> complete [
	active ifFalse: [ self error: 'Only an Active Standard Loop iteration can complete.' ].
	active := false.
	completed := true
]

{ #category : 'lifecycle' }
CPStandardLoopIterationExecution >> terminate [
	self isActive ifFalse: [ self error: 'Only an Active Standard Loop iteration can be terminated.' ].
	subScope ifNotNil: [ subScope terminateRemainingWork ].
	(messageSubscription notNil and: [ messageSubscription isWaiting ]) ifTrue: [
		messageSubscription cancel ].
	active := false.
	terminated := true.
	^ self
]


{ #category : 'messages' }
CPStandardLoopIterationExecution >> messageDispatch [ ^ messageDispatch ]

{ #category : 'messages' }
CPStandardLoopIterationExecution >> prepareMessageDispatch [
	| outerExecution inputs input |
	self isActive ifFalse: [ self error: 'Only an Active Standard Loop Send Task iteration can prepare a Message dispatch.' ].
	messageDispatch ifNotNil: [ self error: 'A Standard Loop Send Task iteration can prepare only one Message dispatch.' ].
	outerExecution := self activityExecution.
	outerExecution definition messageRef ifNil: [ self error: 'A Send Task requires a Message.' ].
	messageDispatch := CPMessageDispatch new
		message: outerExecution definition messageRef;
		activityExecution: self;
		yourself.
	outerExecution definition ioSpecification ifNil: [ ^ messageDispatch ].
	inputs := outerExecution definition ioSpecification dataInputs.
	inputs ifEmpty: [ ^ messageDispatch ].
	inputs size = 1 ifFalse: [ self error: 'A Send Task Message input requires at most one Data Input.' ].
	input := inputs first.
	(outerExecution hasItemValueFor: input) ifFalse: [ self error: 'The Send Task Data Input is unavailable for the Message dispatch.' ].
	messageDispatch payload: (outerExecution itemValueFor: input).
	^ messageDispatch
]

{ #category : 'messages' }
CPStandardLoopIterationExecution >> messageSubscription [ ^ messageSubscription ]

{ #category : 'messages' }
CPStandardLoopIterationExecution >> messageSubscription: aSubscription [
	messageSubscription ifNotNil: [ self error: 'A Standard Loop Receive Task iteration can have only one Message subscription.' ].
	messageSubscription := aSubscription
]

{ #category : 'messages' }
CPStandardLoopIterationExecution >> receivedOccurrence [ ^ receivedOccurrence ]

{ #category : 'messages' }
CPStandardLoopIterationExecution >> isWaitingForMessage [
	^ self isActive and: [ receivedOccurrence isNil and: [ messageSubscription notNil and: [ messageSubscription isWaiting ] ] ]
]

{ #category : 'messages' }
CPStandardLoopIterationExecution >> acceptMessageSubscription: aSubscription occurrence: anOccurrence [
	messageSubscription == aSubscription ifFalse: [ self error: 'The Message subscription does not belong to this Standard Loop Receive Task iteration.' ].
	^ self activityExecution scope triggerStandardLoopReceiveTaskIteration: self with: anOccurrence
]

{ #category : 'messages' }
CPStandardLoopIterationExecution >> acceptReceivedOccurrence: anOccurrence [
	self isWaitingForMessage ifFalse: [ self error: 'Only a waiting Standard Loop Receive Task iteration can accept a message occurrence.' ].
	receivedOccurrence := anOccurrence.
	^ anOccurrence
]


{ #category : 'external work' }
CPStandardLoopIterationExecution >> externalInvocation [
	^ externalInvocation
]

{ #category : 'external work' }
CPStandardLoopIterationExecution >> prepareExternalInvocationIdentifiedBy: anIdentifier [
	| outerExecution implementation inputs input |
	self isActive ifFalse: [ self error: 'Only an Active Standard Loop Service Task iteration can prepare external work.' ].
	externalInvocation ifNotNil: [ self error: 'A Standard Loop Service Task iteration can prepare external work only once.' ].
	outerExecution := self activityExecution.
	implementation := outerExecution resolvedImplementation.
	implementation ifNil: [ self error: 'A Standard Loop Service Task requires a resolved implementation before preparing external work.' ].
	externalInvocation := CPExternalInvocation new
		invocationIdentifier: anIdentifier;
		activityExecution: self;
		implementation: implementation;
		yourself.
	outerExecution definition ioSpecification ifNil: [ ^ externalInvocation ].
	inputs := outerExecution definition ioSpecification dataInputs.
	inputs ifEmpty: [ ^ externalInvocation ].
	inputs size = 1 ifFalse: [
		self error: 'A Standard Loop Service Task Operation input requires exactly one Data Input.' ].
	input := inputs first.
	(outerExecution hasItemValueFor: input) ifFalse: [
		self error: 'The Standard Loop Service Task Data Input is unavailable for external invocation.' ].
	externalInvocation inputValue: (outerExecution itemValueFor: input).
	^ externalInvocation
]


{ #category : 'user task' }
CPStandardLoopIterationExecution >> userTaskWorkItem [
	^ userTaskWorkItem
]

{ #category : 'user task' }
CPStandardLoopIterationExecution >> userTaskWorkItem: aWorkItem [
	userTaskWorkItem ifNotNil: [ self error: 'A Standard Loop User Task iteration can have only one work item.' ].
	userTaskWorkItem := aWorkItem
]

{ #category : 'manual task' }
CPStandardLoopIterationExecution >> manualTaskResourceAssignments [
	^ manualTaskResourceAssignments ifNil: [ #() ]
]

{ #category : 'manual task' }
CPStandardLoopIterationExecution >> manualTaskResourceAssignments: aCollection [
	manualTaskResourceAssignments ifNotNil: [
		self error: 'A Standard Loop Manual Task iteration can resolve its resource assignments only once.' ].
	manualTaskResourceAssignments := aCollection asOrderedCollection.
	^ manualTaskResourceAssignments
]
