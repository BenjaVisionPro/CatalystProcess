Class {
	#name : 'CPDataObjectReference',
	#superclass : 'CPFlowElement',
	#instVars : [
		'dataObjectRef',
		'dataState'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'defaults' }
CPDataObjectReference class >> defaultIcon [
	^ #database
]

{ #category : 'accessing' }
CPDataObjectReference >> dataObjectRef [ ^ dataObjectRef ]
{ #category : 'accessing' }
CPDataObjectReference >> dataObjectRef: aDataObject [ dataObjectRef := aDataObject ]
{ #category : 'accessing' }
CPDataObjectReference >> label [
	^ dataObjectRef
		ifNil: [ super label ]
		ifNotNil: [ dataObjectRef label ]
]
{ #category : 'accessing' }
CPDataObjectReference >> label: anObject [
	^ dataObjectRef
		ifNil: [ super label: anObject ]
		ifNotNil: [ dataObjectRef label: anObject ]
]
{ #category : 'accessing' }
CPDataObjectReference >> dataState [ ^ dataState ]
{ #category : 'accessing' }
CPDataObjectReference >> dataState: aDataState [ dataState := aDataState ]
{ #category : 'accessing' }
CPDataObjectReference >> itemSubjectRef [ ^ dataObjectRef ifNotNil: [ dataObjectRef itemSubjectRef ] ]
{ #category : 'accessing' }
CPDataObjectReference >> structureRef [ ^ dataObjectRef ifNotNil: [ dataObjectRef structureRef ] ]
{ #category : 'accessing' }
CPDataObjectReference >> isCollection [ ^ dataObjectRef notNil and: [ dataObjectRef isCollection ] ]

{ #category : 'descriptions' }
CPDataObjectReference >> dataObjectRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #dataObjectRef;
		classes: { CPDataObject };
		reference: CPDataObject new labelDescription;
		label: 'Data object';
		priority: 110;
		group: 'Data';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPDataObjectReference >> dataStateDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #dataState;
		classes: { CPDataState };
		reference: CPDataState new labelDescription;
		label: 'State';
		priority: 120;
		group: 'Data';
		yourself
]


{ #category : 'testing' }
CPDataObjectReference >> isDataObjectReference [
	^ true
]

{ #category : 'testing' }
CPDataObjectReference >> isDataReference [
	^ true
]
