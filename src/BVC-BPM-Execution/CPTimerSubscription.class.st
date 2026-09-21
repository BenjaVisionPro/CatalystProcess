Class {
	#name : 'CPTimerSubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'eventExecution', 'timerDefinition', 'occurrence', 'cancelled', 'armedAt', 'dueTime', 'dispatchPending', 'dispatchOccurrenceIdentifier' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPTimerSubscription >> initialize [
	super initialize.
	cancelled := false.
	dispatchPending := false
]

{ #category : 'accessing' }
CPTimerSubscription >> eventExecution [ ^ eventExecution ]
{ #category : 'accessing' }
CPTimerSubscription >> eventExecution: anEventExecution [ eventExecution := anEventExecution ]
{ #category : 'accessing' }
CPTimerSubscription >> timerDefinition [ ^ timerDefinition ]
{ #category : 'accessing' }
CPTimerSubscription >> timerDefinition: aTimerDefinition [ timerDefinition := aTimerDefinition. dueTime := nil ]
{ #category : 'accessing' }
CPTimerSubscription >> armedAt [ ^ armedAt ]
{ #category : 'accessing' }
CPTimerSubscription >> armedAt: aTime [ armedAt := aTime. dueTime := nil ]
{ #category : 'accessing' }
CPTimerSubscription >> executionScope [ ^ eventExecution scope ]
{ #category : 'accessing' }
CPTimerSubscription >> occurrence [ ^ occurrence ]
{ #category : 'testing' }
CPTimerSubscription >> isWaiting [ ^ occurrence isNil and: [ cancelled not and: [ dispatchPending not ] ] ]

{ #category : 'testing' }
CPTimerSubscription >> isDispatchPending [ ^ dispatchPending ]

{ #category : 'accessing' }
CPTimerSubscription >> dispatchOccurrenceIdentifier [ ^ dispatchOccurrenceIdentifier ]

{ #category : 'testing' }
CPTimerSubscription >> canReceiveOccurrence [
	^ occurrence isNil and: [ cancelled not and: [ self isWaiting or: [ self isDispatchPending ] ] ]
]

{ #category : 'testing' }
CPTimerSubscription >> isCancelled [ ^ cancelled ]
{ #category : 'testing' }
CPTimerSubscription >> isTriggered [ ^ occurrence notNil ]

{ #category : 'validation' }
CPTimerSubscription >> validateOccurrenceForDelivery: anOccurrence [
	self canReceiveOccurrence ifFalse: [ self error: 'Only a waiting or dispatch-pending Timer subscription can receive an occurrence.' ].
	self isDispatchPending ifTrue: [
		anOccurrence occurrenceIdentifier = dispatchOccurrenceIdentifier ifFalse: [
			self error: 'The occurrence identifier does not match the pending Timer dispatch.' ] ].
	anOccurrence definition == timerDefinition ifFalse: [
		self error: 'The occurrence does not match this Timer subscription.' ].
	^ self
]

{ #category : 'occurrences' }
CPTimerSubscription >> triggerWith: anOccurrence [
	self validateOccurrenceForDelivery: anOccurrence.
	occurrence := anOccurrence.
	dispatchPending := false.
	dispatchOccurrenceIdentifier := nil.
	^ self
]


{ #category : 'occurrences' }
CPTimerSubscription >> deliverOccurrence: anOccurrence [
	self validateOccurrenceForDelivery: anOccurrence.
	^ eventExecution acceptTimerSubscription: self occurrence: anOccurrence
]

{ #category : 'lifecycle' }
CPTimerSubscription >> cancel [
	self canReceiveOccurrence ifFalse: [ self error: 'Only a waiting or dispatch-pending Timer subscription can be cancelled.' ].
	cancelled := true.
	dispatchPending := false.
	dispatchOccurrenceIdentifier := nil.
	^ self
]


{ #category : 'timing' }
CPTimerSubscription >> dueAt [
	armedAt ifNil: [ self error: 'A Timer subscription must have an arming time before its due time can be evaluated.' ].
	dueTime ifNil: [
		dueTime := self executionScope environment
			timerDueAtFor: timerDefinition
			armedAt: armedAt
			in: self executionScope.
		dueTime ifNil: [ self error: 'Timer due-time evaluation must produce a due time.' ] ].
	^ dueTime
]

{ #category : 'testing' }
CPTimerSubscription >> isDueAt: aTime [
	self isWaiting ifFalse: [ ^ false ].
	^ self dueAt <= aTime
]

{ #category : 'lifecycle' }
CPTimerSubscription >> markDispatchPendingWithOccurrenceIdentifier: anOccurrenceIdentifier [
	self isWaiting ifFalse: [ self error: 'Only a waiting Timer subscription can be marked dispatch pending.' ].
	anOccurrenceIdentifier ifNil: [ self error: 'A Timer dispatch requires an occurrence identifier.' ].
	dispatchPending := true.
	dispatchOccurrenceIdentifier := anOccurrenceIdentifier.
	^ self
]
