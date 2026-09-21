Class {
	#name : 'CPStartEventInitiationSubscription',
	#superclass : 'CPEventBasedGatewayInitiationSubscription',
	#instVars : [ 'startEvent' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPStartEventInitiationSubscription >> startEvent [ ^ startEvent ]

{ #category : 'accessing' }
CPStartEventInitiationSubscription >> startEvent: aStartEvent [ startEvent := aStartEvent ]

{ #category : 'process initiation' }
CPStartEventInitiationSubscription >> instantiateUsingService: aBpmService occurrence: anOccurrence [
	^ aBpmService
		instantiateStartEvent: startEvent
		fromDeployment: self processDeployment
		occurrence: anOccurrence
]
