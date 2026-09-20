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
	execution := CPActivityExecution new
		definition: (CPTask new identifier: 'activity'; yourself);
		yourself.
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
	process addFlowElement: activity.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	activityExecution beginCompletion.
	activityExecution complete.
	record := execution claimCompensationRecord: execution availableCompensationRecords first.
	self assert: record isClaimed.
	self assert: record isAvailable not.
	self assert: (execution availableCompensationRecords includes: record) not.
	self assert: (execution availableCompensationRecordsFor: activity) isEmpty.
	rejected := false.
	[ execution claimCompensationRecord: record ]
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
CPExecutionKernelExamples >> defaultCompensationOrdersActualSequenceFlowConsumerBeforeProducer [
	<gtExample>
	| process firstWork firstDefinition firstBoundary secondWork secondDefinition secondBoundary flow execution firstExecution activation secondExecution records |
	process := CPProcess new identifier: 'process'; yourself.
	firstWork := CPTask new identifier: 'firstWork'; yourself.
	firstDefinition := CPCompensationEventDefinition new identifier: 'firstCompensation'; yourself.
	firstBoundary := CPBoundaryEvent new identifier: 'firstBoundary'; attachedToRef: firstWork; cancelActivity: false; yourself.
	firstBoundary eventDefinitions add: firstDefinition.
	secondWork := CPTask new identifier: 'secondWork'; yourself.
	secondDefinition := CPCompensationEventDefinition new identifier: 'secondCompensation'; yourself.
	secondBoundary := CPBoundaryEvent new identifier: 'secondBoundary'; attachedToRef: secondWork; cancelActivity: false; yourself.
	secondBoundary eventDefinitions add: secondDefinition.
	flow := CPSequenceFlow new identifier: 'firstToSecond'; sourceRef: firstWork; targetRef: secondWork; yourself.
	{ firstWork. secondWork. flow } do: [ :each | process addFlowElement: each ].
	execution := self executionFor: process.
	firstExecution := execution createActivityExecutionFor: firstWork.
	firstExecution activate; beginCompletion; complete.
	execution produceOutgoingControlFor: firstExecution.
	activation := (execution availableFlowActivationsOn: flow) first.
	secondExecution := execution readyActivityExecutionFor: secondWork.
	secondExecution activate; beginCompletion; complete.
	records := execution defaultCompensationRecords.
	self assert: activation producedBy == firstExecution.
	self assert: activation consumedBy == secondExecution.
	self assert: records size equals: 2.
	self assert: records first activityExecution == secondExecution.
	self assert: records second activityExecution == firstExecution.
	^ records
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> defaultCompensationOrdersBoundaryFlowConsumerBeforeAttachedActivity [
	<gtExample>
	| process firstWork firstDefinition firstCompensationBoundary noticeBoundary secondWork secondDefinition secondCompensationBoundary flow execution firstExecution noticeExecution occurrence activation secondExecution records ready |
	process := CPProcess new identifier: 'process'; yourself.
	firstWork := CPTask new identifier: 'firstWork'; yourself.
	firstDefinition := CPCompensationEventDefinition new identifier: 'firstCompensation'; yourself.
	firstCompensationBoundary := CPBoundaryEvent new
		identifier: 'firstCompensationBoundary';
		attachedToRef: firstWork;
		cancelActivity: false;
		yourself.
	firstCompensationBoundary eventDefinitions add: firstDefinition.
	noticeBoundary := CPBoundaryEvent new
		identifier: 'noticeBoundary';
		attachedToRef: firstWork;
		cancelActivity: false;
		yourself.
	secondWork := CPTask new identifier: 'secondWork'; yourself.
	secondDefinition := CPCompensationEventDefinition new identifier: 'secondCompensation'; yourself.
	secondCompensationBoundary := CPBoundaryEvent new
		identifier: 'secondCompensationBoundary';
		attachedToRef: secondWork;
		cancelActivity: false;
		yourself.
	secondCompensationBoundary eventDefinitions add: secondDefinition.
	flow := CPSequenceFlow new identifier: 'noticeToSecond'; sourceRef: noticeBoundary; targetRef: secondWork; yourself.
	{ firstWork. secondWork. flow } do: [ :each | process addFlowElement: each ].
	execution := self executionFor: process.
	firstExecution := execution createActivityExecutionFor: firstWork.
	firstExecution activate.
	noticeExecution := execution beginBoundaryEvent: noticeBoundary attachedTo: firstExecution.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: #notice1;
		definition: noticeBoundary;
		yourself.
	execution triggerBoundaryEventExecution: noticeExecution with: occurrence.
	activation := (execution availableFlowActivationsOn: flow) first.
	secondExecution := execution readyActivityExecutionFor: secondWork.
	secondExecution activate; beginCompletion; complete.
	firstExecution beginCompletion; complete.
	records := execution defaultCompensationRecords.
	ready := execution readyDefaultCompensationRecordsIn: records.
	self assert: noticeExecution attachedActivityExecution == firstExecution.
	self assert: activation producedBy == noticeExecution.
	self assert: activation consumedBy == secondExecution.
	self assert: records size equals: 2.
	self assert: records first activityExecution == secondExecution.
	self assert: records second activityExecution == firstExecution.
	self assert: ready size equals: 1.
	self assert: ready first activityExecution == secondExecution.
	^ records
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
CPExecutionKernelExamples >> synchronousScopeCompensationStartsIndependentHandlersTogetherAndWaitsForAll [
	<gtExample>
	| process firstWork firstBoundary firstDefinition firstHandler firstAssociation secondWork secondBoundary secondDefinition secondHandler secondAssociation before throwDefinition throwEvent after incoming outgoing execution firstExecution secondExecution records firstRecord secondRecord producer activation throwExecution firstHandlerExecution secondHandlerExecution |
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
	records := execution defaultCompensationRecords.
	firstRecord := records detect: [ :each | each activityExecution == firstExecution ].
	secondRecord := records detect: [ :each | each activityExecution == secondExecution ].
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	firstHandlerExecution := firstRecord handlerExecution.
	secondHandlerExecution := secondRecord handlerExecution.
	self assert: throwExecution isPending.
	self assert: firstRecord isHandling.
	self assert: secondRecord isHandling.
	self assert: firstHandlerExecution definition == firstHandler.
	self assert: secondHandlerExecution definition == secondHandler.
	self assert: firstHandlerExecution isActive.
	self assert: secondHandlerExecution isActive.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	secondHandlerExecution beginCompletion; complete.
	self assert: secondRecord isHandled.
	self assert: firstRecord isHandling.
	self assert: throwExecution isPending.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	firstHandlerExecution beginCompletion; complete.
	self assert: firstRecord isHandled.
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


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> compensationEndEventWaitsForScopeCompensationBeforeProcessCanComplete [
	<gtExample>
	| process start work boundary compensationDefinition handler association before endDefinition endEvent incoming execution workExecution records producer activation endExecution handlerExecution |
	process := CPProcess new identifier: 'process'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	work := CPTask new identifier: 'work'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'workCompensation'; yourself.
	boundary := CPBoundaryEvent new identifier: 'compensationBoundary'; attachedToRef: work; cancelActivity: false; yourself.
	boundary eventDefinitions add: compensationDefinition.
	handler := CPTask new identifier: 'undoWork'; isForCompensation: true; yourself.
	before := CPTask new identifier: 'beforeEnd'; yourself.
	endDefinition := CPCompensationEventDefinition new identifier: 'endCompensation'; waitForCompletion: true; yourself.
	endEvent := CPCompensationEndEvent new identifier: 'compensationEnd'; yourself.
	endEvent eventDefinitions add: endDefinition.
	incoming := CPSequenceFlow new identifier: 'toCompensationEnd'; sourceRef: before; targetRef: endEvent; yourself.
	{ start. work. handler. before. endEvent. incoming } do: [ :each | process addFlowElement: each ].
	association := CPAssociation new identifier: 'handlerAssociation'; sourceRef: boundary; targetRef: handler; beOne; yourself.
	process addArtifact: association.
	execution := self executionFor: process.
	execution start.
	self assert: execution isStarted.
	workExecution := execution createActivityExecutionFor: work.
	workExecution activate; beginCompletion; complete.
	records := execution allAvailableCompensationRecords.
	self assert: records size equals: 1.
	producer := execution createActivityExecutionFor: before.
	producer activate; beginCompletion; complete.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	endExecution := execution executeCompensationEndEvent: endEvent consuming: activation.
	handlerExecution := records first handlerExecution.
	self assert: endExecution isPending.
	self assert: handlerExecution definition == handler.
	self assert: handlerExecution isActive.
	self assert: execution canComplete not.
	handlerExecution beginCompletion; complete.
	self assert: records first isHandled.
	self assert: endExecution isCompleted.
	self assert: execution canComplete.
	execution complete.
	self assert: execution isCompleted.
	^ endExecution
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> compensationActivityIsOutsideNormalFlow [
	<gtExample>
	| process before handler incoming execution producer activation rejected subProcess subExecution |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	handler := CPTask new identifier: 'undoWork'; isForCompensation: true; yourself.
	incoming := CPSequenceFlow new identifier: 'toHandler'; sourceRef: before; targetRef: handler; yourself.
	{ before. handler. incoming } do: [ :each | process addFlowElement: each ].
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: before.
	producer activate; beginCompletion; complete.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	rejected := false.
	[ execution readyActivityExecutionFor: handler ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: activation isAvailable.
	self assert: (execution activityExecutions noneSatisfy: [ :each | each definition == handler ]).

	subProcess := CPNoneSubProcess new identifier: 'subProcess'; yourself.
	subProcess addFlowElement: (CPTask new identifier: 'nestedUndo'; isForCompensation: true; yourself).
	subExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subExecution.
	self assert: subExecution subScope flowActivations isEmpty.
	^ handler
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> compensationEventSubProcessIsExplicitCompensationHandler [
	<gtExample>
	| handler start definition |
	handler := CPCompensationSubProcess new identifier: 'compensationHandler'; yourself.
	start := CPCompensationStartEvent new identifier: 'compensationStart'; yourself.
	definition := CPCompensationEventDefinition new identifier: 'compensationDefinition'; yourself.
	start eventDefinitions add: definition.
	handler addFlowElement: start.
	self assert: handler isSubProcess.
	self assert: handler isForCompensation.
	self assert: start isStartEvent.
	self assert: start container == handler.
	self assert: start eventDefinitions size equals: 1.
	self assert: start eventDefinitions first == definition.
	self assert: definition isCompensationEventDefinition.
	self assert: (CPStartEvent startEventTypes includes: CPCompensationStartEvent).
	^ handler
]



{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> subProcessCanDeclareImplicitDefaultCompensation [
	<gtExample>
	| subProcess |
	subProcess := CPNoneSubProcess new identifier: 'booking'; yourself.
	self assert: subProcess compensable not.
	subProcess compensable: true.
	self assert: subProcess compensable.
	self assert: subProcess isForCompensation not.
	^ subProcess
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> completedCompensableSubProcessEntersCompensationHistory [
	<gtExample>
	| process subProcess execution subExecution records |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPNoneSubProcess new identifier: 'booking'; compensable: true; yourself.
	process addFlowElement: subProcess.
	execution := self executionFor: process.
	subExecution := execution createActivityExecutionFor: subProcess.
	subExecution activate; beginCompletion; complete.
	records := execution availableCompensationRecordsFor: subProcess.
	self assert: records size equals: 1.
	self assert: records first activityExecution == subExecution.
	self assert: records first boundaryEvent isNil.
	self assert: records first isAvailable.
	^ records first
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> targetedDefaultSubProcessCompensationUsesExactCompletedScope [
	<gtExample>
	| process outside outsideBoundary outsideDefinition outsideHandler outsideAssociation booking work workBoundary workDefinition workHandler workAssociation before throwDefinition throwEvent after incoming outgoing execution outsideExecution bookingExecution bookingScope workExecution bookingRecord producer activation throwExecution workRecord handlerExecution |
	process := CPProcess new identifier: 'process'; yourself.
	outside := CPTask new identifier: 'outside'; yourself.
	outsideDefinition := CPCompensationEventDefinition new identifier: 'outsideCompensation'; yourself.
	outsideBoundary := CPBoundaryEvent new identifier: 'outsideBoundary'; attachedToRef: outside; cancelActivity: false; yourself.
	outsideBoundary eventDefinitions add: outsideDefinition.
	outsideHandler := CPTask new identifier: 'undoOutside'; isForCompensation: true; yourself.
	booking := CPNoneSubProcess new identifier: 'booking'; compensable: true; yourself.
	work := CPTask new identifier: 'work'; yourself.
	workDefinition := CPCompensationEventDefinition new identifier: 'workCompensation'; yourself.
	workBoundary := CPBoundaryEvent new identifier: 'workBoundary'; attachedToRef: work; cancelActivity: false; yourself.
	workBoundary eventDefinitions add: workDefinition.
	workHandler := CPTask new identifier: 'undoWork'; isForCompensation: true; yourself.
	booking addFlowElement: work; addFlowElement: workHandler.
	workAssociation := CPAssociation new identifier: 'workAssociation'; sourceRef: workBoundary; targetRef: workHandler; beOne; yourself.
	booking addArtifact: workAssociation.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new identifier: 'throwDefinition'; activityRef: booking; waitForCompletion: true; yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	after := CPTask new identifier: 'afterThrow'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrowFlow'; sourceRef: throwEvent; targetRef: after; yourself.
	process addFlowElement: outside; addFlowElement: outsideHandler; addFlowElement: booking; addFlowElement: before; addFlowElement: throwEvent; addFlowElement: after; addFlowElement: incoming; addFlowElement: outgoing.
	outsideAssociation := CPAssociation new identifier: 'outsideAssociation'; sourceRef: outsideBoundary; targetRef: outsideHandler; beOne; yourself.
	process addArtifact: outsideAssociation.
	execution := self executionFor: process.
	outsideExecution := execution createActivityExecutionFor: outside.
	outsideExecution activate; beginCompletion; complete.
	bookingExecution := execution createActivityExecutionFor: booking.
	bookingExecution activate.
	bookingScope := bookingExecution createSubScopeFor: booking.
	workExecution := bookingScope createActivityExecutionFor: work.
	workExecution activate; beginCompletion; complete.
	bookingExecution beginCompletion; complete.
	bookingRecord := (execution availableCompensationRecordsFor: booking) first.
	workRecord := (bookingScope availableCompensationRecordsFor: work) first.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	self assert: throwExecution isPending.
	self assert: bookingRecord isHandling.
	self assert: (bookingRecord compensationRecords identityIncludes: workRecord).
	self assert: workRecord isHandling.
	self assert: outsideExecution isCompleted.
	self assert: (execution availableCompensationRecordsFor: outside) size equals: 1.
	handlerExecution := workRecord handlerExecution.
	self assert: handlerExecution definition == workHandler.
	handlerExecution beginCompletion; complete.
	self assert: workRecord isHandled.
	self assert: bookingRecord isHandled.
	self assert: throwExecution isCompleted.
	self assert: (execution availableCompensationRecordsFor: outside) size equals: 1.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ bookingRecord
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> emptyDefaultSubProcessCompensationCompletesSynchronously [
	<gtExample>
	| process booking before throwDefinition throwEvent after incoming outgoing execution bookingExecution producer activation throwExecution bookingRecord |
	process := CPProcess new identifier: 'process'; yourself.
	booking := CPNoneSubProcess new identifier: 'booking'; compensable: true; yourself.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new identifier: 'throwDefinition'; activityRef: booking; waitForCompletion: true; yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	after := CPTask new identifier: 'afterThrow'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrowFlow'; sourceRef: throwEvent; targetRef: after; yourself.
	process addFlowElement: booking; addFlowElement: before; addFlowElement: throwEvent; addFlowElement: after; addFlowElement: incoming; addFlowElement: outgoing.
	execution := self executionFor: process.
	bookingExecution := execution createActivityExecutionFor: booking.
	bookingExecution activate.
	bookingExecution createSubScopeFor: booking.
	bookingExecution beginCompletion; complete.
	bookingRecord := (execution availableCompensationRecordsFor: booking) first.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	self assert: bookingRecord isHandled.
	self assert: throwExecution isCompleted.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ bookingRecord
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> customCompensationEventSubProcessHandlesExactCompletedSubProcess [
	<gtExample>
	| process booking work workBoundary workCompensation workHandler workAssociation compensationHandler compensationStart compensationDefinition undo startFlow before throwDefinition throwEvent after incoming outgoing execution bookingExecution bookingScope workExecution workRecord bookingRecord producer activation throwExecution handlerExecution handlerScope undoExecution |
	process := CPProcess new identifier: 'process'; yourself.
	booking := CPNoneSubProcess new identifier: 'booking'; compensable: true; yourself.
	work := CPTask new identifier: 'work'; yourself.
	workCompensation := CPCompensationEventDefinition new identifier: 'workCompensation'; yourself.
	workBoundary := CPBoundaryEvent new identifier: 'workBoundary'; attachedToRef: work; cancelActivity: false; yourself.
	workBoundary eventDefinitions add: workCompensation.
	workHandler := CPTask new identifier: 'undoWork'; isForCompensation: true; yourself.
	workAssociation := CPAssociation new identifier: 'workAssociation'; sourceRef: workBoundary; targetRef: workHandler; beOne; yourself.
	booking addFlowElement: work; addFlowElement: workHandler; addArtifact: workAssociation.
	compensationHandler := CPCompensationSubProcess new identifier: 'bookingCompensation'; yourself.
	compensationStart := CPCompensationStartEvent new identifier: 'compensationStart'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensationDefinition'; yourself.
	compensationStart eventDefinitions add: compensationDefinition.
	undo := CPTask new identifier: 'undoBooking'; yourself.
	startFlow := CPSequenceFlow new identifier: 'startUndo'; sourceRef: compensationStart; targetRef: undo; yourself.
	compensationHandler addFlowElement: compensationStart; addFlowElement: undo; addFlowElement: startFlow.
	booking addFlowElement: compensationHandler.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new identifier: 'throwDefinition'; activityRef: booking; waitForCompletion: true; yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	after := CPTask new identifier: 'afterThrow'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrowFlow'; sourceRef: throwEvent; targetRef: after; yourself.
	process addFlowElement: booking; addFlowElement: before; addFlowElement: throwEvent; addFlowElement: after; addFlowElement: incoming; addFlowElement: outgoing.
	execution := self executionFor: process.
	bookingExecution := execution createActivityExecutionFor: booking.
	bookingExecution activate.
	bookingScope := bookingExecution createSubScopeFor: booking.
	workExecution := bookingScope createActivityExecutionFor: work.
	workExecution activate; beginCompletion; complete.
	workRecord := (bookingScope availableCompensationRecordsFor: work) first.
	bookingExecution beginCompletion; complete.
	bookingRecord := (execution availableCompensationRecordsFor: booking) first.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	self assert: throwExecution isPending.
	self assert: bookingRecord isHandling.
	self assert: workRecord isAvailable.
	handlerExecution := bookingRecord handlerExecution.
	self assert: handlerExecution definition == compensationHandler.
	self assert: handlerExecution scope == bookingScope.
	self assert: handlerExecution isActive.
	handlerScope := handlerExecution subScope.
	self assert: handlerScope notNil.
	self assert: (handlerScope availableFlowActivationsOn: startFlow) size equals: 1.
	undoExecution := handlerScope readyActivityExecutionFor: undo.
	undoExecution activate; beginCompletion; complete.
	self assert: (bookingScope canCompleteSubProcessActivity: handlerExecution).
	bookingScope completeSubProcessActivity: handlerExecution.
	self assert: bookingRecord isHandled.
	self assert: workRecord isAvailable.
	self assert: throwExecution isCompleted.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ bookingRecord
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> asynchronousCustomCompensationEventSubProcessContinuesImmediately [
	<gtExample>
	| process booking compensationHandler compensationStart compensationDefinition undo startFlow before throwDefinition throwEvent after incoming outgoing execution bookingExecution bookingScope bookingRecord producer activation throwExecution handlerExecution undoExecution |
	process := CPProcess new identifier: 'process'; yourself.
	booking := CPNoneSubProcess new identifier: 'booking'; compensable: true; yourself.
	compensationHandler := CPCompensationSubProcess new identifier: 'bookingCompensation'; yourself.
	compensationStart := CPCompensationStartEvent new identifier: 'compensationStart'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensationDefinition'; yourself.
	compensationStart eventDefinitions add: compensationDefinition.
	undo := CPTask new identifier: 'undoBooking'; yourself.
	startFlow := CPSequenceFlow new identifier: 'startUndo'; sourceRef: compensationStart; targetRef: undo; yourself.
	compensationHandler addFlowElement: compensationStart; addFlowElement: undo; addFlowElement: startFlow.
	booking addFlowElement: compensationHandler.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new identifier: 'throwDefinition'; activityRef: booking; waitForCompletion: false; yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	after := CPTask new identifier: 'afterThrow'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrowFlow'; sourceRef: throwEvent; targetRef: after; yourself.
	process addFlowElement: booking; addFlowElement: before; addFlowElement: throwEvent; addFlowElement: after; addFlowElement: incoming; addFlowElement: outgoing.
	execution := self executionFor: process.
	bookingExecution := execution createActivityExecutionFor: booking.
	bookingExecution activate.
	bookingScope := bookingExecution createSubScopeFor: booking.
	bookingExecution beginCompletion; complete.
	bookingRecord := (execution availableCompensationRecordsFor: booking) first.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	self assert: throwExecution isCompleted.
	self assert: bookingRecord isHandling.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	handlerExecution := bookingRecord handlerExecution.
	self assert: handlerExecution definition == compensationHandler.
	self assert: handlerExecution scope == bookingScope.
	self assert: handlerExecution isActive.
	undoExecution := handlerExecution subScope readyActivityExecutionFor: undo.
	undoExecution activate; beginCompletion; complete.
	self assert: (bookingScope canCompleteSubProcessActivity: handlerExecution).
	bookingScope completeSubProcessActivity: handlerExecution.
	self assert: bookingRecord isHandled.
	^ bookingRecord
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> invalidCustomCompensationHandlerIsRejectedBeforeMutation [
	<gtExample>
	| process booking compensationHandler malformedStart before throwDefinition throwEvent incoming execution bookingExecution bookingRecord producer activation rejected |
	process := CPProcess new identifier: 'process'; yourself.
	booking := CPNoneSubProcess new identifier: 'booking'; compensable: true; yourself.
	compensationHandler := CPCompensationSubProcess new identifier: 'bookingCompensation'; yourself.
	malformedStart := CPCompensationStartEvent new identifier: 'compensationStart'; yourself.
	compensationHandler addFlowElement: malformedStart.
	booking addFlowElement: compensationHandler.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new identifier: 'throwDefinition'; activityRef: booking; waitForCompletion: true; yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	process addFlowElement: booking; addFlowElement: before; addFlowElement: throwEvent; addFlowElement: incoming.
	execution := self executionFor: process.
	bookingExecution := execution createActivityExecutionFor: booking.
	bookingExecution activate.
	bookingExecution createSubScopeFor: booking.
	bookingExecution beginCompletion; complete.
	bookingRecord := (execution availableCompensationRecordsFor: booking) first.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	rejected := false.
	[ execution executeCompensationThrowEvent: throwEvent consuming: activation ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: bookingRecord isAvailable.
	self assert: bookingRecord isClaimed not.
	self assert: bookingRecord handlerExecution isNil.
	self assert: activation isAvailable.
	^ bookingRecord
]


{ #category : 'examples - error events' }
CPExecutionKernelExamples >> errorEventSubProcessHasInterruptingErrorStart [
	<gtExample>
	| handler start definition error |
	error := CPError new identifier: 'bookingError'; yourself.
	handler := CPErrorSubProcess new identifier: 'errorHandler'; yourself.
	start := CPErrorStartEvent new identifier: 'errorStart'; yourself.
	definition := CPErrorEventDefinition new identifier: 'errorDefinition'; error: error; yourself.
	start eventDefinitions add: definition.
	handler addFlowElement: start.
	self assert: handler isSubProcess.
	self assert: start isStartEvent.
	self assert: start container == handler.
	self assert: start incoming isEmpty.
	self assert: start eventDefinitions size equals: 1.
	self assert: start eventDefinitions first == definition.
	self assert: (definition catchesError: error).
	self assert: definition interruptsActivityWithFailure.
	self assert: (CPStartEvent startEventTypes includes: CPErrorStartEvent).
	self assert: (CPSubProcess subProcessTypes includes: CPErrorSubProcess).
	^ handler
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> matchingErrorEventSubProcessInterruptsExactScope [
	<gtExample>
	| process subProcess handler start startDefinition thrownError errorEnd errorDefinition before flow execution subExecution childScope producer activation handlerExecution |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPNoneSubProcess new identifier: 'booking'; yourself.
	thrownError := CPError new identifier: 'bookingError'; yourself.
	handler := CPErrorSubProcess new identifier: 'errorHandler'; yourself.
	start := CPErrorStartEvent new identifier: 'errorStart'; yourself.
	startDefinition := CPErrorEventDefinition new identifier: 'catchBookingError'; error: thrownError; yourself.
	start eventDefinitions add: startDefinition.
	handler addFlowElement: start.
	errorEnd := CPErrorEndEvent new identifier: 'throwError'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'throwBookingError'; error: thrownError; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	before := CPTask new identifier: 'beforeError'; yourself.
	flow := CPSequenceFlow new identifier: 'toError'; sourceRef: before; targetRef: errorEnd; yourself.
	subProcess addFlowElement: handler; addFlowElement: before; addFlowElement: errorEnd; addFlowElement: flow.
	process addFlowElement: subProcess.
	execution := self executionFor: process.
	subExecution := execution createActivityExecutionFor: subProcess.
	subExecution activate.
	childScope := subExecution createSubScopeFor: subProcess.
	producer := childScope createActivityExecutionFor: before.
	producer activate.
	activation := childScope activateSequenceFlow: flow producedBy: producer.
	childScope executeErrorEndEvent: errorEnd consuming: activation.
	handlerExecution := childScope activityExecutions detect: [ :each | each definition == handler ].
	self assert: subExecution state class equals: CPActivityFailingState.
	self assert: producer state class equals: CPActivityTerminatedState.
	self assert: handlerExecution isActive.
	self assert: handlerExecution subScope notNil.
	self assert: activation isAvailable not.
	self assert: handlerExecution subScope eventExecutions size equals: 1.
	self assert: handlerExecution subScope eventExecutions first definition == start.
	self assert: handlerExecution subScope eventExecutions first occurrence definition == thrownError.
	childScope completeErrorEventSubProcessActivity: handlerExecution.
	self assert: handlerExecution isCompleted.
	self assert: subExecution state class equals: CPActivityFailedState.
	^ handlerExecution
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> malformedMatchingErrorEventSubProcessIsRejectedBeforeMutation [
	<gtExample>
	| process subProcess handler start firstDefinition secondDefinition thrownError errorEnd errorDefinition before flow execution subExecution childScope producer activation rejected |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPNoneSubProcess new identifier: 'booking'; yourself.
	thrownError := CPError new identifier: 'bookingError'; yourself.
	handler := CPErrorSubProcess new identifier: 'errorHandler'; yourself.
	start := CPErrorStartEvent new identifier: 'errorStart'; yourself.
	firstDefinition := CPErrorEventDefinition new identifier: 'firstCatch'; error: thrownError; yourself.
	secondDefinition := CPErrorEventDefinition new identifier: 'secondCatch'; error: thrownError; yourself.
	start eventDefinitions add: firstDefinition; add: secondDefinition.
	handler addFlowElement: start.
	errorEnd := CPErrorEndEvent new identifier: 'throwError'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'throwBookingError'; error: thrownError; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	before := CPTask new identifier: 'beforeError'; yourself.
	flow := CPSequenceFlow new identifier: 'toError'; sourceRef: before; targetRef: errorEnd; yourself.
	subProcess addFlowElement: handler; addFlowElement: before; addFlowElement: errorEnd; addFlowElement: flow.
	process addFlowElement: subProcess.
	execution := self executionFor: process.
	subExecution := execution createActivityExecutionFor: subProcess.
	subExecution activate.
	childScope := subExecution createSubScopeFor: subProcess.
	producer := childScope createActivityExecutionFor: before.
	producer activate.
	activation := childScope activateSequenceFlow: flow producedBy: producer.
	rejected := false.
	[ childScope executeErrorEndEvent: errorEnd consuming: activation ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: subExecution isActive.
	self assert: producer isActive.
	self assert: activation isAvailable.
	self assert: (childScope activityExecutions anySatisfy: [ :each | each definition == handler ]) not.
	^ subExecution
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> errorEventSubProcessIsOutsideNormalFlow [
	<gtExample>
	| process handler source flow execution producer activation rejected |
	process := CPProcess new identifier: 'process'; yourself.
	handler := CPErrorSubProcess new identifier: 'errorHandler'; yourself.
	source := CPTask new identifier: 'source'; yourself.
	flow := CPSequenceFlow new identifier: 'invalidNormalFlow'; sourceRef: source; targetRef: handler; yourself.
	process addFlowElement: source; addFlowElement: handler; addFlowElement: flow.
	execution := self executionFor: process.
	producer := execution createActivityExecutionFor: source.
	producer activate.
	activation := execution activateSequenceFlow: flow producedBy: producer.
	rejected := false.
	[ execution readyActivityExecutionFor: handler ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: activation isAvailable.
	self assert: (execution activityExecutions anySatisfy: [ :each | each definition == handler ]) not.
	^ handler
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> uncaughtSubProcessErrorCompensatesCompletedWorkBeforeBoundaryPropagation [
	<gtExample>
	| process subProcess work compensationDefinition compensationBoundary compensationHandler compensationAssociation innerStart errorEnd innerFlow error errorDefinition errorBoundary errorBoundaryDefinition after boundaryFlow execution subProcessExecution childScope workExecution workRecord errorBoundaryExecution endActivation errorExecution handlerExecution |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	work := CPTask new identifier: 'completedWork'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'workCompensation'; yourself.
	compensationBoundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: work;
		cancelActivity: false;
		yourself.
	compensationBoundary eventDefinitions add: compensationDefinition.
	compensationHandler := CPTask new identifier: 'undoWork'; isForCompensation: true; yourself.
	compensationAssociation := CPAssociation new
		identifier: 'compensationAssociation';
		sourceRef: compensationBoundary;
		targetRef: compensationHandler;
		beOne;
		yourself.
	innerStart := CPNoneStartEvent new identifier: 'innerStart'; yourself.
	error := CPError new identifier: 'paymentError'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'thrownError'; error: error; yourself.
	errorEnd := CPErrorEndEvent new identifier: 'errorEnd'; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	innerFlow := CPSequenceFlow new identifier: 'toError'; sourceRef: innerStart; targetRef: errorEnd; yourself.
	subProcess
		addFlowElement: work;
		addFlowElement: compensationHandler;
		addFlowElement: innerStart;
		addFlowElement: errorEnd;
		addFlowElement: innerFlow;
		addArtifact: compensationAssociation.
	errorBoundaryDefinition := CPErrorEventDefinition new identifier: 'caughtError'; error: error; yourself.
	errorBoundary := CPBoundaryEvent new identifier: 'errorBoundary'; attachedToRef: subProcess; cancelActivity: true; yourself.
	errorBoundary eventDefinitions add: errorBoundaryDefinition.
	after := CPTask new identifier: 'afterError'; yourself.
	boundaryFlow := CPSequenceFlow new identifier: 'afterBoundary'; sourceRef: errorBoundary; targetRef: after; yourself.
	process addFlowElement: subProcess; addFlowElement: after; addFlowElement: boundaryFlow.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subProcessExecution.
	errorBoundaryExecution := execution beginBoundaryEvent: errorBoundary attachedTo: subProcessExecution.
	childScope := subProcessExecution subScope.
	workExecution := childScope createActivityExecutionFor: work.
	workExecution activate; beginCompletion; complete.
	workRecord := (childScope availableCompensationRecordsFor: work) first.
	endActivation := (childScope availableFlowActivationsOn: innerFlow) first.
	errorExecution := childScope executeErrorEndEvent: errorEnd consuming: endActivation.
	self assert: errorExecution isPendingWork.
	self assert: errorBoundaryExecution isTriggered not.
	self assert: workRecord isHandling.
	handlerExecution := workRecord handlerExecution.
	self assert: handlerExecution definition == compensationHandler.
	handlerExecution beginCompletion; complete.
	self assert: workRecord isHandled.
	self assert: errorExecution isPendingWork not.
	self assert: errorBoundaryExecution isTriggered.
	self assert: errorBoundaryExecution occurrence == errorExecution occurrence.
	self assert: (execution availableFlowActivationsOn: boundaryFlow) size equals: 1.
	^ errorExecution
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> nestedUncaughtErrorCompensatesEachExitedScopeBeforeBoundaryPropagation [
	<gtExample>
	| process outer inner outerWork innerWork outerCompensationDefinition innerCompensationDefinition outerCompensationBoundary innerCompensationBoundary outerHandler innerHandler outerAssociation innerAssociation error errorDefinition errorEnd beforeError errorFlow errorBoundary errorBoundaryDefinition after boundaryFlow execution outerExecution outerScope innerExecution innerScope outerWorkExecution innerWorkExecution outerRecord innerRecord errorBoundaryExecution producer endActivation errorExecution innerHandlerExecution outerHandlerExecution propagationExecution |
	process := CPProcess new identifier: 'process'; yourself.
	outer := CPSubProcess new identifier: 'outer'; yourself.
	inner := CPSubProcess new identifier: 'inner'; yourself.
	outerWork := CPTask new identifier: 'outerWork'; yourself.
	innerWork := CPTask new identifier: 'innerWork'; yourself.
	outerCompensationDefinition := CPCompensationEventDefinition new identifier: 'outerCompensation'; yourself.
	outerCompensationBoundary := CPBoundaryEvent new identifier: 'outerCompensationBoundary'; attachedToRef: outerWork; cancelActivity: false; yourself.
	outerCompensationBoundary eventDefinitions add: outerCompensationDefinition.
	outerHandler := CPTask new identifier: 'undoOuterWork'; isForCompensation: true; yourself.
	outerAssociation := CPAssociation new identifier: 'outerAssociation'; sourceRef: outerCompensationBoundary; targetRef: outerHandler; beOne; yourself.
	innerCompensationDefinition := CPCompensationEventDefinition new identifier: 'innerCompensation'; yourself.
	innerCompensationBoundary := CPBoundaryEvent new identifier: 'innerCompensationBoundary'; attachedToRef: innerWork; cancelActivity: false; yourself.
	innerCompensationBoundary eventDefinitions add: innerCompensationDefinition.
	innerHandler := CPTask new identifier: 'undoInnerWork'; isForCompensation: true; yourself.
	innerAssociation := CPAssociation new identifier: 'innerAssociation'; sourceRef: innerCompensationBoundary; targetRef: innerHandler; beOne; yourself.
	error := CPError new identifier: 'nestedError'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'throwNestedError'; error: error; yourself.
	errorEnd := CPErrorEndEvent new identifier: 'errorEnd'; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	beforeError := CPTask new identifier: 'beforeError'; yourself.
	errorFlow := CPSequenceFlow new identifier: 'toError'; sourceRef: beforeError; targetRef: errorEnd; yourself.
	inner addFlowElement: innerWork; addFlowElement: innerHandler; addFlowElement: beforeError; addFlowElement: errorEnd; addFlowElement: errorFlow; addArtifact: innerAssociation.
	outer addFlowElement: outerWork; addFlowElement: outerHandler; addFlowElement: inner; addArtifact: outerAssociation.
	errorBoundaryDefinition := CPErrorEventDefinition new identifier: 'catchNestedError'; error: error; yourself.
	errorBoundary := CPBoundaryEvent new identifier: 'errorBoundary'; attachedToRef: outer; cancelActivity: true; yourself.
	errorBoundary eventDefinitions add: errorBoundaryDefinition.
	after := CPTask new identifier: 'afterError'; yourself.
	boundaryFlow := CPSequenceFlow new identifier: 'afterBoundary'; sourceRef: errorBoundary; targetRef: after; yourself.
	process addFlowElement: outer; addFlowElement: after; addFlowElement: boundaryFlow.
	execution := self executionFor: process.
	outerExecution := execution createActivityExecutionFor: outer.
	outerExecution activate.
	outerScope := outerExecution createSubScopeFor: outer.
	errorBoundaryExecution := execution beginBoundaryEvent: errorBoundary attachedTo: outerExecution.
	outerWorkExecution := outerScope createActivityExecutionFor: outerWork.
	outerWorkExecution activate; beginCompletion; complete.
	outerRecord := (outerScope availableCompensationRecordsFor: outerWork) first.
	innerExecution := outerScope createActivityExecutionFor: inner.
	innerExecution activate.
	innerScope := innerExecution createSubScopeFor: inner.
	innerWorkExecution := innerScope createActivityExecutionFor: innerWork.
	innerWorkExecution activate; beginCompletion; complete.
	innerRecord := (innerScope availableCompensationRecordsFor: innerWork) first.
	producer := innerScope createActivityExecutionFor: beforeError.
	producer activate.
	endActivation := innerScope activateSequenceFlow: errorFlow producedBy: producer.
	errorExecution := innerScope executeErrorEndEvent: errorEnd consuming: endActivation.
	self assert: errorExecution isPendingWork.
	self assert: innerRecord isHandling.
	self assert: outerRecord isAvailable.
	self assert: errorBoundaryExecution isTriggered not.
	innerHandlerExecution := innerRecord handlerExecution.
	innerHandlerExecution beginCompletion; complete.
	self assert: innerRecord isHandled.
	self assert: outerRecord isHandling.
	self assert: errorBoundaryExecution isTriggered not.
	propagationExecution := outerScope eventExecutions detect: [ :each | each isErrorPropagationExecution ].
	self assert: propagationExecution occurrence == errorExecution occurrence.
	outerHandlerExecution := outerRecord handlerExecution.
	outerHandlerExecution beginCompletion; complete.
	self assert: outerRecord isHandled.
	self assert: propagationExecution isPendingWork not.
	self assert: errorBoundaryExecution isTriggered.
	self assert: errorBoundaryExecution occurrence == errorExecution occurrence.
	self assert: (execution availableFlowActivationsOn: boundaryFlow) size equals: 1.
	^ errorExecution
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> propagatedErrorIsCaughtByIntermediateErrorEventSubProcess [
	<gtExample>
	| process outer middle inner outerWork innerWork outerCompensationDefinition innerCompensationDefinition outerCompensationBoundary innerCompensationBoundary outerHandler innerHandler outerAssociation innerAssociation error handler handlerStart handlerDefinition errorDefinition errorEnd beforeError errorFlow errorBoundary errorBoundaryDefinition after boundaryFlow execution outerExecution outerScope middleExecution middleScope innerExecution innerScope outerWorkExecution innerWorkExecution outerRecord innerRecord errorBoundaryExecution producer endActivation errorExecution innerHandlerExecution errorHandlerExecution |
	process := CPProcess new identifier: 'process'; yourself.
	outer := CPSubProcess new identifier: 'outer'; yourself.
	middle := CPSubProcess new identifier: 'middle'; yourself.
	inner := CPSubProcess new identifier: 'inner'; yourself.
	outerWork := CPTask new identifier: 'outerWork'; yourself.
	innerWork := CPTask new identifier: 'innerWork'; yourself.
	outerCompensationDefinition := CPCompensationEventDefinition new identifier: 'outerCompensation'; yourself.
	outerCompensationBoundary := CPBoundaryEvent new identifier: 'outerCompensationBoundary'; attachedToRef: outerWork; cancelActivity: false; yourself.
	outerCompensationBoundary eventDefinitions add: outerCompensationDefinition.
	outerHandler := CPTask new identifier: 'undoOuterWork'; isForCompensation: true; yourself.
	outerAssociation := CPAssociation new identifier: 'outerAssociation'; sourceRef: outerCompensationBoundary; targetRef: outerHandler; beOne; yourself.
	innerCompensationDefinition := CPCompensationEventDefinition new identifier: 'innerCompensation'; yourself.
	innerCompensationBoundary := CPBoundaryEvent new identifier: 'innerCompensationBoundary'; attachedToRef: innerWork; cancelActivity: false; yourself.
	innerCompensationBoundary eventDefinitions add: innerCompensationDefinition.
	innerHandler := CPTask new identifier: 'undoInnerWork'; isForCompensation: true; yourself.
	innerAssociation := CPAssociation new identifier: 'innerAssociation'; sourceRef: innerCompensationBoundary; targetRef: innerHandler; beOne; yourself.
	error := CPError new identifier: 'nestedError'; yourself.
	handler := CPErrorSubProcess new identifier: 'middleErrorHandler'; yourself.
	handlerStart := CPErrorStartEvent new identifier: 'middleErrorStart'; yourself.
	handlerDefinition := CPErrorEventDefinition new identifier: 'catchNestedErrorInMiddle'; error: error; yourself.
	handlerStart eventDefinitions add: handlerDefinition.
	handler addFlowElement: handlerStart.
	errorDefinition := CPErrorEventDefinition new identifier: 'throwNestedError'; error: error; yourself.
	errorEnd := CPErrorEndEvent new identifier: 'errorEnd'; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	beforeError := CPTask new identifier: 'beforeError'; yourself.
	errorFlow := CPSequenceFlow new identifier: 'toError'; sourceRef: beforeError; targetRef: errorEnd; yourself.
	inner addFlowElement: innerWork; addFlowElement: innerHandler; addFlowElement: beforeError; addFlowElement: errorEnd; addFlowElement: errorFlow; addArtifact: innerAssociation.
	middle addFlowElement: inner; addFlowElement: handler.
	outer addFlowElement: outerWork; addFlowElement: outerHandler; addFlowElement: middle; addArtifact: outerAssociation.
	errorBoundaryDefinition := CPErrorEventDefinition new identifier: 'outerCatch'; error: error; yourself.
	errorBoundary := CPBoundaryEvent new identifier: 'outerErrorBoundary'; attachedToRef: outer; cancelActivity: true; yourself.
	errorBoundary eventDefinitions add: errorBoundaryDefinition.
	after := CPTask new identifier: 'afterError'; yourself.
	boundaryFlow := CPSequenceFlow new identifier: 'afterBoundary'; sourceRef: errorBoundary; targetRef: after; yourself.
	process addFlowElement: outer; addFlowElement: after; addFlowElement: boundaryFlow.
	execution := self executionFor: process.
	outerExecution := execution createActivityExecutionFor: outer.
	outerExecution activate.
	outerScope := outerExecution createSubScopeFor: outer.
	errorBoundaryExecution := execution beginBoundaryEvent: errorBoundary attachedTo: outerExecution.
	outerWorkExecution := outerScope createActivityExecutionFor: outerWork.
	outerWorkExecution activate; beginCompletion; complete.
	outerRecord := (outerScope availableCompensationRecordsFor: outerWork) first.
	middleExecution := outerScope createActivityExecutionFor: middle.
	middleExecution activate.
	middleScope := middleExecution createSubScopeFor: middle.
	innerExecution := middleScope createActivityExecutionFor: inner.
	innerExecution activate.
	innerScope := innerExecution createSubScopeFor: inner.
	innerWorkExecution := innerScope createActivityExecutionFor: innerWork.
	innerWorkExecution activate; beginCompletion; complete.
	innerRecord := (innerScope availableCompensationRecordsFor: innerWork) first.
	producer := innerScope createActivityExecutionFor: beforeError.
	producer activate.
	endActivation := innerScope activateSequenceFlow: errorFlow producedBy: producer.
	errorExecution := innerScope executeErrorEndEvent: errorEnd consuming: endActivation.
	self assert: innerRecord isHandling.
	self assert: outerRecord isAvailable.
	self assert: errorBoundaryExecution isTriggered not.
	innerHandlerExecution := innerRecord handlerExecution.
	innerHandlerExecution beginCompletion; complete.
	self assert: innerRecord isHandled.
	self assert: innerExecution state class equals: CPActivityFailedState.
	self assert: outerRecord isAvailable.
	self assert: errorBoundaryExecution isTriggered not.
	errorHandlerExecution := middleScope activityExecutions detect: [ :each | each definition == handler ].
	self assert: errorHandlerExecution isActive.
	self assert: errorHandlerExecution subScope eventExecutions first occurrence == errorExecution occurrence.
	self assert: middleExecution state class equals: CPActivityFailingState.
	middleScope completeErrorEventSubProcessActivity: errorHandlerExecution.
	self assert: errorHandlerExecution isCompleted.
	self assert: middleExecution state class equals: CPActivityFailedState.
	self assert: outerExecution isActive.
	self assert: outerRecord isAvailable.
	self assert: errorBoundaryExecution isTriggered not.
	self assert: (execution availableFlowActivationsOn: boundaryFlow) isEmpty.
	^ errorHandlerExecution
]


{ #category : 'examples - error events' }
CPExecutionKernelExamples >> errorEventDefinitionWithoutErrorCatchesAnyError [
	<gtExample>
	| firstError secondError catchAll |
	firstError := CPError new identifier: 'firstError'; yourself.
	secondError := CPError new identifier: 'secondError'; yourself.
	catchAll := CPErrorEventDefinition new identifier: 'catchAll'; yourself.
	self assert: catchAll error isNil.
	self assert: (catchAll catchesError: firstError).
	self assert: (catchAll catchesError: secondError).
	^ catchAll
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> errorEventDefinitionWithErrorCatchesOnlyExactError [
	<gtExample>
	| firstError secondError definition |
	firstError := CPError new identifier: 'firstError'; yourself.
	secondError := CPError new identifier: 'secondError'; yourself.
	definition := CPErrorEventDefinition new
		identifier: 'catchFirstError';
		error: firstError;
		yourself.
	self assert: (definition catchesError: firstError).
	self assert: (definition catchesError: secondError) not.
	^ definition
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> ambiguousErrorEventSubProcessMatchingIsRejectedBeforeMutation [
	<gtExample>
	| process subProcess exactHandler exactStart exactDefinition catchAllHandler catchAllStart catchAllDefinition thrownError errorEnd errorDefinition before flow execution subExecution childScope producer activation rejected |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPNoneSubProcess new identifier: 'booking'; yourself.
	thrownError := CPError new identifier: 'bookingError'; yourself.
	exactHandler := CPErrorSubProcess new identifier: 'exactHandler'; yourself.
	exactStart := CPErrorStartEvent new identifier: 'exactStart'; yourself.
	exactDefinition := CPErrorEventDefinition new identifier: 'catchBookingError'; error: thrownError; yourself.
	exactStart eventDefinitions add: exactDefinition.
	exactHandler addFlowElement: exactStart.
	catchAllHandler := CPErrorSubProcess new identifier: 'catchAllHandler'; yourself.
	catchAllStart := CPErrorStartEvent new identifier: 'catchAllStart'; yourself.
	catchAllDefinition := CPErrorEventDefinition new identifier: 'catchAnyError'; yourself.
	catchAllStart eventDefinitions add: catchAllDefinition.
	catchAllHandler addFlowElement: catchAllStart.
	errorEnd := CPErrorEndEvent new identifier: 'throwError'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'throwBookingError'; error: thrownError; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	before := CPTask new identifier: 'beforeError'; yourself.
	flow := CPSequenceFlow new identifier: 'errorFlow'; sourceRef: before; targetRef: errorEnd; yourself.
	subProcess addFlowElement: exactHandler; addFlowElement: catchAllHandler; addFlowElement: before; addFlowElement: errorEnd; addFlowElement: flow.
	process addFlowElement: subProcess.
	execution := self executionFor: process.
	subExecution := execution createActivityExecutionFor: subProcess.
	subExecution activate.
	childScope := subExecution createSubScopeFor: subProcess.
	producer := childScope createActivityExecutionFor: before.
	producer activate.
	activation := childScope activateSequenceFlow: flow producedBy: producer.
	rejected := false.
	[ childScope executeErrorEndEvent: errorEnd consuming: activation ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: activation isAvailable.
	self assert: subExecution isActive.
	self assert: (childScope activityExecutions anySatisfy: [ :each | each definition == exactHandler ]) not.
	self assert: (childScope activityExecutions anySatisfy: [ :each | each definition == catchAllHandler ]) not.
	^ subExecution
]


{ #category : 'examples - error events' }
CPExecutionKernelExamples >> errorEndEventIsCaughtByCatchAllBoundaryEvent [
	<gtExample>
	| process subProcess innerStart errorEnd innerFlow error errorDefinition boundary boundaryDefinition execution subProcessExecution childScope boundaryExecution endActivation |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	innerStart := CPNoneStartEvent new identifier: 'innerStart'; yourself.
	error := CPError new identifier: 'paymentError'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'thrownError'; error: error; yourself.
	errorEnd := CPErrorEndEvent new identifier: 'errorEnd'; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	innerFlow := CPSequenceFlow new identifier: 'toError'; sourceRef: innerStart; targetRef: errorEnd; yourself.
	subProcess addFlowElement: innerStart; addFlowElement: errorEnd; addFlowElement: innerFlow.
	boundaryDefinition := CPErrorEventDefinition new identifier: 'catchAnyError'; yourself.
	boundary := CPBoundaryEvent new identifier: 'catchAllBoundary'; attachedToRef: subProcess; cancelActivity: true; yourself.
	boundary eventDefinitions add: boundaryDefinition.
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
	self assert: (execution acceptedOccurrences occurrencesOf: boundaryExecution occurrence) equals: 1.
	^ boundaryExecution
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> exactAndCatchAllErrorBoundariesAreAmbiguousBeforeMutation [
	<gtExample>
	| process subProcess innerStart errorEnd innerFlow error errorDefinition exactBoundary exactDefinition catchAllBoundary catchAllDefinition execution subProcessExecution childScope exactBoundaryExecution catchAllBoundaryExecution endActivation rejected |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	innerStart := CPNoneStartEvent new identifier: 'innerStart'; yourself.
	error := CPError new identifier: 'paymentError'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'thrownError'; error: error; yourself.
	errorEnd := CPErrorEndEvent new identifier: 'errorEnd'; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	innerFlow := CPSequenceFlow new identifier: 'toError'; sourceRef: innerStart; targetRef: errorEnd; yourself.
	subProcess addFlowElement: innerStart; addFlowElement: errorEnd; addFlowElement: innerFlow.
	exactDefinition := CPErrorEventDefinition new identifier: 'catchPaymentError'; error: error; yourself.
	exactBoundary := CPBoundaryEvent new identifier: 'exactBoundary'; attachedToRef: subProcess; cancelActivity: true; yourself.
	exactBoundary eventDefinitions add: exactDefinition.
	catchAllDefinition := CPErrorEventDefinition new identifier: 'catchAnyError'; yourself.
	catchAllBoundary := CPBoundaryEvent new identifier: 'catchAllBoundary'; attachedToRef: subProcess; cancelActivity: true; yourself.
	catchAllBoundary eventDefinitions add: catchAllDefinition.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subProcessExecution.
	exactBoundaryExecution := execution beginBoundaryEvent: exactBoundary attachedTo: subProcessExecution.
	catchAllBoundaryExecution := execution beginBoundaryEvent: catchAllBoundary attachedTo: subProcessExecution.
	childScope := subProcessExecution subScope.
	endActivation := (childScope availableFlowActivationsOn: innerFlow) first.
	rejected := false.
	[ childScope executeErrorEndEvent: errorEnd consuming: endActivation ]
		on: Error
		do: [ :caught | rejected := true ].
	self assert: rejected.
	self assert: endActivation isAvailable.
	self assert: subProcessExecution isActive.
	self assert: exactBoundaryExecution isWaiting.
	self assert: catchAllBoundaryExecution isWaiting.
	self assert: childScope acceptedOccurrences isEmpty.
	^ execution
]

{ #category : 'examples - event sub-processes' }
CPExecutionKernelExamples >> errorEventSubProcessRejectsAttachedBoundaryEvent [
	<gtExample>
	| handler start definition boundary rejected |
	handler := CPErrorSubProcess new identifier: 'errorHandler'; yourself.
	start := CPErrorStartEvent new identifier: 'errorStart'; yourself.
	definition := CPErrorEventDefinition new identifier: 'catchAllError'; yourself.
	start eventDefinitions add: definition.
	handler addFlowElement: start.
	boundary := CPBoundaryEvent new identifier: 'invalidBoundary'; attachedToRef: handler; yourself.
	rejected := false.
	[ handler validateEventSubProcessStructure ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: handler boundaryEventRefs size equals: 1.
	self assert: handler boundaryEventRefs first == boundary.
	^ handler
]

{ #category : 'examples - event sub-processes' }
CPExecutionKernelExamples >> errorEventSubProcessRejectsEnclosingSequenceFlowConnection [
	<gtExample>
	| process source handler start definition flow rejected |
	process := CPProcess new identifier: 'process'; yourself.
	source := CPTask new identifier: 'source'; yourself.
	handler := CPErrorSubProcess new identifier: 'errorHandler'; yourself.
	start := CPErrorStartEvent new identifier: 'errorStart'; yourself.
	definition := CPErrorEventDefinition new identifier: 'catchAllError'; yourself.
	start eventDefinitions add: definition.
	handler addFlowElement: start.
	flow := CPSequenceFlow new identifier: 'invalidFlow'; sourceRef: source; targetRef: handler; yourself.
	process addFlowElement: source; addFlowElement: handler; addFlowElement: flow.
	rejected := false.
	[ handler validateEventSubProcessStructure ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: handler incoming size equals: 1.
	self assert: handler incoming first == flow.
	^ handler
]

{ #category : 'examples - event sub-processes' }
CPExecutionKernelExamples >> compensationSubProcessUsesEventSubProcessStructuralContract [
	<gtExample>
	| handler start definition rejected |
	handler := CPCompensationSubProcess new identifier: 'compensationHandler'; yourself.
	start := CPCompensationStartEvent new identifier: 'compensationStart'; yourself.
	definition := CPCompensationEventDefinition new identifier: 'compensationDefinition'; yourself.
	start eventDefinitions add: definition.
	handler addFlowElement: start.
	self assert: handler isEventSubProcess.
	handler validateEventSubProcessStructure.
	start incoming add: (CPSequenceFlow new identifier: 'invalidIncoming'; yourself).
	rejected := false.
	[ handler validateEventSubProcessStructure ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	^ handler
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> defaultCompensationReadinessPreservesIndependentWork [
	<gtExample>
	| process firstWork firstDefinition firstBoundary secondWork secondDefinition secondBoundary independentWork independentDefinition independentBoundary flow execution firstExecution activation secondExecution independentExecution records firstRecord secondRecord independentRecord ready |
	process := CPProcess new identifier: 'process'; yourself.
	firstWork := CPTask new identifier: 'firstWork'; yourself.
	firstDefinition := CPCompensationEventDefinition new identifier: 'firstCompensation'; yourself.
	firstBoundary := CPBoundaryEvent new identifier: 'firstBoundary'; attachedToRef: firstWork; cancelActivity: false; yourself.
	firstBoundary eventDefinitions add: firstDefinition.
	secondWork := CPTask new identifier: 'secondWork'; yourself.
	secondDefinition := CPCompensationEventDefinition new identifier: 'secondCompensation'; yourself.
	secondBoundary := CPBoundaryEvent new identifier: 'secondBoundary'; attachedToRef: secondWork; cancelActivity: false; yourself.
	secondBoundary eventDefinitions add: secondDefinition.
	independentWork := CPTask new identifier: 'independentWork'; yourself.
	independentDefinition := CPCompensationEventDefinition new identifier: 'independentCompensation'; yourself.
	independentBoundary := CPBoundaryEvent new identifier: 'independentBoundary'; attachedToRef: independentWork; cancelActivity: false; yourself.
	independentBoundary eventDefinitions add: independentDefinition.
	flow := CPSequenceFlow new identifier: 'firstToSecond'; sourceRef: firstWork; targetRef: secondWork; yourself.
	{ firstWork. secondWork. independentWork. flow } do: [ :each | process addFlowElement: each ].
	execution := self executionFor: process.
	firstExecution := execution createActivityExecutionFor: firstWork.
	firstExecution activate; beginCompletion; complete.
	execution produceOutgoingControlFor: firstExecution.
	activation := (execution availableFlowActivationsOn: flow) first.
	secondExecution := execution readyActivityExecutionFor: secondWork.
	secondExecution activate; beginCompletion; complete.
	independentExecution := execution createActivityExecutionFor: independentWork.
	independentExecution activate; beginCompletion; complete.
	records := execution availableCompensationRecords.
	firstRecord := records detect: [ :each | each activityExecution == firstExecution ].
	secondRecord := records detect: [ :each | each activityExecution == secondExecution ].
	independentRecord := records detect: [ :each | each activityExecution == independentExecution ].
	ready := execution readyDefaultCompensationRecordsIn: records.
	self assert: activation producedBy == firstExecution.
	self assert: activation consumedBy == secondExecution.
	self assert: ready size equals: 2.
	self assert: (ready identityIncludes: secondRecord).
	self assert: (ready identityIncludes: independentRecord).
	self assert: (ready identityIncludes: firstRecord) not.
	^ ready
]

{ #category : 'examples - error events' }
CPExecutionKernelExamples >> presumedAbortStartsIndependentCompensationTogetherBeforeErrorPropagation [
	<gtExample>
	| process subProcess workA workB definitionA definitionB boundaryA boundaryB handlerA handlerB associationA associationB beforeError errorEnd errorFlow error errorDefinition errorBoundary errorBoundaryDefinition after boundaryFlow execution subExecution childScope executionA executionB recordA recordB errorBoundaryExecution producer endActivation errorExecution handlerExecutionA handlerExecutionB |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	workA := CPTask new identifier: 'workA'; yourself.
	workB := CPTask new identifier: 'workB'; yourself.
	definitionA := CPCompensationEventDefinition new identifier: 'compensationA'; yourself.
	boundaryA := CPBoundaryEvent new identifier: 'boundaryA'; attachedToRef: workA; cancelActivity: false; yourself.
	boundaryA eventDefinitions add: definitionA.
	handlerA := CPTask new identifier: 'undoA'; isForCompensation: true; yourself.
	associationA := CPAssociation new identifier: 'associationA'; sourceRef: boundaryA; targetRef: handlerA; beOne; yourself.
	definitionB := CPCompensationEventDefinition new identifier: 'compensationB'; yourself.
	boundaryB := CPBoundaryEvent new identifier: 'boundaryB'; attachedToRef: workB; cancelActivity: false; yourself.
	boundaryB eventDefinitions add: definitionB.
	handlerB := CPTask new identifier: 'undoB'; isForCompensation: true; yourself.
	associationB := CPAssociation new identifier: 'associationB'; sourceRef: boundaryB; targetRef: handlerB; beOne; yourself.
	beforeError := CPTask new identifier: 'beforeError'; yourself.
	error := CPError new identifier: 'error'; yourself.
	errorDefinition := CPErrorEventDefinition new identifier: 'throwError'; error: error; yourself.
	errorEnd := CPErrorEndEvent new identifier: 'errorEnd'; yourself.
	errorEnd eventDefinitions add: errorDefinition.
	errorFlow := CPSequenceFlow new identifier: 'toError'; sourceRef: beforeError; targetRef: errorEnd; yourself.
	subProcess
		addFlowElement: workA;
		addFlowElement: workB;
		addFlowElement: handlerA;
		addFlowElement: handlerB;
		addFlowElement: beforeError;
		addFlowElement: errorEnd;
		addFlowElement: errorFlow;
		addArtifact: associationA;
		addArtifact: associationB.
	errorBoundaryDefinition := CPErrorEventDefinition new identifier: 'catchError'; error: error; yourself.
	errorBoundary := CPBoundaryEvent new identifier: 'errorBoundary'; attachedToRef: subProcess; cancelActivity: true; yourself.
	errorBoundary eventDefinitions add: errorBoundaryDefinition.
	after := CPTask new identifier: 'afterError'; yourself.
	boundaryFlow := CPSequenceFlow new identifier: 'afterBoundary'; sourceRef: errorBoundary; targetRef: after; yourself.
	process addFlowElement: subProcess; addFlowElement: after; addFlowElement: boundaryFlow.
	execution := self executionFor: process.
	subExecution := execution createActivityExecutionFor: subProcess.
	execution activateSubProcessExecution: subExecution.
	errorBoundaryExecution := execution beginBoundaryEvent: errorBoundary attachedTo: subExecution.
	childScope := subExecution subScope.
	executionA := childScope createActivityExecutionFor: workA.
	executionA activate; beginCompletion; complete.
	executionB := childScope createActivityExecutionFor: workB.
	executionB activate; beginCompletion; complete.
	recordA := (childScope availableCompensationRecordsFor: workA) first.
	recordB := (childScope availableCompensationRecordsFor: workB) first.
	producer := childScope createActivityExecutionFor: beforeError.
	producer activate.
	endActivation := childScope activateSequenceFlow: errorFlow producedBy: producer.
	errorExecution := childScope executeErrorEndEvent: errorEnd consuming: endActivation.
	self assert: errorExecution isPendingWork.
	self assert: recordA isHandling.
	self assert: recordB isHandling.
	self assert: errorBoundaryExecution isTriggered not.
	handlerExecutionA := recordA handlerExecution.
	handlerExecutionB := recordB handlerExecution.
	handlerExecutionA beginCompletion; complete.
	self assert: recordA isHandled.
	self assert: recordB isHandling.
	self assert: errorExecution isPendingWork.
	self assert: errorBoundaryExecution isTriggered not.
	handlerExecutionB beginCompletion; complete.
	self assert: recordB isHandled.
	self assert: errorExecution isPendingWork not.
	self assert: errorBoundaryExecution isTriggered.
	self assert: errorBoundaryExecution occurrence == errorExecution occurrence.
	self assert: (execution availableFlowActivationsOn: boundaryFlow) size equals: 1.
	^ errorExecution
]


{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> nestedDefaultSubProcessCompensationStartsIndependentHandlersTogether [
	<gtExample>
	| process booking workA workB definitionA definitionB boundaryA boundaryB handlerA handlerB associationA associationB before throwDefinition throwEvent after incoming outgoing execution bookingExecution bookingScope executionA executionB bookingRecord recordA recordB producer activation throwExecution handlerExecutionA handlerExecutionB |
	process := CPProcess new identifier: 'process'; yourself.
	booking := CPNoneSubProcess new identifier: 'booking'; compensable: true; yourself.
	workA := CPTask new identifier: 'workA'; yourself.
	definitionA := CPCompensationEventDefinition new identifier: 'compensationA'; yourself.
	boundaryA := CPBoundaryEvent new identifier: 'boundaryA'; attachedToRef: workA; cancelActivity: false; yourself.
	boundaryA eventDefinitions add: definitionA.
	handlerA := CPTask new identifier: 'undoA'; isForCompensation: true; yourself.
	associationA := CPAssociation new identifier: 'associationA'; sourceRef: boundaryA; targetRef: handlerA; beOne; yourself.
	workB := CPTask new identifier: 'workB'; yourself.
	definitionB := CPCompensationEventDefinition new identifier: 'compensationB'; yourself.
	boundaryB := CPBoundaryEvent new identifier: 'boundaryB'; attachedToRef: workB; cancelActivity: false; yourself.
	boundaryB eventDefinitions add: definitionB.
	handlerB := CPTask new identifier: 'undoB'; isForCompensation: true; yourself.
	associationB := CPAssociation new identifier: 'associationB'; sourceRef: boundaryB; targetRef: handlerB; beOne; yourself.
	booking addFlowElement: workA; addFlowElement: handlerA; addFlowElement: workB; addFlowElement: handlerB.
	booking addArtifact: associationA; addArtifact: associationB.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new identifier: 'throwDefinition'; activityRef: booking; waitForCompletion: true; yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	after := CPTask new identifier: 'afterThrow'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrowFlow'; sourceRef: throwEvent; targetRef: after; yourself.
	{ booking. before. throwEvent. after. incoming. outgoing } do: [ :each | process addFlowElement: each ].
	execution := self executionFor: process.
	bookingExecution := execution createActivityExecutionFor: booking.
	bookingExecution activate.
	bookingScope := bookingExecution createSubScopeFor: booking.
	executionA := bookingScope createActivityExecutionFor: workA.
	executionA activate; beginCompletion; complete.
	executionB := bookingScope createActivityExecutionFor: workB.
	executionB activate; beginCompletion; complete.
	bookingExecution beginCompletion; complete.
	bookingRecord := (execution availableCompensationRecordsFor: booking) first.
	recordA := (bookingScope availableCompensationRecordsFor: workA) first.
	recordB := (bookingScope availableCompensationRecordsFor: workB) first.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	self assert: throwExecution isPending.
	self assert: bookingRecord isHandling.
	self assert: recordA isHandling.
	self assert: recordB isHandling.
	handlerExecutionA := recordA handlerExecution.
	handlerExecutionB := recordB handlerExecution.
	self assert: handlerExecutionA isActive.
	self assert: handlerExecutionB isActive.
	handlerExecutionA beginCompletion; complete.
	self assert: recordA isHandled.
	self assert: recordB isHandling.
	self assert: bookingRecord isHandling.
	self assert: throwExecution isPending.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	handlerExecutionB beginCompletion; complete.
	self assert: recordB isHandled.
	self assert: bookingRecord isHandled.
	self assert: throwExecution isCompleted.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ bookingRecord
]

{ #category : 'examples - compensation events' }
CPExecutionKernelExamples >> asynchronousScopeCompensationContinuesDependentWorkAfterThrowCompletes [
	<gtExample>
	| process firstWork firstBoundary firstDefinition firstHandler firstAssociation secondWork secondBoundary secondDefinition secondHandler secondAssociation dependency before throwDefinition throwEvent after incoming outgoing execution firstExecution dependencyActivation secondExecution firstRecord secondRecord producer activation throwExecution compensationExecution secondHandlerExecution firstHandlerExecution |
	process := CPProcess new identifier: 'process'; yourself.
	firstWork := CPTask new identifier: 'firstWork'; yourself.
	firstDefinition := CPCompensationEventDefinition new identifier: 'firstCompensation'; yourself.
	firstBoundary := CPBoundaryEvent new identifier: 'firstBoundary'; attachedToRef: firstWork; cancelActivity: false; yourself.
	firstBoundary eventDefinitions add: firstDefinition.
	firstHandler := CPTask new identifier: 'undoFirst'; isForCompensation: true; yourself.
	firstAssociation := CPAssociation new identifier: 'firstHandler'; sourceRef: firstBoundary; targetRef: firstHandler; beOne; yourself.
	secondWork := CPTask new identifier: 'secondWork'; yourself.
	secondDefinition := CPCompensationEventDefinition new identifier: 'secondCompensation'; yourself.
	secondBoundary := CPBoundaryEvent new identifier: 'secondBoundary'; attachedToRef: secondWork; cancelActivity: false; yourself.
	secondBoundary eventDefinitions add: secondDefinition.
	secondHandler := CPTask new identifier: 'undoSecond'; isForCompensation: true; yourself.
	secondAssociation := CPAssociation new identifier: 'secondHandler'; sourceRef: secondBoundary; targetRef: secondHandler; beOne; yourself.
	dependency := CPSequenceFlow new identifier: 'firstToSecond'; sourceRef: firstWork; targetRef: secondWork; yourself.
	before := CPTask new identifier: 'beforeThrow'; yourself.
	throwDefinition := CPCompensationEventDefinition new identifier: 'throwDefinition'; waitForCompletion: false; yourself.
	throwEvent := CPCompensationThrowIntermediateEvent new identifier: 'throwCompensation'; yourself.
	throwEvent eventDefinitions add: throwDefinition.
	after := CPTask new identifier: 'afterThrow'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: before; targetRef: throwEvent; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrowFlow'; sourceRef: throwEvent; targetRef: after; yourself.
	{ firstWork. firstHandler. secondWork. secondHandler. dependency. before. throwEvent. after. incoming. outgoing } do: [ :each |
		process addFlowElement: each ].
	process addArtifact: firstAssociation; addArtifact: secondAssociation.
	execution := self executionFor: process.
	firstExecution := execution createActivityExecutionFor: firstWork.
	firstExecution activate; beginCompletion; complete.
	execution produceOutgoingControlFor: firstExecution.
	dependencyActivation := (execution availableFlowActivationsOn: dependency) first.
	secondExecution := execution readyActivityExecutionFor: secondWork.
	secondExecution activate; beginCompletion; complete.
	firstRecord := (execution availableCompensationRecordsFor: firstWork) first.
	secondRecord := (execution availableCompensationRecordsFor: secondWork) first.
	self assert: dependencyActivation producedBy == firstExecution.
	self assert: dependencyActivation consumedBy == secondExecution.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	throwExecution := execution executeCompensationThrowEvent: throwEvent consuming: activation.
	compensationExecution := execution eventExecutions
		detect: [ :each | each isCompensationExecution ]
		ifNone: [ self error: 'Asynchronous scope compensation requires a durable Compensation execution.' ].
	self assert: throwExecution isCompleted.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	self assert: secondRecord isHandling.
	self assert: firstRecord isAvailable.
	self assert: compensationExecution isPendingWork.
	secondHandlerExecution := secondRecord handlerExecution.
	self assert: secondHandlerExecution definition == secondHandler.
	secondHandlerExecution beginCompletion; complete.
	self assert: secondRecord isHandled.
	self assert: firstRecord isHandling.
	self assert: compensationExecution isPendingWork.
	firstHandlerExecution := firstRecord handlerExecution.
	self assert: firstHandlerExecution definition == firstHandler.
	firstHandlerExecution beginCompletion; complete.
	self assert: firstRecord isHandled.
	self assert: compensationExecution isPendingWork not.
	^ compensationExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> activityExecutionsOwnIndependentDataInputValues [
	<gtExample>
	| process task specification input execution first second |
	process := CPProcess new identifier: 'process'; yourself.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	input := CPDataInput new identifier: 'input'; yourself.
	specification dataInputs add: input.
	task ioSpecification: specification.
	process addFlowElement: task.
	execution := self executionFor: process.
	first := execution createActivityExecutionFor: task.
	second := execution createActivityExecutionFor: task.
	first itemValueFor: input put: 'first'.
	second itemValueFor: input put: 'second'.
	self assert: (first itemValueFor: input) equals: 'first'.
	self assert: (second itemValueFor: input) equals: 'second'.
	^ execution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> processExecutionsOwnIndependentDataObjectValues [
	<gtExample>
	| process dataObject first second |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	process addFlowElement: dataObject.
	first := self executionFor: process.
	second := self executionFor: process.
	first itemValueFor: dataObject put: 'first order'.
	second itemValueFor: dataObject put: 'second order'.
	self assert: (first itemValueFor: dataObject) equals: 'first order'.
	self assert: (second itemValueFor: dataObject) equals: 'second order'.
	^ first
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> processExecutionOwnsProcessPropertyValue [
	<gtExample>
	| process property execution |
	process := CPProcess new identifier: 'process'; yourself.
	property := CPProperty new identifier: 'property'; yourself.
	process properties add: property.
	execution := self executionFor: process.
	execution itemValueFor: property put: 42.
	self assert: (execution itemValueFor: property) equals: 42.
	^ execution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> nestedExecutionScopeOwnsContainedDataObjectValue [
	<gtExample>
	| process subProcess dataObject execution subProcessExecution subScope |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	dataObject := CPDataObject new identifier: 'localData'; yourself.
	subProcess addFlowElement: dataObject.
	process addFlowElement: subProcess.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	subScope := subProcessExecution createSubScopeFor: subProcess.
	subScope itemValueFor: dataObject put: 'local'.
	self assert: (subScope itemValueFor: dataObject) equals: 'local'.
	^ subScope
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> executionDataRejectsItemOwnedByAnotherContext [
	<gtExample>
	| process task specification input dataObject execution activityExecution scopeRejected activityRejected |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'processData'; yourself.
	process addFlowElement: dataObject.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	input := CPDataInput new identifier: 'input'; yourself.
	specification dataInputs add: input.
	task ioSpecification: specification.
	process addFlowElement: task.
	execution := self executionFor: process.
	activityExecution := execution createActivityExecutionFor: task.
	scopeRejected := false.
	[ execution itemValueFor: input put: 'wrong owner' ]
		on: Error
		do: [ :error | scopeRejected := true ].
	activityRejected := false.
	[ activityExecution itemValueFor: dataObject put: 'wrong owner' ]
		on: Error
		do: [ :error | activityRejected := true ].
	self assert: scopeRejected.
	self assert: activityRejected.
	^ execution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> nestedActivityAccessesEnclosingProcessDataObjectValue [
	<gtExample>
	| process dataObject subProcess task execution subProcessExecution subScope taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	process addFlowElement: dataObject.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	task := CPTask new identifier: 'task'; yourself.
	subProcess addFlowElement: task.
	process addFlowElement: subProcess.
	execution := self executionFor: process.
	execution itemValueFor: dataObject put: 'order-123'.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	subScope := subProcessExecution createSubScopeFor: subProcess.
	taskExecution := subScope createActivityExecutionFor: task.
	self assert: (taskExecution accessibleItemValueFor: dataObject) equals: 'order-123'.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> nestedActivityUpdatesEnclosingProcessDataObjectValue [
	<gtExample>
	| process dataObject subProcess task execution subProcessExecution subScope taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	process addFlowElement: dataObject.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	task := CPTask new identifier: 'task'; yourself.
	subProcess addFlowElement: task.
	process addFlowElement: subProcess.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	subScope := subProcessExecution createSubScopeFor: subProcess.
	taskExecution := subScope createActivityExecutionFor: task.
	taskExecution accessibleItemValueFor: dataObject put: 'updated'.
	self assert: (execution itemValueFor: dataObject) equals: 'updated'.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> dataObjectReferenceResolvesToReferencedExecutionValue [
	<gtExample>
	| process dataObject reference task execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	reference := CPDataObjectReference new
		identifier: 'orderReference';
		dataObjectRef: dataObject;
		yourself.
	task := CPTask new identifier: 'task'; yourself.
	process addFlowElement: dataObject.
	process addFlowElement: reference.
	process addFlowElement: task.
	execution := self executionFor: process.
	execution itemValueFor: dataObject put: 'order-123'.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: (taskExecution accessibleItemValueFor: reference) equals: 'order-123'.
	taskExecution accessibleItemValueFor: reference put: 'order-456'.
	self assert: (execution itemValueFor: dataObject) equals: 'order-456'.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> nestedActivityAccessesEnclosingSubProcessPropertyValue [
	<gtExample>
	| process subProcess property task execution subProcessExecution subScope taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	subProcess := CPSubProcess new identifier: 'subProcess'; yourself.
	property := CPProperty new identifier: 'property'; yourself.
	subProcess properties add: property.
	task := CPTask new identifier: 'task'; yourself.
	subProcess addFlowElement: task.
	process addFlowElement: subProcess.
	execution := self executionFor: process.
	subProcessExecution := execution createActivityExecutionFor: subProcess.
	subProcessExecution itemValueFor: property put: 'subProcess value'.
	subScope := subProcessExecution createSubScopeFor: subProcess.
	taskExecution := subScope createActivityExecutionFor: task.
	self assert: (taskExecution accessibleItemValueFor: property) equals: 'subProcess value'.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> inaccessibleDataObjectReferenceIsRejected [
	<gtExample>
	| process dataObject reference task execution taskExecution rejected |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	reference := CPDataObjectReference new
		identifier: 'detachedReference';
		dataObjectRef: dataObject;
		yourself.
	task := CPTask new identifier: 'task'; yourself.
	process addFlowElement: dataObject.
	process addFlowElement: task.
	execution := self executionFor: process.
	taskExecution := execution createActivityExecutionFor: task.
	rejected := false.
	[ taskExecution accessibleItemValueFor: reference ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> simpleInputDataAssociationCopiesAvailableSourceValue [
	<gtExample>
	| process dataObject task specification input association execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	process addFlowElement: dataObject.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	input := CPDataInput new identifier: 'orderInput'; yourself.
	specification dataInputs add: input.
	task ioSpecification: specification.
	association := CPDataInputAssociation new
		sourceRefs: { dataObject };
		targetRef: input;
		yourself.
	task dataInputAssociations add: association.
	process addFlowElement: task.
	execution := self executionFor: process.
	execution itemValueFor: dataObject put: 'order-123'.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: (taskExecution executeDataAssociation: association).
	self assert: (taskExecution itemValueFor: input) equals: 'order-123'.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> simpleOutputDataAssociationCopiesAvailableSourceValue [
	<gtExample>
	| process dataObject task specification output association execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'result'; yourself.
	process addFlowElement: dataObject.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	output := CPDataOutput new identifier: 'resultOutput'; yourself.
	specification dataOutputs add: output.
	task ioSpecification: specification.
	association := CPDataOutputAssociation new
		sourceRefs: { output };
		targetRef: dataObject;
		yourself.
	task dataOutputAssociations add: association.
	process addFlowElement: task.
	execution := self executionFor: process.
	taskExecution := execution createActivityExecutionFor: task.
	taskExecution itemValueFor: output put: 'completed'.
	self assert: (taskExecution executeDataAssociation: association).
	self assert: (execution itemValueFor: dataObject) equals: 'completed'.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> simpleDataAssociationWaitsForUnavailableSource [
	<gtExample>
	| process dataObject task specification input association execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	process addFlowElement: dataObject.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	input := CPDataInput new identifier: 'orderInput'; yourself.
	specification dataInputs add: input.
	task ioSpecification: specification.
	association := CPDataInputAssociation new
		sourceRefs: { dataObject };
		targetRef: input;
		yourself.
	task dataInputAssociations add: association.
	process addFlowElement: task.
	execution := self executionFor: process.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: (taskExecution executeDataAssociation: association) = false.
	self assert: (taskExecution hasItemValueFor: input) = false.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> simpleDataAssociationPreservesAvailableNilValue [
	<gtExample>
	| process dataObject task specification input association execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	process addFlowElement: dataObject.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	input := CPDataInput new identifier: 'orderInput'; yourself.
	specification dataInputs add: input.
	task ioSpecification: specification.
	association := CPDataInputAssociation new
		sourceRefs: { dataObject };
		targetRef: input;
		yourself.
	task dataInputAssociations add: association.
	process addFlowElement: task.
	execution := self executionFor: process.
	execution itemValueFor: dataObject put: nil.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: (taskExecution executeDataAssociation: association).
	self assert: (taskExecution hasItemValueFor: input).
	self assert: (taskExecution itemValueFor: input) isNil.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> activityInputsUseFirstAvailableInputSet [
	<gtExample>
	| process unavailable available task specification firstInput secondInput firstSet secondSet firstAssociation secondAssociation execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	unavailable := CPDataObject new identifier: 'unavailable'; yourself.
	available := CPDataObject new identifier: 'available'; yourself.
	process addFlowElement: unavailable.
	process addFlowElement: available.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	firstInput := CPDataInput new identifier: 'firstInput'; yourself.
	secondInput := CPDataInput new identifier: 'secondInput'; yourself.
	specification dataInputs: { firstInput. secondInput }.
	firstSet := CPInputSet new dataInputRefs: { firstInput }; yourself.
	secondSet := CPInputSet new dataInputRefs: { secondInput }; yourself.
	specification inputSets: { firstSet. secondSet }.
	task ioSpecification: specification.
	firstAssociation := CPDataInputAssociation new sourceRefs: { unavailable }; targetRef: firstInput; yourself.
	secondAssociation := CPDataInputAssociation new sourceRefs: { available }; targetRef: secondInput; yourself.
	task dataInputAssociations: { firstAssociation. secondAssociation }.
	process addFlowElement: task.
	execution := self executionFor: process.
	execution itemValueFor: available put: 'ready'.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: taskExecution prepareInputs.
	self assert: (taskExecution hasItemValueFor: firstInput) = false.
	self assert: (taskExecution itemValueFor: secondInput) equals: 'ready'.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> activityInputsWaitWhenNoInputSetIsAvailable [
	<gtExample>
	| process dataObject task specification input inputSet association execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	process addFlowElement: dataObject.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	input := CPDataInput new identifier: 'orderInput'; yourself.
	specification dataInputs: { input }.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	specification inputSets: { inputSet }.
	task ioSpecification: specification.
	association := CPDataInputAssociation new sourceRefs: { dataObject }; targetRef: input; yourself.
	task dataInputAssociations: { association }.
	process addFlowElement: task.
	execution := self executionFor: process.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: taskExecution prepareInputs = false.
	self assert: taskExecution isReady.
	self assert: (taskExecution hasItemValueFor: input) = false.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> optionalActivityInputDoesNotBlockAvailableInputSet [
	<gtExample>
	| process dataObject optionalSource task specification requiredInput optionalInput inputSet requiredAssociation optionalAssociation execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	process addFlowElement: dataObject.
	optionalSource := CPDataObject new identifier: 'optionalSource'; yourself.
	process addFlowElement: optionalSource.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	requiredInput := CPDataInput new identifier: 'required'; yourself.
	optionalInput := CPDataInput new identifier: 'optional'; yourself.
	specification dataInputs: { requiredInput. optionalInput }.
	inputSet := CPInputSet new
		dataInputRefs: { requiredInput. optionalInput };
		optionalInputRefs: { optionalInput };
		yourself.
	specification inputSets: { inputSet }.
	task ioSpecification: specification.
	requiredAssociation := CPDataInputAssociation new sourceRefs: { dataObject }; targetRef: requiredInput; yourself.
	optionalAssociation := CPDataInputAssociation new sourceRefs: { optionalSource }; targetRef: optionalInput; yourself.
	task dataInputAssociations: { requiredAssociation. optionalAssociation }.
	process addFlowElement: task.
	execution := self executionFor: process.
	execution itemValueFor: dataObject put: 'ready'.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: taskExecution prepareInputs.
	self assert: (taskExecution itemValueFor: requiredInput) equals: 'ready'.
	self assert: (taskExecution hasItemValueFor: optionalInput) = false.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> serviceTaskWaitsForRequiredInputBeforeResolvingOperation [
	<gtExample>
	| process dataObject serviceTask specification input inputSet association operation implementation environment execution serviceExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	process addFlowElement: dataObject.
	operation := CPOperation new identifier: 'chargeAccount'; yourself.
	serviceTask := CPServiceTask new
		identifier: 'charge';
		operationRef: operation;
		yourself.
	specification := CPInputOutputSpecification new.
	input := CPDataInput new identifier: 'orderInput'; yourself.
	specification dataInputs: { input }.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	specification inputSets: { inputSet }.
	serviceTask ioSpecification: specification.
	association := CPDataInputAssociation new
		sourceRefs: { dataObject };
		targetRef: input;
		yourself.
	serviceTask dataInputAssociations: { association }.
	process addFlowElement: serviceTask.
	environment := CPExampleExecutionEnvironment new.
	execution := CPProcessExecution for: process environment: environment.
	serviceExecution := execution createServiceTaskExecutionFor: serviceTask.
	self assert: (execution activateServiceTaskExecution: serviceExecution) = false.
	self assert: serviceExecution isReady.
	self assert: serviceExecution resolvedImplementation isNil.
	self assert: (serviceExecution hasItemValueFor: input) = false.
	implementation := Object new.
	environment operation: operation resolvesTo: implementation.
	execution itemValueFor: dataObject put: 'ready'.
	self assert: (execution activateServiceTaskExecution: serviceExecution) == serviceExecution.
	self assert: serviceExecution isActive.
	self assert: serviceExecution resolvedImplementation == implementation.
	self assert: (serviceExecution itemValueFor: input) equals: 'ready'.
	^ serviceExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> receiveTaskWaitsForRequiredInputBeforeCreatingSubscription [
	<gtExample>
	| process dataObject message receiveTask specification input inputSet association execution receiveExecution |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'correlation'; yourself.
	process addFlowElement: dataObject.
	message := CPMessage new identifier: 'reply'; yourself.
	receiveTask := CPReceiveTask new
		identifier: 'receive';
		messageRef: message;
		yourself.
	specification := CPInputOutputSpecification new.
	input := CPDataInput new identifier: 'correlationInput'; yourself.
	specification dataInputs: { input }.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	specification inputSets: { inputSet }.
	receiveTask ioSpecification: specification.
	association := CPDataInputAssociation new
		sourceRefs: { dataObject };
		targetRef: input;
		yourself.
	receiveTask dataInputAssociations: { association }.
	process addFlowElement: receiveTask.
	execution := self executionFor: process.
	receiveExecution := execution createReceiveTaskExecutionFor: receiveTask.
	self assert: (execution activateReceiveTaskExecution: receiveExecution) = false.
	self assert: receiveExecution isReady.
	self assert: receiveExecution subscription isNil.
	self assert: execution messageSubscriptions isEmpty.
	execution itemValueFor: dataObject put: 'customer-1'.
	self assert: (execution activateReceiveTaskExecution: receiveExecution) == receiveExecution.
	self assert: receiveExecution isActive.
	self assert: receiveExecution subscription notNil.
	self assert: execution messageSubscriptions size equals: 1.
	self assert: (receiveExecution itemValueFor: input) equals: 'customer-1'.
	^ receiveExecution
]


{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> activityCompletionSelectsFirstAvailableOutputSetAndPushesData [
	<gtExample>
	| process firstTarget secondTarget task specification firstOutput secondOutput firstSet secondSet firstAssociation secondAssociation execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	firstTarget := CPDataObject new identifier: 'firstTarget'; yourself.
	secondTarget := CPDataObject new identifier: 'secondTarget'; yourself.
	process addFlowElement: firstTarget.
	process addFlowElement: secondTarget.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	firstOutput := CPDataOutput new identifier: 'first'; yourself.
	secondOutput := CPDataOutput new identifier: 'second'; yourself.
	specification dataOutputs: { firstOutput. secondOutput }.
	firstSet := CPOutputSet new dataOutputRefs: { firstOutput }; yourself.
	secondSet := CPOutputSet new dataOutputRefs: { secondOutput }; yourself.
	specification outputSets: { firstSet. secondSet }.
	task ioSpecification: specification.
	firstAssociation := CPDataOutputAssociation new sourceRefs: { firstOutput }; targetRef: firstTarget; yourself.
	secondAssociation := CPDataOutputAssociation new sourceRefs: { secondOutput }; targetRef: secondTarget; yourself.
	task dataOutputAssociations: { firstAssociation. secondAssociation }.
	process addFlowElement: task.
	execution := self executionFor: process.
	taskExecution := execution createActivityExecutionFor: task.
	taskExecution activate.
	taskExecution itemValueFor: secondOutput put: 'second-value'.
	taskExecution beginCompletion.
	taskExecution complete.
	self assert: taskExecution selectedOutputSet == secondSet.
	self assert: (execution itemValueFor: secondTarget) equals: 'second-value'.
	self assert: (execution hasItemValueFor: firstTarget) = false.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> optionalUnavailableActivityOutputDoesNotBlockCompletion [
	<gtExample>
	| process target task specification requiredOutput optionalOutput outputSet association execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	target := CPDataObject new identifier: 'target'; yourself.
	process addFlowElement: target.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	requiredOutput := CPDataOutput new identifier: 'required'; yourself.
	optionalOutput := CPDataOutput new identifier: 'optional'; yourself.
	specification dataOutputs: { requiredOutput. optionalOutput }.
	outputSet := CPOutputSet new
		dataOutputRefs: { requiredOutput. optionalOutput };
		optionalOutputRefs: { optionalOutput };
		yourself.
	specification outputSets: { outputSet }.
	task ioSpecification: specification.
	association := CPDataOutputAssociation new sourceRefs: { requiredOutput }; targetRef: target; yourself.
	task dataOutputAssociations: { association }.
	process addFlowElement: task.
	execution := self executionFor: process.
	taskExecution := execution createActivityExecutionFor: task.
	taskExecution activate.
	taskExecution itemValueFor: requiredOutput put: 'produced'.
	taskExecution beginCompletion.
	taskExecution complete.
	self assert: taskExecution isCompleted.
	self assert: (taskExecution hasItemValueFor: optionalOutput) = false.
	self assert: (execution itemValueFor: target) equals: 'produced'.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> activityCompletionRejectsMissingRequiredOutput [
	<gtExample>
	| process task specification output outputSet execution taskExecution errorRaised |
	process := CPProcess new identifier: 'process'; yourself.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	output := CPDataOutput new identifier: 'required'; yourself.
	specification dataOutputs: { output }.
	outputSet := CPOutputSet new dataOutputRefs: { output }; yourself.
	specification outputSets: { outputSet }.
	task ioSpecification: specification.
	process addFlowElement: task.
	execution := self executionFor: process.
	taskExecution := execution createActivityExecutionFor: task.
	taskExecution activate.
	taskExecution beginCompletion.
	errorRaised := false.
	[ taskExecution complete ] on: Error do: [ :error | errorRaised := true ].
	self assert: errorRaised.
	self assert: taskExecution isCompleting.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> serviceTaskResultPopulatesDataOutputBeforeCompletion [
	<gtExample>
	| process target serviceTask operation inputMessage outputMessage specification output outputSet association implementation environment execution serviceExecution invocation result payload |
	process := CPProcess new identifier: 'process'; yourself.
	target := CPDataObject new identifier: 'result'; yourself.
	process addFlowElement: target.
	inputMessage := CPMessage new identifier: 'request'; yourself.
	outputMessage := CPMessage new identifier: 'response'; yourself.
	operation := CPOperation new
		identifier: 'chargeAccount';
		inMessageRef: inputMessage;
		outMessageRef: outputMessage;
		yourself.
	serviceTask := CPServiceTask new
		identifier: 'charge';
		operationRef: operation;
		yourself.
	specification := CPInputOutputSpecification new.
	output := CPDataOutput new identifier: 'responseOutput'; yourself.
	specification dataOutputs: { output }.
	outputSet := CPOutputSet new dataOutputRefs: { output }; yourself.
	specification outputSets: { outputSet }.
	serviceTask ioSpecification: specification.
	association := CPDataOutputAssociation new
		sourceRefs: { output };
		targetRef: target;
		yourself.
	serviceTask dataOutputAssociations: { association }.
	process addFlowElement: serviceTask.
	implementation := Object new.
	environment := CPExampleExecutionEnvironment new
		operation: operation resolvesTo: implementation;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	serviceExecution := execution createServiceTaskExecutionFor: serviceTask.
	execution activateServiceTaskExecution: serviceExecution.
	invocation := serviceExecution prepareExternalInvocationIdentifiedBy: #chargeInvocationWithData.
	payload := Dictionary new at: #authorization put: 'approved'; yourself.
	result := CPExecutionOccurrence new
		occurrenceIdentifier: #chargeResultWithData;
		definition: invocation;
		payload: payload;
		yourself.
	execution completeServiceTaskExecution: serviceExecution withResultOccurrence: result.
	self assert: serviceExecution isCompleted.
	self assert: (serviceExecution itemValueFor: output) == payload.
	self assert: (execution itemValueFor: target) == payload.
	^ serviceExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> receiveTaskMessagePopulatesDataOutputBeforeCompletion [
	<gtExample>
	| process target message receiveTask specification output outputSet association execution receiveExecution occurrence payload |
	process := CPProcess new identifier: 'process'; yourself.
	target := CPDataObject new identifier: 'received'; yourself.
	process addFlowElement: target.
	message := CPMessage new identifier: 'reply'; yourself.
	receiveTask := CPReceiveTask new
		identifier: 'receive';
		messageRef: message;
		yourself.
	specification := CPInputOutputSpecification new.
	output := CPDataOutput new identifier: 'messageOutput'; yourself.
	specification dataOutputs: { output }.
	outputSet := CPOutputSet new dataOutputRefs: { output }; yourself.
	specification outputSets: { outputSet }.
	receiveTask ioSpecification: specification.
	association := CPDataOutputAssociation new
		sourceRefs: { output };
		targetRef: target;
		yourself.
	receiveTask dataOutputAssociations: { association }.
	process addFlowElement: receiveTask.
	execution := self executionFor: process.
	receiveExecution := execution createReceiveTaskExecutionFor: receiveTask.
	execution activateReceiveTaskExecution: receiveExecution.
	payload := Dictionary new at: #customer put: 'customer-1'; yourself.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: #replyWithData;
		definition: message;
		payload: payload;
		yourself.
	execution triggerReceiveTaskExecution: receiveExecution with: occurrence.
	self assert: receiveExecution isCompleted.
	self assert: (receiveExecution itemValueFor: output) == payload.
	self assert: (execution itemValueFor: target) == payload.
	^ receiveExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> serviceTaskExternalInvocationCarriesResolvedInputValue [
	<gtExample>
	| process dataObject serviceTask specification input inputSet association operation implementation environment execution serviceExecution invocation |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'order'; yourself.
	process addFlowElement: dataObject.
	operation := CPOperation new identifier: 'chargeAccount'; yourself.
	serviceTask := CPServiceTask new
		identifier: 'charge';
		operationRef: operation;
		yourself.
	specification := CPInputOutputSpecification new.
	input := CPDataInput new identifier: 'orderInput'; yourself.
	specification dataInputs: { input }.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	specification inputSets: { inputSet }.
	serviceTask ioSpecification: specification.
	association := CPDataInputAssociation new
		sourceRefs: { dataObject };
		targetRef: input;
		yourself.
	serviceTask dataInputAssociations: { association }.
	process addFlowElement: serviceTask.
	implementation := Object new.
	environment := CPExampleExecutionEnvironment new
		operation: operation resolvesTo: implementation;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	execution itemValueFor: dataObject put: 'order-42'.
	serviceExecution := execution createServiceTaskExecutionFor: serviceTask.
	execution activateServiceTaskExecution: serviceExecution.
	invocation := serviceExecution prepareExternalInvocationIdentifiedBy: #chargeOrder42.
	self assert: invocation hasInputValue.
	self assert: invocation inputValue equals: 'order-42'.
	^ invocation
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> serviceTaskExternalInvocationPreservesNilInputValue [
	<gtExample>
	| process serviceTask specification input inputSet operation implementation environment execution serviceExecution invocation |
	process := CPProcess new identifier: 'process'; yourself.
	operation := CPOperation new identifier: 'inspect'; yourself.
	serviceTask := CPServiceTask new
		identifier: 'inspect';
		operationRef: operation;
		yourself.
	specification := CPInputOutputSpecification new.
	input := CPDataInput new identifier: 'input'; yourself.
	specification dataInputs: { input }.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	specification inputSets: { inputSet }.
	serviceTask ioSpecification: specification.
	process addFlowElement: serviceTask.
	implementation := Object new.
	environment := CPExampleExecutionEnvironment new
		operation: operation resolvesTo: implementation;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	serviceExecution := execution createServiceTaskExecutionFor: serviceTask.
	serviceExecution itemValueFor: input put: nil.
	execution activateServiceTaskExecution: serviceExecution.
	invocation := serviceExecution prepareExternalInvocationIdentifiedBy: #inspectNil.
	self assert: invocation hasInputValue.
	self assert: invocation inputValue isNil.
	^ invocation
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> compensationEventSubProcessRestoresCompletionDataSnapshot [
	<gtExample>
	| process booking property dataObject compensationHandler compensationStart compensationDefinition execution bookingExecution bookingScope bookingRecord handlerExecution |
	process := CPProcess new identifier: 'process'; yourself.
	booking := CPNoneSubProcess new identifier: 'booking'; compensable: true; yourself.
	property := CPProperty new identifier: 'bookingProperty'; yourself.
	booking properties add: property.
	dataObject := CPDataObject new identifier: 'bookingData'; yourself.
	booking addFlowElement: dataObject.
	compensationHandler := CPCompensationSubProcess new identifier: 'bookingCompensation'; yourself.
	compensationStart := CPCompensationStartEvent new identifier: 'compensationStart'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensationDefinition'; yourself.
	compensationStart eventDefinitions add: compensationDefinition.
	compensationHandler addFlowElement: compensationStart.
	booking addFlowElement: compensationHandler.
	process addFlowElement: booking.
	execution := self executionFor: process.
	bookingExecution := execution createActivityExecutionFor: booking.
	bookingExecution activate.
	bookingScope := bookingExecution createSubScopeFor: booking.
	bookingExecution itemValueFor: property put: 'property at completion'.
	bookingScope itemValueFor: dataObject put: 'data at completion'.
	bookingExecution beginCompletion; complete.
	bookingRecord := (execution availableCompensationRecordsFor: booking) first.
	bookingExecution itemValueFor: property put: 'property changed later'.
	bookingScope itemValueFor: dataObject put: 'data changed later'.
	handlerExecution := execution beginCompensationFor: bookingRecord.
	self assert: handlerExecution definition == compensationHandler.
	self assert: (bookingExecution itemValueFor: property) equals: 'property at completion'.
	self assert: (bookingScope itemValueFor: dataObject) equals: 'data at completion'.
	^ bookingRecord
]


{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> dataAssociationProvenanceCreatesCompensationDependency [
	<gtExample>
	| process shared firstTask firstSpecification firstOutput firstOutputAssociation secondTask secondSpecification secondInput secondInputAssociation execution firstExecution secondExecution firstRecord secondRecord |
	process := CPProcess new identifier: 'process'; yourself.
	shared := CPDataObject new identifier: 'shared'; yourself.
	process addFlowElement: shared.

	firstTask := CPTask new identifier: 'produce'; yourself.
	firstSpecification := CPInputOutputSpecification new.
	firstOutput := CPDataOutput new identifier: 'produced'; yourself.
	firstSpecification dataOutputs: { firstOutput }.
	firstTask ioSpecification: firstSpecification.
	firstOutputAssociation := CPDataOutputAssociation new
		sourceRefs: { firstOutput };
		targetRef: shared;
		yourself.
	firstTask dataOutputAssociations: { firstOutputAssociation }.
	process addFlowElement: firstTask.

	secondTask := CPTask new identifier: 'consume'; yourself.
	secondSpecification := CPInputOutputSpecification new.
	secondInput := CPDataInput new identifier: 'consumed'; yourself.
	secondSpecification dataInputs: { secondInput }.
	secondTask ioSpecification: secondSpecification.
	secondInputAssociation := CPDataInputAssociation new
		sourceRefs: { shared };
		targetRef: secondInput;
		yourself.
	secondTask dataInputAssociations: { secondInputAssociation }.
	process addFlowElement: secondTask.

	execution := self executionFor: process.
	firstExecution := execution createActivityExecutionFor: firstTask.
	secondExecution := execution createActivityExecutionFor: secondTask.
	firstExecution itemValueFor: firstOutput put: 'value-from-a'.
	self assert: (firstExecution executeDataAssociation: firstOutputAssociation).
	self assert: (secondExecution executeDataAssociation: secondInputAssociation).
	self assert: (secondExecution hasDataDependencyOn: firstExecution).

	firstRecord := CPCompensationRecord new activityExecution: firstExecution; yourself.
	secondRecord := CPCompensationRecord new activityExecution: secondExecution; yourself.
	self assert: (execution compensationRecord: secondRecord mustPrecede: firstRecord).
	self assert: (execution compensationRecord: firstRecord mustPrecede: secondRecord) = false.
	^ secondExecution
]


{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> activityCompletionAcceptsOutputSetExpectedBySelectedInputSet [
	<gtExample>
	| process task specification inputSet output outputSet execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	inputSet := CPInputSet new.
	output := CPDataOutput new identifier: 'output'; yourself.
	outputSet := CPOutputSet new dataOutputRefs: { output }; yourself.
	inputSet outputSetRefs: { outputSet }.
	outputSet inputSetRefs: { inputSet }.
	specification
		dataOutputs: { output };
		inputSets: { inputSet };
		outputSets: { outputSet }.
	task ioSpecification: specification.
	process addFlowElement: task.
	execution := self executionFor: process.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: taskExecution prepareForActivation.
	taskExecution activate.
	taskExecution itemValueFor: output put: 'result'.
	taskExecution beginCompletion.
	taskExecution complete.
	self assert: taskExecution selectedInputSet == inputSet.
	self assert: taskExecution selectedOutputSet == outputSet.
	self assert: taskExecution isCompleted.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> activityCompletionRejectsFirstAvailableOutputSetIncompatibleWithSelectedInputSet [
	<gtExample>
	| process task specification inputSet firstOutput secondOutput firstSet secondSet execution taskExecution errorRaised |
	process := CPProcess new identifier: 'process'; yourself.
	task := CPTask new identifier: 'task'; yourself.
	specification := CPInputOutputSpecification new.
	inputSet := CPInputSet new.
	firstOutput := CPDataOutput new identifier: 'first'; yourself.
	secondOutput := CPDataOutput new identifier: 'second'; yourself.
	firstSet := CPOutputSet new dataOutputRefs: { firstOutput }; yourself.
	secondSet := CPOutputSet new dataOutputRefs: { secondOutput }; yourself.
	inputSet outputSetRefs: { secondSet }.
	secondSet inputSetRefs: { inputSet }.
	specification
		dataOutputs: { firstOutput. secondOutput };
		inputSets: { inputSet };
		outputSets: { firstSet. secondSet }.
	task ioSpecification: specification.
	process addFlowElement: task.
	execution := self executionFor: process.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: taskExecution prepareForActivation.
	taskExecution activate.
	taskExecution itemValueFor: firstOutput put: 'first-result'.
	taskExecution itemValueFor: secondOutput put: 'second-result'.
	taskExecution beginCompletion.
	errorRaised := false.
	[ taskExecution complete ] on: Error do: [ :error | errorRaised := true ].
	self assert: errorRaised.
	self assert: taskExecution isCompleting.
	self assert: taskExecution selectedOutputSet isNil.
	^ taskExecution
]

{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> messageCatchEventCopiesPayloadThroughDataOutputAssociation [
	<gtExample>
	| process start catch message messageDefinition dataOutput dataObject association flow execution eventExecution occurrence payload |
	process := CPProcess new identifier: 'process'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	messageDefinition := CPMessageEventDefinition new messageRef: message; yourself.
	dataOutput := CPDataOutput new identifier: 'receivedData'; yourself.
	dataObject := CPDataObject new identifier: 'processData'; yourself.
	association := CPDataOutputAssociation new
		sourceRefs: { dataOutput };
		targetRef: dataObject;
		yourself.
	catch := CPMessageCatchIntermediateEvent new
		identifier: 'receiveMessage';
		eventDefinitions: { messageDefinition };
		dataOutputs: { dataOutput };
		dataOutputAssociations: { association };
		yourself.
	flow := CPSequenceFlow new identifier: 'toCatch'; sourceRef: start; targetRef: catch; yourself.
	process addFlowElement: start; addFlowElement: catch; addFlowElement: dataObject; addFlowElement: flow.
	execution := self executionFor: process.
	execution start.
	eventExecution := execution beginMessageIntermediateCatchEvent: catch consuming: (execution availableFlowActivationsOn: flow) first.
	payload := Dictionary new at: 'order' put: 42; yourself.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: 'message-1';
		definition: message;
		payload: payload;
		yourself.
	execution triggerMessageIntermediateCatchEventExecution: eventExecution with: occurrence.
	self assert: (eventExecution itemValueFor: dataOutput) == payload.
	self assert: (execution accessibleItemValueFor: dataObject) == payload.
	^ eventExecution
]


{ #category : 'examples - data execution' }
CPExecutionKernelExamples >> messageThrowEventPreparesDataInputFromAssociation [
	<gtExample>
	| process start throw after message messageDefinition dataObject dataInput association incoming outgoing execution eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	messageDefinition := CPMessageEventDefinition new messageRef: message; yourself.
	dataObject := CPDataObject new identifier: 'processData'; yourself.
	dataInput := CPDataInput new identifier: 'messageData'; yourself.
	association := CPDataInputAssociation new
		sourceRefs: { dataObject };
		targetRef: dataInput;
		yourself.
	throw := CPMessageThrowIntermediateEvent new
		identifier: 'sendMessage';
		eventDefinitions: { messageDefinition };
		dataInputs: { dataInput };
		dataInputAssociations: { association };
		yourself.
	after := CPTask new identifier: 'after'; yourself.
	incoming := CPSequenceFlow new identifier: 'toThrow'; sourceRef: start; targetRef: throw; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterThrow'; sourceRef: throw; targetRef: after; yourself.
	process addFlowElement: start; addFlowElement: throw; addFlowElement: after; addFlowElement: dataObject; addFlowElement: incoming; addFlowElement: outgoing.
	execution := self executionFor: process.
	execution accessibleItemValueFor: dataObject put: 'message payload'.
	execution start.
	eventExecution := execution beginIntermediateThrowEvent: throw consuming: (execution availableFlowActivationsOn: incoming) first.
	self assert: (eventExecution itemValueFor: dataInput) equals: 'message payload'.
	self assert: eventExecution thrownOccurrences size equals: 1.
	self assert: eventExecution thrownOccurrences first definition == message.
	self assert: eventExecution thrownOccurrences first payload equals: 'message payload'.
	self assert: eventExecution isPending.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	^ eventExecution
]


{ #category : 'examples - data' }
CPExecutionKernelExamples >> messageStartEventPopulatesProcessDataInput [
	<gtExample>
	| process specification processInput message messageDefinition messageStart eventOutput association after flow execution occurrence eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	processInput := CPDataInput new identifier: 'processInput'; yourself.
	specification := CPInputOutputSpecification new
		dataInputs: { processInput };
		yourself.
	process ioSpecification: specification.
	message := CPMessage new identifier: 'message'; yourself.
	messageDefinition := CPMessageEventDefinition new
		identifier: 'messageDefinition';
		messageRef: message;
		yourself.
	eventOutput := CPDataOutput new identifier: 'eventOutput'; yourself.
	association := CPDataOutputAssociation new
		identifier: 'startOutput';
		sourceRefs: { eventOutput };
		targetRef: processInput;
		yourself.
	messageStart := CPMessageStartEvent new
		identifier: 'messageStart';
		dataOutputs: { eventOutput };
		dataOutputAssociations: { association };
		yourself.
	messageStart eventDefinitions add: messageDefinition.
	after := CPTask new identifier: 'after'; yourself.
	flow := CPSequenceFlow new identifier: 'flow'; sourceRef: messageStart; targetRef: after; yourself.
	process addFlowElement: messageStart; addFlowElement: after; addFlowElement: flow.
	execution := self executionFor: process.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: #messageStartWithData1;
		definition: message;
		payload: 'process input value';
		yourself.
	eventExecution := execution startWithOccurrence: occurrence.
	self assert: (eventExecution itemValueFor: eventOutput) equals: 'process input value'.
	self assert: (execution itemValueFor: processInput) equals: 'process input value'.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	^ eventExecution
]


{ #category : 'examples - data' }
CPExecutionKernelExamples >> messageEndEventUsesProcessDataOutput [
	<gtExample>
	| process specification processOutput start message messageDefinition messageEnd eventInput association flow execution eventExecution |
	process := CPProcess new identifier: 'process'; yourself.
	processOutput := CPDataOutput new identifier: 'processOutput'; yourself.
	specification := CPInputOutputSpecification new
		dataOutputs: { processOutput };
		yourself.
	process ioSpecification: specification.
	start := CPNoneStartEvent new identifier: 'start'; yourself.
	message := CPMessage new identifier: 'message'; yourself.
	messageDefinition := CPMessageEventDefinition new
		identifier: 'messageDefinition';
		messageRef: message;
		yourself.
	eventInput := CPDataInput new identifier: 'eventInput'; yourself.
	association := CPDataInputAssociation new
		identifier: 'endInput';
		sourceRefs: { processOutput };
		targetRef: eventInput;
		yourself.
	messageEnd := CPMessageEndEvent new
		identifier: 'messageEnd';
		dataInputs: { eventInput };
		dataInputAssociations: { association };
		yourself.
	messageEnd eventDefinitions add: messageDefinition.
	flow := CPSequenceFlow new identifier: 'toEnd'; sourceRef: start; targetRef: messageEnd; yourself.
	process addFlowElement: start; addFlowElement: messageEnd; addFlowElement: flow.
	execution := self executionFor: process.
	execution itemValueFor: processOutput put: 'process result'.
	execution start.
	eventExecution := execution executeEndEvent: messageEnd consuming: (execution availableFlowActivationsOn: flow) first.
	self assert: (eventExecution itemValueFor: eventInput) equals: 'process result'.
	self assert: eventExecution thrownOccurrences size equals: 1.
	self assert: eventExecution thrownOccurrences first definition == message.
	self assert: eventExecution thrownOccurrences first payload equals: 'process result'.
	^ eventExecution
]

{ #category : 'examples - call activity' }
CPExecutionKernelExamples >> callActivityMapsCallableProcessDataInterface [
	<gtExample>
	| caller source result calledProcess call callSpecification callInput callOutput calledSpecification calledInput calledOutput inputAssociation outputAssociation execution callExecution calledScope |
	caller := CPProcess new identifier: 'caller'; yourself.
	source := CPDataObject new identifier: 'source'; yourself.
	result := CPDataObject new identifier: 'result'; yourself.
	caller addFlowElement: source.
	caller addFlowElement: result.
	calledProcess := CPProcess new identifier: 'called'; yourself.
	calledSpecification := CPInputOutputSpecification new.
	calledInput := CPDataInput new identifier: 'calledInput'; yourself.
	calledOutput := CPDataOutput new identifier: 'calledOutput'; yourself.
	calledSpecification dataInputs add: calledInput.
	calledSpecification dataOutputs add: calledOutput.
	calledSpecification inputSets first dataInputRefs add: calledInput.
	calledSpecification outputSets first dataOutputRefs add: calledOutput.
	calledProcess ioSpecification: calledSpecification.
	call := CPCallActivity new identifier: 'call'; calledElement: calledProcess; yourself.
	callSpecification := CPInputOutputSpecification new.
	callInput := CPDataInput new identifier: 'callInput'; yourself.
	callOutput := CPDataOutput new identifier: 'callOutput'; yourself.
	callSpecification dataInputs add: callInput.
	callSpecification dataOutputs add: callOutput.
	callSpecification inputSets first dataInputRefs add: callInput.
	callSpecification outputSets first dataOutputRefs add: callOutput.
	call ioSpecification: callSpecification.
	inputAssociation := CPDataInputAssociation new sourceRefs: { source }; targetRef: callInput; yourself.
	outputAssociation := CPDataOutputAssociation new sourceRefs: { callOutput }; targetRef: result; yourself.
	call dataInputAssociations add: inputAssociation.
	call dataOutputAssociations add: outputAssociation.
	caller addFlowElement: call.
	execution := self executionFor: caller.
	execution environment callableElement: calledProcess resolvesTo: calledProcess.
	execution itemValueFor: source put: 'request'.
	callExecution := execution createActivityExecutionFor: call.
	execution activateCallActivityExecution: callExecution.
	calledScope := callExecution subScope.
	self assert: (calledScope itemValueFor: calledInput) equals: 'request'.
	calledScope itemValueFor: calledOutput put: 'response'.
	execution completeCallActivity: callExecution.
	self assert: (callExecution itemValueFor: callOutput) equals: 'response'.
	self assert: (execution itemValueFor: result) equals: 'response'.
	^ callExecution
]


{ #category : 'examples - call activity' }
CPExecutionKernelExamples >> callActivityRejectsMismatchedCallableInputSetsBeforeActivation [
	<gtExample>
	| caller calledProcess call callSpecification callInput calledSpecification calledInput secondCalledInputSet execution callExecution errorRaised |
	caller := CPProcess new identifier: 'caller'; yourself.
	calledProcess := CPProcess new identifier: 'called'; yourself.
	calledSpecification := CPInputOutputSpecification new.
	calledInput := CPDataInput new identifier: 'calledInput'; yourself.
	calledSpecification dataInputs add: calledInput.
	calledSpecification inputSets first dataInputRefs add: calledInput.
	secondCalledInputSet := CPInputSet new.
	secondCalledInputSet dataInputRefs add: calledInput.
	calledSpecification inputSets add: secondCalledInputSet.
	calledProcess ioSpecification: calledSpecification.
	call := CPCallActivity new identifier: 'call'; calledElement: calledProcess; yourself.
	callSpecification := CPInputOutputSpecification new.
	callInput := CPDataInput new identifier: 'callInput'; yourself.
	callSpecification dataInputs add: callInput.
	callSpecification inputSets first dataInputRefs add: callInput.
	call ioSpecification: callSpecification.
	caller addFlowElement: call.
	execution := self executionFor: caller.
	execution environment callableElement: calledProcess resolvesTo: calledProcess.
	callExecution := execution createActivityExecutionFor: call.
	callExecution itemValueFor: callInput put: 'request'.
	errorRaised := false.
	[ execution activateCallActivityExecution: callExecution ] on: Error do: [ :error | errorRaised := true ].
	self assert: errorRaised.
	self assert: callExecution isReady.
	self assert: callExecution subScope isNil.
	^ callExecution
]


{ #category : 'examples - standard loop' }
CPExecutionKernelExamples >> standardLoopExecutionTracksCounterAndPostTestsCondition [
	<gtExample>
	| process task loop condition execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPFormalExpression new identifier: 'continueLoop'; yourself.
	loop := CPStandardLoopCharacteristics new
		testBefore: false;
		loopMaximum: 2;
		loopCondition: condition;
		yourself.
	task := CPTask new
		identifier: 'repeat';
		loopCharacteristics: loop;
		yourself.
	execution := self executionFor: process.
	execution environment expression: condition evaluatesTo: true.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: taskExecution loopCounter equals: 0.
	self assert: taskExecution standardLoopMayBeginNextIteration.
	self assert: taskExecution recordStandardLoopIterationCompletion equals: 1.
	self assert: taskExecution standardLoopMayBeginNextIteration.
	self assert: taskExecution recordStandardLoopIterationCompletion equals: 2.
	self assert: taskExecution standardLoopMayBeginNextIteration not.
	^ taskExecution
]

{ #category : 'examples - standard loop' }
CPExecutionKernelExamples >> standardLoopPreTestCanPreventFirstIteration [
	<gtExample>
	| process task loop condition execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPFormalExpression new identifier: 'continueLoop'; yourself.
	loop := CPStandardLoopCharacteristics new
		testBefore: true;
		loopCondition: condition;
		yourself.
	task := CPTask new
		identifier: 'repeat';
		loopCharacteristics: loop;
		yourself.
	execution := self executionFor: process.
	execution environment expression: condition evaluatesTo: false.
	taskExecution := execution createActivityExecutionFor: task.
	self assert: taskExecution standardLoopMayBeginNextIteration not.
	self assert: taskExecution loopCounter equals: 0.
	^ taskExecution
]


{ #category : 'examples - standard loop' }
CPExecutionKernelExamples >> standardLoopExecutesSequentialIterationsBeforeOutgoingControl [
	<gtExample>
	| process before task after loop condition incoming outgoing execution producer taskExecution firstIteration secondIteration |
	process := CPProcess new identifier: 'process'; yourself.
	before := CPTask new identifier: 'before'; yourself.
	condition := CPFormalExpression new identifier: 'continueLoop'; yourself.
	loop := CPStandardLoopCharacteristics new
		testBefore: false;
		loopMaximum: 2;
		loopCondition: condition;
		yourself.
	task := CPTask new identifier: 'repeat'; loopCharacteristics: loop; yourself.
	after := CPTask new identifier: 'after'; yourself.
	incoming := CPSequenceFlow new identifier: 'toLoop'; sourceRef: before; targetRef: task; yourself.
	outgoing := CPSequenceFlow new identifier: 'afterLoop'; sourceRef: task; targetRef: after; yourself.
	process addFlowElement: before; addFlowElement: task; addFlowElement: after; addFlowElement: incoming; addFlowElement: outgoing.
	execution := self executionFor: process.
	execution environment expression: condition evaluatesTo: true.
	producer := execution createActivityExecutionFor: before.
	producer activate; beginCompletion; complete.
	execution produceOutgoingControlFor: producer.
	taskExecution := execution readyActivityExecutionFor: task.
	execution activateStandardLoopExecution: taskExecution.
	firstIteration := taskExecution activeStandardLoopIteration.
	self assert: firstIteration index equals: 1.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	execution completeStandardLoopIteration: firstIteration of: taskExecution.
	secondIteration := taskExecution activeStandardLoopIteration.
	self assert: secondIteration index equals: 2.
	self assert: taskExecution loopCounter equals: 1.
	self assert: (execution availableFlowActivationsOn: outgoing) isEmpty.
	execution completeStandardLoopIteration: secondIteration of: taskExecution.
	self assert: taskExecution isCompleted.
	self assert: taskExecution loopCounter equals: 2.
	self assert: taskExecution activeStandardLoopIteration isNil.
	self assert: (execution availableFlowActivationsOn: outgoing) size equals: 1.
	^ taskExecution
]


{ #category : 'examples - looping' }
CPExecutionKernelExamples >> standardLoopConditionReceivesActivityExecutionContext [
	<gtExample>
	| process task loop condition execution environment taskExecution iteration |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPFormalExpression new identifier: 'continueLoop'; yourself.
	loop := CPStandardLoopCharacteristics new
		testBefore: false;
		loopMaximum: 2;
		loopCondition: condition;
		yourself.
	task := CPTask new
		identifier: 'loopTask';
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	execution := self executionFor: process.
	environment := execution environment.
	environment expression: condition evaluatesTo: true.
	taskExecution := execution createActivityExecutionFor: task.
	taskExecution activate.
	iteration := taskExecution beginStandardLoopIteration.
	taskExecution completeStandardLoopIteration: iteration.
	self assert: taskExecution standardLoopMayBeginNextIteration.
	self assert: environment lastActivityExecutionUsedForExpressionEvaluation == taskExecution.
	self assert: environment lastLoopCounterAtExpressionEvaluation equals: 1.
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceCardinalityIsEvaluatedOnce [
	<gtExample>
	| process task cardinality loop execution environment taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	cardinality := CPExpression new identifier: 'cardinality'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: cardinality;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: cardinality evaluatesTo: 3;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	self assert: taskExecution initializeMultiInstanceCardinality equals: 3.
	environment expression: cardinality evaluatesTo: 5.
	self assert: taskExecution initializeMultiInstanceCardinality equals: 3.
	self assert: taskExecution multiInstanceCardinality equals: 3.
	self assert: environment lastActivityExecutionUsedForExpressionEvaluation == taskExecution.
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceCardinalityComesFromLoopDataInput [
	<gtExample>
	| process task loopDataInput specification loop execution taskExecution values |
	process := CPProcess new identifier: 'process'; yourself.
	loopDataInput := CPDataInput new
		identifier: 'items';
		isCollection: true;
		yourself.
	specification := CPInputOutputSpecification new
		dataInputs: { loopDataInput };
		yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopDataInputRef: loopDataInput;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		ioSpecification: specification;
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: CPExampleExecutionEnvironment new.
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	values := OrderedCollection withAll: { 'alpha'. 'beta'. 'gamma' }.
	taskExecution itemValueFor: loopDataInput put: values.
	self assert: taskExecution initializeMultiInstanceCardinality equals: 3.
	self assert: taskExecution multiInstanceInputItems equals: values.
	values add: 'delta'.
	self assert: taskExecution initializeMultiInstanceCardinality equals: 3.
	self assert: taskExecution multiInstanceInputItems size equals: 3.
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceInputDataItemIsBoundPerInstance [
	<gtExample>
	| process task loopDataInput inputDataItem specification loop execution taskExecution values firstInstance secondInstance thirdInstance |
	process := CPProcess new identifier: 'process'; yourself.
	loopDataInput := CPDataInput new
		identifier: 'items';
		isCollection: true;
		yourself.
	inputDataItem := CPDataInput new identifier: 'item'; yourself.
	specification := CPInputOutputSpecification new
		dataInputs: { loopDataInput };
		yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopDataInputRef: loopDataInput;
		inputDataItem: inputDataItem;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		ioSpecification: specification;
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: CPExampleExecutionEnvironment new.
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	values := OrderedCollection withAll: { 'alpha'. 'beta'. 'gamma' }.
	taskExecution itemValueFor: loopDataInput put: values.
	self assert: taskExecution initializeMultiInstanceCardinality equals: 3.
	firstInstance := taskExecution beginMultiInstanceActivityExecutionAt: 1.
	secondInstance := taskExecution beginMultiInstanceActivityExecutionAt: 2.
	thirdInstance := taskExecution beginMultiInstanceActivityExecutionAt: 3.
	self assert: (firstInstance itemValueFor: inputDataItem) equals: 'alpha'.
	self assert: (secondInstance itemValueFor: inputDataItem) equals: 'beta'.
	self assert: (thirdInstance itemValueFor: inputDataItem) equals: 'gamma'.
	self assert: taskExecution multiInstanceActivityExecutions size equals: 3.
	self assert: firstInstance activityExecution == taskExecution.
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> sequentialMultiInstanceGeneratesNextOnlyAfterCompletion [
	<gtExample>
	| process task cardinality loop execution taskExecution firstInstance secondInstance |
	process := CPProcess new identifier: 'process'; yourself.
	cardinality := CPExpression new identifier: 'cardinality'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		isSequential: true;
		loopCardinality: cardinality;
		yourself.
	task := CPTask new identifier: 'multiTask'; loopCharacteristics: loop; yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: (CPExampleExecutionEnvironment new
		expression: cardinality evaluatesTo: 3;
		yourself).
	taskExecution := execution addActivityExecution: (CPActivityExecution new definition: task; yourself).
	taskExecution beginMultiInstanceActivityExecutions.
	self assert: taskExecution multiInstanceActivityExecutions size equals: 1.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	self assert: firstInstance index equals: 1.
	firstInstance complete.
	self assert: taskExecution multiInstanceActivityExecutions size equals: 2.
	secondInstance := taskExecution multiInstanceActivityExecutions second.
	self assert: secondInstance index equals: 2.
	self assert: taskExecution multiInstanceCompletedCount equals: 1.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> parallelMultiInstanceGeneratesAllInstancesTogether [
	<gtExample>
	| process task cardinality loop execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	cardinality := CPExpression new identifier: 'cardinality'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		isSequential: false;
		loopCardinality: cardinality;
		yourself.
	task := CPTask new identifier: 'multiTask'; loopCharacteristics: loop; yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: (CPExampleExecutionEnvironment new
		expression: cardinality evaluatesTo: 3;
		yourself).
	taskExecution := execution addActivityExecution: (CPActivityExecution new definition: task; yourself).
	taskExecution beginMultiInstanceActivityExecutions.
	self assert: taskExecution multiInstanceActivityExecutions size equals: 3.
	self assert: taskExecution multiInstanceActivityExecutions first index equals: 1.
	self assert: taskExecution multiInstanceActivityExecutions second index equals: 2.
	self assert: taskExecution multiInstanceActivityExecutions third index equals: 3.
	self assert: taskExecution multiInstanceCompletedCount equals: 0.
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceCompletionConditionCancelsRemainingInstances [
	<gtExample>
	| process task loop condition execution environment taskExecution firstInstance |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPExpression new identifier: 'completionCondition'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		completionCondition: condition;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 3;
		expression: condition evaluatesTo: true;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	self assert: taskExecution multiInstanceActivityExecutions size equals: 3.
	self assert: taskExecution multiInstanceActiveCount equals: 3.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	firstInstance complete.
	self assert: taskExecution multiInstanceCompletedCount equals: 1.
	self assert: taskExecution multiInstanceCancelledCount equals: 2.
	self assert: taskExecution multiInstanceActiveCount equals: 0.
	self assert: taskExecution isCompleted.
	self assert: environment lastActivityExecutionUsedForExpressionEvaluation == firstInstance.
	self assert: environment lastLoopCounterAtExpressionEvaluation equals: 1.
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceOutputDataItemsBuildLoopDataOutputCollection [
	<gtExample>
	| process task specification loopDataOutput instanceOutput loop execution taskExecution firstInstance secondInstance thirdInstance |
	process := CPProcess new identifier: 'process'; yourself.
	loopDataOutput := CPDataOutput new
		identifier: 'results';
		isCollection: true;
		yourself.
	specification := CPInputOutputSpecification new
		dataOutputs: { loopDataOutput };
		yourself.
	instanceOutput := CPDataOutput new identifier: 'instanceResult'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		loopDataOutputRef: loopDataOutput;
		outputDataItem: instanceOutput;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		ioSpecification: specification;
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: (CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 3;
		yourself).
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	secondInstance := taskExecution multiInstanceActivityExecutions second.
	thirdInstance := taskExecution multiInstanceActivityExecutions third.
	firstInstance itemValueFor: instanceOutput put: 'alpha result'.
	secondInstance itemValueFor: instanceOutput put: 'beta result'.
	thirdInstance itemValueFor: instanceOutput put: 'gamma result'.
	firstInstance complete.
	self assert: (taskExecution itemValueFor: loopDataOutput) first equals: 'alpha result'.
	secondInstance complete.
	thirdInstance complete.
	self assert: taskExecution multiInstanceOutputItems equals: (OrderedCollection withAll: {
		'alpha result'. 'beta result'. 'gamma result' }).
	self assert: (taskExecution itemValueFor: loopDataOutput) == taskExecution multiInstanceOutputItems.
	self assert: taskExecution isCompleted.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceCompensationRequiresAllInstancesToCompleteSuccessfully [
	<gtExample>
	| process task loop condition compensationDefinition boundary execution environment taskExecution firstInstance |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPExpression new identifier: 'completionCondition'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		completionCondition: condition;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensation'; yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: task;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: compensationDefinition.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 3;
		expression: condition evaluatesTo: true;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	firstInstance complete.
	self assert: taskExecution isCompleted.
	self assert: taskExecution multiInstanceCompletedCount equals: 1.
	self assert: taskExecution multiInstanceCancelledCount equals: 2.
	self assert: execution availableCompensationRecords isEmpty.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> completedMultiInstanceActivityCreatesCompensationHistory [
	<gtExample>
	| process task loop compensationDefinition boundary execution environment taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensation'; yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: task;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: compensationDefinition.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 2;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	taskExecution multiInstanceActivityExecutions first complete.
	taskExecution multiInstanceActivityExecutions second complete.
	self assert: taskExecution isCompleted.
	self assert: taskExecution multiInstanceCompletedCount equals: 2.
	self assert: taskExecution multiInstanceCancelledCount equals: 0.
	self assert: execution availableCompensationRecords size equals: 1.
	self assert: execution availableCompensationRecords first activityExecution == taskExecution.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceSubProcessInstancesOwnIndependentExecutionScopes [
	<gtExample>
	| process subProcess dataObject loop execution subProcessExecution firstInstance secondInstance |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'instanceData'; yourself.
	subProcess := CPSubProcess new identifier: 'multiSubProcess'; yourself.
	subProcess addFlowElement: dataObject.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		yourself.
	subProcess loopCharacteristics: loop.
	process addFlowElement: subProcess.
	execution := CPProcessExecution
		for: process
		environment: (CPExampleExecutionEnvironment new
			expression: loop loopCardinality evaluatesTo: 2;
			yourself).
	subProcessExecution := execution addActivityExecution: (CPActivityExecution new
		definition: subProcess;
		yourself).
	subProcessExecution activate.
	subProcessExecution beginMultiInstanceActivityExecutions.
	firstInstance := subProcessExecution multiInstanceActivityExecutions first.
	secondInstance := subProcessExecution multiInstanceActivityExecutions second.
	self assert: firstInstance subScope notNil.
	self assert: secondInstance subScope notNil.
	self assert: firstInstance subScope ~~ secondInstance subScope.
	self assert: firstInstance subScope owningActivity == firstInstance.
	self assert: secondInstance subScope owningActivity == secondInstance.
	firstInstance subScope itemValueFor: dataObject put: 'first'.
	secondInstance subScope itemValueFor: dataObject put: 'second'.
	self assert: (firstInstance subScope itemValueFor: dataObject) equals: 'first'.
	self assert: (secondInstance subScope itemValueFor: dataObject) equals: 'second'.
	^ subProcessExecution
]



{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceSubProcessInstanceCapturesCompletionDataSnapshot [
	<gtExample>
	| process subProcess dataObject loop execution subProcessExecution instance |
	process := CPProcess new identifier: 'process'; yourself.
	dataObject := CPDataObject new identifier: 'instanceData'; yourself.
	subProcess := CPSubProcess new identifier: 'multiSubProcess'; yourself.
	subProcess addFlowElement: dataObject.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		yourself.
	subProcess loopCharacteristics: loop.
	process addFlowElement: subProcess.
	execution := CPProcessExecution
		for: process
		environment: (CPExampleExecutionEnvironment new
			expression: loop loopCardinality evaluatesTo: 2;
			yourself).
	subProcessExecution := execution addActivityExecution: (CPActivityExecution new
		definition: subProcess;
		yourself).
	subProcessExecution activate.
	subProcessExecution beginMultiInstanceActivityExecutions.
	instance := subProcessExecution multiInstanceActivityExecutions first.
	instance subScope itemValueFor: dataObject put: 'data at instance completion'.
	instance complete.
	instance subScope itemValueFor: dataObject put: 'data changed later'.
	instance restoreCompensationDataSnapshot.
	self assert: (instance subScope itemValueFor: dataObject) equals: 'data at instance completion'.
	self assert: instance isCompleted.
	self assert: subProcessExecution isActive.
	^ instance
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceCompensationRecordRetainsCompletedInstanceExecutions [
	<gtExample>
	| process subProcess loop compensationHandler compensationStart compensationDefinition execution activityExecution firstInstance secondInstance firstData secondData record |
	process := CPProcess new identifier: 'process'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		yourself.
	subProcess := CPNoneSubProcess new
		identifier: 'multiSubProcess';
		loopCharacteristics: loop;
		yourself.
	compensationHandler := CPCompensationSubProcess new identifier: 'compensationHandler'; yourself.
	compensationStart := CPCompensationStartEvent new identifier: 'compensationStart'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensationDefinition'; yourself.
	compensationStart eventDefinitions add: compensationDefinition.
	compensationHandler addFlowElement: compensationStart.
	firstData := CPDataObject new identifier: 'firstData'; yourself.
	secondData := CPDataObject new identifier: 'secondData'; yourself.
	subProcess addFlowElement: firstData; addFlowElement: secondData; addFlowElement: compensationHandler.
	process addFlowElement: subProcess.
	execution := CPProcessExecution
		for: process
		environment: (CPExampleExecutionEnvironment new
			expression: loop loopCardinality evaluatesTo: 2;
			yourself).
	activityExecution := execution addActivityExecution: (CPActivityExecution new
		definition: subProcess;
		yourself).
	activityExecution activate.
	activityExecution beginMultiInstanceActivityExecutions.
	firstInstance := activityExecution multiInstanceActivityExecutions first.
	secondInstance := activityExecution multiInstanceActivityExecutions second.
	firstInstance subScope itemValueFor: firstData put: 'first snapshot'.
	secondInstance subScope itemValueFor: secondData put: 'second snapshot'.
	firstInstance complete.
	secondInstance complete.
	record := (execution availableCompensationRecordsFor: subProcess) first.
	self assert: record multiInstanceActivityExecutions size equals: 2.
	self assert: record multiInstanceActivityExecutions first == firstInstance.
	self assert: record multiInstanceActivityExecutions second == secondInstance.
	firstInstance subScope itemValueFor: firstData put: 'changed first'.
	secondInstance subScope itemValueFor: secondData put: 'changed second'.
	firstInstance restoreCompensationDataSnapshot.
	secondInstance restoreCompensationDataSnapshot.
	self assert: (firstInstance subScope itemValueFor: firstData) equals: 'first snapshot'.
	self assert: (secondInstance subScope itemValueFor: secondData) equals: 'second snapshot'.
	^ record
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceCustomCompensationRunsOncePerCompletedInstance [
	<gtExample>
	| process subProcess loop compensationHandler compensationStart compensationDefinition undo startFlow dataObject execution activityExecution firstInstance secondInstance record handlerExecutions firstHandler secondHandler firstUndo secondUndo |
	process := CPProcess new identifier: 'process'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		yourself.
	subProcess := CPNoneSubProcess new
		identifier: 'multiSubProcess';
		loopCharacteristics: loop;
		yourself.
	dataObject := CPDataObject new identifier: 'instanceData'; yourself.
	subProcess addFlowElement: dataObject.
	compensationHandler := CPCompensationSubProcess new identifier: 'compensationHandler'; yourself.
	compensationStart := CPCompensationStartEvent new identifier: 'compensationStart'; yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensationDefinition'; yourself.
	compensationStart eventDefinitions add: compensationDefinition.
	undo := CPTask new identifier: 'undo'; yourself.
	startFlow := CPSequenceFlow new identifier: 'startUndo'; sourceRef: compensationStart; targetRef: undo; yourself.
	compensationHandler addFlowElement: compensationStart; addFlowElement: undo; addFlowElement: startFlow.
	subProcess addFlowElement: compensationHandler.
	process addFlowElement: subProcess.
	execution := CPProcessExecution
		for: process
		environment: (CPExampleExecutionEnvironment new
			expression: loop loopCardinality evaluatesTo: 2;
			yourself).
	activityExecution := execution createActivityExecutionFor: subProcess.
	activityExecution activate.
	activityExecution beginMultiInstanceActivityExecutions.
	firstInstance := activityExecution multiInstanceActivityExecutions first.
	secondInstance := activityExecution multiInstanceActivityExecutions second.
	firstInstance subScope itemValueFor: dataObject put: 'first snapshot'.
	secondInstance subScope itemValueFor: dataObject put: 'second snapshot'.
	firstInstance complete.
	secondInstance complete.
	record := (execution availableCompensationRecordsFor: subProcess) first.
	firstInstance subScope itemValueFor: dataObject put: 'changed first'.
	secondInstance subScope itemValueFor: dataObject put: 'changed second'.
	handlerExecutions := execution beginCompensationFor: record.
	self assert: handlerExecutions size equals: 2.
	firstHandler := handlerExecutions first.
	secondHandler := handlerExecutions second.
	self assert: firstHandler scope == firstInstance subScope.
	self assert: secondHandler scope == secondInstance subScope.
	self assert: (firstInstance subScope itemValueFor: dataObject) equals: 'first snapshot'.
	self assert: (secondInstance subScope itemValueFor: dataObject) equals: 'second snapshot'.
	self assert: firstHandler isActive.
	self assert: secondHandler isActive.
	firstUndo := firstHandler subScope readyActivityExecutionFor: undo.
	secondUndo := secondHandler subScope readyActivityExecutionFor: undo.
	firstUndo activate; beginCompletion; complete.
	firstInstance subScope completeSubProcessActivity: firstHandler.
	self assert: record isHandling.
	self assert: record isHandled not.
	secondUndo activate; beginCompletion; complete.
	secondInstance subScope completeSubProcessActivity: secondHandler.
	self assert: record isHandled.
	^ record
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceBoundaryCompensationRunsOncePerCompletedInstance [
	<gtExample>
	| process subProcess loop compensationDefinition boundary handler association execution activityExecution record handlerExecutions |
	process := CPProcess new identifier: 'process'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		yourself.
	subProcess := CPNoneSubProcess new
		identifier: 'multiSubProcess';
		loopCharacteristics: loop;
		yourself.
	compensationDefinition := CPCompensationEventDefinition new identifier: 'compensation'; yourself.
	boundary := CPBoundaryEvent new
		identifier: 'compensationBoundary';
		attachedToRef: subProcess;
		cancelActivity: false;
		yourself.
	boundary eventDefinitions add: compensationDefinition.
	handler := CPTask new identifier: 'undo'; isForCompensation: true; yourself.
	process addFlowElement: subProcess.
	process addFlowElement: handler.
	association := CPAssociation new
		identifier: 'compensationHandler';
		sourceRef: boundary;
		targetRef: handler;
		beOne;
		yourself.
	process addArtifact: association.
	execution := CPProcessExecution
		for: process
		environment: (CPExampleExecutionEnvironment new
			expression: loop loopCardinality evaluatesTo: 2;
			yourself).
	activityExecution := execution createActivityExecutionFor: subProcess.
	activityExecution activate.
	activityExecution beginMultiInstanceActivityExecutions.
	activityExecution multiInstanceActivityExecutions first complete.
	activityExecution multiInstanceActivityExecutions second complete.
	record := (execution availableCompensationRecordsFor: subProcess) first.
	self assert: record boundaryEvent == boundary.
	self assert: record multiInstanceActivityExecutions size equals: 2.
	handlerExecutions := execution beginCompensationFor: record.
	self assert: handlerExecutions size equals: 2.
	self assert: handlerExecutions first ~~ handlerExecutions second.
	self assert: handlerExecutions first scope == execution.
	self assert: handlerExecutions second scope == execution.
	self assert: handlerExecutions first definition == handler.
	self assert: handlerExecutions second definition == handler.
	self assert: handlerExecutions first isActive.
	self assert: handlerExecutions second isActive.
	handlerExecutions first beginCompletion; complete.
	self assert: record isHandling.
	self assert: record isHandled not.
	handlerExecutions second beginCompletion; complete.
	self assert: record isHandled.
	^ record
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> sequentialMultiInstanceCompletionConditionStopsBeforeNextInstance [
	<gtExample>
	| process task loop condition execution environment taskExecution firstInstance |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPExpression new identifier: 'completionCondition'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		completionCondition: condition;
		isSequential: true;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 3;
		expression: condition evaluatesTo: true;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	self assert: taskExecution multiInstanceActivityExecutions size equals: 1.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	firstInstance complete.
	self assert: taskExecution multiInstanceActivityExecutions size equals: 1.
	self assert: taskExecution multiInstanceCompletedCount equals: 1.
	self assert: taskExecution multiInstanceCancelledCount equals: 0.
	self assert: taskExecution isCompleted.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceFalseCompletionConditionWaitsForAllInstances [
	<gtExample>
	| process task loop condition execution environment taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPExpression new identifier: 'completionCondition'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		completionCondition: condition;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 2;
		expression: condition evaluatesTo: false;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	taskExecution multiInstanceActivityExecutions first complete.
	self assert: taskExecution isActive.
	self assert: taskExecution multiInstanceCompletedCount equals: 1.
	taskExecution multiInstanceActivityExecutions second complete.
	self assert: taskExecution multiInstanceCompletedCount equals: 2.
	self assert: taskExecution isCompleted.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceCompletionConditionRequiresBooleanResult [
	<gtExample>
	| process task loop condition execution environment taskExecution error |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPExpression new identifier: 'completionCondition'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		completionCondition: condition;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 1;
		expression: condition evaluatesTo: 'not boolean';
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	error := nil.
	[ taskExecution multiInstanceActivityExecutions first complete ]
		on: Error
		do: [ :caught | error := caught ].
	self assert: error notNil.
	self assert: error messageText equals: 'A Multi-Instance completionCondition must evaluate to a boolean.'.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceRuntimeAttributesTrackGeneratedInstances [
	<gtExample>
	| process task loop execution taskExecution firstInstance secondInstance |
	process := CPProcess new identifier: 'process'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		isSequential: true;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	execution := CPProcessExecution
		for: process
		environment: (CPExampleExecutionEnvironment new
			expression: loop loopCardinality evaluatesTo: 3;
			yourself).
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	self assert: taskExecution numberOfInstances equals: 1.
	self assert: taskExecution numberOfActiveInstances equals: 1.
	self assert: taskExecution numberOfCompletedInstances equals: 0.
	self assert: taskExecution numberOfTerminatedInstances equals: 0.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	self assert: firstInstance loopCounter equals: 1.
	firstInstance complete.
	self assert: taskExecution numberOfInstances equals: 2.
	self assert: taskExecution numberOfActiveInstances equals: 1.
	self assert: taskExecution numberOfCompletedInstances equals: 1.
	self assert: taskExecution numberOfTerminatedInstances equals: 0.
	secondInstance := taskExecution multiInstanceActivityExecutions second.
	self assert: secondInstance loopCounter equals: 2.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceRuntimeAttributesTrackTerminatedInstances [
	<gtExample>
	| process task loop condition execution taskExecution firstInstance |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPExpression new identifier: 'completionCondition'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		completionCondition: condition;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	execution := CPProcessExecution
		for: process
		environment: (CPExampleExecutionEnvironment new
			expression: loop loopCardinality evaluatesTo: 3;
			expression: condition evaluatesTo: true;
			yourself).
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	firstInstance complete.
	self assert: taskExecution numberOfInstances equals: 3.
	self assert: taskExecution numberOfActiveInstances equals: 0.
	self assert: taskExecution numberOfCompletedInstances equals: 1.
	self assert: taskExecution numberOfTerminatedInstances equals: 2.
	self assert: (taskExecution numberOfActiveInstances
		+ taskExecution numberOfCompletedInstances
		+ taskExecution numberOfTerminatedInstances) equals: taskExecution numberOfInstances.
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceNoneBehaviorThrowsForEveryCompletedInstance [
	<gtExample>
	| process task loop signal eventDefinition execution taskExecution first second firstOccurrence secondOccurrence |
	process := CPProcess new identifier: 'process'; yourself.
	signal := CPSignal new identifier: 'progress'; yourself.
	eventDefinition := CPSignalEventDefinition new signalRef: signal; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		noneBehaviorEventRef: eventDefinition;
		beNone;
		yourself.
	task := CPTask new identifier: 'multiTask'; loopCharacteristics: loop; yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: (CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 2;
		yourself).
	taskExecution := execution addActivityExecution: (CPActivityExecution new definition: task; yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	first := taskExecution multiInstanceActivityExecutions first.
	second := taskExecution multiInstanceActivityExecutions second.
	first complete.
	second complete.
	self assert: first thrownOccurrences size equals: 1.
	self assert: second thrownOccurrences size equals: 1.
	firstOccurrence := first thrownOccurrences first.
	secondOccurrence := second thrownOccurrences first.
	self assert: firstOccurrence definition == signal.
	self assert: secondOccurrence definition == signal.
	self assert: (firstOccurrence payload at: 'loopCounter') equals: 1.
	self assert: (firstOccurrence payload at: 'numberOfCompletedInstances') equals: 1.
	self assert: (secondOccurrence payload at: 'loopCounter') equals: 2.
	self assert: (secondOccurrence payload at: 'numberOfCompletedInstances') equals: 2.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceOneBehaviorThrowsOnlyForFirstCompletedInstance [
	<gtExample>
	| process task loop signal eventDefinition execution taskExecution first second occurrence |
	process := CPProcess new identifier: 'process'; yourself.
	signal := CPSignal new identifier: 'firstProgress'; yourself.
	eventDefinition := CPSignalEventDefinition new signalRef: signal; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		oneBehaviorEventRef: eventDefinition;
		beOne;
		yourself.
	task := CPTask new identifier: 'multiTask'; loopCharacteristics: loop; yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: (CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 2;
		yourself).
	taskExecution := execution addActivityExecution: (CPActivityExecution new definition: task; yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	first := taskExecution multiInstanceActivityExecutions first.
	second := taskExecution multiInstanceActivityExecutions second.
	second complete.
	first complete.
	self assert: second thrownOccurrences size equals: 1.
	self assert: first thrownOccurrences isEmpty.
	occurrence := second thrownOccurrences first.
	self assert: occurrence definition == signal.
	self assert: (occurrence payload at: 'loopCounter') equals: 2.
	self assert: (occurrence payload at: 'numberOfCompletedInstances') equals: 1.
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceComplexBehaviorEvaluatesEveryDefinitionAndThrowsEachSatisfiedEvent [
	<gtExample>
	| process task loop firstCondition secondCondition thirdCondition firstSignal secondSignal thirdSignal firstEvent secondEvent thirdEvent firstBehavior secondBehavior thirdBehavior execution taskExecution instance occurrences |
	process := CPProcess new identifier: 'process'; yourself.
	firstCondition := CPFormalExpression new identifier: 'firstCondition'; yourself.
	secondCondition := CPFormalExpression new identifier: 'secondCondition'; yourself.
	thirdCondition := CPFormalExpression new identifier: 'thirdCondition'; yourself.
	firstSignal := CPSignal new identifier: 'firstProgress'; yourself.
	secondSignal := CPSignal new identifier: 'secondProgress'; yourself.
	thirdSignal := CPSignal new identifier: 'thirdProgress'; yourself.
	firstEvent := CPImplicitThrowEvent new
		identifier: 'firstEvent';
		eventDefinitions: { CPSignalEventDefinition new signalRef: firstSignal; yourself };
		yourself.
	secondEvent := CPImplicitThrowEvent new
		identifier: 'secondEvent';
		eventDefinitions: { CPSignalEventDefinition new signalRef: secondSignal; yourself };
		yourself.
	thirdEvent := CPImplicitThrowEvent new
		identifier: 'thirdEvent';
		eventDefinitions: { CPSignalEventDefinition new signalRef: thirdSignal; yourself };
		yourself.
	firstBehavior := CPComplexBehaviorDefinition new condition: firstCondition; event: firstEvent; yourself.
	secondBehavior := CPComplexBehaviorDefinition new condition: secondCondition; event: secondEvent; yourself.
	thirdBehavior := CPComplexBehaviorDefinition new condition: thirdCondition; event: thirdEvent; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		complexBehaviorDefinitions: { firstBehavior. secondBehavior. thirdBehavior };
		beComplex;
		yourself.
	task := CPTask new identifier: 'multiTask'; loopCharacteristics: loop; yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: (CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 1;
		expression: firstCondition evaluatesTo: true;
		expression: secondCondition evaluatesTo: false;
		expression: thirdCondition evaluatesTo: true;
		yourself).
	taskExecution := execution addActivityExecution: (CPActivityExecution new definition: task; yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	instance := taskExecution multiInstanceActivityExecutions first.
	instance complete.
	occurrences := instance thrownOccurrences.
	self assert: occurrences size equals: 2.
	self assert: occurrences first definition == firstSignal.
	self assert: occurrences second definition == thirdSignal.
	self assert: (occurrences first payload at: 'loopCounter') equals: 1.
	self assert: (occurrences first payload at: 'numberOfCompletedInstances') equals: 1.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceComplexBehaviorRequiresBooleanConditionResult [
	<gtExample>
	| process task loop condition signal implicitEvent behavior execution taskExecution instance errorRaised |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPFormalExpression new identifier: 'condition'; yourself.
	signal := CPSignal new identifier: 'progress'; yourself.
	implicitEvent := CPImplicitThrowEvent new
		identifier: 'progressEvent';
		eventDefinitions: { CPSignalEventDefinition new signalRef: signal; yourself };
		yourself.
	behavior := CPComplexBehaviorDefinition new condition: condition; event: implicitEvent; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		complexBehaviorDefinitions: { behavior };
		beComplex;
		yourself.
	task := CPTask new identifier: 'multiTask'; loopCharacteristics: loop; yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: (CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 1;
		expression: condition evaluatesTo: 'not boolean';
		yourself).
	taskExecution := execution addActivityExecution: (CPActivityExecution new definition: task; yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	instance := taskExecution multiInstanceActivityExecutions first.
	errorRaised := false.
	[ instance complete ] on: Error do: [ :error | errorRaised := true ].
	self assert: errorRaised.
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceCompletionProducesOutgoingControlFlow [
	<gtExample>
	| process task target flow loop execution taskExecution firstInstance secondInstance |
	process := CPProcess new identifier: 'process'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	target := CPTask new identifier: 'target'; yourself.
	flow := CPSequenceFlow new
		identifier: 'afterMulti';
		sourceRef: task;
		targetRef: target;
		yourself.
	process addFlowElement: task; addFlowElement: target; addFlowElement: flow.
	execution := CPProcessExecution
		for: process
		environment: (CPExampleExecutionEnvironment new
			expression: loop loopCardinality evaluatesTo: 2;
			yourself).
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	secondInstance := taskExecution multiInstanceActivityExecutions second.
	firstInstance complete.
	self assert: (execution availableFlowActivationsOn: flow) isEmpty.
	secondInstance complete.
	self assert: taskExecution isCompleted.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	self assert: (execution canReadyActivity: target).
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceCompletionConditionProducesOutgoingControlFlowOnce [
	<gtExample>
	| process task target flow loop condition execution environment taskExecution firstInstance |
	process := CPProcess new identifier: 'process'; yourself.
	condition := CPExpression new identifier: 'completionCondition'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		completionCondition: condition;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		loopCharacteristics: loop;
		yourself.
	target := CPTask new identifier: 'target'; yourself.
	flow := CPSequenceFlow new
		identifier: 'afterMulti';
		sourceRef: task;
		targetRef: target;
		yourself.
	process addFlowElement: task; addFlowElement: target; addFlowElement: flow.
	environment := CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 3;
		expression: condition evaluatesTo: true;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution addActivityExecution: (CPActivityExecution new
		definition: task;
		yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	firstInstance complete.
	self assert: taskExecution isCompleted.
	self assert: taskExecution multiInstanceCancelledCount equals: 2.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	self assert: (execution canReadyActivity: target).
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceActivityLocalDataIsOwnedPerInstance [
	<gtExample>
	| process task loopDataInput activityInput activityOutput activityProperty specification loop execution taskExecution firstInstance secondInstance |
	process := CPProcess new identifier: 'process'; yourself.
	loopDataInput := CPDataInput new identifier: 'items'; isCollection: true; yourself.
	activityInput := CPDataInput new identifier: 'activityInput'; yourself.
	activityOutput := CPDataOutput new identifier: 'activityOutput'; yourself.
	activityProperty := CPProperty new identifier: 'activityProperty'; yourself.
	specification := CPInputOutputSpecification new
		dataInputs: { loopDataInput. activityInput };
		dataOutputs: { activityOutput };
		yourself.
	loop := CPMultiInstanceLoopCharacteristics new loopDataInputRef: loopDataInput; yourself.
	task := CPTask new
		identifier: 'multiTask';
		properties: { activityProperty };
		ioSpecification: specification;
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: CPExampleExecutionEnvironment new.
	taskExecution := execution addActivityExecution: (CPActivityExecution new definition: task; yourself).
	taskExecution itemValueFor: loopDataInput put: (OrderedCollection withAll: { 'first'. 'second' }).
	self assert: taskExecution initializeMultiInstanceCardinality equals: 2.
	firstInstance := taskExecution beginMultiInstanceActivityExecutionAt: 1.
	secondInstance := taskExecution beginMultiInstanceActivityExecutionAt: 2.
	firstInstance itemValueFor: activityInput put: 'first input'.
	secondInstance itemValueFor: activityInput put: 'second input'.
	firstInstance itemValueFor: activityOutput put: 'first output'.
	secondInstance itemValueFor: activityOutput put: 'second output'.
	firstInstance itemValueFor: activityProperty put: 'first property'.
	secondInstance itemValueFor: activityProperty put: 'second property'.
	self assert: (firstInstance itemValueFor: activityInput) equals: 'first input'.
	self assert: (secondInstance itemValueFor: activityInput) equals: 'second input'.
	self assert: (firstInstance itemValueFor: activityOutput) equals: 'first output'.
	self assert: (secondInstance itemValueFor: activityOutput) equals: 'second output'.
	self assert: (firstInstance itemValueFor: activityProperty) equals: 'first property'.
	self assert: (secondInstance itemValueFor: activityProperty) equals: 'second property'.
	self assert: (taskExecution ownsItemValueFor: loopDataInput).
	self assert: (firstInstance ownsItemValueFor: loopDataInput) equals: false.
	self assert: (secondInstance ownsItemValueFor: loopDataInput) equals: false.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceDataAssociationsExecutePerInstance [
	<gtExample>
	| process task loopDataInput loopDataOutput activityInput activityOutput inputDataItem outputDataItem inputSet outerInputSet outputSet outerOutputSet specification inputAssociation outputAssociation loop execution taskExecution firstInstance secondInstance |
	process := CPProcess new identifier: 'process'; yourself.
	loopDataInput := CPDataInput new identifier: 'items'; isCollection: true; yourself.
	loopDataOutput := CPDataOutput new identifier: 'results'; isCollection: true; yourself.
	activityInput := CPDataInput new identifier: 'activityInput'; yourself.
	activityOutput := CPDataOutput new identifier: 'activityOutput'; yourself.
	inputDataItem := CPDataInput new identifier: 'instanceInput'; yourself.
	outputDataItem := CPDataOutput new identifier: 'instanceOutput'; yourself.
	inputSet := CPInputSet new dataInputRefs: { activityInput }; yourself.
	outerInputSet := CPInputSet new dataInputRefs: { loopDataInput }; yourself.
	outputSet := CPOutputSet new dataOutputRefs: { activityOutput }; yourself.
	outerOutputSet := CPOutputSet new dataOutputRefs: { loopDataOutput }; yourself.
	specification := CPInputOutputSpecification new
		dataInputs: { loopDataInput. activityInput };
		dataOutputs: { loopDataOutput. activityOutput };
		inputSets: { inputSet. outerInputSet };
		outputSets: { outputSet. outerOutputSet };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { inputDataItem };
		targetRef: activityInput;
		yourself.
	outputAssociation := CPDataOutputAssociation new
		sourceRefs: { activityOutput };
		targetRef: outputDataItem;
		yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopDataInputRef: loopDataInput;
		loopDataOutputRef: loopDataOutput;
		inputDataItem: inputDataItem;
		outputDataItem: outputDataItem;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		ioSpecification: specification;
		dataInputAssociations: { inputAssociation };
		dataOutputAssociations: { outputAssociation };
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	execution := CPProcessExecution for: process environment: CPExampleExecutionEnvironment new.
	taskExecution := execution addActivityExecution: (CPActivityExecution new definition: task; yourself).
	taskExecution itemValueFor: loopDataInput put: (OrderedCollection withAll: { 'first'. 'second' }).
	taskExecution activate.
	taskExecution initializeMultiInstanceCardinality.
	firstInstance := taskExecution beginMultiInstanceActivityExecutionAt: 1.
	secondInstance := taskExecution beginMultiInstanceActivityExecutionAt: 2.
	self assert: (firstInstance itemValueFor: activityInput) equals: 'first'.
	self assert: (secondInstance itemValueFor: activityInput) equals: 'second'.
	self assert: (firstInstance accessibleItemValueFor: loopDataInput) equals: (OrderedCollection withAll: { 'first'. 'second' }).
	self assert: (secondInstance accessibleItemValueFor: loopDataInput) equals: (OrderedCollection withAll: { 'first'. 'second' }).
	self assert: firstInstance selectedInputSet == inputSet.
	self assert: secondInstance selectedInputSet == inputSet.
	firstInstance itemValueFor: activityOutput put: 'first result'.
	secondInstance itemValueFor: activityOutput put: 'second result'.
	firstInstance complete.
	secondInstance complete.
	self assert: (firstInstance itemValueFor: outputDataItem) equals: 'first result'.
	self assert: (secondInstance itemValueFor: outputDataItem) equals: 'second result'.
	self assert: firstInstance selectedOutputSet == outputSet.
	self assert: secondInstance selectedOutputSet == outputSet.
	self assert: taskExecution multiInstanceOutputItems equals: (OrderedCollection withAll: {
		'first result'. 'second result' }).
	self assert: (taskExecution itemValueFor: loopDataOutput) equals: (OrderedCollection withAll: {
		'first result'. 'second result' }).
	self assert: (firstInstance accessibleItemValueFor: loopDataOutput) equals: (OrderedCollection withAll: {
		'first result'. 'second result' }).
	self assert: (secondInstance accessibleItemValueFor: loopDataOutput) equals: (OrderedCollection withAll: {
		'first result'. 'second result' }).
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceLoopDataOutputIsNotPublishedAfterEarlyCompletion [
	<gtExample>
	| process target task loopDataOutput outputDataItem inputSet outputSet specification outputAssociation condition loop environment execution taskExecution firstInstance |
	process := CPProcess new identifier: 'process'; yourself.
	target := CPDataObject new identifier: 'publishedResults'; isCollection: true; yourself.
	process addFlowElement: target.
	loopDataOutput := CPDataOutput new identifier: 'results'; isCollection: true; yourself.
	outputDataItem := CPDataOutput new identifier: 'instanceOutput'; yourself.
	inputSet := CPInputSet new yourself.
	outputSet := CPOutputSet new
		dataOutputRefs: { loopDataOutput };
		optionalOutputRefs: { loopDataOutput };
		yourself.
	specification := CPInputOutputSpecification new
		dataOutputs: { loopDataOutput };
		inputSets: { inputSet };
		outputSets: { outputSet };
		yourself.
	outputAssociation := CPDataOutputAssociation new
		sourceRefs: { loopDataOutput };
		targetRef: target;
		yourself.
	condition := CPExpression new identifier: 'completionCondition'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		loopDataOutputRef: loopDataOutput;
		outputDataItem: outputDataItem;
		completionCondition: condition;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		ioSpecification: specification;
		dataOutputAssociations: { outputAssociation };
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 2;
		expression: condition evaluatesTo: true;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution addActivityExecution: (CPActivityExecution new definition: task; yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	firstInstance itemValueFor: outputDataItem put: 'first result'.
	firstInstance complete.
	self assert: taskExecution isCompleted.
	self assert: taskExecution multiInstanceCompletedCount equals: 1.
	self assert: taskExecution multiInstanceCancelledCount equals: 1.
	self assert: (taskExecution hasItemValueFor: loopDataOutput).
	self assert: (execution hasItemValueFor: target) equals: false.
	^ taskExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceLoopDataOutputPublishesAfterAllItemsAreWritten [
	<gtExample>
	| process target task loopDataOutput outputDataItem inputSet outputSet specification outputAssociation loop environment execution taskExecution firstInstance secondInstance |
	process := CPProcess new identifier: 'process'; yourself.
	target := CPDataObject new identifier: 'publishedResults'; isCollection: true; yourself.
	process addFlowElement: target.
	loopDataOutput := CPDataOutput new identifier: 'results'; isCollection: true; yourself.
	outputDataItem := CPDataOutput new identifier: 'instanceOutput'; yourself.
	inputSet := CPInputSet new yourself.
	outputSet := CPOutputSet new dataOutputRefs: { loopDataOutput }; yourself.
	specification := CPInputOutputSpecification new
		dataOutputs: { loopDataOutput };
		inputSets: { inputSet };
		outputSets: { outputSet };
		yourself.
	outputAssociation := CPDataOutputAssociation new
		sourceRefs: { loopDataOutput };
		targetRef: target;
		yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: (CPExpression new identifier: 'cardinality'; yourself);
		loopDataOutputRef: loopDataOutput;
		outputDataItem: outputDataItem;
		yourself.
	task := CPTask new
		identifier: 'multiTask';
		ioSpecification: specification;
		dataOutputAssociations: { outputAssociation };
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: loop loopCardinality evaluatesTo: 2;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution addActivityExecution: (CPActivityExecution new definition: task; yourself).
	taskExecution activate.
	taskExecution beginMultiInstanceActivityExecutions.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	secondInstance := taskExecution multiInstanceActivityExecutions second.
	firstInstance itemValueFor: outputDataItem put: 'first result'.
	secondInstance itemValueFor: outputDataItem put: 'second result'.
	firstInstance complete.
	self assert: taskExecution isActive.
	self assert: (execution hasItemValueFor: target) equals: false.
	secondInstance complete.
	self assert: taskExecution isCompleted.
	self assert: (execution itemValueFor: target) equals: (OrderedCollection withAll: {
		'first result'. 'second result' }).
	^ taskExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceServiceTaskExecutesExternalWorkPerInstance [
	<gtExample>
	| process serviceTask operation outMessage implementation environment execution serviceExecution loopDataInput loopDataOutput activityInput activityOutput inputDataItem outputDataItem inputSet outerInputSet outputSet outerOutputSet specification inputAssociation outputAssociation loop firstInstance secondInstance firstInvocation secondInvocation firstResult secondResult |
	process := CPProcess new identifier: 'process'; yourself.
	loopDataInput := CPDataInput new identifier: 'items'; isCollection: true; yourself.
	loopDataOutput := CPDataOutput new identifier: 'results'; isCollection: true; yourself.
	activityInput := CPDataInput new identifier: 'activityInput'; yourself.
	activityOutput := CPDataOutput new identifier: 'activityOutput'; yourself.
	inputDataItem := CPDataInput new identifier: 'instanceInput'; yourself.
	outputDataItem := CPDataOutput new identifier: 'instanceOutput'; yourself.
	inputSet := CPInputSet new dataInputRefs: { activityInput }; yourself.
	outerInputSet := CPInputSet new dataInputRefs: { loopDataInput }; yourself.
	outputSet := CPOutputSet new dataOutputRefs: { activityOutput }; yourself.
	outerOutputSet := CPOutputSet new dataOutputRefs: { loopDataOutput }; yourself.
	specification := CPInputOutputSpecification new
		dataInputs: { loopDataInput. activityInput };
		dataOutputs: { loopDataOutput. activityOutput };
		inputSets: { inputSet. outerInputSet };
		outputSets: { outputSet. outerOutputSet };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { inputDataItem };
		targetRef: activityInput;
		yourself.
	outputAssociation := CPDataOutputAssociation new
		sourceRefs: { activityOutput };
		targetRef: outputDataItem;
		yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopDataInputRef: loopDataInput;
		loopDataOutputRef: loopDataOutput;
		inputDataItem: inputDataItem;
		outputDataItem: outputDataItem;
		yourself.
	outMessage := CPMessage new identifier: 'resultMessage'; yourself.
	operation := CPOperation new identifier: 'performItem'; outMessageRef: outMessage; yourself.
	serviceTask := CPServiceTask new
		identifier: 'multiService';
		operationRef: operation;
		ioSpecification: specification;
		dataInputAssociations: { inputAssociation };
		dataOutputAssociations: { outputAssociation };
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: serviceTask.
	implementation := Object new.
	environment := CPExampleExecutionEnvironment new
		operation: operation resolvesTo: implementation;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	serviceExecution := execution createServiceTaskExecutionFor: serviceTask.
	serviceExecution itemValueFor: loopDataInput put: (OrderedCollection withAll: { 'first'. 'second' }).
	execution activateServiceTaskExecution: serviceExecution.
	serviceExecution beginMultiInstanceActivityExecutions.
	firstInstance := serviceExecution multiInstanceActivityExecutions first.
	secondInstance := serviceExecution multiInstanceActivityExecutions second.
	firstInvocation := firstInstance prepareExternalInvocationIdentifiedBy: #firstInvocation.
	secondInvocation := secondInstance prepareExternalInvocationIdentifiedBy: #secondInvocation.
	self assert: firstInvocation activityExecution == firstInstance.
	self assert: secondInvocation activityExecution == secondInstance.
	self assert: firstInvocation implementation == implementation.
	self assert: secondInvocation implementation == implementation.
	self assert: firstInvocation inputValue equals: 'first'.
	self assert: secondInvocation inputValue equals: 'second'.
	firstResult := CPExecutionOccurrence new
		occurrenceIdentifier: #firstResult;
		definition: firstInvocation;
		payload: 'first result';
		yourself.
	secondResult := CPExecutionOccurrence new
		occurrenceIdentifier: #secondResult;
		definition: secondInvocation;
		payload: 'second result';
		yourself.
	execution completeMultiInstanceServiceTaskExecution: firstInstance withResultOccurrence: firstResult.
	self assert: firstInstance isCompleted.
	self assert: secondInstance isActive.
	self assert: serviceExecution isActive.
	execution completeMultiInstanceServiceTaskExecution: secondInstance withResultOccurrence: secondResult.
	self assert: secondInstance isCompleted.
	self assert: serviceExecution isCompleted.
	self assert: (serviceExecution itemValueFor: loopDataOutput) equals: (OrderedCollection withAll: {
		'first result'. 'second result' }).
	^ serviceExecution
]

{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceReceiveTaskWaitsPerInstance [
	<gtExample>
	| process message receiveTask loopDataInput loopDataOutput activityOutput outputDataItem outerInputSet outputSet outerOutputSet specification outputAssociation loop execution receiveExecution firstInstance secondInstance firstSubscription secondSubscription ambiguous firstOccurrence secondOccurrence |
	process := CPProcess new identifier: 'process'; yourself.
	message := CPMessage new identifier: 'request'; yourself.
	loopDataInput := CPDataInput new identifier: 'items'; isCollection: true; yourself.
	loopDataOutput := CPDataOutput new identifier: 'results'; isCollection: true; yourself.
	activityOutput := CPDataOutput new identifier: 'activityOutput'; yourself.
	outputDataItem := CPDataOutput new identifier: 'instanceOutput'; yourself.
	outerInputSet := CPInputSet new dataInputRefs: { loopDataInput }; yourself.
	outputSet := CPOutputSet new dataOutputRefs: { activityOutput }; yourself.
	outerOutputSet := CPOutputSet new dataOutputRefs: { loopDataOutput }; yourself.
	specification := CPInputOutputSpecification new
		dataInputs: { loopDataInput };
		dataOutputs: { loopDataOutput. activityOutput };
		inputSets: { outerInputSet };
		outputSets: { outputSet. outerOutputSet };
		yourself.
	outputAssociation := CPDataOutputAssociation new
		sourceRefs: { activityOutput };
		targetRef: outputDataItem;
		yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopDataInputRef: loopDataInput;
		loopDataOutputRef: loopDataOutput;
		outputDataItem: outputDataItem;
		yourself.
	receiveTask := CPReceiveTask new
		identifier: 'multiReceive';
		messageRef: message;
		ioSpecification: specification;
		dataOutputAssociations: { outputAssociation };
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: receiveTask.
	execution := self executionFor: process.
	receiveExecution := execution createReceiveTaskExecutionFor: receiveTask.
	receiveExecution itemValueFor: loopDataInput put: (OrderedCollection withAll: { 'first'. 'second' }).
	execution activateReceiveTaskExecution: receiveExecution.
	firstInstance := receiveExecution multiInstanceActivityExecutions first.
	secondInstance := receiveExecution multiInstanceActivityExecutions second.
	firstSubscription := firstInstance messageSubscription.
	secondSubscription := secondInstance messageSubscription.
	self assert: receiveExecution subscription isNil.
	self assert: firstSubscription waitingExecution == firstInstance.
	self assert: secondSubscription waitingExecution == secondInstance.
	self assert: firstSubscription isWaiting.
	self assert: secondSubscription isWaiting.
	self assert: execution waitingMessageSubscriptions size equals: 2.
	ambiguous := false.
	[ execution deliverMessageOccurrence: (CPExecutionOccurrence new
		occurrenceIdentifier: #ambiguousRequest;
		definition: message;
		payload: 'ambiguous';
		yourself) ]
		on: Error
		do: [ :error | ambiguous := true ].
	self assert: ambiguous.
	firstOccurrence := CPExecutionOccurrence new
		occurrenceIdentifier: #firstRequest;
		definition: message;
		payload: 'first result';
		yourself.
	firstSubscription deliverOccurrence: firstOccurrence.
	self assert: firstInstance receivedOccurrence == firstOccurrence.
	self assert: firstInstance isCompleted.
	self assert: secondInstance isActive.
	self assert: receiveExecution isActive.
	self assert: execution waitingMessageSubscriptions size equals: 1.
	secondOccurrence := CPExecutionOccurrence new
		occurrenceIdentifier: #secondRequest;
		definition: message;
		payload: 'second result';
		yourself.
	execution deliverMessageOccurrence: secondOccurrence.
	self assert: secondInstance receivedOccurrence == secondOccurrence.
	self assert: secondInstance isCompleted.
	self assert: receiveExecution isCompleted.
	self assert: execution waitingMessageSubscriptions isEmpty.
	self assert: (receiveExecution itemValueFor: loopDataOutput) equals: (OrderedCollection withAll: {
		'first result'. 'second result' }).
	^ receiveExecution
]


{ #category : 'examples - multi-instance' }
CPExecutionKernelExamples >> multiInstanceSendTaskDispatchesPerInstance [
	<gtExample>
	| process message sendTask loopDataInput activityInput inputDataItem inputSet outerInputSet specification inputAssociation loop execution sendExecution firstInstance secondInstance firstDispatch secondDispatch |
	process := CPProcess new identifier: 'process'; yourself.
	message := CPMessage new identifier: 'notification'; yourself.
	loopDataInput := CPDataInput new identifier: 'items'; isCollection: true; yourself.
	activityInput := CPDataInput new identifier: 'activityInput'; yourself.
	inputDataItem := CPDataInput new identifier: 'instanceInput'; yourself.
	inputSet := CPInputSet new dataInputRefs: { activityInput }; yourself.
	outerInputSet := CPInputSet new dataInputRefs: { loopDataInput }; yourself.
	specification := CPInputOutputSpecification new
		dataInputs: { loopDataInput. activityInput };
		inputSets: { inputSet. outerInputSet };
		outputSets: { CPOutputSet new };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { inputDataItem };
		targetRef: activityInput;
		yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopDataInputRef: loopDataInput;
		inputDataItem: inputDataItem;
		yourself.
	sendTask := CPSendTask new
		identifier: 'multiSend';
		messageRef: message;
		ioSpecification: specification;
		dataInputAssociations: { inputAssociation };
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: sendTask.
	execution := CPProcessExecution for: process environment: CPExampleExecutionEnvironment new.
	sendExecution := execution createSendTaskExecutionFor: sendTask.
	sendExecution itemValueFor: loopDataInput put: (OrderedCollection withAll: { 'first'. 'second' }).
	execution activateSendTaskExecution: sendExecution.
	firstInstance := sendExecution multiInstanceActivityExecutions first.
	secondInstance := sendExecution multiInstanceActivityExecutions second.
	firstDispatch := firstInstance messageDispatch.
	secondDispatch := secondInstance messageDispatch.
	self assert: firstDispatch activityExecution == firstInstance.
	self assert: secondDispatch activityExecution == secondInstance.
	self assert: firstDispatch message == message.
	self assert: secondDispatch message == message.
	self assert: firstDispatch payload equals: 'first'.
	self assert: secondDispatch payload equals: 'second'.
	self assert: firstDispatch isPending.
	self assert: secondDispatch isPending.
	execution completeMultiInstanceSendTaskExecution: firstInstance.
	self assert: firstDispatch isSent.
	self assert: firstInstance isCompleted.
	self assert: secondInstance isActive.
	self assert: sendExecution isActive.
	execution completeMultiInstanceSendTaskExecution: secondInstance.
	self assert: secondDispatch isSent.
	self assert: secondInstance isCompleted.
	self assert: sendExecution isCompleted.
	^ sendExecution
]


{ #category : 'examples - tasks' }
CPExecutionKernelExamples >> scriptTaskCarriesExecutableDefinition [
	<gtExample>
	| task |
	task := CPScriptTask new
		identifier: 'calculate';
		scriptFormat: 'text/x-smalltalk';
		script: 'invoice recalculateTotal';
		yourself.
	self assert: task scriptFormat equals: 'text/x-smalltalk'.
	self assert: task script equals: 'invoice recalculateTotal'.
	^ task
]

{ #category : 'examples - tasks' }
CPExecutionKernelExamples >> scriptTaskExecutesThroughEnvironment [
	<gtExample>
	| process task environment execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	task := CPScriptTask new
		identifier: 'calculate';
		scriptFormat: 'text/x-smalltalk';
		script: 'invoice recalculateTotal';
		yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution createScriptTaskExecutionFor: task.
	execution activateScriptTaskExecution: taskExecution.
	self assert: environment scriptTaskExecutions size equals: 1.
	self assert: environment scriptTaskExecutions first == taskExecution.
	self assert: taskExecution isCompleted.
	^ taskExecution
]

{ #category : 'examples - tasks' }
CPExecutionKernelExamples >> multiInstanceScriptTaskExecutesPerInstance [
	<gtExample>
	| process task loop cardinality environment execution taskExecution firstInstance secondInstance |
	process := CPProcess new identifier: 'process'; yourself.
	cardinality := CPExpression new identifier: 'cardinality'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: cardinality;
		yourself.
	task := CPScriptTask new
		identifier: 'calculate';
		scriptFormat: 'text/x-smalltalk';
		script: 'item recalculate';
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: cardinality evaluatesTo: 2;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution createScriptTaskExecutionFor: task.
	execution activateScriptTaskExecution: taskExecution.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	secondInstance := taskExecution multiInstanceActivityExecutions second.
	self assert: environment scriptTaskExecutions size equals: 2.
	self assert: environment scriptTaskExecutions first == firstInstance.
	self assert: environment scriptTaskExecutions second == secondInstance.
	self assert: firstInstance isCompleted.
	self assert: secondInstance isCompleted.
	self assert: taskExecution isCompleted.
	^ taskExecution
]

{ #category : 'examples - tasks' }
CPExecutionKernelExamples >> businessRuleTaskExecutesThroughEnvironment [
	<gtExample>
	| process task environment execution taskExecution |
	process := CPProcess new identifier: 'process'; yourself.
	task := CPBusinessRuleTask new identifier: 'decide'; yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution createBusinessRuleTaskExecutionFor: task.
	execution activateBusinessRuleTaskExecution: taskExecution.
	self assert: task implementation equals: '##unspecified'.
	self assert: environment businessRuleTaskExecutions size equals: 1.
	self assert: environment businessRuleTaskExecutions first == taskExecution.
	self assert: taskExecution isCompleted.
	^ taskExecution
]

{ #category : 'examples - tasks' }
CPExecutionKernelExamples >> multiInstanceBusinessRuleTaskExecutesPerInstance [
	<gtExample>
	| process task loop cardinality environment execution taskExecution firstInstance secondInstance |
	process := CPProcess new identifier: 'process'; yourself.
	cardinality := CPExpression new identifier: 'cardinality'; yourself.
	loop := CPMultiInstanceLoopCharacteristics new
		loopCardinality: cardinality;
		yourself.
	task := CPBusinessRuleTask new
		identifier: 'decide';
		loopCharacteristics: loop;
		yourself.
	process addFlowElement: task.
	environment := CPExampleExecutionEnvironment new
		expression: cardinality evaluatesTo: 2;
		yourself.
	execution := CPProcessExecution for: process environment: environment.
	taskExecution := execution createBusinessRuleTaskExecutionFor: task.
	execution activateBusinessRuleTaskExecution: taskExecution.
	firstInstance := taskExecution multiInstanceActivityExecutions first.
	secondInstance := taskExecution multiInstanceActivityExecutions second.
	self assert: environment businessRuleTaskExecutions size equals: 2.
	self assert: environment businessRuleTaskExecutions first == firstInstance.
	self assert: environment businessRuleTaskExecutions second == secondInstance.
	self assert: firstInstance isCompleted.
	self assert: secondInstance isCompleted.
	self assert: taskExecution isCompleted.
	^ taskExecution
]


{ #category : 'examples - tasks' }
CPExecutionKernelExamples >> userTaskWaitsForDistributedWorkCompletion [
    <gtExample>
    | process task environment execution taskExecution workItem |
    process := CPProcess new identifier: 'process'; yourself.
    task := CPUserTask new identifier: 'review'; yourself.
    process addFlowElement: task.
    environment := CPExampleExecutionEnvironment new.
    execution := CPProcessExecution for: process environment: environment.
    taskExecution := execution createUserTaskExecutionFor: task.
    execution activateUserTaskExecution: taskExecution.
    self assert: taskExecution isActive.
    self assert: environment userTaskWorkItems size equals: 1.
    workItem := environment userTaskWorkItems first.
    self assert: workItem activityExecution == taskExecution.
    self assert: workItem userTask == task.
    self assert: workItem isPending.
    execution completeUserTaskExecution: taskExecution.
    self assert: workItem isCompleted.
    self assert: taskExecution isCompleted.
    ^ taskExecution
]

{ #category : 'examples - tasks' }
CPExecutionKernelExamples >> multiInstanceUserTaskDistributesWorkPerInstance [
    <gtExample>
    | process task loop cardinality environment execution taskExecution firstInstance secondInstance firstWorkItem secondWorkItem |
    process := CPProcess new identifier: 'process'; yourself.
    cardinality := CPExpression new identifier: 'cardinality'; yourself.
    loop := CPMultiInstanceLoopCharacteristics new
        loopCardinality: cardinality;
        yourself.
    task := CPUserTask new
        identifier: 'review';
        loopCharacteristics: loop;
        yourself.
    process addFlowElement: task.
    environment := CPExampleExecutionEnvironment new
        expression: cardinality evaluatesTo: 2;
        yourself.
    execution := CPProcessExecution for: process environment: environment.
    taskExecution := execution createUserTaskExecutionFor: task.
    execution activateUserTaskExecution: taskExecution.
    firstInstance := taskExecution multiInstanceActivityExecutions first.
    secondInstance := taskExecution multiInstanceActivityExecutions second.
    self assert: environment userTaskWorkItems size equals: 2.
    firstWorkItem := environment userTaskWorkItems first.
    secondWorkItem := environment userTaskWorkItems second.
    self assert: firstWorkItem activityExecution == firstInstance.
    self assert: secondWorkItem activityExecution == secondInstance.
    self assert: firstWorkItem isPending.
    self assert: secondWorkItem isPending.
    execution completeMultiInstanceUserTaskExecution: firstInstance.
    self assert: firstWorkItem isCompleted.
    self assert: firstInstance isCompleted.
    self assert: secondInstance isActive.
    self assert: taskExecution isActive.
    execution completeMultiInstanceUserTaskExecution: secondInstance.
    self assert: secondWorkItem isCompleted.
    self assert: secondInstance isCompleted.
    self assert: taskExecution isCompleted.
    ^ taskExecution
]


{ #category : 'examples - tasks' }
CPExecutionKernelExamples >> userTaskExposesBPMNInstanceAssignmentAttributes [
    <gtExample>
    | process task environment execution taskExecution workItem duplicateClaim |
    process := CPProcess new identifier: 'process'; yourself.
    task := CPUserTask new identifier: 'review'; yourself.
    process addFlowElement: task.
    environment := CPExampleExecutionEnvironment new.
    execution := CPProcessExecution for: process environment: environment.
    taskExecution := execution createUserTaskExecutionFor: task.
    execution activateUserTaskExecution: taskExecution.
    workItem := taskExecution workItem.
    self assert: taskExecution actualOwner isNil.
    self assert: taskExecution taskPriority isNil.
    taskExecution taskPriority: 40.
    taskExecution claimBy: 'reviewer@example.test'.
    self assert: workItem actualOwner equals: 'reviewer@example.test'.
    self assert: taskExecution actualOwner equals: 'reviewer@example.test'.
    self assert: workItem taskPriority equals: 40.
    self assert: taskExecution taskPriority equals: 40.
    duplicateClaim := false.
    [ taskExecution claimBy: 'other@example.test' ]
        on: Error
        do: [ :error | duplicateClaim := true ].
    self assert: duplicateClaim.
    execution completeUserTaskExecution: taskExecution.
    self assert: taskExecution isCompleted.
    ^ taskExecution
]

{ #category : 'examples - tasks' }
CPExecutionKernelExamples >> multiInstanceUserTaskMaintainsAssignmentPerInstance [
    <gtExample>
    | process task loop cardinality environment execution taskExecution firstInstance secondInstance |
    process := CPProcess new identifier: 'process'; yourself.
    cardinality := CPExpression new identifier: 'cardinality'; yourself.
    loop := CPMultiInstanceLoopCharacteristics new
        loopCardinality: cardinality;
        yourself.
    task := CPUserTask new
        identifier: 'review';
        loopCharacteristics: loop;
        yourself.
    process addFlowElement: task.
    environment := CPExampleExecutionEnvironment new
        expression: cardinality evaluatesTo: 2;
        yourself.
    execution := CPProcessExecution for: process environment: environment.
    taskExecution := execution createUserTaskExecutionFor: task.
    execution activateUserTaskExecution: taskExecution.
    firstInstance := taskExecution multiInstanceActivityExecutions first.
    secondInstance := taskExecution multiInstanceActivityExecutions second.
    firstInstance userTaskPriority: 10.
    secondInstance userTaskPriority: 20.
    firstInstance claimUserTaskBy: 'first@example.test'.
    secondInstance claimUserTaskBy: 'second@example.test'.
    self assert: firstInstance userTaskActualOwner equals: 'first@example.test'.
    self assert: secondInstance userTaskActualOwner equals: 'second@example.test'.
    self assert: firstInstance userTaskPriority equals: 10.
    self assert: secondInstance userTaskPriority equals: 20.
    execution completeMultiInstanceUserTaskExecution: firstInstance.
    self assert: secondInstance isActive.
    execution completeMultiInstanceUserTaskExecution: secondInstance.
    self assert: taskExecution isCompleted.
    ^ taskExecution
]

{ #category : 'examples - tasks' }
CPExecutionKernelExamples >> userTaskPotentialOwnersConstrainClaiming [
    <gtExample>
    | process task assignment potentialOwner environment execution taskExecution workItem rejectedClaim |
    process := CPProcess new identifier: 'process'; yourself.
    assignment := CPResourceAssignmentExpression new
        expression: (CPExpression new identifier: 'reviewers'; yourself);
        yourself.
    potentialOwner := CPPotentialOwner new
        identifier: 'reviewers';
        resourceAssignmentExpression: assignment;
        yourself.
    task := CPUserTask new
        identifier: 'review';
        resources: { potentialOwner };
        yourself.
    process addFlowElement: task.
    environment := CPExampleExecutionEnvironment new
        potentialOwner: potentialOwner resolvesTo: { 'alice@example.test'. 'bob@example.test' };
        yourself.
    execution := CPProcessExecution for: process environment: environment.
    taskExecution := execution createUserTaskExecutionFor: task.
    execution activateUserTaskExecution: taskExecution.
    workItem := taskExecution workItem.
    self assert: workItem potentialOwners equals: (OrderedCollection withAll: { 'alice@example.test'. 'bob@example.test' }).
    rejectedClaim := false.
    [ taskExecution claimBy: 'mallory@example.test' ]
        on: Error
        do: [ :error | rejectedClaim := true ].
    self assert: rejectedClaim.
    self assert: taskExecution actualOwner isNil.
    taskExecution claimBy: 'alice@example.test'.
    self assert: taskExecution actualOwner equals: 'alice@example.test'.
    execution completeUserTaskExecution: taskExecution.
    self assert: taskExecution isCompleted.
    ^ taskExecution
]
