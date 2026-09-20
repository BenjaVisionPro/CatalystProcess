Class {
	#name : 'CPErrorEndEventExecution',
	#superclass : 'CPEventExecution',
	#instVars : [
		'boundaryExecution',
		'compensationRecords',
		'currentCompensationRecordIndex',
		'completed'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPErrorEndEventExecution >> initialize [
	super initialize.
	compensationRecords := OrderedCollection new.
	currentCompensationRecordIndex := 0.
	completed := false
]

{ #category : 'accessing' }
CPErrorEndEventExecution >> boundaryExecution [ ^ boundaryExecution ]

{ #category : 'accessing' }
CPErrorEndEventExecution >> boundaryExecution: aBoundaryEventExecution [ boundaryExecution := aBoundaryEventExecution ]

{ #category : 'accessing' }
CPErrorEndEventExecution >> compensationRecords: aCollection [
	compensationRecords isEmpty ifFalse: [
		self error: 'An Error End Event execution can establish presumed-abort compensation work only once.' ].
	aCollection isEmpty ifTrue: [
		self error: 'Presumed-abort compensation coordination requires at least one compensation record.' ].
	compensationRecords addAll: aCollection.
	currentCompensationRecordIndex := 1
]

{ #category : 'accessing' }
CPErrorEndEventExecution >> currentCompensationRecord [
	currentCompensationRecordIndex = 0 ifTrue: [ ^ nil ].
	^ compensationRecords at: currentCompensationRecordIndex
]

{ #category : 'testing' }
CPErrorEndEventExecution >> hasMoreCompensationRecords [
	^ currentCompensationRecordIndex > 0
		and: [ currentCompensationRecordIndex < compensationRecords size ]
]

{ #category : 'testing' }
CPErrorEndEventExecution >> isWaitingForCompensationRecord: aCompensationRecord [
	^ completed not
		and: [ self currentCompensationRecord == aCompensationRecord ]
]

{ #category : 'lifecycle' }
CPErrorEndEventExecution >> advanceAfterCompensationRecord: aCompensationRecord [
	(self isWaitingForCompensationRecord: aCompensationRecord) ifFalse: [
		self error: 'Only completion of the current presumed-abort compensation record can advance Error propagation.' ].
	self hasMoreCompensationRecords ifFalse: [ ^ nil ].
	currentCompensationRecordIndex := currentCompensationRecordIndex + 1.
	^ self currentCompensationRecord
]

{ #category : 'lifecycle' }
CPErrorEndEventExecution >> complete [
	completed ifTrue: [ self error: 'An Error End Event execution can complete propagation only once.' ].
	completed := true.
	^ self
]

{ #category : 'testing' }
CPErrorEndEventExecution >> isPendingWork [
	^ completed not
]

{ #category : 'testing' }
CPErrorEndEventExecution >> isErrorEndEventExecution [
	^ true
]
