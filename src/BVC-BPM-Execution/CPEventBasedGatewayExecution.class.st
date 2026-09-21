Class {
	#name : 'CPEventBasedGatewayExecution',
	#superclass : 'CPGatewayExecution',
	#instVars : [ 'subscriptions' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPEventBasedGatewayExecution >> initialize [
	super initialize.
	subscriptions := OrderedCollection new
]
{ #category : 'accessing' }
CPEventBasedGatewayExecution >> subscriptions [ ^ subscriptions ]
{ #category : 'testing' }
CPEventBasedGatewayExecution >> isWaiting [ ^ subscriptions anySatisfy: [ :each | each canReceiveOccurrence ] ]
{ #category : 'testing' }
CPEventBasedGatewayExecution >> isResolved [ ^ subscriptions anySatisfy: [ :each | each isTriggered ] ]
{ #category : 'building' }
CPEventBasedGatewayExecution >> subscriptionsToOutgoingFlow: aSequenceFlow [
	| target definitions created |
	(self definition outgoing identityIncludes: aSequenceFlow) ifFalse: [ self error: 'The Sequence Flow is not an outgoing alternative of this Event-Based Gateway.' ].
	target := aSequenceFlow targetRef.
	target isReceiveTask ifTrue: [
		| subscription |
		target messageRef ifNil: [ self error: 'A Receive Task following an Event-Based Gateway requires a Message.' ].
		subscription := CPEventBasedGatewayReceiveTaskSubscription new
			sequenceFlow: aSequenceFlow;
			target: target;
			gatewayExecution: self;
			yourself.
		subscriptions add: subscription.
		^ { subscription } ].
	(target isEvent and: [ target isIntermediateEvent and: [ target isCatchEvent ] ]) ifFalse: [
		self error: 'An Event-Based Gateway outgoing Sequence Flow must target an Intermediate Catch Event or Receive Task.' ].
	definitions := target eventDefinitions.
	definitions ifEmpty: [ self error: 'An Event-Based Gateway Intermediate Catch Event target requires at least one Event Definition.' ].
	created := OrderedCollection new.
	definitions do: [ :definition |
		| subscription |
		(definition isMessageEventDefinition or: [ definition isSignalEventDefinition or: [ definition isTimerEventDefinition or: [ definition isConditionalEventDefinition ] ] ]) ifFalse: [
			self error: 'An Event-Based Gateway catch Event supports Message, Signal, Timer, Conditional, or Multiple combinations of those triggers.' ].
		subscription := CPEventBasedGatewaySubscription new
			sequenceFlow: aSequenceFlow;
			target: target;
			gatewayExecution: self;
			eventDefinition: definition;
			yourself.
		subscriptions add: subscription.
		created add: subscription ].
	^ created
]

{ #category : 'occurrences' }
CPEventBasedGatewayExecution >> acceptOccurrence: anOccurrence for: aSubscription [
	(subscriptions identityIncludes: aSubscription) ifFalse: [ self error: 'The subscription does not belong to this Event-Based Gateway execution.' ].
	self isResolved ifTrue: [ self error: 'This Event-Based Gateway race has already been resolved.' ].
	self scope acceptOccurrence: anOccurrence.
	aSubscription triggerWith: anOccurrence.
	subscriptions do: [ :each |
		(each ~~ aSubscription and: [ each canReceiveOccurrence ]) ifTrue: [ each withdraw ] ].
	^ aSubscription
]


{ #category : 'occurrences' }
CPEventBasedGatewayExecution >> triggerAcceptedOccurrence: anOccurrence for: aSubscription [
	(subscriptions identityIncludes: aSubscription) ifFalse: [ self error: 'The subscription does not belong to this Event-Based Gateway execution.' ].
	self isResolved ifTrue: [ self error: 'This Event-Based Gateway race has already been resolved.' ].
	aSubscription triggerWith: anOccurrence.
	subscriptions do: [ :each |
		(each ~~ aSubscription and: [ each canReceiveOccurrence ]) ifTrue: [ each withdraw ] ].
	^ aSubscription
]

{ #category : 'occurrences' }
CPEventBasedGatewayExecution >> triggerConditionalSubscription: aSubscription [
	(subscriptions identityIncludes: aSubscription) ifFalse: [ self error: 'The subscription does not belong to this Event-Based Gateway execution.' ].
	self isResolved ifTrue: [ self error: 'This Event-Based Gateway race has already been resolved.' ].
	aSubscription triggerWithoutOccurrence.
	subscriptions do: [ :each |
		(each ~~ aSubscription and: [ each canReceiveOccurrence ]) ifTrue: [ each withdraw ] ].
	^ aSubscription
]
