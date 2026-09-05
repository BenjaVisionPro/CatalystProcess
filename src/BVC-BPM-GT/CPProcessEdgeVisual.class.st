"I own the Bloc elements that together render one CPEdge.

CPEdge remains the BPMN-DI model object. I group its visible path elements and wider interaction hit elements so CPProcessVisualElement can reason about one rendered edge as one presentation object without keeping parallel dictionaries."
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
