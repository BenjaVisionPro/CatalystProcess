Class {
	#name : 'CPIntermediateThrowEventExecution',
	#superclass : 'CPEventExecution',
	#instVars : [
		'completed'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPIntermediateThrowEventExecution >> initialize [
	super initialize.
	completed := false
]

{ #category : 'testing' }
CPIntermediateThrowEventExecution >> isCompleted [ ^ completed ]

{ #category : 'testing' }
CPIntermediateThrowEventExecution >> isPending [ ^ completed not ]

{ #category : 'execution' }
CPIntermediateThrowEventExecution >> complete [
	completed ifTrue: [ self error: 'The Intermediate Throw Event execution is already completed.' ].
	completed := true
]

{ #category : 'testing' }
CPIntermediateThrowEventExecution >> isPendingWork [
	^ self isPending
]
