Class {
	#name : 'CPExecutionKernelExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples',
	#package : 'BVC-BPM-Examples'
}


{ #category : 'private' }
CPExecutionKernelExamples >> executionFor: aProcess [
	^ CPProcessExecution
		for: aProcess
		environment: CPExampleExecutionEnvironment new
]
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
	process := self executionFor: processDefinition.
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
	process := self executionFor: processDefinition.
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
	| process execution occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	execution := self executionFor: process.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: 'message-42';
		payload: (Dictionary new at: #value put: 42; yourself);
		yourself.
	execution acceptOccurrence: occurrence.
	self assert: (execution hasAcceptedOccurrenceIdentifiedBy: 'message-42').
	self assert: execution acceptedOccurrences size equals: 1.
	^ execution
]

{ #category : 'examples - control flow' }
CPExecutionKernelExamples >> activityConsumesIncomingControlFlow [
	<gtExample>
	| process source target flow execution sourceExecution targetExecution activation |
	process := CPProcess new identifier: 'process'; yourself.
	source := CPTask new identifier: 'source'; yourself.
	target := CPTask new identifier: 'target'; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: source; targetRef: target; yourself.
	execution := self executionFor: process.
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
	execution := self executionFor: process.
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
	execution := self executionFor: process.
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
	execution := self executionFor: process.
	sourceExecution := execution createActivityExecutionFor: source.
	sourceExecution activate; beginCompletion; complete.
	execution produceOutgoingControlFor: sourceExecution.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 2.
	^ execution
]

{ #category : 'examples - gateways' }
CPExecutionKernelExamples >> parallelGatewaySynchronizesIncomingControl [
	<gtExample>
	| process left right gateway after first second out execution leftExecution rightExecution gatewayExecution |
	process := CPProcess new identifier: 'process'; yourself.
	left := CPTask new identifier: 'left'; yourself.
	right := CPTask new identifier: 'right'; yourself.
	gateway := CPParallelGateway new identifier: 'join'; yourself.
	after := CPTask new identifier: 'after'; yourself.
	first := CPSequenceFlow new identifier: 'first'; sourceRef: left; targetRef: gateway; yourself.
	second := CPSequenceFlow new identifier: 'second'; sourceRef: right; targetRef: gateway; yourself.
	out := CPSequenceFlow new identifier: 'out'; sourceRef: gateway; targetRef: after; yourself.
	execution := self executionFor: process.
	leftExecution := execution createActivityExecutionFor: left.
	rightExecution := execution createActivityExecutionFor: right.
	execution activateSequenceFlow: first producedBy: leftExecution.
	self assert: (execution canExecuteParallelGateway: gateway) not.
	execution activateSequenceFlow: second producedBy: rightExecution.
	self assert: (execution canExecuteParallelGateway: gateway).
	gatewayExecution := execution executeParallelGateway: gateway.
	self assert: gatewayExecution consumedFlowActivations size equals: 2.
	self assert: gatewayExecution producedFlowActivations size equals: 1.
	self assert: (execution availableFlowActivationsOn: out) size equals: 1.
	^ execution
]

{ #category : 'examples - gateways' }
CPExecutionKernelExamples >> parallelGatewayLeavesExcessIncomingControl [
	<gtExample>
	| process left right gateway after first second out execution leftExecution rightExecution |
	process := CPProcess new identifier: 'process'; yourself.
	left := CPTask new identifier: 'left'; yourself.
	right := CPTask new identifier: 'right'; yourself.
	gateway := CPParallelGateway new identifier: 'join'; yourself.
	after := CPTask new identifier: 'after'; yourself.
	first := CPSequenceFlow new identifier: 'first'; sourceRef: left; targetRef: gateway; yourself.
	second := CPSequenceFlow new identifier: 'second'; sourceRef: right; targetRef: gateway; yourself.
	out := CPSequenceFlow new identifier: 'out'; sourceRef: gateway; targetRef: after; yourself.
	execution := self executionFor: process.
	leftExecution := execution createActivityExecutionFor: left.
	rightExecution := execution createActivityExecutionFor: right.
	execution activateSequenceFlow: first producedBy: leftExecution.
	execution activateSequenceFlow: first producedBy: leftExecution.
	execution activateSequenceFlow: second producedBy: rightExecution.
	execution executeParallelGateway: gateway.
	self assert: (execution availableFlowActivationsOn: first) size equals: 1.
	self assert: (execution availableFlowActivationsOn: second) isEmpty.
	self assert: (execution availableFlowActivationsOn: out) size equals: 1.
	^ execution
]

{ #category : 'examples - gateways' }
CPExecutionKernelExamples >> exclusiveGatewaySelectsFirstTrueCondition [
	<gtExample>
	| process before gateway firstTarget secondTarget defaultTarget incoming first second fallback firstCondition secondCondition execution producer activation gatewayExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	gateway := CPExclusiveGateway new identifier: 'choice'; yourself.
	firstTarget := CPTask new identifier: 'firstTarget'; yourself.
	secondTarget := CPTask new identifier: 'secondTarget'; yourself.
	defaultTarget := CPTask new identifier: 'defaultTarget'; yourself.
	firstCondition := CPFormalExpression new identifier: 'firstCondition'; body: 'first'; yourself.
	secondCondition := CPFormalExpression new identifier: 'secondCondition'; body: 'second'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: gateway; yourself.
	first := CPSequenceFlow new identifier: 'first'; sourceRef: gateway; targetRef: firstTarget; conditionExpression: firstCondition; yourself.
	second := CPSequenceFlow new identifier: 'second'; sourceRef: gateway; targetRef: secondTarget; conditionExpression: secondCondition; yourself.
	fallback := CPSequenceFlow new identifier: 'fallback'; sourceRef: gateway; targetRef: defaultTarget; yourself.
	gateway default: fallback.
	execution := self executionFor: process.
	execution environment
		expression: firstCondition evaluatesTo: true;
		expression: secondCondition evaluatesTo: true.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	gatewayExecution := execution
		executeExclusiveGateway: gateway
		consuming: activation.
	self assert: gatewayExecution producedFlowActivations first definition == first.
	self assert: (execution availableFlowActivationsOn: first) size equals: 1.
	self assert: (execution availableFlowActivationsOn: second) isEmpty.
	self assert: (execution availableFlowActivationsOn: fallback) isEmpty.
	^ execution
]

{ #category : 'examples - gateways' }
CPExecutionKernelExamples >> exclusiveGatewayUsesDefaultWhenConditionsAreFalse [
	<gtExample>
	| process before gateway target fallbackTarget incoming conditional fallback condition execution producer activation gatewayExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	gateway := CPExclusiveGateway new identifier: 'choice'; yourself.
	target := CPTask new identifier: 'target'; yourself.
	fallbackTarget := CPTask new identifier: 'fallbackTarget'; yourself.
	condition := CPFormalExpression new identifier: 'condition'; body: 'false'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: gateway; yourself.
	conditional := CPSequenceFlow new identifier: 'conditional'; sourceRef: gateway; targetRef: target; conditionExpression: condition; yourself.
	fallback := CPSequenceFlow new identifier: 'fallback'; sourceRef: gateway; targetRef: fallbackTarget; yourself.
	gateway default: fallback.
	execution := self executionFor: process.
	execution environment expression: condition evaluatesTo: false.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	gatewayExecution := execution
		executeExclusiveGateway: gateway
		consuming: activation.
	self assert: gatewayExecution producedFlowActivations first definition == fallback.
	self assert: (execution availableFlowActivationsOn: conditional) isEmpty.
	self assert: (execution availableFlowActivationsOn: fallback) size equals: 1.
	^ execution
]

{ #category : 'examples - gateways' }
CPExecutionKernelExamples >> eventBasedGatewayFirstOccurrenceWins [
	<gtExample>
	| process before gateway message timer afterMessage afterTimer incoming messageFlow timerFlow execution producer activation gatewayExecution messageSubscription occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	gateway := CPEventBasedGateway new identifier: 'wait'; yourself.
	message := CPMessageCatchIntermediateEvent new identifier: 'message'; yourself.
	timer := CPTimerIntermediateEvent new identifier: 'timer'; yourself.
	afterMessage := CPTask new identifier: 'afterMessage'; yourself.
	afterTimer := CPTask new identifier: 'afterTimer'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: gateway; yourself.
	messageFlow := CPSequenceFlow new identifier: 'messageFlow'; sourceRef: gateway; targetRef: message; yourself.
	timerFlow := CPSequenceFlow new identifier: 'timerFlow'; sourceRef: gateway; targetRef: timer; yourself.
	CPSequenceFlow new identifier: 'afterMessageFlow'; sourceRef: message; targetRef: afterMessage; yourself.
	CPSequenceFlow new identifier: 'afterTimerFlow'; sourceRef: timer; targetRef: afterTimer; yourself.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	gatewayExecution := execution beginExclusiveEventBasedGateway: gateway consuming: activation.
	self assert: gatewayExecution subscriptions size equals: 2.
	self assert: gatewayExecution isWaiting.
	messageSubscription := gatewayExecution subscriptions detect: [ :each | each sequenceFlow == messageFlow ].
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #message1; definition: message; yourself.
	gatewayExecution acceptOccurrence: occurrence for: messageSubscription.
	self assert: messageSubscription isTriggered.
	self assert: (gatewayExecution subscriptions detect: [ :each | each sequenceFlow == timerFlow ]) isWithdrawn.
	self assert: gatewayExecution isResolved.
	self assert: (execution hasAcceptedOccurrenceIdentifiedBy: #message1).
	^ gatewayExecution
]

{ #category : 'examples - execution' }
CPExecutionKernelExamples >> startEventProducesOutgoingControl [
	| processDefinition startEvent task flow process eventExecution |
	processDefinition := CPProcess new identifier: 'process'; yourself.
	startEvent := CPNoneStartEvent new identifier: 'start'; yourself.
	task := CPTask new identifier: 'task'; yourself.
	flow := CPSequenceFlow new
		identifier: 'startToTask';
		sourceRef: startEvent;
		targetRef: task;
		yourself.
	process := self executionFor: processDefinition.
	eventExecution := process executeStartEvent: startEvent occurrence: nil.
	self assert: eventExecution producedFlowActivations size equals: 1.
	self assert: eventExecution producedFlowActivations first definition == flow.
	self assert: eventExecution producedFlowActivations first isAvailable
]

{ #category : 'examples - execution' }
CPExecutionKernelExamples >> endEventConsumesIncomingControl [
	| processDefinition task endEvent flow process activation eventExecution |
	processDefinition := CPProcess new identifier: 'process'; yourself.
	task := CPTask new identifier: 'task'; yourself.
	endEvent := CPNoneEndEvent new identifier: 'end'; yourself.
	flow := CPSequenceFlow new
		identifier: 'taskToEnd';
		sourceRef: task;
		targetRef: endEvent;
		yourself.
	process := self executionFor: processDefinition.
	activation := process activateSequenceFlow: flow producedBy: nil.
	eventExecution := process executeEndEvent: endEvent consuming: activation.
	self assert: eventExecution consumedFlowActivation == activation.
	self assert: activation isAvailable not.
	self assert: eventExecution producedFlowActivations isEmpty
]

{ #category : 'examples - gateways' }
CPExecutionKernelExamples >> inclusiveGatewaySelectsEveryTrueBranch [
	<gtExample>
	| process before gateway firstTarget secondTarget fallbackTarget incoming first second fallback firstCondition secondCondition execution producer activation gatewayExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	gateway := CPInclusiveGateway new identifier: 'choice'; yourself.
	firstTarget := CPTask new identifier: 'firstTarget'; yourself.
	secondTarget := CPTask new identifier: 'secondTarget'; yourself.
	fallbackTarget := CPTask new identifier: 'fallbackTarget'; yourself.
	firstCondition := CPFormalExpression new identifier: 'firstCondition'; body: 'first'; yourself.
	secondCondition := CPFormalExpression new identifier: 'secondCondition'; body: 'second'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: gateway; yourself.
	first := CPSequenceFlow new identifier: 'first'; sourceRef: gateway; targetRef: firstTarget; conditionExpression: firstCondition; yourself.
	second := CPSequenceFlow new identifier: 'second'; sourceRef: gateway; targetRef: secondTarget; conditionExpression: secondCondition; yourself.
	fallback := CPSequenceFlow new identifier: 'fallback'; sourceRef: gateway; targetRef: fallbackTarget; yourself.
	gateway default: fallback.
	execution := self executionFor: process.
	execution environment
		expression: firstCondition evaluatesTo: true;
		expression: secondCondition evaluatesTo: true.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	gatewayExecution := execution executeInclusiveGateway: gateway.
	self assert: gatewayExecution consumedFlowActivations size equals: 1.
	self assert: gatewayExecution producedFlowActivations size equals: 2.
	self assert: (execution availableFlowActivationsOn: first) size equals: 1.
	self assert: (execution availableFlowActivationsOn: second) size equals: 1.
	self assert: (execution availableFlowActivationsOn: fallback) isEmpty.
	^ execution
]

{ #category : 'examples - gateways' }
CPExecutionKernelExamples >> inclusiveGatewayWaitsForReachableIncomingBranch [
	<gtExample>
	| process left upstream right gateway after leftFlow upstreamFlow rightFlow out execution leftExecution upstreamExecution |
	process := CPProcess new identifier: 'process'; yourself.
	left := CPTask new identifier: 'left'; yourself.
	upstream := CPTask new identifier: 'upstream'; yourself.
	right := CPTask new identifier: 'right'; yourself.
	gateway := CPInclusiveGateway new identifier: 'join'; yourself.
	after := CPTask new identifier: 'after'; yourself.
	leftFlow := CPSequenceFlow new identifier: 'leftFlow'; sourceRef: left; targetRef: gateway; yourself.
	upstreamFlow := CPSequenceFlow new identifier: 'upstreamFlow'; sourceRef: upstream; targetRef: right; yourself.
	rightFlow := CPSequenceFlow new identifier: 'rightFlow'; sourceRef: right; targetRef: gateway; yourself.
	out := CPSequenceFlow new identifier: 'out'; sourceRef: gateway; targetRef: after; yourself.
	execution := self executionFor: process.
	leftExecution := execution createActivityExecutionFor: left.
	upstreamExecution := execution createActivityExecutionFor: upstream.
	execution activateSequenceFlow: leftFlow producedBy: leftExecution.
	execution activateSequenceFlow: upstreamFlow producedBy: upstreamExecution.
	self assert: (execution canExecuteInclusiveGateway: gateway) not.
	(execution availableFlowActivationsOn: upstreamFlow) first consumeBy: (execution createActivityExecutionFor: right).
	execution activateSequenceFlow: rightFlow producedBy: (execution activityExecutions last).
	self assert: (execution canExecuteInclusiveGateway: gateway).
	^ execution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> intermediateCatchEventWaitsThenContinues [
	<gtExample>
	| process before event after incoming outgoing execution producer activation eventExecution occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	event := CPMessageCatchIntermediateEvent new identifier: 'message'; yourself.
	after := CPTask new identifier: 'after'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: event; yourself.
	outgoing := CPSequenceFlow new identifier: 'outgoing'; sourceRef: event; targetRef: after; yourself.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	eventExecution := execution beginIntermediateCatchEvent: event consuming: activation.
	self assert: eventExecution isWaiting.
	self assert: activation isAvailable not.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #message1; definition: event; yourself.
	execution triggerIntermediateCatchEventExecution: eventExecution with: occurrence.
	self assert: eventExecution isTriggered.
	self assert: eventExecution occurrence == occurrence.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ eventExecution
]

{ #category : 'examples - gateways' }
CPExecutionKernelExamples >> eventBasedGatewayWinningEventContinuesControlFlow [
	<gtExample>
	| process before gateway message timer afterMessage afterTimer incoming messageFlow timerFlow afterMessageFlow execution producer activation gatewayExecution messageSubscription occurrence eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	gateway := CPEventBasedGateway new identifier: 'wait'; yourself.
	message := CPMessageCatchIntermediateEvent new identifier: 'message'; yourself.
	timer := CPTimerIntermediateEvent new identifier: 'timer'; yourself.
	afterMessage := CPTask new identifier: 'afterMessage'; yourself.
	afterTimer := CPTask new identifier: 'afterTimer'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: gateway; yourself.
	messageFlow := CPSequenceFlow new identifier: 'messageFlow'; sourceRef: gateway; targetRef: message; yourself.
	timerFlow := CPSequenceFlow new identifier: 'timerFlow'; sourceRef: gateway; targetRef: timer; yourself.
	afterMessageFlow := CPSequenceFlow new identifier: 'afterMessageFlow'; sourceRef: message; targetRef: afterMessage; yourself.
	CPSequenceFlow new identifier: 'afterTimerFlow'; sourceRef: timer; targetRef: afterTimer; yourself.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	gatewayExecution := execution beginExclusiveEventBasedGateway: gateway consuming: activation.
	messageSubscription := gatewayExecution subscriptions detect: [ :each | each sequenceFlow == messageFlow ].
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #message1; definition: message; yourself.
	eventExecution := execution
		triggerEventBasedGatewayExecution: gatewayExecution
		subscription: messageSubscription
		with: occurrence.
	self assert: eventExecution isTriggered.
	self assert: (execution availableFlowActivationsOn: afterMessageFlow) size equals: 1.
	self assert: (gatewayExecution subscriptions detect: [ :each | each sequenceFlow == timerFlow ]) isWithdrawn.
	^ eventExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> intermediateThrowEventCompletesThenContinues [
	<gtExample>
	| process before event after incoming outgoing execution producer activation eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	event := CPMessageThrowIntermediateEvent new identifier: 'message'; yourself.
	after := CPTask new identifier: 'after'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: event; yourself.
	outgoing := CPSequenceFlow new identifier: 'outgoing'; sourceRef: event; targetRef: after; yourself.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	eventExecution := execution beginIntermediateThrowEvent: event consuming: activation.
	self assert: eventExecution isPending.
	self assert: activation isAvailable not.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	execution completeIntermediateThrowEventExecution: eventExecution.
	self assert: eventExecution isCompleted.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ eventExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> interruptingBoundaryEventTerminatesActivityAndContinues [
	<gtExample>
	| process activity boundary after flow execution activityExecution boundaryExecution occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	activity := CPTask new identifier: 'activity'; yourself.
	boundary := CPBoundaryEvent new identifier: 'timeout'; attachedToRef: activity; cancelActivity: true; yourself.
	after := CPTask new identifier: 'after'; yourself.
	flow := CPSequenceFlow new identifier: 'timeoutFlow'; sourceRef: boundary; targetRef: after; yourself.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	boundaryExecution := execution beginBoundaryEvent: boundary attachedTo: activityExecution.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #timeout1; definition: boundary; yourself.
	execution triggerBoundaryEventExecution: boundaryExecution with: occurrence.
	self assert: activityExecution state class equals: CPActivityTerminatedState.
	self assert: boundaryExecution isTriggered.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	^ boundaryExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> nonInterruptingBoundaryEventLeavesActivityActive [
	<gtExample>
	| process activity boundary after flow execution activityExecution boundaryExecution occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	activity := CPTask new identifier: 'activity'; yourself.
	boundary := CPBoundaryEvent new identifier: 'notice'; attachedToRef: activity; cancelActivity: false; yourself.
	after := CPTask new identifier: 'after'; yourself.
	flow := CPSequenceFlow new identifier: 'noticeFlow'; sourceRef: boundary; targetRef: after; yourself.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	boundaryExecution := execution beginBoundaryEvent: boundary attachedTo: activityExecution.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #notice1; definition: boundary; yourself.
	execution triggerBoundaryEventExecution: boundaryExecution with: occurrence.
	self assert: activityExecution isActive.
	self assert: boundaryExecution isTriggered.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	^ boundaryExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> errorBoundaryEventFailsActivityAndContinues [
	<gtExample>
	| process activity boundary errorDefinition after flow execution activityExecution boundaryExecution occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	activity := CPTask new identifier: 'activity'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'errorDefinition'; yourself.
	boundary := CPBoundaryEvent new identifier: 'error'; attachedToRef: activity; cancelActivity: true; yourself.
	boundary eventDefinitions add: errorDefinition.
	after := CPTask new identifier: 'after'; yourself.
	flow := CPSequenceFlow new identifier: 'errorFlow'; sourceRef: boundary; targetRef: after; yourself.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	boundaryExecution := execution beginBoundaryEvent: boundary attachedTo: activityExecution.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #error1; definition: boundary; yourself.
	execution triggerBoundaryEventExecution: boundaryExecution with: occurrence.
	self assert: activityExecution state class equals: CPActivityFailedState.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	^ boundaryExecution
]

{ #category : 'examples - sub-process' }
CPExecutionKernelExamples >> subProcessCreatesOwnedExecutionScope [
	<gtExample>
	| process subProcess start inner flow execution activation subProcessExecution |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	inner := CPTask new identifier: 'inner'; yourself.
	flow := CPSequenceFlow new identifier: 'startToInner'; sourceRef: start; targetRef: inner; yourself.
	subProcess addFlowElement: start.
	subProcess addFlowElement: inner.
	subProcess addFlowElement: flow.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subProcessExecution.
	self assert: subProcessExecution isActive.
	self assert: subProcessExecution subScope parentScope == execution.
	self assert: subProcessExecution subScope owningActivity == subProcessExecution.
	activation := (subProcessExecution subScope availableFlowActivationsOn: flow) first.
	self assert: activation isAvailable.
	^ subProcessExecution
]

{ #category : 'examples - sub-process' }
CPExecutionKernelExamples >> completedSubProcessContinuesParentControlFlow [
	<gtExample>
	| process subProcess start end innerFlow after outerFlow execution subProcessExecution childScope endActivation |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	end := CPNoneEndEvent new identifier: 'end'; yourself.
	innerFlow := CPSequenceFlow new identifier: 'inner'; sourceRef: start; targetRef: end; yourself.
	subProcess addFlowElement: start.
	subProcess addFlowElement: end.
	subProcess addFlowElement: innerFlow.
	after := CPTask new identifier: 'after'; yourself.
	outerFlow := CPSequenceFlow new identifier: 'afterSubProcess'; sourceRef: subProcess; targetRef: after; yourself.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subProcessExecution.
	childScope := subProcessExecution subScope.
	endActivation := (childScope availableFlowActivationsOn: innerFlow) first.
	childScope executeEndEvent: end consuming: endActivation.
	execution completeSubProcessActivity: subProcessExecution.
	self assert: subProcessExecution isCompleted.
	self assert: (execution availableFlowActivationsOn: outerFlow) size equals: 1.
	^ subProcessExecution
]

{ #category : 'examples - call activity' }
CPExecutionKernelExamples >> callActivityCreatesOwnedCalledProcessScope [
	<gtExample>
	| process calledProcess start end innerFlow call execution callExecution childScope |
	process := CPProcess new identifier: 'caller'; yourself.
	calledProcess := CPProcess new identifier: 'called'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	end := CPNoneEndEvent new identifier: 'end'; yourself.
	innerFlow := CPSequenceFlow new identifier: 'calledFlow'; sourceRef: start; targetRef: end; yourself.
	calledProcess addFlowElement: start.
	calledProcess addFlowElement: end.
	calledProcess addFlowElement: innerFlow.
	call := CPCallActivity new identifier: 'call'; calledElement: calledProcess; yourself.
	execution := self executionFor: process.
	callExecution := execution createActivityExecutionFor: call.
	execution environment callableElement: calledProcess resolvesTo: calledProcess.
	execution activateCallActivityExecution: callExecution.
	childScope := callExecution subScope.
	self assert: callExecution isActive.
	self assert: childScope definition == calledProcess.
	self assert: childScope parentScope == execution.
	self assert: childScope owningActivity == callExecution.
	self assert: (childScope availableFlowActivationsOn: innerFlow) size equals: 1.
	^ callExecution
]

{ #category : 'examples - call activity' }
CPExecutionKernelExamples >> completedCallActivityContinuesCallerControlFlow [
	<gtExample>
	| process calledProcess start end innerFlow call after outerFlow execution callExecution childScope endActivation |
	process := CPProcess new identifier: 'caller'; yourself.
	calledProcess := CPProcess new identifier: 'called'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	end := CPNoneEndEvent new identifier: 'end'; yourself.
	innerFlow := CPSequenceFlow new identifier: 'calledFlow'; sourceRef: start; targetRef: end; yourself.
	calledProcess addFlowElement: start.
	calledProcess addFlowElement: end.
	calledProcess addFlowElement: innerFlow.
	call := CPCallActivity new identifier: 'call'; calledElement: calledProcess; yourself.
	after := CPTask new identifier: 'after'; yourself.
	outerFlow := CPSequenceFlow new identifier: 'afterCall'; sourceRef: call; targetRef: after; yourself.
	self assert: (call outgoing occurrencesOf: outerFlow) equals: 1.
	self assert: (after incoming occurrencesOf: outerFlow) equals: 1.
	execution := self executionFor: process.
	callExecution := execution createActivityExecutionFor: call.
	execution environment callableElement: calledProcess resolvesTo: calledProcess.
	execution activateCallActivityExecution: callExecution.
	childScope := callExecution subScope.
	endActivation := (childScope availableFlowActivationsOn: innerFlow) first.
	childScope executeEndEvent: end consuming: endActivation.
	execution completeCallActivity: callExecution.
	self assert: callExecution isCompleted.
	self assert: (execution availableFlowActivationsOn: outerFlow) size equals: 1.
	^ callExecution
]

{ #category : 'examples - environment' }
CPExecutionKernelExamples >> nestedExecutionScopeUsesProcessEnvironment [
	<gtExample>
	| processDefinition subProcessDefinition execution activity child |
	processDefinition := CPProcess new identifier: 'process'; yourself.
	subProcessDefinition := CPSubProcess new identifier: 'subProcess'; yourself.
	execution := self executionFor: processDefinition.
	activity := execution createActivityExecutionFor: subProcessDefinition.
	child := activity createSubScopeFor: subProcessDefinition.
	self assert: child environment == execution environment.
	^ child
]

{ #category : 'examples - environment' }
CPExecutionKernelExamples >> callActivityUsesResolvedCallableProcess [
	<gtExample>
	| caller logicalCallable resolvedProcess call execution callExecution |
	caller := CPProcess new identifier: 'caller'; yourself.
	logicalCallable := CPCallableElement new identifier: 'logicalCallable'; yourself.
	resolvedProcess := CPProcess new identifier: 'resolvedProcess'; yourself.
	call := CPCallActivity new
		identifier: 'call';
		calledElement: logicalCallable;
		yourself.
	execution := self executionFor: caller.
	execution environment
		callableElement: logicalCallable
		resolvesTo: resolvedProcess.
	callExecution := execution createActivityExecutionFor: call.
	execution activateCallActivityExecution: callExecution.
	self assert: callExecution subScope definition == resolvedProcess.
	self assert: callExecution subScope definition ~~ logicalCallable.
	^ callExecution
]

{ #category : 'examples - service task' }
CPExecutionKernelExamples >> serviceTaskResolvesOperationBeforeExternalWork [
	<gtExample>
	| process serviceTask operation implementation execution environment serviceExecution |
	process := CPProcess new identifier: 'process'; yourself.
	operation := CPOperation new identifier: 'chargeAccount'; yourself.
	serviceTask := CPServiceTask new
		identifier: 'charge';
		operationRef: operation;
		yourself.
	implementation := Object new.
	environment := CPExampleExecutionEnvironment new
		operation: operation resolvesTo: implementation;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	serviceExecution := execution createServiceTaskExecutionFor: serviceTask.
	execution activateServiceTaskExecution: serviceExecution.
	self assert: serviceExecution isActive.
	self assert: serviceExecution resolvedImplementation == implementation.
	self assert: serviceExecution isCompleted not.
	self assert: execution flowActivations isEmpty.
	^ serviceExecution
]


{ #category : 'examples - service task' }
CPExecutionKernelExamples >> serviceTaskExternalResultCompletesExactlyOnce [
	<gtExample>
	| process serviceTask operation implementation after outgoing execution environment serviceExecution invocation result |
	process := CPProcess new identifier: 'process'; yourself.
	operation := CPOperation new identifier: 'chargeAccount'; yourself.
	serviceTask := CPServiceTask new
		identifier: 'charge';
		operationRef: operation;
		yourself.
	after := CPTask new identifier: 'after'; yourself.
	outgoing := CPSequenceFlow new
		identifier: 'afterCharge';
		sourceRef: serviceTask;
		targetRef: after;
		yourself.
	process addFlowElement: serviceTask.
	process addFlowElement: after.
	process addFlowElement: outgoing.
	implementation := Object new.
	environment := CPExampleExecutionEnvironment new
		operation: operation resolvesTo: implementation;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	serviceExecution := execution createServiceTaskExecutionFor: serviceTask.
	execution activateServiceTaskExecution: serviceExecution.
	invocation := serviceExecution prepareExternalInvocationIdentifiedBy: #chargeInvocation1.
	self assert: invocation invocationIdentifier equals: #chargeInvocation1.
	self assert: invocation activityExecution == serviceExecution.
	self assert: invocation implementation == implementation.
	self assert: invocation isPending.
	self assert: execution flowActivations isEmpty.
	result := CPExecutionOccurrence new
		occurrenceIdentifier: #chargeResult1;
		definition: invocation;
		yourself.
	execution completeServiceTaskExecution: serviceExecution withResultOccurrence: result.
	self assert: invocation resultOccurrence == result.
	self assert: invocation isCompleted.
	self assert: serviceExecution isCompleted.
	self assert: (execution hasAcceptedOccurrenceIdentifiedBy: #chargeResult1).
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ serviceExecution
]

{ #category : 'examples - service task' }
CPExecutionKernelExamples >> serviceTaskRejectsDuplicateExternalResult [
	<gtExample>
	| serviceExecution execution invocation duplicateRejected |
	serviceExecution := self serviceTaskExternalResultCompletesExactlyOnce.
	execution := serviceExecution scope.
	invocation := serviceExecution externalInvocation.
	duplicateRejected := false.
	[ execution
		completeServiceTaskExecution: serviceExecution
		withResultOccurrence: (CPExecutionOccurrence new
			occurrenceIdentifier: invocation resultOccurrence occurrenceIdentifier;
			definition: invocation;
			yourself) ]
		on: Error
		do: [ :error | duplicateRejected := true ].
	self assert: duplicateRejected.
	self assert: serviceExecution isCompleted.
	self assert: invocation isCompleted.
	^ serviceExecution
]

{ #category : 'examples - receive task' }
CPExecutionKernelExamples >> receiveTaskWaitsForMessageOccurrence [
	<gtExample>
	| process message receive after outgoing execution receiveExecution occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	message := CPMessage new identifier: 'request'; yourself.
	receive := CPReceiveTask new
		identifier: 'receiveRequest';
		messageRef: message;
		yourself.
	after := CPTask new identifier: 'after'; yourself.
	outgoing := CPSequenceFlow new
		identifier: 'afterReceive';
		sourceRef: receive;
		targetRef: after;
		yourself.
	process addFlowElement: receive.
	process addFlowElement: after.
	process addFlowElement: outgoing.
	execution := self executionFor: process.
	receiveExecution := execution createReceiveTaskExecutionFor: receive.
	execution activateReceiveTaskExecution: receiveExecution.
	self assert: receiveExecution isWaitingForMessage.
	self assert: receiveExecution subscription isWaiting.
	self assert: (execution messageSubscriptions occurrencesOf: receiveExecution subscription) equals: 1.
	self assert: (execution waitingMessageSubscriptions occurrencesOf: receiveExecution subscription) equals: 1.
	self assert: receiveExecution isCompleted not.
	self assert: execution flowActivations isEmpty.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: #request1;
		definition: message;
		yourself.
	execution triggerReceiveTaskExecution: receiveExecution with: occurrence.
	self assert: receiveExecution receivedOccurrence == occurrence.
	self assert: receiveExecution isCompleted.
	self assert: (execution hasAcceptedOccurrenceIdentifiedBy: #request1).
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ receiveExecution
]

{ #category : 'examples - receive task' }
CPExecutionKernelExamples >> receiveTaskCreatesDurableMessageSubscription [
	<gtExample>
	| receiveExecution execution subscription |
	receiveExecution := self receiveTaskWaitsForMessageOccurrence.
	execution := receiveExecution scope.
	subscription := receiveExecution subscription.
	self assert: subscription notNil.
	self assert: subscription waitingExecution == receiveExecution.
	self assert: subscription message == receiveExecution definition messageRef.
	self assert: subscription isTriggered.
	self assert: subscription occurrence == receiveExecution receivedOccurrence.
	self assert: (execution messageSubscriptions occurrencesOf: subscription) equals: 1.
	self assert: (execution waitingMessageSubscriptions includes: subscription) not.
	^ subscription
]

{ #category : 'examples - receive task' }
CPExecutionKernelExamples >> receiveTaskRejectsDuplicateMessageOccurrence [
	<gtExample>
	| receiveExecution execution occurrence duplicateRejected |
	receiveExecution := self receiveTaskWaitsForMessageOccurrence.
	execution := receiveExecution scope.
	occurrence := receiveExecution receivedOccurrence.
	duplicateRejected := false.
	[ execution
		triggerReceiveTaskExecution: receiveExecution
		with: (CPExecutionOccurrence new
			occurrenceIdentifier: occurrence occurrenceIdentifier;
			definition: occurrence definition;
			yourself) ]
		on: Error
		do: [ :error | duplicateRejected := true ].
	self assert: duplicateRejected.
	self assert: receiveExecution isCompleted.
	^ receiveExecution
]


{ #category : 'examples - receive task' }
CPExecutionKernelExamples >> receiveTaskRejectsOccurrenceForDifferentMessage [
	<gtExample>
	| process expectedMessage otherMessage receive execution receiveExecution occurrence rejected |
	process := CPProcess new identifier: 'process'; yourself.
	expectedMessage := CPMessage new identifier: 'expected'; yourself.
	otherMessage := CPMessage new identifier: 'other'; yourself.
	receive := CPReceiveTask new
		identifier: 'receiveExpected';
		messageRef: expectedMessage;
		yourself.
	process addFlowElement: receive.
	execution := self executionFor: process.
	receiveExecution := execution createReceiveTaskExecutionFor: receive.
	execution activateReceiveTaskExecution: receiveExecution.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: #other1;
		definition: otherMessage;
		yourself.
	rejected := false.
	[ execution triggerReceiveTaskExecution: receiveExecution with: occurrence ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: receiveExecution isWaitingForMessage.
	self assert: receiveExecution receivedOccurrence isNil.
	self assert: (execution hasAcceptedOccurrenceIdentifiedBy: #other1) not.
	^ receiveExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> timerIntermediateCatchEventCreatesDurableSubscription [
	<gtExample>
	| process before timer after timerDefinition incoming outgoing execution producer activation eventExecution occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	timerDefinition := CPTimerEventDefinition new identifier: 'timerDefinition'; yourself.
	timer := CPTimerIntermediateEvent new
		identifier: 'timer';
		eventDefinitions: { timerDefinition } asOrderedCollection;
		yourself.
	after := CPTask new identifier: 'after'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: timer; yourself.
	outgoing := CPSequenceFlow new identifier: 'outgoing'; sourceRef: timer; targetRef: after; yourself.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	eventExecution := execution beginTimerIntermediateCatchEvent: timer consuming: activation.
	self assert: eventExecution isWaiting.
	self assert: eventExecution subscription isWaiting.
	self assert: eventExecution subscription timerDefinition == timerDefinition.
	self assert: (execution timerSubscriptions occurrencesOf: eventExecution subscription) equals: 1.
	self assert: (execution waitingTimerSubscriptions occurrencesOf: eventExecution subscription) equals: 1.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #timer1; definition: timerDefinition; yourself.
	execution triggerTimerIntermediateCatchEventExecution: eventExecution with: occurrence.
	self assert: eventExecution isTriggered.
	self assert: eventExecution subscription isTriggered.
	self assert: eventExecution subscription occurrence == occurrence.
	self assert: (execution timerSubscriptions occurrencesOf: eventExecution subscription) equals: 1.
	self assert: (execution waitingTimerSubscriptions includes: eventExecution subscription) not.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ eventExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> timerIntermediateCatchEventRejectsWrongOccurrence [
	<gtExample>
	| eventExecution execution otherTimer occurrence |
	eventExecution := self timerIntermediateCatchEventCreatesDurableSubscription.
	execution := eventExecution scope.
	otherTimer := CPTimerEventDefinition new identifier: 'otherTimer'; yourself.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #wrongTimer; definition: otherTimer; yourself.
	[ execution triggerTimerIntermediateCatchEventExecution: eventExecution with: occurrence ]
		on: Error
		do: [ :error | self assert: error messageText notEmpty ].
	self assert: (execution hasAcceptedOccurrenceIdentifiedBy: #wrongTimer) not.
	^ eventExecution
]


{ #category : 'examples - events' }
CPExecutionKernelExamples >> messageIntermediateCatchEventCreatesDurableSubscription [
	<gtExample>
	| process before messageEvent after message messageDefinition incoming outgoing execution producer activation eventExecution occurrence subscription |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	message := CPMessage new identifier: 'request'; yourself.
	messageDefinition := CPMessageEventDefinition new
		identifier: 'requestDefinition';
		messageRef: message;
		yourself.
	messageEvent := CPMessageCatchIntermediateEvent new
		identifier: 'waitForRequest';
		eventDefinitions: { messageDefinition } asOrderedCollection;
		yourself.
	after := CPTask new identifier: 'after'; yourself.
	incoming := CPSequenceFlow new identifier: 'toMessage'; sourceRef: before; targetRef: messageEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterMessage'; sourceRef: messageEvent; targetRef: after; yourself.
	process addFlowElement: before; addFlowElement: messageEvent; addFlowElement: after; addFlowElement: incoming; addFlowElement: outgoing.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	eventExecution := execution beginMessageIntermediateCatchEvent: messageEvent consuming: activation.
	subscription := eventExecution subscription.
	self assert: eventExecution isWaiting.
	self assert: subscription waitingExecution == eventExecution.
	self assert: subscription message == message.
	self assert: subscription isWaiting.
	self assert: (execution messageSubscriptions occurrencesOf: subscription) equals: 1.
	self assert: (execution waitingMessageSubscriptions occurrencesOf: subscription) equals: 1.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #requestMessage1; definition: message; yourself.
	execution triggerMessageIntermediateCatchEventExecution: eventExecution with: occurrence.
	self assert: eventExecution isTriggered.
	self assert: subscription isTriggered.
	self assert: subscription occurrence == occurrence.
	self assert: (execution hasAcceptedOccurrenceIdentifiedBy: #requestMessage1).
	self assert: (execution waitingMessageSubscriptions includes: subscription) not.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ eventExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> messageIntermediateCatchEventRejectsDifferentMessage [
	<gtExample>
	| eventExecution execution subscription otherMessage occurrence rejected |
	eventExecution := self messageIntermediateCatchEventCreatesDurableSubscription.
	execution := eventExecution scope.
	"Build a fresh waiting execution because the example above has already triggered its subscription."
	eventExecution := self messageIntermediateCatchEventWaitingExecution.
	execution := eventExecution scope.
	subscription := eventExecution subscription.
	otherMessage := CPMessage new identifier: 'other'; yourself.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #wrongMessage1; definition: otherMessage; yourself.
	rejected := false.
	[ execution triggerMessageIntermediateCatchEventExecution: eventExecution with: occurrence ]
		on: Error do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: eventExecution isWaiting.
	self assert: subscription isWaiting.
	self assert: (execution hasAcceptedOccurrenceIdentifiedBy: #wrongMessage1) not.
	^ eventExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> messageIntermediateCatchEventWaitingExecution [
	<gtExample>
	| process before messageEvent message messageDefinition incoming execution producer activation eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	message := CPMessage new identifier: 'expected'; yourself.
	messageDefinition := CPMessageEventDefinition new identifier: 'expectedDefinition'; messageRef: message; yourself.
	messageEvent := CPMessageCatchIntermediateEvent new identifier: 'wait'; eventDefinitions: { messageDefinition } asOrderedCollection; yourself.
	incoming := CPSequenceFlow new identifier: 'toWait'; sourceRef: before; targetRef: messageEvent; yourself.
	process addFlowElement: before; addFlowElement: messageEvent; addFlowElement: incoming.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	eventExecution := execution beginMessageIntermediateCatchEvent: messageEvent consuming: activation.
	self assert: eventExecution isWaiting.
	^ eventExecution
]


{ #category : 'examples - subscriptions' }
CPExecutionKernelExamples >> processExecutionDiscoversWaitingMessageSubscriptionsInChildScopes [
	<gtExample>
	| process subProcess ownerDefinition message receive execution ownerExecution childScope receiveExecution |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	ownerDefinition := CPTask new identifier: 'owner'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	receive := CPReceiveTask new identifier: 'receive'; messageRef: message; yourself.
	execution := self executionFor: process.
	ownerExecution := execution createActivityExecutionFor: ownerDefinition.
	childScope := ownerExecution createSubScopeFor: subProcess.
	receiveExecution := childScope createReceiveTaskExecutionFor: receive.
	childScope activateReceiveTaskExecution: receiveExecution.
	self assert: execution waitingMessageSubscriptions isEmpty.
	self assert: execution allWaitingMessageSubscriptions size equals: 1.
	self assert: execution allWaitingMessageSubscriptions first == receiveExecution subscription.
	self assert: (execution allWaitingMessageSubscriptionsFor: message) size equals: 1.
	^ execution
]

{ #category : 'examples - subscriptions' }
CPExecutionKernelExamples >> processExecutionDiscoversWaitingTimerSubscriptionsInChildScopes [
	<gtExample>
	| process subProcess ownerDefinition timer timerDefinition before incoming execution ownerExecution childScope producer activation eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	ownerDefinition := CPTask new identifier: 'owner'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	timerDefinition := CPTimerEventDefinition new identifier: 'timerDefinition'; yourself.
	timer := CPTimerIntermediateEvent new identifier: 'timer'; eventDefinitions: { timerDefinition } asOrderedCollection; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: timer; yourself.
	execution := self executionFor: process.
	ownerExecution := execution createActivityExecutionFor: ownerDefinition.
	childScope := ownerExecution createSubScopeFor: subProcess.
	producer := childScope createActivityExecutionFor: before.
	activation := childScope activateSequenceFlow: incoming producedBy: producer.
	eventExecution := childScope beginTimerIntermediateCatchEvent: timer consuming: activation.
	self assert: execution waitingTimerSubscriptions isEmpty.
	self assert: execution allWaitingTimerSubscriptions size equals: 1.
	self assert: execution allWaitingTimerSubscriptions first == eventExecution subscription.
	self assert: (execution allWaitingTimerSubscriptionsFor: timerDefinition) size equals: 1.
	^ execution
]


{ #category : 'examples - subscriptions' }
CPExecutionKernelExamples >> processExecutionDeliversMessageToUniqueWaitingSubscription [
	<gtExample>
	| process subProcess ownerDefinition message receive execution ownerExecution childScope receiveExecution occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	ownerDefinition := CPTask new identifier: 'owner'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	receive := CPReceiveTask new identifier: 'receive'; messageRef: message; yourself.
	execution := self executionFor: process.
	ownerExecution := execution createActivityExecutionFor: ownerDefinition.
	childScope := ownerExecution createSubScopeFor: subProcess.
	receiveExecution := childScope createReceiveTaskExecutionFor: receive.
	childScope activateReceiveTaskExecution: receiveExecution.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #messageDelivery1; definition: message; yourself.
	execution deliverMessageOccurrence: occurrence.
	self assert: receiveExecution isCompleted.
	self assert: receiveExecution receivedOccurrence == occurrence.
	self assert: receiveExecution subscription isTriggered.
	self assert: (childScope acceptedOccurrences identityIncludes: occurrence).
	self assert: execution allWaitingMessageSubscriptions isEmpty.
	^ execution
]

{ #category : 'examples - subscriptions' }
CPExecutionKernelExamples >> processExecutionRejectsAmbiguousMessageDeliveryWithoutCorrelation [
	<gtExample>
	| process message firstReceive secondReceive execution firstExecution secondExecution occurrence rejected |
	process := CPProcess new identifier: 'process'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	firstReceive := CPReceiveTask new identifier: 'firstReceive'; messageRef: message; yourself.
	secondReceive := CPReceiveTask new identifier: 'secondReceive'; messageRef: message; yourself.
	execution := self executionFor: process.
	firstExecution := execution createReceiveTaskExecutionFor: firstReceive.
	secondExecution := execution createReceiveTaskExecutionFor: secondReceive.
	execution activateReceiveTaskExecution: firstExecution.
	execution activateReceiveTaskExecution: secondExecution.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #ambiguousMessage1; definition: message; yourself.
	rejected := false.
	[ execution deliverMessageOccurrence: occurrence ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: firstExecution isWaitingForMessage.
	self assert: secondExecution isWaitingForMessage.
	self assert: firstExecution subscription isWaiting.
	self assert: secondExecution subscription isWaiting.
	self assert: (execution acceptedOccurrences identityIncludes: occurrence) not.
	^ execution
]


{ #category : 'examples - subscriptions' }
CPExecutionKernelExamples >> timerSubscriptionDeliversOccurrenceToOwningEventExecution [
	<gtExample>
	| process before timerDefinition timer outgoing after execution producer activation eventExecution occurrence subscription |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	timerDefinition := CPTimerEventDefinition new identifier: 'timerDefinition'; yourself.
	timer := CPTimerIntermediateEvent new identifier: 'timer'; eventDefinitions: { timerDefinition } asOrderedCollection; yourself.
	after := CPTask new identifier: 'after'; yourself.
	CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: timer; yourself.
	outgoing := CPSequenceFlow new identifier: 'outgoing'; sourceRef: timer; targetRef: after; yourself.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: timer incoming first producedBy: producer.
	eventExecution := execution beginTimerIntermediateCatchEvent: timer consuming: activation.
	subscription := eventExecution subscription.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #timerDelivery1; definition: timerDefinition; yourself.
	subscription deliverOccurrence: occurrence.
	self assert: subscription isTriggered.
	self assert: subscription occurrence == occurrence.
	self assert: eventExecution isTriggered.
	self assert: eventExecution occurrence == occurrence.
	self assert: (execution acceptedOccurrences identityIncludes: occurrence).
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ execution
]

{ #category : 'examples - subscriptions' }
CPExecutionKernelExamples >> timerSubscriptionRejectsMismatchedOccurrenceBeforeAcceptance [
	<gtExample>
	| process before timerDefinition otherTimerDefinition timer execution producer activation eventExecution occurrence subscription rejected |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	timerDefinition := CPTimerEventDefinition new identifier: 'timerDefinition'; yourself.
	otherTimerDefinition := CPTimerEventDefinition new identifier: 'otherTimerDefinition'; yourself.
	timer := CPTimerIntermediateEvent new identifier: 'timer'; eventDefinitions: { timerDefinition } asOrderedCollection; yourself.
	CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: timer; yourself.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: timer incoming first producedBy: producer.
	eventExecution := execution beginTimerIntermediateCatchEvent: timer consuming: activation.
	subscription := eventExecution subscription.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #wrongTimerDelivery1; definition: otherTimerDefinition; yourself.
	rejected := false.
	[ subscription deliverOccurrence: occurrence ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: subscription isWaiting.
	self assert: eventExecution isWaiting.
	self assert: (execution acceptedOccurrences identityIncludes: occurrence) not.
	^ execution
]


{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> processExecutionStartsFromNoneStartEvents [
	<gtExample>
	| process firstStart secondStart firstTask secondTask firstFlow secondFlow execution startExecutions |
	process := CPProcess new identifier: 'process'; yourself.
	firstStart := CPNoneStartEvent new identifier: 'firstStart'; yourself.
	secondStart := CPNoneStartEvent new identifier: 'secondStart'; yourself.
	firstTask := CPTask new identifier: 'firstTask'; yourself.
	secondTask := CPTask new identifier: 'secondTask'; yourself.
	firstFlow := CPSequenceFlow new identifier: 'firstFlow'; sourceRef: firstStart; targetRef: firstTask; yourself.
	secondFlow := CPSequenceFlow new identifier: 'secondFlow'; sourceRef: secondStart; targetRef: secondTask; yourself.
	process addFlowElement: firstStart; addFlowElement: secondStart; addFlowElement: firstTask; addFlowElement: secondTask; addFlowElement: firstFlow; addFlowElement: secondFlow.
	execution := self executionFor: process.
	self assert: execution isStarted not.
	startExecutions := execution start.
	self assert: execution isStarted.
	self assert: startExecutions size equals: 2.
	self assert: (execution availableFlowActivationsOn: firstFlow) size equals: 1.
	self assert: (execution availableFlowActivationsOn: secondFlow) size equals: 1.
	^ execution
]

{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> processExecutionCannotStartTwice [
	<gtExample>
	| execution rejected |
	execution := self processExecutionStartsFromNoneStartEvents.
	rejected := false.
	[ execution start ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: execution isStarted.
	^ execution
]


{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> processExecutionCompletesWhenNoWorkRemains [
	<gtExample>
	| process start end flow execution activation |
	process := CPProcess new identifier: 'process'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	end := CPNoneEndEvent new identifier: 'end'; yourself.
	flow := CPSequenceFlow new identifier: 'toEnd'; sourceRef: start; targetRef: end; yourself.
	process addFlowElement: start; addFlowElement: end; addFlowElement: flow.
	execution := self executionFor: process.
	execution start.
	self assert: execution isCompleted not.
	self assert: execution canComplete not.
	activation := (execution availableFlowActivationsOn: flow) first.
	execution executeEndEvent: end consuming: activation.
	self assert: execution canComplete.
	execution complete.
	self assert: execution isCompleted.
	^ execution
]

{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> processExecutionCannotCompleteWhileMessageWaits [
	<gtExample>
	| process start receive message flow execution receiveExecution rejected |
	process := CPProcess new identifier: 'process'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	receive := CPReceiveTask new identifier: 'receive'; messageRef: message; yourself.
	flow := CPSequenceFlow new identifier: 'toReceive'; sourceRef: start; targetRef: receive; yourself.
	process addFlowElement: start; addFlowElement: receive; addFlowElement: flow.
	execution := self executionFor: process.
	execution start.
	receiveExecution := execution createReceiveTaskExecutionFor: receive.
	receiveExecution consumeFlowActivation: (execution availableFlowActivationsOn: flow) first.
	execution activateReceiveTaskExecution: receiveExecution.
	self assert: execution canComplete not.
	rejected := false.
	[ execution complete ] on: Error do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: execution isCompleted not.
	self assert: receiveExecution isWaitingForMessage.
	^ execution
]


{ #category : 'examples - cancellation' }
CPExecutionKernelExamples >> cancelledSequenceFlowActivationIsNoLongerAvailable [
	<gtExample>
	| process source target flow execution producer activation rejected |
	process := CPProcess new identifier: 'process'; yourself.
	source := CPTask new identifier: 'source'; yourself.
	target := CPTask new identifier: 'target'; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: source; targetRef: target; yourself.
	process addFlowElement: source; addFlowElement: target; addFlowElement: flow.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: source.
	activation := execution activateSequenceFlow: flow producedBy: producer.
	self assert: activation isAvailable.
	activation cancel.
	self assert: activation isCancelled.
	self assert: activation isAvailable not.
	rejected := false.
	[ (execution createActivityExecutionFor: target) consumeFlowActivation: activation ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	^ activation
]

{ #category : 'examples - cancellation' }
CPExecutionKernelExamples >> cancelledSubscriptionsLeaveWaitingSet [
	<gtExample>
	| process before message receive timer timerDefinition incoming execution producer activation receiveExecution messageSubscription timerExecution timerSubscription |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	receive := CPReceiveTask new identifier: 'receive'; messageRef: message; yourself.
	timerDefinition := CPTimerEventDefinition new identifier: 'timerDefinition'; yourself.
	timer := CPTimerIntermediateEvent new
		identifier: 'timer';
		eventDefinitions: { timerDefinition } asOrderedCollection;
		yourself.
	incoming := CPSequenceFlow new identifier: 'toTimer'; sourceRef: before; targetRef: timer; yourself.
	execution := self executionFor: process.
	receiveExecution := execution createReceiveTaskExecutionFor: receive.
	execution activateReceiveTaskExecution: receiveExecution.
	messageSubscription := receiveExecution subscription.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	timerExecution := execution beginTimerIntermediateCatchEvent: timer consuming: activation.
	timerSubscription := timerExecution subscription.
	self assert: messageSubscription isWaiting.
	self assert: timerSubscription isWaiting.
	messageSubscription cancel.
	timerSubscription cancel.
	self assert: messageSubscription isCancelled.
	self assert: timerSubscription isCancelled.
	self assert: (execution waitingMessageSubscriptions identityIncludes: messageSubscription) not.
	self assert: (execution waitingTimerSubscriptions identityIncludes: timerSubscription) not.
	^ execution
]

{ #category : 'examples - termination' }
CPExecutionKernelExamples >> terminateEndEventCancelsRemainingProcessWork [
	<gtExample>
	| process start terminate receive message toTerminate toReceive execution terminateActivation receiveExecution terminateExecution |
	process := CPProcess new identifier: 'process'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	terminate := CPTerminateEndEvent new identifier: 'terminate'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	receive := CPReceiveTask new identifier: 'receive'; messageRef: message; yourself.
	toTerminate := CPSequenceFlow new identifier: 'toTerminate'; sourceRef: start; targetRef: terminate; yourself.
	toReceive := CPSequenceFlow new identifier: 'toReceive'; sourceRef: start; targetRef: receive; yourself.
	process
		addFlowElement: start;
		addFlowElement: terminate;
		addFlowElement: receive;
		addFlowElement: toTerminate;
		addFlowElement: toReceive.
	execution := self executionFor: process.
	execution start.
	receiveExecution := execution createReceiveTaskExecutionFor: receive.
	receiveExecution consumeFlowActivation: (execution availableFlowActivationsOn: toReceive) first.
	execution activateReceiveTaskExecution: receiveExecution.
	self assert: receiveExecution isActive.
	self assert: execution waitingMessageSubscriptions size equals: 1.
	terminateActivation := (execution availableFlowActivationsOn: toTerminate) first.
	terminateExecution := execution executeTerminateEndEvent: terminate consuming: terminateActivation.
	self assert: receiveExecution state class equals: CPActivityTerminatedState.
	self assert: execution waitingMessageSubscriptions isEmpty.
	self assert: execution messageSubscriptions first isCancelled.
	self assert: execution canComplete not.
	self assert: execution isCompleted.
	^ terminateExecution
]

{ #category : 'examples - termination' }
CPExecutionKernelExamples >> terminateEndEventCompletesOnlyItsSubProcessScope [
	<gtExample>
	| process subProcess start terminate receive message innerTerminate innerReceive after outerFlow execution subExecution child terminateActivation receiveExecution |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	terminate := CPTerminateEndEvent new identifier: 'terminate'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	receive := CPReceiveTask new identifier: 'receive'; messageRef: message; yourself.
	innerTerminate := CPSequenceFlow new identifier: 'innerTerminate'; sourceRef: start; targetRef: terminate; yourself.
	innerReceive := CPSequenceFlow new identifier: 'innerReceive'; sourceRef: start; targetRef: receive; yourself.
	subProcess
		addFlowElement: start;
		addFlowElement: terminate;
		addFlowElement: receive;
		addFlowElement: innerTerminate;
		addFlowElement: innerReceive.
	after := CPTask new identifier: 'after'; yourself.
	outerFlow := CPSequenceFlow new identifier: 'afterSubProcess'; sourceRef: subProcess; targetRef: after; yourself.
	execution := self executionFor: process.
	subExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subExecution.
	child := subExecution subScope.
	receiveExecution := child createReceiveTaskExecutionFor: receive.
	receiveExecution consumeFlowActivation: (child availableFlowActivationsOn: innerReceive) first.
	child activateReceiveTaskExecution: receiveExecution.
	terminateActivation := (child availableFlowActivationsOn: innerTerminate) first.
	child executeTerminateEndEvent: terminate consuming: terminateActivation.
	self assert: receiveExecution state class equals: CPActivityTerminatedState.
	self assert: child waitingMessageSubscriptions isEmpty.
	self assert: subExecution isCompleted.
	self assert: execution isCompleted not.
	self assert: (execution availableFlowActivationsOn: outerFlow) size equals: 1.
	^ subExecution
]


{ #category : 'examples - sub-process' }
CPExecutionKernelExamples >> subProcessCannotCompleteWhileMessageCatchWaits [
	<gtExample>
	| process subProcess start catch message messageDefinition flow execution subExecution child catchExecution rejected |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	messageDefinition := CPMessageEventDefinition new messageRef: message; yourself.
	catch := CPMessageCatchIntermediateEvent new
		identifier: 'waitForMessage';
		eventDefinitions: { messageDefinition };
		yourself.
	flow := CPSequenceFlow new identifier: 'toCatch'; sourceRef: start; targetRef: catch; yourself.
	subProcess addFlowElement: start; addFlowElement: catch; addFlowElement: flow.
	execution := self executionFor: process.
	subExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subExecution.
	child := subExecution subScope.
	catchExecution := child beginMessageIntermediateCatchEvent: catch consuming: (child availableFlowActivationsOn: flow) first.
	self assert: catchExecution isWaiting.
	self assert: child allWaitingMessageSubscriptions size equals: 1.
	self assert: (execution canCompleteSubProcessActivity: subExecution) not.
	rejected := false.
	[ execution completeSubProcessActivity: subExecution ] on: Error do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: subExecution isActive.
	^ subExecution
]

{ #category : 'examples - call' }
CPExecutionKernelExamples >> callActivityCannotCompleteWhileCalledTimerWaits [
	<gtExample>
	| process call calledProcess start timer timerDefinition flow environment execution callExecution child timerExecution rejected |
	process := CPProcess new identifier: 'process'; yourself.
	call := CPCallActivity new identifier: 'call'; yourself.
	calledProcess := CPProcess new identifier: 'calledProcess'; yourself.
	call calledElement: calledProcess.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	timerDefinition := CPTimerEventDefinition new.
	timer := CPTimerIntermediateEvent new
		identifier: 'waitForTimer';
		eventDefinitions: { timerDefinition };
		yourself.
	flow := CPSequenceFlow new identifier: 'toTimer'; sourceRef: start; targetRef: timer; yourself.
	calledProcess addFlowElement: start; addFlowElement: timer; addFlowElement: flow.
	environment := CPExampleExecutionEnvironment new.
	environment callableElement: calledProcess resolvesTo: calledProcess.
	execution := CPProcessExecution for: process environment: environment.
	callExecution := execution createActivityExecutionFor: call.
	execution activateCallActivityExecution: callExecution.
	child := callExecution subScope.
	timerExecution := child beginTimerIntermediateCatchEvent: timer consuming: (child availableFlowActivationsOn: flow) first.
	self assert: timerExecution isWaiting.
	self assert: child allWaitingTimerSubscriptions size equals: 1.
	self assert: (execution canCompleteCallActivity: callExecution) not.
	rejected := false.
	[ execution completeCallActivity: callExecution ] on: Error do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: callExecution isActive.
	^ callExecution
]


{ #category : 'examples - completion' }
CPExecutionKernelExamples >> processCannotCompleteWhileEventBasedGatewayWaits [
	<gtExample>
	| process start gateway message timer startFlow messageFlow timerFlow execution gatewayExecution |
	process := CPProcess new identifier: 'process'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	gateway := CPEventBasedGateway new identifier: 'wait'; yourself.
	message := CPMessageCatchIntermediateEvent new identifier: 'message'; yourself.
	timer := CPTimerIntermediateEvent new identifier: 'timer'; yourself.
	startFlow := CPSequenceFlow new identifier: 'toGateway'; sourceRef: start; targetRef: gateway; yourself.
	messageFlow := CPSequenceFlow new identifier: 'messageAlternative'; sourceRef: gateway; targetRef: message; yourself.
	timerFlow := CPSequenceFlow new identifier: 'timerAlternative'; sourceRef: gateway; targetRef: timer; yourself.
	process addFlowElement: start; addFlowElement: gateway; addFlowElement: message; addFlowElement: timer;
		addFlowElement: startFlow; addFlowElement: messageFlow; addFlowElement: timerFlow.
	execution := self executionFor: process.
	execution start.
	gatewayExecution := execution
		beginExclusiveEventBasedGateway: gateway
		consuming: (execution availableFlowActivationsOn: startFlow) first.
	self assert: gatewayExecution isWaiting.
	self assert: execution allWaitingEventBasedGatewaySubscriptions size equals: 2.
	self assert: execution canComplete not.
	^ execution
]

{ #category : 'examples - termination' }
CPExecutionKernelExamples >> terminationWithdrawsEventBasedGatewayWaits [
	<gtExample>
	| process before gateway message timer incoming messageFlow timerFlow execution producer gatewayExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	gateway := CPEventBasedGateway new identifier: 'wait'; yourself.
	message := CPMessageCatchIntermediateEvent new identifier: 'message'; yourself.
	timer := CPTimerIntermediateEvent new identifier: 'timer'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: gateway; yourself.
	messageFlow := CPSequenceFlow new identifier: 'messageAlternative'; sourceRef: gateway; targetRef: message; yourself.
	timerFlow := CPSequenceFlow new identifier: 'timerAlternative'; sourceRef: gateway; targetRef: timer; yourself.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	gatewayExecution := execution
		beginExclusiveEventBasedGateway: gateway
		consuming: (execution activateSequenceFlow: incoming producedBy: producer).
	self assert: gatewayExecution isWaiting.
	self assert: execution waitingEventBasedGatewaySubscriptions size equals: 2.
	execution terminateRemainingWork.
	self assert: gatewayExecution isWaiting not.
	self assert: execution waitingEventBasedGatewaySubscriptions isEmpty.
	self assert: gatewayExecution subscriptions size equals: 2.
	self assert: (gatewayExecution subscriptions allSatisfy: #isWithdrawn).
	^ gatewayExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> boundaryEventWithdrawsWhenAttachedActivityCompletes [
	<gtExample>
	| process activity boundary after flow execution activityExecution boundaryExecution |
	process := CPProcess new identifier: 'process'; yourself.
	activity := CPTask new identifier: 'activity'; yourself.
	boundary := CPBoundaryEvent new identifier: 'timeout'; attachedToRef: activity; cancelActivity: true; yourself.
	after := CPTask new identifier: 'after'; yourself.
	flow := CPSequenceFlow new identifier: 'afterActivity'; sourceRef: activity; targetRef: after; yourself.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	boundaryExecution := execution beginBoundaryEvent: boundary attachedTo: activityExecution.
	self assert: boundaryExecution isWaiting.
	activityExecution beginCompletion.
	activityExecution complete.
	execution produceOutgoingControlFor: activityExecution.
	self assert: boundaryExecution isWaiting not.
	self assert: boundaryExecution isWithdrawn.
	self assert: boundaryExecution isTriggered not.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	^ boundaryExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> interruptingBoundaryEventWithdrawsSiblingBoundaryWaits [
	<gtExample>
	| process activity timeout escalation execution activityExecution timeoutExecution escalationExecution occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	activity := CPTask new identifier: 'activity'; yourself.
	timeout := CPBoundaryEvent new identifier: 'timeout'; attachedToRef: activity; cancelActivity: true; yourself.
	escalation := CPBoundaryEvent new identifier: 'escalation'; attachedToRef: activity; cancelActivity: false; yourself.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	timeoutExecution := execution beginBoundaryEvent: timeout attachedTo: activityExecution.
	escalationExecution := execution beginBoundaryEvent: escalation attachedTo: activityExecution.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #timeout; definition: timeout; yourself.
	execution triggerBoundaryEventExecution: timeoutExecution with: occurrence.
	self assert: timeoutExecution isTriggered.
	self assert: escalationExecution isWaiting not.
	self assert: escalationExecution isWithdrawn.
	self assert: escalationExecution isTriggered not.
	self assert: activityExecution state class equals: CPActivityTerminatedState.
	^ escalationExecution
]


{ #category : 'examples - occurrences' }
CPExecutionKernelExamples >> occurrenceIdentityIsUniqueAcrossNestedScopes [
	<gtExample>
	| process ownerOne ownerTwo execution ownerExecutionOne ownerExecutionTwo scopeOne scopeTwo firstOccurrence duplicateOccurrence rejected |
	process := CPProcess new identifier: 'process'; yourself.
	ownerOne := CPSubProcess new identifier: 'one'; yourself.
	ownerTwo := CPSubProcess new identifier: 'two'; yourself.
	execution := self executionFor: process.
	ownerExecutionOne := execution createActivityExecutionFor: ownerOne.
	ownerExecutionTwo := execution createActivityExecutionFor: ownerTwo.
	scopeOne := CPExecutionScope for: ownerOne ownedBy: ownerExecutionOne.
	scopeTwo := CPExecutionScope for: ownerTwo ownedBy: ownerExecutionTwo.
	self assert: scopeOne parentScope == execution.
	self assert: scopeTwo parentScope == execution.
	self assert: (execution childScopes identityIncludes: scopeOne).
	self assert: (execution childScopes identityIncludes: scopeTwo).
	firstOccurrence := CPExecutionOccurrence new occurrenceIdentifier: #delivery42; definition: #first; yourself.
	duplicateOccurrence := CPExecutionOccurrence new occurrenceIdentifier: #delivery42; definition: #second; yourself.
	scopeOne acceptOccurrence: firstOccurrence.
	rejected := false.
	[ scopeTwo acceptOccurrence: duplicateOccurrence ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: (scopeOne acceptedOccurrences identityIncludes: firstOccurrence).
	self assert: (scopeTwo acceptedOccurrences identityIncludes: duplicateOccurrence) not.
	self assert: (execution hasAcceptedOccurrenceIdentifiedByAnywhere: #delivery42).
	^ execution
]

{ #category : 'examples - lifecycle' }
CPExecutionKernelExamples >> processCannotCompleteWhileIntermediateThrowEventIsPending [
	<gtExample>
	| process start event incoming execution activation eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	event := CPMessageThrowIntermediateEvent new identifier: 'message'; yourself.
	incoming := CPSequenceFlow new identifier: 'toMessage'; sourceRef: start; targetRef: event; yourself.
	process flowElements addAll: { start. event. incoming }.
	execution := self executionFor: process.
	execution start.
	activation := (execution availableFlowActivationsOn: incoming) first.
	eventExecution := execution beginIntermediateThrowEvent: event consuming: activation.
	self assert: eventExecution isPending.
	self assert: execution hasPendingEventWork.
	self assert: execution canComplete not.
	execution completeIntermediateThrowEventExecution: eventExecution.
	self assert: eventExecution isCompleted.
	self assert: execution hasPendingEventWork not.
	self assert: execution canComplete.
	^ execution
]


{ #category : 'examples - lifecycle' }
CPExecutionKernelExamples >> terminateEndEventWithdrawsPendingIntermediateThrowEvent [
	<gtExample>
	| process start throwEvent terminateEvent throwFlow terminateFlow execution throwActivation terminateActivation throwExecution |
	process := CPProcess new identifier: 'process'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	throwEvent := CPMessageThrowIntermediateEvent new identifier: 'pendingMessage'; yourself.
	terminateEvent := CPTerminateEndEvent new identifier: 'terminate'; yourself.
	throwFlow := CPSequenceFlow new identifier: 'toThrow'; sourceRef: start; targetRef: throwEvent; yourself.
	terminateFlow := CPSequenceFlow new identifier: 'toTerminate'; sourceRef: start; targetRef: terminateEvent; yourself.
	process flowElements addAll: { start. throwEvent. terminateEvent. throwFlow. terminateFlow }.
	execution := self executionFor: process.
	execution start.
	throwActivation := (execution availableFlowActivationsOn: throwFlow) first.
	terminateActivation := (execution availableFlowActivationsOn: terminateFlow) first.
	throwExecution := execution beginIntermediateThrowEvent: throwEvent consuming: throwActivation.
	self assert: throwExecution isPending.
	self assert: execution hasPendingEventWork.
	execution executeTerminateEndEvent: terminateEvent consuming: terminateActivation.
	self assert: throwExecution isPending not.
	self assert: throwExecution isWithdrawn.
	self assert: throwExecution isCompleted not.
	self assert: execution hasPendingEventWork not.
	self assert: execution isCompleted.
	^ execution
]

{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> messageOccurrenceInstantiatesProcessThroughMatchingStartEvent [
	<gtExample>
	| process message otherMessage messageDefinition otherDefinition messageStart otherStart after otherAfter flow otherFlow execution occurrence eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	otherMessage := CPMessage new identifier: 'otherMessage'; yourself.
	messageDefinition := CPMessageEventDefinition new identifier: 'messageDefinition'; messageRef: message; yourself.
	otherDefinition := CPMessageEventDefinition new identifier: 'otherDefinition'; messageRef: otherMessage; yourself.
	messageStart := CPMessageStartEvent new identifier: 'messageStart'; yourself.
	messageStart eventDefinitions add: messageDefinition.
	otherStart := CPMessageStartEvent new identifier: 'otherStart'; yourself.
	otherStart eventDefinitions add: otherDefinition.
	after := CPTask new identifier: 'after'; yourself.
	otherAfter := CPTask new identifier: 'otherAfter'; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: messageStart; targetRef: after; yourself.
	otherFlow := CPSequenceFlow new identifier: 'otherFlow'; sourceRef: otherStart; targetRef: otherAfter; yourself.
	process flowElements addAll: { messageStart. otherStart. after. otherAfter. flow. otherFlow }.
	execution := self executionFor: process.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #messageStart1; definition: message; yourself.
	eventExecution := execution startWithOccurrence: occurrence.
	self assert: execution isStarted.
	self assert: eventExecution definition == messageStart.
	self assert: eventExecution occurrence == occurrence.
	self assert: (execution acceptedOccurrences identityIncludes: occurrence).
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	self assert: (execution availableFlowActivationsOn: otherFlow) isEmpty.
	^ execution
]

{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> unmatchedMessageOccurrenceCannotInstantiateProcess [
	<gtExample>
	| process message otherMessage messageDefinition messageStart execution occurrence rejected |
	process := CPProcess new identifier: 'process'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	otherMessage := CPMessage new identifier: 'otherMessage'; yourself.
	messageDefinition := CPMessageEventDefinition new identifier: 'messageDefinition'; messageRef: message; yourself.
	messageStart := CPMessageStartEvent new identifier: 'messageStart'; yourself.
	messageStart eventDefinitions add: messageDefinition.
	process addFlowElement: messageStart.
	execution := self executionFor: process.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #wrongMessage; definition: otherMessage; yourself.
	rejected := false.
	[ execution startWithOccurrence: occurrence ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: execution isStarted not.
	self assert: execution acceptedOccurrences isEmpty.
	^ execution
]

{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> timerOccurrenceInstantiatesProcessThroughMatchingStartEvent [
	<gtExample>
	| process timerDefinition otherTimerDefinition timerStart otherStart after otherAfter flow otherFlow execution occurrence eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	timerDefinition := CPTimerEventDefinition new identifier: 'timerDefinition'; yourself.
	otherTimerDefinition := CPTimerEventDefinition new identifier: 'otherTimerDefinition'; yourself.
	timerStart := CPTimerStartEvent new identifier: 'timerStart'; yourself.
	timerStart eventDefinitions add: timerDefinition.
	otherStart := CPTimerStartEvent new identifier: 'otherStart'; yourself.
	otherStart eventDefinitions add: otherTimerDefinition.
	after := CPTask new identifier: 'after'; yourself.
	otherAfter := CPTask new identifier: 'otherAfter'; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: timerStart; targetRef: after; yourself.
	otherFlow := CPSequenceFlow new identifier: 'otherFlow'; sourceRef: otherStart; targetRef: otherAfter; yourself.
	process flowElements addAll: { timerStart. otherStart. after. otherAfter. flow. otherFlow }.
	execution := self executionFor: process.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #timerStart1; definition: timerDefinition; yourself.
	eventExecution := execution startWithOccurrence: occurrence.
	self assert: execution isStarted.
	self assert: eventExecution definition == timerStart.
	self assert: eventExecution occurrence == occurrence.
	self assert: (execution acceptedOccurrences identityIncludes: occurrence).
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	self assert: (execution availableFlowActivationsOn: otherFlow) isEmpty.
	^ execution
]

{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> unmatchedTimerOccurrenceCannotInstantiateProcess [
	<gtExample>
	| process timerDefinition otherTimerDefinition timerStart execution occurrence rejected |
	process := CPProcess new identifier: 'process'; yourself.
	timerDefinition := CPTimerEventDefinition new identifier: 'timerDefinition'; yourself.
	otherTimerDefinition := CPTimerEventDefinition new identifier: 'otherTimerDefinition'; yourself.
	timerStart := CPTimerStartEvent new identifier: 'timerStart'; yourself.
	timerStart eventDefinitions add: timerDefinition.
	process addFlowElement: timerStart.
	execution := self executionFor: process.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #wrongTimer; definition: otherTimerDefinition; yourself.
	rejected := false.
	[ execution startWithOccurrence: occurrence ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: execution isStarted not.
	self assert: execution acceptedOccurrences isEmpty.
	^ execution
]

{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> signalOccurrenceInstantiatesProcessThroughMatchingStartEvent [
	<gtExample>
	| process signal otherSignal signalDefinition otherDefinition signalStart otherStart after otherAfter flow otherFlow execution occurrence eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	signal := CPSignal new identifier: 'signal'; yourself.
	otherSignal := CPSignal new identifier: 'otherSignal'; yourself.
	signalDefinition := CPSignalEventDefinition new identifier: 'signalDefinition'; signalRef: signal; yourself.
	otherDefinition := CPSignalEventDefinition new identifier: 'otherDefinition'; signalRef: otherSignal; yourself.
	signalStart := CPSignalStartEvent new identifier: 'signalStart'; yourself.
	signalStart eventDefinitions add: signalDefinition.
	otherStart := CPSignalStartEvent new identifier: 'otherStart'; yourself.
	otherStart eventDefinitions add: otherDefinition.
	after := CPTask new identifier: 'after'; yourself.
	otherAfter := CPTask new identifier: 'otherAfter'; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: signalStart; targetRef: after; yourself.
	otherFlow := CPSequenceFlow new identifier: 'otherFlow'; sourceRef: otherStart; targetRef: otherAfter; yourself.
	process flowElements addAll: { signalStart. otherStart. after. otherAfter. flow. otherFlow }.
	execution := self executionFor: process.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #signalStart1; definition: signal; yourself.
	eventExecution := execution startWithOccurrence: occurrence.
	self assert: execution isStarted.
	self assert: eventExecution definition == signalStart.
	self assert: eventExecution occurrence == occurrence.
	self assert: (execution acceptedOccurrences identityIncludes: occurrence).
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	self assert: (execution availableFlowActivationsOn: otherFlow) isEmpty.
	^ execution
]

{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> unmatchedSignalOccurrenceCannotInstantiateProcess [
	<gtExample>
	| process signal otherSignal signalDefinition signalStart execution occurrence rejected |
	process := CPProcess new identifier: 'process'; yourself.
	signal := CPSignal new identifier: 'signal'; yourself.
	otherSignal := CPSignal new identifier: 'otherSignal'; yourself.
	signalDefinition := CPSignalEventDefinition new identifier: 'signalDefinition'; signalRef: signal; yourself.
	signalStart := CPSignalStartEvent new identifier: 'signalStart'; yourself.
	signalStart eventDefinitions add: signalDefinition.
	process addFlowElement: signalStart.
	execution := self executionFor: process.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #wrongSignal; definition: otherSignal; yourself.
	rejected := false.
	[ execution startWithOccurrence: occurrence ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: execution isStarted not.
	self assert: execution acceptedOccurrences isEmpty.
	^ execution
]

{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> conditionalStartInstantiatesProcessWhenConditionIsSatisfied [
	<gtExample>
	| process condition definition conditionalStart after flow execution eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPFormalExpression new identifier: 'condition'; body: 'ready'; yourself.
	definition := CPConditionalEventDefinition new identifier: 'conditionalDefinition'; condition: condition; yourself.
	conditionalStart := CPConditionalStartEvent new identifier: 'conditionalStart'; yourself.
	conditionalStart eventDefinitions add: definition.
	after := CPTask new identifier: 'after'; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: conditionalStart; targetRef: after; yourself.
	process flowElements addAll: { conditionalStart. after. flow }.
	execution := self executionFor: process.
	execution environment expression: condition evaluatesTo: true.
	eventExecution := execution startWhenConditionSatisfied.
	self assert: execution isStarted.
	self assert: eventExecution definition == conditionalStart.
	self assert: eventExecution occurrence isNil.
	self assert: execution acceptedOccurrences isEmpty.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	^ execution
]

{ #category : 'examples - process lifecycle' }
CPExecutionKernelExamples >> unsatisfiedConditionalStartCannotInstantiateProcess [
	<gtExample>
	| process condition definition conditionalStart execution rejected |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPFormalExpression new identifier: 'condition'; body: 'ready'; yourself.
	definition := CPConditionalEventDefinition new identifier: 'conditionalDefinition'; condition: condition; yourself.
	conditionalStart := CPConditionalStartEvent new identifier: 'conditionalStart'; yourself.
	conditionalStart eventDefinitions add: definition.
	process addFlowElement: conditionalStart.
	execution := self executionFor: process.
	execution environment expression: condition evaluatesTo: false.
	rejected := false.
	[ execution startWhenConditionSatisfied ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: execution isStarted not.
	self assert: execution eventExecutions isEmpty.
	^ execution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> signalIntermediateCatchEventCreatesDurableSubscription [
	<gtExample>
	| process before signalEvent after signal signalDefinition incoming outgoing execution producer activation eventExecution subscription occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	signal := CPSignal new identifier: 'ready'; yourself.
	signalDefinition := CPSignalEventDefinition new
		identifier: 'readyDefinition';
		signalRef: signal;
		yourself.
	signalEvent := CPSignalIntermediateEvent new
		identifier: 'waitForReady';
		eventDefinitions: { signalDefinition } asOrderedCollection;
		yourself.
	after := CPTask new identifier: 'after'; yourself.
	incoming := CPSequenceFlow new identifier: 'toSignal'; sourceRef: before; targetRef: signalEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterSignal'; sourceRef: signalEvent; targetRef: after; yourself.
	process addFlowElement: before; addFlowElement: signalEvent; addFlowElement: after; addFlowElement: incoming; addFlowElement: outgoing.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	eventExecution := execution beginSignalIntermediateCatchEvent: signalEvent consuming: activation.
	subscription := eventExecution subscription.
	self assert: eventExecution isWaiting.
	self assert: subscription waitingExecution == eventExecution.
	self assert: subscription signal == signal.
	self assert: subscription isWaiting.
	self assert: (execution signalSubscriptions occurrencesOf: subscription) equals: 1.
	self assert: (execution waitingSignalSubscriptions occurrencesOf: subscription) equals: 1.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #readySignal1; definition: signal; yourself.
	subscription deliverOccurrence: occurrence.
	self assert: eventExecution isTriggered.
	self assert: subscription isTriggered.
	self assert: subscription occurrence == occurrence.
	self assert: (execution hasAcceptedOccurrenceIdentifiedBy: #readySignal1).
	self assert: (execution waitingSignalSubscriptions includes: subscription) not.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ eventExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> signalIntermediateCatchEventRejectsDifferentSignal [
	<gtExample>
	| eventExecution execution subscription otherSignal occurrence rejected |
	eventExecution := self signalIntermediateCatchEventWaitingExecution.
	execution := eventExecution scope.
	subscription := eventExecution subscription.
	otherSignal := CPSignal new identifier: 'other'; yourself.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #wrongSignal1; definition: otherSignal; yourself.
	rejected := false.
	[ subscription deliverOccurrence: occurrence ]
		on: Error do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: eventExecution isWaiting.
	self assert: subscription isWaiting.
	self assert: (execution hasAcceptedOccurrenceIdentifiedBy: #wrongSignal1) not.
	^ eventExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> signalIntermediateCatchEventWaitingExecution [
	<gtExample>
	| process before signalEvent signal signalDefinition incoming execution producer activation eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	signal := CPSignal new identifier: 'expected'; yourself.
	signalDefinition := CPSignalEventDefinition new identifier: 'expectedSignalDefinition'; signalRef: signal; yourself.
	signalEvent := CPSignalIntermediateEvent new identifier: 'wait'; eventDefinitions: { signalDefinition } asOrderedCollection; yourself.
	incoming := CPSequenceFlow new identifier: 'toWait'; sourceRef: before; targetRef: signalEvent; yourself.
	process addFlowElement: before; addFlowElement: signalEvent; addFlowElement: incoming.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	eventExecution := execution beginSignalIntermediateCatchEvent: signalEvent consuming: activation.
	self assert: eventExecution isWaiting.
	^ eventExecution
]

{ #category : 'examples - events' }
CPExecutionKernelExamples >> signalBroadcastDeliversOneOccurrenceToAllWaitingSubscriptions [
	<gtExample>
	| process beforeOne beforeTwo catchOne catchTwo afterOne afterTwo signal definition inOne inTwo outOne outTwo execution producerOne producerTwo activationOne activationTwo eventOne eventTwo occurrence delivered |
	process := CPProcess new identifier: 'process'; yourself.
	beforeOne := CPTask new identifier: 'beforeOne'; yourself.
	beforeTwo := CPTask new identifier: 'beforeTwo'; yourself.
	signal := CPSignal new identifier: 'ready'; yourself.
	definition := CPSignalEventDefinition new identifier: 'readyDefinition'; signalRef: signal; yourself.
	catchOne := CPSignalIntermediateEvent new identifier: 'catchOne'; eventDefinitions: { definition } asOrderedCollection; yourself.
	catchTwo := CPSignalIntermediateEvent new identifier: 'catchTwo'; eventDefinitions: { definition } asOrderedCollection; yourself.
	afterOne := CPTask new identifier: 'afterOne'; yourself.
	afterTwo := CPTask new identifier: 'afterTwo'; yourself.
	inOne := CPSequenceFlow new identifier: 'inOne'; sourceRef: beforeOne; targetRef: catchOne; yourself.
	inTwo := CPSequenceFlow new identifier: 'inTwo'; sourceRef: beforeTwo; targetRef: catchTwo; yourself.
	outOne := CPSequenceFlow new identifier: 'outOne'; sourceRef: catchOne; targetRef: afterOne; yourself.
	outTwo := CPSequenceFlow new identifier: 'outTwo'; sourceRef: catchTwo; targetRef: afterTwo; yourself.
	{ beforeOne. beforeTwo. catchOne. catchTwo. afterOne. afterTwo. inOne. inTwo. outOne. outTwo } do: [ :each | process addFlowElement: each ].
	execution := self executionFor: process.
	producerOne := execution createActivityExecutionFor: beforeOne.
	producerTwo := execution createActivityExecutionFor: beforeTwo.
	activationOne := execution activateSequenceFlow: inOne producedBy: producerOne.
	activationTwo := execution activateSequenceFlow: inTwo producedBy: producerTwo.
	eventOne := execution beginSignalIntermediateCatchEvent: catchOne consuming: activationOne.
	eventTwo := execution beginSignalIntermediateCatchEvent: catchTwo consuming: activationTwo.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #broadcastReady1; definition: signal; yourself.
	delivered := execution deliverSignalOccurrence: occurrence.
	self assert: delivered size equals: 2.
	self assert: eventOne isTriggered.
	self assert: eventTwo isTriggered.
	self assert: eventOne occurrence == occurrence.
	self assert: eventTwo occurrence == occurrence.
	self assert: (execution acceptedOccurrences occurrencesOf: occurrence) equals: 1.
	self assert: (execution availableFlowActivationsOn: outOne) size equals: 1.
	self assert: (execution availableFlowActivationsOn: outTwo) size equals: 1.
	self assert: execution waitingSignalSubscriptions isEmpty.
	^ execution
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> errorEndEventIsCaughtByMatchingBoundaryEvent [
	<gtExample>
	| process subProcess innerStart errorEnd innerFlow error errorDefinition boundary boundaryDefinition after boundaryFlow execution subProcessExecution childScope boundaryExecution endActivation |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	innerStart := CPNoneStartEvent new identifier: 'innerStart'; yourself.
	error := CPError new identifier: 'paymentError'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'thrownError'; error: error; yourself.
	errorEnd := CPErrorEndEvent new identifier: 'errorEnd'; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	innerFlow := CPSequenceFlow new identifier: 'toError'; sourceRef: innerStart; targetRef: errorEnd; yourself.
	subProcess addFlowElement: innerStart.
	subProcess addFlowElement: errorEnd.
	subProcess addFlowElement: innerFlow.
	boundaryDefinition := CPErrorEventDefinition new identifier: 'caughtError'; error: error; yourself.
	boundary := CPBoundaryEvent new identifier: 'errorBoundary'; attachedToRef: subProcess; cancelActivity: true; yourself.
	boundary eventDefinitions add: boundaryDefinition.
	after := CPTask new identifier: 'afterError'; yourself.
	boundaryFlow := CPSequenceFlow new identifier: 'afterBoundary'; sourceRef: boundary; targetRef: after; yourself.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subProcessExecution.
	boundaryExecution := execution beginBoundaryEvent: boundary attachedTo: subProcessExecution.
	childScope := subProcessExecution subScope.
	endActivation := (childScope availableFlowActivationsOn: innerFlow) first.
	childScope executeErrorEndEvent: errorEnd consuming: endActivation.
	self assert: subProcessExecution state class equals: CPActivityFailedState.
	self assert: boundaryExecution isTriggered.
	self assert: boundaryExecution occurrence definition == error.
	self assert: (execution availableFlowActivationsOn: boundaryFlow) size equals: 1.
	self assert: (childScope flowActivations noneSatisfy: [ :each | each isAvailable ]).
	^ boundaryExecution
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> errorEndEventPropagatesToEnclosingBoundaryEvent [
	<gtExample>
	| process outer inner innerStart errorEnd innerFlow error errorDefinition boundary boundaryDefinition after boundaryFlow execution outerExecution outerScope innerExecution innerScope boundaryExecution endActivation |
	process := CPProcess new identifier: 'process'; yourself.
	outer := CPSubProcess new identifier: 'outer'; yourself.
	inner := CPSubProcess new identifier: 'inner'; yourself.
	innerStart := CPNoneStartEvent new identifier: 'innerStart'; yourself.
	error := CPError new identifier: 'paymentError'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'thrownError'; error: error; yourself.
	errorEnd := CPErrorEndEvent new identifier: 'errorEnd'; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	innerFlow := CPSequenceFlow new identifier: 'toError'; sourceRef: innerStart; targetRef: errorEnd; yourself.
	inner addFlowElement: innerStart.
	inner addFlowElement: errorEnd.
	inner addFlowElement: innerFlow.
	outer addFlowElement: inner.
	boundaryDefinition := CPErrorEventDefinition new identifier: 'caughtError'; error: error; yourself.
	boundary := CPBoundaryEvent new identifier: 'outerErrorBoundary'; attachedToRef: outer; cancelActivity: true; yourself.
	boundary eventDefinitions add: boundaryDefinition.
	after := CPTask new identifier: 'afterError'; yourself.
	boundaryFlow := CPSequenceFlow new identifier: 'afterBoundary'; sourceRef: boundary; targetRef: after; yourself.
	execution := self executionFor: process.
	outerExecution := execution createActivityExecutionFor: outer.
	execution activateSubProcessExecution: outerExecution.
	boundaryExecution := execution beginBoundaryEvent: boundary attachedTo: outerExecution.
	outerScope := outerExecution subScope.
	innerExecution := outerScope createActivityExecutionFor: inner.
	outerScope activateSubProcessExecution: innerExecution.
	innerScope := innerExecution subScope.
	endActivation := (innerScope availableFlowActivationsOn: innerFlow) first.
	innerScope executeErrorEndEvent: errorEnd consuming: endActivation.
	self assert: innerExecution state class equals: CPActivityFailedState.
	self assert: outerExecution state class equals: CPActivityFailedState.
	self assert: boundaryExecution isTriggered.
	self assert: boundaryExecution occurrence definition == error.
	self assert: (execution availableFlowActivationsOn: boundaryFlow) size equals: 1.
	self assert: (innerScope flowActivations noneSatisfy: [ :each | each isAvailable ]).
	self assert: (outerScope flowActivations noneSatisfy: [ :each | each isAvailable ]).
	^ boundaryExecution
]


{ #category : 'examples - error events' }
CPExecutionKernelExamples >> ambiguousErrorBoundaryMatchIsRejectedBeforeMutation [
	<gtExample>
	| process subProcess innerStart errorEnd innerFlow error errorDefinition firstBoundary secondBoundary firstDefinition secondDefinition execution subProcessExecution childScope firstBoundaryExecution secondBoundaryExecution endActivation rejected |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	innerStart := CPNoneStartEvent new identifier: 'innerStart'; yourself.
	error := CPError new identifier: 'paymentError'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'thrownError'; error: error; yourself.
	errorEnd := CPErrorEndEvent new identifier: 'errorEnd'; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	innerFlow := CPSequenceFlow new identifier: 'toError'; sourceRef: innerStart; targetRef: errorEnd; yourself.
	subProcess addFlowElement: innerStart.
	subProcess addFlowElement: errorEnd.
	subProcess addFlowElement: innerFlow.
	firstDefinition := CPErrorEventDefinition new identifier: 'firstCaughtError'; error: error; yourself.
	firstBoundary := CPBoundaryEvent new identifier: 'firstErrorBoundary'; attachedToRef: subProcess; cancelActivity: true; yourself.
	firstBoundary eventDefinitions add: firstDefinition.
	secondDefinition := CPErrorEventDefinition new identifier: 'secondCaughtError'; error: error; yourself.
	secondBoundary := CPBoundaryEvent new identifier: 'secondErrorBoundary'; attachedToRef: subProcess; cancelActivity: true; yourself.
	secondBoundary eventDefinitions add: secondDefinition.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subProcessExecution.
	firstBoundaryExecution := execution beginBoundaryEvent: firstBoundary attachedTo: subProcessExecution.
	secondBoundaryExecution := execution beginBoundaryEvent: secondBoundary attachedTo: subProcessExecution.
	childScope := subProcessExecution subScope.
	endActivation := (childScope availableFlowActivationsOn: innerFlow) first.
	rejected := false.
	[ childScope executeErrorEndEvent: errorEnd consuming: endActivation ]
		on: Error
		do: [ :caught | rejected := true ].
	self assert: rejected.
	self assert: endActivation isAvailable.
	self assert: subProcessExecution isActive.
	self assert: firstBoundaryExecution isWaiting.
	self assert: secondBoundaryExecution isWaiting.
	self assert: childScope acceptedOccurrences isEmpty.
	^ execution
]

{ #category : 'examples - conditional events' }
CPExecutionKernelExamples >> conditionalIntermediateCatchEventWaitsUntilConditionIsSatisfied [
	<gtExample>
	| process before conditional after condition definition incoming outgoing environment execution producer activation eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	condition := CPExpression new identifier: 'condition'; yourself.
	definition := CPConditionalEventDefinition new identifier: 'conditionalDefinition'; condition: condition; yourself.
	conditional := CPIntermediateCatchEvent new
		identifier: 'conditional';
		eventDefinitions: { definition } asOrderedCollection;
		yourself.
	after := CPTask new identifier: 'after'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: conditional; yourself.
	outgoing := CPSequenceFlow new identifier: 'outgoing'; sourceRef: conditional; targetRef: after; yourself.
	environment := CPExampleExecutionEnvironment new.
	environment expression: condition evaluatesTo: false.
	execution := CPProcessExecution for: process environment: environment.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	eventExecution := execution beginConditionalIntermediateCatchEvent: conditional consuming: activation.
	self assert: eventExecution isWaiting.
	self assert: eventExecution subscription isWaiting.
	self assert: eventExecution subscription condition == condition.
	self assert: (execution conditionalSubscriptions occurrencesOf: eventExecution subscription) equals: 1.
	self assert: (execution waitingConditionalSubscriptions occurrencesOf: eventExecution subscription) equals: 1.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	environment expression: condition evaluatesTo: true.
	self assert: (execution evaluateConditionalSubscription: eventExecution subscription).
	self assert: eventExecution isTriggered.
	self assert: eventExecution subscription isTriggered.
	self assert: (execution waitingConditionalSubscriptions includes: eventExecution subscription) not.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ eventExecution
]

{ #category : 'examples - link events' }
CPExecutionKernelExamples >> linkEventDefinitionModelsSourceAndTargetRelationship [
	<gtExample>
	| sourceOne sourceTwo target |
	target := CPLinkEventDefinition new
		identifier: 'targetLink';
		name: 'To Close';
		yourself.
	sourceOne := CPLinkEventDefinition new
		identifier: 'sourceLinkOne';
		name: 'To Close';
		target: target;
		yourself.
	sourceTwo := CPLinkEventDefinition new
		identifier: 'sourceLinkTwo';
		name: 'To Close';
		target: target;
		yourself.
	target sources add: sourceOne.
	target sources add: sourceTwo.
	self assert: sourceOne target == target.
	self assert: sourceTwo target == target.
	self assert: target sources size equals: 2.
	self assert: (target sources identityIncludes: sourceOne).
	self assert: (target sources identityIncludes: sourceTwo).
	self assert: target name equals: 'To Close'.
	^ target
]


{ #category : 'examples - link events' }
CPExecutionKernelExamples >> linkThrowTransfersControlToTargetCatchInSameScope [
	<gtExample>
	| process before sourceEvent targetEvent after sourceDefinition targetDefinition incoming outgoing execution producer activation throwExecution targetExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	targetDefinition := CPLinkEventDefinition new identifier: 'targetDefinition'; name: 'Continue'; yourself.
	sourceDefinition := CPLinkEventDefinition new identifier: 'sourceDefinition'; name: 'Continue'; target: targetDefinition; yourself.
	targetDefinition sources add: sourceDefinition.
	sourceEvent := CPLinkThrowIntermediateEvent new
		identifier: 'sourceLink';
		eventDefinitions: { sourceDefinition } asOrderedCollection;
		yourself.
	targetEvent := CPLinkIntermediateEvent new
		identifier: 'targetLink';
		eventDefinitions: { targetDefinition } asOrderedCollection;
		yourself.
	after := CPTask new identifier: 'after'; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: sourceEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'outgoing'; sourceRef: targetEvent; targetRef: after; yourself.
	process addFlowElement: before.
	process addFlowElement: sourceEvent.
	process addFlowElement: targetEvent.
	process addFlowElement: after.
	process addFlowElement: incoming.
	process addFlowElement: outgoing.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeLinkThrowEvent: sourceEvent consuming: activation.
	targetExecution := execution eventExecutions detect: [ :each | each definition == targetEvent ].
	self assert: throwExecution isCompleted.
	self assert: activation isAvailable not.
	self assert: targetExecution isTriggered.
	self assert: targetExecution occurrence isNil.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ throwExecution
]

{ #category : 'examples - link events' }
CPExecutionKernelExamples >> linkThrowRejectsTargetOutsideCurrentScopeBeforeMutation [
	<gtExample>
	| process before sourceEvent targetEvent sourceDefinition targetDefinition incoming execution producer activation rejected |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	targetDefinition := CPLinkEventDefinition new identifier: 'targetDefinition'; name: 'Continue'; yourself.
	sourceDefinition := CPLinkEventDefinition new identifier: 'sourceDefinition'; name: 'Continue'; target: targetDefinition; yourself.
	targetDefinition sources add: sourceDefinition.
	sourceEvent := CPLinkThrowIntermediateEvent new identifier: 'sourceLink'; eventDefinitions: { sourceDefinition } asOrderedCollection; yourself.
	targetEvent := CPLinkIntermediateEvent new identifier: 'targetLink'; eventDefinitions: { targetDefinition } asOrderedCollection; yourself.
	incoming := CPSequenceFlow new identifier: 'incoming'; sourceRef: before; targetRef: sourceEvent; yourself.
	process addFlowElement: before.
	process addFlowElement: sourceEvent.
	process addFlowElement: incoming.
	"The target is intentionally not part of this Process level."
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	rejected := false.
	[ execution executeLinkThrowEvent: sourceEvent consuming: activation ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: activation isAvailable.
	self assert: (execution eventExecutions noneSatisfy: [ :each | each definition == sourceEvent ]).
	^ execution
]

{ #category : 'examples - escalation events' }
CPExecutionKernelExamples >> escalationEndEventAndBoundaryShareExplicitMatchingContract [
	<gtExample>
	| escalation otherEscalation definition boundary endEvent |
	escalation := CPEscalation new identifier: 'businessEscalation'; yourself.
	otherEscalation := CPEscalation new identifier: 'otherEscalation'; yourself.
	definition := CPEscalationEventDefinition new
		identifier: 'caughtEscalation';
		escalationRef: escalation;
		yourself.
	boundary := CPBoundaryEvent new identifier: 'boundary'; yourself.
	boundary eventDefinitions add: definition.
	endEvent := CPEscalationEndEvent new identifier: 'escalationEnd'; yourself.
	endEvent eventDefinitions add: (CPEscalationEventDefinition new
		identifier: 'thrownEscalation';
		escalationRef: escalation;
		yourself).
	self assert: (CPEndEvent endEventTypes includes: CPEscalationEndEvent).
	self assert: (boundary catchesEscalation: escalation).
	self assert: (boundary catchesEscalation: otherEscalation) not.
	self assert: endEvent eventDefinitions first escalationRef == escalation.
	^ endEvent
]

{ #category : 'examples - escalation events' }
CPExecutionKernelExamples >> escalationEndEventIsCaughtByNonInterruptingBoundaryEvent [
	<gtExample>
	| process subProcess innerStart escalationEnd innerFlow escalation thrownDefinition boundary caughtDefinition after boundaryFlow execution subProcessExecution childScope boundaryExecution endActivation |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	innerStart := CPNoneStartEvent new identifier: 'innerStart'; yourself.
	escalation := CPEscalation new identifier: 'businessEscalation'; yourself.
	thrownDefinition := CPEscalationEventDefinition new identifier: 'thrownEscalation'; escalationRef: escalation; yourself.
	escalationEnd := CPEscalationEndEvent new identifier: 'escalationEnd'; yourself.
	escalationEnd eventDefinitions add: thrownDefinition.
	innerFlow := CPSequenceFlow new identifier: 'toEscalation'; sourceRef: innerStart; targetRef: escalationEnd; yourself.
	subProcess addFlowElement: innerStart.
	subProcess addFlowElement: escalationEnd.
	subProcess addFlowElement: innerFlow.
	caughtDefinition := CPEscalationEventDefinition new identifier: 'caughtEscalation'; escalationRef: escalation; yourself.
	boundary := CPBoundaryEvent new identifier: 'escalationBoundary'; attachedToRef: subProcess; cancelActivity: false; yourself.
	boundary eventDefinitions add: caughtDefinition.
	after := CPTask new identifier: 'afterEscalation'; yourself.
	boundaryFlow := CPSequenceFlow new identifier: 'afterBoundary'; sourceRef: boundary; targetRef: after; yourself.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subProcessExecution.
	boundaryExecution := execution beginBoundaryEvent: boundary attachedTo: subProcessExecution.
	childScope := subProcessExecution subScope.
	endActivation := (childScope availableFlowActivationsOn: innerFlow) first.
	childScope executeEscalationEndEvent: escalationEnd consuming: endActivation.
	self assert: subProcessExecution isActive.
	self assert: boundaryExecution isTriggered.
	self assert: boundaryExecution occurrence definition == escalation.
	self assert: (execution availableFlowActivationsOn: boundaryFlow) size equals: 1.
	self assert: endActivation isAvailable not.
	^ boundaryExecution
]


{ #category : 'examples - escalation events' }
CPExecutionKernelExamples >> escalationEndEventIsCaughtByInterruptingBoundaryEvent [
	<gtExample>
	| process subProcess innerStart escalationEnd competingReceive toEscalation toReceive escalation thrownDefinition boundary caughtDefinition after boundaryFlow message execution subProcessExecution childScope boundaryExecution endActivation receiveExecution |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	innerStart := CPNoneStartEvent new identifier: 'innerStart'; yourself.
	escalation := CPEscalation new identifier: 'businessEscalation'; yourself.
	thrownDefinition := CPEscalationEventDefinition new identifier: 'thrownEscalation'; escalationRef: escalation; yourself.
	escalationEnd := CPEscalationEndEvent new identifier: 'escalationEnd'; yourself.
	escalationEnd eventDefinitions add: thrownDefinition.
	message := CPMessage new identifier: 'competingMessage'; yourself.
	competingReceive := CPReceiveTask new identifier: 'competingReceive'; messageRef: message; yourself.
	toEscalation := CPSequenceFlow new identifier: 'toEscalation'; sourceRef: innerStart; targetRef: escalationEnd; yourself.
	toReceive := CPSequenceFlow new identifier: 'toReceive'; sourceRef: innerStart; targetRef: competingReceive; yourself.
	subProcess addFlowElement: innerStart.
	subProcess addFlowElement: escalationEnd.
	subProcess addFlowElement: competingReceive.
	subProcess addFlowElement: toEscalation.
	subProcess addFlowElement: toReceive.
	caughtDefinition := CPEscalationEventDefinition new identifier: 'caughtEscalation'; escalationRef: escalation; yourself.
	boundary := CPBoundaryEvent new identifier: 'escalationBoundary'; attachedToRef: subProcess; cancelActivity: true; yourself.
	boundary eventDefinitions add: caughtDefinition.
	after := CPTask new identifier: 'afterEscalation'; yourself.
	boundaryFlow := CPSequenceFlow new identifier: 'afterBoundary'; sourceRef: boundary; targetRef: after; yourself.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subProcessExecution.
	boundaryExecution := execution beginBoundaryEvent: boundary attachedTo: subProcessExecution.
	childScope := subProcessExecution subScope.
	receiveExecution := childScope createReceiveTaskExecutionFor: competingReceive.
	childScope activateReceiveTaskExecution: receiveExecution.
	endActivation := (childScope availableFlowActivationsOn: toEscalation) first.
	childScope executeEscalationEndEvent: escalationEnd consuming: endActivation.
	self assert: subProcessExecution state class = CPActivityTerminatedState.
	self assert: boundaryExecution isTriggered.
	self assert: boundaryExecution occurrence definition == escalation.
	self assert: receiveExecution isFinal.
	self assert: receiveExecution subscription isWaiting not.
	self assert: (execution availableFlowActivationsOn: boundaryFlow) size equals: 1.
	self assert: (childScope flowActivations noneSatisfy: [ :each | each isAvailable ]).
	^ boundaryExecution
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> compensationEventFamilyIsExplicitlyModelled [
	<gtExample>
	| activity boundary definition throwEvent endEvent |
	activity := CPTask new identifier: 'compensatedActivity'; yourself.
	definition := CPCompensationEventDefinition new
		identifier: 'compensation';
		activityRef: activity;
		yourself.
	boundary := CPBoundaryEvent new identifier: 'compensationBoundary'; attachedToRef: activity; cancelActivity: false; yourself.
	boundary eventDefinitions add: definition.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: (CPCompensationEventDefinition new identifier: 'throwDefinition'; activityRef: activity; yourself).
	endEvent := CPCompensationEndEvent new identifier: 'endCompensation'; yourself.
	endEvent eventDefinitions add: (CPCompensationEventDefinition new identifier: 'endDefinition'; activityRef: activity; yourself).
	self assert: (CPBoundaryEvent eventDefinitionTypes includes: CPCompensationEventDefinition).
	self assert: (CPEvent intermediateEventTypes includes: CPCompensationThrowIntermediateEvent).
	self assert: (CPEndEvent endEventTypes includes: CPCompensationEndEvent).
	self assert: boundary eventDefinitions first == definition.
	self assert: throwEvent eventDefinitions first activityRef == activity.
	self assert: endEvent eventDefinitions first activityRef == activity.
	^ boundary
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> completedActivityCreatesDurableCompensationRecord [
	<gtExample>
	| process activity boundary definition execution activityExecution records record |
	process := CPProcess new identifier: 'process'; yourself.
	activity := CPTask new identifier: 'compensatedActivity'; yourself.
	process addFlowElement: activity.
	definition := CPCompensationEventDefinition new
		identifier: 'compensation';
		activityRef: activity;
		yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: activity;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: definition.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	activityExecution beginCompletion.
	activityExecution complete.
	records := execution availableCompensationRecords.
	self assert: records size equals: 1.
	record := records first.
	self assert: record activityExecution == activityExecution.
	self assert: record boundaryEvent == boundary.
	self assert: record isAvailable.
	^ record
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> compensationRecordCanBeClaimedExactlyOnce [
	<gtExample>
	| process activity compensationDefinition boundary execution activityExecution record rejected |
	process := CPProcess new identifier: 'process'; yourself.
	activity := CPTask new identifier: 'work'; yourself.
	compensationDefinition := CPCompensationEventDefinition new
		identifier: 'compensation';
		yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: activity;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: compensationDefinition.
	activity boundaryEventRefs add: boundary.
	process addFlowElement: activity.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	activityExecution beginCompletion.
	activityExecution complete.
	record := execution claimCompensationRecordFor: activityExecution.
	self assert: record isClaimed.
	self assert: record isAvailable not.
	self assert: (execution availableCompensationRecords includes: record) not.
	self assert: (execution availableCompensationRecordsFor: activity) isEmpty.
	rejected := false.
	[ execution claimCompensationRecordFor: activityExecution ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	^ record
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> processExecutionDiscoversCompensationHistoryInNestedScopes [
	<gtExample>
	| process subProcess activity compensationDefinition boundary execution subProcessExecution childScope activityExecution records |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	activity := CPTask new identifier: 'nestedWork'; yourself.
	compensationDefinition := CPCompensationEventDefinition new
		identifier: 'compensation';
		yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: activity;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: compensationDefinition.
	subProcess addFlowElement: activity.
	process addFlowElement: subProcess.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subProcessExecution.
	childScope := subProcessExecution subScope.
	activityExecution := childScope createActivityExecutionFor: activity.
	activityExecution activate.
	activityExecution beginCompletion.
	activityExecution complete.
	self assert: execution availableCompensationRecords isEmpty.
	records := execution allAvailableCompensationRecords.
	self assert: records size equals: 1.
	self assert: records first activityExecution == activityExecution.
	self assert: records first boundaryEvent == boundary.
	self assert: (execution allAvailableCompensationRecordsFor: activity) size equals: 1.
	^ records first
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> compensationBoundaryAssociatesWithExplicitHandlerActivity [
	<gtExample>
	| process activity compensationDefinition boundary handler association |
	process := CPProcess new identifier: 'process'; yourself.
	activity := CPTask new identifier: 'work'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensation'; yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: activity;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: compensationDefinition.
	handler := CPTask new identifier: 'undoWork'; isForCompensation: true; yourself.
	process addFlowElement: activity.
	process addFlowElement: handler.
	association := CPAssociation new
		identifier: 'compensationHandler';
		sourceRef: boundary;
		targetRef: handler;
		beOne;
		yourself.
	process addArtifact: association.
	self assert: association container == process.
	self assert: association sourceRef == boundary.
	self assert: association targetRef == handler.
	self assert: association associationDirection equals: 'One'.
	self assert: handler isForCompensation.
	self assert: process artifacts size equals: 1.
	^ association
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> compensationRecordResolvesExplicitHandlerActivity [
	<gtExample>
	| process activity compensationDefinition boundary handler association execution activityExecution record resolvedHandler |
	process := CPProcess new identifier: 'process'; yourself.
	activity := CPTask new identifier: 'work'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensation'; yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: activity;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: compensationDefinition.
	handler := CPTask new identifier: 'undoWork'; isForCompensation: true; yourself.
	process addFlowElement: activity.
	process addFlowElement: handler.
	association := CPAssociation new
		identifier: 'compensationHandler';
		sourceRef: boundary;
		targetRef: handler;
		beOne;
		yourself.
	process addArtifact: association.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	activityExecution beginCompletion.
	activityExecution complete.
	record := execution availableCompensationRecords first.
	resolvedHandler := execution compensationHandlerFor: record.
	self assert: resolvedHandler == handler.
	self assert: resolvedHandler isForCompensation.
	self assert: record boundaryEvent == boundary.
	^ resolvedHandler
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> compensationRecordBeginsExplicitHandlerExactlyOnce [
	<gtExample>
	| process activity compensationDefinition boundary handler association execution activityExecution record handlerExecution rejected |
	process := CPProcess new identifier: 'process'; yourself.
	activity := CPTask new identifier: 'work'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensation'; yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: activity;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: compensationDefinition.
	handler := CPTask new identifier: 'undoWork'; isForCompensation: true; yourself.
	process addFlowElement: activity.
	process addFlowElement: handler.
	association := CPAssociation new
		identifier: 'compensationHandler';
		sourceRef: boundary;
		targetRef: handler;
		beOne;
		yourself.
	process addArtifact: association.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	activityExecution beginCompletion.
	activityExecution complete.
	record := execution availableCompensationRecords first.
	handlerExecution := execution beginCompensationFor: record.
	self assert: record isClaimed.
	self assert: record isHandling.
	self assert: record handlerExecution == handlerExecution.
	self assert: handlerExecution definition == handler.
	self assert: handlerExecution scope == execution.
	self assert: handlerExecution isActive.
	self assert: (execution availableCompensationRecords includes: record) not.
	rejected := false.
	[ execution beginCompensationFor: record ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: record handlerExecution == handlerExecution.
	^ record
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> targetedAsynchronousCompensationThrowBeginsHandlerAndContinues [
	<gtExample>
	| process work compensationDefinition boundary handler association before throwDefinition throwEvent after incoming outgoing execution workExecution record producer activation throwExecution |
	process := CPProcess new identifier: 'process'; yourself.
	work := CPTask new identifier: 'work'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'workCompensation'; yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: work;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: compensationDefinition.
	handler := CPTask new identifier: 'undoWork'; isForCompensation: true; yourself.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new
		identifier: 'throwDefinition';
		activityRef: work;
		waitForCompletion: false;
		yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	after := CPTask new identifier: 'afterThrow'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrowFlow'; sourceRef: throwEvent; targetRef: after; yourself.
	process
		addFlowElement: work;
		addFlowElement: handler;
		addFlowElement: before;
		addFlowElement: throwEvent;
		addFlowElement: after;
		addFlowElement: incoming;
		addFlowElement: outgoing.
	self assert: work container == process.
	self assert: handler container == process.
	self assert: throwEvent container == process.
	association := CPAssociation new
		identifier: 'compensationHandler';
		sourceRef: boundary;
		targetRef: handler;
		beOne;
		yourself.
	process addArtifact: association.
	execution := self executionFor: process.
	workExecution := execution createActivityExecutionFor: work.
	workExecution activate.
	workExecution beginCompletion.
	workExecution complete.
	record := execution availableCompensationRecords first.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	self assert: throwExecution isCompleted.
	self assert: activation isAvailable not.
	self assert: record isClaimed.
	self assert: record isHandling.
	self assert: record handlerExecution definition == handler.
	self assert: record handlerExecution isActive.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ throwExecution
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> targetedSynchronousCompensationThrowWaitsForHandlerCompletion [
	<gtExample>
	| process work compensationDefinition boundary handler association before throwDefinition throwEvent after incoming outgoing execution workExecution record producer activation throwExecution handlerExecution |
	process := CPProcess new identifier: 'process'; yourself.
	work := CPTask new identifier: 'work'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'workCompensation'; yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: work;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: compensationDefinition.
	handler := CPTask new identifier: 'undoWork'; isForCompensation: true; yourself.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new
		identifier: 'throwDefinition';
		activityRef: work;
		waitForCompletion: true;
		yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	after := CPTask new identifier: 'afterThrow'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrowFlow'; sourceRef: throwEvent; targetRef: after; yourself.
	process
		addFlowElement: work;
		addFlowElement: handler;
		addFlowElement: before;
		addFlowElement: throwEvent;
		addFlowElement: after;
		addFlowElement: incoming;
		addFlowElement: outgoing.
	association := CPAssociation new
		identifier: 'compensationHandler';
		sourceRef: boundary;
		targetRef: handler;
		beOne;
		yourself.
	process addArtifact: association.
	execution := self executionFor: process.
	workExecution := execution createActivityExecutionFor: work.
	workExecution activate.
	workExecution beginCompletion.
	workExecution complete.
	record := execution availableCompensationRecords first.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	handlerExecution := record handlerExecution.
	self assert: throwExecution isPending.
	self assert: throwExecution isWaitingForCompensation.
	self assert: throwExecution compensationRecord == record.
	self assert: record isHandling.
	self assert: handlerExecution isActive.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	handlerExecution beginCompletion.
	handlerExecution complete.
	self assert: record isHandled.
	self assert: throwExecution isCompleted.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ throwExecution
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> compensationHistoryPreservesGlobalReverseCompletionOrderAcrossScopes [
	<gtExample>
	| process outerWork outerDefinition outerBoundary nestedProcess nestedWork nestedDefinition nestedBoundary execution outerExecution ownerExecution nestedScope nestedExecution ordered |
	process := CPProcess new identifier: 'process'; yourself.
	outerWork := CPTask new identifier: 'outerWork'; yourself.
	outerDefinition := CPCompensationEventDefinition new identifier: 'outerCompensation'; yourself.
	outerBoundary := CPBoundaryEvent new identifier: 'outerBoundary'; attachedToRef: outerWork; cancelActivity: false; yourself.
	outerBoundary eventDefinitions add: outerDefinition.
	nestedProcess := CPSubProcess new identifier: 'nested'; yourself.
	nestedWork := CPTask new identifier: 'nestedWork'; yourself.
	nestedDefinition := CPCompensationEventDefinition new identifier: 'nestedCompensation'; yourself.
	nestedBoundary := CPBoundaryEvent new identifier: 'nestedBoundary'; attachedToRef: nestedWork; cancelActivity: false; yourself.
	nestedBoundary eventDefinitions add: nestedDefinition.
	process addFlowElement: outerWork; addFlowElement: nestedProcess.
	nestedProcess addFlowElement: nestedWork.
	execution := self executionFor: process.
	outerExecution := execution createActivityExecutionFor: outerWork.
	outerExecution activate; beginCompletion; complete.
	ownerExecution := execution createActivityExecutionFor: nestedProcess.
	nestedScope := CPExecutionScope for: nestedProcess ownedBy: ownerExecution.
	nestedExecution := nestedScope createActivityExecutionFor: nestedWork.
	nestedExecution activate; beginCompletion; complete.
	ordered := execution allAvailableCompensationRecordsInReverseCompletionOrder.
	self assert: ordered size equals: 2.
	self assert: ordered first activityExecution == nestedExecution.
	self assert: ordered second activityExecution == outerExecution.
	self assert: ordered first completionSequence > ordered second completionSequence.
	^ ordered
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> asynchronousScopeCompensationBeginsHandlersInReverseCompletionOrderAndContinues [
	<gtExample>
	| process firstWork firstBoundary firstDefinition firstHandler firstAssociation secondWork secondBoundary secondDefinition secondHandler secondAssociation before throwDefinition throwEvent after incoming outgoing execution firstExecution secondExecution ordered producer activation throwExecution |
	process := CPProcess new identifier: 'process'; yourself.
	firstWork := CPTask new identifier: 'firstWork'; yourself.
	firstDefinition := CPCompensationEventDefinition new identifier: 'firstCompensation'; yourself.
	firstBoundary := CPBoundaryEvent new identifier: 'firstBoundary'; attachedToRef: firstWork; cancelActivity: false; yourself.
	firstBoundary eventDefinitions add: firstDefinition.
	firstHandler := CPTask new identifier: 'undoFirst'; isForCompensation: true; yourself.
	secondWork := CPTask new identifier: 'secondWork'; yourself.
	secondDefinition := CPCompensationEventDefinition new identifier: 'secondCompensation'; yourself.
	secondBoundary := CPBoundaryEvent new identifier: 'secondBoundary'; attachedToRef: secondWork; cancelActivity: false; yourself.
	secondBoundary eventDefinitions add: secondDefinition.
	secondHandler := CPTask new identifier: 'undoSecond'; isForCompensation: true; yourself.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new identifier: 'throwDefinition'; waitForCompletion: false; yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	after := CPTask new identifier: 'afterThrow'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrowFlow'; sourceRef: throwEvent; targetRef: after; yourself.
	{ firstWork. firstHandler. secondWork. secondHandler. before. throwEvent. after. incoming. outgoing } do: [ :each | process addFlowElement: each ].
	firstAssociation := CPAssociation new identifier: 'firstHandler'; sourceRef: firstBoundary; targetRef: firstHandler; beOne; yourself.
	secondAssociation := CPAssociation new identifier: 'secondHandler'; sourceRef: secondBoundary; targetRef: secondHandler; beOne; yourself.
	process addArtifact: firstAssociation; addArtifact: secondAssociation.
	execution := self executionFor: process.
	firstExecution := execution createActivityExecutionFor: firstWork.
	firstExecution activate; beginCompletion; complete.
	secondExecution := execution createActivityExecutionFor: secondWork.
	secondExecution activate; beginCompletion; complete.
	ordered := execution allAvailableCompensationRecordsInReverseCompletionOrder.
	self assert: ordered size equals: 2.
	self assert: ordered first activityExecution == secondExecution.
	self assert: ordered second activityExecution == firstExecution.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	self assert: throwExecution isCompleted.
	self assert: activation isAvailable not.
	self assert: ordered first isHandling.
	self assert: ordered second isHandling.
	self assert: ordered first handlerExecution definition == secondHandler.
	self assert: ordered second handlerExecution definition == firstHandler.
	self assert: ordered first handlerExecution isActive.
	self assert: ordered second handlerExecution isActive.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ throwExecution
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> synchronousScopeCompensationRunsHandlersSequentiallyInReverseCompletionOrder [
	<gtExample>
	| process firstWork firstBoundary firstDefinition firstHandler firstAssociation secondWork secondBoundary secondDefinition secondHandler secondAssociation before throwDefinition throwEvent after incoming outgoing execution firstExecution secondExecution ordered producer activation throwExecution secondHandlerExecution firstHandlerExecution |
	process := CPProcess new identifier: 'process'; yourself.
	firstWork := CPTask new identifier: 'firstWork'; yourself.
	firstDefinition := CPCompensationEventDefinition new identifier: 'firstCompensation'; yourself.
	firstBoundary := CPBoundaryEvent new identifier: 'firstBoundary'; attachedToRef: firstWork; cancelActivity: false; yourself.
	firstBoundary eventDefinitions add: firstDefinition.
	firstHandler := CPTask new identifier: 'undoFirst'; isForCompensation: true; yourself.
	secondWork := CPTask new identifier: 'secondWork'; yourself.
	secondDefinition := CPCompensationEventDefinition new identifier: 'secondCompensation'; yourself.
	secondBoundary := CPBoundaryEvent new identifier: 'secondBoundary'; attachedToRef: secondWork; cancelActivity: false; yourself.
	secondBoundary eventDefinitions add: secondDefinition.
	secondHandler := CPTask new identifier: 'undoSecond'; isForCompensation: true; yourself.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new identifier: 'throwDefinition'; waitForCompletion: true; yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	after := CPTask new identifier: 'afterThrow'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrowFlow'; sourceRef: throwEvent; targetRef: after; yourself.
	{ firstWork. firstHandler. secondWork. secondHandler. before. throwEvent. after. incoming. outgoing } do: [ :each | process addFlowElement: each ].
	firstAssociation := CPAssociation new identifier: 'firstHandler'; sourceRef: firstBoundary; targetRef: firstHandler; beOne; yourself.
	secondAssociation := CPAssociation new identifier: 'secondHandler'; sourceRef: secondBoundary; targetRef: secondHandler; beOne; yourself.
	process addArtifact: firstAssociation; addArtifact: secondAssociation.
	execution := self executionFor: process.
	firstExecution := execution createActivityExecutionFor: firstWork.
	firstExecution activate; beginCompletion; complete.
	secondExecution := execution createActivityExecutionFor: secondWork.
	secondExecution activate; beginCompletion; complete.
	ordered := execution allAvailableCompensationRecordsInReverseCompletionOrder.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	secondHandlerExecution := ordered first handlerExecution.
	self assert: throwExecution isPending.
	self assert: throwExecution compensationRecords size equals: 2.
	self assert: throwExecution currentCompensationRecord == ordered first.
	self assert: ordered first isHandling.
	self assert: ordered second isAvailable.
	self assert: ordered second handlerExecution isNil.
	self assert: secondHandlerExecution definition == secondHandler.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	secondHandlerExecution beginCompletion; complete.
	firstHandlerExecution := ordered second handlerExecution.
	self assert: ordered first isHandled.
	self assert: throwExecution isPending.
	self assert: throwExecution currentCompensationRecord == ordered second.
	self assert: ordered second isHandling.
	self assert: firstHandlerExecution definition == firstHandler.
	self assert: firstHandlerExecution isActive.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	firstHandlerExecution beginCompletion; complete.
	self assert: ordered second isHandled.
	self assert: throwExecution isCompleted.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ throwExecution
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> compensationHandlerCompletionDoesNotCreateCompensationHistory [
	<gtExample>
	| process handler handlerBoundary handlerDefinition nestedHandler association execution handlerExecution |
	process := CPProcess new identifier: 'process'; yourself.
	handler := CPTask new identifier: 'compensationHandler'; isForCompensation: true; yourself.
	handlerDefinition := CPCompensationEventDefinition new identifier: 'handlerCompensation'; yourself.
	handlerBoundary := CPBoundaryEvent new
		identifier: 'handlerBoundary';
		attachedToRef: handler;
		cancelActivity: false;
		yourself.
	handlerBoundary eventDefinitions add: handlerDefinition.
	nestedHandler := CPTask new identifier: 'nestedUndo'; isForCompensation: true; yourself.
	{ handler. nestedHandler } do: [ :each | process addFlowElement: each ].
	association := CPAssociation new
		identifier: 'handlerAssociation';
		sourceRef: handlerBoundary;
		targetRef: nestedHandler;
		beOne;
		yourself.
	process addArtifact: association.
	execution := self executionFor: process.
	handlerExecution := execution createActivityExecutionFor: handler.
	handlerExecution activate; beginCompletion; complete.
	self assert: handlerExecution isCompleted.
	self assert: execution compensationRecords isEmpty.
	self assert: execution allAvailableCompensationRecords isEmpty.
	^ handlerExecution
]
