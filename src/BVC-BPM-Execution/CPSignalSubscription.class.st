Class {
	#name : 'CPSignalSubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'waitingExecution', 'signal', 'occurrence', 'cancelled' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPSignalSubscription >> initialize [
	super initialize.
	cancelled := false
]

{ #category : 'accessing' }
CPSignalSubscription >> waitingExecution [ ^ waitingExecution ]
{ #category : 'accessing' }
CPSignalSubscription >> waitingExecution: anExecution [ waitingExecution := anExecution ]
{ #category : 'accessing' }
CPSignalSubscription >> signal [ ^ signal ]
{ #category : 'accessing' }
CPSignalSubscription >> signal: aSignal [ signal := aSignal ]
{ #category : 'accessing' }
CPSignalSubscription >> occurrence [ ^ occurrence ]

{ #category : 'testing' }
CPSignalSubscription >> isWaiting [ ^ occurrence isNil and: [ cancelled not ] ]
{ #category : 'testing' }
CPSignalSubscription >> isCancelled [ ^ cancelled ]
{ #category : 'testing' }
CPSignalSubscription >> isTriggered [ ^ occurrence notNil ]

{ #category : 'signals' }
CPSignalSubscription >> triggerWith: anOccurrence [
	self isWaiting ifFalse: [ self error: 'A Signal subscription can be triggered only once.' ].
	anOccurrence definition == signal ifFalse: [ self error: 'The occurrence does not match this Signal subscription.' ].
	occurrence := anOccurrence.
	^ anOccurrence
]

{ #category : 'signals' }
CPSignalSubscription >> deliverOccurrence: anOccurrence [
	self isWaiting ifFalse: [ self error: 'A Signal subscription can be delivered only once.' ].
	anOccurrence definition == signal ifFalse: [ self error: 'The occurrence does not match this Signal subscription.' ].
	^ waitingExecution acceptSignalSubscription: self occurrence: anOccurrence
]

{ #category : 'lifecycle' }
CPSignalSubscription >> cancel [
	self isWaiting ifFalse: [ self error: 'Only a waiting Signal subscription can be cancelled.' ].
	cancelled := true.
	^ self
]
