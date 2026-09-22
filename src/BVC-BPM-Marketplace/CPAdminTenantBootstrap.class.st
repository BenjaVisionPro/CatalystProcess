"I construct the initial Catalyst Process application state for the administrative tenant.

I am application bootstrap, not BPMN execution semantics. I create the persistent domain objects that exist before the first user interaction, materialize and activate the Admin Tenant Lifecycle deployment, authorize the bootstrap administrator to start it, and expose the Runtime configuration that hosts CPBpmService over that same system root."
Class {
	#name : 'CPAdminTenantBootstrap',
	#superclass : 'Object',
	#instVars : [
		'systemRoot',
		'marketplace',
		'tenantLifecycleProduct',
		'tenantLifecycleLicence',
		'adminTenant',
		'adminUser',
		'adminMembership',
		'tenantLifecycleDefinitions',
		'tenantLifecycleDeployment',
		'tenantLifecycleRelease',
		'bpmServiceConfiguration',
		'executionEnvironment',
		'runtimeConfiguration'
	],
	#category : 'BVC-BPM-Marketplace-Bootstrap',
	#package : 'BVC-BPM-Marketplace',
	#tag : 'Bootstrap'
}

{ #category : 'instance creation' }
CPAdminTenantBootstrap class >> configured [
	^ self new configure; yourself
]

{ #category : 'configuration' }
CPAdminTenantBootstrap >> configure [
	| process orchestration topology host deployment |
	systemRoot := CPSystemRoot new
		label: 'Catalyst Process';
		yourself.
	marketplace := CPMarketplace new
		label: 'Catalyst Marketplace';
		yourself.
	marketplace addPublishedDefinition: CatalystTenantLifecycleV1.
	tenantLifecycleProduct := CPMarketplaceProduct new
		label: 'Tenant Lifecycle';
		yourself.
	tenantLifecycleProduct addPublishedDefinition: CatalystTenantLifecycleV1.
	marketplace addProduct: tenantLifecycleProduct.
	systemRoot marketplace: marketplace.
	adminTenant := CPTenant new
		label: 'Admin';
		yourself.
	adminUser := CPUser new
		label: 'Administrator';
		yourself.
	systemRoot
		addTenant: adminTenant;
		addUser: adminUser.
	adminMembership := CPTenantMembership tenant: adminTenant user: adminUser.
	tenantLifecycleLicence := CPMarketplaceLicence new
		tenant: adminTenant;
		product: tenantLifecycleProduct;
		yourself.
	tenantLifecycleLicence addFeature: CPMarketplaceUseFeature new.
	marketplace addLicence: tenantLifecycleLicence.

	tenantLifecycleDefinitions := CPDefinitionsSourceMaterializer materialize: CatalystTenantLifecycleV1.
	process := tenantLifecycleDefinitions rootElements
		detect: [ :each | each identifier = #provisionTenant ]
		ifNone: [ self error: 'Marketplace Tenant Lifecycle does not define provisionTenant.' ].
	tenantLifecycleRelease := CPOperationalRelease new
		label: 'Tenant Lifecycle V1 - Admin';
		publishedDefinition: CatalystTenantLifecycleV1;
		definitions: tenantLifecycleDefinitions;
		release.
	tenantLifecycleDeployment := CPProcessDeployment new
		label: 'Admin Tenant Lifecycle - Provision Tenant';
		tenant: adminTenant;
		processKey: #provisionTenant;
		version: CatalystTenantLifecycleV1 version;
		processDefinition: process;
		operationalRelease: tenantLifecycleRelease;
		deployedBy: adminUser;
		deployedAt: DateAndTime now;
		yourself.
	adminTenant addProcessDeployment: tenantLifecycleDeployment.
	systemRoot addProcessDeployment: tenantLifecycleDeployment.
	tenantLifecycleDeployment
		authorizeStartFor: adminUser;
		activate.

	executionEnvironment := CPBpmExecutionEnvironment new.
	runtimeConfiguration := CRRuntimeConfiguration new
		label: 'Catalyst Process Admin';
		yourself.
	bpmServiceConfiguration := (CPBpmServiceConfiguration withParent: runtimeConfiguration)
		systemRoot: systemRoot;
		executionEnvironment: executionEnvironment;
		yourself.
	orchestration := CROrchestrationConfiguration defaultWithParent: runtimeConfiguration.

	topology := CRTopologyConfiguration defaultWithParent: runtimeConfiguration.
	topology
		label: 'Admin Local Topology';
		placementStrategyConfiguration: (CRFirstAvailablePlacementStrategyConfiguration defaultWithParent: topology).
	host := CRHostConfiguration defaultWithParent: topology.
	host
		identifier: #adminHost;
		label: 'Admin Host';
		address: 'local';
		maxProcesses: 2;
		services: { orchestration identifier. bpmServiceConfiguration identifier }.
	topology hosts: { host }.

	deployment := CRDeploymentConfiguration defaultWithParent: runtimeConfiguration.
	deployment serviceDeployments: {
		(CRServiceDeploymentConfiguration defaultWithParent: deployment)
			serviceIdentifier: orchestration identifier;
			label: 'Orchestration Service';
			initialCount: 1;
			yourself.
		(CRServiceDeploymentConfiguration defaultWithParent: deployment)
			serviceIdentifier: bpmServiceConfiguration identifier;
			label: 'BPM Service';
			initialCount: 1;
			yourself }.
	runtimeConfiguration
		services: { orchestration. bpmServiceConfiguration } asOrderedCollection;
		topology: topology;
		deployment: deployment

]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> marketplace [
	^ marketplace
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> tenantLifecycleProduct [
	^ tenantLifecycleProduct
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> tenantLifecycleLicence [
	^ tenantLifecycleLicence
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> systemRoot [
	^ systemRoot
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> adminTenant [
	^ adminTenant
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> adminUser [
	^ adminUser
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> adminMembership [
	^ adminMembership
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> tenantLifecycleDefinitions [
	^ tenantLifecycleDefinitions
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> tenantLifecycleRelease [
	^ tenantLifecycleRelease
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> tenantLifecycleDeployment [
	^ tenantLifecycleDeployment
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> bpmServiceConfiguration [
	^ bpmServiceConfiguration
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> executionEnvironment [
	^ executionEnvironment
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> runtimeConfiguration [
	^ runtimeConfiguration
]
