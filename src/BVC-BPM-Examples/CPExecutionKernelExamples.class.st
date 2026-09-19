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
