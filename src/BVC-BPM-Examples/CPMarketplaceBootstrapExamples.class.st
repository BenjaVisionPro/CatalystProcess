Class {
	#name : 'CPMarketplaceBootstrapExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples-Marketplace',
	#package : 'BVC-BPM-Examples',
	#tag : 'Marketplace'
}

{ #category : 'examples - marketplace bootstrap' }
CPMarketplaceBootstrapExamples >> adminBootstrapEstablishesPersistentApplicationWorld [
	<gtExample>
	| bootstrap root tenant user membership deployment |
	bootstrap := CPAdminTenantBootstrap configured.
	root := bootstrap systemRoot.
	tenant := bootstrap adminTenant.
	user := bootstrap adminUser.
	membership := bootstrap adminMembership.
	deployment := bootstrap tenantLifecycleDeployment.
	self assert: root tenants asArray equals: { tenant }.
	self assert: root users asArray equals: { user }.
	self assert: membership tenant == tenant.
	self assert: membership user == user.
	self assert: tenant memberships asArray equals: { membership }.
	self assert: user memberships asArray equals: { membership }.
	self assert: root processDeployments asArray equals: { deployment }.
	self assert: tenant processDeployments asArray equals: { deployment }.
	self assert: deployment tenant == tenant.
	self assert: deployment deployedBy == user.
	self assert: deployment processDefinition identifier equals: #provisionTenant.
	self assert: deployment isActive.
	self assert: (deployment canBeStartedBy: user).
	^ bootstrap
]

{ #category : 'examples - marketplace bootstrap' }
CPMarketplaceBootstrapExamples >> adminBootstrapConfiguresRuntimeBpmServiceOverSameSystemRoot [
	<gtExample>
	| bootstrap bpm runtime service |
	bootstrap := CPAdminTenantBootstrap configured.
	bpm := bootstrap bpmServiceConfiguration.
	runtime := bootstrap runtimeConfiguration.
	self assert: bpm identifier equals: #bpm.
	self assert: bpm serviceClass == CPBpmService.
	self assert: bpm systemRoot == bootstrap systemRoot.
	self assert: runtime services asArray equals: { bpm }.
	self assert: runtime deployment serviceDeployments size equals: 1.
	self assert: runtime deployment serviceDeployments first serviceIdentifier equals: #bpm.
	self assert: runtime validate isValid.
	service := CPBpmService new installWithConfiguration: bpm.
	self assert: (service startableProcessDeploymentsFor: bootstrap adminUser) asArray
		equals: { bootstrap tenantLifecycleDeployment }.
	^ runtime
]

{ #category : 'examples - marketplace bootstrap' }
CPMarketplaceBootstrapExamples >> adminTenantLifecycleIsProductionMarketplaceSource [
	<gtExample>
	| bootstrap definitions |
	bootstrap := CPAdminTenantBootstrap configured.
	definitions := bootstrap tenantLifecycleDefinitions.
	self assert: definitions rootElements size equals: 9.
	self assert: definitions diagrams size equals: 6.
	self assert: bootstrap tenantLifecycleDeployment processDefinition identifier equals: #provisionTenant.
	^ definitions
]

{ #category : 'examples - marketplace bootstrap' }
CPMarketplaceBootstrapExamples >> adminTenantRegistrationBeginsWithHumanCollection [
	<gtExample>
	| process registrationData initiated collect flow input output environment execution registration taskExecution |
	process := AdminTenantLifecycle provisionTenant.
	registrationData := process flowElements
		detect: [ :each | each identifier = #tenantRegistration ].
	initiated := process flowElements
		detect: [ :each | each identifier = #tenantRegistrationInitiated ].
	collect := process flowElements
		detect: [ :each | each identifier = #collectTenantRegistration ].
	flow := process flowElements
		detect: [ :each | each identifier = #initiationToRegistration ].
	input := collect ioSpecification dataInputs first.
	output := collect ioSpecification dataOutputs first.

	self assert: registrationData isDataObject.
	self assert: registrationData structureRef class equals: CPTenantRegistration.
	self assert: initiated isStartEvent.
	self assert: collect class equals: CPUserTask.
	self assert: collect dataInputAssociations first sourceRefs first == registrationData.
	self assert: collect dataInputAssociations first targetRef == input.
	self assert: collect dataOutputAssociations first sourceRefs first == output.
	self assert: collect dataOutputAssociations first targetRef == registrationData.

	environment := CPExampleExecutionEnvironment new.
	execution := CPProcessExecution for: process environment: environment.
	registration := CPTenantRegistration new label: 'Prospective tenant'; yourself.
	execution itemValueFor: registrationData put: registration.
	execution start.
	self assert: (execution availableFlowActivationsOn: flow) size equals: 1.

	taskExecution := execution createUserTaskExecutionFor: collect.
	execution readyActivityExecution: taskExecution.
	execution activateUserTaskExecution: taskExecution.
	self assert: taskExecution isActive.
	self assert: taskExecution workItem isPending.
	self assert: taskExecution workItem activityExecution == taskExecution.
	self assert: (taskExecution itemValueFor: input) == registration.
	self assert: environment userTaskWorkItems asArray equals: { taskExecution workItem }.
	^ taskExecution
]

{ #category : 'examples - marketplace bootstrap' }
CPMarketplaceBootstrapExamples >> tenantRegistrationBeginsAsRuntimeWorkWithoutExistingUser [
	<gtExample>
	| bootstrap root deployment registration environment configuration service workUnit context workItem execution input |
	bootstrap := CPAdminTenantBootstrap configured.
	root := bootstrap systemRoot.
	deployment := bootstrap tenantLifecycleDeployment.
	registration := CPTenantRegistration new
		label: 'Prospective tenant';
		yourself.
	environment := CPExampleExecutionEnvironment new.
	configuration := CPBpmServiceConfiguration new
		systemRoot: root;
		executionEnvironment: environment;
		yourself.
	service := CPBpmService new installWithConfiguration: configuration.
	workUnit := CPBeginTenantRegistrationWorkUnit
		processDeployment: deployment
		registration: registration.
	self assert: workUnit class serviceClass == CPBpmService.
	self assert: workUnit processDeployment == deployment.
	self assert: workUnit registration == registration.
	context := CRWorkUnitExecutionContext envelope: workUnit asEnvelope.
	context service: service.
	context bindCapabilities: Dictionary new.
	workItem := workUnit executeInContext: context.
	execution := workItem activityExecution scope processExecution.
	input := workItem userTask ioSpecification dataInputs first.
	self assert: root processExecutions size equals: 1.
	self assert: root processExecutions first == execution.
	self assert: execution deployment == deployment.
	self assert: execution isStarted.
	self assert: workItem isPending.
	self assert: workItem userTask identifier equals: #collectTenantRegistration.
	self assert: (workItem activityExecution itemValueFor: input) == registration.
	self assert: environment userTaskWorkItems asArray equals: { workItem }.
	self assert: execution startedBy isNil.
	^ workItem
]

{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> tenantRegistrationApplicationUsesRuntimeAndReturnsAuthoritativeWork [
	<gtExample>
	| bootstrap root deployment environment configuration service runtime topology host queue worker serviceHandle application registration envelope context workItem |
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
		workerIdentifier: #registrationWorker;
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
	registration := application beginTenantRegistration.
	self assert: registration class equals: CPTenantRegistration.
	self assert: queue depth equals: 1.
	envelope := queue nextOrNil.
	self assert: envelope workUnit class equals: CPBeginTenantRegistrationWorkUnit.
	self assert: envelope workUnit registration == registration.

	context := CRWorkUnitExecutionContext envelope: envelope.
	context service: service.
	context bindCapabilities: Dictionary new.
	workItem := envelope workUnit executeInContext: context.
	self assert: (application workItemForTenantRegistration: registration) == workItem.
	self assert: workItem isPending.
	^ application
]

{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> tenantRegistrationApplicationPresentsPendingInteractionThroughFoundation [
	<gtExample>
	| application execution workItem input registration memento viewModel element |
	application := self tenantRegistrationApplicationUsesRuntimeAndReturnsAuthoritativeWork.
	execution := application systemRoot processExecutions first.
	workItem := execution allPendingUserTaskWorkItems first.
	input := workItem userTask ioSpecification dataInputs first.
	registration := workItem activityExecution itemValueFor: input.

	self assert: (application workItemForTenantRegistration: registration) == workItem.
	memento := CFMaMemento model: registration.
	viewModel := CFMaViewModel forObject: registration memento: memento.
	element := viewModel preparedElementForMemento: memento.

	self assert: memento model == registration.
	self assert: registration label isNil.
	memento write: 'Prospective tenant' using: registration labelDescription.
	self assert: registration label isNil.
	memento commit.
	self assert: registration label equals: 'Prospective tenant'.
	^ element
]

{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> tenantRegistrationApplicationCommitsAndSubmitsPendingInteraction [
	<gtExample>
	| application execution workItem input registration memento runtime topology worker queue envelope |
	application := self tenantRegistrationApplicationUsesRuntimeAndReturnsAuthoritativeWork.
	execution := application systemRoot processExecutions first.
	workItem := execution allPendingUserTaskWorkItems first.
	input := workItem userTask ioSpecification dataInputs first.
	registration := workItem activityExecution itemValueFor: input.

	memento := CFMaMemento model: registration.
	memento write: 'Prospective tenant' using: registration labelDescription.
	memento commit.
	self assert: registration label equals: 'Prospective tenant'.

	runtime := application runtime.
	topology := runtime deploymentTopology.
	worker := topology hosts first workerHandles first.
	queue := worker workQueue.
	self assert: queue depth equals: 0.
	application completeTenantRegistration: registration.
	self assert: queue depth equals: 1.
	envelope := queue nextOrNil.
	self assert: envelope workUnit class equals: CPCompleteTenantRegistrationWorkUnit.
	self assert: envelope workUnit workItem == workItem.
	self assert: workItem isPending.
	^ registration
]



{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> tenantRegistrationSubmissionReachesExecutableValidationOperation [
	<gtExample>
	| application execution workItem input registration memento runtime topology worker queue completionEnvelope context environment validate operation implementation validationFlow validationExecution invocation |
	application := self tenantRegistrationApplicationUsesRuntimeAndReturnsAuthoritativeWork.
	execution := application systemRoot processExecutions first.
	workItem := execution allPendingUserTaskWorkItems first.
	input := workItem userTask ioSpecification dataInputs first.
	registration := workItem activityExecution itemValueFor: input.

	memento := CFMaMemento model: registration.
	memento write: 'Prospective tenant' using: registration labelDescription.
	memento commit.

	validate := execution definition flowElements
		detect: [ :each | each identifier = #validateRegistration ].
	operation := validate operationRef.
	self assert: operation notNil.
	self assert: operation identifier equals: #validateTenantRegistration.
	self assert: validate ioSpecification dataInputs size equals: 1.
	self assert: validate dataInputAssociations first sourceRefs first identifier equals: #tenantRegistration.
	implementation := Object new.
	environment := execution environment.
	environment operation: operation resolvesTo: implementation.

	application completeTenantRegistration: registration.
	runtime := application runtime.
	topology := runtime deploymentTopology.
	worker := topology hosts first workerHandles first.
	queue := worker workQueue.
	self assert: queue depth equals: 1.
	completionEnvelope := queue nextOrNil.
	context := CRWorkUnitExecutionContext envelope: completionEnvelope.
	context service: (CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new
			systemRoot: application systemRoot;
			executionEnvironment: environment;
			yourself)).
	context bindCapabilities: Dictionary new.
	completionEnvelope workUnit executeInContext: context.
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


{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> tenantRegistrationValidationCompletionSelectsAcceptedPath [
	<gtExample>
	| invocation validationExecution execution environment accepted acceptedFlow rejectedFlow condition root service workUnit context decisionFlow decisionActivation gatewayExecution |
	invocation := self tenantRegistrationSubmissionReachesExecutableValidationOperation.
	validationExecution := invocation activityExecution.
	execution := validationExecution scope processExecution.
	environment := execution environment.
	accepted := execution definition flowElements
		detect: [ :each | each identifier = #registrationAccepted ].
	acceptedFlow := execution definition flowElements
		detect: [ :each | each identifier = #acceptedToTenant ].
	rejectedFlow := execution definition flowElements
		detect: [ :each | each identifier = #rejectedRegistration ].
	condition := acceptedFlow conditionExpression.
	self assert: condition notNil.
	self assert: condition identifier equals: #tenantRegistrationIsAccepted.
	self assert: accepted default == rejectedFlow.
	environment expression: condition evaluatesTo: true.

	root := CPSystemRoot new.
	root addProcessExecution: execution.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new
			systemRoot: root;
			executionEnvironment: environment;
			yourself).
	workUnit := CPCompleteServiceInvocationWorkUnit
		invocation: invocation
		occurrenceIdentifier: #tenantRegistrationValidated
		payload: Dictionary new.
	context := CRWorkUnitExecutionContext envelope: workUnit asEnvelope.
	context service: service.
	context bindCapabilities: Dictionary new.
	workUnit executeInContext: context.
	self assert: invocation isCompleted.
	self assert: validationExecution isCompleted.

	decisionFlow := execution definition flowElements
		detect: [ :each | each identifier = #validationToDecision ].
	self assert: (execution availableFlowActivationsOn: decisionFlow) size equals: 1.
	decisionActivation := (execution availableFlowActivationsOn: decisionFlow) first.
	gatewayExecution := execution executeExclusiveGateway: accepted consuming: decisionActivation.
	self assert: gatewayExecution notNil.
	self assert: (execution availableFlowActivationsOn: acceptedFlow) size equals: 1.
	self assert: (execution availableFlowActivationsOn: rejectedFlow) isEmpty.
	^ gatewayExecution
]


{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> acceptedTenantRegistrationReachesExecutableTenantEstablishment [
	<gtExample>
	| gatewayExecution execution acceptedFlow acceptedActivation establishTenant operation registration input implementation environment tenantExecution invocation |
	gatewayExecution := self tenantRegistrationValidationCompletionSelectsAcceptedPath.
	execution := gatewayExecution scope processExecution.
	acceptedFlow := execution definition flowElements
		detect: [ :each | each identifier = #acceptedToTenant ].
	establishTenant := execution definition flowElements
		detect: [ :each | each identifier = #establishTenant ].
	operation := establishTenant operationRef.
	self assert: operation notNil.
	self assert: operation identifier equals: #establishTenantFromRegistration.
	self assert: establishTenant ioSpecification dataInputs size equals: 1.
	input := establishTenant ioSpecification dataInputs first.
	self assert: establishTenant dataInputAssociations first sourceRefs first identifier equals: #tenantRegistration.
	registration := execution itemValueFor:
		(execution definition flowElements detect: [ :each | each identifier = #tenantRegistration ]).
	implementation := Object new.
	environment := execution environment.
	environment operation: operation resolvesTo: implementation.
	self assert: gatewayExecution producedFlowActivations size equals: 1.
	acceptedActivation := gatewayExecution producedFlowActivations first.
	self assert: acceptedActivation definition == acceptedFlow.
	self assert: acceptedActivation isAvailable.
	tenantExecution := execution createServiceTaskExecutionFor: establishTenant.
	execution readyActivityExecution: tenantExecution.
	self assert: (tenantExecution consumedFlowActivations identityIncludes: acceptedActivation).
	execution activateServiceTaskExecution: tenantExecution.
	self assert: tenantExecution isActive.
	self assert: tenantExecution resolvedImplementation == implementation.
	self assert: (tenantExecution itemValueFor: input) == registration.
	invocation := tenantExecution prepareExternalInvocationIdentifiedBy: #establishTenantInvocation.
	self assert: invocation isPending.
	self assert: invocation inputValue == registration.
	^ invocation
]
