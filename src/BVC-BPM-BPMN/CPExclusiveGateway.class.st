Class {
	#name : 'CPExclusiveGateway',
	#superclass : 'CPGateway',
	#instVars : [ 'default' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}


{ #category : 'accessing' }
CPExclusiveGateway >> default [
	^ default
]

{ #category : 'accessing' }
CPExclusiveGateway >> default: aSequenceFlow [
	default := aSequenceFlow
]

{ #category : 'descriptions' }
CPExclusiveGateway >> defaultDescription [
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
