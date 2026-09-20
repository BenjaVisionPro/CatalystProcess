Class {
	#name : 'CPErrorPropagationExecution',
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
CPErrorPropagationExecution >> initialize [
	super initialize.
	compensationRecords := OrderedCollection new.
	currentCompensationRecordIndex := 0.
	completed := false
]

{ #category : 'accessing' }
CPErrorPropagationExecution >> boundaryExecution [ ^ boundaryExecution ]

{ #category : 'accessing' }
CPErrorPropagationExecution >> boundaryExecution: aBoundaryEventExecution [ boundaryExecution := aBoundaryEventExecution ]

{ #category : 'accessing' }
CPErrorPropagationExecution >> compensationRecords: aCollection [
	compensationRecords isEmpty ifFalse: [
		self error: 'A propagated Error execution can establish presumed-abort compensation work only once.' ].
	aCollection isEmpty ifTrue: [
		self error: 'Propagated presumed-abort compensation coordination requires at least one compensation record.' ].
	compensationRecords addAll: aCollection.
	currentCompensationRecordIndex := 1
]

{ #category : 'accessing' }
CPErrorPropagationExecution >> currentCompensationRecord [
	currentCompensationRecordIndex = 0 ifTrue: [ ^ nil ].
	^ compensationRecords at: currentCompensationRecordIndex
]

{ #category : 'testing' }
CPErrorPropagationExecution >> hasMoreCompensationRecords [
	^ currentCompensationRecordIndex > 0
		and: [ currentCompensationRecordIndex < compensationRecords size ]
]

{ #category : 'testing' }
CPErrorPropagationExecution >> isWaitingForCompensationRecord: aCompensationRecord [
	^ completed not
		and: [ self currentCompensationRecord == aCompensationRecord ]
]

{ #category : 'lifecycle' }
CPErrorPropagationExecution >> advanceAfterCompensationRecord: aCompensationRecord [
	(self isWaitingForCompensationRecord: aCompensationRecord) ifFalse: [
		self error: 'Only completion of the current presumed-abort compensation record can advance propagated Error handling.' ].
	self hasMoreCompensationRecords ifFalse: [ ^ nil ].
	currentCompensationRecordIndex := currentCompensationRecordIndex + 1.
	^ self currentCompensationRecord
]

{ #category : 'lifecycle' }
CPErrorPropagationExecution >> complete [
	completed ifTrue: [ self error: 'A propagated Error execution can complete only once.' ].
	completed := true.
	^ self
]

{ #category : 'testing' }
CPErrorPropagationExecution >> isPendingWork [
	^ completed not
]

{ #category : 'testing' }
CPErrorPropagationExecution >> isErrorPropagationExecution [
	^ true
]
