Class {
	#name : 'CPServiceTaskExecution',
	#superclass : 'CPActivityExecution',
	#instVars : [
		'resolvedImplementation',
		'externalInvocation'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPServiceTaskExecution >> resolvedImplementation [ ^ resolvedImplementation ]

{ #category : 'accessing' }
CPServiceTaskExecution >> resolvedImplementation: anObject [
	resolvedImplementation ifNotNil: [ self error: 'A Service Task implementation can be resolved only once for an Activity execution.' ].
	anObject ifNil: [ self error: 'A Service Task requires a resolved Operation implementation.' ].
	resolvedImplementation := anObject
]


{ #category : 'accessing' }
CPServiceTaskExecution >> externalInvocation [ ^ externalInvocation ]

{ #category : 'external work' }
CPServiceTaskExecution >> prepareExternalInvocationIdentifiedBy: anIdentifier [
	self isActive ifFalse: [ self error: 'Only an Active Service Task can prepare external work.' ].
	resolvedImplementation ifNil: [ self error: 'A Service Task requires a resolved implementation before preparing external work.' ].
	externalInvocation ifNotNil: [ self error: 'A Service Task execution can prepare external work only once.' ].
	externalInvocation := CPExternalInvocation new
		invocationIdentifier: anIdentifier;
		activityExecution: self;
		implementation: resolvedImplementation;
		yourself.
	self populateExternalInvocationInput.
	^ externalInvocation
]

{ #category : 'external work' }
CPServiceTaskExecution >> populateExternalInvocationInput [
	| inputs input |
	definition ioSpecification ifNil: [ ^ self ].
	inputs := definition ioSpecification dataInputs.
	inputs ifEmpty: [ ^ self ].
	inputs size = 1 ifFalse: [
		self error: 'A Service Task Operation input requires exactly one Data Input.' ].
	input := inputs first.
	(self hasItemValueFor: input) ifFalse: [
		self error: 'The Service Task Data Input is unavailable for external invocation.' ].
	externalInvocation inputValue: (self itemValueFor: input).
	^ self
]


{ #category : 'standard loop' }
CPServiceTaskExecution >> standardLoopIterationDidBegin: anIteration [
	super standardLoopIterationDidBegin: anIteration.
	^ anIteration
]
