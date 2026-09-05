"I own the Bloc elements that together render one CPEdge.

CPEdge remains the BPMN-DI model object. I group its visible path elements and wider interaction hit elements so CPProcessVisualElement can reason about one rendered edge as one presentation object without keeping parallel dictionaries."
Class {
	#name : 'CPProcessEdgeVisual',
	#superclass : 'Object',
	#instVars : [
		'diagramEdge',
		'lineElements',
		'hitElements'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessEdgeVisual >> edge: anEdge [
	diagramEdge := anEdge.
	lineElements := OrderedCollection new.
	hitElements := OrderedCollection new
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
