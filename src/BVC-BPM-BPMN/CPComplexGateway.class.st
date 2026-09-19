Class {
	#name : 'CPComplexGateway',
	#superclass : 'CPGateway',
	#instVars : [ 'activationCondition', 'default' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPComplexGateway >> activationCondition [ ^ activationCondition ]

{ #category : 'accessing' }
CPComplexGateway >> activationCondition: anExpression [ activationCondition := anExpression ]

{ #category : 'descriptions' }
CPComplexGateway >> activationConditionDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new accessor: #activationCondition; classes: { CPExpression }; label: 'Activation condition'; priority: 100; group: 'Gateway'; yourself
]

{ #category : 'accessing' }
CPComplexGateway >> default [ ^ default ]

{ #category : 'accessing' }
CPComplexGateway >> default: aSequenceFlow [ default := aSequenceFlow ]

{ #category : 'descriptions' }
CPComplexGateway >> defaultDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new accessor: #default; classes: { CPSequenceFlow }; reference: CPSequenceFlow new labelDescription; label: 'Default'; priority: 110; group: 'Relations'; yourself
]

{ #category : 'testing' }
CPComplexGateway >> isDefaultFlow: aSequenceFlow [ ^ default == aSequenceFlow ]

{ #category : 'validation' }
CPComplexGateway >> hasValidDefaultFlow [ ^ default isNil or: [ self outgoing identityIncludes: default ] ]

{ #category : 'defaults' }
CPComplexGateway class >> defaultIcon [ ^ #complexGateway ]

{ #category : 'gateway type' }
CPComplexGateway class >> gatewayTypeLabel [ ^ 'Complex' ]

{ #category : 'gateway type' }
CPComplexGateway class >> gatewayTypeIcon [ ^ #gears ]
