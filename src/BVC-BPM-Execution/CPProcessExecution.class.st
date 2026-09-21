Class {
	#name : 'CPProcessExecution',
	#superclass : 'CPExecutionScope',
	#instVars : [
		'deployment',
		'tenant',
		'startedBy',
		'environment',
		'started',
		'completed',
		'nextCompensationCompletionSequence',
		'executionIdentifier'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'instance creation' }
CPProcessExecution class >> for: aProcess environment: anExecutionEnvironment [
	^ self new
		definition: aProcess;
		environment: anExecutionEnvironment;
		yourself
]

{ #category : 'accessing' }
CPProcessExecution >> executionIdentifier [ ^ executionIdentifier ]

{ #category : 'accessing' }
CPProcessExecution >> deployment [ ^ deployment ]
{ #category : 'accessing' }
CPProcessExecution >> deployment: anObject [ deployment := anObject ]
{ #category : 'accessing' }
CPProcessExecution >> tenant [ ^ tenant ]
{ #category : 'accessing' }
CPProcessExecution >> tenant: anObject [ tenant := anObject ]
{ #category : 'accessing' }
CPProcessExecution >> startedBy [ ^ startedBy ]
{ #category : 'accessing' }
CPProcessExecution >> startedBy: anObject [ startedBy := anObject ]

{ #category : 'accessing' }
CPProcessExecution >> environment [ ^ environment ]
{ #category : 'accessing' }
CPProcessExecution >> environment: anExecutionEnvironment [ environment := anExecutionEnvironment ]


{ #category : 'initialization' }
CPProcessExecution >> initialize [
	super initialize.
	executionIdentifier := UUID new asString.
	started := false.
	completed := false.
	nextCompensationCompletionSequence := 1
]

{ #category : 'testing' }
CPProcessExecution >> isStarted [
	^ started
]

{ #category : 'lifecycle' }
CPProcessExecution >> start [
	| startEvents executions |
	started ifTrue: [ self error: 'A Process execution can only be started once.' ].
	startEvents := self definition flowElements select: [ :each |
		each isStartEvent and: [ each eventDefinitions isEmpty ] ].
	startEvents ifEmpty: [ self error: 'Process instantiation requires at least one None Start Event.' ].
	started := true.
	executions := startEvents collect: [ :each | self executeStartEvent: each occurrence: nil ].
	self armMessageEventSubProcesses.
	self armSignalEventSubProcesses.
	self armTimerEventSubProcesses.
	self armConditionalEventSubProcesses.
	^ executions
]


{ #category : 'testing' }
CPProcessExecution >> isCompleted [
	^ completed
]

{ #category : 'lifecycle' }
CPProcessExecution >> canComplete [
	started ifFalse: [ ^ false ].
	completed ifTrue: [ ^ false ].
	(self flowActivations anySatisfy: [ :each | each isAvailable ]) ifTrue: [ ^ false ].
	(self activityExecutions anySatisfy: [ :each | each isFinal not ]) ifTrue: [ ^ false ].
	self allWaitingBlockingMessageSubscriptions ifNotEmpty: [ ^ false ].
	self allWaitingTimerSubscriptions ifNotEmpty: [ ^ false ].
	self allWaitingSignalSubscriptions ifNotEmpty: [ ^ false ].
	self allWaitingConditionalSubscriptions ifNotEmpty: [ ^ false ].
	self allWaitingEventBasedGatewaySubscriptions ifNotEmpty: [ ^ false ].
	self hasPendingEventWork ifTrue: [ ^ false ].
	^ true
]

{ #category : 'lifecycle' }
CPProcessExecution >> complete [
	self canComplete ifFalse: [
		self error: 'A Process execution cannot complete while executable or waiting work remains.' ].
	self cancelMessageEventSubProcessSubscriptions.
	self cancelSignalEventSubProcessSubscriptions.
	self cancelTimerEventSubProcessSubscriptions.
	self cancelConditionalEventSubProcessSubscriptions.
	completed := true.
	^ self
]

{ #category : 'lifecycle' }
CPProcessExecution >> finishTermination [
	self complete.
	^ self
]


{ #category : 'occurrences' }
CPProcessExecution >> processExecution [
	^ self
]

{ #category : 'lifecycle' }
CPProcessExecution >> startWithOccurrence: anOccurrence [
	| matchingStartEvents execution |
	started ifTrue: [ self error: 'A Process execution can only be started once.' ].
	anOccurrence ifNil: [ self error: 'Triggered Process instantiation requires an occurrence.' ].
	matchingStartEvents := self definition flowElements select: [ :each |
		each isStartEvent and: [ each matchesInstantiationOccurrence: anOccurrence ] ].
	matchingStartEvents ifEmpty: [
		self error: 'No Start Event matches the instantiating occurrence.' ].
	matchingStartEvents size > 1 ifTrue: [
		self error: 'The instantiating occurrence matches more than one Start Event.' ].
	started := true.
	execution := self executeStartEvent: matchingStartEvents first occurrence: anOccurrence.
	self armMessageEventSubProcesses.
	self armSignalEventSubProcesses.
	self armTimerEventSubProcesses.
	self armConditionalEventSubProcesses.
	^ execution
]

{ #category : 'lifecycle' }
CPProcessExecution >> startAtParallelMultipleStartEvent: aStartEvent occurrences: occurrences [
	| execution |
	started ifTrue: [ self error: 'A Process execution can only be started once.' ].
	aStartEvent isParallelMultipleStartEvent ifFalse: [ self error: 'Parallel Multiple Process start requires a Parallel Multiple Start Event.' ].
	occurrences size = aStartEvent eventDefinitions size ifFalse: [ self error: 'Parallel Multiple Process start requires one occurrence for each Event Definition.' ].
	aStartEvent eventDefinitions withIndexDo: [ :definition :index |
		(aStartEvent eventDefinitionMatchingInstantiationOccurrence: (occurrences at: index)) == definition ifFalse: [
			self error: 'Parallel Multiple Process start occurrences must correspond to the Start Event Definitions in order.' ] ].
	started := true.
	execution := self executeParallelMultipleStartEvent: aStartEvent occurrences: occurrences.
	self armMessageEventSubProcesses.
	self armSignalEventSubProcesses.
	self armTimerEventSubProcesses.
	self armConditionalEventSubProcesses.
	^ execution
]

{ #category : 'lifecycle' }
CPProcessExecution >> startWhenConditionSatisfied [
	| matchingStartEvents execution |
	started ifTrue: [ self error: 'A Process execution can only be started once.' ].
	matchingStartEvents := self definition flowElements select: [ :each |
		each isStartEvent and: [ each conditionAllowsInstantiationIn: self ] ].
	matchingStartEvents ifEmpty: [
		self error: 'No Conditional Start Event condition is satisfied.' ].
	matchingStartEvents size > 1 ifTrue: [
		self error: 'More than one Conditional Start Event condition is satisfied.' ].
	started := true.
	execution := self executeStartEvent: matchingStartEvents first occurrence: nil.
	self armMessageEventSubProcesses.
	self armSignalEventSubProcesses.
	self armTimerEventSubProcesses.
	self armConditionalEventSubProcesses.
	^ execution
]


{ #category : 'signals' }
CPProcessExecution >> deliverSignalOccurrence: anOccurrence [
	| matches |
	anOccurrence ifNil: [ self error: 'Signal delivery requires an occurrence.' ].
	matches := self allWaitingDeliverableSignalSubscriptionsFor: anOccurrence definition.
	matches isEmpty ifTrue: [
		self error: 'No waiting Signal subscription matches this occurrence.' ].
	self acceptOccurrence: anOccurrence.
	matches do: [ :each | each deliverAcceptedOccurrence: anOccurrence ].
	^ matches
]


{ #category : 'events - timer' }
CPProcessExecution >> waitingDeliverableTimerSubscriptionIdentifiedBy: aSubscriptionIdentifier [
	| matches |
	aSubscriptionIdentifier ifNil: [
		self error: 'A Timer subscription identifier is required.' ].
	matches := self allWaitingDeliverableTimerSubscriptions select: [ :each |
		each identifier = aSubscriptionIdentifier ].
	matches isEmpty ifTrue: [
		self error: 'No waiting Timer subscription has the requested identifier.' ].
	matches size = 1 ifFalse: [
		self error: 'More than one waiting Timer subscription has the requested identifier.' ].
	^ matches first
]


{ #category : 'events - timer' }
CPProcessExecution >> deliverableTimerSubscriptionIdentifiedByOrNil: aSubscriptionIdentifier [
	| matches |
	aSubscriptionIdentifier ifNil: [
		self error: 'A Timer subscription identifier is required.' ].
	matches := (self allWaitingDeliverableTimerSubscriptions , self allDispatchPendingTimerSubscriptions)
		select: [ :each | each identifier = aSubscriptionIdentifier ].
	matches isEmpty ifTrue: [ ^ nil ].
	matches size = 1 ifFalse: [
		self error: 'More than one deliverable Timer subscription has the requested identifier.' ].
	^ matches first
]

{ #category : 'events - timer' }
CPProcessExecution >> deliverableTimerSubscriptionIdentifiedBy: aSubscriptionIdentifier [
	^ (self deliverableTimerSubscriptionIdentifiedByOrNil: aSubscriptionIdentifier)
		ifNil: [ self error: 'No deliverable Timer subscription has the requested identifier.' ]
]

{ #category : 'events - timer' }
CPProcessExecution >> markTimerSubscriptionDispatchPending: aTimerSubscription occurrenceIdentifier: anOccurrenceIdentifier [
	(self allWaitingDeliverableTimerSubscriptions identityIncludes: aTimerSubscription) ifFalse: [
		self error: 'Only a live waiting Timer subscription can be marked dispatch pending.' ].
	^ aTimerSubscription markDispatchPendingWithOccurrenceIdentifier: anOccurrenceIdentifier
]

{ #category : 'events - timer' }
CPProcessExecution >> deliverTimerOccurrence: anOccurrence toSubscriptionIdentifiedBy: aSubscriptionIdentifier [
	| subscription |
	anOccurrence ifNil: [ self error: 'Timer delivery requires an occurrence.' ].
	subscription := self deliverableTimerSubscriptionIdentifiedBy: aSubscriptionIdentifier.
	anOccurrence definition == subscription timerDefinition ifFalse: [
		self error: 'The occurrence does not match the requested Timer subscription.' ].
	^ subscription deliverOccurrence: anOccurrence
]


{ #category : 'activities - compensation' }
CPProcessExecution >> nextCompensationCompletionSequence [
	| sequence |
	sequence := nextCompensationCompletionSequence.
	nextCompensationCompletionSequence := nextCompensationCompletionSequence + 1.
	^ sequence
]

{ #category : 'work items' }
CPProcessExecution >> pendingUserTaskWorkItemIdentifiedBy: aWorkItemIdentifier [
    | matches |
    aWorkItemIdentifier ifNil: [ self error: 'A User Task work item identifier is required.' ].
    matches := self allPendingUserTaskWorkItems select: [ :each |
        each identifier = aWorkItemIdentifier ].
    matches isEmpty ifTrue: [ self error: 'No pending User Task work item has the requested identifier.' ].
    matches size = 1 ifFalse: [ self error: 'More than one pending User Task work item has the requested identifier.' ].
    ^ matches first
]

{ #category : 'external work' }
CPProcessExecution >> pendingExternalInvocationIdentifiedBy: anInvocationIdentifier [
	| matches |
	anInvocationIdentifier ifNil: [
		self error: 'An external invocation identifier is required.' ].
	matches := self allPendingExternalInvocations select: [ :each |
		each invocationIdentifier = anInvocationIdentifier ].
	matches isEmpty ifTrue: [
		self error: 'No pending external invocation has the requested identifier.' ].
	matches size = 1 ifFalse: [
		self error: 'More than one pending external invocation has the requested identifier.' ].
	^ matches first
]

{ #category : 'lifecycle' }
CPProcessExecution >> terminate [
	started ifFalse: [ self error: 'Only a started Process execution can be terminated.' ].
	completed ifTrue: [ self error: 'A completed Process execution cannot be terminated.' ].
	self terminateRemainingWork.
	self finishTermination.
	^ self
]

{ #category : 'lifecycle' }
CPProcessExecution >> startAtInstantiatingReceiveTask: aReceiveTask occurrence: anOccurrence [
	| execution |
	started ifTrue: [ self error: 'A Process execution can only be started once.' ].
	aReceiveTask instantiate ifFalse: [ self error: 'Process instantiation requires an instantiating Receive Task.' ].
	aReceiveTask incoming isEmpty ifFalse: [ self error: 'An instantiating Receive Task must not have incoming Sequence Flows.' ].
	aReceiveTask messageRef ifNil: [ self error: 'An instantiating Receive Task requires a Message.' ].
	anOccurrence ifNil: [ self error: 'Receive Task instantiation requires an occurrence.' ].
	anOccurrence definition == aReceiveTask messageRef ifFalse: [ self error: 'The occurrence does not carry the Message awaited by this Receive Task.' ].
	started := true.
	self acceptOccurrence: anOccurrence.
	execution := self createReceiveTaskExecutionFor: aReceiveTask.
	(execution prepareForActivation) ifFalse: [ self error: 'The instantiating Receive Task does not have its required inputs available.' ].
	execution activate.
	execution acceptReceivedOccurrence: anOccurrence.
	execution populateSingleDataOutputFromOccurrence: anOccurrence.
	execution beginCompletion.
	execution complete.
	self produceOutgoingControlFor: execution.
	self armMessageEventSubProcesses.
	self armSignalEventSubProcesses.
	self armTimerEventSubProcesses.
	self armConditionalEventSubProcesses.
	^ execution
]


{ #category : 'lifecycle' }
CPProcessExecution >> startAtInstantiatingEventBasedGateway: aGateway via: aSequenceFlow occurrence: anOccurrence [
	| target continuation |
	started ifTrue: [ self error: 'A Process execution can only be started once.' ].
	aGateway instantiate ifFalse: [ self error: 'Process instantiation requires an instantiating Event-Based Gateway.' ].
	(aGateway outgoing includes: aSequenceFlow) ifFalse: [ self error: 'The Sequence Flow does not leave the instantiating Event-Based Gateway.' ].
	target := aSequenceFlow targetRef.
	(target isReceiveTask or: [ target isIntermediateEvent ]) ifFalse: [ self error: 'An instantiating Event-Based Gateway must target a Receive Task or Intermediate Catch Event.' ].
	anOccurrence ifNil: [ self error: 'Event-Based Gateway instantiation requires an occurrence.' ].
	started := true.
	self acceptOccurrence: anOccurrence.
	target isReceiveTask
		ifTrue: [ continuation := self completeEventBasedGatewayReceiveTask: target withAcceptedOccurrence: anOccurrence ]
		ifFalse: [ continuation := self continueInstantiatingEventBasedGatewayCatchEvent: target withAcceptedOccurrence: anOccurrence ].
	self armMessageEventSubProcesses.
	self armSignalEventSubProcesses.
	self armTimerEventSubProcesses.
	self armConditionalEventSubProcesses.
	^ continuation
]

{ #category : 'lifecycle' }
CPProcessExecution >> continueInstantiatingEventBasedGatewayCatchEvent: anEvent withAcceptedOccurrence: anOccurrence [
	| definition eventExecution |
	anEvent eventDefinitions ifEmpty: [ self error: 'An Event-Based Gateway Intermediate Catch Event requires at least one Event Definition.' ].
	definition := anEvent eventDefinitions
		detect: [ :each |
			each isMessageEventDefinition ifTrue: [ anOccurrence definition == each messageRef ] ifFalse: [
			each isSignalEventDefinition ifTrue: [ anOccurrence definition == each signalRef ] ifFalse: [
			each isTimerEventDefinition ifTrue: [ anOccurrence definition == each ] ifFalse: [
			each isConditionalEventDefinition ifTrue: [ anOccurrence definition == each ] ifFalse: [ false ] ] ] ] ]
		ifNone: [ self error: 'The occurrence does not match any Event Definition of this gateway alternative.' ].
	eventExecution := CPIntermediateCatchEventExecution new definition: anEvent; scope: self; yourself.
	self eventExecutions add: eventExecution.
	eventExecution triggerWithAcceptedOccurrence: anOccurrence.
	^ eventExecution
]
