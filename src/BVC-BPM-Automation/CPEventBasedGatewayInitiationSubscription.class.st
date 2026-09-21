Class {
	#name : 'CPEventBasedGatewayInitiationSubscription',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'processDeployment', 'gateway', 'sequenceFlow', 'eventDefinition' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> processDeployment [ ^ processDeployment ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> processDeployment: anObject [ processDeployment := anObject ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> gateway [ ^ gateway ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> gateway: anObject [ gateway := anObject ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> sequenceFlow [ ^ sequenceFlow ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> target [ ^ sequenceFlow targetRef ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> eventDefinition [ ^ eventDefinition ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> eventDefinition: anObject [ eventDefinition := anObject ]

{ #category : 'testing' }
CPEventBasedGatewayInitiationSubscription >> isMessageSubscription [ ^ eventDefinition isMessageEventDefinition ]
{ #category : 'testing' }
CPEventBasedGatewayInitiationSubscription >> isSignalSubscription [ ^ eventDefinition isSignalEventDefinition ]
{ #category : 'testing' }
CPEventBasedGatewayInitiationSubscription >> isTimerSubscription [ ^ eventDefinition isTimerEventDefinition ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> message [ ^ eventDefinition messageRef ]
{ #category : 'accessing' }
CPEventBasedGatewayInitiationSubscription >> signal [ ^ eventDefinition signalRef ]

{ #category : 'matching' }
CPEventBasedGatewayInitiationSubscription >> matchesOccurrence: anOccurrence [
	processDeployment acceptsNewProcessExecutions ifFalse: [ ^ false ].
	self isMessageSubscription ifTrue: [ ^ anOccurrence definition == self message ].
	self isSignalSubscription ifTrue: [ ^ anOccurrence definition == self signal ].
	^ false
]
