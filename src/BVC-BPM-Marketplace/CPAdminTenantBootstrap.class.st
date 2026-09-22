"I construct the initial Catalyst Process application state for the administrative tenant.

I am application bootstrap, not BPMN execution semantics. I create the persistent domain objects that exist before the first user interaction, materialize and activate the Admin Tenant Lifecycle deployment, authorize the bootstrap administrator to start it, and expose the Runtime configuration that hosts CPBpmService over that same system root."
Class {
	#name : 'CPAdminTenantBootstrap',
	#superclass : 'Object',
	#instVars : [
		'systemRoot',
		'marketplace',
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

	tenantLifecycleDefinitions := CPDefinitionsSourceMaterializer materialize: AdminTenantLifecycle.
	process := tenantLifecycleDefinitions rootElements
		detect: [ :each | each identifier = #provisionTenant ]
		ifNone: [ self error: 'Admin Tenant Lifecycle does not define provisionTenant.' ].
	tenantLifecycleDeployment := CPProcessDeployment new
		label: 'Admin Tenant Lifecycle - Provision Tenant';
		tenant: adminTenant;
		processKey: #provisionTenant;
		version: CatalystTenantLifecycleV1 version;
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

{ #category : 'accessing' }
CPAdminTenantBootstrap >> marketplace [
	^ marketplace
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
