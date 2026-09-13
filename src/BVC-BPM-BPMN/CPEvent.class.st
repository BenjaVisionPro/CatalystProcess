Class {
	#name : 'CPEvent',
	#superclass : 'CPFlowNode',
	#instVars : [ 'properties' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPEvent >> isEvent [
	^ true
]


{ #category : 'message flow' }
CPEvent >> canBeMessageFlowEndpoint [
	^ true
]


{ #category : 'initialization' }
CPEvent >> initialize [
	super initialize.
	properties := OrderedCollection new
]
{ #category : 'accessing' }
CPEvent >> properties [ ^ properties ]
{ #category : 'accessing' }
CPEvent >> properties: aCollection [ properties := aCollection asOrderedCollection ]
{ #category : 'descriptions' }
CPEvent >> propertiesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #properties; classes: { CPProperty }; reference: CPProperty new labelDescription; label: 'Properties'; priority: 140; group: 'Data'; beOrdered; yourself
]
