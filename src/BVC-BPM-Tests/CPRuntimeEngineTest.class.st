Class {
	#name : 'CPRuntimeEngineTest',
	#superclass : 'TestCase',
	#category : 'BVC-BPM-Tests',
	#package : 'BVC-BPM-Tests'
}

{ #category : 'tests' }
CPRuntimeEngineTest >> testStartSimpleUserTaskProcessCreatesWorkItem [
	| instance |
	instance := CPProcessExamples new startedSimpleUserTaskInstance.
	self assert: instance workItems size equals: 1.
	self assert: instance workItems first isAvailable
]

{ #category : 'tests' }
CPRuntimeEngineTest >> testCompleteWorkItemAdvancesToEnd [
	| instance |
	instance := CPProcessExamples new completedSimpleUserTaskInstance.
	self assert: instance isCompleted
]

{ #category : 'tests' }
CPRuntimeEngineTest >> testCompletingProcessAppendsAuditEvents [
	| instance |
	instance := CPProcessExamples new completedSimpleUserTaskInstance.
	self assert: instance auditEvents notEmpty
]

