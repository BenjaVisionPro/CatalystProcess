"I am a process-scoped BPMN Data Object. My item definition identifies the authoritative Magritte-described application structure."
Class {
	#name : 'CPDataObject',
	#superclass : 'CPFlowElement',
	#instVars : [
		'itemSubjectRef',
		'isCollection'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'defaults' }
CPDataObject class >> defaultIcon [
	^ #database
]

{ #category : 'initialization' }
CPDataObject >> initialize [
	super initialize.
	isCollection := false
]

{ #category : 'accessing' }
CPDataObject >> itemSubjectRef [ ^ itemSubjectRef ]
{ #category : 'accessing' }
CPDataObject >> itemSubjectRef: anItemDefinition [ itemSubjectRef := anItemDefinition ]
{ #category : 'accessing' }
CPDataObject >> structureRef [ ^ itemSubjectRef ifNotNil: [ itemSubjectRef structureRef ] ]
{ #category : 'accessing' }
CPDataObject >> isCollection [
	^ itemSubjectRef
		ifNil: [ isCollection ]
		ifNotNil: [ itemSubjectRef isCollection ]
]
{ #category : 'accessing' }
CPDataObject >> isCollection: aBoolean [ isCollection := aBoolean ]

{ #category : 'descriptions' }
CPDataObject >> itemSubjectRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #itemSubjectRef;
		classes: { CPItemDefinition };
		reference: CPItemDefinition new identifierDescription;
		label: 'Item definition';
		priority: 110;
		group: 'Data';
		yourself
]

{ #category : 'descriptions' }
CPDataObject >> isCollectionDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #isCollection;
		label: 'Collection';
		priority: 120;
		group: 'Data';
		yourself
]


{ #category : 'testing' }
CPDataObject >> isDataObject [
	^ true
]
