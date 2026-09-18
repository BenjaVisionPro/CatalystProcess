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
	| definitions suspend diagrams provision provisionDiagram provisionNodes |
	definitions := CPDefinitionsSourceMaterializer materialize: CatalystTenantLifecycle.

	self assert: definitions identifier equals: #tenantLifecycle.
	self assert: definitions targetNamespace equals: 'urn:catalyst:tenant-lifecycle'.
	self assert: definitions rootElements size equals: 9.
	self assert: definitions diagrams size equals: 5.

	suspend := definitions rootElements
		detect: [ :each | each identifier = #suspendTenant ].
	diagrams := definitions diagrams
		select: [ :each | each plane modelElement == suspend ].
	self assert: diagrams size equals: 2.
	provision := definitions rootElements detect: [ :each | each identifier = #provisionTenant ].
	provisionDiagram := definitions diagrams detect: [ :each | each identifier = #provisionTenantOverview ].
	provisionNodes := provision flowElements reject: [ :each | each isSequenceFlow ].
	self assert: provision label equals: 'Provision Tenant'.
	self assert: provision flowElements size equals: 21.
	self assert: provisionNodes size equals: 11.
	self assert: provisionDiagram plane modelElement == provision.
	provisionDiagram plane elements do: [ :each |
		(each isShape or: [ each isEdge ]) ifTrue: [
			self assert: (provision flowElements identityIncludes: each modelElement) ] ].
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
	self assert: definitions rootElements size equals: 9.
	self assert: definitions diagrams size equals: 5.
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
	self restoreInheritedProcess: #resumeTenant in: CustomerInheritedTenantLifecycle.
	[ definitions := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
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
	^ reverted ] ensure: [
		self restoreInheritedProcess: #resumeTenant in: CustomerInheritedTenantLifecycle ]
]


{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> saveInheritedDiagramCreatesIndependentSpecialisationAndRevertRestoresInheritance [
	<gtExample>
	| definitions diagram process selector reloaded reloadedDiagram reloadedProcess revertedSelector reverted revertedDiagram revertedProcess |
	self restoreInheritedDiagram: #suspendTenantOverview in: CustomerInheritedTenantLifecycle.
	[ 	definitions := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedProcess: #suspendTenant
		in: CustomerInheritedTenantLifecycle).
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedDiagram: #suspendTenantOverview
		in: CustomerInheritedTenantLifecycle).

	diagram := definitions diagrams
		detect: [ :each | each identifier = #suspendTenantOverview ].
	process := diagram plane modelElement.
	selector := CPDefinitionsSourceMaterializer
		saveDiagram: diagram
		in: CustomerInheritedTenantLifecycle.
	self assert: selector equals: #suspendTenantOverview.
	self assert: (CPDefinitionsSourceMaterializer
		isSpecialisedDiagram: #suspendTenantOverview
		in: CustomerInheritedTenantLifecycle).
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedProcess: #suspendTenant
		in: CustomerInheritedTenantLifecycle).

	reloaded := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
	reloadedDiagram := reloaded diagrams
		detect: [ :each | each identifier = #suspendTenantOverview ].
	reloadedProcess := reloaded rootElements
		detect: [ :each | each identifier = #suspendTenant ].
	self assert: reloadedDiagram plane modelElement == reloadedProcess.
	self assert: reloadedProcess label equals: process label.

	revertedSelector := CPDefinitionsSourceMaterializer
		revertDiagram: #suspendTenantOverview
		in: CustomerInheritedTenantLifecycle.
	self assert: revertedSelector equals: selector.
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedDiagram: #suspendTenantOverview
		in: CustomerInheritedTenantLifecycle).
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedProcess: #suspendTenant
		in: CustomerInheritedTenantLifecycle).

	reverted := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
	revertedDiagram := reverted diagrams
		detect: [ :each | each identifier = #suspendTenantOverview ].
	revertedProcess := reverted rootElements
		detect: [ :each | each identifier = #suspendTenant ].
	self assert: revertedDiagram plane modelElement == revertedProcess.
	^ reverted ] ensure: [
		self restoreInheritedDiagram: #suspendTenantOverview in: CustomerInheritedTenantLifecycle ]
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> atelierMementoSaveWritesSourceThenCommitsModel [
	<gtExample>
	| definitions root context resume resumeMemento selectors reloaded reloadedResume |
	self restoreInheritedProcess: #resumeTenant in: CustomerInheritedTenantLifecycle.
	[ 	definitions := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
	root := CFMaMemento model: definitions.
	context := CPDefinitionsMementoContext memento: root.
	resume := context rootElements detect: [ :each | each identifier = #resumeTenant ].
	resumeMemento := context mementoForRootElement: resume.
	self assert: resumeMemento class equals: CFMaMemento.
	resumeMemento write: 'Customer Resume Tenant' using: resume labelDescription.

	self assert: resume label equals: 'Resume Tenant'.
	selectors := CPDefinitionsSourceMaterializer
		saveMemento: root
		in: CustomerInheritedTenantLifecycle.
	self assert: selectors size equals: 1.
	self assert: selectors first equals: #resumeTenant.
	self assert: resume label equals: 'Customer Resume Tenant'.
	self assert: (CPDefinitionsSourceMaterializer
		isSpecialisedProcess: #resumeTenant
		in: CustomerInheritedTenantLifecycle).

	reloaded := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
	reloadedResume := reloaded rootElements detect: [ :each | each identifier = #resumeTenant ].
	self assert: reloadedResume label equals: 'Customer Resume Tenant'.

	^ reloaded ] ensure: [
		self restoreInheritedProcess: #resumeTenant in: CustomerInheritedTenantLifecycle ]
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> sourceBackedMementoCommitWritesSourceAndCommitsModel [
	<gtExample>
	| definitions root context resume resumeMemento reloaded reloadedResume |
	self restoreInheritedProcess: #resumeTenant in: CustomerInheritedTenantLifecycle.
	[ 	definitions := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
	root := CPDefinitionsSourceMemento
		model: definitions
		sourceClass: CustomerInheritedTenantLifecycle.
	context := CPDefinitionsMementoContext memento: root.
	resume := context rootElements detect: [ :each | each identifier = #resumeTenant ].
	resumeMemento := context mementoForRootElement: resume.
	self assert: resumeMemento class equals: CFMaMemento.
	resumeMemento write: 'Customer Resume Tenant' using: resume labelDescription.

	self assert: resume label equals: 'Resume Tenant'.
	root commit.
	self assert: resume label equals: 'Customer Resume Tenant'.
	self assert: (CPDefinitionsSourceMaterializer
		isSpecialisedProcess: #resumeTenant
		in: CustomerInheritedTenantLifecycle).

	reloaded := CPDefinitionsSourceMaterializer materialize: CustomerInheritedTenantLifecycle.
	reloadedResume := reloaded rootElements detect: [ :each | each identifier = #resumeTenant ].
	self assert: reloadedResume label equals: 'Customer Resume Tenant'.

	^ reloaded ] ensure: [
		self restoreInheritedProcess: #resumeTenant in: CustomerInheritedTenantLifecycle ]
]


{ #category : 'private - source fixtures' }
CPTenantLifecycleSourceExamples >> restoreInheritedProcess: anIdentifier in: aSourceClass [
	(CPDefinitionsSourceMaterializer
		isSpecialisedProcess: anIdentifier
		in: aSourceClass) ifTrue: [
		CPDefinitionsSourceMaterializer
			revertProcess: anIdentifier
			in: aSourceClass ]
]

{ #category : 'private - source fixtures' }
CPTenantLifecycleSourceExamples >> restoreInheritedDiagram: anIdentifier in: aSourceClass [
	(CPDefinitionsSourceMaterializer
		isSpecialisedDiagram: anIdentifier
		in: aSourceClass) ifTrue: [
		CPDefinitionsSourceMaterializer
			revertDiagram: anIdentifier
			in: aSourceClass ]
]

{ #category : 'examples - marketplace versions' }
CPTenantLifecycleSourceExamples >> publishedVersionIsSelfContainedAndVersioned [
	<gtExample>
	| definitions |
	definitions := CPDefinitionsSourceMaterializer materialize: CatalystTenantLifecycleV1.
	self assert: CatalystTenantLifecycleV1 version equals: 1.
	self assert: (CPDefinitionsSourceMaterializer isPublishedVersion: CatalystTenantLifecycleV1).
	self assert: (CPDefinitionsSourceMaterializer versionOf: CatalystTenantLifecycleV1) equals: CatalystTenantLifecycle.
	self assert: CatalystTenantLifecycleV1 superclass equals: Object.
	self assert: definitions identifier equals: #tenantLifecycle.
	self assert: definitions rootElements size equals: 9.
	self assert: definitions diagrams size equals: 6.
	^ definitions
]

{ #category : 'examples - marketplace versions' }
CPTenantLifecycleSourceExamples >> workingDefinitionCanDeriveFromPublishedVersion [
	<gtExample>
	| definitions |
	definitions := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
	self assert: (CPDefinitionsSourceMaterializer isPublishedVersion: CustomerVersionedTenantLifecycle) not.
	self assert: CustomerVersionedTenantLifecycle superclass equals: CatalystTenantLifecycleV1.
	self assert: (CPDefinitionsSourceMaterializer
		isInheritedProcess: #suspendTenant
		in: CustomerVersionedTenantLifecycle).
	self assert: definitions rootElements size equals: 9.
	^ definitions
]

{ #category : 'examples - marketplace bootstrap' }
CPTenantLifecycleSourceExamples >> adminTenantLifecycleAtelier [
	<gtExample>
	^ self adminTenantLifecycleDefinition
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> startSubscriptionIsMaterialisedAsBpmn [
	<gtExample>
	| definitions process diagram |
	definitions := CPDefinitionsSourceMaterializer materialize: CatalystTenantLifecycle.
	process := definitions rootElements
		detect: [ :each | each identifier = #startSubscription ].
	diagram := definitions diagrams
		detect: [ :each | each identifier = #startSubscriptionOverview ].
	self assert: process flowElements size equals: 22.
	self assert: (process flowElements count: [ :each | each isFlowNode ]) equals: 11.
	self assert: (process flowElements count: [ :each | each isSequenceFlow ]) equals: 11.
	self assert: diagram plane modelElement == process.
	^ diagram
]
