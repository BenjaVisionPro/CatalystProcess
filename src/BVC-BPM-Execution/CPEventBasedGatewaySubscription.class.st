Class {
	#name : 'CPEventBasedGatewaySubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'sequenceFlow', 'target', 'gatewayExecution', 'eventDefinition', 'state', 'occurrence', 'armedAt', 'dueTime', 'dispatchPending', 'dispatchOccurrenceIdentifier' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPEventBasedGatewaySubscription >> initialize [
	super initialize.
	state := CPEventBasedGatewaySubscriptionWaitingState new.
	dispatchPending := false
]

{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> sequenceFlow [ ^ sequenceFlow ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> sequenceFlow: aSequenceFlow [ sequenceFlow := aSequenceFlow ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> target [ ^ target ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> target: aFlowNode [ target := aFlowNode ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> gatewayExecution [ ^ gatewayExecution ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> gatewayExecution: anExecution [ gatewayExecution := anExecution ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> eventDefinition [ ^ eventDefinition ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> eventDefinition: aDefinition [ eventDefinition := aDefinition. dueTime := nil ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> state [ ^ state ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> occurrence [ ^ occurrence ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> executionScope [ ^ gatewayExecution scope ]

{ #category : 'testing' }
CPEventBasedGatewaySubscription >> isWaiting [ ^ state isWaiting and: [ dispatchPending not ] ]
{ #category : 'testing' }
CPEventBasedGatewaySubscription >> isTriggered [ ^ state isTriggered ]
{ #category : 'testing' }
CPEventBasedGatewaySubscription >> isWithdrawn [ ^ state isWithdrawn ]
{ #category : 'testing' }
CPEventBasedGatewaySubscription >> isCancelled [ ^ self isWithdrawn ]
{ #category : 'testing' }
CPEventBasedGatewaySubscription >> isDispatchPending [ ^ dispatchPending ]
{ #category : 'testing' }
CPEventBasedGatewaySubscription >> canReceiveOccurrence [
	^ state isWaiting and: [ self isWaiting or: [ self isDispatchPending ] ]
]

{ #category : 'event type' }
CPEventBasedGatewaySubscription >> isMessageSubscription [ ^ eventDefinition isMessageEventDefinition ]
{ #category : 'event type' }
CPEventBasedGatewaySubscription >> isSignalSubscription [ ^ eventDefinition isSignalEventDefinition ]
{ #category : 'event type' }
CPEventBasedGatewaySubscription >> isTimerSubscription [ ^ eventDefinition isTimerEventDefinition ]
{ #category : 'event type' }
CPEventBasedGatewaySubscription >> isConditionalSubscription [ ^ eventDefinition isConditionalEventDefinition ]

{ #category : 'event type' }
CPEventBasedGatewaySubscription >> message [ ^ eventDefinition messageRef ]
{ #category : 'event type' }
CPEventBasedGatewaySubscription >> signal [ ^ eventDefinition signalRef ]
{ #category : 'event type' }
CPEventBasedGatewaySubscription >> timerDefinition [ ^ eventDefinition ]
{ #category : 'event type' }
CPEventBasedGatewaySubscription >> condition [ ^ eventDefinition condition ]

{ #category : 'occurrences' }
CPEventBasedGatewaySubscription >> triggerWith: anOccurrence [
	self canReceiveOccurrence ifFalse: [ self error: 'Only a waiting Event-Based Gateway subscription can be triggered.' ].
	occurrence := anOccurrence.
	dispatchPending := false.
	dispatchOccurrenceIdentifier := nil.
	state := CPEventBasedGatewaySubscriptionTriggeredState new.
	^ anOccurrence
]

{ #category : 'occurrences' }
CPEventBasedGatewaySubscription >> deliverOccurrence: anOccurrence [
	self validateOccurrenceForDelivery: anOccurrence.
	^ self executionScope
		triggerEventBasedGatewayExecution: gatewayExecution
		subscription: self
		with: anOccurrence
]

{ #category : 'occurrences' }
CPEventBasedGatewaySubscription >> deliverAcceptedOccurrence: anOccurrence [
	self validateOccurrenceForDelivery: anOccurrence.
	^ self executionScope
		triggerEventBasedGatewayExecutionWithAcceptedOccurrence: gatewayExecution
		subscription: self
		with: anOccurrence
]

{ #category : 'occurrences' }
CPEventBasedGatewaySubscription >> validateOccurrenceForDelivery: anOccurrence [
	self canReceiveOccurrence ifFalse: [ self error: 'Only a waiting or dispatch-pending Event-Based Gateway subscription can receive an occurrence.' ].
	self isDispatchPending ifTrue: [
		anOccurrence occurrenceIdentifier = dispatchOccurrenceIdentifier ifFalse: [
			self error: 'The occurrence identifier does not match the pending Timer dispatch.' ] ].
	self isMessageSubscription ifTrue: [
		anOccurrence definition == self message ifFalse: [ self error: 'The occurrence does not match this Message gateway alternative.' ].
		^ self ].
	self isSignalSubscription ifTrue: [
		anOccurrence definition == self signal ifFalse: [ self error: 'The occurrence does not match this Signal gateway alternative.' ].
		^ self ].
	self isTimerSubscription ifTrue: [
		anOccurrence definition == self timerDefinition ifFalse: [ self error: 'The occurrence does not match this Timer gateway alternative.' ].
		^ self ].
	self error: 'This Event-Based Gateway alternative does not accept an occurrence.'
]

{ #category : 'conditional events' }
CPEventBasedGatewaySubscription >> reevaluateInScope: anExecutionScope [
	self isConditionalSubscription ifFalse: [ self error: 'Only a Conditional gateway alternative can be reevaluated.' ].
	self isWaiting ifFalse: [ self error: 'Only a waiting Conditional gateway alternative can be reevaluated.' ].
	(anExecutionScope environment evaluateExpression: self condition in: anExecutionScope) ifFalse: [ ^ false ].
	anExecutionScope triggerConditionalEventBasedGatewaySubscription: self.
	^ true
]

{ #category : 'lifecycle' }
CPEventBasedGatewaySubscription >> withdraw [
	self canReceiveOccurrence ifFalse: [ self error: 'Only a waiting Event-Based Gateway subscription can be withdrawn.' ].
	dispatchPending := false.
	dispatchOccurrenceIdentifier := nil.
	state := CPEventBasedGatewaySubscriptionWithdrawnState new.
	^ self
]
{ #category : 'lifecycle' }
CPEventBasedGatewaySubscription >> cancel [ ^ self withdraw ]

{ #category : 'timing' }
CPEventBasedGatewaySubscription >> armedAt [ ^ armedAt ]
{ #category : 'timing' }
CPEventBasedGatewaySubscription >> armedAt: aTime [ armedAt := aTime. dueTime := nil ]
{ #category : 'timing' }
CPEventBasedGatewaySubscription >> dueAt [
	self isTimerSubscription ifFalse: [ self error: 'Only a Timer gateway alternative has a due time.' ].
	armedAt ifNil: [ self error: 'A Timer gateway alternative must have an arming time.' ].
	dueTime ifNil: [
		dueTime := self executionScope environment
			timerDueAtFor: self timerDefinition
			armedAt: armedAt
			in: self executionScope.
		dueTime ifNil: [ self error: 'Timer due-time evaluation must produce a due time.' ] ].
	^ dueTime
]
{ #category : 'timing' }
CPEventBasedGatewaySubscription >> isDueAt: aTime [
	self isWaiting ifFalse: [ ^ false ].
	^ self dueAt <= aTime
]
{ #category : 'timing' }
CPEventBasedGatewaySubscription >> dispatchOccurrenceIdentifier [ ^ dispatchOccurrenceIdentifier ]
{ #category : 'timing' }
CPEventBasedGatewaySubscription >> markDispatchPendingWithOccurrenceIdentifier: anOccurrenceIdentifier [
	self isTimerSubscription ifFalse: [ self error: 'Only a Timer gateway alternative can be dispatched by the Timer service.' ].
	self isWaiting ifFalse: [ self error: 'Only a waiting Timer gateway alternative can be marked dispatch pending.' ].
	anOccurrenceIdentifier ifNil: [ self error: 'A Timer dispatch requires an occurrence identifier.' ].
	dispatchPending := true.
	dispatchOccurrenceIdentifier := anOccurrenceIdentifier.
	^ self
]


{ #category : 'occurrences' }
CPEventBasedGatewaySubscription >> triggerWithoutOccurrence [
	self isWaiting ifFalse: [ self error: 'Only a waiting Event-Based Gateway subscription can be triggered.' ].
	state := CPEventBasedGatewaySubscriptionTriggeredState new.
	^ self
]


{ #category : 'conditional events' }
CPEventBasedGatewaySubscription >> triggerInScope: anExecutionScope [
	^ anExecutionScope triggerConditionalEventBasedGatewaySubscription: self
]

{ #category : 'continuation' }
CPEventBasedGatewaySubscription >> continueWithOccurrence: anOccurrence inScope: anExecutionScope [
	| eventExecution |
	eventExecution := CPIntermediateCatchEventExecution new
		definition: target;
		scope: anExecutionScope;
		yourself.
	anExecutionScope eventExecutions add: eventExecution.
	eventExecution triggerWithAcceptedOccurrence: anOccurrence.
	^ eventExecution
]

{ #category : 'continuation' }
CPEventBasedGatewaySubscription >> continueConditionalInScope: anExecutionScope [
	| eventExecution |
	eventExecution := CPIntermediateCatchEventExecution new
		definition: target;
		scope: anExecutionScope;
		yourself.
	anExecutionScope eventExecutions add: eventExecution.
	eventExecution triggerWithoutOccurrence.
	^ eventExecution
]
