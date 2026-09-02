Class {
	#name : 'CPValidationResult',
	#superclass : 'CFObject',
	#instVars : [
		'issues'
	],
	#category : 'BVC-BPM-Core',
	#package : 'BVC-BPM-Core'
}

{ #category : 'accessing' }
CPValidationResult >> issues [
	^ issues
]

{ #category : 'accessing' }
CPValidationResult >> issues: anObject [
	issues := anObject
]

{ #category : 'initialization' }
CPValidationResult >> initialize [
	super initialize.
	issues := OrderedCollection new
]

{ #category : 'adding' }
CPValidationResult >> addIssue: anIssue [
	issues add: anIssue.
	^ anIssue
]

{ #category : 'testing' }
CPValidationResult >> hasErrors [
	^ issues anySatisfy: [ :each | each severity = #error ]
]

{ #category : 'testing' }
CPValidationResult >> hasWarnings [
	^ issues anySatisfy: [ :each | each severity = #warning ]
]

{ #category : 'testing' }
CPValidationResult >> isValid [
	^ self hasErrors not
]

{ #category : 'accessing' }
CPValidationResult >> errors [
	^ issues select: [ :each | each severity = #error ]
]

{ #category : 'accessing' }
CPValidationResult >> warnings [
	^ issues select: [ :each | each severity = #warning ]
]

{ #category : 'adding' }
CPValidationResult >> addErrorCode: aCode message: aString subject: anObject [
	^ self addIssue: (CPValidationIssue new
		severity: #error;
		code: aCode;
		message: aString;
		subject: anObject;
		yourself)
]

{ #category : 'adding' }
CPValidationResult >> addWarningCode: aCode message: aString subject: anObject [
	^ self addIssue: (CPValidationIssue new
		severity: #warning;
		code: aCode;
		message: aString;
		subject: anObject;
		yourself)
]

{ #category : 'descriptions' }
CPValidationResult >> issuesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #issues;
		label: 'Issues';
		priority: 10;
		group: 'Relations';
		yourself
]

