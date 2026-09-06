"I render one BPMN Participant as a Pool.

I own only Participant presentation: the Pool frame, its label band, and an optional hosted Process visual. The Process visual remains CPProcessVisualElement and keeps its own editing behavior and memento. This element clips its hosted content to the Pool boundary."
Class {
	#name : 'CPParticipantShapeElement',
	#superclass : 'BlElement',
	#instVars : [
		'participant',
		'diagramShape',
		'labelBand',
		'labelElement',
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
	self
		extent: aRectangle extent;
		geometry: BlRectangleGeometry new;
		background: aBackground;
		border: (BlBorder paint: aBorderColor width: 1.5);
		layout: BlFrameLayout new;
		clipChildren: true.
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
			c horizontal exact: 36.
			c vertical matchParent.
			c frame horizontal alignLeft.
			c frame vertical alignTop ];
		preventMeAndChildrenMouseEvents;
		yourself.
	labelElement := BrLabel new
		text: (participant label ifNil: [ '' ]);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent.
			c frame horizontal alignCenter.
			c frame vertical alignCenter.
			c margin: (BlInsets top: 4 right: 4 bottom: 4 left: 4) ];
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
			c margin: (BlInsets top: 0 right: 0 bottom: 0 left: 36) ];
		yourself.
	self addChildFirst: processHost
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
