Class {
	#name : 'CPParallelGateway',
	#superclass : 'CPGateway',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'defaults' }
CPParallelGateway class >> defaultIcon [
	^ #parallelGateway
]

{ #category : 'gateway type' }
CPParallelGateway class >> gatewayTypeLabel [
	^ 'Parallel'
]

{ #category : 'gateway type' }
CPParallelGateway class >> gatewayTypeIcon [
	^ #plus
]
