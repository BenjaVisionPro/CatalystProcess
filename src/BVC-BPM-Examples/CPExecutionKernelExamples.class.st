Class {
	#name : 'CPExecutionKernelExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples',
	#package : 'BVC-BPM-Examples'
}

{ #category : 'examples' }
CPExecutionKernelExamples >> readyActivityExecution [
	<gtExample>
	| execution |
	execution := CPActivityExecution new.
	self assert: execution isReady.
	self assert: execution isFinal not.
	^ execution
]

{ #category : 'examples' }
CPExecutionKernelExamples >> completedActivityExecution [
	<gtExample>
	| execution |
	execution := self readyActivityExecution.
	execution activate.
	execution beginCompletion.
	execution complete.
	self assert: execution isCompleted.
	self assert: execution isFinal.
	^ execution
]

{ #category : 'examples' }
CPExecutionKernelExamples >> nestedExecutionScope [
	<gtExample>
	| process activity child |
	process := CPProcessExecution new.
	activity := CPActivityExecution new.
	process addActivityExecution: activity.
	child := CPExecutionScope new owningActivity: activity; yourself.
	process addChildScope: child.
	activity subScope: child.
	self assert: child parentScope == process.
	self assert: activity scope == process.
	self assert: activity subScope == child.
	^ process
]

{ #category : 'examples' }
CPExecutionKernelExamples >> acceptedOccurrence [
	<gtExample>
	| scope occurrence |
	scope := CPExecutionScope new.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: 'message-42';
		payload: (Dictionary new at: #value put: 42; yourself);
		yourself.
	scope acceptOccurrence: occurrence.
	self assert: (scope hasAcceptedOccurrenceIdentifiedBy: 'message-42').
	self assert: scope acceptedOccurrences size equals: 1.
	^ scope
]
