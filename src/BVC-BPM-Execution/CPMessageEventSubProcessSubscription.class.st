Class {
	#name : 'CPMessageEventSubProcessSubscription',
	#superclass : 'CPMessageSubscription',
	#instVars : [
		'scope',
		'eventSubProcess',
		'startEvent'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPMessageEventSubProcessSubscription >> scope [ ^ scope ]

{ #category : 'accessing' }
CPMessageEventSubProcessSubscription >> scope: anExecutionScope [ scope := anExecutionScope ]

{ #category : 'accessing' }
CPMessageEventSubProcessSubscription >> eventSubProcess [ ^ eventSubProcess ]

{ #category : 'accessing' }
CPMessageEventSubProcessSubscription >> eventSubProcess: aSubProcess [ eventSubProcess := aSubProcess ]

{ #category : 'accessing' }
CPMessageEventSubProcessSubscription >> startEvent [ ^ startEvent ]

{ #category : 'accessing' }
CPMessageEventSubProcessSubscription >> startEvent: aStartEvent [ startEvent := aStartEvent ]

{ #category : 'messages' }
CPMessageEventSubProcessSubscription >> deliverOccurrence: anOccurrence [
	self isWaiting ifFalse: [ self error: 'A Message Event SubProcess subscription can be delivered only once.' ].
	anOccurrence definition == self message ifFalse: [
		self error: 'The occurrence does not match this Message Event SubProcess subscription.' ].
	^ scope acceptMessageEventSubProcessSubscription: self occurrence: anOccurrence
]
