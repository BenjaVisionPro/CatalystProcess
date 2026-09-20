Class {
	#name : 'CPCompensationRecord',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'activityExecution',
		'boundaryEvent',
		'claimed',
		'handling',
		'handled',
		'handlerExecution',
		'completionSequence',
		'compensationRecords'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPCompensationRecord >> initialize [
	super initialize.
	claimed := false.
	handling := false.
	handled := false.
	compensationRecords := OrderedCollection new
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

{ #category : 'lifecycle' }
CPCompensationRecord >> beginHandling [
	self isClaimed ifFalse: [ self error: 'A compensation record must be claimed before handling can begin.' ].
	(handling or: [ handled ]) ifTrue: [ self error: 'A compensation record can begin handling only once.' ].
	handling := true.
	^ self
]

{ #category : 'accessing' }
CPCompensationRecord >> handlerExecution [ ^ handlerExecution ]

{ #category : 'lifecycle' }
CPCompensationRecord >> beginHandlingWith: anActivityExecution [
	self beginHandling.
	handlerExecution := anActivityExecution.
	^ anActivityExecution
]

{ #category : 'lifecycle' }
CPCompensationRecord >> completeHandling [
	handling ifFalse: [ self error: 'Only a handling compensation record can complete.' ].
	handling := false.
	handled := true.
	^ self
]

{ #category : 'testing' }
CPCompensationRecord >> isHandling [
	^ handling
]

{ #category : 'testing' }
CPCompensationRecord >> isHandled [
	^ handled
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

{ #category : 'accessing' }
CPCompensationRecord >> compensationRecords [
	^ compensationRecords
]

{ #category : 'accessing' }
CPCompensationRecord >> compensationRecords: aCollection [
	compensationRecords isEmpty ifFalse: [
		self error: 'A compensation record can establish its nested compensation work only once.' ].
	compensationRecords addAll: aCollection
]

{ #category : 'testing' }
CPCompensationRecord >> isWaitingForCompensationRecord: aCompensationRecord [
	^ self isHandling
		and: [ compensationRecords identityIncludes: aCompensationRecord ]
]
