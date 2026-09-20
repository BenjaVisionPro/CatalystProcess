Class {
	#name : 'CPReceiveTaskExecution',
	#superclass : 'CPActivityExecution',
	#instVars : [
		'receivedOccurrence',
		'subscription'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPReceiveTaskExecution >> receivedOccurrence [ ^ receivedOccurrence ]


{ #category : 'accessing' }
CPReceiveTaskExecution >> subscription [ ^ subscription ]

{ #category : 'accessing' }
CPReceiveTaskExecution >> subscription: aMessageSubscription [ subscription := aMessageSubscription ]

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


{ #category : 'messages' }
CPReceiveTaskExecution >> acceptMessageSubscription: aSubscription occurrence: anOccurrence [
	subscription == aSubscription ifFalse: [ self error: 'The Message subscription does not belong to this Receive Task execution.' ].
	^ scope triggerReceiveTaskExecution: self with: anOccurrence
]


{ #category : 'multi-instance' }
CPReceiveTaskExecution >> multiInstanceActivityExecutionDidBegin: anInstance [
	super multiInstanceActivityExecutionDidBegin: anInstance.
	self scope subscribeMultiInstanceReceiveTaskExecution: anInstance.
	^ anInstance
]


{ #category : 'looping' }
CPReceiveTaskExecution >> standardLoopIterationDidBegin: anIteration [
	super standardLoopIterationDidBegin: anIteration.
	scope subscribeStandardLoopReceiveTaskIteration: anIteration.
	^ anIteration
]
