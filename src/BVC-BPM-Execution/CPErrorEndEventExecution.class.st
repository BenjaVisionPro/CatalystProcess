Class {
	#name : 'CPErrorEndEventExecution',
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
CPErrorEndEventExecution >> initialize [
	super initialize.
	compensationRecords := OrderedCollection new.
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
	compensationRecords addAll: aCollection
]

{ #category : 'accessing' }
CPErrorEndEventExecution >> compensationRecords [
	^ compensationRecords
]

{ #category : 'testing' }
CPErrorEndEventExecution >> isWaitingForCompensationRecord: aCompensationRecord [
	^ completed not
		and: [ compensationRecords identityIncludes: aCompensationRecord ]
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
