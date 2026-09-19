Class {
	#name : 'CPAssignment',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'fromExpression',
		'toExpression'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPAssignment >> fromExpression [
	^ fromExpression
]

{ #category : 'accessing' }
CPAssignment >> fromExpression: anExpression [
	fromExpression := anExpression
]

{ #category : 'accessing' }
CPAssignment >> toExpression [
	^ toExpression
]

{ #category : 'accessing' }
CPAssignment >> toExpression: anExpression [
	toExpression := anExpression
]

{ #category : 'descriptions' }
CPAssignment >> fromExpressionDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #fromExpression;
		classes: { CPExpression };
		reference: CPExpression new identifierDescription;
		label: 'From';
		priority: 100;
		group: 'Assignment';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPAssignment >> toExpressionDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #toExpression;
		classes: { CPExpression };
		reference: CPExpression new identifierDescription;
		label: 'To';
		priority: 110;
		group: 'Assignment';
		beRequired;
		yourself
]
