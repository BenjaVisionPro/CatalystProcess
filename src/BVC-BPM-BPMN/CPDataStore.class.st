"I am a reusable BPMN Data Store whose contents persist beyond one Process instance."
Class {
	#name : 'CPDataStore',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'itemSubjectRef',
		'capacity',
		'isUnlimited'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPDataStore >> initialize [
	super initialize.
	isUnlimited := false
]

{ #category : 'accessing' }
CPDataStore >> itemSubjectRef [ ^ itemSubjectRef ]
{ #category : 'accessing' }
CPDataStore >> itemSubjectRef: anItemDefinition [ itemSubjectRef := anItemDefinition ]
{ #category : 'accessing' }
CPDataStore >> structureRef [ ^ itemSubjectRef ifNotNil: [ itemSubjectRef structureRef ] ]
{ #category : 'accessing' }
CPDataStore >> capacity [ ^ capacity ]
{ #category : 'accessing' }
CPDataStore >> capacity: anInteger [ capacity := anInteger ]
{ #category : 'accessing' }
CPDataStore >> isUnlimited [ ^ isUnlimited ]
{ #category : 'accessing' }
CPDataStore >> isUnlimited: aBoolean [ isUnlimited := aBoolean ]

{ #category : 'descriptions' }
CPDataStore >> itemSubjectRefDescription [
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
CPDataStore >> capacityDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #capacity;
		label: 'Capacity';
		priority: 120;
		group: 'Data';
		yourself
]

{ #category : 'descriptions' }
CPDataStore >> isUnlimitedDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #isUnlimited;
		label: 'Unlimited';
		priority: 130;
		group: 'Data';
		yourself
]

{ #category : 'testing' }
CPDataStore >> isProcessDefinition [
	^ false
]

{ #category : 'accessing - presentation' }
CPDataStore class >> defaultIcon [
	^ #database
]

