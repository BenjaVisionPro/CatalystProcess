Class {
	#name : 'CPTenantLifecycleSourceExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples-Marketplace',
	#package : 'BVC-BPM-Examples',
	#tag : 'Marketplace'
}

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> marketplaceDefinitions [
	<gtExample>
	| definitions suspend diagrams |
	definitions := CPDefinitionsSourceMaterializer materialize: CatalystTenantLifecycle.

	self assert: definitions identifier equals: #tenantLifecycle.
	self assert: definitions targetNamespace equals: 'urn:catalyst:tenant-lifecycle'.
	self assert: definitions rootElements size equals: 3.
	self assert: definitions diagrams size equals: 2.

	suspend := definitions rootElements
		detect: [ :each | each identifier = #suspendTenant ].
	diagrams := definitions diagrams
		select: [ :each | each plane modelElement == suspend ].
	self assert: diagrams size equals: 2.
	^ definitions
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> customerDefinitionsUseNearestIdentityContribution [
	<gtExample>
	| definitions suspend overview operations |
	definitions := CPDefinitionsSourceMaterializer materialize: CustomerTenantLifecycle.
	suspend := definitions rootElements
		detect: [ :each | each identifier = #suspendTenant ].
	overview := definitions diagrams
		detect: [ :each | each identifier = #suspendTenantOverview ].
	operations := definitions diagrams
		detect: [ :each | each identifier = #suspendTenantOperations ].

	self assert: suspend label equals: 'Customer Suspend Tenant'.
	self assert: overview plane modelElement == suspend.
	self assert: operations plane modelElement == suspend.
	self assert: definitions rootElements size equals: 3.
	self assert: definitions diagrams size equals: 2.
	^ definitions
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> marketplaceSourceOwnership [
	<gtExample>
	self assert: (CPDefinitionsSourceMaterializer
		isLocalProcess: #suspendTenant
		in: CatalystTenantLifecycle).
	self assert: (CPDefinitionsSourceMaterializer
		isLocalDiagram: #suspendTenantOperations
		in: CatalystTenantLifecycle).
	^ CatalystTenantLifecycle
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> customerSourceOwnership [
	<gtExample>
	self assert: (CPDefinitionsSourceMaterializer
		isSpecialisedProcess: #suspendTenant
		in: CustomerTenantLifecycle).
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedProcess: #resumeTenant
		in: CustomerTenantLifecycle).
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedProcess: #removeTenant
		in: CustomerTenantLifecycle).
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedDiagram: #suspendTenantOverview
		in: CustomerTenantLifecycle).
	self assert: (CPDefinitionsSourceMaterializer
		isSpecialisedDiagram: #suspendTenantOperations
		in: CustomerTenantLifecycle).
	^ CustomerTenantLifecycle
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> processSourcePreservesExistingSelector [
	<gtExample>
	| definitions suspend source |
	definitions := CPDefinitionsSourceMaterializer materialize: CustomerTenantLifecycle.
	suspend := definitions rootElements detect: [ :each | each identifier = #suspendTenant ].
	suspend label: 'Changed Customer Suspend Tenant'.
	source := CPDefinitionsSourceMaterializer new
		processSourceFor: suspend
		selector: #customerSuspension.

	self assert: (source beginsWith: 'customerSuspension').
	self assert: (source includesSubstring: '<process: #suspendTenant>').
	self assert: (source includesSubstring: 'Changed Customer Suspend Tenant').
	^ source
]


{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> saveExistingSpecialisedProcessAndReload [
	<gtExample>
	| definitions suspend selector reloaded reloadedSuspend |
	definitions := CPDefinitionsSourceMaterializer materialize: CustomerTenantLifecycle.
	suspend := definitions rootElements
		detect: [ :each | each identifier = #suspendTenant ].

	selector := CPDefinitionsSourceMaterializer
		saveProcess: suspend
		in: CustomerTenantLifecycle.
	self assert: selector equals: #customerSuspension.

	reloaded := CPDefinitionsSourceMaterializer materialize: CustomerTenantLifecycle.
	reloadedSuspend := reloaded rootElements
		detect: [ :each | each identifier = #suspendTenant ].
	self assert: reloadedSuspend identifier equals: #suspendTenant.
	self assert: reloadedSuspend label equals: 'Customer Suspend Tenant'.
	self assert: (CPDefinitionsSourceMaterializer
		isSpecialisedProcess: #suspendTenant
		in: CustomerTenantLifecycle).
	^ reloaded
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> saveInheritedProcessCreatesSpecialisationAndRevertRestoresInheritance [
	<gtExample>
	| definitions resume selector reloaded reloadedResume revertedSelector reverted revertedResume |
	definitions := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedProcess: #resumeTenant
		in: CustomerInheritedTenantLifecycle).

	resume := definitions rootElements
		detect: [ :each | each identifier = #resumeTenant ].
	resume label: 'Customer Resume Tenant'.
	selector := CPDefinitionsSourceMaterializer
		saveProcess: resume
		in: CustomerInheritedTenantLifecycle.
	self assert: selector equals: #resumeTenant.
	self assert: (CPDefinitionsSourceMaterializer
		isSpecialisedProcess: #resumeTenant
		in: CustomerInheritedTenantLifecycle).

	reloaded := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
	reloadedResume := reloaded rootElements
		detect: [ :each | each identifier = #resumeTenant ].
	self assert: reloadedResume label equals: 'Customer Resume Tenant'.

	revertedSelector := CPDefinitionsSourceMaterializer
		revertProcess: #resumeTenant
		in: CustomerInheritedTenantLifecycle.
	self assert: revertedSelector equals: selector.
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedProcess: #resumeTenant
		in: CustomerInheritedTenantLifecycle).

	reverted := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
	revertedResume := reverted rootElements
		detect: [ :each | each identifier = #resumeTenant ].
	self assert: revertedResume label equals: 'Resume Tenant'.
	^ reverted
]
