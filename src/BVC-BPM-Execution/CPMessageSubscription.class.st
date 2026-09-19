Class {
	#name : 'CPMessageSubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'receiveTaskExecution',
		'message',
		'occurrence'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPMessageSubscription >> receiveTaskExecution [ ^ receiveTaskExecution ]

{ #category : 'accessing' }
CPMessageSubscription >> receiveTaskExecution: anExecution [ receiveTaskExecution := anExecution ]

{ #category : 'accessing' }
CPMessageSubscription >> message [ ^ message ]

{ #category : 'accessing' }
CPMessageSubscription >> message: aMessage [ message := aMessage ]

{ #category : 'accessing' }
CPMessageSubscription >> occurrence [ ^ occurrence ]

{ #category : 'testing' }
CPMessageSubscription >> isWaiting [ ^ occurrence isNil ]

{ #category : 'testing' }
CPMessageSubscription >> isTriggered [ ^ occurrence notNil ]

{ #category : 'messages' }
CPMessageSubscription >> triggerWith: anOccurrence [
	self isWaiting ifFalse: [ self error: 'A Message subscription can be triggered only once.' ].
	anOccurrence definition == message ifFalse: [ self error: 'The occurrence does not match this Message subscription.' ].
	occurrence := anOccurrence.
	^ anOccurrence
]
