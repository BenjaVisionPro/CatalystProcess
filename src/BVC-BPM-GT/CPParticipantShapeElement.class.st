"I render one BPMN Participant as a Pool.

I own only Participant presentation: the Pool frame, its label band, and an optional hosted Process visual. The Process visual remains CPProcessVisualElement and keeps its own editing behavior and memento. The dedicated processHost clips hosted Process content to the Pool boundary while the Pool itself may expose editing affordances outside its border."
Class {
	#name : 'CPParticipantShapeElement',
	#superclass : 'CPProcessShapeElement',
	#instVars : [
		'participant',
		'labelBand',
		'processHost',
		'processVisual',
		'orientation'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPParticipantShapeElement >> participant: aParticipant shape: aShape bounds: aRectangle background: aBackground borderColor: aBorderColor label: anEditableLabel [
	participant := aParticipant.
	diagramShape := aShape.
	modelElement := aParticipant.
	labelElement := anEditableLabel.
	orientation := CPPoolLaneOrientation forShape: aShape.
	normalBorderColor := aBorderColor.
	resizeHandles := #().
	self
		extent: aRectangle extent;
		geometry: BlRectangleGeometry new;
		background: aBackground;
		border: (BlBorder paint: aBorderColor width: 1.5);
		layout: BlFrameLayout new;
		clipChildren: false.
	self
		addLabelBandBorderColor: aBorderColor;
		addProcessHost
]

{ #category : 'private - building' }
CPParticipantShapeElement >> addLabelBandBorderColor: aBorderColor [
	labelBand := BlElement new
		geometry: BlRectangleGeometry new;
		background: Color transparent;
		border: (BlBorder paint: aBorderColor width: 1);
		layout: BlFrameLayout new;
		yourself.
	orientation
		configureParticipantLabelBand: labelBand
		label: labelElement.
	labelBand addChild: labelElement.
	self addChild: labelBand
]

{ #category : 'private - building' }
CPParticipantShapeElement >> addProcessHost [
	processHost := BlElement new
		background: Color transparent;
		layout: BlFrameLayout new;
		clipChildren: true;
		yourself.
	orientation configureParticipantProcessHost: processHost.
	self addChildFirst: processHost
]

{ #category : 'geometry' }
CPParticipantShapeElement class >> processContentOriginOffset [
	^ 36 @ 0
]

{ #category : 'geometry' }
CPParticipantShapeElement >> processContentOriginOffset [
	^ orientation participantContentOriginOffset
]

{ #category : 'hosting' }
CPParticipantShapeElement >> hostProcessVisual: aProcessVisual [
	processVisual := aProcessVisual.
	processHost addChild: processVisual
]

{ #category : 'accessing' }
CPParticipantShapeElement >> participant [
	^ participant
]

{ #category : 'accessing' }
CPParticipantShapeElement >> diagramShape [
	^ diagramShape
]

{ #category : 'accessing - testing' }
CPParticipantShapeElement >> labelBand [
	^ labelBand
]

{ #category : 'accessing - testing' }
CPParticipantShapeElement >> processHost [
	^ processHost
]

{ #category : 'accessing - testing' }
CPParticipantShapeElement >> processVisual [
	^ processVisual
]


{ #category : 'private - cursor' }
CPParticipantShapeElement >> bodyCursor [
	^ BlHandCursor new
]


{ #category : 'private - appearance' }
CPParticipantShapeElement >> borderForColor: aColor width: aWidth [
	^ BlBorder paint: aColor width: aWidth
]

{ #category : 'private - appearance' }
CPParticipantShapeElement >> normalBorderWidth [
	^ 1.5
]

{ #category : 'private - appearance' }
CPParticipantShapeElement >> selectedBorderWidth [
	^ 3
]

{ #category : 'appearance' }
CPParticipantShapeElement >> selected: isSelected selectionColor: aSelectionColor normalColor: aNormalColor [
	self border: (BlBorder
		paint: (isSelected ifTrue: [ aSelectionColor ] ifFalse: [ aNormalColor ])
		width: (isSelected ifTrue: [ self selectedBorderWidth ] ifFalse: [ self normalBorderWidth ]))
]


{ #category : 'accessing - testing' }
CPParticipantShapeElement >> orientation [
	^ orientation
]
