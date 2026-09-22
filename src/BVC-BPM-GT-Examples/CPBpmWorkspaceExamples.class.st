"I prove that the GT BPM workspace is a thin presentation over the authenticated application boundary."
Class {
	#name : 'CPBpmWorkspaceExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Examples-Workspace',
	#package : 'BVC-BPM-GT-Examples',
	#tag : 'Workspace'
}

{ #category : 'examples - workspace' }
CPBpmWorkspaceExamples >> workspaceUsesAuthenticatedApplicationBoundary [
	<gtExample>
	| root user service application workspace |
	root := CPSystemRoot new.
	user := CPUser new.
	root addUser: user.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new systemRoot: root; yourself).
	application := CPBpmApplication
		runtime: nil
		bpmService: service
		user: user.
	workspace := CPBpmWorkspace application: application.

	self assert: workspace application == application.
	self assert: application user == user.
	self assert: application startableProcessDeployments isEmpty.
	self assert: application assignedUserTaskWorkItems isEmpty.
	self assert: application claimableUserTaskWorkItems isEmpty.
	^ workspace
]


{ #category : 'examples - workspace' }
CPBpmWorkspaceExamples >> workspaceCompletesUserTaskThroughRuntimeCommand [
	<gtExample>
	| root user service runtime topology host queue worker serviceHandle application workspace workItem envelope |
	root := CPSystemRoot new.
	user := CPUser new.
	root addUser: user.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new systemRoot: root; yourself).
	runtime := CRRuntime new.
	topology := CRDeploymentTopology new.
	host := topology ensureHostNamed: #localhost.
	queue := CRPharoWorkQueue new.
	worker := CRWorkerHandle new
		workerIdentifier: #bpmWorkspaceWorker;
		workQueue: queue;
		lifecycleStatus: CRStatus running;
		yourself.
	serviceHandle := worker
		ensureServiceHandleForIdentifier: #bpm
		serviceClass: CPBpmService.
	serviceHandle lifecycleStatus: CRStatus running.
	host noteWorkerHandle: worker.
	runtime deploymentTopology: topology.
	application := CPBpmApplication
		runtime: runtime
		bpmService: service
		user: user.
	workspace := CPBpmWorkspace application: application.
	workItem := CPUserTaskWorkItem new.

	self assert: (workspace completeUserTaskWorkItem: workItem) == workItem.
	self assert: queue depth equals: 1.
	envelope := queue nextOrNil.
	self assert: envelope workUnit class equals: CPCompleteUserTaskWorkUnit.
	self assert: envelope workUnit workItem == workItem.
	^ workspace
]


