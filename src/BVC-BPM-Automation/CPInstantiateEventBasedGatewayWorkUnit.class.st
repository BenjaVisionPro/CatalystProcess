Class {
	#name : 'CPInstantiateEventBasedGatewayWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'processDeployment', 'gateway', 'sequenceFlow', 'occurrence' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPInstantiateEventBasedGatewayWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPInstantiateEventBasedGatewayWorkUnit class >> processDeployment: aDeployment gateway: aGateway sequenceFlow: aSequenceFlow occurrence: anOccurrence [
	^ self new processDeployment: aDeployment; gateway: aGateway; sequenceFlow: aSequenceFlow; occurrence: anOccurrence; yourself
]

{ #category : 'accessing' }
CPInstantiateEventBasedGatewayWorkUnit >> processDeployment [ ^ processDeployment ]
{ #category : 'accessing' }
CPInstantiateEventBasedGatewayWorkUnit >> processDeployment: anObject [ processDeployment := anObject ]
{ #category : 'accessing' }
CPInstantiateEventBasedGatewayWorkUnit >> gateway [ ^ gateway ]
{ #category : 'accessing' }
CPInstantiateEventBasedGatewayWorkUnit >> gateway: anObject [ gateway := anObject ]
{ #category : 'accessing' }
CPInstantiateEventBasedGatewayWorkUnit >> sequenceFlow [ ^ sequenceFlow ]
{ #category : 'accessing' }
CPInstantiateEventBasedGatewayWorkUnit >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPInstantiateEventBasedGatewayWorkUnit >> occurrence [ ^ occurrence ]
{ #category : 'accessing' }
CPInstantiateEventBasedGatewayWorkUnit >> occurrence: anObject [ occurrence := anObject ]

{ #category : 'running' }
CPInstantiateEventBasedGatewayWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service instantiateEventBasedGatewayWorkUnit: self
]
