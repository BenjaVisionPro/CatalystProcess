Class {
	#name : 'CPEventBasedGatewaySubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'sequenceFlow', 'target', 'state', 'occurrence' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPEventBasedGatewaySubscription >> initialize [
	super initialize.
	state := CPEventBasedGatewaySubscriptionWaitingState new
]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> sequenceFlow [ ^ sequenceFlow ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> sequenceFlow: aSequenceFlow [ sequenceFlow := aSequenceFlow ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> target [ ^ target ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> target: aFlowNode [ target := aFlowNode ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> state [ ^ state ]
{ #category : 'accessing' }
CPEventBasedGatewaySubscription >> occurrence [ ^ occurrence ]
{ #category : 'testing' }
CPEventBasedGatewaySubscription >> isWaiting [ ^ state isWaiting ]
{ #category : 'testing' }
CPEventBasedGatewaySubscription >> isTriggered [ ^ state isTriggered ]
{ #category : 'testing' }
CPEventBasedGatewaySubscription >> isWithdrawn [ ^ state isWithdrawn ]
{ #category : 'transitions' }
CPEventBasedGatewaySubscription >> triggerWith: anOccurrence [
	self isWaiting ifFalse: [ self error: 'Only a waiting Event-Based Gateway subscription can be triggered.' ].
	occurrence := anOccurrence.
	state := CPEventBasedGatewaySubscriptionTriggeredState new.
	^ self
]
{ #category : 'transitions' }
CPEventBasedGatewaySubscription >> withdraw [
	self isWaiting ifFalse: [ self error: 'Only a waiting Event-Based Gateway subscription can be withdrawn.' ].
	state := CPEventBasedGatewaySubscriptionWithdrawnState new.
	^ self
]
