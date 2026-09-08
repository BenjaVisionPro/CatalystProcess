"I render and locally interact with one CPEdge.

CPEdge remains the BPMN-DI model object. I own the visible path and hit surface, edge-label host, bendpoint and reconnect affordances, their appearance, and their local pointer mechanics. CPProcessVisualElement resolves relationships to other diagram objects, routing targets, staged BPMN-DI changes, and Atelier operations."
Class {
	#name : 'CPProcessEdgeVisual',
	#superclass : 'Object',
	#instVars : [
		'diagramEdge',
		'lineElements',
		'hitElements',
		'bendpointHandles',
		'reconnectHandles',
		'labelHost'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessEdgeVisual >> edge: anEdge [
	diagramEdge := anEdge.
	lineElements := OrderedCollection new.
	hitElements := OrderedCollection new.
	bendpointHandles := OrderedCollection new.
	reconnectHandles := OrderedCollection new.
	labelHost := nil
]

{ #category : 'rendering' }
CPProcessEdgeVisual >> addSegmentFrom: aFromAnchor to: aToAnchor arrowhead: hasArrowhead color: aColor segmentIndex: aSegmentIndex installInteraction: anInteractionBlock addTo: aParent [
	| line hitLine |
	hitLine := BlLineElement new
		fromAnchor: aFromAnchor;
		toAnchor: aToAnchor;
		border: (BlBorder paint: Color transparent width: 8);
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.
	self identify: hitLine.
	anInteractionBlock value: hitLine value: aSegmentIndex.

	line := BlLineElement new
		fromAnchor: aFromAnchor;
		toAnchor: aToAnchor;
		border: (BlBorder paint: aColor width: 1.5);
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.
	hasArrowhead ifTrue: [
		line toHead: (BlArrowheadSimpleArrow new
			border: (BlBorder paint: aColor width: 1.5)) ].
	self identify: line.
	anInteractionBlock value: line value: aSegmentIndex.

	hitElements add: hitLine.
	lineElements add: line.
	aParent addChild: hitLine.
	aParent addChild: line
]

{ #category : 'private' }
CPProcessEdgeVisual >> identify: anElement [
	anElement userData at: #processDiagramElement put: diagramEdge.
	anElement userData at: #processModelElement put: diagramEdge modelElement
]

{ #category : 'accessing' }
CPProcessEdgeVisual >> diagramEdge [
	^ diagramEdge
]

{ #category : 'accessing' }
CPProcessEdgeVisual >> lineElements [
	^ lineElements
]

{ #category : 'accessing' }
CPProcessEdgeVisual >> hitElements [
	^ hitElements
]

{ #category : 'removing' }
CPProcessEdgeVisual >> removeRenderedElements [
	lineElements do: [ :anElement | anElement removeFromParent ].
	hitElements do: [ :anElement | anElement removeFromParent ]
]

{ #category : 'testing' }
CPProcessEdgeVisual >> containsGlobalPoint: aPoint [
	^ hitElements anySatisfy: [ :anElement |
		anElement containsGlobalPoint: aPoint ]
]

{ #category : 'appearance' }
CPProcessEdgeVisual >> selected: isSelected insertionTarget: isInsertionTarget selectionColor: aSelectionColor normalColor: aNormalColor [
	| isEmphasized |
	isEmphasized := isSelected or: [ isInsertionTarget ].
	lineElements do: [ :aLine |
		aLine border: (BlBorder
			paint: (isEmphasized ifTrue: [ aSelectionColor ] ifFalse: [ aNormalColor ])
			width: (isEmphasized ifTrue: [ 3 ] ifFalse: [ 1.5 ])) ]
]

{ #category : 'bendpoint handles' }
CPProcessEdgeVisual >> bendpointHandles [
	^ bendpointHandles
]

{ #category : 'bendpoint handles' }
CPProcessEdgeVisual >> bendpointHandles: someHandles [
	bendpointHandles := someHandles asOrderedCollection
]

{ #category : 'bendpoint handles' }
CPProcessEdgeVisual >> positionBendpointHandlesUsingWaypoints: someWaypoints [
	bendpointHandles size = (someWaypoints size - 2) ifFalse: [ ^ self ].
	1 to: bendpointHandles size do: [ :index |
		| handle point |
		handle := bendpointHandles at: index.
		point := someWaypoints at: index + 1.
		handle relocate: point - (handle extent / 2) ]
]

{ #category : 'bendpoint handles' }
CPProcessEdgeVisual >> bendpointHandlesVisible: aBoolean [
	| visibility |
	visibility := aBoolean
		ifTrue: [ BlVisibility visible ]
		ifFalse: [ BlVisibility hidden ].
	bendpointHandles do: [ :aHandle | aHandle visibility: visibility ]
]

{ #category : 'bendpoint handles' }
CPProcessEdgeVisual >> bringBendpointHandlesToFrontIn: aParent [
	bendpointHandles do: [ :aHandle |
		aHandle removeFromParent.
		aParent addChild: aHandle ]
]



{ #category : 'reconnect handles' }
CPProcessEdgeVisual >> reconnectHandles [
	^ reconnectHandles
]

{ #category : 'reconnect handles' }
CPProcessEdgeVisual >> reconnectHandles: someHandles [
	reconnectHandles := someHandles asOrderedCollection
]

{ #category : 'reconnect handles' }
CPProcessEdgeVisual >> reconnectHandlesVisible: aBoolean [
	| visibility |
	visibility := aBoolean
		ifTrue: [ BlVisibility visible ]
		ifFalse: [ BlVisibility hidden ].
	reconnectHandles do: [ :aHandle | aHandle visibility: visibility ]
]

{ #category : 'reconnect handles' }
CPProcessEdgeVisual >> positionReconnectHandlesAtSource: aSourcePoint target: aTargetPoint [
	reconnectHandles size = 2 ifFalse: [ ^ self ].
	reconnectHandles first
		relocate: aSourcePoint - (reconnectHandles first extent / 2).
	reconnectHandles last
		relocate: aTargetPoint - (reconnectHandles last extent / 2)
]

{ #category : 'reconnect handles' }
CPProcessEdgeVisual >> bringReconnectHandlesToFrontIn: aParent [
	reconnectHandles do: [ :aHandle |
		aHandle removeFromParent.
		aParent addChild: aHandle ]
]


{ #category : 'label' }
CPProcessEdgeVisual >> labelHost [
	^ labelHost
]

{ #category : 'label' }
CPProcessEdgeVisual >> labelHost: anElement [
	labelHost := anElement
]

{ #category : 'label' }
CPProcessEdgeVisual >> hasLabelHost [
	^ labelHost notNil
]

{ #category : 'label' }
CPProcessEdgeVisual >> positionLabelCenteredAt: aPoint [
	labelHost ifNil: [ ^ self ].
	labelHost relocate: (aPoint x - 90) @ (aPoint y - 22)
]

{ #category : 'label' }
CPProcessEdgeVisual >> bringLabelToFrontIn: aParent [
	labelHost ifNil: [ ^ self ].
	labelHost removeFromParent.
	aParent addChild: labelHost
]

{ #category : 'appearance' }
CPProcessEdgeVisual >> pathVisible: aBoolean [
	| visibility |
	visibility := aBoolean
		ifTrue: [ BlVisibility visible ]
		ifFalse: [ BlVisibility hidden ].
	lineElements do: [ :aLine | aLine visibility: visibility ]
]

{ #category : 'bendpoint handles' }
CPProcessEdgeVisual >> newBendpointHandleAt: aPoint waypointIndex: waypointIndex selectionColor: aSelectionColor removeRequested: aRemoveBlock dragStarted: aDragStartBlock dragged: aDragBlock dragEnded: aDragEndBlock [
	| handle handleExtent dragStartEventPosition dragStartHandlePosition isDragging |
	isDragging := false.
	handleExtent := 9 @ 9.
	handle := BlElement new
		extent: handleExtent;
		geometry: BlRectangleGeometry new;
		background: Color white;
		border: (BlBorder
			paint: aSelectionColor
			width: 1.5);
		visibility: BlVisibility hidden;
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: aPoint - (handleExtent / 2);
		yourself.

	handle
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent | anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDoubleClickEvent
			do: [ :anEvent |
				aRemoveBlock value: waypointIndex.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				dragStartEventPosition := anEvent position.
				dragStartHandlePosition := handle position.
				isDragging := true.
				self pathVisible: false.
				aDragStartBlock value: anEvent.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| newPoint |
					handle relocate:
						dragStartHandlePosition + anEvent position - dragStartEventPosition.
					newPoint := handle position + (handle extent / 2).
					aDragBlock value: anEvent value: newPoint.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					| newPoint |
					isDragging := false.
					newPoint := handle position + (handle extent / 2).
					self pathVisible: true.
					aDragEndBlock value: anEvent value: newPoint.
					anEvent consumed: true ] ]).
	^ handle
]

{ #category : 'reconnect handles' }
CPProcessEdgeVisual >> newReconnectHandleMovingSource: movesSource selectionColor: aSelectionColor dragStarted: aDragStartBlock dragged: aDragBlock dragEnded: aDragEndBlock [
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
		addEventHandler: (BlEventHandler
			on: BlClickEvent
			do: [ :anEvent | anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				isDragging := true.
				aDragStartBlock value: anEvent value: handle.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					aDragBlock value: anEvent value: handle.
					anEvent consumed: true ] ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				isDragging ifTrue: [
					isDragging := false.
					aDragEndBlock value: anEvent value: handle.
					anEvent consumed: true ] ]).
	^ handle
]

{ #category : 'reconnect handles' }
CPProcessEdgeVisual >> positionReconnectHandle: aHandle fromPreviewLine: aPreviewLine movingSource: movesSource within: aParent [
	| endpoint |
	endpoint := movesSource
		ifTrue: [
			aPreviewLine fromAnchor
				positionForAnchoredElement: aPreviewLine
					within: aParent ]
		ifFalse: [
			aPreviewLine toAnchor
				positionForAnchoredElement: aPreviewLine
					within: aParent ].
	aHandle relocate: endpoint - (aHandle extent / 2)
]

