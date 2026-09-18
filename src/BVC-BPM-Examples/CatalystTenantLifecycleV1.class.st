Class {
	#name : 'CatalystTenantLifecycleV1',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples-Marketplace',
	#package : 'BVC-BPM-Examples',
	#tag : 'Marketplace'
}

{ #category : 'versioning' }
CatalystTenantLifecycleV1 class >> version [
	<publishedVersion>
	^ 1
]

{ #category : 'versioning' }
CatalystTenantLifecycleV1 class >> versionOf [
	^ CatalystTenantLifecycle
]

{ #category : 'model' }
CatalystTenantLifecycleV1 class >> definitions [
	| definitions |
	definitions := CPDefinitions identifier: #tenantLifecycle.
	definitions targetNamespace: 'urn:catalyst:tenant-lifecycle'.
	^ definitions
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> suspendTenant [
	<process: #suspendTenant>
	^ (CPProcess identifier: #suspendTenant)
		label: 'Suspend Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> resumeTenant [
	<process: #resumeTenant>
	^ (CPProcess identifier: #resumeTenant)
		label: 'Resume Tenant';
		yourself
]

{ #category : 'processes' }
CatalystTenantLifecycleV1 class >> removeTenant [
	<process: #removeTenant>
	^ (CPProcess identifier: #removeTenant)
		label: 'Remove Tenant';
		yourself
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV1 class >> suspendTenantOverview [
	<diagram: #suspendTenantOverview process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOverview
]

{ #category : 'diagrams' }
CatalystTenantLifecycleV1 class >> suspendTenantOperations [
	<diagram: #suspendTenantOperations process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOperations
]
