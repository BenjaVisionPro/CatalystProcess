Class {
	#name : 'CPGatewayTypeSelection',
	#superclass : 'CPFlowNodeTypeSelection',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'type protocol' }
CPGatewayTypeSelection >> typeClasses [
	^ CPGateway gatewayTypes
]

{ #category : 'type protocol' }
CPGatewayTypeSelection >> typeDescriptionLabel [
	^ 'Gateway type'
]

{ #category : 'type protocol' }
CPGatewayTypeSelection >> typeLabelFor: aClass [
	^ aClass gatewayTypeLabel
]

{ #category : 'type protocol' }
CPGatewayTypeSelection >> typeIconFor: aClass [
	^ aClass gatewayTypeIcon
]
