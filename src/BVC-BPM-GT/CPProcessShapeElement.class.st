"I render the local visual representation of one CPShape.

The CPShape and its semantic flow node remain model objects. I own only their Bloc depiction: BPMN shape geometry, local label layout, event decoration, and selection border appearance. Diagram-level interaction and semantic editing remain coordinated by CPProcessVisualElement and Atelier operations."
Class {
	#name : 'CPProcessShapeElement',
	#superclass : 'BlElement',
	#instVars : [
		'diagramShape',
		'modelElement',
		'labelElement',
		'normalBorderColor',
		'resizeHandle'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessShapeElement >> shape: aShape modelElement: aFlowNode bounds: aRectangle background: aBackground borderColor: aBorderColor label: anEditableLabel [
	diagramShape := aShape.
	modelElement := aFlowNode.
	labelElement := anEditableLabel.
	normalBorderColor := aBorderColor.
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
	self addIntermediateEventDecorationForBounds: aRectangle
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
			c frame horizontal alignCenter.
			c frame vertical alignCenter ].
	self addChild: labelElement
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
	^ modelElement isEndEvent ifTrue: [ 3 ] ifFalse: [ 1.5 ]
]

{ #category : 'private - appearance' }
CPProcessShapeElement >> selectedBorderWidth [
	^ modelElement isEndEvent ifTrue: [ 4.5 ] ifFalse: [ 3 ]
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

