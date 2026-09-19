Class {
	#name : 'CPProcessExecution',
	#superclass : 'CPExecutionScope',
	#instVars : [
		'deployment',
		'tenant',
		'startedBy'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

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
