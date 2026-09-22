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
	self assert: (definitions rootElements anySatisfy: [ :each |
		each identifier = #tenantRegistrationOperations ]).
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

{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> tenantEstablishmentPublishesEstablishedTenantAsProcessData [
	<gtExample>
	| invocation tenantExecution execution establishTenant tenantData tenantOutput tenantToAdministrator tenant root service workUnit context |
	invocation := self acceptedTenantRegistrationReachesExecutableTenantEstablishment.
	tenantExecution := invocation activityExecution.
	execution := tenantExecution scope processExecution.
	establishTenant := tenantExecution definition.
	tenantData := execution definition flowElements
		detect: [ :each | each identifier = #establishedTenant ].
	tenantOutput := establishTenant ioSpecification dataOutputs first.
	self assert: tenantOutput identifier equals: #establishedTenantOutput.
	self assert: establishTenant dataOutputAssociations size equals: 1.
	self assert: establishTenant dataOutputAssociations first sourceRefs first == tenantOutput.
	self assert: establishTenant dataOutputAssociations first targetRef == tenantData.
	tenant := CPTenant new
		label: 'Prospective tenant';
		yourself.
	root := CPSystemRoot new.
	root addProcessExecution: execution.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new
			systemRoot: root;
			executionEnvironment: execution environment;
			yourself).
	workUnit := CPCompleteServiceInvocationWorkUnit
		invocation: invocation
		occurrenceIdentifier: #tenantEstablished
		payload: tenant.
	context := CRWorkUnitExecutionContext envelope: workUnit asEnvelope.
	context service: service.
	context bindCapabilities: Dictionary new.
	workUnit executeInContext: context.
	self assert: invocation isCompleted.
	self assert: tenantExecution isCompleted.
	self assert: (tenantExecution itemValueFor: tenantOutput) == tenant.
	self assert: (execution itemValueFor: tenantData) == tenant.
	tenantToAdministrator := execution definition flowElements
		detect: [ :each | each identifier = #tenantToAdministrator ].
	self assert: (execution availableFlowActivationsOn: tenantToAdministrator) size equals: 1.
	^ tenantExecution
]

{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> tenantAdministratorEstablishmentHasExplicitOperationBoundary [
	<gtExample>
	| definitions process establishAdministrator operation input output association administratorData |
	definitions := CPDefinitionsSourceMaterializer materialize: AdminTenantLifecycle.
	process := definitions rootElements
		detect: [ :each | each identifier = #provisionTenant ].
	establishAdministrator := process flowElements
		detect: [ :each | each identifier = #establishTenantAdministrator ].
	operation := establishAdministrator operationRef.
	self assert: operation notNil.
	self assert: operation identifier equals: #establishTenantAdministratorFromRegistration.
	self assert: establishAdministrator ioSpecification dataInputs size equals: 1.
	self assert: establishAdministrator ioSpecification dataOutputs size equals: 1.
	input := establishAdministrator ioSpecification dataInputs first.
	output := establishAdministrator ioSpecification dataOutputs first.
	self assert: input identifier equals: #tenantAdministratorEstablishment.
	self assert: output identifier equals: #establishedTenantAdministratorOutput.
	association := establishAdministrator dataInputAssociations first.
	self assert: association sourceRefs size equals: 2.
	self assert: association sourceRefs first identifier equals: #establishedTenant.
	self assert: association sourceRefs second identifier equals: #tenantRegistration.
	self assert: association transformation identifier equals: #prepareTenantAdministratorEstablishment.
	administratorData := process flowElements
		detect: [ :each | each identifier = #establishedTenantAdministrator ].
	self assert: establishAdministrator dataOutputAssociations first sourceRefs first == output.
	self assert: establishAdministrator dataOutputAssociations first targetRef == administratorData.
	^ establishAdministrator
]

{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> establishedTenantReachesExecutableAdministratorEstablishment [
	<gtExample>
	| tenantExecution execution incomingFlow establishAdministrator operation tenantData registrationData tenant registration request transformation implementation environment administratorExecution invocation |
	tenantExecution := self tenantEstablishmentPublishesEstablishedTenantAsProcessData.
	execution := tenantExecution scope processExecution.
	incomingFlow := execution definition flowElements
		detect: [ :each | each identifier = #tenantToAdministrator ].
	establishAdministrator := execution definition flowElements
		detect: [ :each | each identifier = #establishTenantAdministrator ].
	operation := establishAdministrator operationRef.
	tenantData := execution definition flowElements
		detect: [ :each | each identifier = #establishedTenant ].
	registrationData := execution definition flowElements
		detect: [ :each | each identifier = #tenantRegistration ].
	tenant := execution itemValueFor: tenantData.
	registration := execution itemValueFor: registrationData.
	request := CPTenantAdministratorEstablishment new
		tenant: tenant;
		registration: registration;
		yourself.
	transformation := establishAdministrator dataInputAssociations first transformation.
	implementation := Object new.
	environment := execution environment.
	environment
		expression: transformation evaluatesTo: request;
		operation: operation resolvesTo: implementation.
	self assert: (execution availableFlowActivationsOn: incomingFlow) size equals: 1.
	administratorExecution := execution createServiceTaskExecutionFor: establishAdministrator.
	execution readyActivityExecution: administratorExecution.
	self assert: administratorExecution consumedFlowActivations size equals: 1.
	execution activateServiceTaskExecution: administratorExecution.
	self assert: administratorExecution isActive.
	self assert: administratorExecution resolvedImplementation == implementation.
	self assert: (administratorExecution itemValueFor: establishAdministrator ioSpecification dataInputs first) == request.
	self assert: request tenant == tenant.
	self assert: request registration == registration.
	invocation := administratorExecution prepareExternalInvocationIdentifiedBy: #establishTenantAdministratorInvocation.
	self assert: invocation isPending.
	self assert: invocation inputValue == request.
	^ invocation
]

{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> administratorEstablishmentPublishesEstablishedAdministratorAsProcessData [
	<gtExample>
	| invocation administratorExecution execution establishAdministrator administratorData administratorOutput administratorToTrial administrator root service workUnit context |
	invocation := self establishedTenantReachesExecutableAdministratorEstablishment.
	administratorExecution := invocation activityExecution.
	execution := administratorExecution scope processExecution.
	establishAdministrator := administratorExecution definition.
	administratorData := execution definition flowElements
		detect: [ :each | each identifier = #establishedTenantAdministrator ].
	administratorOutput := establishAdministrator ioSpecification dataOutputs first.
	administrator := CPUser new
		label: 'Prospective tenant administrator';
		yourself.
	root := CPSystemRoot new.
	root addProcessExecution: execution.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new
			systemRoot: root;
			executionEnvironment: execution environment;
			yourself).
	workUnit := CPCompleteServiceInvocationWorkUnit
		invocation: invocation
		occurrenceIdentifier: #tenantAdministratorEstablished
		payload: administrator.
	context := CRWorkUnitExecutionContext envelope: workUnit asEnvelope.
	context service: service.
	context bindCapabilities: Dictionary new.
	workUnit executeInContext: context.
	self assert: invocation isCompleted.
	self assert: administratorExecution isCompleted.
	self assert: (administratorExecution itemValueFor: administratorOutput) == administrator.
	self assert: (execution itemValueFor: administratorData) == administrator.
	administratorToTrial := execution definition flowElements
		detect: [ :each | each identifier = #administratorToTrial ].
	self assert: (execution availableFlowActivationsOn: administratorToTrial) size equals: 1.
	^ administratorExecution
]


{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> establishedAdministratorReachesExecutableTrialSubscription [
	<gtExample>
	| administratorExecution execution incomingFlow establishTrial operation tenantData tenant implementation environment trialExecution invocation |
	administratorExecution := self administratorEstablishmentPublishesEstablishedAdministratorAsProcessData.
	execution := administratorExecution scope processExecution.
	incomingFlow := execution definition flowElements
		detect: [ :each | each identifier = #administratorToTrial ].
	establishTrial := execution definition flowElements
		detect: [ :each | each identifier = #establishTrialSubscription ].
	operation := establishTrial operationRef.
	self assert: operation notNil.
	self assert: operation identifier equals: #establishTrialSubscriptionForTenant.
	self assert: establishTrial ioSpecification dataInputs size equals: 1.
	self assert: establishTrial ioSpecification dataOutputs isEmpty.
	self assert: establishTrial dataInputAssociations size equals: 1.
	self assert: establishTrial dataInputAssociations first sourceRefs first identifier equals: #establishedTenant.
	tenantData := execution definition flowElements
		detect: [ :each | each identifier = #establishedTenant ].
	tenant := execution itemValueFor: tenantData.
	implementation := Object new.
	environment := execution environment.
	environment operation: operation resolvesTo: implementation.
	self assert: (execution availableFlowActivationsOn: incomingFlow) size equals: 1.
	trialExecution := execution createServiceTaskExecutionFor: establishTrial.
	execution readyActivityExecution: trialExecution.
	self assert: trialExecution consumedFlowActivations size equals: 1.
	execution activateServiceTaskExecution: trialExecution.
	self assert: trialExecution isActive.
	self assert: trialExecution resolvedImplementation == implementation.
	self assert: (trialExecution itemValueFor: establishTrial ioSpecification dataInputs first) == tenant.
	invocation := trialExecution prepareExternalInvocationIdentifiedBy: #establishTrialSubscriptionInvocation.
	self assert: invocation isPending.
	self assert: invocation inputValue == tenant.
	^ invocation
]


{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> trialSubscriptionCompletionReachesExecutableTenantServiceProvisioning [
	<gtExample>
	| invocation trialExecution execution trialToServices provisionServices operation tenantData tenant root service workUnit context implementation environment provisionExecution provisionInvocation |
	invocation := self establishedAdministratorReachesExecutableTrialSubscription.
	trialExecution := invocation activityExecution.
	execution := trialExecution scope processExecution.
	root := CPSystemRoot new.
	root addProcessExecution: execution.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new
			systemRoot: root;
			executionEnvironment: execution environment;
			yourself).
	workUnit := CPCompleteServiceInvocationWorkUnit
		invocation: invocation
		occurrenceIdentifier: #trialSubscriptionEstablished
		payload: Dictionary new.
	context := CRWorkUnitExecutionContext envelope: workUnit asEnvelope.
	context service: service.
	context bindCapabilities: Dictionary new.
	workUnit executeInContext: context.
	self assert: invocation isCompleted.
	self assert: trialExecution isCompleted.
	trialToServices := execution definition flowElements
		detect: [ :each | each identifier = #trialToServices ].
	self assert: (execution availableFlowActivationsOn: trialToServices) size equals: 1.
	provisionServices := execution definition flowElements
		detect: [ :each | each identifier = #provisionTenantServices ].
	operation := provisionServices operationRef.
	self assert: operation notNil.
	self assert: operation identifier equals: #provisionTenantServicesForTenant.
	self assert: provisionServices ioSpecification dataInputs size equals: 1.
	self assert: provisionServices ioSpecification dataOutputs isEmpty.
	self assert: provisionServices dataInputAssociations size equals: 1.
	self assert: provisionServices dataInputAssociations first sourceRefs first identifier equals: #establishedTenant.
	tenantData := execution definition flowElements
		detect: [ :each | each identifier = #establishedTenant ].
	tenant := execution itemValueFor: tenantData.
	implementation := Object new.
	environment := execution environment.
	environment operation: operation resolvesTo: implementation.
	provisionExecution := execution createServiceTaskExecutionFor: provisionServices.
	execution readyActivityExecution: provisionExecution.
	self assert: provisionExecution consumedFlowActivations size equals: 1.
	execution activateServiceTaskExecution: provisionExecution.
	self assert: provisionExecution isActive.
	self assert: provisionExecution resolvedImplementation == implementation.
	self assert: (provisionExecution itemValueFor: provisionServices ioSpecification dataInputs first) == tenant.
	provisionInvocation := provisionExecution prepareExternalInvocationIdentifiedBy: #provisionTenantServicesInvocation.
	self assert: provisionInvocation isPending.
	self assert: provisionInvocation inputValue == tenant.
	^ provisionInvocation
]

{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> tenantServiceProvisioningCompletionReachesExecutableTrialAccessActivation [
	<gtExample>
	| invocation provisionExecution execution servicesToAccess activateAccess operation tenantData tenant root service workUnit context implementation environment accessExecution accessInvocation |
	invocation := self trialSubscriptionCompletionReachesExecutableTenantServiceProvisioning.
	provisionExecution := invocation activityExecution.
	execution := provisionExecution scope processExecution.
	root := CPSystemRoot new.
	root addProcessExecution: execution.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new
			systemRoot: root;
			executionEnvironment: execution environment;
			yourself).
	workUnit := CPCompleteServiceInvocationWorkUnit
		invocation: invocation
		occurrenceIdentifier: #tenantServicesProvisioned
		payload: Dictionary new.
	context := CRWorkUnitExecutionContext envelope: workUnit asEnvelope.
	context service: service.
	context bindCapabilities: Dictionary new.
	workUnit executeInContext: context.
	self assert: invocation isCompleted.
	self assert: provisionExecution isCompleted.
	servicesToAccess := execution definition flowElements
		detect: [ :each | each identifier = #servicesToAccess ].
	self assert: (execution availableFlowActivationsOn: servicesToAccess) size equals: 1.
	activateAccess := execution definition flowElements
		detect: [ :each | each identifier = #activateTrialAccess ].
	operation := activateAccess operationRef.
	self assert: operation notNil.
	self assert: operation identifier equals: #activateTrialAccessForTenant.
	self assert: activateAccess ioSpecification dataInputs size equals: 1.
	self assert: activateAccess ioSpecification dataOutputs isEmpty.
	self assert: activateAccess dataInputAssociations size equals: 1.
	self assert: activateAccess dataInputAssociations first sourceRefs first identifier equals: #establishedTenant.
	tenantData := execution definition flowElements
		detect: [ :each | each identifier = #establishedTenant ].
	tenant := execution itemValueFor: tenantData.
	implementation := Object new.
	environment := execution environment.
	environment operation: operation resolvesTo: implementation.
	accessExecution := execution createServiceTaskExecutionFor: activateAccess.
	execution readyActivityExecution: accessExecution.
	self assert: accessExecution consumedFlowActivations size equals: 1.
	execution activateServiceTaskExecution: accessExecution.
	self assert: accessExecution isActive.
	self assert: accessExecution resolvedImplementation == implementation.
	self assert: (accessExecution itemValueFor: activateAccess ioSpecification dataInputs first) == tenant.
	accessInvocation := accessExecution prepareExternalInvocationIdentifiedBy: #activateTrialAccessInvocation.
	self assert: accessInvocation isPending.
	self assert: accessInvocation inputValue == tenant.
	^ accessInvocation
]



{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> trialAccessCompletionSendsWelcomeAndCompletesTenantProvisioning [
	<gtExample>
	| invocation accessExecution execution accessToWelcome welcome tenantData tenant welcomeExecution dispatch welcomeToProvisioned provisioned endActivation root service workUnit context |
	invocation := self tenantServiceProvisioningCompletionReachesExecutableTrialAccessActivation.
	accessExecution := invocation activityExecution.
	execution := accessExecution scope processExecution.
	root := CPSystemRoot new.
	root addProcessExecution: execution.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new
			systemRoot: root;
			executionEnvironment: execution environment;
			yourself).
	workUnit := CPCompleteServiceInvocationWorkUnit
		invocation: invocation
		occurrenceIdentifier: #trialAccessActivated
		payload: Dictionary new.
	context := CRWorkUnitExecutionContext envelope: workUnit asEnvelope.
	context service: service.
	context bindCapabilities: Dictionary new.
	workUnit executeInContext: context.
	self assert: invocation isCompleted.
	self assert: accessExecution isCompleted.
	accessToWelcome := execution definition flowElements
		detect: [ :each | each identifier = #accessToWelcome ].
	self assert: (execution availableFlowActivationsOn: accessToWelcome) size equals: 1.
	welcome := execution definition flowElements
		detect: [ :each | each identifier = #sendWelcomeNotification ].
	self assert: welcome messageRef notNil.
	self assert: welcome messageRef identifier equals: #tenantWelcomeNotification.
	self assert: welcome ioSpecification dataInputs size equals: 1.
	self assert: welcome dataInputAssociations size equals: 1.
	self assert: welcome dataInputAssociations first sourceRefs first identifier equals: #establishedTenant.
	tenantData := execution definition flowElements
		detect: [ :each | each identifier = #establishedTenant ].
	tenant := execution itemValueFor: tenantData.
	welcomeExecution := execution createSendTaskExecutionFor: welcome.
	execution readyActivityExecution: welcomeExecution.
	self assert: welcomeExecution consumedFlowActivations size equals: 1.
	execution activateSendTaskExecution: welcomeExecution.
	self assert: welcomeExecution isActive.
	dispatch := welcomeExecution messageDispatch.
	self assert: dispatch isPending.
	self assert: dispatch message == welcome messageRef.
	self assert: dispatch payload == tenant.
	execution completeSendTaskExecution: welcomeExecution.
	self assert: dispatch isSent.
	self assert: welcomeExecution isCompleted.
	welcomeToProvisioned := execution definition flowElements
		detect: [ :each | each identifier = #welcomeToProvisioned ].
	self assert: (execution availableFlowActivationsOn: welcomeToProvisioned) size equals: 1.
	provisioned := execution definition flowElements
		detect: [ :each | each identifier = #tenantProvisioned ].
	endActivation := (execution availableFlowActivationsOn: welcomeToProvisioned) first.
	execution executeEndEvent: provisioned consuming: endActivation.
	self assert: execution canComplete.
	execution complete.
	self assert: execution isCompleted.
	^ execution
]

{ #category : 'examples - marketplace application' }
CPMarketplaceBootstrapExamples >> rejectedTenantRegistrationCompletesWithoutProvisioning [
	<gtExample>
	| invocation validationExecution execution environment decision acceptedFlow rejectedFlow rejectedEnd root service workUnit context decisionFlow decisionActivation gatewayExecution rejectedActivation |
	invocation := self tenantRegistrationSubmissionReachesExecutableValidationOperation.
	validationExecution := invocation activityExecution.
	execution := validationExecution scope processExecution.
	environment := execution environment.
	decision := execution definition flowElements
		detect: [ :each | each identifier = #registrationAccepted ].
	acceptedFlow := execution definition flowElements
		detect: [ :each | each identifier = #acceptedToTenant ].
	rejectedFlow := execution definition flowElements
		detect: [ :each | each identifier = #rejectedRegistration ].
	rejectedEnd := execution definition flowElements
		detect: [ :each | each identifier = #registrationRejected ].
	environment
		expression: acceptedFlow conditionExpression
		evaluatesTo: false.

	root := CPSystemRoot new.
	root addProcessExecution: execution.
	service := CPBpmService new installWithConfiguration:
		(CPBpmServiceConfiguration new
			systemRoot: root;
			executionEnvironment: environment;
			yourself).
	workUnit := CPCompleteServiceInvocationWorkUnit
		invocation: invocation
		occurrenceIdentifier: #tenantRegistrationRejected
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
	gatewayExecution := execution executeExclusiveGateway: decision consuming: decisionActivation.
	self assert: gatewayExecution notNil.
	self assert: (execution availableFlowActivationsOn: acceptedFlow) isEmpty.
	self assert: (execution availableFlowActivationsOn: rejectedFlow) size equals: 1.

	rejectedActivation := (execution availableFlowActivationsOn: rejectedFlow) first.
	execution executeEndEvent: rejectedEnd consuming: rejectedActivation.
	self assert: execution canComplete.
	execution complete.
	self assert: execution isCompleted.
	self assert: (execution definition flowElements
		select: [ :each | each identifier = #establishTenant ]) size equals: 1.
	self assert: (execution availableFlowActivationsOn: acceptedFlow) isEmpty.
	^ execution
]

{ #category : 'examples - marketplace bootstrap' }
CPMarketplaceBootstrapExamples >> marketplaceContainsInitialPublishedTenantLifecycleDefinition [
	<gtExample>
	| marketplace |
	marketplace := CPMarketplace new
		label: 'Catalyst Marketplace';
		yourself.
	marketplace addPublishedDefinition: CatalystTenantLifecycleV1.
	marketplace addPublishedDefinition: CatalystTenantLifecycleV1.

	self assert: marketplace publishedDefinitions asArray equals: { CatalystTenantLifecycleV1 }.
	self assert: (marketplace includesPublishedDefinition: CatalystTenantLifecycleV1).
	self assert: (CPDefinitionsSourceMaterializer isPublishedVersion: CatalystTenantLifecycleV1).
	self assert: (CPDefinitionsSourceMaterializer versionOf: CatalystTenantLifecycleV1) == CatalystTenantLifecycle.
	^ marketplace
]

{ #category : 'examples - marketplace bootstrap' }
CPMarketplaceBootstrapExamples >> marketplaceRejectsMutableDefinitionSource [
	<gtExample>
	| marketplace rejected |
	marketplace := CPMarketplace new.
	rejected := false.
	[ marketplace addPublishedDefinition: AdminTenantLifecycle ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: marketplace publishedDefinitions isEmpty.
	^ marketplace
]

{ #category : 'examples - marketplace products' }
CPMarketplaceBootstrapExamples >> tenantLifecycleProductPackagesPublishedDefinition [
	<gtExample>
	| marketplace product |
	marketplace := CPMarketplace new
		label: 'Catalyst Marketplace';
		yourself.
	marketplace addPublishedDefinition: CatalystTenantLifecycleV1.
	product := CPMarketplaceProduct new
		label: 'Tenant Lifecycle';
		yourself.
	product addPublishedDefinition: CatalystTenantLifecycleV1.
	marketplace addProduct: product.

	self assert: marketplace products asArray equals: { product }.
	self assert: product publishedDefinitions asArray equals: { CatalystTenantLifecycleV1 }.
	self assert: (marketplace includesPublishedDefinition: CatalystTenantLifecycleV1).
	^ product
]

{ #category : 'examples - marketplace products' }
CPMarketplaceBootstrapExamples >> marketplaceProductRejectsMutableDefinitionSource [
	<gtExample>
	| product rejected |
	product := CPMarketplaceProduct new.
	rejected := false.
	[ product addPublishedDefinition: AdminTenantLifecycle ]
		on: Error
		do: [ :error | rejected := true ].
	self assert: rejected.
	self assert: product publishedDefinitions isEmpty.
	^ product
]


{ #category : 'examples - marketplace products' }
CPMarketplaceBootstrapExamples >> adminBootstrapSeedsTenantLifecycleProduct [
	<gtExample>
	| bootstrap marketplace product |
	bootstrap := CPAdminTenantBootstrap configured.
	marketplace := bootstrap marketplace.

	self assert: marketplace products size equals: 1.
	product := marketplace products first.
	self assert: product label equals: 'Tenant Lifecycle'.
	self assert: product publishedDefinitions asArray equals: { CatalystTenantLifecycleV1 }.
	self assert: (marketplace includesPublishedDefinition: CatalystTenantLifecycleV1).
	^ product
]
