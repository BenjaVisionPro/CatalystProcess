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
		'tenantLifecyclePublishedDefinition',
		'adminTenant',
		'adminUser',
		'adminMembership',
		'tenantLifecycleDefinitions',
		'tenantLifecycleDeployment',
		'bpmServiceConfiguration',
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
	| process topology host deployment |
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
	tenantLifecycleLicence
		addFeature: CPMarketplaceUseFeature new;
		addFeature: CPMarketplaceAdaptFeature new;
		addFeature: CPMarketplacePublishDerivativeFeature new.
	marketplace addLicence: tenantLifecycleLicence.

	tenantLifecyclePublishedDefinition := self establishAdminTenantLifecyclePublication.
	marketplace addPublishedDefinition: tenantLifecyclePublishedDefinition.
	tenantLifecycleDefinitions := CPDefinitionsSourceMaterializer materialize: tenantLifecyclePublishedDefinition.
	process := tenantLifecycleDefinitions rootElements
		detect: [ :each | each identifier = #provisionTenant ]
		ifNone: [ self error: 'Admin Tenant Lifecycle does not define provisionTenant.' ].
	tenantLifecycleDeployment := CPProcessDeployment new
		label: 'Admin Tenant Lifecycle - Provision Tenant';
		tenant: adminTenant;
		processKey: #provisionTenant;
		version: tenantLifecyclePublishedDefinition version;
		processDefinition: process;
		deployedBy: adminUser;
		deployedAt: DateAndTime now;
		yourself.
	adminTenant addProcessDeployment: tenantLifecycleDeployment.
	systemRoot addProcessDeployment: tenantLifecycleDeployment.
	tenantLifecycleDeployment
		authorizeStartFor: adminUser;
		activate.

	bpmServiceConfiguration := CPBpmServiceConfiguration new
		systemRoot: systemRoot;
		yourself.

	host := CRHostConfiguration new
		identifier: #adminHost;
		label: 'Admin Host';
		address: 'local';
		maxProcesses: 1;
		services: { bpmServiceConfiguration identifier };
		yourself.
	topology := CRTopologyConfiguration new
		label: 'Admin Local Topology';
		hosts: { host };
		placementStrategyConfiguration: CRFirstAvailablePlacementStrategyConfiguration new;
		yourself.
	deployment := CRDeploymentConfiguration new
		serviceDeployments: {
			CRServiceDeploymentConfiguration new
				serviceIdentifier: bpmServiceConfiguration identifier;
				label: 'BPM Service';
				initialCount: 1;
				yourself } asOrderedCollection;
		yourself.
	runtimeConfiguration := CRRuntimeConfiguration new
		label: 'Catalyst Process Admin';
		services: { bpmServiceConfiguration } asOrderedCollection;
		topology: topology;
		deployment: deployment;
		yourself
]


{ #category : 'configuration - marketplace' }
CPAdminTenantBootstrap >> establishAdminTenantLifecyclePublication [
	| publications |
	publications := (Pragma allNamed: #publishedVersion)
		collect: [ :aPragma | aPragma methodClass instanceSide ]
		thenSelect: [ :each |
			each ~~ AdminTenantLifecycle
				and: [ each versionOf = AdminTenantLifecycle ] ].
	publications size > 1 ifTrue: [
		self error: 'Bootstrap requires one canonical Admin Tenant Lifecycle publication.' ].
	^ publications
		ifEmpty: [ CPDefinitionsSourceMaterializer publish: AdminTenantLifecycle ]
		ifNotEmpty: [ publications first ]
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
CPAdminTenantBootstrap >> tenantLifecyclePublishedDefinition [
	^ tenantLifecyclePublishedDefinition
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
CPAdminTenantBootstrap >> tenantLifecycleDeployment [
	^ tenantLifecycleDeployment
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> bpmServiceConfiguration [
	^ bpmServiceConfiguration
]

{ #category : 'accessing' }
CPAdminTenantBootstrap >> runtimeConfiguration [
	^ runtimeConfiguration
]
