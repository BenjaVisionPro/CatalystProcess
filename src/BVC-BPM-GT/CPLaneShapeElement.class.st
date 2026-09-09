"I render one BPMN Lane partition behind its Process FlowNodes.

I own only Lane presentation: rectangular DI bounds, low-opacity fill, the BPMN lane label band, and selection appearance. Lane movement, resizing, and FlowNode reassignment remain Process editing concerns and are deliberately not installed here."
Class {
	#name : 'CPLaneShapeElement',
	#superclass : 'BlElement',
	#instVars : [
		'lane',
		'diagramShape',
		'labelBand',
		'labelElement',
		'normalBorderColor'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPLaneShapeElement >> lane: aLane shape: aShape bounds: aRectangle background: aBackground borderColor: aBorderColor label: anEditableLabel [
	lane := aLane.
	diagramShape := aShape.
	labelElement := anEditableLabel.
	normalBorderColor := aBorderColor.
	self userData at: #processDiagramElement put: aShape.
	self userData at: #processModelElement put: aLane.
	self
		extent: aRectangle extent;
		geometry: BlRectangleGeometry new;
		background: aBackground;
		border: (BlBorder paint: aBorderColor width: self normalBorderWidth);
		layout: BlFrameLayout new;
		clipChildren: false.
	self addLaneHeaderBorderColor: aBorderColor
]

{ #category : 'private - building' }
CPLaneShapeElement >> addLaneHeaderBorderColor: aBorderColor [
	labelBand := BlElement new
		geometry: BlRectangleGeometry new;
		background: Color transparent;
		border: (BlBorder paint: aBorderColor width: 1);
		layout: BlFrameLayout new;
		constraintsDo: [ :c |
			c horizontal exact: self laneHeaderWidth.
			c vertical matchParent.
			c frame horizontal alignLeft.
			c frame vertical alignTop ];
		yourself.
	labelElement
		hFitContent;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		transformDo: [ :aTransform | aTransform rotateBy: -90 ].
	labelBand addChild: labelElement.
	self addChild: labelBand
]

{ #category : 'geometry' }
CPLaneShapeElement >> laneHeaderWidth [
	^ 30
]

{ #category : 'accessing' }
CPLaneShapeElement >> lane [
	^ lane
]

{ #category : 'accessing' }
CPLaneShapeElement >> diagramShape [
	^ diagramShape
]

{ #category : 'accessing - testing' }
CPLaneShapeElement >> labelBand [
	^ labelBand
]

{ #category : 'accessing - testing' }
CPLaneShapeElement >> labelElement [
	^ labelElement
]

{ #category : 'private - appearance' }
CPLaneShapeElement >> normalBorderWidth [
	^ 1.5
]

{ #category : 'private - appearance' }
CPLaneShapeElement >> selectedBorderWidth [
	^ 3
]

{ #category : 'appearance' }
CPLaneShapeElement >> selected: isSelected selectionColor: aSelectionColor normalColor: aNormalColor [
	self border: (BlBorder
		paint: (isSelected ifTrue: [ aSelectionColor ] ifFalse: [ aNormalColor ])
		width: (isSelected ifTrue: [ self selectedBorderWidth ] ifFalse: [ self normalBorderWidth ]))
]
