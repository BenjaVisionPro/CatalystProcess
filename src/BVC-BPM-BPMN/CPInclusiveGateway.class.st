Class {
	#name : 'CPInclusiveGateway',
	#superclass : 'CPGateway',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'defaults' }
CPInclusiveGateway class >> defaultIcon [
	^ #inclusiveGateway
]

{ #category : 'gateway type' }
CPInclusiveGateway class >> gatewayTypeLabel [
	^ 'Inclusive'
]

{ #category : 'gateway type' }
CPInclusiveGateway class >> gatewayTypeIcon [
	^ #circle
]
