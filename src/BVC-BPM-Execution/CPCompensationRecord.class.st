Class {
	#name : 'CPCompensationRecord',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'activityExecution',
		'boundaryEvent',
		'claimed'
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
