"I am a deliberately small, manually operable GT harness for the public Tenant Registration slice. I assemble the same Runtime, Process, Marketplace application and Foundation interaction used by the executable examples, while keeping the harness itself out of the production application boundary."
Class {
	#name : 'CPTenantRegistrationTestHarness',
	#superclass : 'Object',
	#instVars : [
		'root',
		'service',
		'runtime',
		'queue',
		'application',
		'workspace',
		'registration',
		'workItem',
		'interaction'
	],
	#category : 'BVC-BPM-GT-Examples-Workspace',
	#package : 'BVC-BPM-GT-Examples',
	#tag : 'Workspace'
}

{ #category : 'instance creation' }
CPTenantRegistrationTestHarness class >> configured [
	^ self new configure; yourself
]

{ #category : 'initialization' }
CPTenantRegistrationTestHarness >> configure [
	| bootstrap deployment environment configuration topology host worker serviceHandle |
	bootstrap := CPAdminTenantBootstrap configured.
	root := bootstrap systemRoot.
	deployment := bootstrap tenantLifecycleDeployment.
	environment := CPExampleExecutionEnvironment new.
	configuration := CPBpmServiceConfiguration new
		systemRoot: root;
		executionEnvironment: environment;
		yourself.
	service := CPBpmService new installWithConfiguration: configuration.
	runtime := CRRuntime new.
	topology := CRDeploymentTopology new.
	host := topology ensureHostNamed: #localhost.
	queue := CRPharoWorkQueue new.
	worker := CRWorkerHandle new
		workerIdentifier: #tenantRegistrationInteractiveWorker;
		workQueue: queue;
		lifecycleStatus: CRStatus running;
		yourself.
	serviceHandle := worker
		ensureServiceHandleForIdentifier: #bpm
		serviceClass: CPBpmService.
	serviceHandle lifecycleStatus: CRStatus running.
	host noteWorkerHandle: worker.
	runtime deploymentTopology: topology.
	application := CPTenantRegistrationApplication
		runtime: runtime
		systemRoot: root
		processDeployment: deployment.
	workspace := CPTenantRegistrationWorkspace application: application
]

{ #category : 'accessing' }
CPTenantRegistrationTestHarness >> root [ ^ root ]

{ #category : 'accessing' }
CPTenantRegistrationTestHarness >> registration [ ^ registration ]

{ #category : 'accessing' }
CPTenantRegistrationTestHarness >> workItem [ ^ workItem ]

{ #category : 'accessing' }
CPTenantRegistrationTestHarness >> interaction [ ^ interaction ]

{ #category : 'testing' }
CPTenantRegistrationTestHarness >> hasBegun [ ^ registration notNil ]

{ #category : 'testing' }
CPTenantRegistrationTestHarness >> hasSubmitted [
	^ workItem notNil and: [ workItem isCompleted ]
]

{ #category : 'commands' }
CPTenantRegistrationTestHarness >> beginRegistration [
	| envelope context |
	registration ifNotNil: [ ^ interaction ].
	registration := workspace beginTenantRegistration.
	envelope := queue nextOrNil.
	envelope ifNil: [ self error: 'Beginning Tenant registration did not enqueue Runtime work.' ].
	context := CRWorkUnitExecutionContext envelope: envelope.
	context service: service.
	context bindCapabilities: Dictionary new.
	workItem := envelope workUnit executeInContext: context.
	interaction := workspace interactionFor: registration.
	^ interaction
]

{ #category : 'commands' }
CPTenantRegistrationTestHarness >> submitRegistration [
	| envelope context |
	interaction ifNil: [ self error: 'Begin the Tenant registration before submitting it.' ].
	self hasSubmitted ifTrue: [ ^ registration ].
	interaction submit.
	envelope := queue nextOrNil.
	envelope ifNil: [ self error: 'Submitting Tenant registration did not enqueue Runtime work.' ].
	context := CRWorkUnitExecutionContext envelope: envelope.
	context service: service.
	context bindCapabilities: Dictionary new.
	envelope workUnit executeInContext: context.
	^ registration
]


{ #category : 'accessing' }
CPTenantRegistrationTestHarness >> registrationStatus [
	interaction ifNil: [ ^ 'Not started' ].
	self hasSubmitted ifTrue: [ ^ 'Submitted' ].
	^ 'Pending submission'
]

{ #category : 'gt - views' }
CPTenantRegistrationTestHarness >> gtStatusFor: aView [
	<gtView>
	^ aView text
		title: 'Status';
		priority: 5;
		text: [ self registrationStatus ]
]

{ #category : 'gt - views' }
CPTenantRegistrationTestHarness >> gtRegistrationFor: aView [
	<gtView>
	^ aView explicit
		title: 'Registration';
		priority: 10;
		stencil: [ self beginRegistration element ]
]

{ #category : 'gt - views' }
CPTenantRegistrationTestHarness >> gtProcessExecutionsFor: aView [
	<gtView>
	^ aView list
		title: 'Process Executions';
		priority: 20;
		items: [ root processExecutions ]
]

{ #category : 'gt - actions' }
CPTenantRegistrationTestHarness >> gtSubmitRegistrationFor: anAction [
	<gtAction>
	^ anAction button
		label: 'Submit registration';
		tooltip: 'Commit the Foundation interaction and execute its Runtime completion command';
		action: [ :aButton |
			self submitRegistration.
			aButton phlow fireUpdateWish ]
]
