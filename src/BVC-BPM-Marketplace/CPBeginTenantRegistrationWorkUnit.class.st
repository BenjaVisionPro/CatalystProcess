"I begin the public tenant-registration use case as Runtime work. I carry the actual deployment and registration domain object. I do not weaken CPStartProcessWorkUnit's authenticated-user contract."
Class {
	#name : 'CPBeginTenantRegistrationWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processDeployment',
		'registration'
	],
	#category : 'BVC-BPM-Marketplace',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Marketplace'
}

{ #category : 'service context' }
CPBeginTenantRegistrationWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'instance creation' }
CPBeginTenantRegistrationWorkUnit class >> processDeployment: aProcessDeployment registration: aTenantRegistration [
	^ self new
		processDeployment: aProcessDeployment;
		registration: aTenantRegistration;
		yourself
]

{ #category : 'accessing' }
CPBeginTenantRegistrationWorkUnit >> processDeployment [
	^ processDeployment
]

{ #category : 'accessing' }
CPBeginTenantRegistrationWorkUnit >> processDeployment: aProcessDeployment [
	processDeployment := aProcessDeployment
]

{ #category : 'accessing' }
CPBeginTenantRegistrationWorkUnit >> registration [
	^ registration
]

{ #category : 'accessing' }
CPBeginTenantRegistrationWorkUnit >> registration: aTenantRegistration [
	registration := aTenantRegistration
]

{ #category : 'running' }
CPBeginTenantRegistrationWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	| process registrationData collect initialValues execution taskExecution |
	processDeployment ifNil: [ self error: 'A Process deployment is required to begin tenant registration.' ].
	registration ifNil: [ self error: 'A Tenant registration is required.' ].
	process := processDeployment processDefinition.
	process ifNil: [ self error: 'The Process deployment has no executable BPMN Process definition.' ].
	registrationData := process flowElements
		detect: [ :each | each identifier = #tenantRegistration ]
		ifNone: [ self error: 'The Tenant Registration Process requires tenantRegistration process data.' ].
	collect := process flowElements
		detect: [ :each | each identifier = #collectTenantRegistration ]
		ifNone: [ self error: 'The Tenant Registration Process requires collectTenantRegistration.' ].
	initialValues := IdentityDictionary new
		at: registrationData put: registration;
		yourself.
	execution := aCRWorkUnitExecutionContext service
		instantiateProcessDeployment: processDeployment
		initialItemValues: initialValues.
	taskExecution := execution createUserTaskExecutionFor: collect.
	execution readyActivityExecution: taskExecution.
	execution activateUserTaskExecution: taskExecution.
	^ taskExecution workItem
]
