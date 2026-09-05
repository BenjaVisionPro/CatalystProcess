Class {
	#name : 'CPEventBasedGateway',
	#superclass : 'CPGateway',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'defaults' }
CPEventBasedGateway class >> defaultIcon [
	^ #eventBasedGateway
]

{ #category : 'gateway type' }
CPEventBasedGateway class >> gatewayTypeLabel [
	^ 'Event-based'
]

{ #category : 'gateway type' }
CPEventBasedGateway class >> gatewayTypeIcon [
	^ #pentagon
]
