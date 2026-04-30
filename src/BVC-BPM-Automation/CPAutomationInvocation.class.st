Class {
	#name : 'CPAutomationInvocation',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'tenant',
		'processInstance',
		'activityInstance',
		'actionReference',
		'state',
		'inputPayload',
		'resultPayload',
		'failure',
		'createdAt',
		'startedAt',
		'completedAt'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'accessing' }
CPAutomationInvocation >> tenant [
	^ tenant
]

{ #category : 'accessing' }
CPAutomationInvocation >> tenant: anObject [
	tenant := anObject
]

{ #category : 'accessing' }
CPAutomationInvocation >> processInstance [
	^ processInstance
]

{ #category : 'accessing' }
CPAutomationInvocation >> processInstance: anObject [
	processInstance := anObject
]

{ #category : 'accessing' }
CPAutomationInvocation >> activityInstance [
	^ activityInstance
]

{ #category : 'accessing' }
CPAutomationInvocation >> activityInstance: anObject [
	activityInstance := anObject
]

{ #category : 'accessing' }
CPAutomationInvocation >> actionReference [
	^ actionReference
]

{ #category : 'accessing' }
CPAutomationInvocation >> actionReference: anObject [
	actionReference := anObject
]

{ #category : 'accessing' }
CPAutomationInvocation >> state [
	^ state
]

{ #category : 'accessing' }
CPAutomationInvocation >> state: anObject [
	state := anObject
]

{ #category : 'accessing' }
CPAutomationInvocation >> inputPayload [
	^ inputPayload
]

{ #category : 'accessing' }
CPAutomationInvocation >> inputPayload: anObject [
	inputPayload := anObject
]

{ #category : 'accessing' }
CPAutomationInvocation >> resultPayload [
	^ resultPayload
]

{ #category : 'accessing' }
CPAutomationInvocation >> resultPayload: anObject [
	resultPayload := anObject
]

{ #category : 'accessing' }
CPAutomationInvocation >> failure [
	^ failure
]

{ #category : 'accessing' }
CPAutomationInvocation >> failure: anObject [
	failure := anObject
]

{ #category : 'accessing' }
CPAutomationInvocation >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
CPAutomationInvocation >> createdAt: anObject [
	createdAt := anObject
]

{ #category : 'accessing' }
CPAutomationInvocation >> startedAt [
	^ startedAt
]

{ #category : 'accessing' }
CPAutomationInvocation >> startedAt: anObject [
	startedAt := anObject
]

{ #category : 'accessing' }
CPAutomationInvocation >> completedAt [
	^ completedAt
]

{ #category : 'accessing' }
CPAutomationInvocation >> completedAt: anObject [
	completedAt := anObject
]

{ #category : 'initialization' }
CPAutomationInvocation >> initialize [
	super initialize.
	state := #pending.
	createdAt := DateAndTime now
]

