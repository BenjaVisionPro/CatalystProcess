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
	execution := CPProcessExecution for: process.
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
	execution := CPProcessExecution for: process.
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
	execution := CPProcessExecution for: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	gatewayExecution := execution
		executeExclusiveGateway: gateway
		consuming: activation
		conditionEvaluator: [ :expression | expression == firstCondition or: [ expression == secondCondition ] ].
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
	execution := CPProcessExecution for: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	gatewayExecution := execution
		executeExclusiveGateway: gateway
		consuming: activation
		conditionEvaluator: [ :expression | false ].
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
	execution := CPProcessExecution for: process.
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
	startEvent outgoing add: flow.
	task incoming add: flow.
	process := CPProcessExecution for: processDefinition.
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
	task outgoing add: flow.
	endEvent incoming add: flow.
	process := CPProcessExecution for: processDefinition.
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
	execution := CPProcessExecution for: process.
	producer := execution createActivityExecutionFor: before.
	activation := execution activateSequenceFlow: incoming producedBy: producer.
	gatewayExecution := execution
		executeInclusiveGateway: gateway
		conditionEvaluator: [ :expression | expression == firstCondition or: [ expression == secondCondition ] ].
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
	execution := CPProcessExecution for: process.
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
	execution := CPProcessExecution for: process.
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
	execution := CPProcessExecution for: process.
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
	execution := CPProcessExecution for: process.
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
	boundary outgoing add: flow.
	after incoming add: flow.
	execution := CPProcessExecution for: process.
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
	boundary outgoing add: flow.
	after incoming add: flow.
	execution := CPProcessExecution for: process.
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
	boundary outgoing add: flow.
	after incoming add: flow.
	execution := CPProcessExecution for: process.
	activityExecution := execution createActivityExecutionFor: activity.
	activityExecution activate.
	boundaryExecution := execution beginBoundaryEvent: boundary attachedTo: activityExecution.
	occurrence := CPExecutionOccurrence new occurrenceIdentifier: #error1; definition: boundary; yourself.
	execution triggerBoundaryEventExecution: boundaryExecution with: occurrence.
	self assert: activityExecution state class equals: CPActivityFailedState.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.
	^ boundaryExecution
]
