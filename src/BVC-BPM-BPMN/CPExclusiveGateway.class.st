Class {
	#name : 'CPExclusiveGateway',
	#superclass : 'CPGateway',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'defaults' }
CPExclusiveGateway class >> defaultIcon [
	^ #exclusiveGateway
]

{ #category : 'gateway type' }
CPExclusiveGateway class >> gatewayTypeLabel [
	^ 'Exclusive'
]

{ #category : 'gateway type' }
CPExclusiveGateway class >> gatewayTypeIcon [
	^ #xmark
]
