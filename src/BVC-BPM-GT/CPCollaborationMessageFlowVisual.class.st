"I render one Collaboration-owned CPMessageFlow CPEdge.

The CPEdge waypoints are authoritative Collaboration DI. I render the dashed path, open source circle, open target arrow, and pointer hit surface. I retain the externally built editable label host plus bendpoint and reconnect affordances; CPCollaborationVisualElement resolves staged semantics, cross-plane geometry, and editing operations."
Class {
	#name : 'CPCollaborationMessageFlowVisual',
	#superclass : 'Object',
	#instVars : [
		'diagramEdge',
		'lineElements',
		'hitElements',
		'sourceMarker',
		'labelHost',
		'reconnectHandles',
		'bendpointHandles'
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
	hitElements := OrderedCollection new.
	sourceMarker := nil.
	labelHost := nil.
	reconnectHandles := OrderedCollection new.
	bendpointHandles := OrderedCollection new
]

{ #category : 'rendering' }
CPCollaborationMessageFlowVisual >> renderWaypoints: someWaypoints color: aColor in: aParent [
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
		in: aParent
]

{ #category : 'private - rendering' }
CPCollaborationMessageFlowVisual >> addDashedPathFor: someWaypoints color: aColor in: aParent [
	1 to: someWaypoints size - 1 do: [ :index |
		| start finish hitLine |
		start := someWaypoints at: index.
		finish := someWaypoints at: index + 1.
		hitLine := BlLineElement new
			fromAnchor: (BlAbsolutePositionAnchor position: start);
			toAnchor: (BlAbsolutePositionAnchor position: finish);
			border: (BlBorder paint: Color transparent width: 8);
			constraintsDo: [ :c | c ignoreByLayout ];
			yourself.
		self identify: hitLine.
		hitElements add: hitLine.
		aParent addChild: hitLine.
		self
			addDashedSegmentFrom: start
			to: finish
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


{ #category : 'accessing - testing' }
CPCollaborationMessageFlowVisual >> hitElements [
	^ hitElements
]


{ #category : 'appearance' }
CPCollaborationMessageFlowVisual >> selected: isSelected selectionColor: aSelectionColor normalColor: aNormalColor [
	lineElements allButLast do: [ :aLine |
		aLine border: (BlBorder
			paint: (isSelected ifTrue: [ aSelectionColor ] ifFalse: [ aNormalColor ])
			width: (isSelected ifTrue: [ 3 ] ifFalse: [ 1.5 ])) ].
	sourceMarker ifNotNil: [
		sourceMarker border: (BlBorder
			paint: (isSelected ifTrue: [ aSelectionColor ] ifFalse: [ aNormalColor ])
			width: (isSelected ifTrue: [ 3 ] ifFalse: [ 1.5 ])) ].
	self reconnectHandlesVisible: isSelected.
	self bendpointHandlesVisible: isSelected
]

{ #category : 'reconnect handles' }
CPCollaborationMessageFlowVisual >> reconnectHandles [
	^ reconnectHandles
]

{ #category : 'reconnect handles' }
CPCollaborationMessageFlowVisual >> reconnectHandles: someHandles [
	reconnectHandles := someHandles asOrderedCollection
]

{ #category : 'reconnect handles' }
CPCollaborationMessageFlowVisual >> reconnectHandlesVisible: aBoolean [
	| visibility |
	visibility := aBoolean ifTrue: [ BlVisibility visible ] ifFalse: [ BlVisibility hidden ].
	reconnectHandles do: [ :aHandle | aHandle visibility: visibility ]
]

{ #category : 'reconnect handles' }
CPCollaborationMessageFlowVisual >> positionReconnectHandlesAtSource: aSourcePoint target: aTargetPoint [
	reconnectHandles size = 2 ifFalse: [ ^ self ].
	reconnectHandles first relocate: aSourcePoint - (reconnectHandles first extent / 2).
	reconnectHandles last relocate: aTargetPoint - (reconnectHandles last extent / 2)
]

{ #category : 'reconnect handles' }
CPCollaborationMessageFlowVisual >> newReconnectHandleMovingSource: movesSource selectionColor: aSelectionColor dragStarted: aDragStartBlock dragged: aDragBlock dragEnded: aDragEndBlock [
	| handle isDragging |
	isDragging := false.
	handle := BlElement new
		extent: 10 @ 10;
		geometry: BlCircleGeometry new;
		background: Color white;
		border: (BlBorder paint: aSelectionColor width: 2);
		visibility: BlVisibility hidden;
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.
	handle
		addEventHandler: (BlEventHandler on: BlClickEvent do: [ :anEvent | anEvent consumed: true ]);
		addEventHandler: (BlEventHandler on: BlDragStartEvent do: [ :anEvent |
			isDragging := true.
			aDragStartBlock value: anEvent value: handle.
			anEvent consumed: true ]);
		addEventHandler: (BlEventHandler on: BlDragEvent do: [ :anEvent |
			isDragging ifTrue: [
				aDragBlock value: anEvent value: handle.
				anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler on: BlDragEndEvent do: [ :anEvent |
			isDragging ifTrue: [
				isDragging := false.
				aDragEndBlock value: anEvent value: handle.
				anEvent consumed: true ] ]).
	^ handle
]


{ #category : 'label' }
CPCollaborationMessageFlowVisual >> labelHost: anElement [
	labelHost := anElement
]

{ #category : 'label' }
CPCollaborationMessageFlowVisual >> positionLabelCenteredAt: aPoint [
	labelHost ifNil: [ ^ self ].
	labelHost relocate: (aPoint x - 90) @ (aPoint y - 22)
]

{ #category : 'bendpoint handles' }
CPCollaborationMessageFlowVisual >> bendpointHandles [
	^ bendpointHandles
]

{ #category : 'bendpoint handles' }
CPCollaborationMessageFlowVisual >> bendpointHandles: someHandles [
	bendpointHandles := someHandles asOrderedCollection
]

{ #category : 'bendpoint handles' }
CPCollaborationMessageFlowVisual >> bendpointHandlesVisible: aBoolean [
	| visibility |
	visibility := aBoolean ifTrue: [ BlVisibility visible ] ifFalse: [ BlVisibility hidden ].
	bendpointHandles do: [ :aHandle | aHandle visibility: visibility ]
]

{ #category : 'bendpoint handles' }
CPCollaborationMessageFlowVisual >> newBendpointHandleAt: aPoint waypointIndex: waypointIndex selectionColor: aSelectionColor removeRequested: aRemoveBlock dragged: aDragBlock dragEnded: aDragEndBlock [
	| handle handleExtent dragStartEventPosition dragStartHandlePosition isDragging |
	isDragging := false.
	handleExtent := 9 @ 9.
	handle := BlElement new
		extent: handleExtent;
		geometry: BlRectangleGeometry new;
		background: Color white;
		border: (BlBorder paint: aSelectionColor width: 1.5);
		visibility: BlVisibility hidden;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: aPoint - (handleExtent / 2);
		yourself.
	handle
		addEventHandler: (BlEventHandler on: BlClickEvent do: [ :anEvent | anEvent consumed: true ]);
		addEventHandler: (BlEventHandler on: BlDoubleClickEvent do: [ :anEvent |
			aRemoveBlock value: waypointIndex.
			anEvent consumed: true ]);
		addEventHandler: (BlEventHandler on: BlDragStartEvent do: [ :anEvent |
			dragStartEventPosition := anEvent position.
			dragStartHandlePosition := handle position.
			isDragging := true.
			anEvent consumed: true ]);
		addEventHandler: (BlEventHandler on: BlDragEvent do: [ :anEvent |
			isDragging ifTrue: [
				| newPoint |
				handle relocate: dragStartHandlePosition + anEvent position - dragStartEventPosition.
				newPoint := handle position + (handle extent / 2).
				aDragBlock value: anEvent value: newPoint.
				anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler on: BlDragEndEvent do: [ :anEvent |
			isDragging ifTrue: [
				| newPoint |
				isDragging := false.
				newPoint := handle position + (handle extent / 2).
				aDragEndBlock value: anEvent value: newPoint.
				anEvent consumed: true ] ]).
	^ handle
]
