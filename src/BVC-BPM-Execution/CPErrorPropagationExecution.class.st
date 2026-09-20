Class {
	#name : 'CPErrorPropagationExecution',
	#superclass : 'CPEventExecution',
	#instVars : [
		'boundaryExecution',
		'compensationRecords',
		'completed'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPErrorPropagationExecution >> initialize [
	super initialize.
	compensationRecords := OrderedCollection new.
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
	compensationRecords addAll: aCollection
]

{ #category : 'accessing' }
CPErrorPropagationExecution >> compensationRecords [
	^ compensationRecords
]

{ #category : 'testing' }
CPErrorPropagationExecution >> isWaitingForCompensationRecord: aCompensationRecord [
	^ completed not
		and: [ compensationRecords identityIncludes: aCompensationRecord ]
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
