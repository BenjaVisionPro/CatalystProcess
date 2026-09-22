Class {
	#name : 'CPGatewayExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'scope',
		'consumedFlowActivations',
		'producedFlowActivations'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPGatewayExecution >> initialize [
	super initialize.
	consumedFlowActivations := OrderedCollection new.
	producedFlowActivations := OrderedCollection new
]

{ #category : 'accessing' }
CPGatewayExecution >> definition [ ^ definition ]
{ #category : 'accessing' }
CPGatewayExecution >> definition: aGateway [ definition := aGateway ]
{ #category : 'accessing' }
CPGatewayExecution >> scope [ ^ scope ]
{ #category : 'accessing' }
CPGatewayExecution >> scope: anExecutionScope [ scope := anExecutionScope ]
{ #category : 'accessing' }
CPGatewayExecution >> consumedFlowActivations [ ^ consumedFlowActivations ]
{ #category : 'accessing' }
CPGatewayExecution >> producedFlowActivations [ ^ producedFlowActivations ]


{ #category : 'gateways - event based' }
CPGatewayExecution >> eventBasedSubscriptions [
	^ #()
]

{ #category : 'control flow' }
CPGatewayExecution >> consumeFlowActivation: anActivation [
	anActivation consumeBy: self.
	consumedFlowActivations add: anActivation.
	^ anActivation
]

{ #category : 'control flow' }
CPGatewayExecution >> recordProducedFlowActivation: anActivation [
	producedFlowActivations add: anActivation.
	^ anActivation
]
