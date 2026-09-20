Class {
	#name : 'CPCompensationThrowEventExecution',
	#superclass : 'CPIntermediateThrowEventExecution',
	#instVars : [
		'compensationRecord'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPCompensationThrowEventExecution >> compensationRecord [
	^ compensationRecord
]

{ #category : 'accessing' }
CPCompensationThrowEventExecution >> compensationRecord: aCompensationRecord [
	compensationRecord ifNotNil: [ self error: 'A Compensation Throw Event execution can coordinate only one compensation record.' ].
	compensationRecord := aCompensationRecord
]

{ #category : 'testing' }
CPCompensationThrowEventExecution >> isWaitingForCompensation [
	^ self isPending and: [ compensationRecord notNil ]
]

{ #category : 'testing' }
CPCompensationThrowEventExecution >> isWaitingForHandlerExecution: anActivityExecution [
	^ self isWaitingForCompensation
		and: [ compensationRecord handlerExecution == anActivityExecution ]
]

{ #category : 'testing' }
CPCompensationThrowEventExecution >> isCompensationThrowEventExecution [
	^ true
]
