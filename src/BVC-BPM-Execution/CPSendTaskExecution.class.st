Class {
	#name : 'CPSendTaskExecution',
	#superclass : 'CPActivityExecution',
	#instVars : [
		'messageDispatch'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPSendTaskExecution >> messageDispatch [ ^ messageDispatch ]

{ #category : 'messages' }
CPSendTaskExecution >> prepareMessageDispatch [
	| inputs input |
	self isActive ifFalse: [ self error: 'Only an Active Send Task can prepare a Message dispatch.' ].
	messageDispatch ifNotNil: [ self error: 'A Send Task execution can prepare only one Message dispatch.' ].
	definition messageRef ifNil: [ self error: 'A Send Task requires a Message.' ].
	messageDispatch := CPMessageDispatch new
		message: definition messageRef;
		activityExecution: self;
		yourself.
	definition ioSpecification ifNil: [ ^ messageDispatch ].
	inputs := definition ioSpecification dataInputs.
	inputs ifEmpty: [ ^ messageDispatch ].
	inputs size = 1 ifFalse: [
		self error: 'A Send Task Message input requires at most one Data Input.' ].
	input := inputs first.
	(self hasItemValueFor: input) ifFalse: [
		self error: 'The Send Task Data Input is unavailable for the Message dispatch.' ].
	messageDispatch payload: (self itemValueFor: input).
	^ messageDispatch
]

{ #category : 'multi-instance' }
CPSendTaskExecution >> multiInstanceActivityExecutionDidBegin: anInstance [
	super multiInstanceActivityExecutionDidBegin: anInstance.
	anInstance prepareMessageDispatch.
	^ anInstance
]
