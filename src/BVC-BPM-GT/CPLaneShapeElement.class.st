"I render one BPMN Lane as a native Bloc structural region inside CPLaneSetVisualElement.

I own the Lane header and body surfaces. My outer geometry is an exact projection of the staged CPShape bounds supplied by CPProcessVisualElement. The header is presentation chrome inside that rectangle; it does not alter BPMN-DI coordinates. The CPShape remains the durable BPMN-DI representation."
Class {
	#name : 'CPLaneShapeElement',
	#superclass : 'BlElement',
	#instVars : [
		'lane',
		'diagramShape',
		'labelBand',
		'bodyHost',
		'labelElement',
		'orientation'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPLaneShapeElement >> lane: aLane shape: aShape borderColor: aBorderColor label: anEditableLabel [
	^ self
		lane: aLane
		shape: aShape
		borderColor: aBorderColor
		label: anEditableLabel
		horizontal: aShape isHorizontal
]

{ #category : 'initialization' }
CPLaneShapeElement >> lane: aLane shape: aShape borderColor: aBorderColor label: anEditableLabel horizontal: isHorizontal [
	lane := aLane.
	diagramShape := aShape.
	labelElement := anEditableLabel.
	orientation := isHorizontal
		ifTrue: [ CPHorizontalPoolLaneOrientation new ]
		ifFalse: [ CPVerticalPoolLaneOrientation new ].
	self userData at: #processDiagramElement put: aShape.
	self userData at: #processModelElement put: aLane.
	self
		geometry: BlRectangleGeometry new;
		background: Color transparent;
		border: (BlBorder paint: aBorderColor width: self normalBorderWidth);
		layout: BlFrameLayout new;
		clipChildren: false.
	self
		addBodyHost;
		addLaneHeaderBorderColor: aBorderColor
]

{ #category : 'private - building' }
CPLaneShapeElement >> addBodyHost [
	bodyHost := BlElement new
		background: Color transparent;
		layout: BlFrameLayout new;
		clipChildren: true;
		yourself.
	orientation configureLaneBodyHost: bodyHost.
	self addChild: bodyHost
]

{ #category : 'private - building' }
CPLaneShapeElement >> addLaneHeaderBorderColor: aBorderColor [
	labelBand := BlElement new
		geometry: BlRectangleGeometry new;
		background: Color transparent;
		border: (BlBorder paint: aBorderColor width: 1);
		layout: BlFrameLayout new;
		yourself.
	orientation
		configureLaneLabelBand: labelBand
		label: labelElement.
	labelBand addChild: labelElement.
	self addChild: labelBand
]

{ #category : 'geometry' }
CPLaneShapeElement >> bodyOriginOffset [
	^ orientation laneBodyOriginOffset
]

{ #category : 'geometry' }
CPLaneShapeElement class >> laneHeaderWidth [
	^ 30
]

{ #category : 'geometry' }
CPLaneShapeElement >> laneHeaderWidth [
	^ self class laneHeaderWidth
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
CPLaneShapeElement >> bodyHost [
	^ bodyHost
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
	| borderColor |
	borderColor := isSelected
		ifTrue: [ aSelectionColor ]
		ifFalse: [ aNormalColor ].
	self border: (BlBorder
		paint: borderColor
		width: (isSelected ifTrue: [ self selectedBorderWidth ] ifFalse: [ self normalBorderWidth ])).
	labelBand border: (BlBorder paint: borderColor width: 1)
]


{ #category : 'accessing - testing' }
CPLaneShapeElement >> orientation [
	^ orientation
]
