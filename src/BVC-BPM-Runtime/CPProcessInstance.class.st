Class {
	#name : 'CPProcessInstance',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'deployment',
		'tenant',
		'state',
		'startedAt',
		'startedBy',
		'completedAt',
		'cancelledAt',
		'variables',
		'tokens',
		'activityInstances',
		'workItems',
		'auditEvents'
	],
	#category : 'BVC-BPM-Runtime',
	#package : 'BVC-BPM-Runtime'
}

{ #category : 'accessing' }
CPProcessInstance >> deployment [
	^ deployment
]

{ #category : 'accessing' }
CPProcessInstance >> deployment: anObject [
	deployment := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> tenant [
	^ tenant
]

{ #category : 'accessing' }
CPProcessInstance >> tenant: anObject [
	tenant := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> state [
	^ state
]

{ #category : 'accessing' }
CPProcessInstance >> state: anObject [
	state := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> startedAt [
	^ startedAt
]

{ #category : 'accessing' }
CPProcessInstance >> startedAt: anObject [
	startedAt := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> startedBy [
	^ startedBy
]

{ #category : 'accessing' }
CPProcessInstance >> startedBy: anObject [
	startedBy := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> completedAt [
	^ completedAt
]

{ #category : 'accessing' }
CPProcessInstance >> completedAt: anObject [
	completedAt := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> cancelledAt [
	^ cancelledAt
]

{ #category : 'accessing' }
CPProcessInstance >> cancelledAt: anObject [
	cancelledAt := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> variables [
	^ variables
]

{ #category : 'accessing' }
CPProcessInstance >> variables: anObject [
	variables := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> tokens [
	^ tokens
]

{ #category : 'accessing' }
CPProcessInstance >> tokens: anObject [
	tokens := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> activityInstances [
	^ activityInstances
]

{ #category : 'accessing' }
CPProcessInstance >> activityInstances: anObject [
	activityInstances := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> workItems [
	^ workItems
]

{ #category : 'accessing' }
CPProcessInstance >> workItems: anObject [
	workItems := anObject
]

{ #category : 'accessing' }
CPProcessInstance >> auditEvents [
	^ auditEvents
]

{ #category : 'accessing' }
CPProcessInstance >> auditEvents: anObject [
	auditEvents := anObject
]

{ #category : 'initialization' }
CPProcessInstance >> initialize [
	super initialize.
	state := #created.
	variables := Dictionary new.
	tokens := OrderedCollection new.
	activityInstances := OrderedCollection new.
	workItems := OrderedCollection new.
	auditEvents := OrderedCollection new
]

{ #category : 'testing' }
CPProcessInstance >> isRunning [
	^ state = #running
]

{ #category : 'testing' }
CPProcessInstance >> isCompleted [
	^ state = #completed
]

{ #category : 'testing' }
CPProcessInstance >> isCancelled [
	^ state = #cancelled
]

{ #category : 'accessing' }
CPProcessInstance >> variableAt: aKey [
	^ variables at: aKey ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CPProcessInstance >> variableAt: aKey put: aValue [
	^ variables at: aKey put: aValue
]

{ #category : 'adding' }
CPProcessInstance >> appendAuditEvent: anAuditEvent [
	auditEvents add: anAuditEvent.
	^ anAuditEvent
]

{ #category : 'accessing' }
CPProcessInstance >> activeWorkItems [
	^ workItems select: [ :each | each isAvailable or: [ each isClaimed ] ]
]

