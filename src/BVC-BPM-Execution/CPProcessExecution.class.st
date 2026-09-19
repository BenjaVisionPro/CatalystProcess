Class {
	#name : 'CPProcessExecution',
	#superclass : 'CPExecutionScope',
	#instVars : [
		'deployment',
		'tenant',
		'startedBy',
		'environment'
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
