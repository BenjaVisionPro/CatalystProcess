"I render one BPMN Participant as a Pool.

I own only Participant presentation: the Pool frame, its label band, and an optional hosted Process visual. The Process visual remains CPProcessVisualElement and keeps its own editing behavior and memento. The dedicated processHost clips hosted Process content to the Pool boundary while the Pool itself may expose editing affordances outside its border."
Class {
	#name : 'CPParticipantShapeElement',
	#superclass : 'CPProcessShapeElement',
	#instVars : [
		'participant',
		'labelBand',
		'processHost',
		'processVisual'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPParticipantShapeElement >> participant: aParticipant shape: aShape bounds: aRectangle background: aBackground borderColor: aBorderColor [
	participant := aParticipant.
	diagramShape := aShape.
	modelElement := aParticipant.
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
		constraintsDo: [ :c |
			c horizontal exact: self processContentOriginOffset x.
			c vertical matchParent.
			c frame horizontal alignLeft.
			c frame vertical alignTop ];
		yourself.
	labelElement := BrLabel new
		text: (participant label ifNil: [ '' ]);
		hFitContent;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		transformDo: [ :aTransform | aTransform rotateBy: -90 ];
		preventMeAndChildrenMouseEvents;
		yourself.
	labelBand addChild: labelElement.
	self addChild: labelBand
]

{ #category : 'private - building' }
CPParticipantShapeElement >> addProcessHost [
	processHost := BlElement new
		background: Color transparent;
		layout: BlFrameLayout new;
		clipChildren: true;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent.
			c frame horizontal alignRight.
			c frame vertical alignTop.
			c margin: (BlInsets top: 0 right: 0 bottom: 0 left: self processContentOriginOffset x) ];
		yourself.
	self addChildFirst: processHost
]

{ #category : 'geometry' }
CPParticipantShapeElement >> processContentOriginOffset [
	^ 36 @ 0
]

{ #category : 'hosting' }
CPParticipantShapeElement >> hostProcessVisual: aProcessVisual [
	processVisual := aProcessVisual.
	processVisual
		beCollaborationHosted;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent.
			c frame horizontal alignLeft.
			c frame vertical alignTop ].
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
CPParticipantShapeElement >> normalBorderWidth [
	^ 1.5
]

{ #category : 'private - appearance' }
CPParticipantShapeElement >> selectedBorderWidth [
	^ 3
]
