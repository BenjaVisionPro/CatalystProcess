Class {
	#name : 'CPBPMNActivityAndGatewayExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples',
	#package : 'BVC-BPM-Examples'
}

{ #category : 'examples - activities' }
CPBPMNActivityAndGatewayExamples >> activityExecutionProperties [
	<gtExample>
	| activity alternate defaultFlow targetA targetB |
	activity := CPServiceTask identifier: #performWork.
	targetA := CPEndEvent identifier: #normalEnd.
	targetB := CPEndEvent identifier: #alternateEnd.
	alternate := (CPSequenceFlow identifier: #normalFlow) sourceRef: activity; targetRef: targetA; yourself.
	defaultFlow := (CPSequenceFlow identifier: #defaultFlow) sourceRef: activity; targetRef: targetB; yourself.
	activity
		isForCompensation: true;
		startQuantity: 2;
		completionQuantity: 3;
		default: defaultFlow.
	self assert: activity isForCompensation.
	self assert: activity startQuantity equals: 2.
	self assert: activity completionQuantity equals: 3.
	self assert: (activity isDefaultFlow: defaultFlow).
	self assert: activity hasValidDefaultFlow.
	self assert: (activity isDefaultFlow: alternate) not.
	^ activity
]

{ #category : 'examples - gateways' }
CPBPMNActivityAndGatewayExamples >> divergingGatewayDirection [
	<gtExample>
	| gateway source targetA targetB |
	source := CPTask identifier: #beforeDecision.
	gateway := CPExclusiveGateway identifier: #decision.
	targetA := CPTask identifier: #pathA.
	targetB := CPTask identifier: #pathB.
	(CPSequenceFlow identifier: #intoDecision) sourceRef: source; targetRef: gateway.
	(CPSequenceFlow identifier: #pathAFlow) sourceRef: gateway; targetRef: targetA.
	(CPSequenceFlow identifier: #pathBFlow) sourceRef: gateway; targetRef: targetB.
	gateway beDiverging.
	self assert: gateway gatewayDirection equals: 'Diverging'.
	self assert: gateway hasValidGatewayDirection.
	^ gateway
]

{ #category : 'examples - gateways' }
CPBPMNActivityAndGatewayExamples >> complexGatewayContract [
	<gtExample>
	| gateway target defaultFlow condition |
	gateway := CPComplexGateway identifier: #complexDecision.
	target := CPTask identifier: #continue.
	defaultFlow := (CPSequenceFlow identifier: #otherwise) sourceRef: gateway; targetRef: target; yourself.
	condition := (CPFormalExpression identifier: #activation) body: 'ready'; yourself.
	gateway activationCondition: condition; default: defaultFlow.
	self assert: gateway activationCondition equals: condition.
	self assert: (gateway isDefaultFlow: defaultFlow).
	self assert: gateway hasValidDefaultFlow.
	^ gateway
]

{ #category : 'examples - gateways' }
CPBPMNActivityAndGatewayExamples >> eventBasedGatewayContract [
	<gtExample>
	| gateway |
	gateway := CPEventBasedGateway identifier: #awaitEvent.
	self assert: gateway instantiate not.
	self assert: gateway eventGatewayType equals: 'Exclusive'.
	self assert: gateway hasValidEventGatewayType.
	gateway instantiate: true; beParallel.
	self assert: gateway eventGatewayType equals: 'Parallel'.
	self assert: gateway hasValidEventGatewayType.
	^ gateway
]
