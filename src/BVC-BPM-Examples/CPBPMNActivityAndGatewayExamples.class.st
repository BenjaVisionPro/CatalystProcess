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

{ #category : 'examples - call activities' }
CPBPMNActivityAndGatewayExamples >> callActivityUsesCallableElementContract [
	<gtExample>
	| callable input output operation binding call |
	callable := CPProcess identifier: #reusableProcess.
	input := CPDataInput identifier: #request.
	output := CPDataOutput identifier: #response.
	callable ioSpecification: (CPInputOutputSpecification new
		dataInputs: { input };
		dataOutputs: { output };
		yourself).
	operation := CPOperation identifier: #invoke.
	binding := (CPInputOutputBinding identifier: #invokeBinding)
		inputDataRef: input;
		outputDataRef: output;
		operationRef: operation;
		yourself.
	callable ioBindings: { binding }.
	call := (CPCallActivity identifier: #callReusableProcess)
		calledElement: callable;
		yourself.
	self assert: call calledElement equals: callable.
	self assert: callable ioSpecification dataInputs first equals: input.
	self assert: callable ioBindings first equals: binding.
	^ call
]
