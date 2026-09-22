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

{ #category : 'process construction' }
AdminTenantLifecycle class >> collectTenantRegistrationUsing: registrationData [
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
AdminTenantLifecycle class >> establishedTenantAdministratorData [
	^ (CPDataObject identifier: #establishedTenantAdministrator)
		itemSubjectRef: (CPItemDefinition forStructure: CPUser new);
		yourself
]

{ #category : 'process construction' }
AdminTenantLifecycle class >> establishedTenantData [
	^ (CPDataObject identifier: #establishedTenant)
		itemSubjectRef: (CPItemDefinition forStructure: CPTenant new);
		yourself
]

{ #category : 'process construction' }
AdminTenantLifecycle class >> establishTenantAdministratorUsing: tenantData registration: registrationData result: administratorData [
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
AdminTenantLifecycle class >> establishTenantUsing: registrationData result: tenantData [
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
AdminTenantLifecycle class >> registrationAcceptedGateway [
	^ (CPExclusiveGateway identifier: #registrationAccepted)
		label: 'Registration accepted?';
		yourself
]

{ #category : 'process construction' }
AdminTenantLifecycle class >> tenantRegistrationData [
	^ (CPDataObject identifier: #tenantRegistration)
		itemSubjectRef: (CPItemDefinition forStructure: CPTenantRegistration new);
		yourself
]

{ #category : 'process construction' }
AdminTenantLifecycle class >> validateTenantRegistrationUsing: registrationData [
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

{ #category : 'processes' }
AdminTenantLifecycle class >> provisionTenant [
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
	  establishAdministrator. establishTrial. provisionServices. activateAccess. notifyWelcome. provisioned. rejected }
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
