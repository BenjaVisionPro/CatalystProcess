Class {
	#name : 'CPCompensationRecord',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'activityExecution',
		'boundaryEvent',
		'claimed',
		'handlerExecution',
		'completionSequence'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPCompensationRecord >> initialize [
	super initialize.
	claimed := false
]

{ #category : 'accessing' }
CPCompensationRecord >> activityExecution [ ^ activityExecution ]

{ #category : 'accessing' }
CPCompensationRecord >> activityExecution: anActivityExecution [ activityExecution := anActivityExecution ]

{ #category : 'accessing' }
CPCompensationRecord >> boundaryEvent [ ^ boundaryEvent ]

{ #category : 'accessing' }
CPCompensationRecord >> boundaryEvent: aBoundaryEvent [ boundaryEvent := aBoundaryEvent ]

{ #category : 'testing' }
CPCompensationRecord >> isClaimed [ ^ claimed ]

{ #category : 'testing' }
CPCompensationRecord >> isAvailable [
	^ activityExecution isCompleted and: [ claimed not ]
]

{ #category : 'lifecycle' }
CPCompensationRecord >> claim [
	self isAvailable ifFalse: [ self error: 'Only an available compensation record can be claimed.' ].
	claimed := true.
	^ self
]


{ #category : 'accessing' }
CPCompensationRecord >> handlerExecution [ ^ handlerExecution ]

{ #category : 'lifecycle' }
CPCompensationRecord >> beginHandlingWith: anActivityExecution [
	self isClaimed ifFalse: [ self error: 'A compensation record must be claimed before its handler can begin.' ].
	handlerExecution ifNotNil: [ self error: 'A compensation record can begin its handler only once.' ].
	handlerExecution := anActivityExecution.
	^ anActivityExecution
]

{ #category : 'testing' }
CPCompensationRecord >> isHandling [
	^ handlerExecution notNil and: [ handlerExecution isFinal not ]
]

{ #category : 'testing' }
CPCompensationRecord >> isHandled [
	^ handlerExecution notNil and: [ handlerExecution isCompleted ]
]


{ #category : 'accessing' }
CPCompensationRecord >> completionSequence [
	^ completionSequence
]

{ #category : 'accessing' }
CPCompensationRecord >> completionSequence: anInteger [
	completionSequence ifNotNil: [ self error: 'A compensation record completion sequence can only be assigned once.' ].
	completionSequence := anInteger
]
