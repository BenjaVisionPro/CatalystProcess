Class {
	#name : 'CPAuditEvent',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'timestamp',
		'tenant',
		'processInstance',
		'eventType',
		'subject',
		'actor',
		'payload'
	],
	#category : 'BVC-BPM-Runtime',
	#package : 'BVC-BPM-Runtime'
}

{ #category : 'accessing' }
CPAuditEvent >> timestamp [
	^ timestamp
]

{ #category : 'accessing' }
CPAuditEvent >> timestamp: anObject [
	timestamp := anObject
]

{ #category : 'accessing' }
CPAuditEvent >> tenant [
	^ tenant
]

{ #category : 'accessing' }
CPAuditEvent >> tenant: anObject [
	tenant := anObject
]

{ #category : 'accessing' }
CPAuditEvent >> processInstance [
	^ processInstance
]

{ #category : 'accessing' }
CPAuditEvent >> processInstance: anObject [
	processInstance := anObject
]

{ #category : 'accessing' }
CPAuditEvent >> eventType [
	^ eventType
]

{ #category : 'accessing' }
CPAuditEvent >> eventType: anObject [
	eventType := anObject
]

{ #category : 'accessing' }
CPAuditEvent >> subject [
	^ subject
]

{ #category : 'accessing' }
CPAuditEvent >> subject: anObject [
	subject := anObject
]

{ #category : 'accessing' }
CPAuditEvent >> actor [
	^ actor
]

{ #category : 'accessing' }
CPAuditEvent >> actor: anObject [
	actor := anObject
]

{ #category : 'accessing' }
CPAuditEvent >> payload [
	^ payload
]

{ #category : 'accessing' }
CPAuditEvent >> payload: anObject [
	payload := anObject
]

{ #category : 'initialization' }
CPAuditEvent >> initialize [
	super initialize.
	timestamp := DateAndTime now.
	payload := Dictionary new
]

