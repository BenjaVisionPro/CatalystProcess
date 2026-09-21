Class {
	#name : 'CPTimerSubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'eventExecution', 'timerDefinition', 'occurrence', 'cancelled', 'armedAt', 'dueTime' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPTimerSubscription >> initialize [
	super initialize.
	cancelled := false
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
CPTimerSubscription >> isWaiting [ ^ occurrence isNil and: [ cancelled not ] ]

{ #category : 'testing' }
CPTimerSubscription >> isCancelled [ ^ cancelled ]
{ #category : 'testing' }
CPTimerSubscription >> isTriggered [ ^ occurrence notNil ]
{ #category : 'occurrences' }
CPTimerSubscription >> triggerWith: anOccurrence [
	self isWaiting ifFalse: [ self error: 'Only a waiting Timer subscription can be triggered.' ].
	anOccurrence definition == timerDefinition ifFalse: [
		self error: 'The occurrence does not match this Timer subscription.' ].
	occurrence := anOccurrence.
	^ self
]


{ #category : 'occurrences' }
CPTimerSubscription >> deliverOccurrence: anOccurrence [
	self isWaiting ifFalse: [ self error: 'Only a waiting Timer subscription can receive an occurrence.' ].
	anOccurrence definition == timerDefinition ifFalse: [
		self error: 'The occurrence does not match this Timer subscription.' ].
	^ eventExecution acceptTimerSubscription: self occurrence: anOccurrence
]

{ #category : 'lifecycle' }
CPTimerSubscription >> cancel [
	self isWaiting ifFalse: [ self error: 'Only a waiting Timer subscription can be cancelled.' ].
	cancelled := true.
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
