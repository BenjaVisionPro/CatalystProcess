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
CPEventBasedGatewayExecution >> isWaiting [ ^ subscriptions anySatisfy: [ :each | each isWaiting ] ]
{ #category : 'testing' }
CPEventBasedGatewayExecution >> isResolved [ ^ subscriptions anySatisfy: [ :each | each isTriggered ] ]
{ #category : 'building' }
CPEventBasedGatewayExecution >> subscribeToOutgoingFlow: aSequenceFlow [
	| subscription |
	(self definition outgoing identityIncludes: aSequenceFlow) ifFalse: [ self error: 'The Sequence Flow is not an outgoing alternative of this Event-Based Gateway.' ].
	subscription := CPEventBasedGatewaySubscription new
		sequenceFlow: aSequenceFlow;
		target: aSequenceFlow targetRef;
		yourself.
	subscriptions add: subscription.
	^ subscription
]
{ #category : 'occurrences' }
CPEventBasedGatewayExecution >> acceptOccurrence: anOccurrence for: aSubscription [
	(subscriptions identityIncludes: aSubscription) ifFalse: [ self error: 'The subscription does not belong to this Event-Based Gateway execution.' ].
	self isResolved ifTrue: [ self error: 'This Event-Based Gateway race has already been resolved.' ].
	self scope acceptOccurrence: anOccurrence.
	aSubscription triggerWith: anOccurrence.
	subscriptions do: [ :each |
		(each ~~ aSubscription and: [ each isWaiting ]) ifTrue: [ each withdraw ] ].
	^ aSubscription
]
