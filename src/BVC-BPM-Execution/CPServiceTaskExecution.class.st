Class {
	#name : 'CPServiceTaskExecution',
	#superclass : 'CPActivityExecution',
	#instVars : [
		'resolvedImplementation'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPServiceTaskExecution >> resolvedImplementation [ ^ resolvedImplementation ]

{ #category : 'accessing' }
CPServiceTaskExecution >> resolvedImplementation: anObject [
	resolvedImplementation ifNotNil: [ self error: 'A Service Task implementation can be resolved only once for an Activity execution.' ].
	anObject ifNil: [ self error: 'A Service Task requires a resolved Operation implementation.' ].
	resolvedImplementation := anObject
]
