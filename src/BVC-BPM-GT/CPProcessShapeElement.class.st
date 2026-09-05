"I render and locally interact with one CPShape.

The CPShape and its semantic flow node remain model objects. I own their Bloc depiction and shape-local affordances: geometry, labels, decoration, selection appearance, resize, connection port, replacement/type UI, and local pointer mechanics. CPProcessVisualElement coordinates relationships between diagram objects and delegates semantic edits to Atelier operations."
Class {
	#name : 'CPProcessShapeElement',
	#superclass : 'BlElement',
	#instVars : [
		'diagramShape',
		'modelElement',
		'labelElement',
		'normalBorderColor',
		'resizeHandle',
		'connectionPort',
		'externalLabelHost',
		'isExpanded',
		'subProcessExpansionMarker',
		'nestedProcessViewport',
		'nestedProcessVisual'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessShapeElement >> shape: aShape modelElement: aFlowNode bounds: aRectangle background: aBackground borderColor: aBorderColor label: anEditableLabel [
	^ self
		shape: aShape
		modelElement: aFlowNode
		bounds: aRectangle
		background: aBackground
		borderColor: aBorderColor
		label: anEditableLabel
		expanded: aShape isExpanded
]

{ #category : 'initialization' }
CPProcessShapeElement >> shape: aShape modelElement: aFlowNode bounds: aRectangle background: aBackground borderColor: aBorderColor label: anEditableLabel expanded: aBoolean [
	diagramShape := aShape.
	modelElement := aFlowNode.
	labelElement := anEditableLabel.
	normalBorderColor := aBorderColor.
	externalLabelHost := nil.
	isExpanded := aBoolean.
	subProcessExpansionMarker := nil.
	self userData at: #processDiagramElement put: aShape.
	self userData at: #processModelElement put: aFlowNode.
	self
		extent: aRectangle extent;
		geometry: (self geometryFor: aFlowNode bounds: aRectangle);
		background: aBackground;
		border: (BlBorder
			paint: aBorderColor
			width: self normalBorderWidth);
		layout: BlFrameLayout new.
	self addActivityLabelForBounds: aRectangle.
	self addIntermediateEventDecorationForBounds: aRectangle.
	self addCallActivityDecorationForBounds: aRectangle.
	self addSubProcessDecorationForBounds: aRectangle
]


{ #category : 'accessing' }
CPProcessShapeElement >> diagramShape [
	^ diagramShape
]

{ #category : 'accessing' }
CPProcessShapeElement >> modelElement [
	^ modelElement
]

{ #category : 'accessing' }
CPProcessShapeElement >> labelElement [
	^ labelElement
]

{ #category : 'private - geometry' }
CPProcessShapeElement >> geometryFor: aFlowNode bounds: aRectangle [
	aFlowNode isEvent ifTrue: [ ^ BlCircleGeometry new ].
	aFlowNode isActivity ifTrue: [ ^ BlRoundedRectangleGeometry cornerRadius: 8 ].
	aFlowNode isGateway ifTrue: [
		^ BlPolygonGeometry vertices: {
			aRectangle width / 2 @ 0.
			aRectangle width @ (aRectangle height / 2).
			aRectangle width / 2 @ aRectangle height.
			0 @ (aRectangle height / 2) } ].
	^ BlRectangleGeometry new
]

{ #category : 'private - labels' }
CPProcessShapeElement >> addActivityLabelForBounds: aRectangle [
	labelElement ifNil: [ ^ self ].
	labelElement
		hFitContentLimited;
		vFitContent;
		constraintsDo: [ :c |
			c maxWidth: (aRectangle width - 20 max: 1).
			(modelElement isSubProcess and: [ isExpanded ])
				ifTrue: [
					c frame horizontal alignLeft.
					c frame vertical alignTop.
					c margin: (BlInsets top: 10 left: 12) ]
				ifFalse: [
					c frame horizontal alignCenter.
					c frame vertical alignCenter.
					modelElement isSubProcess ifTrue: [
						c margin: (BlInsets bottom: 4) ] ] ].
	self addChild: labelElement
]

{ #category : 'private - decoration' }
CPProcessShapeElement >> addCallActivityDecorationForBounds: aRectangle [
	| marker horizontalBar verticalBar markerExtent |
	(modelElement isCallActivity and: [ modelElement calledElement notNil ]) ifFalse: [ ^ self ].
	markerExtent := 14 @ 14.
	marker := BlElement new
		extent: markerExtent;
		geometry: BlRectangleGeometry new;
		background: Color transparent;
		border: (BlBorder paint: self normalBorderColor width: 1.5);
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignBottom.
			c margin: (BlInsets bottom: 4) ];
		preventMeAndChildrenMouseEvents;
		yourself.
	horizontalBar := BlElement new
		extent: 8 @ 1.5;
		background: self normalBorderColor;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		preventMeAndChildrenMouseEvents;
		yourself.
	verticalBar := BlElement new
		extent: 1.5 @ 8;
		background: self normalBorderColor;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		preventMeAndChildrenMouseEvents;
		yourself.
	marker
		addChild: horizontalBar;
		addChild: verticalBar.
	self addChild: marker
]

{ #category : 'private - decoration' }
CPProcessShapeElement >> addIntermediateEventDecorationForBounds: aRectangle [
	| innerRing |
	modelElement isIntermediateEvent ifFalse: [ ^ self ].
	innerRing := BlElement new
		extent: aRectangle extent - (8 @ 8);
		geometry: BlCircleGeometry new;
		background: Color transparent;
		border: (BlBorder paint: self normalBorderColor width: 1.5);
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		preventMeAndChildrenMouseEvents;
		yourself.
	self addChild: innerRing
]

{ #category : 'private - appearance' }
CPProcessShapeElement >> normalBorderColor [
	^ normalBorderColor
]

{ #category : 'private - appearance' }
CPProcessShapeElement >> normalBorderWidth [
	^ (modelElement isEndEvent or: [ modelElement isCallActivity ])
		ifTrue: [ 3 ]
		ifFalse: [ 1.5 ]
]

{ #category : 'private - appearance' }
CPProcessShapeElement >> selectedBorderWidth [
	^ (modelElement isEndEvent or: [ modelElement isCallActivity ])
		ifTrue: [ 4.5 ]
		ifFalse: [ 3 ]
]

{ #category : 'appearance' }
CPProcessShapeElement >> selected: isSelected selectionColor: aSelectionColor normalColor: aNormalColor [
	self border: (BlBorder
		paint: (isSelected ifTrue: [ aSelectionColor ] ifFalse: [ aNormalColor ])
		width: (isSelected ifTrue: [ self selectedBorderWidth ] ifFalse: [ self normalBorderWidth ]))
]

{ #category : 'resizing' }
CPProcessShapeElement >> installResizeHandleMinimumExtent: aMinimumExtent selectionColor: aSelectionColor stagedBounds: aStagedBoundsBlock resize: aResizeBlock geometryChanged: aGeometryChangedBlock [
	| handleExtent isDragging dragStartEventPosition dragStartExtent |
	handleExtent := 9 @ 9.
	isDragging := false.
	resizeHandle := BlElement new
		extent: handleExtent;
		geometry: BlRectangleGeometry new;
		background: Color white;
		border: (BlBorder paint: aSelectionColor width: 1.5);
		visibility: BlVisibility hidden;
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.
	self positionResizeHandle.
	resizeHandle
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent | anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				isDragging := true.
				dragStartEventPosition := anEvent position.
				dragStartExtent := self extent.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| delta proposedExtent |
					delta := anEvent position - dragStartEventPosition.
					proposedExtent :=
						((dragStartExtent x + delta x) max: aMinimumExtent x)
						@ ((dragStartExtent y + delta y) max: aMinimumExtent y).
					self extent: proposedExtent.
					self positionResizeHandle.
					aGeometryChangedBlock ifNotNil: [ aGeometryChangedBlock value ].
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| currentBounds proposedBounds |
					isDragging := false.
					currentBounds := aStagedBoundsBlock value.
					proposedBounds := currentBounds origin extent: self extent.
					aResizeBlock value: proposedBounds.
					anEvent consumed: true ] ]).
	^ resizeHandle
]

{ #category : 'resizing' }
CPProcessShapeElement >> positionResizeHandle [
	resizeHandle ifNil: [ ^ self ].
	resizeHandle relocate:
		self position
			+ self extent
			- (resizeHandle extent / 2)
]

{ #category : 'resizing' }
CPProcessShapeElement >> resizeHandle [
	^ resizeHandle
]

{ #category : 'resizing' }
CPProcessShapeElement >> resizeHandleVisible: aBoolean [
	resizeHandle ifNil: [ ^ self ].
	resizeHandle visibility: (aBoolean
		ifTrue: [ BlVisibility visible ]
		ifFalse: [ BlVisibility hidden ])
]

{ #category : 'connection' }
CPProcessShapeElement >> installConnectionPortSelectionColor: aSelectionColor borderColor: aBorderColor beginConnection: aBeginBlock dragStarted: aDragStartBlock dragged: aDragBlock dragEnded: aDragEndBlock [
	| isDragging didDrag |
	isDragging := false.
	didDrag := false.
	connectionPort := BlElement new
		extent: 12 @ 12;
		geometry: BlCircleGeometry new;
		background: aSelectionColor;
		border: (BlBorder paint: aBorderColor width: 1.5);
		visibility: BlVisibility hidden;
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignCenter ];
		yourself.
	connectionPort
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent |
				didDrag
					ifTrue: [ didDrag := false ]
					ifFalse: [ aBeginBlock value ].
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				isDragging := true.
				didDrag := true.
				aDragStartBlock value: anEvent.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					aDragBlock value: anEvent.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					isDragging := false.
					aDragEndBlock value: anEvent.
					anEvent consumed: true ] ]).
	self addChild: connectionPort.
	^ connectionPort
]

{ #category : 'connection' }
CPProcessShapeElement >> connectionPort [
	^ connectionPort
]

{ #category : 'connection' }
CPProcessShapeElement >> connectionPortVisible: aBoolean [
	connectionPort ifNil: [ ^ self ].
	connectionPort visibility: (aBoolean
		ifTrue: [ BlVisibility visible ]
		ifFalse: [ BlVisibility hidden ])
]

{ #category : 'replacement' }
CPProcessShapeElement >> installPaletteReplacementAccepting: anAcceptBlock dropped: aDropBlock [
	self addEventHandler: (CPProcessPaletteDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea | anAcceptBlock value: aDragItem ];
		whenDroppedDo: [ :anEvent | aDropBlock value: anEvent ];
		yourself)
]

{ #category : 'type selection' }
CPProcessShapeElement >> installTypePopup: aPopup visibleIcon: aVisibleIcon iconExtent: anExtent configure: aConfigureBlock selectedClass: aSelectedClassBlock replacementSelected: aReplacementBlock [
	| visibleHost |
	aVisibleIcon constraintsDo: [ :c |
		c frame horizontal alignCenter.
		c frame vertical alignCenter ].
	visibleHost := BlElement new
		extent: anExtent;
		layout: BlFrameLayout new;
		addChild: aVisibleIcon;
		yourself.
	aConfigureBlock value: visibleHost.
	self addChild: visibleHost.

	aPopup
		opacity: 0.0;
		extent: anExtent.
	aConfigureBlock value: aPopup.
	aPopup
		when: BrDropdownIsHidden
		do: [ :anEvent |
			| selectedClass |
			selectedClass := aSelectedClassBlock value.
			selectedClass == modelElement class ifFalse: [
				self enqueueTask: (BlTaskAction new action: [
					aReplacementBlock value: selectedClass ]) ] ].
	self addChild: aPopup
]

{ #category : 'positioning' }
CPProcessShapeElement >> installPositioningFrom: anInteractionElement stagedBounds: aStagedBoundsBlock dragStarted: aDragStartBlock dragged: aDragBlock dragEnded: aDragEndBlock [
	| isDragging dragStartEventPosition dragStartElementPosition originalBounds |
	isDragging := false.
	anInteractionElement
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				dragStartEventPosition := anEvent position.
				dragStartElementPosition := self position.
				originalBounds := aStagedBoundsBlock value.
				isDragging := true.
				aDragStartBlock value: anEvent value: originalBounds.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| proposedPosition delta |
					proposedPosition := dragStartElementPosition + anEvent position - dragStartEventPosition.
					self relocate: proposedPosition.
					delta := self position - dragStartElementPosition.
					aDragBlock value: anEvent value: delta.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| proposedBounds delta |
					isDragging := false.
					delta := self position - dragStartElementPosition.
					proposedBounds := self position extent: originalBounds extent.
					aDragEndBlock value: anEvent value: proposedBounds value: delta.
					anEvent consumed: true ] ])
]

{ #category : 'external label' }
CPProcessShapeElement >> externalLabelHost [
	^ externalLabelHost
]

{ #category : 'external label' }
CPProcessShapeElement >> externalLabelHost: anElement [
	externalLabelHost := anElement
]

{ #category : 'external label' }
CPProcessShapeElement >> bringExternalLabelToFrontIn: aParent [
	externalLabelHost ifNil: [ ^ self ].
	externalLabelHost removeFromParent.
	aParent addChild: externalLabelHost
]

{ #category : 'private - decoration' }
CPProcessShapeElement >> addSubProcessDecorationForBounds: aRectangle [
	modelElement isSubProcess ifFalse: [ ^ self ].
	subProcessExpansionMarker := (FontAwesomeIcons
		icon: (isExpanded
			ifTrue: [ #squareMinus ]
			ifFalse: [ #squarePlus ]))
		size: 14 @ 14;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignBottom.
			c margin: (BlInsets bottom: 4) ];
		allowMeAndChildrenMouseEvents;
		yourself.
	self addChild: subProcessExpansionMarker
]

{ #category : 'interaction - subprocess' }
CPProcessShapeElement >> installSubProcessExpansion: aBlock [
	subProcessExpansionMarker ifNil: [ ^ self ].
	subProcessExpansionMarker
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent |
				aBlock value: isExpanded not.
				anEvent consumed: true ])
]

{ #category : 'accessing - testing' }
CPProcessShapeElement >> subProcessExpansionMarker [
	^ subProcessExpansionMarker
]


{ #category : 'subprocess' }
CPProcessShapeElement >> hostNestedProcessVisual: aProcessVisual [
	nestedProcessVisual := aProcessVisual.
	nestedProcessViewport := BlElement new
		extent: self extent;
		geometry: BlRectangleGeometry new;
		background: Color transparent;
		layout: BlFrameLayout new;
		clipChildren: true;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: 0 @ 0;
		yourself.
	nestedProcessVisual
		hMatchParent;
		vMatchParent;
		constraintsDo: [ :c |
			c frame horizontal alignLeft.
			c frame vertical alignTop ].
	nestedProcessViewport addChild: nestedProcessVisual.
	self addChildFirst: nestedProcessViewport
]

{ #category : 'accessing - testing' }
CPProcessShapeElement >> nestedProcessViewport [
	^ nestedProcessViewport
]

{ #category : 'accessing - testing' }
CPProcessShapeElement >> nestedProcessVisual [
	^ nestedProcessVisual
]
