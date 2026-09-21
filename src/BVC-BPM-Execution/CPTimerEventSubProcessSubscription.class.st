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
	self validateOccurrenceForDelivery: anOccurrence.
	^ scope acceptTimerEventSubProcessSubscription: self occurrence: anOccurrence
]


{ #category : 'accessing' }
CPTimerEventSubProcessSubscription >> executionScope [ ^ scope ]
