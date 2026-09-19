"I represent a BPMN FormalExpression.

My language optionally overrides the containing Definitions expression language. My body is the expression content; evaluation belongs to the execution environment, not to the BPMN model."
Class {
	#name : 'CPFormalExpression',
	#superclass : 'CPExpression',
	#instVars : [
		'language',
		'body',
		'evaluatesToTypeRef'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPFormalExpression >> language [
	^ language
]

{ #category : 'accessing' }
CPFormalExpression >> language: aString [
	language := aString
]

{ #category : 'accessing' }
CPFormalExpression >> body [
	^ body
]

{ #category : 'accessing' }
CPFormalExpression >> body: aString [
	body := aString
]

{ #category : 'accessing' }
CPFormalExpression >> evaluatesToTypeRef [
	^ evaluatesToTypeRef
]

{ #category : 'accessing' }
CPFormalExpression >> evaluatesToTypeRef: anItemDefinition [
	evaluatesToTypeRef := anItemDefinition
]

{ #category : 'descriptions' }
CPFormalExpression >> languageDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #language;
		label: 'Language';
		priority: 100;
		group: 'Expression';
		yourself
]

{ #category : 'descriptions' }
CPFormalExpression >> bodyDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #body;
		label: 'Body';
		priority: 110;
		group: 'Expression';
		yourself
]

{ #category : 'descriptions' }
CPFormalExpression >> evaluatesToTypeRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #evaluatesToTypeRef;
		classes: { CPItemDefinition };
		reference: CPItemDefinition new identifierDescription;
		label: 'Evaluates to type';
		priority: 120;
		group: 'Expression';
		yourself
]
