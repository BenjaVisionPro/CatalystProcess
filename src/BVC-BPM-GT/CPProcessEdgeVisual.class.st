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
CPProcessEdgeVisual >> edge: anEdge lineElements: someLines hitElements: someHitElements [
	diagramEdge := anEdge.
	lineElements := someLines.
	hitElements := someHitElements
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
