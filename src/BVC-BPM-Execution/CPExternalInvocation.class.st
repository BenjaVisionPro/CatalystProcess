Class {
	#name : 'CPExternalInvocation',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'invocationIdentifier',
		'activityExecution',
		'implementation',
		'inputValue',
		'inputValueAssigned',
		'resultOccurrence',
		'faultOccurrence'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}


{ #category : 'initialization' }
CPExternalInvocation >> initialize [
	super initialize.
	inputValueAssigned := false
]

{ #category : 'accessing' }
CPExternalInvocation >> hasInputValue [ ^ inputValueAssigned ]

{ #category : 'accessing' }
CPExternalInvocation >> inputValue [
	inputValueAssigned ifFalse: [ self error: 'The external invocation has no input value.' ].
	^ inputValue
]

{ #category : 'accessing' }
CPExternalInvocation >> inputValue: aValue [
	inputValueAssigned ifTrue: [ self error: 'An external invocation input value can be assigned only once.' ].
	inputValue := aValue.
	inputValueAssigned := true.
	^ aValue
]

{ #category : 'accessing' }
CPExternalInvocation >> invocationIdentifier [ ^ invocationIdentifier ]

{ #category : 'accessing' }
CPExternalInvocation >> invocationIdentifier: anIdentifier [
	anIdentifier ifNil: [ self error: 'An external invocation requires a stable invocation identifier.' ].
	invocationIdentifier ifNotNil: [ self error: 'An external invocation identifier can be assigned only once.' ].
	invocationIdentifier := anIdentifier
]

{ #category : 'accessing' }
CPExternalInvocation >> activityExecution [ ^ activityExecution ]

{ #category : 'accessing' }
CPExternalInvocation >> activityExecution: anActivityExecution [
	activityExecution ifNotNil: [ self error: 'An external invocation can belong to only one Activity execution.' ].
	activityExecution := anActivityExecution
]

{ #category : 'accessing' }
CPExternalInvocation >> implementation [ ^ implementation ]

{ #category : 'accessing' }
CPExternalInvocation >> implementation: anImplementation [
	anImplementation ifNil: [ self error: 'An external invocation requires a resolved implementation.' ].
	implementation ifNotNil: [ self error: 'An external invocation implementation can be assigned only once.' ].
	implementation := anImplementation
]

{ #category : 'accessing' }
CPExternalInvocation >> resultOccurrence [ ^ resultOccurrence ]

{ #category : 'accessing' }
CPExternalInvocation >> faultOccurrence [ ^ faultOccurrence ]

{ #category : 'testing' }
CPExternalInvocation >> isPending [ ^ resultOccurrence isNil and: [ faultOccurrence isNil ] ]

{ #category : 'testing' }
CPExternalInvocation >> isCompleted [ ^ resultOccurrence notNil and: [ faultOccurrence isNil ] ]

{ #category : 'testing' }
CPExternalInvocation >> isFaulted [ ^ faultOccurrence notNil and: [ resultOccurrence isNil ] ]

{ #category : 'results' }
CPExternalInvocation >> acceptResultOccurrence: anOccurrence [
	self isPending ifFalse: [ self error: 'An external invocation can accept only one terminal outcome.' ].
	resultOccurrence := anOccurrence.
	^ anOccurrence
]

{ #category : 'results' }
CPExternalInvocation >> acceptFaultOccurrence: anOccurrence [
	self isPending ifFalse: [ self error: 'An external invocation can accept only one terminal outcome.' ].
	faultOccurrence := anOccurrence.
	^ anOccurrence
]
