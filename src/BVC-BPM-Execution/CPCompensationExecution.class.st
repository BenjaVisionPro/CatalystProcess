Class {
	#name : 'CPCompensationExecution',
	#superclass : 'CPEventExecution',
	#instVars : [
		'compensationRecords',
		'completed'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPCompensationExecution >> initialize [
	super initialize.
	compensationRecords := OrderedCollection new.
	completed := false
]

{ #category : 'accessing' }
CPCompensationExecution >> compensationRecords [
	^ compensationRecords
]

{ #category : 'accessing' }
CPCompensationExecution >> compensationRecords: aCollection [
	compensationRecords isEmpty ifFalse: [
		self error: 'A Compensation execution can establish its compensation work only once.' ].
	aCollection isEmpty ifTrue: [
		self error: 'A Compensation execution requires at least one compensation record.' ].
	compensationRecords addAll: aCollection
]

{ #category : 'lifecycle' }
CPCompensationExecution >> complete [
	completed ifTrue: [ self error: 'A Compensation execution can complete only once.' ].
	completed := true.
	^ self
]

{ #category : 'testing' }
CPCompensationExecution >> isCompensationExecution [
	^ true
]

{ #category : 'testing' }
CPCompensationExecution >> isPendingWork [
	^ completed not
]

{ #category : 'testing' }
CPCompensationExecution >> isWaitingForCompensationRecord: aCompensationRecord [
	^ completed not and: [ compensationRecords identityIncludes: aCompensationRecord ]
]
