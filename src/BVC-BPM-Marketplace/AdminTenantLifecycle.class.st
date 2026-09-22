Class {
	#name : 'AdminTenantLifecycle',
	#superclass : 'CatalystTenantLifecycleV1',
	#category : 'BVC-BPM-Marketplace',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Marketplace'
}

{ #category : 'definitions' }
AdminTenantLifecycle class >> definitions [
	| definitions tenantRegistrationInterface validateOperation establishTenantOperation establishTenantResultMessage establishAdministratorOperation establishAdministratorResultMessage |
	definitions := super definitions.
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
	tenantRegistrationInterface := (CPInterface identifier: #tenantRegistrationOperations)
		label: 'Tenant registration operations';
		yourself.
	tenantRegistrationInterface
		addOperation: validateOperation;
		addOperation: establishTenantOperation;
		addOperation: establishAdministratorOperation.
	definitions addRootElement: tenantRegistrationInterface.
	^ definitions
]

{ #category : 'processes' }
AdminTenantLifecycle class >> provisionTenant [
	<process: #provisionTenant>
	| process registrationData registrationDefinition tenantData tenantDefinition administratorData administratorDefinition administratorRequestDefinition initiated collectRegistration registrationInput registrationOutput inputSet outputSet ioSpecification inputAssociation outputAssociation validate validateOperation validateInput validateInputSet validateIoSpecification validateInputAssociation accepted acceptedCondition establishTenant establishTenantOperation establishTenantResultMessage establishTenantInput establishTenantOutput establishTenantInputSet establishTenantOutputSet establishTenantIoSpecification establishTenantInputAssociation establishTenantOutputAssociation establishAdministrator establishAdministratorOperation establishAdministratorResultMessage administratorInput administratorOutput administratorInputSet administratorOutputSet administratorIoSpecification administratorInputAssociation administratorOutputAssociation administratorTransformation establishTrial provisionServices activateAccess notifyWelcome provisioned rejected flows |
	process := (CPProcess identifier: #provisionTenant)
		label: 'Provision Tenant';
		yourself.

	registrationDefinition := CPItemDefinition forStructure: CPTenantRegistration new.
	registrationData := (CPDataObject identifier: #tenantRegistration)
		itemSubjectRef: registrationDefinition;
		yourself.
	tenantDefinition := CPItemDefinition forStructure: CPTenant new.
	tenantData := (CPDataObject identifier: #establishedTenant)
		itemSubjectRef: tenantDefinition;
		yourself.
	administratorDefinition := CPItemDefinition forStructure: CPUser new.
	administratorData := (CPDataObject identifier: #establishedTenantAdministrator)
		itemSubjectRef: administratorDefinition;
		yourself.
	administratorRequestDefinition := CPItemDefinition forStructure: CPTenantAdministratorEstablishment new.
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
	validateOperation := (CPOperation identifier: #validateTenantRegistration)
		label: 'Validate tenant registration';
		yourself.
	validateInput := (CPDataInput identifier: #registrationToValidate)
		itemSubjectRef: registrationDefinition;
		yourself.
	validateInputSet := CPInputSet new dataInputRefs: { validateInput }; yourself.
	validateIoSpecification := CPInputOutputSpecification new
		dataInputs: { validateInput };
		inputSets: { validateInputSet };
		yourself.
	validateInputAssociation := CPDataInputAssociation new
		sourceRefs: { registrationData };
		targetRef: validateInput;
		yourself.
	validate := (CPServiceTask identifier: #validateRegistration)
		label: 'Validate registration';
		operationRef: validateOperation;
		ioSpecification: validateIoSpecification;
		dataInputAssociations: { validateInputAssociation };
		yourself.
	acceptedCondition := (CPFormalExpression identifier: #tenantRegistrationIsAccepted)
		body: 'tenantRegistrationIsAccepted';
		yourself.
	accepted := (CPExclusiveGateway identifier: #registrationAccepted)
		label: 'Registration accepted?';
		yourself.
	establishTenantResultMessage := (CPMessage identifier: #establishedTenantResult)
		label: 'Established tenant result';
		yourself.
	establishTenantOperation := (CPOperation identifier: #establishTenantFromRegistration)
		label: 'Establish tenant from registration';
		outMessageRef: establishTenantResultMessage;
		yourself.
	establishTenantInput := (CPDataInput identifier: #registrationForTenantEstablishment)
		itemSubjectRef: registrationDefinition;
		yourself.
	establishTenantOutput := (CPDataOutput identifier: #establishedTenantOutput)
		itemSubjectRef: tenantDefinition;
		yourself.
	establishTenantInputSet := CPInputSet new dataInputRefs: { establishTenantInput }; yourself.
	establishTenantOutputSet := CPOutputSet new dataOutputRefs: { establishTenantOutput }; yourself.
	establishTenantIoSpecification := CPInputOutputSpecification new
		dataInputs: { establishTenantInput };
		dataOutputs: { establishTenantOutput };
		inputSets: { establishTenantInputSet };
		outputSets: { establishTenantOutputSet };
		yourself.
	establishTenantInputAssociation := CPDataInputAssociation new
		sourceRefs: { registrationData };
		targetRef: establishTenantInput;
		yourself.
	establishTenantOutputAssociation := CPDataOutputAssociation new
		sourceRefs: { establishTenantOutput };
		targetRef: tenantData;
		yourself.
	establishTenant := (CPServiceTask identifier: #establishTenant)
		label: 'Establish tenant';
		operationRef: establishTenantOperation;
		ioSpecification: establishTenantIoSpecification;
		dataInputAssociations: { establishTenantInputAssociation };
		dataOutputAssociations: { establishTenantOutputAssociation };
		yourself.
	establishAdministratorResultMessage := (CPMessage identifier: #establishedTenantAdministratorResult)
		label: 'Established tenant administrator result';
		yourself.
	establishAdministratorOperation := (CPOperation identifier: #establishTenantAdministratorFromRegistration)
		label: 'Establish tenant administrator from registration';
		outMessageRef: establishAdministratorResultMessage;
		yourself.
	administratorInput := (CPDataInput identifier: #tenantAdministratorEstablishment)
		itemSubjectRef: administratorRequestDefinition;
		yourself.
	administratorOutput := (CPDataOutput identifier: #establishedTenantAdministratorOutput)
		itemSubjectRef: administratorDefinition;
		yourself.
	administratorInputSet := CPInputSet new dataInputRefs: { administratorInput }; yourself.
	administratorOutputSet := CPOutputSet new dataOutputRefs: { administratorOutput }; yourself.
	administratorIoSpecification := CPInputOutputSpecification new
		dataInputs: { administratorInput };
		dataOutputs: { administratorOutput };
		inputSets: { administratorInputSet };
		outputSets: { administratorOutputSet };
		yourself.
	administratorTransformation := (CPFormalExpression identifier: #prepareTenantAdministratorEstablishment)
		body: 'prepareTenantAdministratorEstablishment';
		yourself.
	administratorInputAssociation := CPDataInputAssociation new
		sourceRefs: { tenantData. registrationData };
		targetRef: administratorInput;
		transformation: administratorTransformation;
		yourself.
	administratorOutputAssociation := CPDataOutputAssociation new
		sourceRefs: { administratorOutput };
		targetRef: administratorData;
		yourself.
	establishAdministrator := (CPServiceTask identifier: #establishTenantAdministrator)
		label: 'Establish tenant administrator';
		operationRef: establishAdministratorOperation;
		ioSpecification: administratorIoSpecification;
		dataInputAssociations: { administratorInputAssociation };
		dataOutputAssociations: { administratorOutputAssociation };
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
	  establishAdministrator. establishTrial. provisionServices. activateAccess.
	  notifyWelcome. provisioned. rejected }
		do: [ :each | process addFlowElement: each ].
	flows do: [ :each | process addFlowElement: each ].
	^ process
]

{ #category : 'diagrams' }
AdminTenantLifecycle class >> provisionTenantOverview [
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
