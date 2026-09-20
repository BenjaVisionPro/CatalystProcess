Class {
	#name : 'CPCompensationThrowEventExecution',
	#superclass : 'CPIntermediateThrowEventExecution',
	#instVars : [
		'compensationRecords',
		'currentCompensationRecordIndex'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPCompensationThrowEventExecution >> initialize [
	super initialize.
	compensationRecords := OrderedCollection new.
	currentCompensationRecordIndex := 0
]

{ #category : 'accessing' }
CPCompensationThrowEventExecution >> compensationRecord [
	^ self currentCompensationRecord
]

{ #category : 'accessing' }
CPCompensationThrowEventExecution >> compensationRecord: aCompensationRecord [
	self compensationRecords: { aCompensationRecord }
]

{ #category : 'accessing' }
CPCompensationThrowEventExecution >> compensationRecords [
	^ compensationRecords
]

{ #category : 'accessing' }
CPCompensationThrowEventExecution >> compensationRecords: aCollection [
	compensationRecords isEmpty ifFalse: [
		self error: 'A Compensation Throw Event execution can establish its compensation work only once.' ].
	aCollection isEmpty ifTrue: [
		self error: 'A synchronous Compensation Throw Event requires at least one compensation record.' ].
	compensationRecords addAll: aCollection.
	currentCompensationRecordIndex := 1
]

{ #category : 'accessing' }
CPCompensationThrowEventExecution >> currentCompensationRecord [
	currentCompensationRecordIndex = 0 ifTrue: [ ^ nil ].
	^ compensationRecords at: currentCompensationRecordIndex
]

{ #category : 'testing' }
CPCompensationThrowEventExecution >> hasMoreCompensationRecords [
	^ currentCompensationRecordIndex > 0
		and: [ currentCompensationRecordIndex < compensationRecords size ]
]

{ #category : 'lifecycle' }
CPCompensationThrowEventExecution >> advanceAfterHandlerExecution: anActivityExecution [
	(self isWaitingForHandlerExecution: anActivityExecution) ifFalse: [
		self error: 'Only completion of the current compensation handler can advance a synchronous Compensation Throw Event.' ].
	self hasMoreCompensationRecords ifFalse: [ ^ nil ].
	currentCompensationRecordIndex := currentCompensationRecordIndex + 1.
	^ self currentCompensationRecord
]

{ #category : 'testing' }
CPCompensationThrowEventExecution >> isWaitingForCompensation [
	^ self isPending and: [ self currentCompensationRecord notNil ]
]

{ #category : 'testing' }
CPCompensationThrowEventExecution >> isWaitingForHandlerExecution: anActivityExecution [
	^ self isWaitingForCompensation
		and: [ self currentCompensationRecord handlerExecution == anActivityExecution ]
]

{ #category : 'testing' }
CPCompensationThrowEventExecution >> isCompensationThrowEventExecution [
	^ true
]
