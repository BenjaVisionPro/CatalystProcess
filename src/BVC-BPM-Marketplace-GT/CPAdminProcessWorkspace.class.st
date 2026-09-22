"I present the bootstrapped Catalyst Process installation to an administrator.

I do not bootstrap Process, construct Runtime, deploy Processes, or reproduce authorization policy. The bootstrap supplies the authoritative installation objects and CPBpmApplication supplies authenticated Process queries and commands. I compose those two existing boundaries for GT presentation."
Class {
	#name : 'CPAdminProcessWorkspace',
	#superclass : 'Object',
	#instVars : [
		'bootstrap',
		'bpmWorkspace'
	],
	#category : 'BVC-BPM-Marketplace-GT',
	#package : 'BVC-BPM-Marketplace-GT'
}

{ #category : 'instance creation' }
CPAdminProcessWorkspace class >> bootstrap: aCPAdminTenantBootstrap application: aCPBpmApplication [
	^ self new
		bootstrap: aCPAdminTenantBootstrap;
		bpmWorkspace: (CPBpmWorkspace application: aCPBpmApplication);
		yourself
]

{ #category : 'accessing' }
CPAdminProcessWorkspace >> bootstrap [
	^ bootstrap
]

{ #category : 'accessing' }
CPAdminProcessWorkspace >> bootstrap: aCPAdminTenantBootstrap [
	bootstrap := aCPAdminTenantBootstrap
]

{ #category : 'accessing' }
CPAdminProcessWorkspace >> bpmWorkspace [
	^ bpmWorkspace
]

{ #category : 'accessing' }
CPAdminProcessWorkspace >> bpmWorkspace: aCPBpmWorkspace [
	bpmWorkspace := aCPBpmWorkspace
]

{ #category : 'private' }
CPAdminProcessWorkspace >> requiredBootstrap [
	bootstrap ifNil: [ self error: 'The Admin Process workspace requires the installation bootstrap.' ].
	^ bootstrap
]

{ #category : 'private' }
CPAdminProcessWorkspace >> requiredBpmWorkspace [
	bpmWorkspace ifNil: [ self error: 'The Admin Process workspace requires a BPM workspace.' ].
	^ bpmWorkspace
]

{ #category : 'accessing' }
CPAdminProcessWorkspace >> systemRoot [
	^ self requiredBootstrap systemRoot
]

{ #category : 'accessing' }
CPAdminProcessWorkspace >> marketplace [
	^ self requiredBootstrap marketplace
]

{ #category : 'accessing' }
CPAdminProcessWorkspace >> adminTenant [
	^ self requiredBootstrap adminTenant
]

{ #category : 'accessing' }
CPAdminProcessWorkspace >> administrator [
	^ self requiredBootstrap adminUser
]

{ #category : 'accessing' }
CPAdminProcessWorkspace >> runtimeConfiguration [
	^ self requiredBootstrap runtimeConfiguration
]

{ #category : 'queries' }
CPAdminProcessWorkspace >> startableProcessDeployments [
	^ self requiredBpmWorkspace application startableProcessDeployments
]

{ #category : 'queries' }
CPAdminProcessWorkspace >> assignedUserTaskWorkItems [
	^ self requiredBpmWorkspace application assignedUserTaskWorkItems
]

{ #category : 'queries' }
CPAdminProcessWorkspace >> claimableUserTaskWorkItems [
	^ self requiredBpmWorkspace application claimableUserTaskWorkItems
]

{ #category : 'commands' }
CPAdminProcessWorkspace >> startProcessDeployment: aCPProcessDeployment [
	^ self requiredBpmWorkspace startProcessDeployment: aCPProcessDeployment
]

{ #category : 'gt - views' }
CPAdminProcessWorkspace >> gtMarketplaceProductsFor: aView [
	<gtView>
	^ aView list
		title: 'Marketplace';
		priority: 10;
		items: [ self marketplace products ]
]

{ #category : 'gt - views' }
CPAdminProcessWorkspace >> gtAdminDeploymentsFor: aView [
	<gtView>
	^ aView list
		title: 'Admin Deployments';
		priority: 20;
		items: [ self adminTenant processDeployments ]
]

{ #category : 'gt - views' }
CPAdminProcessWorkspace >> gtStartableProcessesFor: aView [
	<gtView>
	^ aView list
		title: 'Startable Processes';
		priority: 30;
		items: [ self startableProcessDeployments ]
]

{ #category : 'gt - views' }
CPAdminProcessWorkspace >> gtInboxFor: aView [
	<gtView>
	^ aView list
		title: 'Inbox';
		priority: 40;
		items: [ self assignedUserTaskWorkItems ]
]

{ #category : 'gt - views' }
CPAdminProcessWorkspace >> gtClaimableWorkFor: aView [
	<gtView>
	^ aView list
		title: 'Claimable Work';
		priority: 50;
		items: [ self claimableUserTaskWorkItems ]
]

{ #category : 'gt - views' }
CPAdminProcessWorkspace >> gtRuntimeConfigurationFor: aView [
	<gtView>
	^ aView forward
		title: 'Runtime';
		priority: 60;
		object: [ self runtimeConfiguration ]
]
