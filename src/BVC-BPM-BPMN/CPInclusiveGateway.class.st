Class {
	#name : 'CPInclusiveGateway',
	#superclass : 'CPGateway',
	#instVars : [ 'default' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}


{ #category : 'accessing' }
CPInclusiveGateway >> default [
	^ default
]

{ #category : 'accessing' }
CPInclusiveGateway >> default: aSequenceFlow [
	default := aSequenceFlow
]

{ #category : 'descriptions' }
CPInclusiveGateway >> defaultDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #default;
		classes: { CPSequenceFlow };
		reference: CPSequenceFlow new labelDescription;
		label: 'Default';
		priority: 100;
		group: 'Relations';
		yourself
]

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

{ #category : 'testing' }
CPInclusiveGateway >> isDefaultFlow: aSequenceFlow [
	^ default == aSequenceFlow
]

{ #category : 'validation' }
CPInclusiveGateway >> hasValidDefaultFlow [
	^ default isNil or: [ self outgoing identityIncludes: default ]
]
