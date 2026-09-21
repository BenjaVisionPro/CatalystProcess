Class {
	#name : 'CPTimerEventSubProcessSubscription',
	#superclass : 'CPTimerSubscription',
	#instVars : [
		'scope',
		'eventSubProcess',
		'startEvent'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPTimerEventSubProcessSubscription >> scope [ ^ scope ]

{ #category : 'accessing' }
CPTimerEventSubProcessSubscription >> scope: anExecutionScope [ scope := anExecutionScope ]

{ #category : 'accessing' }
CPTimerEventSubProcessSubscription >> eventSubProcess [ ^ eventSubProcess ]

{ #category : 'accessing' }
CPTimerEventSubProcessSubscription >> eventSubProcess: aSubProcess [ eventSubProcess := aSubProcess ]

{ #category : 'accessing' }
CPTimerEventSubProcessSubscription >> startEvent [ ^ startEvent ]

{ #category : 'accessing' }
CPTimerEventSubProcessSubscription >> startEvent: aStartEvent [ startEvent := aStartEvent ]

{ #category : 'occurrences' }
CPTimerEventSubProcessSubscription >> deliverOccurrence: anOccurrence [
	self isWaiting ifFalse: [ self error: 'A Timer Event SubProcess subscription can be delivered only once.' ].
	anOccurrence definition == self timerDefinition ifFalse: [
		self error: 'The occurrence does not match this Timer Event SubProcess subscription.' ].
	^ scope acceptTimerEventSubProcessSubscription: self occurrence: anOccurrence
]


{ #category : 'accessing' }
CPTimerEventSubProcessSubscription >> executionScope [ ^ scope ]
