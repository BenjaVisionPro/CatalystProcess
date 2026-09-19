Class {
	#name : 'CPComplexGateway',
	#superclass : 'CPGateway',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'defaults' }
CPComplexGateway class >> defaultIcon [
	^ #complexGateway
]

{ #category : 'gateway type' }
CPComplexGateway class >> gatewayTypeLabel [
	^ 'Complex'
]

{ #category : 'gateway type' }
CPComplexGateway class >> gatewayTypeIcon [
	^ #gears
]
