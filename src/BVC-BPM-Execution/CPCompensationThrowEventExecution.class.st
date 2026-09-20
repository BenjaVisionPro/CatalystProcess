Class {
	#name : 'CPCompensationThrowEventExecution',
	#superclass : 'CPIntermediateThrowEventExecution',
	#instVars : [
		'compensationRecords'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPCompensationThrowEventExecution >> initialize [
	super initialize.
	compensationRecords := OrderedCollection new
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
	compensationRecords addAll: aCollection
]

{ #category : 'accessing' }
CPCompensationThrowEventExecution >> currentCompensationRecord [
	^ compensationRecords
		detect: [ :each | each isHandled not ]
		ifNone: [ nil ]
]

{ #category : 'testing' }
CPCompensationThrowEventExecution >> isWaitingForCompensation [
	^ self isPending and: [
		compensationRecords anySatisfy: [ :each | each isHandled not ] ]
]

{ #category : 'testing' }
CPCompensationThrowEventExecution >> isWaitingForCompensationRecord: aCompensationRecord [
	^ self isPending
		and: [ (compensationRecords identityIncludes: aCompensationRecord)
			and: [ aCompensationRecord isHandled ] ]
]

{ #category : 'testing' }
CPCompensationThrowEventExecution >> isCompensationThrowEventExecution [
	^ true
]
