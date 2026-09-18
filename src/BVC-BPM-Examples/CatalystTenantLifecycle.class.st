Class {
	#name : 'CatalystTenantLifecycle',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples-Marketplace',
	#package : 'BVC-BPM-Examples',
	#tag : 'Marketplace'
}

{ #category : 'model' }
CatalystTenantLifecycle class >> definitions [
	| definitions |
	definitions := CPDefinitions identifier: #tenantLifecycle.
	definitions targetNamespace: 'urn:catalyst:tenant-lifecycle'.
	^ definitions
]

{ #category : 'processes' }
CatalystTenantLifecycle class >> suspendTenant [
	<process: #suspendTenant>
	^ (CPProcess identifier: #suspendTenant)
		label: 'Suspend Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycle class >> resumeTenant [
	<process: #resumeTenant>
	^ (CPProcess identifier: #resumeTenant)
		label: 'Resume Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycle class >> removeTenant [
	<process: #removeTenant>
	^ (CPProcess identifier: #removeTenant)
		label: 'Remove Tenant';
		yourself
]

{ #category : 'diagrams' }
CatalystTenantLifecycle class >> suspendTenantOverview [
	<diagram: #suspendTenantOverview process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycle class >> suspendTenantOperations [
	<diagram: #suspendTenantOperations process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOperations
]


{ #category : 'processes' }
CatalystTenantLifecycle class >> createTenant [
	<process: #createTenant>
	^ (CPProcess identifier: #createTenant)
		label: 'Create Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycle class >> upgradeTenant [
	<process: #upgradeTenant>
	^ (CPProcess identifier: #upgradeTenant)
		label: 'Upgrade Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycle class >> expireTenantTrial [
	<process: #expireTenantTrial>
	^ (CPProcess identifier: #expireTenantTrial)
		label: 'Expire Tenant Trial';
		yourself
]

{ #category : 'diagrams' }
CatalystTenantLifecycle class >> createTenantOverview [
	<diagram: #createTenantOverview process: #createTenant>
	^ CPDiagram identifier: #createTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycle class >> upgradeTenantOverview [
	<diagram: #upgradeTenantOverview process: #upgradeTenant>
	^ CPDiagram identifier: #upgradeTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycle class >> expireTenantTrialOverview [
	<diagram: #expireTenantTrialOverview process: #expireTenantTrial>
	^ CPDiagram identifier: #expireTenantTrialOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycle class >> resumeTenantOverview [
	<diagram: #resumeTenantOverview process: #resumeTenant>
	^ CPDiagram identifier: #resumeTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycle class >> removeTenantOverview [
	<diagram: #removeTenantOverview process: #removeTenant>
	^ CPDiagram identifier: #removeTenantOverview
]
