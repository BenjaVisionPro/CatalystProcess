Class {
	#name : 'CatalystTenantLifecycleV3',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples-Marketplace',
	#package : 'BVC-BPM-Examples',
	#tag : 'Marketplace'
}

{ #category : 'versioning' }
CatalystTenantLifecycleV3 class >> version [
	<publishedVersion>
	^ 3
]

{ #category : 'versioning' }
CatalystTenantLifecycleV3 class >> versionOf [
	^ CatalystTenantLifecycle
]

{ #category : 'model' }
CatalystTenantLifecycleV3 class >> definitions [
	| definitions |
	definitions := CPDefinitions identifier: #tenantLifecycle.
	definitions targetNamespace: 'urn:catalyst:tenant-lifecycle'.
	^ definitions
]

{ #category : 'processes' }
CatalystTenantLifecycleV3 class >> suspendTenant [
	<process: #suspendTenant>
	^ (CPProcess identifier: #suspendTenant)
		label: 'Suspend Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV3 class >> resumeTenant [
	<process: #resumeTenant>
	^ (CPProcess identifier: #resumeTenant)
		label: 'Resume Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV3 class >> removeTenant [
	<process: #removeTenant>
	^ (CPProcess identifier: #removeTenant)
		label: 'Remove Tenant';
		yourself
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV3 class >> suspendTenantOverview [
	<diagram: #suspendTenantOverview process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV3 class >> suspendTenantOperations [
	<diagram: #suspendTenantOperations process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOperations
]


{ #category : 'diagrams' }
CatalystTenantLifecycleV3 class >> resumeTenantOverview [
	<diagram: #resumeTenantOverview process: #resumeTenant>
	^ CPDiagram identifier: #resumeTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV3 class >> removeTenantOverview [
	<diagram: #removeTenantOverview process: #removeTenant>
	^ CPDiagram identifier: #removeTenantOverview
]

{ #category : 'processes' }
CatalystTenantLifecycleV3 class >> provisionTenant [
	<process: #provisionTenant>
	| process registration validate accepted establishTenant establishAdministrator establishTrial provisionServices activateAccess notifyWelcome provisioned rejected flows |
	process := (CPProcess identifier: #provisionTenant)
		label: 'Provision Tenant';
		yourself.
	registration := (CPStartEvent identifier: #tenantRegistrationReceived)
		label: 'Tenant registration received';
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
	(flows at: 1) sourceRef: registration; targetRef: validate.
	(flows at: 2) sourceRef: validate; targetRef: accepted.
	(flows at: 3) label: 'Accepted'; sourceRef: accepted; targetRef: establishTenant.
	(flows at: 4) label: 'Rejected'; sourceRef: accepted; targetRef: rejected.
	(flows at: 5) sourceRef: establishTenant; targetRef: establishAdministrator.
	(flows at: 6) sourceRef: establishAdministrator; targetRef: establishTrial.
	(flows at: 7) sourceRef: establishTrial; targetRef: provisionServices.
	(flows at: 8) sourceRef: provisionServices; targetRef: activateAccess.
	(flows at: 9) sourceRef: activateAccess; targetRef: notifyWelcome.
	(flows at: 10) sourceRef: notifyWelcome; targetRef: provisioned.

	{ registration. validate. accepted. establishTenant. establishAdministrator.
	  establishTrial. provisionServices. activateAccess. notifyWelcome. provisioned. rejected }
		do: [ :each | process addFlowElement: each ].
	flows do: [ :each | process addFlowElement: each ].
	^ process
]

{ #category : 'processes' }
CatalystTenantLifecycleV3 class >> startSubscription [
	<process: #startSubscription>
	^ (CPProcess identifier: #startSubscription)
		label: 'Start Subscription';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV3 class >> changeSubscription [
	<process: #changeSubscription>
	^ (CPProcess identifier: #changeSubscription)
		label: 'Change Subscription';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV3 class >> renewSubscription [
	<process: #renewSubscription>
	^ (CPProcess identifier: #renewSubscription)
		label: 'Renew Subscription';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV3 class >> recoverPayment [
	<process: #recoverPayment>
	^ (CPProcess identifier: #recoverPayment)
		label: 'Recover Payment';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV3 class >> cancelSubscription [
	<process: #cancelSubscription>
	^ (CPProcess identifier: #cancelSubscription)
		label: 'Cancel Subscription';
		yourself
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV3 class >> provisionTenantOverview [
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
		bounds: (472 @ 260 extent: 42 @ 42).
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
