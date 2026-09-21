Class {
	#name : 'CPStartEventInitiationSubscription',
	#superclass : 'CPEventBasedGatewayInitiationSubscription',
	#instVars : [ 'startEvent', 'parallelMultipleInitiation' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPStartEventInitiationSubscription >> startEvent [ ^ startEvent ]

{ #category : 'accessing' }
CPStartEventInitiationSubscription >> startEvent: aStartEvent [ startEvent := aStartEvent ]

{ #category : 'process initiation' }
CPStartEventInitiationSubscription >> instantiateUsingService: aBpmService occurrence: anOccurrence [
	parallelMultipleInitiation ifNotNil: [
		^ parallelMultipleInitiation
			acceptOccurrence: anOccurrence
			forDefinition: self eventDefinition
			usingService: aBpmService ].
	^ aBpmService
		instantiateStartEvent: startEvent
		fromDeployment: self processDeployment
		occurrence: anOccurrence
]


{ #category : 'accessing' }
CPStartEventInitiationSubscription >> parallelMultipleInitiation [ ^ parallelMultipleInitiation ]

{ #category : 'accessing' }
CPStartEventInitiationSubscription >> parallelMultipleInitiation: anObject [ parallelMultipleInitiation := anObject ]
