"I temporarily lift one Process shape presentation out of its normal Bloc parent for an active drag.

The semantic CPShape remains owned by its original Process/Sub-Process. I preserve the shape and external-label global positions while reparenting them to the root Process visual, then preserve their current global positions when restoring their original presentation parents. Drag delta and final semantic bounds remain owned by the normal positioning and Atelier operation path. This lets a nested shape cross a clipped Sub-Process viewport without changing clipping for any sibling content."
Class {
	#name : 'CPProcessDragPresentation',
	#superclass : 'Object',
	#instVars : [
		'shapeElement',
		'labelElement',
		'originalShapeParent',
		'originalLabelParent',
		'dragShapePosition',
		'dragLabelPosition'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessDragPresentation class >> shapeElement: aShapeElement [
	^ self new
		shapeElement: aShapeElement;
		yourself
]

{ #category : 'dragging' }
CPProcessDragPresentation >> liftTo: aRootVisual [
	| globalOrigin |
	originalShapeParent := shapeElement parent.
	globalOrigin := shapeElement localPointToGlobal: 0 @ 0.
	dragShapePosition := aRootVisual globalPointToLocal: globalOrigin.
	shapeElement removeFromParent.
	aRootVisual addChild: shapeElement.
	shapeElement relocate: dragShapePosition.

	labelElement := shapeElement externalLabelHost.
	labelElement ifNotNil: [
		originalLabelParent := labelElement parent.
		globalOrigin := labelElement localPointToGlobal: 0 @ 0.
		dragLabelPosition := aRootVisual globalPointToLocal: globalOrigin.
		labelElement removeFromParent.
		aRootVisual addChild: labelElement.
		labelElement relocate: dragLabelPosition ].
	^ self
]

{ #category : 'dragging' }
CPProcessDragPresentation >> restore [
	| globalOrigin |
	globalOrigin := shapeElement localPointToGlobal: 0 @ 0.
	shapeElement removeFromParent.
	originalShapeParent addChild: shapeElement.
	shapeElement relocate: (originalShapeParent globalPointToLocal: globalOrigin).

	labelElement ifNotNil: [
		globalOrigin := labelElement localPointToGlobal: 0 @ 0.
		labelElement removeFromParent.
		originalLabelParent addChild: labelElement.
		labelElement relocate: (originalLabelParent globalPointToLocal: globalOrigin) ]
]

{ #category : 'accessing' }
CPProcessDragPresentation >> shapeElement [
	^ shapeElement
]

{ #category : 'accessing' }
CPProcessDragPresentation >> shapeElement: anElement [
	shapeElement := anElement
]

{ #category : 'accessing' }
CPProcessDragPresentation >> dragShapePosition [
	^ dragShapePosition
]

{ #category : 'accessing' }
CPProcessDragPresentation >> dragLabelPosition [
	^ dragLabelPosition
]
