Class {
	#name : 'CPStandardLoopIterationExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'activityExecution',
		'index',
		'active',
		'completed',
		'messageDispatch',
		'messageSubscription',
		'receivedOccurrence'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPStandardLoopIterationExecution >> initialize [
	super initialize.
	active := false.
	completed := false
]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> activityExecution [ ^ activityExecution ]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> activityExecution: anActivityExecution [ activityExecution := anActivityExecution ]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> index [ ^ index ]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> index: anInteger [ index := anInteger ]

{ #category : 'testing' }
CPStandardLoopIterationExecution >> isActive [ ^ active ]

{ #category : 'testing' }
CPStandardLoopIterationExecution >> isCompleted [ ^ completed ]

{ #category : 'lifecycle' }
CPStandardLoopIterationExecution >> activate [
	(active or: [ completed ]) ifTrue: [ self error: 'A Standard Loop iteration can be activated only once.' ].
	active := true
]

{ #category : 'lifecycle' }
CPStandardLoopIterationExecution >> complete [
	active ifFalse: [ self error: 'Only an Active Standard Loop iteration can complete.' ].
	active := false.
	completed := true
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
