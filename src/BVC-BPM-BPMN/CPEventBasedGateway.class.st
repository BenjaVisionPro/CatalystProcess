Class {
	#name : 'CPEventBasedGateway',
	#superclass : 'CPGateway',
	#instVars : [ 'instantiate', 'eventGatewayType' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPEventBasedGateway >> initialize [
	super initialize.
	instantiate := false.
	eventGatewayType := 'Exclusive'
]

{ #category : 'accessing' }
CPEventBasedGateway >> instantiate [ ^ instantiate ]

{ #category : 'accessing' }
CPEventBasedGateway >> instantiate: aBoolean [ instantiate := aBoolean ]

{ #category : 'accessing' }
CPEventBasedGateway >> eventGatewayType [ ^ eventGatewayType ]

{ #category : 'accessing' }
CPEventBasedGateway >> eventGatewayType: aString [ eventGatewayType := aString ]

{ #category : 'gateway type' }
CPEventBasedGateway >> beExclusive [ eventGatewayType := 'Exclusive' ]

{ #category : 'gateway type' }
CPEventBasedGateway >> beParallel [ eventGatewayType := 'Parallel' ]

{ #category : 'validation' }
CPEventBasedGateway >> hasValidEventGatewayType [
	(#('Exclusive' 'Parallel') includes: eventGatewayType) ifFalse: [ ^ false ].
	(eventGatewayType = 'Parallel' and: [ instantiate not ]) ifTrue: [ ^ false ].
	(instantiate and: [ self incoming notEmpty ]) ifTrue: [ ^ false ].
	^ true
]

{ #category : 'descriptions' }
CPEventBasedGateway >> instantiateDescription [
	<magritteDescription>
	^ MABooleanDescription new accessor: #instantiate; label: 'Instantiate'; priority: 100; group: 'Gateway'; yourself
]

{ #category : 'descriptions' }
CPEventBasedGateway >> eventGatewayTypeDescription [
	<magritteDescription>
	^ MASingleOptionDescription new accessor: #eventGatewayType; label: 'Event gateway type'; options: { 'Exclusive'. 'Parallel' }; priority: 110; group: 'Gateway'; yourself
]

{ #category : 'defaults' }
CPEventBasedGateway class >> defaultIcon [ ^ #eventBasedGateway ]

{ #category : 'gateway type' }
CPEventBasedGateway class >> gatewayTypeLabel [ ^ 'Event-based' ]

{ #category : 'gateway type' }
CPEventBasedGateway class >> gatewayTypeIcon [ ^ #pentagon ]
