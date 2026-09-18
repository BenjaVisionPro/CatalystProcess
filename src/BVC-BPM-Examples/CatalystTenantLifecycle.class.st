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
