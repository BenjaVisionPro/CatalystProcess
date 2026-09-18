Class {
	#name : 'CustomerTenantLifecycle',
	#superclass : 'CatalystTenantLifecycle',
	#category : 'BVC-BPM-Examples-Marketplace',
	#package : 'BVC-BPM-Examples',
	#tag : 'Marketplace'
}

{ #category : 'processes' }
CustomerTenantLifecycle class >> customerSuspension [
	<process: #suspendTenant>
	^ (CPProcess identifier: #suspendTenant)
		label: 'Customer Suspend Tenant';
		yourself
]

{ #category : 'diagrams' }
CustomerTenantLifecycle class >> customerSuspensionOperations [
	<diagram: #suspendTenantOperations process: #suspendTenant>
	^ CPDiagram identifier: #suspendTenantOperations
]
