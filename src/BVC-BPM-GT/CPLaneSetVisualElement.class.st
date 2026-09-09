"I render one staged BPMN LaneSet as native Bloc structure.

I own only structural presentation: ordered Lane rows in a vertical linear layout. Lane heights are represented as Bloc linear weights, so the LaneSet fills its host and resizes live with it. Semantic ordering and durable DI remain owned by the staged BPMN model and Atelier operations."
Class {
	#name : 'CPLaneSetVisualElement',
	#superclass : 'BlElement',
	#instVars : [
		'laneSet',
		'lanesHost'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPLaneSetVisualElement >> laneSet: aLaneSet [
	laneSet := aLaneSet.
	self
		layout: BlFrameLayout new;
		background: Color transparent;
		clipChildren: true;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ].
	lanesHost := BlElement new
		layout: BlLinearLayout vertical;
		background: Color transparent;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		yourself.
	self addChild: lanesHost
]

{ #category : 'building' }
CPLaneSetVisualElement >> addLaneElement: aLaneElement weight: aWeight [
	aLaneElement constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent.
		c linear weight: aWeight ].
	lanesHost addChild: aLaneElement
]

{ #category : 'accessing' }
CPLaneSetVisualElement >> laneSet [
	^ laneSet
]

{ #category : 'accessing - testing' }
CPLaneSetVisualElement >> lanesHost [
	^ lanesHost
]

{ #category : 'accessing - testing' }
CPLaneSetVisualElement >> laneElements [
	^ lanesHost children
]
