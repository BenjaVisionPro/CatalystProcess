"I am the visual Magritte presentation for a CPProcess.

I compose the Process diagram with Foundation Detail for the currently selected semantic object. Both presentations edit the same CFMaMemento transaction: the diagram uses the root Process memento and Detail uses that root memento or the appropriate embedded child memento."
Class {
	#name : 'CPProcessPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'diagramElement',
		'collaborationDiagramElement',
		'processDiagramElement',
		'diagramScrollElement',
		'detailHostElement',
		'detailScrollElement',
		'workspaceElement',
		'diagramEditing',
		'diagramCameraInitialized'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessPresentation >> initialize [
	super initialize.
	diagramEditing := CPReadOnlyProcessDiagramEditing new
]

{ #category : 'private - building' }
CPProcessPresentation >> prepareHostElement [
	| surfaceColor collaborationContext collaborationDiagram |
	diagramCameraInitialized := false.
	surfaceColor := self workspaceSurfaceColor.
	collaborationContext := self collaborationContext.
	collaborationDiagram := collaborationContext ifNotNil: [ :aContext | aContext diagram ].

	processDiagramElement := self
		newConfiguredProcessDiagramElementCollaborationHosted: collaborationDiagram notNil.

	collaborationDiagramElement := nil.
	diagramElement := collaborationDiagram
		ifNil: [ processDiagramElement ]
		ifNotNil: [
			collaborationDiagramElement := CPCollaborationVisualElement new
			diagramEditing: diagramEditing;
				diagramElementsRemovedDo: [ :someDiagramElements | self diagramElementsRemoved: someDiagramElements ];
				selectionChangedDo: [ :aDiagramElement | self collaborationDiagramSelectionChanged: aDiagramElement ];
				processMemento: self memento
				processVisual: processDiagramElement;
				yourself.
			collaborationDiagramElement ].

	diagramScrollElement := BrScrollPane new
		background: surfaceColor;
		allowMeAndChildrenMouseEvents;
		aptitude: BrScrollPaneAptitude
			+ BrGlamorousWithHorizontalScrollbarAptitude
			+ BrGlamorousWithVerticalScrollbarAptitude;
		hMatchParent;
		vMatchParent;
		content: diagramElement;
		yourself.
	diagramScrollElement addEventHandler: (BlEventHandler
		on: BlElementExtentChangedEvent
		do: [ :anEvent | self updateDiagramViewportExtent ]).

	detailHostElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 0;
		padding: BlInsets empty;
		background: surfaceColor;
		yourself.

	detailScrollElement := BrScrollPane new
		background: surfaceColor;
		allowMeAndChildrenMouseEvents;
		aptitude: BrScrollPaneAptitude + BrGlamorousWithVerticalScrollbarAptitude;
		hExact: 380;
		vMatchParent;
		content: detailHostElement;
		yourself.

	workspaceElement := BrHorizontalPane new
		background: surfaceColor;
		hMatchParent;
		vMatchParent;
		cellSpacing: 0;
		addChild: diagramScrollElement;
		addChild: detailScrollElement;
		yourself.

	self hostElement
		background: surfaceColor;
		hMatchParent;
		vMatchParent;
		addChild: workspaceElement.

]

{ #category : 'private - building' }
CPProcessPresentation >> newConfiguredProcessDiagramElementCollaborationHosted: aBoolean [
	| visual |
	visual := CPProcessVisualElement new.
	aBoolean ifTrue: [ visual beCollaborationHosted ].
	visual
		selectionChangedDo: [ :aDiagramElement | self processDiagramSelectionChanged: aDiagramElement ];
		diagramElementsRemovedDo: [ :someDiagramElements | self diagramElementsRemoved: someDiagramElements ];
		diagramEditing: diagramEditing;
		collaborationChangedDo: [ self ensureCollaborationDiagramPresentation ];
		memento: self memento.
	^ visual
]

{ #category : 'private - layout' }
CPProcessPresentation >> updateDiagramViewportExtent [
	| viewport |
	diagramElement ifNil: [ ^ self ].
	viewport := diagramScrollElement extent.
	diagramElement viewportExtent: viewport.
	(diagramCameraInitialized not and: [ viewport x > 1 and: [ viewport y > 1 ] ]) ifTrue: [
		diagramCameraInitialized := true.
		diagramScrollElement enqueueTask: (BlTaskAction new action: [
			diagramScrollElement scrollBy: diagramElement cameraSlack / 2 ]) ]
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> ensureCollaborationDiagramPresentation [
	| collaborationContext collaborationDiagram scrollable previousGraphViewportOrigin viewport newGraphContentOrigin targetScrollPosition scrollDelta |
	collaborationContext := self collaborationContext.
	collaborationContext ifNil: [ ^ self ].
	collaborationDiagram := collaborationContext diagram.

	collaborationDiagramElement ifNil: [
		"The first Pool changes presentation topology but must not change the
		user's camera. Work in BlScrollableElement coordinates and establish the
		target scrollPosition before Bloc's normal layout phase.

		Do not force a synchronous layout here. Bloc's documented production
		lifecycle defers layout to the frame. BlScrollableElement>>onLayout: then
		owns gap fixing and clamping against the newly measured content."
		scrollable := diagramScrollElement childNamed: #scrollable.
		previousGraphViewportOrigin := processDiagramElement diagramExtent = (0 @ 0)
			ifTrue: [ nil ]
			ifFalse: [
				scrollable scrollPosition + processDiagramElement cameraSlack ].
		viewport := diagramScrollElement extent max: 1 @ 1.

		processDiagramElement := self
			newConfiguredProcessDiagramElementCollaborationHosted: true.
		collaborationDiagramElement := CPCollaborationVisualElement new
			diagramEditing: diagramEditing;
			diagramElementsRemovedDo: [ :someDiagramElements | self diagramElementsRemoved: someDiagramElements ];
			refreshAfterGeometryChangeDo: [ self refreshCollaborationDiagramPreservingCamera ];
			selectionChangedDo: [ :aDiagramElement | self collaborationDiagramSelectionChanged: aDiagramElement ];
			processMemento: self memento
			processVisual: processDiagramElement;
			yourself.
		collaborationDiagramElement viewportExtent: viewport.
		diagramElement := collaborationDiagramElement.

		"BrScrollPane content replacement requests layout but does not reset the
		native scrollPosition. Install the desired native camera position now;
		the normal Bloc layout will measure the new content and retain it when it
		is within the new scroll bounds."
		diagramCameraInitialized := true.
		diagramScrollElement content: diagramElement.

		previousGraphViewportOrigin ifNotNil: [
			newGraphContentOrigin :=
				collaborationDiagramElement diagramContentOffset
					+ (collaborationDiagramElement
						collaborationPointForProcessRootPoint:
							processDiagramElement diagramBounds origin).
			targetScrollPosition :=
				previousGraphViewportOrigin - newGraphContentOrigin.
			scrollDelta := targetScrollPosition - scrollable scrollPosition.
			scrollable scrollHorizontallyBy: scrollDelta x.
			scrollable scrollVerticallyBy: scrollDelta y ].
		^ self ].
	collaborationDiagramElement refresh
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> refreshCollaborationDiagramPreservingCamera [
	| scrollable oldScrollPosition oldNormalizationOffset newNormalizationOffset targetScrollPosition scrollDelta |
	collaborationDiagramElement ifNil: [ ^ self ].
	scrollable := diagramScrollElement childNamed: #scrollable.

	"Every Collaboration diagram point is rendered through this translation:
	 scrollPosition + cameraSlack - diagramBounds origin.
	 A geometry refresh may change both cameraSlack and diagramBounds. Preserve
	 that complete translation so resizing or moving a Pool never pans the
	 user's camera as a side effect."
	oldScrollPosition := scrollable scrollPosition.
	oldNormalizationOffset :=
		collaborationDiagramElement diagramContentOffset.

	collaborationDiagramElement refresh.

	newNormalizationOffset :=
		collaborationDiagramElement diagramContentOffset.
	targetScrollPosition :=
		oldScrollPosition + oldNormalizationOffset - newNormalizationOffset.
	scrollDelta := targetScrollPosition - scrollable scrollPosition.
	scrollable scrollHorizontallyBy: scrollDelta x.
	scrollable scrollVerticallyBy: scrollDelta y
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> diagramElementsRemoved: someDiagramElements [
	self stagedDefinitionalCollaboration
		ifNil: [ self restoreStandaloneProcessDiagramPreservingCamera ]
		ifNotNil: [ self refreshCollaborationDiagramPreservingCamera ].
	^ someDiagramElements
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> restoreStandaloneProcessDiagramPreservingCamera [
	| scrollable previousGraphViewportOrigin viewport targetScrollPosition scrollDelta |
	collaborationDiagramElement ifNil: [ ^ self ].
	scrollable := diagramScrollElement childNamed: #scrollable.
	previousGraphViewportOrigin :=
		scrollable scrollPosition
			+ collaborationDiagramElement diagramContentOffset
			+ (collaborationDiagramElement
				collaborationPointForProcessRootPoint:
					processDiagramElement diagramBounds origin).
	viewport := diagramScrollElement extent max: 1 @ 1.

	processDiagramElement
		beStandalone;
		collaborationVisual: nil;
		viewportExtent: viewport.
	collaborationDiagramElement := nil.
	diagramElement := processDiagramElement.
	diagramCameraInitialized := true.
	diagramScrollElement content: diagramElement.

	targetScrollPosition :=
		previousGraphViewportOrigin
			- processDiagramElement diagramBoundsOriginInContent.
	scrollDelta := targetScrollPosition - scrollable scrollPosition.
	scrollable scrollHorizontallyBy: scrollDelta x.
	scrollable scrollVerticallyBy: scrollDelta y
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> collaborationContext [
	^ CPProcessCollaborationContext inRootMemento: self memento
]

{ #category : 'private - collaboration' }
CPProcessPresentation >> stagedDefinitionalCollaboration [
	^ self collaborationContext
		ifNil: [ nil ]
		ifNotNil: [ :aContext | aContext collaboration ]
]



{ #category : 'private - selection' }
CPProcessPresentation >> processDiagramSelectionChanged: aDiagramElement [
	| collaborationContext localParticipantShape |
	collaborationContext := self collaborationContext.
	collaborationContext ifNotNil: [
		localParticipantShape := self localParticipantShapeIn: collaborationContext.
		localParticipantShape ifNotNil: [
			processDiagramElement diagramSelection remove: localParticipantShape ] ].
	self diagramSelectionDidChange
]


{ #category : 'private - selection' }
CPProcessPresentation >> collaborationDiagramSelectionChanged: aDiagramElement [
	| collaborationContext modelElement |
	collaborationContext := self collaborationContext.
	(collaborationContext notNil and: [ aDiagramElement notNil ]) ifTrue: [
		modelElement := self stagedModelElementOfDiagramElement: aDiagramElement.
		(modelElement notNil and: [
			(collaborationContext participants identityIncludes: modelElement)
				and: [ (collaborationContext processRefOf: modelElement) == self memento model ] ])
			ifTrue: [
				processDiagramElement diagramElementsInTree do: [ :each |
					processDiagramElement diagramSelection remove: each ] ] ].
	self diagramSelectionDidChange
]


{ #category : 'private - selection' }
CPProcessPresentation >> diagramSelectionDidChange [
	| modelElement |
	processDiagramElement ifNotNil: [ :aVisual |
		aVisual updateSelectionAppearanceRecursively ].
	collaborationDiagramElement ifNotNil: [ :aVisual |
		aVisual updateSelectionAppearance ].
	modelElement := processDiagramElement diagramSelection soleDiagramElement
		ifNotNil: [ :aSoleDiagramElement |
			self stagedModelElementOfDiagramElement: aSoleDiagramElement ].
	self selectModelElement: modelElement
]

{ #category : 'private - selection' }
CPProcessPresentation >> selectModelElement: aModelElement [
	| selectedMemento detailElement |
	aModelElement ifNil: [
		detailHostElement removeChildren.
		^ self ].
	selectedMemento := self mementoForModelElement: aModelElement.
	detailElement := self
		newDetailElementFor: aModelElement
		memento: selectedMemento.
	detailHostElement
		removeChildren;
		addChild: detailElement
]



{ #category : 'private - selection' }
CPProcessPresentation >> localParticipantShapeIn: aCollaborationContext [
	| participant diagramContext shapes |
	participant := aCollaborationContext participants
		detect: [ :each | (aCollaborationContext processRefOf: each) == self memento model ]
		ifNone: [ ^ nil ].
	diagramContext := aCollaborationContext diagramContext.
	shapes := diagramContext shapesForModelElement: participant.
	^ shapes size = 1
		ifTrue: [ shapes first ]
		ifFalse: [ nil ]
]


{ #category : 'private - selection' }
CPProcessPresentation >> stagedModelElementOfDiagramElement: aDiagramElement [
	| collaborationContext collaborationDiagramContext |
	collaborationContext := self collaborationContext.
	collaborationDiagramContext := collaborationContext ifNotNil: [ :aContext |
		aContext diagramContext ].
	(collaborationDiagramContext notNil
		and: [ collaborationContext elements identityIncludes: aDiagramElement ])
		ifTrue: [ ^ collaborationDiagramContext modelElementOf: aDiagramElement ].
	^ processDiagramElement stagedModelElementOfDiagramElement: aDiagramElement
]


{ #category : 'private - selection' }
CPProcessPresentation >> mementoForModelElement: aModelElement [
	| flowContext selectedMemento collaborationContext |
	aModelElement == self memento model ifTrue: [ ^ self memento ].

	flowContext := CPProcessFlowContainerContext rootFor: self memento.
	selectedMemento := flowContext mementoForFlowElement: aModelElement.
	selectedMemento ifNotNil: [ ^ selectedMemento ].

	collaborationContext := self collaborationContext.
	selectedMemento := collaborationContext ifNotNil: [ :aContext |
		aContext mementoForMember: aModelElement ].
	selectedMemento ifNotNil: [ ^ selectedMemento ].

	self error: 'Selected model element is not part of the staged Process, Sub-Process, or definitional Collaboration.'
]


{ #category : 'private - selection' }
CPProcessPresentation >> newDetailElementFor: aModelElement memento: aMemento [
	| viewModel |
	viewModel := CFMaViewModel forObject: aModelElement memento: aMemento.
	viewModel
		ignoreImplicitActions;
		elementBuilderDo: [ CFMaDetailPresentation new ].
	^ viewModel asElement
]

{ #category : 'private - theme' }
CPProcessPresentation >> resolvedThemeColor: aThemeableColor [
	^ aThemeableColor blocResolveColorForTheme: self hostElement theme
]

{ #category : 'private - theme' }
CPProcessPresentation >> workspaceSurfaceColor [
	^ self resolvedThemeColor: self hostElement theme surfaces baseBackground
]

{ #category : 'visiting-description' }
CPProcessPresentation >> visitContainer: aDescription [
	"The Process diagram is the visual representation of the root description.
	Its semantic descriptions remain available to the memento and to complementary
	presentations such as Foundation Detail."
	aDescription == self objectDescription ifTrue: [ ^ self ].
	^ super visitContainer: aDescription
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> diagramElement [
	^ diagramElement
]


{ #category : 'accessing - testing' }
CPProcessPresentation >> collaborationDiagramElement [
	^ collaborationDiagramElement
]


{ #category : 'configuration' }
CPProcessPresentation >> diagramEditing: anEditing [
	diagramEditing := anEditing.
	processDiagramElement ifNotNil: [ :aVisual | aVisual diagramEditing: anEditing ].
	collaborationDiagramElement ifNotNil: [ :aVisual | aVisual diagramEditing: anEditing ]
]

{ #category : 'accessing' }
CPProcessPresentation >> diagramEditing [
	^ diagramEditing
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> processDiagramElement [
	^ processDiagramElement
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> detailHostElement [
	^ detailHostElement
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> selectedModelElement [
	| diagramElement |
	processDiagramElement ifNil: [ ^ nil ].
	diagramElement := processDiagramElement diagramSelection soleDiagramElement.
	^ diagramElement ifNotNil: [
		self stagedModelElementOfDiagramElement: diagramElement ]
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> workspaceElement [
	^ workspaceElement
]
