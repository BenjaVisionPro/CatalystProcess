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
CPExecutionKernelExamples >> processExecutionOwnsActivityExecution [
	<gtExample>
	| processDefinition activityDefinition process activity |
	processDefinition := CPProcess new identifier: 'process'; yourself.
	activityDefinition := CPTask new identifier: 'task'; yourself.
	process := CPProcessExecution for: processDefinition.
	activity := process createActivityExecutionFor: activityDefinition.
	self assert: process definition == processDefinition.
	self assert: activity definition == activityDefinition.
	self assert: activity scope == process.
	self assert: (process activityExecutions includes: activity).
	^ process
]

{ #category : 'examples' }
CPExecutionKernelExamples >> activityExecutionOwnsNestedScope [
	<gtExample>
	| processDefinition subProcessDefinition process activity child |
	processDefinition := CPProcess new identifier: 'process'; yourself.
	subProcessDefinition := CPSubProcess new identifier: 'subProcess'; yourself.
	process := CPProcessExecution for: processDefinition.
	activity := process createActivityExecutionFor: subProcessDefinition.
	child := activity createSubScopeFor: subProcessDefinition.
	self assert: child definition == subProcessDefinition.
	self assert: child parentScope == process.
	self assert: child owningActivity == activity.
	self assert: activity subScope == child.
	self assert: (process childScopes includes: child).
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

{ #category : 'examples - control flow' }
CPExecutionKernelExamples >> activityConsumesIncomingControlFlow [
	<gtExample>
	| process source target flow execution sourceExecution targetExecution activation |
	process := CPProcess new identifier: 'process'; yourself.
	source := CPTask new identifier: 'source'; yourself.
	target := CPTask new identifier: 'target'; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: source; targetRef: target; yourself.
	execution := CPProcessExecution for: process.
	sourceExecution := execution createActivityExecutionFor: source.
	sourceExecution activate; beginCompletion; complete.
	activation := execution activateSequenceFlow: flow producedBy: sourceExecution.
	self assert: (execution canReadyActivity: target).
	targetExecution := execution readyActivityExecutionFor: target.
	self assert: targetExecution isReady.
	self assert: activation isAvailable not.
	self assert: activation consumedBy == targetExecution.
	self assert: targetExecution consumedFlowActivations size equals: 1.
	^ execution
]

{ #category : 'examples - control flow' }
CPExecutionKernelExamples >> completedActivityProducesOutgoingControlFlow [
	<gtExample>
	| process source target flow execution activity |
	process := CPProcess new identifier: 'process'; yourself.
	source := CPTask new identifier: 'source'; yourself.
	target := CPTask new identifier: 'target'; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: source; targetRef: target; yourself.
	execution := CPProcessExecution for: process.
	activity := execution createActivityExecutionFor: source.
	activity activate; beginCompletion; complete.
	execution produceOutgoingControlFor: activity.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	self assert: (execution canReadyActivity: target).
	^ execution
]

{ #category : 'examples - control flow' }
CPExecutionKernelExamples >> activityStartQuantityConsumesRequiredControl [
	<gtExample>
	| process source target flow execution sourceExecution targetExecution |
	process := CPProcess new identifier: 'process'; yourself.
	source := CPTask new identifier: 'source'; yourself.
	target := CPTask new identifier: 'target'; startQuantity: 2; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: source; targetRef: target; yourself.
	execution := CPProcessExecution for: process.
	sourceExecution := execution createActivityExecutionFor: source.
	execution activateSequenceFlow: flow producedBy: sourceExecution.
	self assert: (execution canReadyActivity: target) not.
	execution activateSequenceFlow: flow producedBy: sourceExecution.
	self assert: (execution canReadyActivity: target).
	targetExecution := execution readyActivityExecutionFor: target.
	self assert: targetExecution consumedFlowActivations size equals: 2.
	^ execution
]

{ #category : 'examples - control flow' }
CPExecutionKernelExamples >> completionQuantityProducesRequiredControl [
	<gtExample>
	| process source target flow execution sourceExecution |
	process := CPProcess new identifier: 'process'; yourself.
	source := CPTask new identifier: 'source'; completionQuantity: 2; yourself.
	target := CPTask new identifier: 'target'; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: source; targetRef: target; yourself.
	execution := CPProcessExecution for: process.
	sourceExecution := execution createActivityExecutionFor: source.
	sourceExecution activate; beginCompletion; complete.
	execution produceOutgoingControlFor: sourceExecution.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 2.
	^ execution
]
