"I render one Collaboration-owned CPMessageFlow CPEdge.

For this first vertical slice the CPEdge waypoints are authoritative Collaboration DI. I render a dashed path, an open source circle, an open target arrow, and an optional label. I own presentation only; selection, editing, reconnect and Atelier operations are later slices."
Class {
	#name : 'CPCollaborationMessageFlowVisual',
	#superclass : 'Object',
	#instVars : [
		'diagramEdge',
		'lineElements',
		'sourceMarker',
		'labelHost'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPCollaborationMessageFlowVisual class >> edge: anEdge [
	^ self new
		edge: anEdge;
		yourself
]

{ #category : 'initialization' }
CPCollaborationMessageFlowVisual >> edge: anEdge [
	diagramEdge := anEdge.
	lineElements := OrderedCollection new.
	sourceMarker := nil.
	labelHost := nil
]

{ #category : 'rendering' }
CPCollaborationMessageFlowVisual >> renderWaypoints: someWaypoints color: aColor label: aString in: aParent [
	someWaypoints size < 2 ifTrue: [ ^ self ].
	self
		addDashedPathFor: someWaypoints
		color: aColor
		in: aParent.
	self
		addSourceMarkerAt: someWaypoints first
		color: aColor
		in: aParent.
	self
		addTargetArrowFrom: (someWaypoints at: someWaypoints size - 1)
		to: someWaypoints last
		color: aColor
		in: aParent.
	(aString notNil and: [ aString isEmpty not ]) ifTrue: [
		self
			addLabel: aString
			at: (self labelPointFor: someWaypoints)
			in: aParent ]
]

{ #category : 'private - rendering' }
CPCollaborationMessageFlowVisual >> addDashedPathFor: someWaypoints color: aColor in: aParent [
	1 to: someWaypoints size - 1 do: [ :index |
		self
			addDashedSegmentFrom: (someWaypoints at: index)
			to: (someWaypoints at: index + 1)
			color: aColor
			in: aParent ]
]

{ #category : 'private - rendering' }
CPCollaborationMessageFlowVisual >> addDashedSegmentFrom: start to: finish color: aColor in: aParent [
	| vector length direction distance dashLength gapLength |
	vector := finish - start.
	length := vector r.
	length isZero ifTrue: [ ^ self ].
	direction := vector / length.
	dashLength := 8.0.
	gapLength := 6.0.
	distance := 0.0.
	[ distance < length ] whileTrue: [
		| dashStart dashFinish line |
		dashStart := start + (direction * distance).
		dashFinish := start + (direction * ((distance + dashLength) min: length)).
		line := BlLineElement new
			fromAnchor: (BlAbsolutePositionAnchor position: dashStart);
			toAnchor: (BlAbsolutePositionAnchor position: dashFinish);
			border: (BlBorder paint: aColor width: 1.5);
			constraintsDo: [ :c | c ignoreByLayout ];
			preventMeAndChildrenMouseEvents;
			yourself.
		self identify: line.
		lineElements add: line.
		aParent addChild: line.
		distance := distance + dashLength + gapLength ]
]

{ #category : 'private - rendering' }
CPCollaborationMessageFlowVisual >> addSourceMarkerAt: aPoint color: aColor in: aParent [
	| extent |
	extent := 10 @ 10.
	sourceMarker := BlElement new
		extent: extent;
		geometry: BlCircleGeometry new;
		background: Color transparent;
		border: (BlBorder paint: aColor width: 1.5);
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: aPoint - (extent / 2);
		preventMeAndChildrenMouseEvents;
		yourself.
	self identify: sourceMarker.
	aParent addChild: sourceMarker
]

{ #category : 'private - rendering' }
CPCollaborationMessageFlowVisual >> addTargetArrowFrom: start to: finish color: aColor in: aParent [
	| line |
	line := BlLineElement new
		fromAnchor: (BlAbsolutePositionAnchor position: start);
		toAnchor: (BlAbsolutePositionAnchor position: finish);
		border: (BlBorder paint: Color transparent width: 0);
		constraintsDo: [ :c | c ignoreByLayout ];
		toHead: (BlArrowheadSimpleArrow new
			border: (BlBorder paint: aColor width: 1.5));
		preventMeAndChildrenMouseEvents;
		yourself.
	self identify: line.
	lineElements add: line.
	aParent addChild: line
]

{ #category : 'private - rendering' }
CPCollaborationMessageFlowVisual >> addLabel: aString at: aPoint in: aParent [
	labelHost := BrLabel new
		text: aString;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: aPoint - (60 @ 14);
		preventMeAndChildrenMouseEvents;
		yourself.
	self identify: labelHost.
	aParent addChild: labelHost
]

{ #category : 'private - geometry' }
CPCollaborationMessageFlowVisual >> labelPointFor: someWaypoints [
	| path placement |
	path := CPProcessEdgeLabelPath points: someWaypoints.
	placement := path
		placementAtSegmentIndex: path defaultSegmentIndex
		segmentPosition: 0.5
		offset: -12.
	^ placement first
]

{ #category : 'private' }
CPCollaborationMessageFlowVisual >> identify: anElement [
	anElement userData at: #processDiagramElement put: diagramEdge.
	anElement userData at: #processModelElement put: diagramEdge modelElement
]

{ #category : 'accessing - testing' }
CPCollaborationMessageFlowVisual >> diagramEdge [
	^ diagramEdge
]

{ #category : 'accessing - testing' }
CPCollaborationMessageFlowVisual >> lineElements [
	^ lineElements
]

{ #category : 'accessing - testing' }
CPCollaborationMessageFlowVisual >> sourceMarker [
	^ sourceMarker
]

{ #category : 'accessing - testing' }
CPCollaborationMessageFlowVisual >> labelHost [
	^ labelHost
]
