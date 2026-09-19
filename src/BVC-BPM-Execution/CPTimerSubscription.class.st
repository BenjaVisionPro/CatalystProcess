Class {
	#name : 'CPTimerSubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'eventExecution', 'timerDefinition', 'occurrence' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPTimerSubscription >> eventExecution [ ^ eventExecution ]
{ #category : 'accessing' }
CPTimerSubscription >> eventExecution: anEventExecution [ eventExecution := anEventExecution ]
{ #category : 'accessing' }
CPTimerSubscription >> timerDefinition [ ^ timerDefinition ]
{ #category : 'accessing' }
CPTimerSubscription >> timerDefinition: aTimerDefinition [ timerDefinition := aTimerDefinition ]
{ #category : 'accessing' }
CPTimerSubscription >> occurrence [ ^ occurrence ]
{ #category : 'testing' }
CPTimerSubscription >> isWaiting [ ^ occurrence isNil ]
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
