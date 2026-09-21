Class {
	#name : 'CPProcessExecutionSnapshot',
	#superclass : 'CFObject',
	#instVars : [
		'executionIdentifier',
		'processIdentifier',
		'deploymentIdentifier',
		'started',
		'completed',
		'pendingUserTaskWorkItems',
		'pendingExternalInvocations'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'instance creation' }
CPProcessExecutionSnapshot class >> from: aCPProcessExecution [
	^ self new
		initializeFrom: aCPProcessExecution;
		yourself
]

{ #category : 'initialization' }
CPProcessExecutionSnapshot >> initializeFrom: aCPProcessExecution [
	executionIdentifier := aCPProcessExecution executionIdentifier.
	processIdentifier := aCPProcessExecution definition identifier.
	deploymentIdentifier := aCPProcessExecution deployment
		ifNotNil: [ :deployment | deployment identifier ].
	started := aCPProcessExecution isStarted.
	completed := aCPProcessExecution isCompleted.
	pendingUserTaskWorkItems := (aCPProcessExecution allPendingUserTaskWorkItems collect: [ :each |
		CPUserTaskWorkItemSnapshot from: each ]) asArray.
	pendingExternalInvocations := (aCPProcessExecution allPendingExternalInvocations collect: [ :each |
		CPExternalInvocationSnapshot from: each ]) asArray.
	^ self
]

{ #category : 'accessing' }
CPProcessExecutionSnapshot >> executionIdentifier [ ^ executionIdentifier ]
{ #category : 'accessing' }
CPProcessExecutionSnapshot >> processIdentifier [ ^ processIdentifier ]
{ #category : 'accessing' }
CPProcessExecutionSnapshot >> deploymentIdentifier [ ^ deploymentIdentifier ]
{ #category : 'testing' }
CPProcessExecutionSnapshot >> isStarted [ ^ started ]
{ #category : 'testing' }
CPProcessExecutionSnapshot >> isCompleted [ ^ completed ]
{ #category : 'accessing' }
CPProcessExecutionSnapshot >> pendingUserTaskWorkItems [ ^ pendingUserTaskWorkItems copy ]
{ #category : 'accessing' }
CPProcessExecutionSnapshot >> pendingExternalInvocations [ ^ pendingExternalInvocations copy ]
