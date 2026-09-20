Class {
	#name : 'CPMessageDispatch',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'message',
		'activityExecution',
		'payload',
		'payloadAssigned',
		'sent'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPMessageDispatch >> initialize [
	super initialize.
	payloadAssigned := false.
	sent := false
]

{ #category : 'accessing' }
CPMessageDispatch >> message [ ^ message ]

{ #category : 'accessing' }
CPMessageDispatch >> message: aMessage [
	message ifNotNil: [ self error: 'A Message dispatch can reference only one Message.' ].
	aMessage ifNil: [ self error: 'A Message dispatch requires a Message.' ].
	message := aMessage
]

{ #category : 'accessing' }
CPMessageDispatch >> activityExecution [ ^ activityExecution ]

{ #category : 'accessing' }
CPMessageDispatch >> activityExecution: anActivityExecution [
	activityExecution ifNotNil: [ self error: 'A Message dispatch can belong to only one Activity execution.' ].
	activityExecution := anActivityExecution
]

{ #category : 'accessing' }
CPMessageDispatch >> hasPayload [ ^ payloadAssigned ]

{ #category : 'accessing' }
CPMessageDispatch >> payload [
	payloadAssigned ifFalse: [ self error: 'The Message dispatch has no payload.' ].
	^ payload
]

{ #category : 'accessing' }
CPMessageDispatch >> payload: anObject [
	payloadAssigned ifTrue: [ self error: 'A Message dispatch payload can be assigned only once.' ].
	payload := anObject.
	payloadAssigned := true.
	^ anObject
]

{ #category : 'testing' }
CPMessageDispatch >> isPending [ ^ sent not ]

{ #category : 'testing' }
CPMessageDispatch >> isSent [ ^ sent ]

{ #category : 'lifecycle' }
CPMessageDispatch >> markSent [
	sent ifTrue: [ self error: 'A Message dispatch can be marked sent only once.' ].
	sent := true.
	^ self
]
