"I describe the structure of an item used by BPMN item-aware elements.

For Catalyst Process, structureRef is deliberately an ordinary Magritte-described object. BPMN treats the concrete data structure as external to BPMN; Catalyst therefore keeps the application object and its Magritte descriptions authoritative rather than duplicating an information model."
Class {
	#name : 'CPItemDefinition',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'structureRef',
		'itemKind',
		'isCollection'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'instance creation' }
CPItemDefinition class >> forStructure: anObject [
	^ self new
		structureRef: anObject;
		yourself
]

{ #category : 'initialization' }
CPItemDefinition >> initialize [
	super initialize.
	itemKind := 'Information'.
	isCollection := false
]

{ #category : 'accessing' }
CPItemDefinition >> structureRef [
	^ structureRef
]

{ #category : 'accessing' }
CPItemDefinition >> structureRef: anObject [
	structureRef := anObject
]

{ #category : 'accessing' }
CPItemDefinition >> itemKind [
	^ itemKind
]

{ #category : 'accessing' }
CPItemDefinition >> itemKind: aString [
	itemKind := aString
]

{ #category : 'accessing' }
CPItemDefinition >> isCollection [
	^ isCollection
]

{ #category : 'accessing' }
CPItemDefinition >> isCollection: aBoolean [
	isCollection := aBoolean
]

{ #category : 'descriptions' }
CPItemDefinition >> itemKindDescription [
	<magritteDescription>
	^ MASingleOptionDescription new
		accessor: #itemKind;
		label: 'Item kind';
		options: { 'Information'. 'Physical' };
		priority: 100;
		group: 'Data';
		yourself
]

{ #category : 'descriptions' }
CPItemDefinition >> isCollectionDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #isCollection;
		label: 'Collection';
		priority: 110;
		group: 'Data';
		yourself
]

{ #category : 'testing' }
CPItemDefinition >> isProcessDefinition [
	^ false
]

{ #category : 'accessing - presentation' }
CPItemDefinition class >> defaultIcon [
	^ #cube
]

