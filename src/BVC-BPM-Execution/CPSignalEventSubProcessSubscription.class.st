Class {
	#name : 'CPSignalEventSubProcessSubscription',
	#superclass : 'CPSignalSubscription',
	#instVars : [
		'scope',
		'eventSubProcess',
		'startEvent'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPSignalEventSubProcessSubscription >> scope [ ^ scope ]

{ #category : 'accessing' }
CPSignalEventSubProcessSubscription >> scope: anExecutionScope [ scope := anExecutionScope ]

{ #category : 'accessing' }
CPSignalEventSubProcessSubscription >> eventSubProcess [ ^ eventSubProcess ]

{ #category : 'accessing' }
CPSignalEventSubProcessSubscription >> eventSubProcess: aSubProcess [ eventSubProcess := aSubProcess ]

{ #category : 'accessing' }
CPSignalEventSubProcessSubscription >> startEvent [ ^ startEvent ]

{ #category : 'accessing' }
CPSignalEventSubProcessSubscription >> startEvent: aStartEvent [ startEvent := aStartEvent ]

{ #category : 'signals' }
CPSignalEventSubProcessSubscription >> deliverAcceptedOccurrence: anOccurrence [
	self isWaiting ifFalse: [ self error: 'A Signal Event SubProcess subscription can be delivered only once.' ].
	anOccurrence definition == self signal ifFalse: [
		self error: 'The occurrence does not match this Signal Event SubProcess subscription.' ].
	^ scope acceptSignalEventSubProcessSubscription: self acceptedOccurrence: anOccurrence
]
