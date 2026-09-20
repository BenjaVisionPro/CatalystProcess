Class {
	#name : 'CPIntermediateThrowEventExecution',
	#superclass : 'CPEventExecution',
	#instVars : [
		'completed',
		'withdrawn'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPIntermediateThrowEventExecution >> initialize [
	super initialize.
	completed := false.
	withdrawn := false
]

{ #category : 'testing' }
CPIntermediateThrowEventExecution >> isCompleted [ ^ completed ]

{ #category : 'testing' }
CPIntermediateThrowEventExecution >> isPending [ ^ completed not and: [ withdrawn not ] ]

{ #category : 'execution' }
CPIntermediateThrowEventExecution >> complete [
	self isPending ifFalse: [ self error: 'The Intermediate Throw Event execution is no longer pending.' ].
	completed := true
]

{ #category : 'testing' }
CPIntermediateThrowEventExecution >> isPendingWork [
	^ self isPending
]

{ #category : 'testing' }
CPIntermediateThrowEventExecution >> isWithdrawn [ ^ withdrawn ]

{ #category : 'lifecycle' }
CPIntermediateThrowEventExecution >> terminatePendingWork [
	self isPending ifTrue: [ withdrawn := true ].
	^ self
]
