Class {
	#name : 'CPDataAssociation',
	#superclass : 'CFIdentifiableObject',
	#instVars : [ 'sourceRefs', 'targetRef', 'transformation', 'assignments' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPDataAssociation >> initialize [
	super initialize.
	sourceRefs := OrderedCollection new.
	assignments := OrderedCollection new
]
{ #category : 'accessing' }
CPDataAssociation >> sourceRefs [ ^ sourceRefs ]
{ #category : 'accessing' }
CPDataAssociation >> sourceRefs: aCollection [ sourceRefs := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPDataAssociation >> targetRef [ ^ targetRef ]
{ #category : 'accessing' }
CPDataAssociation >> targetRef: anItemAwareElement [ targetRef := anItemAwareElement ]
{ #category : 'accessing' }
CPDataAssociation >> transformation [ ^ transformation ]
{ #category : 'accessing' }
CPDataAssociation >> transformation: anExpression [ transformation := anExpression ]
{ #category : 'accessing' }
CPDataAssociation >> assignments [ ^ assignments ]
{ #category : 'accessing' }
CPDataAssociation >> assignments: aCollection [ assignments := aCollection asOrderedCollection ]

{ #category : 'accessing' }
CPDataAssociation class >> itemAwareClasses [
	^ { CPDataObject. CPDataObjectReference. CPDataStoreReference. CPProperty. CPDataInput. CPDataOutput }
]

{ #category : 'descriptions' }
CPDataAssociation >> sourceRefsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #sourceRefs;
		classes: self class itemAwareClasses;
		reference: CPDataObject new labelDescription;
		label: 'Sources';
		priority: 100;
		group: 'Relations';
		beOrdered;
		yourself
]
{ #category : 'descriptions' }
CPDataAssociation >> targetRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #targetRef;
		classes: self class itemAwareClasses;
		reference: CPDataObject new labelDescription;
		label: 'Target';
		priority: 110;
		group: 'Relations';
		beRequired;
		yourself
]
{ #category : 'descriptions' }
CPDataAssociation >> assignmentsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #assignments;
		classes: { CPAssignment };
		reference: CPAssignment new identifierDescription;
		label: 'Assignments';
		priority: 120;
		group: 'Data';
		beOrdered;
		yourself
]


{ #category : 'testing' }
CPDataAssociation >> isDataAssociation [
	^ true
]


{ #category : 'testing' }
CPDataAssociation >> isSequenceFlow [
	^ false
]

{ #category : 'testing' }
CPDataAssociation >> isMessageFlow [
	^ false
]
