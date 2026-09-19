Class {
	#name : 'CPProcessExecution',
	#superclass : 'CPExecutionScope',
	#instVars : [
		'deployment',
		'tenant',
		'startedBy',
		'environment',
		'started'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'instance creation' }
CPProcessExecution class >> for: aProcess environment: anExecutionEnvironment [
	^ self new
		definition: aProcess;
		environment: anExecutionEnvironment;
		yourself
]

{ #category : 'accessing' }
CPProcessExecution >> deployment [ ^ deployment ]
{ #category : 'accessing' }
CPProcessExecution >> deployment: anObject [ deployment := anObject ]
{ #category : 'accessing' }
CPProcessExecution >> tenant [ ^ tenant ]
{ #category : 'accessing' }
CPProcessExecution >> tenant: anObject [ tenant := anObject ]
{ #category : 'accessing' }
CPProcessExecution >> startedBy [ ^ startedBy ]
{ #category : 'accessing' }
CPProcessExecution >> startedBy: anObject [ startedBy := anObject ]

{ #category : 'accessing' }
CPProcessExecution >> environment [ ^ environment ]
{ #category : 'accessing' }
CPProcessExecution >> environment: anExecutionEnvironment [ environment := anExecutionEnvironment ]


{ #category : 'initialization' }
CPProcessExecution >> initialize [
	super initialize.
	started := false
]

{ #category : 'testing' }
CPProcessExecution >> isStarted [
	^ started
]

{ #category : 'lifecycle' }
CPProcessExecution >> start [
	| startEvents executions |
	started ifTrue: [ self error: 'A Process execution can only be started once.' ].
	startEvents := self definition flowElements select: [ :each |
		each isStartEvent and: [ each eventDefinitions isEmpty ] ].
	startEvents ifEmpty: [ self error: 'Process instantiation requires at least one None Start Event.' ].
	started := true.
	executions := startEvents collect: [ :each | self executeStartEvent: each occurrence: nil ].
	^ executions
]
