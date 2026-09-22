Class {
	#name : 'CatalystTenantLifecycleV1',
	#superclass : 'Object',
	#category : 'BVC-BPM-Marketplace',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Marketplace'
}

{ #category : 'definitions' }
CatalystTenantLifecycleV1 class >> definitions [
	| definitions tenantRegistrationInterface validateOperation establishTenantOperation establishTenantResultMessage establishAdministratorOperation establishAdministratorResultMessage establishTrialOperation provisionServicesOperation activateAccessOperation welcomeNotificationMessage |
	definitions := CPDefinitions identifier: #tenantLifecycle.
	definitions targetNamespace: 'urn:catalyst:tenant-lifecycle'.
	validateOperation := (CPOperation identifier: #validateTenantRegistration)
		label: 'Validate tenant registration';
		yourself.
	establishTenantResultMessage := (CPMessage identifier: #establishedTenantResult)
		label: 'Established tenant result';
		yourself.
	establishTenantOperation := (CPOperation identifier: #establishTenantFromRegistration)
		label: 'Establish tenant from registration';
		outMessageRef: establishTenantResultMessage;
		yourself.
	establishAdministratorResultMessage := (CPMessage identifier: #establishedTenantAdministratorResult)
		label: 'Established tenant administrator result';
		yourself.
	establishAdministratorOperation := (CPOperation identifier: #establishTenantAdministratorFromRegistration)
		label: 'Establish tenant administrator from registration';
		outMessageRef: establishAdministratorResultMessage;
		yourself.
	establishTrialOperation := (CPOperation identifier: #establishTrialSubscriptionForTenant)
		label: 'Establish trial subscription for tenant';
		yourself.
	provisionServicesOperation := (CPOperation identifier: #provisionTenantServicesForTenant)
		label: 'Provision tenant services for tenant';
		yourself.
	activateAccessOperation := (CPOperation identifier: #activateTrialAccessForTenant)
		label: 'Activate trial access for tenant';
		yourself.
	welcomeNotificationMessage := (CPMessage identifier: #tenantWelcomeNotification)
		label: 'Tenant welcome notification';
		yourself.
	tenantRegistrationInterface := (CPInterface identifier: #tenantRegistrationOperations)
		label: 'Tenant registration operations';
		yourself.
	tenantRegistrationInterface
		addOperation: validateOperation;
		addOperation: establishTenantOperation;
		addOperation: establishAdministratorOperation;
		addOperation: establishTrialOperation;
		addOperation: provisionServicesOperation;
		addOperation: activateAccessOperation.
	definitions
		addRootElement: tenantRegistrationInterface;
		addRootElement: welcomeNotificationMessage.
	^ definitions
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> suspendTenant [
	<process: #suspendTenant>
	^ (CPProcess identifier: #suspendTenant)
		label: 'Suspend Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> resumeTenant [
	<process: #resumeTenant>
	^ (CPProcess identifier: #resumeTenant)
		label: 'Resume Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> removeTenant [
	<process: #removeTenant>
	^ (CPProcess identifier: #removeTenant)
		label: 'Remove Tenant';
		yourself
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV1 class >> suspendTenantOverview [
	<diagram: #suspendTenantOverview process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV1 class >> suspendTenantOperations [
	<diagram: #suspendTenantOperations process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOperations
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV1 class >> resumeTenantOverview [
	<diagram: #resumeTenantOverview process: #resumeTenant>
	^ CPDiagram identifier: #resumeTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV1 class >> removeTenantOverview [
	<diagram: #removeTenantOverview process: #removeTenant>
	^ CPDiagram identifier: #removeTenantOverview
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> provisionTenant [
	<process: #provisionTenant>
	| process registrationData tenantData administratorData initiated collectRegistration validate accepted acceptedCondition establishTenant establishAdministrator establishTrial provisionServices activateAccess notifyWelcome provisioned rejected flows |
	process := (CPProcess identifier: #provisionTenant)
		label: 'Provision Tenant';
		yourself.
	registrationData := self tenantRegistrationData.
	tenantData := self establishedTenantData.
	administratorData := self establishedTenantAdministratorData.
	initiated := (CPStartEvent identifier: #tenantRegistrationInitiated)
		label: 'Tenant registration initiated';
		yourself.
	collectRegistration := self collectTenantRegistrationUsing: registrationData.
	validate := self validateTenantRegistrationUsing: registrationData.
	acceptedCondition := (CPFormalExpression identifier: #tenantRegistrationIsAccepted)
		body: 'tenantRegistrationIsAccepted';
		yourself.
	accepted := self registrationAcceptedGateway.
	establishTenant := self establishTenantUsing: registrationData result: tenantData.
	establishAdministrator := self
		establishTenantAdministratorUsing: tenantData
		registration: registrationData
		result: administratorData.
	establishTrial := self establishTrialSubscriptionUsing: tenantData.
	provisionServices := self provisionTenantServicesUsing: tenantData.
	activateAccess := self activateTrialAccessUsing: tenantData.
	notifyWelcome := self sendWelcomeNotificationUsing: tenantData.
	provisioned := (CPEndEvent identifier: #tenantProvisioned)
		label: 'Tenant provisioned';
		yourself.
	rejected := (CPEndEvent identifier: #registrationRejected)
		label: 'Registration rejected';
		yourself.
	flows := {
		CPSequenceFlow identifier: #initiationToRegistration.
		CPSequenceFlow identifier: #registrationToValidation.
		CPSequenceFlow identifier: #validationToDecision.
		CPSequenceFlow identifier: #acceptedToTenant.
		CPSequenceFlow identifier: #rejectedRegistration.
		CPSequenceFlow identifier: #tenantToAdministrator.
		CPSequenceFlow identifier: #administratorToTrial.
		CPSequenceFlow identifier: #trialToServices.
		CPSequenceFlow identifier: #servicesToAccess.
		CPSequenceFlow identifier: #accessToWelcome.
		CPSequenceFlow identifier: #welcomeToProvisioned }.
	(flows at: 1) sourceRef: initiated; targetRef: collectRegistration.
	(flows at: 2) sourceRef: collectRegistration; targetRef: validate.
	(flows at: 3) sourceRef: validate; targetRef: accepted.
	(flows at: 4)
		label: 'Accepted';
		sourceRef: accepted;
		targetRef: establishTenant;
		conditionExpression: acceptedCondition.
	(flows at: 5) label: 'Rejected'; sourceRef: accepted; targetRef: rejected.
	accepted default: (flows at: 5).
	(flows at: 6) sourceRef: establishTenant; targetRef: establishAdministrator.
	(flows at: 7) sourceRef: establishAdministrator; targetRef: establishTrial.
	(flows at: 8) sourceRef: establishTrial; targetRef: provisionServices.
	(flows at: 9) sourceRef: provisionServices; targetRef: activateAccess.
	(flows at: 10) sourceRef: activateAccess; targetRef: notifyWelcome.
	(flows at: 11) sourceRef: notifyWelcome; targetRef: provisioned.
	{ registrationData. tenantData. administratorData. initiated. collectRegistration. validate. accepted. establishTenant.
	  establishAdministrator. establishTrial. provisionServices. activateAccess. notifyWelcome. provisioned. rejected }
		do: [ :each | process addFlowElement: each ].
	flows do: [ :each | process addFlowElement: each ].
	^ process
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> startSubscription [
	<process: #startSubscription>
	| process requested validate eligible authorize authorized establishSubscription establishEntitlements activatePaidAccess confirm started declined flows |
	process := (CPProcess identifier: #startSubscription)
		label: 'Start Subscription';
		yourself.
	requested := (CPStartEvent identifier: #subscriptionRequested)
		label: 'Subscription requested';
		yourself.
	validate := (CPServiceTask identifier: #validateSubscriptionRequest)
		label: 'Validate subscription request';
		yourself.
	eligible := (CPExclusiveGateway identifier: #subscriptionEligible)
		label: 'Subscription eligible?';
		yourself.
	authorize := (CPServiceTask identifier: #authorizeInitialPayment)
		label: 'Authorize initial payment';
		yourself.
	authorized := (CPExclusiveGateway identifier: #paymentAuthorized)
		label: 'Payment authorized?';
		yourself.
	establishSubscription := (CPServiceTask identifier: #establishPaidSubscription)
		label: 'Establish paid subscription';
		yourself.
	establishEntitlements := (CPServiceTask identifier: #establishPaidEntitlements)
		label: 'Establish paid entitlements';
		yourself.
	activatePaidAccess := (CPServiceTask identifier: #activatePaidAccess)
		label: 'Activate paid access';
		yourself.
	confirm := (CPSendTask identifier: #sendSubscriptionConfirmation)
		label: 'Send subscription confirmation';
		yourself.
	started := (CPEndEvent identifier: #subscriptionStarted)
		label: 'Subscription started';
		yourself.
	declined := (CPEndEvent identifier: #subscriptionNotStarted)
		label: 'Subscription not started';
		yourself.

	flows := {
		CPSequenceFlow identifier: #requestToValidation.
		CPSequenceFlow identifier: #validationToEligibility.
		CPSequenceFlow identifier: #eligibleToAuthorization.
		CPSequenceFlow identifier: #ineligibleSubscription.
		CPSequenceFlow identifier: #authorizationToDecision.
		CPSequenceFlow identifier: #authorizedToSubscription.
		CPSequenceFlow identifier: #paymentDeclined.
		CPSequenceFlow identifier: #subscriptionToEntitlements.
		CPSequenceFlow identifier: #entitlementsToPaidAccess.
		CPSequenceFlow identifier: #paidAccessToConfirmation.
		CPSequenceFlow identifier: #confirmationToStarted }.
	(flows at: 1) sourceRef: requested; targetRef: validate.
	(flows at: 2) sourceRef: validate; targetRef: eligible.
	(flows at: 3) label: 'Eligible'; sourceRef: eligible; targetRef: authorize.
	(flows at: 4) label: 'Ineligible'; sourceRef: eligible; targetRef: declined.
	(flows at: 5) sourceRef: authorize; targetRef: authorized.
	(flows at: 6) label: 'Authorized'; sourceRef: authorized; targetRef: establishSubscription.
	(flows at: 7) label: 'Declined'; sourceRef: authorized; targetRef: declined.
	(flows at: 8) sourceRef: establishSubscription; targetRef: establishEntitlements.
	(flows at: 9) sourceRef: establishEntitlements; targetRef: activatePaidAccess.
	(flows at: 10) sourceRef: activatePaidAccess; targetRef: confirm.
	(flows at: 11) sourceRef: confirm; targetRef: started.

	{ requested. validate. eligible. authorize. authorized. establishSubscription.
	  establishEntitlements. activatePaidAccess. confirm. started. declined }
		do: [ :each | process addFlowElement: each ].
	flows do: [ :each | process addFlowElement: each ].
	^ process
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> changeSubscription [
	<process: #changeSubscription>
	^ (CPProcess identifier: #changeSubscription)
		label: 'Change Subscription';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> renewSubscription [
	<process: #renewSubscription>
	^ (CPProcess identifier: #renewSubscription)
		label: 'Renew Subscription';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> recoverPayment [
	<process: #recoverPayment>
	^ (CPProcess identifier: #recoverPayment)
		label: 'Recover Payment';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> cancelSubscription [
	<process: #cancelSubscription>
	^ (CPProcess identifier: #cancelSubscription)
		label: 'Cancel Subscription';
		yourself
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV1 class >> provisionTenantOverview [
	<diagram: #provisionTenantOverview process: #provisionTenant>
	| diagram process nodes shapes flows edges x y |
	process := self provisionTenant.
	diagram := CPDiagram identifier: #provisionTenantOverview.
	nodes := process flowElements select: [ :each | each isFlowNode ].
	shapes := OrderedCollection new.
	x := 80.
	y := 120.
	nodes do: [ :node |
		| extent shape |
		extent := ((node isStartEvent) or: [ node isEndEvent ])
			ifTrue: [ 42 @ 42 ]
			ifFalse: [ (node isGateway) ifTrue: [ 54 @ 54 ] ifFalse: [ 150 @ 60 ] ].
		shape := CPShape new modelElement: node; bounds: (x @ y extent: extent); yourself.
		shapes add: shape.
		diagram addElement: shape.
		node identifier = #registrationAccepted
			ifTrue: [ x := x + 130 ]
			ifFalse: [ x := x + extent x + 70 ] ].
	"Place the rejected end below the decision rather than extending the happy path."
	(shapes detect: [ :each | each modelElement identifier = #registrationRejected ])
		bounds: (692 @ 260 extent: 42 @ 42).
	flows := process flowElements select: [ :each | each isSequenceFlow ].
	edges := flows collect: [ :flow |
		| edge sourceShape targetShape sourcePoint targetPoint |
		sourceShape := shapes detect: [ :each | each modelElement == flow sourceRef ].
		targetShape := shapes detect: [ :each | each modelElement == flow targetRef ].
		sourcePoint := sourceShape bounds rightCenter.
		targetPoint := targetShape bounds leftCenter.
		edge := CPEdge new modelElement: flow; yourself.
		edge addWaypoint: sourcePoint; addWaypoint: targetPoint.
		diagram addElement: edge.
		edge ].
	^ diagram
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV1 class >> startSubscriptionOverview [
	<diagram: #startSubscriptionOverview process: #startSubscription>
	| diagram process nodes shapes flows x y |
	process := self startSubscription.
	diagram := CPDiagram identifier: #startSubscriptionOverview.
	nodes := process flowElements select: [ :each | each isFlowNode ].
	shapes := OrderedCollection new.
	x := 80.
	y := 120.
	nodes do: [ :node |
		| extent shape |
		extent := ((node isStartEvent) or: [ node isEndEvent ])
			ifTrue: [ 42 @ 42 ]
			ifFalse: [ (node isGateway) ifTrue: [ 54 @ 54 ] ifFalse: [ 150 @ 60 ] ].
		shape := CPShape new modelElement: node; bounds: (x @ y extent: extent); yourself.
		shapes add: shape.
		diagram addElement: shape.
		x := x + extent x + 70 ].
	(shapes detect: [ :each | each modelElement identifier = #subscriptionNotStarted ])
		bounds: (620 @ 280 extent: 42 @ 42).
	flows := process flowElements select: [ :each | each isSequenceFlow ].
	flows do: [ :flow |
		| edge sourceShape targetShape |
		sourceShape := shapes detect: [ :each | each modelElement == flow sourceRef ].
		targetShape := shapes detect: [ :each | each modelElement == flow targetRef ].
		edge := CPEdge new modelElement: flow; yourself.
		edge addWaypoint: sourceShape bounds rightCenter; addWaypoint: targetShape bounds leftCenter.
		diagram addElement: edge ].
	^ diagram
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> collectTenantRegistrationUsing: registrationData [
	| definition input output inputSet outputSet ioSpecification inputAssociation outputAssociation |
	definition := registrationData itemSubjectRef.
	input := (CPDataInput identifier: #tenantRegistrationInput)
		itemSubjectRef: definition;
		yourself.
	output := (CPDataOutput identifier: #tenantRegistrationOutput)
		itemSubjectRef: definition;
		yourself.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	outputSet := CPOutputSet new dataOutputRefs: { output }; yourself.
	ioSpecification := CPInputOutputSpecification new
		dataInputs: { input };
		dataOutputs: { output };
		inputSets: { inputSet };
		outputSets: { outputSet };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { registrationData };
		targetRef: input;
		yourself.
	outputAssociation := CPDataOutputAssociation new
		sourceRefs: { output };
		targetRef: registrationData;
		yourself.
	^ (CPUserTask identifier: #collectTenantRegistration)
		label: 'Collect registration';
		ioSpecification: ioSpecification;
		dataInputAssociations: { inputAssociation };
		dataOutputAssociations: { outputAssociation };
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> establishedTenantAdministratorData [
	^ (CPDataObject identifier: #establishedTenantAdministrator)
		itemSubjectRef: (CPItemDefinition forStructure: CPUser new);
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> establishedTenantData [
	^ (CPDataObject identifier: #establishedTenant)
		itemSubjectRef: (CPItemDefinition forStructure: CPTenant new);
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> establishTenantAdministratorUsing: tenantData registration: registrationData result: administratorData [
	| operation resultMessage requestDefinition input output inputSet outputSet ioSpecification transformation inputAssociation outputAssociation |
	resultMessage := (CPMessage identifier: #establishedTenantAdministratorResult)
		label: 'Established tenant administrator result';
		yourself.
	operation := (CPOperation identifier: #establishTenantAdministratorFromRegistration)
		label: 'Establish tenant administrator from registration';
		outMessageRef: resultMessage;
		yourself.
	requestDefinition := CPItemDefinition forStructure: CPTenantAdministratorEstablishment new.
	input := (CPDataInput identifier: #tenantAdministratorEstablishment)
		itemSubjectRef: requestDefinition;
		yourself.
	output := (CPDataOutput identifier: #establishedTenantAdministratorOutput)
		itemSubjectRef: administratorData itemSubjectRef;
		yourself.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	outputSet := CPOutputSet new dataOutputRefs: { output }; yourself.
	ioSpecification := CPInputOutputSpecification new
		dataInputs: { input };
		dataOutputs: { output };
		inputSets: { inputSet };
		outputSets: { outputSet };
		yourself.
	transformation := (CPFormalExpression identifier: #prepareTenantAdministratorEstablishment)
		body: 'prepareTenantAdministratorEstablishment';
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { tenantData. registrationData };
		targetRef: input;
		transformation: transformation;
		yourself.
	outputAssociation := CPDataOutputAssociation new
		sourceRefs: { output };
		targetRef: administratorData;
		yourself.
	^ (CPServiceTask identifier: #establishTenantAdministrator)
		label: 'Establish tenant administrator';
		operationRef: operation;
		ioSpecification: ioSpecification;
		dataInputAssociations: { inputAssociation };
		dataOutputAssociations: { outputAssociation };
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> establishTrialSubscriptionUsing: tenantData [
	| operation input inputSet ioSpecification inputAssociation |
	operation := (CPOperation identifier: #establishTrialSubscriptionForTenant)
		label: 'Establish trial subscription for tenant';
		yourself.
	input := (CPDataInput identifier: #tenantForTrialSubscription)
		itemSubjectRef: tenantData itemSubjectRef;
		yourself.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	ioSpecification := CPInputOutputSpecification new
		dataInputs: { input };
		inputSets: { inputSet };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { tenantData };
		targetRef: input;
		yourself.
	^ (CPServiceTask identifier: #establishTrialSubscription)
		label: 'Establish trial subscription';
		operationRef: operation;
		ioSpecification: ioSpecification;
		dataInputAssociations: { inputAssociation };
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> establishTenantUsing: registrationData result: tenantData [
	| operation resultMessage input output inputSet outputSet ioSpecification inputAssociation outputAssociation |
	resultMessage := (CPMessage identifier: #establishedTenantResult)
		label: 'Established tenant result';
		yourself.
	operation := (CPOperation identifier: #establishTenantFromRegistration)
		label: 'Establish tenant from registration';
		outMessageRef: resultMessage;
		yourself.
	input := (CPDataInput identifier: #registrationForTenantEstablishment)
		itemSubjectRef: registrationData itemSubjectRef;
		yourself.
	output := (CPDataOutput identifier: #establishedTenantOutput)
		itemSubjectRef: tenantData itemSubjectRef;
		yourself.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	outputSet := CPOutputSet new dataOutputRefs: { output }; yourself.
	ioSpecification := CPInputOutputSpecification new
		dataInputs: { input };
		dataOutputs: { output };
		inputSets: { inputSet };
		outputSets: { outputSet };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { registrationData };
		targetRef: input;
		yourself.
	outputAssociation := CPDataOutputAssociation new
		sourceRefs: { output };
		targetRef: tenantData;
		yourself.
	^ (CPServiceTask identifier: #establishTenant)
		label: 'Establish tenant';
		operationRef: operation;
		ioSpecification: ioSpecification;
		dataInputAssociations: { inputAssociation };
		dataOutputAssociations: { outputAssociation };
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> provisionTenantServicesUsing: tenantData [
	| operation input inputSet ioSpecification inputAssociation |
	operation := (CPOperation identifier: #provisionTenantServicesForTenant)
		label: 'Provision tenant services for tenant';
		yourself.
	input := (CPDataInput identifier: #tenantForServiceProvisioning)
		itemSubjectRef: tenantData itemSubjectRef;
		yourself.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	ioSpecification := CPInputOutputSpecification new
		dataInputs: { input };
		inputSets: { inputSet };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { tenantData };
		targetRef: input;
		yourself.
	^ (CPServiceTask identifier: #provisionTenantServices)
		label: 'Provision tenant services';
		operationRef: operation;
		ioSpecification: ioSpecification;
		dataInputAssociations: { inputAssociation };
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> activateTrialAccessUsing: tenantData [
	| operation input inputSet ioSpecification inputAssociation |
	operation := (CPOperation identifier: #activateTrialAccessForTenant)
		label: 'Activate trial access for tenant';
		yourself.
	input := (CPDataInput identifier: #tenantForTrialAccessActivation)
		itemSubjectRef: tenantData itemSubjectRef;
		yourself.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	ioSpecification := CPInputOutputSpecification new
		dataInputs: { input };
		inputSets: { inputSet };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { tenantData };
		targetRef: input;
		yourself.
	^ (CPServiceTask identifier: #activateTrialAccess)
		label: 'Activate trial access';
		operationRef: operation;
		ioSpecification: ioSpecification;
		dataInputAssociations: { inputAssociation };
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> registrationAcceptedGateway [
	^ (CPExclusiveGateway identifier: #registrationAccepted)
		label: 'Registration accepted?';
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> tenantRegistrationData [
	^ (CPDataObject identifier: #tenantRegistration)
		itemSubjectRef: (CPItemDefinition forStructure: CPTenantRegistration new);
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> validateTenantRegistrationUsing: registrationData [
	| operation input inputSet ioSpecification inputAssociation |
	operation := (CPOperation identifier: #validateTenantRegistration)
		label: 'Validate tenant registration';
		yourself.
	input := (CPDataInput identifier: #registrationToValidate)
		itemSubjectRef: registrationData itemSubjectRef;
		yourself.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	ioSpecification := CPInputOutputSpecification new
		dataInputs: { input };
		inputSets: { inputSet };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { registrationData };
		targetRef: input;
		yourself.
	^ (CPServiceTask identifier: #validateRegistration)
		label: 'Validate registration';
		operationRef: operation;
		ioSpecification: ioSpecification;
		dataInputAssociations: { inputAssociation };
		yourself
]

{ #category : 'process construction' }
CatalystTenantLifecycleV1 class >> sendWelcomeNotificationUsing: tenantData [
	| message input inputSet ioSpecification inputAssociation |
	message := (CPMessage identifier: #tenantWelcomeNotification)
		label: 'Tenant welcome notification';
		yourself.
	input := (CPDataInput identifier: #tenantForWelcomeNotification)
		itemSubjectRef: tenantData itemSubjectRef;
		yourself.
	inputSet := CPInputSet new dataInputRefs: { input }; yourself.
	ioSpecification := CPInputOutputSpecification new
		dataInputs: { input };
		inputSets: { inputSet };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { tenantData };
		targetRef: input;
		yourself.
	^ (CPSendTask identifier: #sendWelcomeNotification)
		label: 'Send welcome notification';
		messageRef: message;
		ioSpecification: ioSpecification;
		dataInputAssociations: { inputAssociation };
		yourself
]

{ #category : 'versioning' }
CatalystTenantLifecycleV1 class >> version [
	<publishedVersion>
	^ 1
]

{ #category : 'versioning' }
CatalystTenantLifecycleV1 class >> versionOf [
	^ CatalystTenantLifecycle
]
