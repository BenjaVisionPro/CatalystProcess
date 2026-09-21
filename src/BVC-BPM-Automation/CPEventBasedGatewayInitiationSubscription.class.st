Class {
	#name : 'CPEventBasedGatewayInitiationSubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'processDeployment', 'gateway', 'sequenceFlow', 'eventDefinition', 'armedAt', 'dueTime', 'dispatchPending', 'dispatchOccurrenceIdentifier', 'timerCompleted' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'initialization' }
CPEventBasedGatewayInitiationSubscription >> initialize [
	super initialize.
	dispatchPending := false.
	timerCompleted := false
]

{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> processDeployment [ ^ processDeployment ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> processDeployment: anObject [ processDeployment := anObject ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> gateway [ ^ gateway ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> gateway: anObject [ gateway := anObject ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> sequenceFlow [ ^ sequenceFlow ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> target [ ^ sequenceFlow targetRef ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> eventDefinition [ ^ eventDefinition ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> eventDefinition: anObject [ eventDefinition := anObject ]

{ #category : 'testing' }
CPEventBasedGatewayInitiationSubscription >> isMessageSubscription [ ^ eventDefinition isMessageEventDefinition ]
{ #category : 'testing' }
CPEventBasedGatewayInitiationSubscription >> isSignalSubscription [ ^ eventDefinition isSignalEventDefinition ]
{ #category : 'testing' }
CPEventBasedGatewayInitiationSubscription >> isTimerSubscription [ ^ eventDefinition isTimerEventDefinition ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> message [ ^ eventDefinition messageRef ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> signal [ ^ eventDefinition signalRef ]

{ #category : 'timing' }
CPEventBasedGatewayInitiationSubscription >> armedAt [ ^ armedAt ]

{ #category : 'timing' }
CPEventBasedGatewayInitiationSubscription >> armTimerAt: aTime [
	self isTimerSubscription ifFalse: [ self error: 'Only a Timer initiation subscription can be armed.' ].
	aTime ifNil: [ self error: 'A Timer initiation subscription requires an arming time.' ].
	armedAt := aTime.
	dueTime := nil.
	dispatchPending := false.
	dispatchOccurrenceIdentifier := nil.
	timerCompleted := false.
	^ self
]

{ #category : 'timing' }
CPEventBasedGatewayInitiationSubscription >> dueAtUsing: anExecutionEnvironment [
	self isTimerSubscription ifFalse: [ self error: 'Only a Timer initiation subscription has a due time.' ].
	armedAt ifNil: [ self error: 'A Timer initiation subscription must be armed before its due time can be evaluated.' ].
	dueTime ifNil: [
		dueTime := anExecutionEnvironment
			timerDueAtFor: eventDefinition
			armedAt: armedAt
			forProcessDeployment: processDeployment ].
	^ dueTime
]

{ #category : 'timing' }
CPEventBasedGatewayInitiationSubscription >> isWaitingTimer [
	^ self isTimerSubscription and: [ timerCompleted not and: [ dispatchPending not ] ]
]

{ #category : 'timing' }
CPEventBasedGatewayInitiationSubscription >> isDueAt: aTime using: anExecutionEnvironment [
	self isWaitingTimer ifFalse: [ ^ false ].
	^ (self dueAtUsing: anExecutionEnvironment) <= aTime
]

{ #category : 'timing' }
CPEventBasedGatewayInitiationSubscription >> markTimerDispatchPendingWithOccurrenceIdentifier: anOccurrenceIdentifier [
	self isWaitingTimer ifFalse: [ self error: 'Only a waiting Timer initiation subscription can be marked dispatch pending.' ].
	anOccurrenceIdentifier ifNil: [ self error: 'A Timer initiation dispatch requires an occurrence identifier.' ].
	dispatchPending := true.
	dispatchOccurrenceIdentifier := anOccurrenceIdentifier.
	^ self
]

{ #category : 'timing' }
CPEventBasedGatewayInitiationSubscription >> isTimerDispatchPending [ ^ dispatchPending ]

{ #category : 'timing' }
CPEventBasedGatewayInitiationSubscription >> dispatchOccurrenceIdentifier [ ^ dispatchOccurrenceIdentifier ]

{ #category : 'timing' }
CPEventBasedGatewayInitiationSubscription >> acceptTimerOccurrenceAt: aTime [
	dispatchPending ifFalse: [ self error: 'A Timer initiation occurrence can only complete a pending dispatch.' ].
	dispatchPending := false.
	dispatchOccurrenceIdentifier := nil.
	eventDefinition timeCycle
		ifNil: [ timerCompleted := true ]
		ifNotNil: [ self armTimerAt: aTime ].
	^ self
]

{ #category : 'matching' }
CPEventBasedGatewayInitiationSubscription >> matchesOccurrence: anOccurrence [
	processDeployment acceptsNewProcessExecutions ifFalse: [ ^ false ].
	self isMessageSubscription ifTrue: [ ^ anOccurrence definition == self message ].
	self isSignalSubscription ifTrue: [ ^ anOccurrence definition == self signal ].
	self isTimerSubscription ifTrue: [
		^ dispatchPending
			and: [ anOccurrence definition == eventDefinition
			and: [ anOccurrence occurrenceIdentifier = dispatchOccurrenceIdentifier ] ] ].
	^ false
]

{ #category : 'process initiation' }
CPEventBasedGatewayInitiationSubscription >> instantiateUsingService: aBpmService occurrence: anOccurrence [
	| workUnit |
	workUnit := CPInstantiateEventBasedGatewayWorkUnit
		processDeployment: processDeployment
		gateway: gateway
		sequenceFlow: sequenceFlow
		occurrence: anOccurrence.
	^ aBpmService instantiateEventBasedGatewayWorkUnit: workUnit
]
