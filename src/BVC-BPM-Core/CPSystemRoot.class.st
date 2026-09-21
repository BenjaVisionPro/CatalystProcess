Class {
	#name : 'CPSystemRoot',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'tenants',
		'users',
		'groups',
		'processDesigns',
		'processDesignLicences',
		'processDeployments',
		'processInstances',
		'processExecutions',
		'workItems',
		'scheduledJobs',
		'auditEvents'
	],
	#category : 'BVC-BPM-Core',
	#package : 'BVC-BPM-Core'
}

{ #category : 'accessing' }
CPSystemRoot >> tenants [
	^ tenants
]

{ #category : 'accessing' }
CPSystemRoot >> tenants: anObject [
	tenants := anObject
]

{ #category : 'accessing' }
CPSystemRoot >> users [
	^ users
]

{ #category : 'accessing' }
CPSystemRoot >> users: anObject [
	users := anObject
]

{ #category : 'accessing' }
CPSystemRoot >> groups [
	^ groups
]

{ #category : 'accessing' }
CPSystemRoot >> groups: anObject [
	groups := anObject
]

{ #category : 'accessing' }
CPSystemRoot >> processDesigns [
	^ processDesigns
]

{ #category : 'accessing' }
CPSystemRoot >> processDesigns: anObject [
	processDesigns := anObject
]

{ #category : 'accessing' }
CPSystemRoot >> processDesignLicences [
	^ processDesignLicences
]

{ #category : 'accessing' }
CPSystemRoot >> processDesignLicences: anObject [
	processDesignLicences := anObject
]

{ #category : 'accessing' }
CPSystemRoot >> processDeployments [
	^ processDeployments
]

{ #category : 'accessing' }
CPSystemRoot >> processDeployments: anObject [
	processDeployments := anObject
]

{ #category : 'accessing' }
CPSystemRoot >> processInstances [
	^ processInstances
]

{ #category : 'accessing' }
CPSystemRoot >> processInstances: anObject [
	processInstances := anObject
]

{ #category : 'accessing' }
CPSystemRoot >> processExecutions [
	^ processExecutions
]

{ #category : 'accessing' }
CPSystemRoot >> processExecutions: anObject [
	processExecutions := anObject
]

{ #category : 'accessing' }
CPSystemRoot >> workItems [
	^ workItems
]

{ #category : 'accessing' }
CPSystemRoot >> workItems: anObject [
	workItems := anObject
]

{ #category : 'accessing' }
CPSystemRoot >> scheduledJobs [
	^ scheduledJobs
]

{ #category : 'accessing' }
CPSystemRoot >> scheduledJobs: anObject [
	scheduledJobs := anObject
]

{ #category : 'accessing' }
CPSystemRoot >> auditEvents [
	^ auditEvents
]

{ #category : 'accessing' }
CPSystemRoot >> auditEvents: anObject [
	auditEvents := anObject
]

{ #category : 'initialization' }
CPSystemRoot >> initialize [
	super initialize.
	tenants := OrderedCollection new.
	users := OrderedCollection new.
	groups := OrderedCollection new.
	processDesigns := OrderedCollection new.
	processDesignLicences := OrderedCollection new.
	processDeployments := OrderedCollection new.
	processInstances := OrderedCollection new.
	processExecutions := OrderedCollection new.
	workItems := OrderedCollection new.
	scheduledJobs := OrderedCollection new.
	auditEvents := OrderedCollection new
]

{ #category : 'adding' }
CPSystemRoot >> addTenant: aTenant [
	tenants add: aTenant.
	^ aTenant
]

{ #category : 'adding' }
CPSystemRoot >> addUser: aUser [
	users add: aUser.
	^ aUser
]

{ #category : 'adding' }
CPSystemRoot >> addGroup: aGroup [
	groups add: aGroup.
	^ aGroup
]

{ #category : 'adding' }
CPSystemRoot >> addProcessDesign: aProcessDesign [
	processDesigns add: aProcessDesign.
	^ aProcessDesign
]

{ #category : 'adding' }
CPSystemRoot >> addProcessDesignLicence: aProcessDesignLicence [
	processDesignLicences add: aProcessDesignLicence.
	^ aProcessDesignLicence
]

{ #category : 'adding' }
CPSystemRoot >> addProcessDeployment: aProcessDeployment [
	processDeployments add: aProcessDeployment.
	^ aProcessDeployment
]

{ #category : 'accessing' }
CPSystemRoot >> processDeploymentForIdentifier: anIdentifier [
	| matches |
	anIdentifier ifNil: [ self error: 'A Process deployment identifier is required.' ].
	matches := processDeployments select: [ :each | each identifier = anIdentifier ].
	matches size > 1 ifTrue: [
		self error: 'More than one Process deployment has the same identifier.' ].
	^ matches ifEmpty: [ nil ] ifNotEmpty: [ matches first ]
]

{ #category : 'adding' }
CPSystemRoot >> addProcessInstance: aProcessInstance [
	processInstances add: aProcessInstance.
	^ aProcessInstance
]

{ #category : 'adding' }
CPSystemRoot >> addProcessExecution: aProcessExecution [
	| identifier |
	aProcessExecution ifNil: [ self error: 'A Process execution is required.' ].
	identifier := aProcessExecution executionIdentifier.
	identifier ifNil: [ self error: 'A Process execution requires an execution identifier.' ].
	(processExecutions anySatisfy: [ :each | each executionIdentifier = identifier ]) ifTrue: [
		self error: 'A Process execution with this identifier is already registered.' ].
	processExecutions add: aProcessExecution.
	^ aProcessExecution
]

{ #category : 'accessing' }
CPSystemRoot >> processExecutionForIdentifier: anIdentifier [
	| matches |
	anIdentifier ifNil: [ self error: 'A Process execution identifier is required.' ].
	matches := processExecutions select: [ :each | each executionIdentifier = anIdentifier ].
	matches size > 1 ifTrue: [
		self error: 'More than one Process execution has the same identifier.' ].
	^ matches ifEmpty: [ nil ] ifNotEmpty: [ matches first ]
]

{ #category : 'adding' }
CPSystemRoot >> addWorkItem: aWorkItem [
	workItems add: aWorkItem.
	^ aWorkItem
]

{ #category : 'adding' }
CPSystemRoot >> appendAuditEvent: anAuditEvent [
	auditEvents add: anAuditEvent.
	^ anAuditEvent
]

{ #category : 'descriptions' }
CPSystemRoot >> tenantsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #tenants;
		label: 'Tenants';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPSystemRoot >> usersDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #users;
		label: 'Users';
		priority: 110;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPSystemRoot >> groupsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #groups;
		label: 'Groups';
		priority: 120;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPSystemRoot >> processDesignsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #processDesigns;
		label: 'Process designs';
		priority: 130;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPSystemRoot >> processDeploymentsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #processDeployments;
		label: 'Process deployments';
		priority: 140;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPSystemRoot >> processInstancesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #processInstances;
		label: 'Process instances';
		priority: 150;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPSystemRoot >> workItemsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #workItems;
		label: 'Work items';
		priority: 160;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPSystemRoot >> auditEventsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #auditEvents;
		label: 'Audit events';
		priority: 170;
		group: 'Relations';
		yourself
]

