Class {
	#name : 'CPEventBasedGatewayReceiveTaskSubscription',
	#superclass : 'CPEventBasedGatewaySubscription',
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'event type' }
CPEventBasedGatewayReceiveTaskSubscription >> isMessageSubscription [ ^ true ]

{ #category : 'event type' }
CPEventBasedGatewayReceiveTaskSubscription >> isSignalSubscription [ ^ false ]

{ #category : 'event type' }
CPEventBasedGatewayReceiveTaskSubscription >> isTimerSubscription [ ^ false ]

{ #category : 'event type' }
CPEventBasedGatewayReceiveTaskSubscription >> isConditionalSubscription [ ^ false ]

{ #category : 'event type' }
CPEventBasedGatewayReceiveTaskSubscription >> message [ ^ self target messageRef ]

{ #category : 'continuation' }
CPEventBasedGatewayReceiveTaskSubscription >> continueWithOccurrence: anOccurrence inScope: anExecutionScope [
	^ anExecutionScope
		completeEventBasedGatewayReceiveTask: self target
		withAcceptedOccurrence: anOccurrence
]

{ #category : 'continuation' }
CPEventBasedGatewayReceiveTaskSubscription >> continueConditionalInScope: anExecutionScope [
	self error: 'A Receive Task gateway alternative cannot be continued by a Conditional trigger.'
]
