Class {
	#name : 'CPTerminateProcessWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'processExecution' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPTerminateProcessWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPTerminateProcessWorkUnit class >> processExecution: aCPProcessExecution [
	^ self new processExecution: aCPProcessExecution; yourself
]

{ #category : 'accessing' }
CPTerminateProcessWorkUnit >> processExecution [ ^ processExecution ]

{ #category : 'accessing' }
CPTerminateProcessWorkUnit >> processExecution: aCPProcessExecution [ processExecution := aCPProcessExecution ]

{ #category : 'running' }
CPTerminateProcessWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service terminateProcessWorkUnit: self
]
