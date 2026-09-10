"I render one staged BPMN LaneSet as native Bloc structure.

I own only structural presentation. My extent is derived by CPProcessVisualElement from the staged DI bounds of my immediate Lanes; each Lane is positioned explicitly from those bounds. I do not independently redistribute or resize Lane geometry. Semantic ordering and durable DI remain owned by the staged BPMN model and Atelier operations."
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
		clipChildren: true.
	lanesHost := BlElement new
		layout: BlFrameLayout new;
		background: Color transparent;
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical matchParent ];
		yourself.
	self addChild: lanesHost
]

{ #category : 'building' }
CPLaneSetVisualElement >> addLaneElement: aLaneElement at: aPoint extent: anExtent [
	aLaneElement
		constraintsDo: [ :c | c ignoreByLayout ];
		extent: anExtent;
		relocate: aPoint.
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
