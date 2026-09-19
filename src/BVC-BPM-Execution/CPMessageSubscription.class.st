Class {
	#name : 'CPMessageSubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'waitingExecution',
		'message',
		'occurrence',
		'cancelled'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPMessageSubscription >> initialize [
	super initialize.
	cancelled := false
]

{ #category : 'accessing' }
CPMessageSubscription >> waitingExecution [ ^ waitingExecution ]

{ #category : 'accessing' }
CPMessageSubscription >> waitingExecution: anExecution [ waitingExecution := anExecution ]

{ #category : 'accessing' }
CPMessageSubscription >> message [ ^ message ]

{ #category : 'accessing' }
CPMessageSubscription >> message: aMessage [ message := aMessage ]

{ #category : 'accessing' }
CPMessageSubscription >> occurrence [ ^ occurrence ]

{ #category : 'testing' }
CPMessageSubscription >> isWaiting [ ^ occurrence isNil and: [ cancelled not ] ]

{ #category : 'testing' }
CPMessageSubscription >> isCancelled [ ^ cancelled ]

{ #category : 'testing' }
CPMessageSubscription >> isTriggered [ ^ occurrence notNil ]

{ #category : 'messages' }
CPMessageSubscription >> triggerWith: anOccurrence [
	self isWaiting ifFalse: [ self error: 'A Message subscription can be triggered only once.' ].
	anOccurrence definition == message ifFalse: [ self error: 'The occurrence does not match this Message subscription.' ].
	occurrence := anOccurrence.
	^ anOccurrence
]


{ #category : 'messages' }
CPMessageSubscription >> deliverOccurrence: anOccurrence [
	self isWaiting ifFalse: [ self error: 'A Message subscription can be delivered only once.' ].
	anOccurrence definition == message ifFalse: [ self error: 'The occurrence does not match this Message subscription.' ].
	^ waitingExecution acceptMessageSubscription: self occurrence: anOccurrence
]

{ #category : 'lifecycle' }
CPMessageSubscription >> cancel [
	self isWaiting ifFalse: [ self error: 'Only a waiting Message subscription can be cancelled.' ].
	cancelled := true.
	^ self
]
