Class {
	#name : 'CPDataStoreReference',
	#superclass : 'CPFlowElement',
	#instVars : [
		'dataStoreRef',
		'dataState'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'defaults' }
CPDataStoreReference class >> defaultIcon [
	^ #database
]

{ #category : 'accessing' }
CPDataStoreReference >> dataStoreRef [ ^ dataStoreRef ]
{ #category : 'accessing' }
CPDataStoreReference >> dataStoreRef: aDataStore [ dataStoreRef := aDataStore ]
{ #category : 'accessing' }
CPDataStoreReference >> dataState [ ^ dataState ]
{ #category : 'accessing' }
CPDataStoreReference >> dataState: aDataState [ dataState := aDataState ]
{ #category : 'accessing' }
CPDataStoreReference >> itemSubjectRef [ ^ dataStoreRef ifNotNil: [ dataStoreRef itemSubjectRef ] ]
{ #category : 'accessing' }
CPDataStoreReference >> structureRef [ ^ dataStoreRef ifNotNil: [ dataStoreRef structureRef ] ]

{ #category : 'descriptions' }
CPDataStoreReference >> dataStoreRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #dataStoreRef;
		classes: { CPDataStore };
		reference: CPDataStore new labelDescription;
		label: 'Data store';
		priority: 110;
		group: 'Data';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPDataStoreReference >> dataStateDescription [
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
CPDataStoreReference >> isDataStoreReference [
	^ true
]