{ #category : 'examples - workspace' }
CPBpmWorkspaceExamples >> workspacePresentsUserTaskInteractionThroughFoundation [
	<gtExample>
	| workspace task specification input execution workItem model element |
	workspace := self workspaceUsesAuthenticatedApplicationBoundary.
	model := CPUser new.
	input := CPDataInput new.
	specification := CPInputOutputSpecification new
		dataInputs: { input };
		yourself.
	task := CPUserTask new ioSpecification: specification; yourself.
	execution := CPActivityExecution new definition: task; yourself.
	execution itemValueFor: input put: model.
	workItem := CPUserTaskWorkItem new
		userTask: task;
		activityExecution: execution;
		yourself.

	self assert: (workspace interactionModelForUserTaskWorkItem: workItem) == model.
	element := workspace foundationInteractionForUserTaskWorkItem: workItem.
	self assert: element notNil.
	^ element
]

{ #category : 'examples - workspace' }
CPBpmWorkspaceExamples >> workspaceSubmitsFoundationUserTaskInteractionThroughRuntimeCommand [
	<gtExample>
	| root user service runtime topology host queue worker serviceHandle application workspace task specification input output execution workItem model interaction envelope |
	root := CPSystemRoot new.
	user := CPUser new.
	root addUser: user.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new systemRoot: root; yourself).
	runtime := CRRuntime new.
	topology := CRDeploymentTopology new.
	host := topology ensureHostNamed: #localhost.
	queue := CRPharoWorkQueue new.
	worker := CRWorkerHandle new
		workerIdentifier: #bpmWorkspaceWorker;
		workQueue: queue;
		lifecycleStatus: CRStatus running;
		yourself.
	serviceHandle := worker
		ensureServiceHandleForIdentifier: #bpm
		serviceClass: CPBpmService.
	serviceHandle lifecycleStatus: CRStatus running.
	host noteWorkerHandle: worker.
	runtime deploymentTopology: topology.
	application := CPBpmApplication
		runtime: runtime
		bpmService: service
		user: user.
	workspace := CPBpmWorkspace application: application.
	model := CPUser new label: 'Before'; yourself.
	input := CPDataInput new.
	output := CPDataOutput new.
	specification := CPInputOutputSpecification new
		dataInputs: { input };
		dataOutputs: { output };
		yourself.
	task := CPUserTask new ioSpecification: specification; yourself.
	execution := CPActivityExecution new definition: task; yourself.
	execution itemValueFor: input put: model.
	workItem := CPUserTaskWorkItem new
		userTask: task;
		activityExecution: execution;
		yourself.
	interaction := workspace userTaskInteractionForUserTaskWorkItem: workItem.

	self assert: interaction model == model.
	self assert: interaction workItem == workItem.
	interaction memento write: 'After' using: model labelDescription.
	self assert: model label equals: 'Before'.
	self assert: (interaction submit) == model.
	self assert: model label equals: 'After'.
	self assert: queue depth equals: 1.
	envelope := queue nextOrNil.
	self assert: envelope workUnit class equals: CPCompleteUserTaskWorkUnit.
	self assert: envelope workUnit workItem == workItem.
	self assert: envelope workUnit outputValue == model.
	^ interaction
]

{ #category : 'examples - marketplace workspace' }
CPBpmWorkspaceExamples >> publicTenantRegistrationUsesItsOwnFoundationInteractionBoundary [
	<gtExample>
	| bootstrap root deployment environment configuration service runtime topology host queue worker serviceHandle application workspace registration beginEnvelope beginContext workItem interaction completionEnvelope |
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
		workerIdentifier: #tenantRegistrationWorkspaceWorker;
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
	workspace := CPTenantRegistrationWorkspace application: application.

	registration := workspace beginTenantRegistration.
	self assert: registration class equals: CPTenantRegistration.
	beginEnvelope := queue nextOrNil.
	self assert: beginEnvelope workUnit class equals: CPBeginTenantRegistrationWorkUnit.
	beginContext := CRWorkUnitExecutionContext envelope: beginEnvelope.
	beginContext service: service.
	beginContext bindCapabilities: Dictionary new.
	workItem := beginEnvelope workUnit executeInContext: beginContext.
	interaction := workspace interactionFor: registration.
	self assert: interaction registration == registration.
	self assert: interaction workItem == workItem.
	self assert: interaction element notNil.
	interaction memento write: 'Prospective tenant' using: registration labelDescription.
	self assert: registration label isNil.
	self assert: (interaction submit) == registration.
	self assert: registration label equals: 'Prospective tenant'.
	self assert: queue depth equals: 1.
	completionEnvelope := queue nextOrNil.
	self assert: completionEnvelope workUnit class equals: CPCompleteTenantRegistrationWorkUnit.
	self assert: completionEnvelope workUnit workItem == workItem.
	self assert: completionEnvelope workUnit registration == registration.
	^ interaction
]

{ #category : 'examples - marketplace workspace' }
CPBpmWorkspaceExamples >> publicTenantRegistrationSubmissionContinuesIntoValidation [
	<gtExample>
	| bootstrap root deployment environment configuration service runtime topology host queue worker serviceHandle application workspace registration beginEnvelope beginContext workItem interaction completionEnvelope completionContext execution validate operation implementation validationFlow validationExecution invocation |
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
		workerIdentifier: #tenantRegistrationContinuationWorker;
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
	workspace := CPTenantRegistrationWorkspace application: application.

	registration := workspace beginTenantRegistration.
	beginEnvelope := queue nextOrNil.
	beginContext := CRWorkUnitExecutionContext envelope: beginEnvelope.
	beginContext service: service.
	beginContext bindCapabilities: Dictionary new.
	workItem := beginEnvelope workUnit executeInContext: beginContext.
	execution := root processExecutions first.
	validate := execution definition flowElements
		detect: [ :each | each identifier = #validateRegistration ].
	operation := validate operationRef.
	implementation := Object new.
	environment operation: operation resolvesTo: implementation.

	interaction := workspace interactionFor: registration.
	interaction memento write: 'Prospective tenant' using: registration labelDescription.
	interaction submit.
	self assert: queue depth equals: 1.
	completionEnvelope := queue nextOrNil.
	self assert: completionEnvelope workUnit class equals: CPCompleteTenantRegistrationWorkUnit.
	completionContext := CRWorkUnitExecutionContext envelope: completionEnvelope.
	completionContext service: service.
	completionContext bindCapabilities: Dictionary new.
	completionEnvelope workUnit executeInContext: completionContext.
	self assert: workItem isCompleted.

	validationFlow := execution definition flowElements
		detect: [ :each | each identifier = #registrationToValidation ].
	self assert: (execution availableFlowActivationsOn: validationFlow) size equals: 1.
	validationExecution := execution createServiceTaskExecutionFor: validate.
	execution readyActivityExecution: validationExecution.
	execution activateServiceTaskExecution: validationExecution.
	self assert: validationExecution isActive.
	self assert: validationExecution resolvedImplementation == implementation.
	invocation := validationExecution prepareExternalInvocationIdentifiedBy: #validateTenantRegistrationInvocation.
	self assert: invocation isPending.
	self assert: invocation inputValue == registration.
	^ invocation
]

{ #category : 'examples - marketplace workspace' }
CPBpmWorkspaceExamples >> interactiveTenantRegistrationHarness [
	<gtExample>
	| harness |
	harness := CPTenantRegistrationTestHarness configured.
	self assert: harness root notNil.
	self assert: harness registration isNil.
	^ harness
]
