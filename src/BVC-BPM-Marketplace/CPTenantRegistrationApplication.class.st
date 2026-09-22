"I am the application boundary for the public tenant-registration journey. I expose the use case without requiring a prospective registrant to be a CPUser and without exposing Runtime routing to presentation clients. Commands enter Catalyst Runtime as WorkUnits; co-resident reads return authoritative Process domain objects."
Class {
	#name : 'CPTenantRegistrationApplication',
	#superclass : 'Object',
	#instVars : [
		'runtime',
		'systemRoot',
		'processDeployment'
	],
	#category : 'BVC-BPM-Marketplace',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Marketplace'
}

{ #category : 'instance creation' }
CPTenantRegistrationApplication class >> runtime: aCRRuntime systemRoot: aCPSystemRoot processDeployment: aCPProcessDeployment [
	^ self new
		runtime: aCRRuntime;
		systemRoot: aCPSystemRoot;
		processDeployment: aCPProcessDeployment;
		yourself
]

{ #category : 'registration' }
CPTenantRegistrationApplication >> beginTenantRegistration [
	| registration |
	registration := CPTenantRegistration new.
	self beginTenantRegistration: registration.
	^ registration
]

{ #category : 'registration' }
CPTenantRegistrationApplication >> beginTenantRegistration: aTenantRegistration [
	| workUnit router |
	aTenantRegistration ifNil: [ self error: 'A Tenant registration is required.' ].
	processDeployment ifNil: [ self error: 'A Tenant Lifecycle Process deployment is required.' ].
	processDeployment acceptsNewProcessExecutions ifFalse: [
		self error: 'The Tenant Lifecycle Process deployment does not accept new Process executions.' ].
	runtime ifNil: [ self error: 'Catalyst Runtime is required.' ].
	workUnit := CPBeginTenantRegistrationWorkUnit
		processDeployment: processDeployment
		registration: aTenantRegistration.
	router := CRWorkRouter deploymentTopology: runtime deploymentTopology.
	router enqueue: workUnit.
	^ aTenantRegistration
]

{ #category : 'registration' }
CPTenantRegistrationApplication >> completeTenantRegistration: aTenantRegistration [
	| workItem router |
	workItem := self workItemForTenantRegistration: aTenantRegistration.
	workItem ifNil: [ self error: 'No pending Tenant registration work item exists for the registration.' ].
	workItem isPending ifFalse: [ self error: 'Only a pending Tenant registration work item can be completed.' ].
	runtime ifNil: [ self error: 'Catalyst Runtime is required.' ].
	router := CRWorkRouter deploymentTopology: runtime deploymentTopology.
	router enqueue: (CPCompleteTenantRegistrationWorkUnit
		workItem: workItem
		registration: aTenantRegistration).
	^ aTenantRegistration
]

{ #category : 'registration' }
CPTenantRegistrationApplication >> workItemForTenantRegistration: aTenantRegistration [
	| matches |
	aTenantRegistration ifNil: [ self error: 'A Tenant registration is required.' ].
	systemRoot ifNil: [ self error: 'A Process system root is required.' ].
	matches := systemRoot processExecutions flatCollect: [ :execution |
		execution deployment == processDeployment
			ifFalse: [ #() ]
			ifTrue: [ execution allPendingUserTaskWorkItems select: [ :workItem |
				| task input |
				task := workItem userTask.
				(task identifier = #collectTenantRegistration and: [ task ioSpecification dataInputs notEmpty ])
					ifFalse: [ false ]
					ifTrue: [
						input := task ioSpecification dataInputs first.
						(workItem activityExecution itemValueFor: input) == aTenantRegistration ] ] ] ].
	matches size > 1 ifTrue: [ self error: 'More than one pending work item exists for the Tenant registration.' ].
	^ matches ifEmpty: [ nil ] ifNotEmpty: [ matches first ]
]

{ #category : 'accessing' }
CPTenantRegistrationApplication >> runtime [ ^ runtime ]

{ #category : 'accessing' }
CPTenantRegistrationApplication >> runtime: aCRRuntime [ runtime := aCRRuntime ]

{ #category : 'accessing' }
CPTenantRegistrationApplication >> systemRoot [ ^ systemRoot ]

{ #category : 'accessing' }
CPTenantRegistrationApplication >> systemRoot: aCPSystemRoot [ systemRoot := aCPSystemRoot ]

{ #category : 'accessing' }
CPTenantRegistrationApplication >> processDeployment [ ^ processDeployment ]

{ #category : 'accessing' }
CPTenantRegistrationApplication >> processDeployment: aCPProcessDeployment [ processDeployment := aCPProcessDeployment ]
