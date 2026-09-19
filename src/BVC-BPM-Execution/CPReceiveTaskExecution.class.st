Class {
	#name : 'CPReceiveTaskExecution',
	#superclass : 'CPActivityExecution',
	#instVars : [
		'receivedOccurrence'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPReceiveTaskExecution >> receivedOccurrence [ ^ receivedOccurrence ]

{ #category : 'testing' }
CPReceiveTaskExecution >> isWaitingForMessage [
	^ self isActive and: [ receivedOccurrence isNil ]
]

{ #category : 'messages' }
CPReceiveTaskExecution >> acceptReceivedOccurrence: anOccurrence [
	self isWaitingForMessage ifFalse: [ self error: 'Only a waiting Receive Task can accept a message occurrence.' ].
	receivedOccurrence := anOccurrence.
	^ anOccurrence
]
