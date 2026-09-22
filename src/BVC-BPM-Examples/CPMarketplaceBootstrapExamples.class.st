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
