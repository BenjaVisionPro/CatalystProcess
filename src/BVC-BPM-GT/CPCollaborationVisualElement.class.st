"I render the definitional Collaboration of one root CPProcess.

The enclosing Atelier transaction remains rooted at that CPProcess. I read the Process's definitionalCollaborationRef and its Collaboration DI, render each Participant as a CPParticipantShapeElement, and host the already-configured root CPProcessVisualElement inside the Participant whose processRef is the edited Process.

Black-box Participants render as Pools without Process content. Participant editing and MessageFlow rendering are separate subsequent capabilities."
Class {
	#name : 'CPCollaborationVisualElement',
	#superclass : 'BlElement',
	#instVars : [
		'processMemento',
		'processVisual',
		'collaboration',
		'collaborationMemento',
		'diagramMemento',
		'elementsDescription',
		'participantsDescription',
		'messageFlowsDescription',
		'createParticipantOperationBlock',
		'moveParticipantShapeOperationBlock',
		'resizeParticipantShapeOperationBlock',
		'selectionChangedBlock',
		'selectionModel',
		'participantElementsByParticipant',
		'messageFlowVisualsByEdge',
		'connectMessageFlowOperationBlock',
		'connectionPreviewLine',
		'connectionPreviewCursor',
		'viewportExtent',
		'diagramBounds',
		'diagramExtent',
		'canvasExtent',
		'diagramLayer',
		'cameraSlack'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPCollaborationVisualElement >> initialize [
	super initialize.
	participantElementsByParticipant := IdentityDictionary new.
	messageFlowVisualsByEdge := IdentityDictionary new.
	connectionPreviewLine := nil.
	connectionPreviewCursor := nil.
	selectionModel := CPDiagramSelectionModel new.
	viewportExtent := 1360 @ 800.
	diagramBounds := 0 @ 0 extent: 0 @ 0.
	diagramExtent := 0 @ 0.
	canvasExtent := 1360 @ 800.
	diagramLayer := nil.
	cameraSlack := 0 @ 0.
	self
		layout: BlFrameLayout new;
		clipChildren: false.
	self installPaletteDropHandler
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> processMemento: aMemento processVisual: aProcessVisual [
	processMemento := aMemento.
	processVisual := aProcessVisual.
	self refresh
]

{ #category : 'updating' }
CPCollaborationVisualElement >> refresh [
	| collaborationDescription diagramDescription diagram elements participantShapes messageFlowEdges stagedParticipants stagedMessageFlows |
	processVisual ifNotNil: [ processVisual removeFromParent ].
	self removeChildren.
	participantElementsByParticipant removeAll.
	messageFlowVisualsByEdge removeAll.

	collaborationDescription := processMemento magritteDescription
		detect: [ :each | each handlesSelector: #definitionalCollaborationRef ].
	collaboration := processMemento readUsing: collaborationDescription.
	collaboration ifNil: [ ^ self ].
	collaborationMemento := processMemento
		childMementoFor: collaboration
		inRelation: collaborationDescription.

	diagramDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	diagram := collaborationMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self ].
	diagramMemento := collaborationMemento
		childMementoFor: diagram
		inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	participantsDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #participants ].
	messageFlowsDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #messageFlows ].
	elements := diagramMemento readUsing: elementsDescription.
	stagedParticipants := collaborationMemento readUsing: participantsDescription.
	stagedMessageFlows := collaborationMemento readUsing: messageFlowsDescription.
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

	diagramBounds := self
		diagramBoundsForShapes: participantShapes
		edges: messageFlowEdges.
	diagramExtent := diagramBounds extent.
	diagramLayer := BlElement new
		layout: BlFrameLayout new;
		clipChildren: false;
		yourself.
	self addChild: diagramLayer.
	self updateCanvasExtent.
	participantShapes do: [ :each | self addParticipantShape: each ].
	messageFlowEdges do: [ :each | self addMessageFlowEdge: each ].
	self updateParticipantSelectionAppearance
]

{ #category : 'private - building' }
CPCollaborationVisualElement >> addParticipantShape: aShape [
	| participant bounds element |
	participant := self stagedModelElementOf: aShape.
	bounds := self stagedBoundsOf: aShape.
	(participant isNil or: [ bounds isNil ]) ifTrue: [ ^ self ].
	element := CPParticipantShapeElement new
		participant: participant
		shape: aShape
		bounds: bounds
		background: self poolBackgroundColor
		borderColor: self poolBorderColor.
	element
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: bounds origin.
	participantElementsByParticipant at: participant put: element.
	self addDiagramChild: element.
	self
		installSelectionOnParticipantElement: element participant: participant;
		installPositioningOnParticipantElement: element shape: aShape;
		installResizeOnParticipantElement: element shape: aShape.

	(self stagedProcessRefOfParticipant: participant) == processMemento model ifTrue: [
		processVisual collaborationVisual: self.
		element hostProcessVisual: processVisual ]
]

{ #category : 'private - selection' }
CPCollaborationVisualElement >> installSelectionOnParticipantElement: anElement participant: aParticipant [
	anElement addEventHandler: (BlEventHandler
		on: BlClickEvent
		do: [ :anEvent |
			anEvent modifiers isShift
				ifTrue: [ selectionModel toggle: aParticipant ]
				ifFalse: [ selectionModel selectOnly: aParticipant ].
			self updateParticipantSelectionAppearance.
			selectionChangedBlock ifNotNil: [ :aBlock | aBlock value: selectionModel selectedModelElement ].
			self requestFocus.
			anEvent consumed: true ]).
	anElement installBodyCursor
]

{ #category : 'selection' }
CPCollaborationVisualElement >> selectionModel [
	^ selectionModel
]

{ #category : 'selection' }
CPCollaborationVisualElement >> selectionModel: aSelectionModel [
	selectionModel := aSelectionModel.
	self updateParticipantSelectionAppearance
]

{ #category : 'private - selection' }
CPCollaborationVisualElement >> updateParticipantSelectionAppearance [
	participantElementsByParticipant keysAndValuesDo: [ :aParticipant :anElement |
		anElement
			selected: (selectionModel includes: aParticipant)
			selectionColor: self selectionColor
			normalColor: self poolBorderColor ]
]

{ #category : 'private - positioning' }
CPCollaborationVisualElement >> installPositioningOnParticipantElement: anElement shape: aShape [
	moveParticipantShapeOperationBlock ifNil: [ ^ self ].
	anElement
		installPositioningFrom: anElement labelBand
		stagedBounds: [ self stagedBoundsOf: aShape ]
		dragStarted: [ :anEvent :originalBounds |
			selectionModel selectOnly: anElement participant.
			self updateParticipantSelectionAppearance ]
		dragStartPosition: [ (self stagedBoundsOf: aShape) origin ]
		dragged: [ :anEvent :delta | ]
		dragEnded: [ :anEvent :proposedBounds :delta |
			| assessment |
			assessment := (moveParticipantShapeOperationBlock
				value: aShape
				value: proposedBounds) apply.
			self refresh ]
]

{ #category : 'private - resizing' }
CPCollaborationVisualElement >> installResizeOnParticipantElement: anElement shape: aShape [
	| handles |
	resizeParticipantShapeOperationBlock ifNil: [ ^ self ].
	handles := anElement
		installResizeHandleMinimumExtent: self minimumParticipantExtent
		stagedBounds: [ self stagedBoundsOf: aShape ]
		resize: [ :proposedBounds |
			(resizeParticipantShapeOperationBlock
				value: aShape
				value: proposedBounds) apply.
			self refresh ]
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
		label: (self stagedLabelOfMessageFlow: messageFlow)
		in: self diagramPresentationParent.
	messageFlowVisualsByEdge at: anEdge put: visual
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> connectMessageFlowOperationFor: aBlock [
	connectMessageFlowOperationBlock := aBlock
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> createParticipantOperationFor: aBlock [
	createParticipantOperationBlock := aBlock
]


{ #category : 'configuration' }
CPCollaborationVisualElement >> moveParticipantShapeOperationFor: aBlock [
	moveParticipantShapeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> resizeParticipantShapeOperationFor: aBlock [
	resizeParticipantShapeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> selectionChangedDo: aBlock [
	selectionChangedBlock := aBlock
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
				ifTrue: [ pointer ]
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
	| target assessment |
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
	connectMessageFlowOperationBlock ifNil: [ ^ nil ].
	assessment := (connectMessageFlowOperationBlock
		value: aSource
		value: target modelElement
		value: (self
			messageFlowWaypointsFrom: aSource
			inVisual: aSourceVisual
			toParticipant: target modelElement)) apply.
	assessment isApplicable ifTrue: [ self refresh ].
	^ assessment
]

{ #category : 'connection' }
CPCollaborationVisualElement >> connectionTargetAtGlobalPoint: aGlobalPoint from: aSource sourceVisual: aSourceVisual [
	| sequenceTarget participantTarget |
	sequenceTarget := aSourceVisual
		sequenceFlowTargetAtGlobalPoint: aGlobalPoint
		from: aSource.
	sequenceTarget ifNotNil: [ ^ CPCollaborationConnectionTarget sequenceFlowTo: sequenceTarget ].
	participantTarget := self
		participantAtCollaborationPoint: (self diagramPointForGlobalPoint: aGlobalPoint)
		excludingEndpoint: aSource.
	participantTarget ifNil: [ ^ nil ].
	^ (CPMessageFlowConnectionRules new
		assessConnectionFrom: aSource
		to: participantTarget
		participants: self stagedParticipants) isAllowed
			ifTrue: [ CPCollaborationConnectionTarget messageFlowTo: participantTarget ]
			ifFalse: [ nil ]
]

{ #category : 'connection' }
CPCollaborationVisualElement >> participantAtCollaborationPoint: aPoint excludingEndpoint: anEndpoint [
	| endpointParticipant |
	endpointParticipant := collaboration participantForEndpoint: anEndpoint.
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
	| shape bounds rootOrigin collaborationBounds |
	shape := aSourceVisual diagramShapeForModelElement: aFlowNode.
	bounds := aSourceVisual stagedBoundsOf: shape.
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
	^ bounds origin + participantElement processContentOriginOffset + aPoint
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
CPCollaborationVisualElement >> acceptsParticipantPaletteDragItem: aDragItem [
	| sourceElement candidate assessment |
	createParticipantOperationBlock ifNil: [ ^ false ].
	sourceElement := aDragItem sourceElement.
	sourceElement ifNil: [ ^ false ].
	(sourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	candidate := aDragItem domainObject.
	candidate isParticipant ifFalse: [ ^ false ].
	assessment := (createParticipantOperationBlock
		value: candidate
		value: (0 @ 0 extent: self defaultBlackBoxParticipantExtent)) assess.
	^ assessment isApplicable
]

{ #category : 'private - creation' }
CPCollaborationVisualElement >> dropParticipantPaletteEvent: anEvent [
	| dragItem participant dropPoint bounds assessment |
	anEvent items size = 1 ifFalse: [ ^ self ].
	dragItem := anEvent items first.
	participant := dragItem domainObject.
	participant isParticipant ifFalse: [ ^ self ].
	dropPoint := self diagramPointForGlobalPoint:
		(anEvent currentTarget localPointToGlobal: anEvent position).
	bounds := (dropPoint - (self defaultBlackBoxParticipantExtent / 2))
		extent: self defaultBlackBoxParticipantExtent.
	assessment := (createParticipantOperationBlock
		value: participant
		value: bounds) apply.
	assessment isApplicable ifTrue: [ self refresh ].
	^ assessment
]

{ #category : 'private - creation' }
CPCollaborationVisualElement >> defaultBlackBoxParticipantExtent [
	^ 620 @ 100
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedParticipants [
	^ collaborationMemento readUsing: participantsDescription
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedProcessRefOfParticipant: aParticipant [
	| participantMemento description |
	participantMemento := collaborationMemento
		childMementoFor: aParticipant
		inRelation: participantsDescription.
	description := participantMemento magritteDescription
		detect: [ :each | each handlesSelector: #processRef ].
	^ participantMemento readUsing: description
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
	| edgeMemento description |
	edgeMemento := diagramMemento
		childMementoFor: anEdge
		inRelation: elementsDescription.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	^ (edgeMemento readUsing: description) ifNil: [ #() ]
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedLabelOfMessageFlow: aMessageFlow [
	| flowMemento description |
	flowMemento := collaborationMemento
		childMementoFor: aMessageFlow
		inRelation: messageFlowsDescription.
	description := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #label ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedBoundsOf: aShape [
	| shapeMemento description |
	shapeMemento := diagramMemento
		childMementoFor: aShape
		inRelation: elementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	^ shapeMemento readUsing: description
]

{ #category : 'private - staged state' }
CPCollaborationVisualElement >> stagedModelElementOf: aShape [
	| shapeMemento description |
	shapeMemento := diagramMemento
		childMementoFor: aShape
		inRelation: elementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	^ shapeMemento readUsing: description
]

{ #category : 'private - layout' }
CPCollaborationVisualElement >> diagramBoundsForShapes: someShapes edges: someEdges [
	| minimumX minimumY maximumX maximumY hasContent |
	hasContent := false.
	someShapes do: [ :each |
		| bounds |
		bounds := self stagedBoundsOf: each.
		bounds ifNotNil: [
			hasContent := true.
			minimumX := minimumX ifNil: [ bounds left ] ifNotNil: [ minimumX min: bounds left ].
			minimumY := minimumY ifNil: [ bounds top ] ifNotNil: [ minimumY min: bounds top ].
			maximumX := maximumX ifNil: [ bounds right ] ifNotNil: [ maximumX max: bounds right ].
			maximumY := maximumY ifNil: [ bounds bottom ] ifNotNil: [ maximumY max: bounds bottom ] ] ].
	someEdges do: [ :each |
		(self stagedWaypointsOf: each) do: [ :aPoint |
			hasContent := true.
			minimumX := minimumX ifNil: [ aPoint x ] ifNotNil: [ minimumX min: aPoint x ].
			minimumY := minimumY ifNil: [ aPoint y ] ifNotNil: [ minimumY min: aPoint y ].
			maximumX := maximumX ifNil: [ aPoint x ] ifNotNil: [ maximumX max: aPoint x ].
			maximumY := maximumY ifNil: [ aPoint y ] ifNotNil: [ maximumY max: aPoint y ] ] ].
	hasContent ifFalse: [ ^ 0 @ 0 extent: 0 @ 0 ].
	^ minimumX @ minimumY corner: maximumX @ maximumY
]


{ #category : 'private - theme' }
CPCollaborationVisualElement >> selectionColor [
	^ self theme item selectedColor
]

{ #category : 'private - theme' }
CPCollaborationVisualElement >> poolBackgroundColor [
	^ self resolvedThemeColor: self theme surfaces baseBackground
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
	^ canvasExtent
]

{ #category : 'accessing - presentation' }
CPCollaborationVisualElement >> viewportExtent [
	^ viewportExtent
]

{ #category : 'accessing - presentation' }
CPCollaborationVisualElement >> diagramExtent [
	^ diagramExtent
]

{ #category : 'configuration' }
CPCollaborationVisualElement >> viewportExtent: anExtent [
	viewportExtent := anExtent max: 1 @ 1.
	self updateCanvasExtent
]

{ #category : 'private - layout' }
CPCollaborationVisualElement >> updateCanvasExtent [
	cameraSlack := (viewportExtent - diagramExtent) max: 0 @ 0.
	diagramExtent = (0 @ 0)
		ifTrue: [
			cameraSlack := 0 @ 0.
			canvasExtent := viewportExtent ]
		ifFalse: [
			canvasExtent := diagramExtent + (cameraSlack * 2) ].
	self constraintsDo: [ :c |
		c horizontal exact: canvasExtent x.
		c vertical exact: canvasExtent y ].
	self updateDiagramLayerGeometry
]

{ #category : 'private - layout' }
CPCollaborationVisualElement >> updateDiagramLayerGeometry [
	diagramLayer ifNil: [ ^ self ].
	diagramLayer
		constraintsDo: [ :c | c ignoreByLayout ];
		extent: (diagramBounds corner max: 1 @ 1);
		relocate: cameraSlack - diagramBounds origin
]

{ #category : 'accessing - presentation' }
CPCollaborationVisualElement >> cameraSlack [
	^ cameraSlack
]

{ #category : 'accessing - presentation' }
CPCollaborationVisualElement >> diagramBounds [
	^ diagramBounds
]

{ #category : 'private - coordinates' }
CPCollaborationVisualElement >> diagramPointForGlobalPoint: aGlobalPoint [
	^ diagramLayer
		ifNil: [ self globalPointToLocal: aGlobalPoint ]
		ifNotNil: [ diagramLayer globalPointToLocal: aGlobalPoint ]
]

{ #category : 'private - coordinates' }
CPCollaborationVisualElement >> globalPointForDiagramPoint: aPoint [
	^ diagramLayer
		ifNil: [ self localPointToGlobal: aPoint ]
		ifNotNil: [ diagramLayer localPointToGlobal: aPoint ]
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
	^ collaboration
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
