Class {
	#name : 'CPStandardLoopIterationExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'activityExecution',
		'index',
		'active',
		'completed'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPStandardLoopIterationExecution >> initialize [
	super initialize.
	active := false.
	completed := false
]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> activityExecution [ ^ activityExecution ]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> activityExecution: anActivityExecution [ activityExecution := anActivityExecution ]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> index [ ^ index ]

{ #category : 'accessing' }
CPStandardLoopIterationExecution >> index: anInteger [ index := anInteger ]

{ #category : 'testing' }
CPStandardLoopIterationExecution >> isActive [ ^ active ]

{ #category : 'testing' }
CPStandardLoopIterationExecution >> isCompleted [ ^ completed ]

{ #category : 'lifecycle' }
CPStandardLoopIterationExecution >> activate [
	(active or: [ completed ]) ifTrue: [ self error: 'A Standard Loop iteration can be activated only once.' ].
	active := true
]

{ #category : 'lifecycle' }
CPStandardLoopIterationExecution >> complete [
	active ifFalse: [ self error: 'Only an Active Standard Loop iteration can complete.' ].
	active := false.
	completed := true
]
