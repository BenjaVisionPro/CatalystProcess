Class {
	#name : 'CPQueryProcessExecutionWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'processExecution' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPQueryProcessExecutionWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPQueryProcessExecutionWorkUnit class >> processExecution: aCPProcessExecution [
	^ self new processExecution: aCPProcessExecution; yourself
]

{ #category : 'accessing' }
CPQueryProcessExecutionWorkUnit >> processExecution [ ^ processExecution ]

{ #category : 'accessing' }
CPQueryProcessExecutionWorkUnit >> processExecution: anObject [ processExecution := anObject ]

{ #category : 'running' }
CPQueryProcessExecutionWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service queryProcessExecutionWorkUnit: self
]
