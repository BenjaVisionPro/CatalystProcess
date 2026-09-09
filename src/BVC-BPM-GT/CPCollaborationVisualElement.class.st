"I render the definitional Collaboration of one root CPProcess.

The enclosing Atelier transaction remains rooted at that CPProcess. I read the Process's definitionalCollaborationRef and its Collaboration DI, render each Participant as a CPParticipantShapeElement, and host the already-configured root CPProcessVisualElement inside the Participant whose processRef is the edited Process.

Black-box Participants render as Pools without Process content. Participant editing and MessageFlow rendering use the shared staged Collaboration and diagram contexts."
Class {
	#name : 'CPCollaborationVisualElement',
	#superclass : 'BlElement',
	#instVars : [
		'processMemento',
		'processVisual',
		'collaborationContext',
		'diagramContext',
		'planeGeometry',
		'diagramViewport',
		'diagramEditing',
		'refreshAfterGeometryChangeBlock',
		'diagramElementsRemovedBlock',
		'diagramSelection',
		'selectionChangedBlock',
		'participantElementsByParticipant',
		'messageFlowVisualsByEdge',
		'connectionPreviewLine',
		'connectionPreviewCursor',
		'viewportExtent',
		'diagramLayer'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPCollaborationVisualElement >> initialize [
	super initialize.
	diagramEditing := CPReadOnlyProcessDiagramEditing new.
	diagramSelection := CPDiagramSelection new.
	participantElementsByParticipant := IdentityDictionary new.
	messageFlowVisualsByEdge := IdentityDictionary new.
	connectionPreviewLine := nil.
	connectionPreviewCursor := nil.
	viewportExtent := 1360 @ 800.
	planeGeometry := CPDiagramPlaneGeometry new.
	diagramViewport := CPDiagramViewport
		viewportExtent: viewportExtent
		diagramExtent: planeGeometry diagramExtent.
	diagramLayer := nil.
	self
		layout: BlFrameLayout new;
		clipChildren: false;
		beFocusable.
	self
		installKeyboardHandler;
		installPaletteDropHandler
]


{ #category : 'configuration' }
CPCollaborationVisualElement >> diagramEditing: anEditing [
	diagramEditing := anEditing.
	processVisual ifNotNil: [ :aVisual | aVisual diagramEditing: anEditing ]
]

{ #category : 'accessing' }
CPCollaborationVisualElement >> diagramEditing [
	^ diagramEditing
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> processMemento: aMemento processVisual: aProcessVisual [
	processMemento := aMemento.
	processVisual := aProcessVisual.
	diagramSelection := processVisual diagramSelection.
	processVisual diagramEditing: diagramEditing.
	self refresh
]

{ #category : 'updating' }
CPCollaborationVisualElement >> refresh [
	| elements participantShapes messageFlowEdges stagedParticipants stagedMessageFlows |
	processVisual ifNotNil: [ processVisual removeFromParent ].
	self removeChildren.
	participantElementsByParticipant removeAll.
	messageFlowVisualsByEdge removeAll.

	collaborationContext := CPProcessCollaborationContext
		inRootMemento: processMemento.
	collaborationContext ifNil: [ ^ self ].
	diagramContext := collaborationContext diagramContext.
	elements := diagramContext elements.
	stagedParticipants := collaborationContext participants.
	stagedMessageFlows := collaborationContext messageFlows.
	participantShapes := elements select: [ :each |
		| modelElement |
		each isShape and: [
			modelElement := self stagedModelElementOf: each.
			modelElement notNil and: [ modelElement isParticipant ] ] ].
	messageFlowEdges := elements select: [ :each |
		| modelElement |
		each isEdge and: [
			modelElement := self stagedModelElementOf: each.
			modelElement notNil and: [
				stagedMessageFlows identityIncludes: modelElement ] ] ].

	planeGeometry := CPDiagramPlaneGeometry
		shapes: participantShapes
		edges: messageFlowEdges
		context: diagramContext.
	diagramLayer := BlElement new
		layout: BlFrameLayout new;
		clipChildren: false;
		preventMouseEvents;
		yourself.
	self addChild: diagramLayer.
	self updateCanvasExtent.
	participantShapes do: [ :each | self addParticipantShape: each ].
	messageFlowEdges do: [ :each | self addMessageFlowEdge: each ].
	self updateSelectionAppearance
]

{ #category : 'private - building' }
CPCollaborationVisualElement >> addParticipantShape: aShape [
	| participant participantMemento label bounds element |
	participant := self stagedModelElementOf: aShape.
	bounds := self stagedBoundsOf: aShape.
	(participant isNil or: [ bounds isNil ]) ifTrue: [ ^ self ].
	participantMemento := collaborationContext mementoForMember: participant.
	participantMemento ifNil: [ ^ self ].
	label := processVisual newEditableLabelForMemento: participantMemento.
	element := CPParticipantShapeElement new
		participant: participant
		shape: aShape
		bounds: bounds
		background: self poolBackgroundColor
		borderColor: self poolBorderColor
		label: label.
	element
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: bounds origin.
	participantElementsByParticipant at: participant put: element.
	self addDiagramChild: element.
	self
		installSelectionOnParticipantElement: element participant: participant;
		installPositioningOnParticipantElement: element shape: aShape;
		installResizeOnParticipantElement: element shape: aShape.
	processVisual
		installLabelEditingOn: element labelBand
		label: label.

	(self stagedProcessRefOfParticipant: participant) == processMemento model ifTrue: [
		processVisual beCollaborationHosted.
		processVisual collaborationVisual: self.
		element hostProcessVisual: processVisual.
		self installPoolStructuralDropOnParticipantHeader: element labelBand ]
]

{ #category : 'private - removal' }
CPCollaborationVisualElement >> removeSelection [
	| diagramElements operation assessment |
	diagramSelection isEmpty ifTrue: [ ^ self ].
	diagramElements := diagramSelection diagramElements.
	operation := diagramEditing remove: diagramElements.
	operation ifNil: [ ^ self ].
	assessment := operation assess.
	assessment isApplicable ifFalse: [ ^ assessment ].
	operation apply.

	diagramSelection clear.
	selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: nil ].
	diagramElementsRemovedBlock
		ifNil: [ self refresh ]
		ifNotNil: [ :aBlock | aBlock value: diagramElements ].
	^ assessment
]


{ #category : 'private - installing' }
CPCollaborationVisualElement >> installKeyboardHandler [
	self addEventHandler: (BlEventHandler
		on: BlKeyDownEvent
		do: [ :anEvent |
			(anEvent target == self
				and: [
					anEvent key = BlKeyboardKey delete
						or: [ anEvent key = BlKeyboardKey backspace ] ])
				ifTrue: [
					self removeSelection.
					anEvent consumed: true ] ])
]

{ #category : 'private - selection' }
CPCollaborationVisualElement >> installSelectionOnMessageFlowElement: anElement edge: anEdge [
	anElement
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent |
				anEvent modifiers isShift
					ifTrue: [ self toggleSelectionOfDiagramElement: anEdge ]
					ifFalse: [ self selectOnlyDiagramElement: anEdge ].
				self requestFocus.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDoubleClickEvent
			do: [ :anEvent |
				self selectOnlyDiagramElement: anEdge.
				self beginEditingMessageFlowLabelForEdge: anEdge.
				anEvent consumed: true ])
]


{ #category : 'private - selection' }
CPCollaborationVisualElement >> installSelectionOnParticipantElement: anElement participant: aParticipant [
	anElement addEventHandler: (BlEventHandler
		on: BlClickEvent
		do: [ :anEvent |
			anEvent modifiers isShift
				ifTrue: [ self toggleSelectionOfDiagramElement: anElement diagramShape ]
				ifFalse: [ self selectOnlyDiagramElement: anElement diagramShape ].
			self requestFocus.
			anEvent consumed: true ]).
	anElement installBodyCursor
]

{ #category : 'private - selection' }
CPCollaborationVisualElement >> updateSelectionAppearance [
	participantElementsByParticipant valuesDo: [ :anElement |
		anElement
			selected: (diagramSelection includes: anElement diagramShape)
			selectionColor: self selectionColor
			normalColor: self poolBorderColor ].
	messageFlowVisualsByEdge keysAndValuesDo: [ :anEdge :aVisual |
		aVisual
			selected: (diagramSelection includes: anEdge)
			selectionColor: self selectionColor
			normalColor: self poolBorderColor ]
]

{ #category : 'private - positioning' }
CPCollaborationVisualElement >> installPositioningOnParticipantElement: anElement shape: aShape [
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	anElement
		installPositioningFrom: anElement labelBand
		stagedBounds: [ self stagedBoundsOf: aShape ]
		dragStarted: [ :anEvent :originalBounds |
			diagramSelection selectOnly: aShape.
			self updateSelectionAppearance.
			selectionChangedBlock ifNotNil: [ :aBlock |
				aBlock value: aShape ] ]
		dragStartPosition: [ (self stagedBoundsOf: aShape) origin ]
		dragged: [ :anEvent :delta | ]
		dragEnded: [ :anEvent :proposedBounds :delta |
			| boundsByShape |
			boundsByShape := IdentityDictionary new
				at: aShape put: proposedBounds;
				yourself.
			(diagramEditing
				moveShapes: boundsByShape
				toProcessHostedBy: nil
				waypointsByEdge: IdentityDictionary new) apply.
			self refreshAfterGeometryChange ]
]

{ #category : 'private - resizing' }
CPCollaborationVisualElement >> installResizeOnParticipantElement: anElement shape: aShape [
	| handles |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	handles := anElement
		installResizeHandleMinimumExtent: self minimumParticipantExtent
		stagedBounds: [ self stagedBoundsOf: aShape ]
		resize: [ :proposedBounds |
			(diagramEditing resizeShape: aShape toBounds: proposedBounds) apply.
			self refreshAfterGeometryChange ]
		geometryChanged: nil.
	handles do: [ :aHandle | anElement addChild: aHandle ]
]

{ #category : 'private - sizing' }
CPCollaborationVisualElement >> minimumParticipantExtent [
	^ 120 @ 80
]

{ #category : 'private - building' }
CPCollaborationVisualElement >> addMessageFlowEdge: anEdge [
	| messageFlow waypoints visual |
	messageFlow := self stagedModelElementOf: anEdge.
	waypoints := self stagedWaypointsOf: anEdge.
	waypoints size < 2 ifTrue: [ ^ self ].
	visual := CPCollaborationMessageFlowVisual edge: anEdge.
	visual
		renderWaypoints: waypoints
		color: self poolBorderColor
		in: self diagramPresentationParent.
	messageFlowVisualsByEdge at: anEdge put: visual.
	self addExternalLabelForMessageFlow: messageFlow edge: anEdge visual: visual.
	visual hitElements do: [ :anElement |
		self installSelectionOnMessageFlowElement: anElement edge: anEdge ].
	self installReconnectHandlesForMessageFlowEdge: anEdge visual: visual.
	self installBendpointHandlesForMessageFlowEdge: anEdge visual: visual
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> refreshAfterGeometryChangeDo: aBlock [
	refreshAfterGeometryChangeBlock := aBlock
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> diagramElementsRemovedDo: aBlock [
	diagramElementsRemovedBlock := aBlock
]



{ #category : 'selection' }
CPCollaborationVisualElement >> selectOnlyDiagramElement: aDiagramElement [
	diagramSelection selectOnly: aDiagramElement.
	self updateSelectionAppearance.
	selectionChangedBlock ifNotNil: [ :aBlock |
		aBlock value: aDiagramElement ]
]


{ #category : 'selection' }
CPCollaborationVisualElement >> toggleSelectionOfDiagramElement: aDiagramElement [
	diagramSelection toggle: aDiagramElement.
	self updateSelectionAppearance.
	selectionChangedBlock ifNotNil: [ :aBlock |
		aBlock value: aDiagramElement ]
]


{ #category : 'selection' }
CPCollaborationVisualElement >> diagramSelection [
	^ diagramSelection
]


{ #category : 'configuration' }
CPCollaborationVisualElement >> diagramSelection: aDiagramSelection [
	diagramSelection := aDiagramSelection.
	processVisual ifNotNil: [ :aVisual | aVisual diagramSelection: aDiagramSelection ]
]


{ #category : 'configuration' }
CPCollaborationVisualElement >> selectionChangedDo: aBlock [
	selectionChangedBlock := aBlock
]

{ #category : 'private - updating' }
CPCollaborationVisualElement >> refreshAfterGeometryChange [
	refreshAfterGeometryChangeBlock
		ifNil: [ self refresh ]
		ifNotNil: [ :aBlock | aBlock value ]
]

{ #category : 'connection' }
CPCollaborationVisualElement >> beginConnectionDragFrom: aSource sourceVisual: aSourceVisual event: anEvent [
	| pointer sourcePoint |
	self removeConnectionPreview.
	pointer := self diagramPointForGlobalPoint: anEvent position.
	sourcePoint := self
		collaborationDockingPointForFlowNode: aSource
		inVisual: aSourceVisual
		toward: pointer.
	connectionPreviewCursor := BlElement new
		extent: 1 @ 1;
		background: Color transparent;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: pointer;
		preventMeAndChildrenMouseEvents;
		yourself.
	connectionPreviewLine := BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: sourcePoint);
		toAnchor: (BlAbsolutePositionAnchor position: pointer);
		border: (BlBorder paint: self selectionColor width: 1.5);
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		yourself.
	connectionPreviewLine toHead: (BlArrowheadSimpleArrow new
		border: (BlBorder paint: self selectionColor width: 1.5)).
	self
		addDiagramChild: connectionPreviewCursor;
		addDiagramChild: connectionPreviewLine
]

{ #category : 'connection' }
CPCollaborationVisualElement >> updateConnectionDragFrom: aSource sourceVisual: aSourceVisual event: anEvent [
	| pointer target sourcePoint targetPoint |
	connectionPreviewLine ifNil: [
		^ self
			beginConnectionDragFrom: aSource
			sourceVisual: aSourceVisual
			event: anEvent ].
	pointer := self diagramPointForGlobalPoint: anEvent position.
	connectionPreviewCursor relocate: pointer.
	target := self
		connectionTargetAtGlobalPoint: anEvent position
		from: aSource
		sourceVisual: aSourceVisual.
	sourcePoint := self
		collaborationDockingPointForFlowNode: aSource
		inVisual: aSourceVisual
		toward: pointer.
	targetPoint := target
		ifNil: [ pointer ]
		ifNotNil: [
			target isSequenceFlowTarget
				ifTrue: [
					self
						collaborationDockingPointForFlowNode: target modelElement
						inVisual: aSourceVisual
						toward: sourcePoint ]
				ifFalse: [
					self
						dockingPointForParticipant: target modelElement
						toward: sourcePoint ] ].
	connectionPreviewLine
		fromAnchor: (BlAbsolutePositionAnchor position: sourcePoint);
		toAnchor: (BlAbsolutePositionAnchor position: targetPoint)
]

{ #category : 'connection' }
CPCollaborationVisualElement >> endConnectionDragFrom: aSource sourceVisual: aSourceVisual event: anEvent [
	| target sourceShape targetShape operation assessment |
	target := self
		connectionTargetAtGlobalPoint: anEvent position
		from: aSource
		sourceVisual: aSourceVisual.
	self removeConnectionPreview.
	target ifNil: [ ^ nil ].
	target isSequenceFlowTarget ifTrue: [
		^ aSourceVisual
			connectSequenceFlowFrom: aSource
			to: target modelElement ].
	sourceShape := aSourceVisual diagramShapeForModelElement: aSource.
	targetShape := self participantShapeFor: target modelElement.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [ ^ nil ].
	operation := diagramEditing
		connectFrom: sourceShape
		to: targetShape
		waypoints: (self
			messageFlowWaypointsFrom: aSource
			inVisual: aSourceVisual
			toParticipant: target modelElement).
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable ifTrue: [ self refresh ].
	^ assessment
]

{ #category : 'connection' }
CPCollaborationVisualElement >> connectionTargetAtGlobalPoint: aGlobalPoint from: aSource sourceVisual: aSourceVisual [
	| sequenceTarget participantTarget sourceShape targetShape operation assessment |
	sequenceTarget := aSourceVisual
		sequenceFlowTargetAtGlobalPoint: aGlobalPoint
		from: aSource.
	sequenceTarget ifNotNil: [ ^ CPCollaborationConnectionTarget sequenceFlowTo: sequenceTarget ].
	participantTarget := self
		participantAtCollaborationPoint: (self diagramPointForGlobalPoint: aGlobalPoint)
		excludingEndpoint: aSource.
	participantTarget ifNil: [ ^ nil ].
	sourceShape := aSourceVisual diagramShapeForModelElement: aSource.
	targetShape := self participantShapeFor: participantTarget.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [ ^ nil ].
	operation := diagramEditing
		connectFrom: sourceShape
		to: targetShape
		waypoints: (self
			messageFlowWaypointsFrom: aSource
			inVisual: aSourceVisual
			toParticipant: participantTarget).
	operation ifNil: [ ^ nil ].
	assessment := operation assess.
	^ assessment isApplicable
		ifTrue: [ CPCollaborationConnectionTarget messageFlowTo: participantTarget ]
		ifFalse: [ nil ]
]

{ #category : 'connection' }
CPCollaborationVisualElement >> participantAtCollaborationPoint: aPoint excludingEndpoint: anEndpoint [
	| endpointParticipant |
	endpointParticipant := collaborationContext participantForEndpoint: anEndpoint.
	^ self stagedParticipants
		detect: [ :each |
			each ~~ endpointParticipant and: [
				| shape bounds |
				shape := self participantShapeFor: each.
				shape notNil and: [
					bounds := self stagedBoundsOf: shape.
					bounds containsPoint: aPoint ] ] ]
		ifNone: [ nil ]
]

{ #category : 'connection' }
CPCollaborationVisualElement >> participantShapeFor: aParticipant [
	| matches |
	matches := participantElementsByParticipant values select: [ :each |
		each participant == aParticipant ].
	^ matches size = 1
		ifTrue: [ matches first diagramShape ]
		ifFalse: [ nil ]
]

{ #category : 'connection geometry' }
CPCollaborationVisualElement >> messageFlowWaypointsFrom: aSource inVisual: aSourceVisual toParticipant: aParticipant [
	| targetBounds sourceCenter targetCenter sourcePoint targetPoint |
	targetBounds := self stagedBoundsOf: (self participantShapeFor: aParticipant).
	targetCenter := targetBounds center.
	sourceCenter := self
		collaborationCenterForFlowNode: aSource
		inVisual: aSourceVisual.
	sourcePoint := self
		collaborationDockingPointForFlowNode: aSource
		inVisual: aSourceVisual
		toward: targetCenter.
	targetPoint := self
		dockingPointForRectangle: targetBounds
		toward: sourceCenter.
	^ { sourcePoint. targetPoint }
]

{ #category : 'connection geometry' }
CPCollaborationVisualElement >> collaborationCenterForFlowNode: aFlowNode inVisual: aSourceVisual [
	| shape bounds rootProcessPoint |
	shape := aSourceVisual diagramShapeForModelElement: aFlowNode.
	bounds := aSourceVisual stagedBoundsOf: shape.
	rootProcessPoint := aSourceVisual
		rootDiagramPointForLocalPoint: bounds center.
	^ self collaborationPointForProcessRootPoint: rootProcessPoint
]

{ #category : 'connection geometry' }
CPCollaborationVisualElement >> collaborationDockingPointForFlowNode: aFlowNode inVisual: aSourceVisual toward: aPoint [
	| element bounds rootOrigin collaborationBounds |
	element := aSourceVisual shapeElementForModelElement: aFlowNode.
	element ifNil: [ ^ aPoint ].
	bounds := aSourceVisual
		diagramBoundsForFlowNode: aFlowNode
		element: element.
	rootOrigin := aSourceVisual
		rootDiagramPointForLocalPoint: bounds origin.
	collaborationBounds :=
		(self collaborationPointForProcessRootPoint: rootOrigin)
			extent: bounds extent.
	^ self
		dockingPointForRectangle: collaborationBounds
		toward: aPoint
]

{ #category : 'connection geometry' }
CPCollaborationVisualElement >> collaborationPointForProcessRootPoint: aPoint [
	| participant participantElement shape bounds |
	participant := self
		stagedParticipantForProcess: processMemento model.
	participant ifNil: [ ^ aPoint ].
	participantElement := participantElementsByParticipant
		at: participant
		ifAbsent: [ ^ aPoint ].
	shape := participantElement diagramShape.
	bounds := self stagedBoundsOf: shape.
	^ bounds origin
		+ participantElement processContentOriginOffset
		+ aPoint
		+ processVisual diagramContentOffset
]

{ #category : 'connection geometry' }
CPCollaborationVisualElement >> dockingPointForParticipant: aParticipant toward: aPoint [
	^ self
		dockingPointForRectangle: (self stagedBoundsOf: (self participantShapeFor: aParticipant))
		toward: aPoint
]

{ #category : 'connection geometry' }
CPCollaborationVisualElement >> dockingPointForRectangle: aRectangle toward: aPoint [
	| center vector halfWidth halfHeight scaleX scaleY scale |
	center := aRectangle center.
	vector := aPoint - center.
	vector = (0 @ 0) ifTrue: [ ^ center ].
	halfWidth := aRectangle width / 2.0.
	halfHeight := aRectangle height / 2.0.
	scaleX := vector x isZero
		ifTrue: [ Float infinity ]
		ifFalse: [ halfWidth / vector x abs ].
	scaleY := vector y isZero
		ifTrue: [ Float infinity ]
		ifFalse: [ halfHeight / vector y abs ].
	scale := scaleX min: scaleY.
	^ center + (vector * scale)
]

{ #category : 'connection' }
CPCollaborationVisualElement >> removeConnectionPreview [
	connectionPreviewLine ifNotNil: [ connectionPreviewLine removeFromParent ].
	connectionPreviewCursor ifNotNil: [ connectionPreviewCursor removeFromParent ].
	connectionPreviewLine := nil.
	connectionPreviewCursor := nil
]

{ #category : 'private - labels' }
CPCollaborationVisualElement >> addExternalLabelForMessageFlow: aMessageFlow edge: anEdge visual: aVisual [
	| labelHost dragSurface label |
	labelHost := BlElement new
		clipChildren: false;
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal exact: 180.
			c vertical fitContent.
			c ignoreByLayout ];
		preventMouseEvents;
		yourself.
	dragSurface := BlElement new
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal fitContent.
			c vertical fitContent.
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		yourself.
	label := self newEditableLabelForMessageFlow: aMessageFlow.
	label hFitContentLimited.
	label vFitContent.
	label constraintsDo: [ :c |
		c maxWidth: 180.
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	dragSurface addChild: label.
	labelHost addChild: dragSurface.
	aVisual labelHost: labelHost.
	self addDiagramChild: labelHost.
	self installMessageFlowLabelPositioningOn: dragSurface for: anEdge.
	self installMessageFlowLabelEditingOn: dragSurface label: label.
	self positionMessageFlowLabelFor: anEdge
]

{ #category : 'private - labels' }
CPCollaborationVisualElement >> newEditableLabelForMessageFlow: aMessageFlow [
	| flowMemento description label |
	flowMemento := collaborationContext mementoForMember: aMessageFlow.
	flowMemento ifNil: [ self error: 'MessageFlow is not present in the staged Collaboration.' ].
	description := flowMemento magritteDescription detect: [ :each | each handlesSelector: #label ].
	label := CFEditableLabel new
		aptitude: CPProcessLabelAptitude new;
		text: ((flowMemento readUsing: description) ifNil: [ '' ]);
		padding: BlInsets empty;
		margin: BlInsets empty;
		background: Color transparent;
		border: BlBorder empty;
		yourself.
	label editor
		when: BrTextEditorModifiedEvent
		do: [ :anEvent |
			GtMagritteBuilderUtility
				writeText: anEvent text
				using: description
				memento: flowMemento
				element: label ].
	label
		when: BrEditorAcceptWish
		do: [ :aWish | self finishEditingMessageFlowLabel: label ];
		when: BrEditorCancelWish
		do: [ :aWish |
			GtMagritteBuilderUtility
				writeText: label text
				using: description
				memento: flowMemento
				element: label.
			self finishEditingMessageFlowLabel: label ].
	label preventMeAndChildrenMouseEvents.
	^ label
]

{ #category : 'private - labels' }
CPCollaborationVisualElement >> installMessageFlowLabelEditingOn: anInteractionElement label: anEditableLabel [
	anInteractionElement addEventHandler: (BlEventHandler
		on: BlDoubleClickEvent
		do: [ :anEvent |
			anEditableLabel allowMeAndChildrenMouseEvents.
			anEditableLabel switchToEditor.
			anEditableLabel enqueueTask: (BlTaskAction new action: [ anEditableLabel requestFocus ]).
			anEvent consumed: true ])
]

{ #category : 'private - labels' }
CPCollaborationVisualElement >> finishEditingMessageFlowLabel: anEditableLabel [
	anEditableLabel preventMeAndChildrenMouseEvents.
	anEditableLabel loseFocus.
	self enqueueTask: (BlTaskAction new action: [ self requestFocus ])
]

{ #category : 'private - labels' }
CPCollaborationVisualElement >> beginEditingMessageFlowLabelForEdge: anEdge [
	| visual labelHost label |
	visual := messageFlowVisualsByEdge at: anEdge ifAbsent: [ ^ self ].
	labelHost := visual labelHost.
	labelHost ifNil: [ ^ self ].
	labelHost children isEmpty ifTrue: [ ^ self ].
	labelHost children first children isEmpty ifTrue: [ ^ self ].
	label := labelHost children first children first.
	label allowMeAndChildrenMouseEvents.
	label switchToEditor.
	label enqueueTask: (BlTaskAction new action: [ label requestFocus ])
]


{ #category : 'private - labels' }
CPCollaborationVisualElement >> installMessageFlowLabelPositioningOn: aLabelHost for: anEdge [
	| isDragging lastPlacement |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	isDragging := false.
	lastPlacement := nil.
	aLabelHost
		addEventHandler: (BlEventHandler on: BlDragStartEvent do: [ :anEvent |
			isDragging := true.
			lastPlacement := nil.
			anEvent consumed: true ]);
		addEventHandler: (BlEventHandler on: BlDragEvent do: [ :anEvent |
			isDragging ifTrue: [
				lastPlacement := (CPProcessEdgeLabelPath points: (self stagedWaypointsOf: anEdge))
					nearestPlacementTo: (self diagramPointForGlobalPoint: anEvent position).
				(self messageFlowVisualsByEdge at: anEdge)
					positionLabelCenteredAt: lastPlacement fourth.
				anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler on: BlDragEndEvent do: [ :anEvent |
			isDragging ifTrue: [
				isDragging := false.
				lastPlacement ifNotNil: [
					self
						setMessageFlowLabelSegmentIndex: lastPlacement first
						segmentPosition: lastPlacement second
						offset: lastPlacement third
						forEdge: anEdge ].
				anEvent consumed: true ] ])
]

{ #category : 'private - labels' }
CPCollaborationVisualElement >> positionMessageFlowLabelFor: anEdge [
	| path segmentIndex segmentPosition offset placement |
	path := CPProcessEdgeLabelPath points: (self stagedWaypointsOf: anEdge).
	segmentIndex := (self stagedLabelSegmentIndexOf: anEdge) ifNil: [ path defaultSegmentIndex ].
	segmentPosition := (self stagedLabelSegmentPositionOf: anEdge) ifNil: [ 0.5 ].
	offset := (self stagedLabelOffsetOf: anEdge) ifNil: [ -12.0 ].
	placement := path
		placementAtSegmentIndex: segmentIndex
		segmentPosition: segmentPosition
		offset: offset.
	(messageFlowVisualsByEdge at: anEdge ifAbsent: [ ^ self ])
		positionLabelCenteredAt: placement first
]

{ #category : 'operations' }
CPCollaborationVisualElement >> setMessageFlowLabelSegmentIndex: aSegmentIndex segmentPosition: aSegmentPosition offset: anOffset forEdge: anEdge [
	| operation assessment |
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	operation := diagramEditing
		setLabelSegmentIndex: aSegmentIndex
		segmentPosition: aSegmentPosition
		offset: anOffset
		forEdge: anEdge.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable ifTrue: [ self refresh ].
	^ assessment
]

{ #category : 'operations' }
CPCollaborationVisualElement >> setMessageFlowWaypoints: someWaypoints forEdge: anEdge [
	| operation assessment currentWaypoints topologyChanges pathFraction segmentPlacement offset |
	diagramEditing allowsEditing ifFalse: [ ^ nil ].
	currentWaypoints := self stagedWaypointsOf: anEdge.
	topologyChanges := currentWaypoints size ~= someWaypoints size.
	topologyChanges ifTrue: [
		| path segmentIndex segmentPosition |
		path := CPProcessEdgeLabelPath points: currentWaypoints.
		segmentIndex := (self stagedLabelSegmentIndexOf: anEdge) ifNil: [ path defaultSegmentIndex ].
		segmentPosition := (self stagedLabelSegmentPositionOf: anEdge) ifNil: [ 0.5 ].
		pathFraction := path
			pathFractionForSegmentIndex: segmentIndex
			segmentPosition: segmentPosition ].
	operation := diagramEditing setWaypoints: someWaypoints forEdge: anEdge.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable ifTrue: [
		topologyChanges ifTrue: [
			segmentPlacement := (CPProcessEdgeLabelPath points: someWaypoints)
				segmentPlacementAtFraction: pathFraction.
			offset := (self stagedLabelOffsetOf: anEdge) ifNil: [ -12.0 ].
			(diagramEditing
				setLabelSegmentIndex: segmentPlacement first
				segmentPosition: segmentPlacement second
				offset: offset
				forEdge: anEdge) apply ].
		self refresh ].
	^ assessment
]

{ #category : 'private - bendpoints' }
CPCollaborationVisualElement >> installBendpointHandlesForMessageFlowEdge: anEdge visual: aVisual [
	| waypoints handles |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	waypoints := self stagedWaypointsOf: anEdge.
	handles := OrderedCollection new.
	waypoints size >= 3 ifTrue: [
		2 to: waypoints size - 1 do: [ :index |
			handles add: (self
				newMessageFlowBendpointHandleFor: anEdge
				visual: aVisual
				waypointIndex: index
				at: (waypoints at: index)) ] ].
	aVisual bendpointHandles: handles.
	handles do: [ :aHandle | self addDiagramChild: aHandle ].
	1 to: aVisual hitElements size do: [ :segmentIndex |
		self
			installMessageFlowBendpointInsertionOn: (aVisual hitElements at: segmentIndex)
			for: anEdge
			segmentIndex: segmentIndex ]
]

{ #category : 'private - bendpoints' }
CPCollaborationVisualElement >> newMessageFlowBendpointHandleFor: anEdge visual: aVisual waypointIndex: waypointIndex at: aPoint [
	| previewLines |
	previewLines := #().
	^ aVisual
		newBendpointHandleAt: aPoint
		waypointIndex: waypointIndex
		selectionColor: self selectionColor
		removeRequested: [ :anIndex |
			| proposed |
			proposed := (self stagedWaypointsOf: anEdge) asOrderedCollection copy.
			proposed size > 2 ifTrue: [
				proposed removeAt: anIndex.
				self setMessageFlowWaypoints: proposed forEdge: anEdge ] ]
		dragged: [ :anEvent :newPoint |
			| proposed |
			proposed := (self stagedWaypointsOf: anEdge) asOrderedCollection copy.
			proposed at: waypointIndex put: newPoint.
			previewLines do: [ :aLine | aLine removeFromParent ].
			previewLines := self newMessageFlowPreviewLinesForWaypoints: proposed.
			previewLines do: [ :aLine | self addDiagramChild: aLine ].
			self positionMessageFlowLabelFor: anEdge usingWaypoints: proposed ]
		dragEnded: [ :anEvent :newPoint |
			| proposed |
			proposed := (self stagedWaypointsOf: anEdge) asOrderedCollection copy.
			proposed at: waypointIndex put: newPoint.
			previewLines do: [ :aLine | aLine removeFromParent ].
			self setMessageFlowWaypoints: proposed forEdge: anEdge ]
]

{ #category : 'private - bendpoints' }
CPCollaborationVisualElement >> installMessageFlowBendpointInsertionOn: anElement for: anEdge segmentIndex: aSegmentIndex [
	| isDragging dragStartEventPosition insertedPoint previewLines |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	isDragging := false.
	previewLines := #().
	anElement
		addEventHandler: (BlEventHandler on: BlDragStartEvent do: [ :anEvent |
			isDragging := true.
			dragStartEventPosition := anEvent position.
			insertedPoint := self diagramPointForGlobalPoint: anEvent position.
			anEvent consumed: true ]);
		addEventHandler: (BlEventHandler on: BlDragEvent do: [ :anEvent |
			isDragging ifTrue: [
				| currentPoint proposed |
				currentPoint := insertedPoint + (anEvent position - dragStartEventPosition).
				proposed := (self stagedWaypointsOf: anEdge) asOrderedCollection copy.
				proposed add: currentPoint beforeIndex: aSegmentIndex + 1.
				previewLines do: [ :aLine | aLine removeFromParent ].
				previewLines := self newMessageFlowPreviewLinesForWaypoints: proposed.
				previewLines do: [ :aLine | self addDiagramChild: aLine ].
				self positionMessageFlowLabelFor: anEdge usingWaypoints: proposed.
				anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler on: BlDragEndEvent do: [ :anEvent |
			isDragging ifTrue: [
				| currentPoint proposed |
				isDragging := false.
				currentPoint := insertedPoint + (anEvent position - dragStartEventPosition).
				proposed := (self stagedWaypointsOf: anEdge) asOrderedCollection copy.
				proposed add: currentPoint beforeIndex: aSegmentIndex + 1.
				previewLines do: [ :aLine | aLine removeFromParent ].
				self setMessageFlowWaypoints: proposed forEdge: anEdge.
				anEvent consumed: true ] ])
]

{ #category : 'private - bendpoints' }
CPCollaborationVisualElement >> newMessageFlowPreviewLinesForWaypoints: someWaypoints [
	| lines |
	lines := OrderedCollection new.
	1 to: someWaypoints size - 1 do: [ :index |
		lines add: (BlLineElement new
			fromAnchor: (BlAbsolutePositionAnchor position: (someWaypoints at: index));
			toAnchor: (BlAbsolutePositionAnchor position: (someWaypoints at: index + 1));
			border: (BlBorder paint: self selectionColor width: 1.5);
			constraintsDo: [ :c | c ignoreByLayout ];
			preventMeAndChildrenMouseEvents;
			yourself) ].
	^ lines
]

{ #category : 'private - labels' }
CPCollaborationVisualElement >> positionMessageFlowLabelFor: anEdge usingWaypoints: someWaypoints [
	| path segmentIndex segmentPosition offset placement |
	path := CPProcessEdgeLabelPath points: someWaypoints.
	segmentIndex := (self stagedLabelSegmentIndexOf: anEdge) ifNil: [ path defaultSegmentIndex ].
	segmentPosition := (self stagedLabelSegmentPositionOf: anEdge) ifNil: [ 0.5 ].
	offset := (self stagedLabelOffsetOf: anEdge) ifNil: [ -12.0 ].
	placement := path
		placementAtSegmentIndex: segmentIndex
		segmentPosition: segmentPosition
		offset: offset.
	(messageFlowVisualsByEdge at: anEdge ifAbsent: [ ^ self ])
		positionLabelCenteredAt: placement first
]


{ #category : 'private - reconnecting' }
CPCollaborationVisualElement >> installReconnectHandlesForMessageFlowEdge: anEdge visual: aVisual [
	| sourceHandle targetHandle waypoints |
	diagramEditing allowsEditing ifFalse: [ ^ self ].
	sourceHandle := aVisual
		newReconnectHandleMovingSource: true
		selectionColor: self selectionColor
		dragStarted: [ :anEvent :handle |
			self beginMessageFlowReconnectFor: anEdge movingSource: true event: anEvent ]
		dragged: [ :anEvent :handle |
			self updateMessageFlowReconnectFor: anEdge movingSource: true event: anEvent ]
		dragEnded: [ :anEvent :handle |
			self endMessageFlowReconnectFor: anEdge movingSource: true event: anEvent ].
	targetHandle := aVisual
		newReconnectHandleMovingSource: false
		selectionColor: self selectionColor
		dragStarted: [ :anEvent :handle |
			self beginMessageFlowReconnectFor: anEdge movingSource: false event: anEvent ]
		dragged: [ :anEvent :handle |
			self updateMessageFlowReconnectFor: anEdge movingSource: false event: anEvent ]
		dragEnded: [ :anEvent :handle |
			self endMessageFlowReconnectFor: anEdge movingSource: false event: anEvent ].
	aVisual reconnectHandles: { sourceHandle. targetHandle }.
	self addDiagramChild: sourceHandle.
	self addDiagramChild: targetHandle.
	waypoints := self stagedWaypointsOf: anEdge.
	waypoints size >= 2 ifTrue: [
		aVisual positionReconnectHandlesAtSource: waypoints first target: waypoints last ]
]

{ #category : 'private - reconnecting' }
CPCollaborationVisualElement >> beginMessageFlowReconnectFor: anEdge movingSource: movesSource event: anEvent [
	| waypoints fixedPoint pointer |
	self removeConnectionPreview.
	waypoints := self stagedWaypointsOf: anEdge.
	waypoints size < 2 ifTrue: [ ^ self ].
	fixedPoint := movesSource
		ifTrue: [ waypoints second ]
		ifFalse: [ waypoints at: waypoints size - 1 ].
	pointer := self diagramPointForGlobalPoint: anEvent position.
	connectionPreviewCursor := BlElement new
		extent: 1 @ 1;
		background: Color transparent;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: pointer;
		preventMeAndChildrenMouseEvents;
		yourself.
	connectionPreviewLine := BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: (movesSource ifTrue: [ pointer ] ifFalse: [ fixedPoint ]));
		toAnchor: (BlAbsolutePositionAnchor position: (movesSource ifTrue: [ fixedPoint ] ifFalse: [ pointer ]));
		border: (BlBorder paint: self selectionColor width: 1.5);
		constraintsDo: [ :c | c ignoreByLayout ];
		preventMeAndChildrenMouseEvents;
		yourself.
	self addDiagramChild: connectionPreviewCursor.
	self addDiagramChild: connectionPreviewLine
]

{ #category : 'private - reconnecting' }
CPCollaborationVisualElement >> updateMessageFlowReconnectFor: anEdge movingSource: movesSource event: anEvent [
	| candidate proposedWaypoints endpoint |
	connectionPreviewLine ifNil: [
		^ self beginMessageFlowReconnectFor: anEdge movingSource: movesSource event: anEvent ].
	connectionPreviewCursor relocate: (self diagramPointForGlobalPoint: anEvent position).
	candidate := self
		validMessageFlowReconnectTargetAtGlobalPoint: anEvent position
		forEdge: anEdge
		movingSource: movesSource.
	candidate ifNil: [
		endpoint := self diagramPointForGlobalPoint: anEvent position.
		movesSource
			ifTrue: [ connectionPreviewLine fromAnchor: (BlAbsolutePositionAnchor position: endpoint) ]
			ifFalse: [ connectionPreviewLine toAnchor: (BlAbsolutePositionAnchor position: endpoint) ].
		^ self ].
	proposedWaypoints := self
		proposedMessageFlowWaypointsFor: anEdge
		movingSource: movesSource
		to: candidate.
	proposedWaypoints ifNil: [ ^ self ].
	movesSource
		ifTrue: [ connectionPreviewLine fromAnchor: (BlAbsolutePositionAnchor position: proposedWaypoints first) ]
		ifFalse: [ connectionPreviewLine toAnchor: (BlAbsolutePositionAnchor position: proposedWaypoints last) ]
]

{ #category : 'private - reconnecting' }
CPCollaborationVisualElement >> endMessageFlowReconnectFor: anEdge movingSource: movesSource event: anEvent [
	| candidate operation assessment |
	candidate := self
		validMessageFlowReconnectTargetAtGlobalPoint: anEvent position
		forEdge: anEdge
		movingSource: movesSource.
	self removeConnectionPreview.
	candidate ifNil: [
		self updateSelectionAppearance.
		^ nil ].
	operation := self
		messageFlowReconnectOperationFor: anEdge
		movingSource: movesSource
		candidate: candidate.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable
		ifTrue: [ self refresh ]
		ifFalse: [ self updateSelectionAppearance ].
	^ assessment
]

{ #category : 'private - reconnecting' }
CPCollaborationVisualElement >> validMessageFlowReconnectTargetAtGlobalPoint: aGlobalPoint forEdge: anEdge movingSource: movesSource [
	| messageFlow currentEndpoint candidate operation assessment |
	messageFlow := self stagedModelElementOf: anEdge.
	currentEndpoint := movesSource
		ifTrue: [ collaborationContext stagedSourceOf: messageFlow ]
		ifFalse: [ collaborationContext stagedTargetOf: messageFlow ].
	candidate := self messageFlowEndpointAtGlobalPoint: aGlobalPoint excluding: currentEndpoint.
	candidate ifNil: [ ^ nil ].
	operation := self
		messageFlowReconnectOperationFor: anEdge
		movingSource: movesSource
		candidate: candidate.
	operation ifNil: [ ^ nil ].
	assessment := operation assess.
	^ assessment isApplicable ifTrue: [ candidate ] ifFalse: [ nil ]
]

{ #category : 'private - reconnecting' }
CPCollaborationVisualElement >> messageFlowReconnectOperationFor: anEdge movingSource: movesSource candidate: aCandidate [
	| messageFlow source target sourceShape targetShape proposedWaypoints |
	messageFlow := self stagedModelElementOf: anEdge.
	messageFlow ifNil: [ ^ nil ].
	source := collaborationContext stagedSourceOf: messageFlow.
	target := collaborationContext stagedTargetOf: messageFlow.
	movesSource ifTrue: [ source := aCandidate ] ifFalse: [ target := aCandidate ].
	sourceShape := self diagramShapeForMessageFlowEndpoint: source.
	targetShape := self diagramShapeForMessageFlowEndpoint: target.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [ ^ nil ].
	proposedWaypoints := self
		proposedMessageFlowWaypointsFor: anEdge
		source: source
		target: target.
	proposedWaypoints ifNil: [ ^ nil ].
	^ diagramEditing
		reconnectEdge: anEdge
		sourceShape: sourceShape
		targetShape: targetShape
		waypoints: proposedWaypoints
]

{ #category : 'private - reconnecting' }
CPCollaborationVisualElement >> messageFlowEndpointAtGlobalPoint: aGlobalPoint excluding: anEndpoint [
	| processCandidate participantCandidate |
	processCandidate := processVisual
		ifNil: [ nil ]
		ifNotNil: [ :aVisual |
			aVisual messageFlowEndpointAtGlobalPoint: aGlobalPoint excluding: anEndpoint ].
	processCandidate ifNotNil: [ ^ processCandidate ].
	participantCandidate := self
		participantAtCollaborationPoint: (self diagramPointForGlobalPoint: aGlobalPoint)
		excludingEndpoint: nil.
	^ participantCandidate
]

{ #category : 'private - reconnecting' }
CPCollaborationVisualElement >> diagramShapeForMessageFlowEndpoint: anEndpoint [
	anEndpoint ifNil: [ ^ nil ].
	anEndpoint isParticipant ifTrue: [ ^ self participantShapeFor: anEndpoint ].
	processVisual ifNil: [ ^ nil ].
	^ processVisual diagramShapeForModelElement: anEndpoint
]

{ #category : 'connection geometry' }
CPCollaborationVisualElement >> proposedMessageFlowWaypointsFor: anEdge movingSource: movesSource to: aCandidate [
	| messageFlow source target |
	messageFlow := self stagedModelElementOf: anEdge.
	messageFlow ifNil: [ ^ nil ].
	source := collaborationContext stagedSourceOf: messageFlow.
	target := collaborationContext stagedTargetOf: messageFlow.
	movesSource ifTrue: [ source := aCandidate ] ifFalse: [ target := aCandidate ].
	^ self proposedMessageFlowWaypointsFor: anEdge source: source target: target
]

{ #category : 'connection geometry' }
CPCollaborationVisualElement >> proposedMessageFlowWaypointsFor: anEdge source: aSource target: aTarget [
	| waypoints sourceToward targetToward sourcePoint targetPoint |
	waypoints := (self stagedWaypointsOf: anEdge) asOrderedCollection copy.
	waypoints size < 2 ifTrue: [ ^ nil ].
	waypoints size = 2
		ifTrue: [
			sourceToward := self collaborationCenterForMessageFlowEndpoint: aTarget.
			targetToward := self collaborationCenterForMessageFlowEndpoint: aSource ]
		ifFalse: [
			sourceToward := waypoints second.
			targetToward := waypoints at: waypoints size - 1 ].
	(sourceToward isNil or: [ targetToward isNil ]) ifTrue: [ ^ nil ].
	sourcePoint := self collaborationDockingPointForMessageFlowEndpoint: aSource toward: sourceToward.
	targetPoint := self collaborationDockingPointForMessageFlowEndpoint: aTarget toward: targetToward.
	(sourcePoint isNil or: [ targetPoint isNil ]) ifTrue: [ ^ nil ].
	waypoints at: 1 put: sourcePoint.
	waypoints at: waypoints size put: targetPoint.
	^ waypoints species withAll: waypoints
]

{ #category : 'connection geometry' }
CPCollaborationVisualElement >> collaborationCenterForMessageFlowEndpoint: anEndpoint [
	| shape bounds |
	anEndpoint ifNil: [ ^ nil ].
	anEndpoint isParticipant ifTrue: [
		shape := self participantShapeFor: anEndpoint.
		shape ifNil: [ ^ nil ].
		^ (self stagedBoundsOf: shape) center ].
	processVisual ifNil: [ ^ nil ].
	shape := processVisual diagramShapeForModelElement: anEndpoint.
	shape ifNil: [ ^ nil ].
	bounds := processVisual stagedBoundsOf: shape.
	^ self collaborationPointForProcessRootPoint:
		(processVisual rootDiagramPointForLocalPoint: bounds center)
]

{ #category : 'connection geometry' }
CPCollaborationVisualElement >> collaborationDockingPointForMessageFlowEndpoint: anEndpoint toward: aPoint [
	anEndpoint ifNil: [ ^ nil ].
	anEndpoint isParticipant ifTrue: [
		^ self dockingPointForParticipant: anEndpoint toward: aPoint ].
	processVisual ifNil: [ ^ nil ].
	(processVisual diagramShapeForModelElement: anEndpoint) ifNil: [ ^ nil ].
	^ self collaborationDockingPointForFlowNode: anEndpoint inVisual: processVisual toward: aPoint
]


{ #category : 'private - creation' }
CPCollaborationVisualElement >> installPaletteDropHandler [
	self addEventHandler: (CPProcessPaletteDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea |
			self acceptsParticipantPaletteDragItem: aDragItem ];
		whenDroppedDo: [ :anEvent |
			self dropParticipantPaletteEvent: anEvent ];
		yourself)
]

{ #category : 'private - creation' }
CPCollaborationVisualElement >> installPoolStructuralDropOnParticipantHeader: aHeaderElement [
	aHeaderElement addEventHandler: (CPProcessPaletteDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea |
			processVisual acceptsPoolPaletteDragItemForNewLaneSet: aDragItem ];
		whenDroppedDo: [ :anEvent |
			self dropPoolStructuralItemOnParticipantHeader: anEvent ];
		yourself)
]

{ #category : 'private - creation' }
CPCollaborationVisualElement >> dropPoolStructuralItemOnParticipantHeader: anEvent [
	| globalPoint |
	anEvent items size = 1 ifFalse: [ ^ self ].
	globalPoint := anEvent currentTarget
		localPointToGlobal: anEvent position.
	^ processVisual createLaneSetFromPoolPaletteAtGlobalPoint: globalPoint
]

{ #category : 'private - creation' }
CPCollaborationVisualElement >> isProcessPoolPaletteDragItem: aDragItem [
	processVisual ifNil: [ ^ false ].
	^ processVisual isPoolPaletteDragItem: aDragItem
]

{ #category : 'private - creation' }
CPCollaborationVisualElement >> acceptsParticipantPaletteDragItem: aDragItem [
	| sourceElement candidate operation assessment |
	sourceElement := aDragItem sourceElement.
	sourceElement ifNil: [ ^ false ].
	(sourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	(self isProcessPoolPaletteDragItem: aDragItem) ifTrue: [ ^ false ].
	candidate := aDragItem domainObject.
	candidate isParticipant ifFalse: [ ^ false ].
	operation := diagramEditing
		createParticipant: candidate
		bounds: (0 @ 0 extent: self defaultBlackBoxParticipantExtent).
	operation ifNil: [ ^ false ].
	assessment := operation assess.
	^ assessment isApplicable
]
{ #category : 'private - creation' }
CPCollaborationVisualElement >> dropParticipantPaletteEvent: anEvent [
	| dragItem participant dropPoint bounds operation assessment |
	anEvent items size = 1 ifFalse: [ ^ self ].
	dragItem := anEvent items first.
	(self isProcessPoolPaletteDragItem: dragItem) ifTrue: [ ^ self ].
	participant := dragItem domainObject.
	participant isParticipant ifFalse: [ ^ self ].
	dropPoint := self diagramPointForGlobalPoint:
		(anEvent currentTarget localPointToGlobal: anEvent position).
	bounds := (dropPoint - (self defaultBlackBoxParticipantExtent / 2))
		extent: self defaultBlackBoxParticipantExtent.
	operation := diagramEditing
		createParticipant: participant
		bounds: bounds.
	operation ifNil: [ ^ nil ].
	assessment := operation apply.
	assessment isApplicable ifTrue: [ self refresh ].
	^ assessment
]

{ #category : 'private - creation' }
CPCollaborationVisualElement >> defaultBlackBoxParticipantExtent [
	^ 620 @ 100
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedParticipants [
	^ collaborationContext participants
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedProcessRefOfParticipant: aParticipant [
	^ collaborationContext processRefOf: aParticipant
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedParticipantForProcess: aProcess [
	^ self stagedParticipants
		detect: [ :each |
			(self stagedProcessRefOfParticipant: each) == aProcess ]
		ifNone: [ nil ]
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedWaypointsOf: anEdge [
	^ diagramContext waypointsOf: anEdge
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedLabelSegmentIndexOf: anEdge [
	^ diagramContext labelSegmentIndexOf: anEdge
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedLabelSegmentPositionOf: anEdge [
	^ diagramContext labelSegmentPositionOf: anEdge
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedLabelOffsetOf: anEdge [
	^ diagramContext labelOffsetOf: anEdge
]


{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedBoundsOf: aShape [
	^ diagramContext boundsOf: aShape
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedModelElementOf: aShape [
	^ diagramContext modelElementOf: aShape
]

{ #category : 'private - theme' }
CPCollaborationVisualElement >> selectionColor [
	^ self theme item selectedColor
]

{ #category : 'private - theme' }
CPCollaborationVisualElement >> poolBackgroundColor [
	^ Color transparent
]

{ #category : 'private - theme' }
CPCollaborationVisualElement >> poolBorderColor [
	^ self resolvedThemeColor: self theme typography primaryForeground
]

{ #category : 'private - theme' }
CPCollaborationVisualElement >> resolvedThemeColor: aThemeableColor [
	^ aThemeableColor blocResolveColorForTheme: self theme
]

{ #category : 'accessing - presentation' }
CPCollaborationVisualElement >> canvasExtent [
	^ diagramViewport canvasExtent
]

{ #category : 'accessing - presentation' }
CPCollaborationVisualElement >> viewportExtent [
	^ viewportExtent
]

{ #category : 'accessing - presentation' }
CPCollaborationVisualElement >> diagramExtent [
	^ planeGeometry diagramExtent
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> viewportExtent: anExtent [
	viewportExtent := anExtent max: 1 @ 1.
	self updateCanvasExtent
]

{ #category : 'private - layout' }
CPCollaborationVisualElement >> updateCanvasExtent [
	diagramViewport := CPDiagramViewport
		viewportExtent: viewportExtent
		diagramExtent: planeGeometry diagramExtent.
	self constraintsDo: [ :c |
		c horizontal exact: diagramViewport canvasExtent x.
		c vertical exact: diagramViewport canvasExtent y ].
	self updateDiagramLayerGeometry
]

{ #category : 'private - layout' }
CPCollaborationVisualElement >> updateDiagramLayerGeometry [
	diagramLayer ifNil: [ ^ self ].
	planeGeometry ifNil: [ ^ self ].
	diagramLayer
		constraintsDo: [ :c | c ignoreByLayout ];
		extent: planeGeometry layerExtent;
		relocate: self diagramContentOffset
]

{ #category : 'accessing - presentation' }
CPCollaborationVisualElement >> cameraSlack [
	^ diagramViewport cameraSlack
]


{ #category : 'geometry' }
CPCollaborationVisualElement >> diagramContentOffset [
	^ diagramViewport cameraSlack + planeGeometry normalizationOffset
]


{ #category : 'geometry' }
CPCollaborationVisualElement >> diagramBoundsOriginInContent [
	^ self diagramContentOffset + planeGeometry diagramBounds origin
]

{ #category : 'accessing - presentation' }
CPCollaborationVisualElement >> diagramBounds [
	^ planeGeometry diagramBounds
]

{ #category : 'private - coordinates' }
CPCollaborationVisualElement >> diagramPointForGlobalPoint: aGlobalPoint [
	^ diagramLayer
		ifNil: [ self globalPointToLocal: aGlobalPoint ]
		ifNotNil: [ diagramLayer globalPointToLocal: aGlobalPoint ]
]

{ #category : 'private - building' }
CPCollaborationVisualElement >> addDiagramChild: anElement [
	diagramLayer
		ifNil: [ self addChild: anElement ]
		ifNotNil: [ diagramLayer addChild: anElement ]
]

{ #category : 'private - coordinates' }
CPCollaborationVisualElement >> diagramPresentationParent [
	^ diagramLayer ifNil: [ self ]
]



{ #category : 'accessing - testing' }
CPCollaborationVisualElement >> collaboration [
	^ collaborationContext ifNotNil: [ collaborationContext collaboration ]
]

{ #category : 'accessing - testing' }
CPCollaborationVisualElement >> processVisual [
	^ processVisual
]

{ #category : 'accessing - testing' }
CPCollaborationVisualElement >> participantElementsByParticipant [
	^ participantElementsByParticipant
]


{ #category : 'accessing - testing' }
CPCollaborationVisualElement >> messageFlowVisualsByEdge [
	^ messageFlowVisualsByEdge
]


{ #category : 'geometry' }
CPCollaborationVisualElement >> hostedProcessBodyExtent [
	| participant participantShape bounds |
	participant := self stagedParticipantForProcess: processMemento model.
	participant ifNil: [ ^ nil ].
	participantShape := self participantShapeFor: participant.
	participantShape ifNil: [ ^ nil ].
	bounds := self stagedBoundsOf: participantShape.
	^ (bounds width - CPParticipantShapeElement processContentOriginOffset x)
		@ bounds height
]
