Class {
	#name : 'CPValidationIssue',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'severity',
		'code',
		'message',
		'subject'
	],
	#category : 'BVC-BPM-Core',
	#package : 'BVC-BPM-Core'
}

{ #category : 'accessing' }
CPValidationIssue >> severity [
	^ severity
]

{ #category : 'accessing' }
CPValidationIssue >> severity: anObject [
	severity := anObject
]

{ #category : 'accessing' }
CPValidationIssue >> code [
	^ code
]

{ #category : 'accessing' }
CPValidationIssue >> code: anObject [
	code := anObject
]

{ #category : 'accessing' }
CPValidationIssue >> message [
	^ message
]

{ #category : 'accessing' }
CPValidationIssue >> message: anObject [
	message := anObject
]

{ #category : 'accessing' }
CPValidationIssue >> subject [
	^ subject
]

{ #category : 'accessing' }
CPValidationIssue >> subject: anObject [
	subject := anObject
]

{ #category : 'descriptions' }
CPValidationIssue >> severityDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #severity;
		label: 'Severity';
		priority: 10;
		group: 'General';
		yourself
]

{ #category : 'descriptions' }
CPValidationIssue >> codeDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #code;
		label: 'Code';
		priority: 20;
		group: 'General';
		yourself
]

{ #category : 'descriptions' }
CPValidationIssue >> messageDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #message;
		label: 'Message';
		priority: 30;
		group: 'General';
		yourself
]

{ #category : 'descriptions' }
CPValidationIssue >> subjectDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #subject;
		label: 'Subject';
		priority: 40;
		group: 'Relations';
		yourself
]

