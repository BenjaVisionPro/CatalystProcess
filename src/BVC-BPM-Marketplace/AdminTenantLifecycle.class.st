Class {
	#name : 'AdminTenantLifecycle',
	#superclass : 'CatalystTenantLifecycleV1',
	#category : 'BVC-BPM-Marketplace',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Marketplace'
}

{ #category : 'processes' }
AdminTenantLifecycle class >> provisionTenant [
	<process: #provisionTenant>
	| process registrationData registrationDefinition initiated collectRegistration registrationInput registrationOutput inputSet outputSet ioSpecification inputAssociation outputAssociation validate accepted establishTenant establishAdministrator establishTrial provisionServices activateAccess notifyWelcome provisioned rejected flows |
	process := (CPProcess identifier: #provisionTenant)
		label: 'Provision Tenant';
		yourself.

	registrationDefinition := CPItemDefinition forStructure: CPTenantRegistration new.
	registrationData := (CPDataObject identifier: #tenantRegistration)
		itemSubjectRef: registrationDefinition;
		yourself.
	initiated := (CPStartEvent identifier: #tenantRegistrationInitiated)
		label: 'Tenant registration initiated';
		yourself.
	registrationInput := (CPDataInput identifier: #tenantRegistrationInput)
		itemSubjectRef: registrationDefinition;
		yourself.
	registrationOutput := (CPDataOutput identifier: #tenantRegistrationOutput)
		itemSubjectRef: registrationDefinition;
		yourself.
	inputSet := CPInputSet new dataInputRefs: { registrationInput }; yourself.
	outputSet := CPOutputSet new dataOutputRefs: { registrationOutput }; yourself.
	ioSpecification := CPInputOutputSpecification new
		dataInputs: { registrationInput };
		dataOutputs: { registrationOutput };
		inputSets: { inputSet };
		outputSets: { outputSet };
		yourself.
	inputAssociation := CPDataInputAssociation new
		sourceRefs: { registrationData };
		targetRef: registrationInput;
		yourself.
	outputAssociation := CPDataOutputAssociation new
		sourceRefs: { registrationOutput };
		targetRef: registrationData;
		yourself.
	collectRegistration := (CPUserTask identifier: #collectTenantRegistration)
		label: 'Collect registration';
		ioSpecification: ioSpecification;
		dataInputAssociations: { inputAssociation };
		dataOutputAssociations: { outputAssociation };
		yourself.
	validate := (CPServiceTask identifier: #validateRegistration)
		label: 'Validate registration';
		yourself.
	accepted := (CPExclusiveGateway identifier: #registrationAccepted)
		label: 'Registration accepted?';
		yourself.
	establishTenant := (CPServiceTask identifier: #establishTenant)
		label: 'Establish tenant';
		yourself.
	establishAdministrator := (CPServiceTask identifier: #establishTenantAdministrator)
		label: 'Establish tenant administrator';
		yourself.
	establishTrial := (CPServiceTask identifier: #establishTrialSubscription)
		label: 'Establish trial subscription';
		yourself.
	provisionServices := (CPServiceTask identifier: #provisionTenantServices)
		label: 'Provision tenant services';
		yourself.
	activateAccess := (CPServiceTask identifier: #activateTrialAccess)
		label: 'Activate trial access';
		yourself.
	notifyWelcome := (CPSendTask identifier: #sendWelcomeNotification)
		label: 'Send welcome notification';
		yourself.
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
	(flows at: 4) label: 'Accepted'; sourceRef: accepted; targetRef: establishTenant.
	(flows at: 5) label: 'Rejected'; sourceRef: accepted; targetRef: rejected.
	(flows at: 6) sourceRef: establishTenant; targetRef: establishAdministrator.
	(flows at: 7) sourceRef: establishAdministrator; targetRef: establishTrial.
	(flows at: 8) sourceRef: establishTrial; targetRef: provisionServices.
	(flows at: 9) sourceRef: provisionServices; targetRef: activateAccess.
	(flows at: 10) sourceRef: activateAccess; targetRef: notifyWelcome.
	(flows at: 11) sourceRef: notifyWelcome; targetRef: provisioned.

	{ registrationData. initiated. collectRegistration. validate. accepted. establishTenant.
	  establishAdministrator. establishTrial. provisionServices. activateAccess.
	  notifyWelcome. provisioned. rejected }
		do: [ :each | process addFlowElement: each ].
	flows do: [ :each | process addFlowElement: each ].
	^ process
]
