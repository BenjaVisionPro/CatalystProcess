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
	| definitions suspend diagrams provision provisionDiagram |
	definitions := CPDefinitionsSourceMaterializer materialize: CatalystTenantLifecycle.

	self assert: definitions identifier equals: #tenantLifecycle.
	self assert: definitions targetNamespace equals: 'urn:catalyst:tenant-lifecycle'.

	suspend := definitions rootElements
		detect: [ :each | each identifier = #suspendTenant ].
	diagrams := definitions diagrams
		select: [ :each | each plane modelElement == suspend ].
	provision := definitions rootElements detect: [ :each | each identifier = #provisionTenant ].
	provisionDiagram := definitions diagrams detect: [ :each | each identifier = #provisionTenantOverview ].
	self assert: provision label equals: 'Provision Tenant'.
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
	^ definitions
]


{ #category : 'examples - marketplace bootstrap' }
CPTenantLifecycleSourceExamples >> customerVersionedTenantLifecycleDefinition [
	<gtExample>
	| definitions |
	definitions := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
	self assert: CustomerVersionedTenantLifecycle superclass = CatalystTenantLifecycleV1.
	self assert: (CPDefinitionsSourceMaterializer isPublishedVersion: CustomerVersionedTenantLifecycle) not.
	self assert: (definitions rootElements anySatisfy: [ :each |
		each identifier = #tenantRegistrationOperations ]).
	^ definitions
]

{ #category : 'examples - marketplace bootstrap' }
CPTenantLifecycleSourceExamples >> customerVersionedTenantLifecycleAtelier [
	<gtExample>
	^ self customerVersionedTenantLifecycleDefinition
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
	self assert: diagram plane modelElement == process.
	^ diagram
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> saveInheritedStartSubscriptionGraphAndRevert [
	<gtExample>
	| definitions subscription selector reloaded restored |
	[
		self restoreInheritedProcess: #startSubscription in: CustomerVersionedTenantLifecycle.
		definitions := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		subscription := definitions rootElements
			detect: [ :each | each identifier = #startSubscription ].
		subscription label: 'Admin Start Subscription'.

		selector := CPDefinitionsSourceMaterializer
			saveProcess: subscription
			in: CustomerVersionedTenantLifecycle.
		self assert: selector equals: #startSubscription.
		self assert: (CPDefinitionsSourceMaterializer
			isSpecialisedProcess: #startSubscription
			in: CustomerVersionedTenantLifecycle).

		reloaded := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		subscription := reloaded rootElements
			detect: [ :each | each identifier = #startSubscription ].
		self assert: subscription label equals: 'Admin Start Subscription'.

		CPDefinitionsSourceMaterializer
			revertProcess: #startSubscription
			in: CustomerVersionedTenantLifecycle.
		restored := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		subscription := restored rootElements
			detect: [ :each | each identifier = #startSubscription ].
		self assert: subscription label equals: 'Start Subscription'.
		^ restored
	] ensure: [
		self restoreInheritedProcess: #startSubscription in: CustomerVersionedTenantLifecycle ]
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> saveInheritedStartSubscriptionDiagramAndRevert [
	<gtExample>
	| definitions diagram selector reloaded restored |
	[
		self restoreInheritedDiagram: #startSubscriptionOverview in: CustomerVersionedTenantLifecycle.
		definitions := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		diagram := definitions diagrams
			detect: [ :each | each identifier = #startSubscriptionOverview ].
		selector := CPDefinitionsSourceMaterializer
			saveDiagram: diagram
			in: CustomerVersionedTenantLifecycle.
		self assert: selector equals: #startSubscriptionOverview.
		self assert: (CPDefinitionsSourceMaterializer
			isSpecialisedDiagram: #startSubscriptionOverview
			in: CustomerVersionedTenantLifecycle).
		reloaded := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		diagram := reloaded diagrams
			detect: [ :each | each identifier = #startSubscriptionOverview ].
		CPDefinitionsSourceMaterializer
			revertDiagram: #startSubscriptionOverview
			in: CustomerVersionedTenantLifecycle.
		restored := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		self assert: (restored diagrams anySatisfy: [ :each |
			each identifier = #startSubscriptionOverview ]).
		^ restored
	] ensure: [
		self restoreInheritedDiagram: #startSubscriptionOverview in: CustomerVersionedTenantLifecycle ]
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> sourceBackedMementoSavesProcessAndDiagramTogether [
	<gtExample>
	| definitions root context process processMemento diagram diagramMemento selectors reloaded |
	[
		self restoreInheritedProcess: #startSubscription in: CustomerVersionedTenantLifecycle.
		self restoreInheritedDiagram: #startSubscriptionOverview in: CustomerVersionedTenantLifecycle.
		definitions := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		root := CPDefinitionsSourceMemento model: definitions sourceClass: CustomerVersionedTenantLifecycle.
		context := CPDefinitionsMementoContext memento: root.
		process := definitions rootElements detect: [ :each | each identifier = #startSubscription ].
		processMemento := context mementoForRootElement: process.
		processMemento write: 'Admin Start Subscription' using: process labelDescription.
		diagram := definitions diagrams detect: [ :each | each identifier = #startSubscriptionOverview ].
		diagramMemento := context mementoForDiagram: diagram.
		diagramMemento
			write: (CPPlane new
				modelElement: diagram plane modelElement;
				elements: diagram plane elements copy;
				yourself)
			using: diagram planeDescription.
		selectors := CPDefinitionsSourceMaterializer new
			saveSourceChangesFromMemento: root
			in: CustomerVersionedTenantLifecycle.
		self assert: (selectors includes: #startSubscription).
		self assert: (selectors includes: #startSubscriptionOverview).
		reloaded := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		self assert: ((reloaded rootElements detect: [ :each | each identifier = #startSubscription ]) label)
			equals: 'Admin Start Subscription'.
		^ reloaded
	] ensure: [
		self restoreInheritedDiagram: #startSubscriptionOverview in: CustomerVersionedTenantLifecycle.
		self restoreInheritedProcess: #startSubscription in: CustomerVersionedTenantLifecycle ]
]

{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> sourceBackedMementoAddsAndRemovesLocalProcess [
	<gtExample>
	| definitions root context localProcess staged reloaded |
	[
		(CustomerVersionedTenantLifecycle class includesSelector: #reviewTenantAccess)
			ifTrue: [ CustomerVersionedTenantLifecycle class removeSelector: #reviewTenantAccess ].
		definitions := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		root := CPDefinitionsSourceMemento model: definitions sourceClass: CustomerVersionedTenantLifecycle.
		context := CPDefinitionsMementoContext memento: root.
		localProcess := (CPProcess identifier: #reviewTenantAccess)
			label: 'Review Tenant Access';
			yourself.
		staged := context rootElements copyWith: localProcess.
		context writeRootElements: staged.
		CPDefinitionsSourceMaterializer new
			saveSourceChangesFromMemento: root
			in: CustomerVersionedTenantLifecycle.
		reloaded := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		self assert: (reloaded rootElements anySatisfy: [ :each | each identifier = #reviewTenantAccess ]).

		root := CPDefinitionsSourceMemento model: reloaded sourceClass: CustomerVersionedTenantLifecycle.
		context := CPDefinitionsMementoContext memento: root.
		staged := context rootElements reject: [ :each | each identifier = #reviewTenantAccess ].
		context writeRootElements: staged.
		CPDefinitionsSourceMaterializer new
			saveSourceChangesFromMemento: root
			in: CustomerVersionedTenantLifecycle.
		reloaded := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		self assert: (reloaded rootElements anySatisfy: [ :each | each identifier = #reviewTenantAccess ]) not.
		^ reloaded
	] ensure: [
		(CustomerVersionedTenantLifecycle class includesSelector: #reviewTenantAccess)
			ifTrue: [ CustomerVersionedTenantLifecycle class removeSelector: #reviewTenantAccess ] ]
]


{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> sourceBackedMementoAddsAndRemovesLocalProcessWithDiagram [
	<gtExample>
	| definitions root context process start finish flow diagram shape edge roots diagrams reloaded |
	[
		(CustomerVersionedTenantLifecycle class includesSelector: #reviewTenantAccessOverview)
			ifTrue: [ CustomerVersionedTenantLifecycle class removeSelector: #reviewTenantAccessOverview ].
		(CustomerVersionedTenantLifecycle class includesSelector: #reviewTenantAccess)
			ifTrue: [ CustomerVersionedTenantLifecycle class removeSelector: #reviewTenantAccess ].
		definitions := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		root := CPDefinitionsSourceMemento model: definitions sourceClass: CustomerVersionedTenantLifecycle.
		context := CPDefinitionsMementoContext memento: root.

		process := (CPProcess identifier: #reviewTenantAccess)
			label: 'Review Tenant Access';
			yourself.
		start := (CPStartEvent identifier: #reviewRequested)
			label: 'Review requested';
			yourself.
		finish := (CPEndEvent identifier: #reviewCompleted)
			label: 'Review completed';
			yourself.
		flow := CPSequenceFlow identifier: #reviewToCompletion.
		flow sourceRef: start.
		flow targetRef: finish.
		process addFlowElement: start; addFlowElement: finish; addFlowElement: flow.

		diagram := CPDiagram identifier: #reviewTenantAccessOverview.
		shape := CPShape new modelElement: start; bounds: (80 @ 120 extent: 42 @ 42); yourself.
		diagram addElement: shape.
		shape := CPShape new modelElement: finish; bounds: (220 @ 120 extent: 42 @ 42); yourself.
		diagram addElement: shape.
		edge := CPEdge new modelElement: flow; yourself.
		edge addWaypoint: 122 @ 141; addWaypoint: 220 @ 141.
		diagram addElement: edge.
		diagram plane modelElement: process.

		roots := context rootElements copyWith: process.
		diagrams := context diagrams copyWith: diagram.
		context writeRootElements: roots.
		context writeDiagrams: diagrams.
		CPDefinitionsSourceMaterializer new
			saveSourceChangesFromMemento: root
			in: CustomerVersionedTenantLifecycle.

		reloaded := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		self assert: (reloaded rootElements anySatisfy: [ :each | each identifier = #reviewTenantAccess ]).
		self assert: (reloaded diagrams anySatisfy: [ :each | each identifier = #reviewTenantAccessOverview ]).
		diagram := reloaded diagrams detect: [ :each | each identifier = #reviewTenantAccessOverview ].
		self assert: diagram plane modelElement identifier equals: #reviewTenantAccess.

		root := CPDefinitionsSourceMemento model: reloaded sourceClass: CustomerVersionedTenantLifecycle.
		context := CPDefinitionsMementoContext memento: root.
		diagrams := context diagrams reject: [ :each | each identifier = #reviewTenantAccessOverview ].
		roots := context rootElements reject: [ :each | each identifier = #reviewTenantAccess ].
		context writeDiagrams: diagrams.
		context writeRootElements: roots.
		CPDefinitionsSourceMaterializer new
			saveSourceChangesFromMemento: root
			in: CustomerVersionedTenantLifecycle.
		reloaded := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		self assert: (reloaded rootElements anySatisfy: [ :each | each identifier = #reviewTenantAccess ]) not.
		self assert: (reloaded diagrams anySatisfy: [ :each | each identifier = #reviewTenantAccessOverview ]) not.
		^ reloaded
	] ensure: [
		(CustomerVersionedTenantLifecycle class includesSelector: #reviewTenantAccessOverview)
			ifTrue: [ CustomerVersionedTenantLifecycle class removeSelector: #reviewTenantAccessOverview ].
		(CustomerVersionedTenantLifecycle class includesSelector: #reviewTenantAccess)
			ifTrue: [ CustomerVersionedTenantLifecycle class removeSelector: #reviewTenantAccess ] ]
]


{ #category : 'examples - marketplace source' }
CPTenantLifecycleSourceExamples >> sourceBackedCommitAddsProcessAndDiagramToModelAndSource [
	<gtExample>
	| definitions root context process start finish flow diagram shape edge reloaded |
	[
		(CustomerVersionedTenantLifecycle class includesSelector: #inspectTenantAccessOverview)
			ifTrue: [ CustomerVersionedTenantLifecycle class removeSelector: #inspectTenantAccessOverview ].
		(CustomerVersionedTenantLifecycle class includesSelector: #inspectTenantAccess)
			ifTrue: [ CustomerVersionedTenantLifecycle class removeSelector: #inspectTenantAccess ].

		definitions := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		root := CPDefinitionsSourceMemento
			model: definitions
			sourceClass: CustomerVersionedTenantLifecycle.
		context := CPDefinitionsMementoContext memento: root.

		process := (CPProcess identifier: #inspectTenantAccess)
			label: 'Inspect Tenant Access';
			yourself.
		start := (CPStartEvent identifier: #inspectionRequested)
			label: 'Inspection requested';
			yourself.
		finish := (CPEndEvent identifier: #inspectionCompleted)
			label: 'Inspection completed';
			yourself.
		flow := CPSequenceFlow identifier: #inspectionToCompletion.
		flow sourceRef: start.
		flow targetRef: finish.
		process
			addFlowElement: start;
			addFlowElement: finish;
			addFlowElement: flow.

		diagram := CPDiagram identifier: #inspectTenantAccessOverview.
		shape := CPShape new
			modelElement: start;
			bounds: (80 @ 120 extent: 42 @ 42);
			yourself.
		diagram addElement: shape.
		shape := CPShape new
			modelElement: finish;
			bounds: (220 @ 120 extent: 42 @ 42);
			yourself.
		diagram addElement: shape.
		edge := CPEdge new modelElement: flow; yourself.
		edge
			addWaypoint: 122 @ 141;
			addWaypoint: 220 @ 141.
		diagram addElement: edge.
		diagram plane modelElement: process.

		context writeRootElements: (context rootElements copyWith: process).
		context writeDiagrams: (context diagrams copyWith: diagram).

		self assert: (definitions rootElements identityIncludes: process) not.
		self assert: (definitions diagrams identityIncludes: diagram) not.

		self assert: ((root commit) includes: #inspectTenantAccess).
		self assert: (definitions rootElements identityIncludes: process).
		self assert: (definitions diagrams identityIncludes: diagram).
		self assert: (CPDefinitionsSourceMaterializer
			isLocalProcess: #inspectTenantAccess
			in: CustomerVersionedTenantLifecycle).
		self assert: (CPDefinitionsSourceMaterializer
			isLocalDiagram: #inspectTenantAccessOverview
			in: CustomerVersionedTenantLifecycle).

		reloaded := CPDefinitionsSourceMaterializer materialize: CustomerVersionedTenantLifecycle.
		self assert: (reloaded rootElements anySatisfy: [ :each |
			each identifier = #inspectTenantAccess ]).
		self assert: (reloaded diagrams anySatisfy: [ :each |
			each identifier = #inspectTenantAccessOverview ]).
		^ reloaded
	] ensure: [
		(CustomerVersionedTenantLifecycle class includesSelector: #inspectTenantAccessOverview)
			ifTrue: [ CustomerVersionedTenantLifecycle class removeSelector: #inspectTenantAccessOverview ].
		(CustomerVersionedTenantLifecycle class includesSelector: #inspectTenantAccess)
			ifTrue: [ CustomerVersionedTenantLifecycle class removeSelector: #inspectTenantAccess ] ]
]
