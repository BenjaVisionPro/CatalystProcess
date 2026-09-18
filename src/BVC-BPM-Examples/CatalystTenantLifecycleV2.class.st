Class {
	#name : 'CatalystTenantLifecycleV2',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples-Marketplace',
	#package : 'BVC-BPM-Examples',
	#tag : 'Marketplace'
}

{ #category : 'versioning' }
CatalystTenantLifecycleV2 class >> version [
	<publishedVersion>
	^ 2
]

{ #category : 'versioning' }
CatalystTenantLifecycleV2 class >> versionOf [
	^ CatalystTenantLifecycle
]

{ #category : 'model' }
CatalystTenantLifecycleV2 class >> definitions [
	| definitions |
	definitions := CPDefinitions identifier: #tenantLifecycle.
	definitions targetNamespace: 'urn:catalyst:tenant-lifecycle'.
	^ definitions
]

{ #category : 'processes' }
CatalystTenantLifecycleV2 class >> createTenant [
	<process: #createTenant>
	^ (CPProcess identifier: #createTenant)
		label: 'Create Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV2 class >> upgradeTenant [
	<process: #upgradeTenant>
	^ (CPProcess identifier: #upgradeTenant)
		label: 'Upgrade Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV2 class >> expireTenantTrial [
	<process: #expireTenantTrial>
	^ (CPProcess identifier: #expireTenantTrial)
		label: 'Expire Tenant Trial';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV2 class >> suspendTenant [
	<process: #suspendTenant>
	^ (CPProcess identifier: #suspendTenant)
		label: 'Suspend Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV2 class >> resumeTenant [
	<process: #resumeTenant>
	^ (CPProcess identifier: #resumeTenant)
		label: 'Resume Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV2 class >> removeTenant [
	<process: #removeTenant>
	^ (CPProcess identifier: #removeTenant)
		label: 'Remove Tenant';
		yourself
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV2 class >> createTenantOverview [
	<diagram: #createTenantOverview process: #createTenant>
	^ CPDiagram identifier: #createTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV2 class >> upgradeTenantOverview [
	<diagram: #upgradeTenantOverview process: #upgradeTenant>
	^ CPDiagram identifier: #upgradeTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV2 class >> expireTenantTrialOverview [
	<diagram: #expireTenantTrialOverview process: #expireTenantTrial>
	^ CPDiagram identifier: #expireTenantTrialOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV2 class >> suspendTenantOverview [
	<diagram: #suspendTenantOverview process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV2 class >> suspendTenantOperations [
	<diagram: #suspendTenantOperations process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOperations
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV2 class >> resumeTenantOverview [
	<diagram: #resumeTenantOverview process: #resumeTenant>
	^ CPDiagram identifier: #resumeTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV2 class >> removeTenantOverview [
	<diagram: #removeTenantOverview process: #removeTenant>
	^ CPDiagram identifier: #removeTenantOverview
]
