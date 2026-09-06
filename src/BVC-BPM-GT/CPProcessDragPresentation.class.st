"I temporarily lift one Process shape presentation out of its normal Bloc parent for an active drag.

The semantic CPShape remains owned by its original Process/Sub-Process. I preserve the shape and external-label global positions while reparenting them to the root Process visual, then restore their original presentation parents translated by the completed drag delta. This lets a nested shape cross a clipped Sub-Process viewport without changing clipping for any sibling content."
Class {
	#name : 'CPProcessDragPresentation',
	#superclass : 'Object',
	#instVars : [
		'shapeElement',
		'labelElement',
		'originalShapeParent',
		'originalShapePosition',
		'originalLabelParent',
		'originalLabelPosition',
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
	originalShapePosition := shapeElement position.
	globalOrigin := shapeElement localPointToGlobal: 0 @ 0.
	dragShapePosition := aRootVisual globalPointToLocal: globalOrigin.
	shapeElement removeFromParent.
	aRootVisual addChild: shapeElement.
	shapeElement relocate: dragShapePosition.

	labelElement := shapeElement externalLabelHost.
	labelElement ifNotNil: [
		originalLabelParent := labelElement parent.
		originalLabelPosition := labelElement position.
		globalOrigin := labelElement localPointToGlobal: 0 @ 0.
		dragLabelPosition := aRootVisual globalPointToLocal: globalOrigin.
		labelElement removeFromParent.
		aRootVisual addChild: labelElement.
		labelElement relocate: dragLabelPosition ].
	^ self
]

{ #category : 'dragging' }
CPProcessDragPresentation >> restoreTranslatedBy: aDelta [
	shapeElement removeFromParent.
	originalShapeParent addChild: shapeElement.
	shapeElement relocate: originalShapePosition + aDelta.
	labelElement ifNotNil: [
		labelElement removeFromParent.
		originalLabelParent addChild: labelElement.
		labelElement relocate: originalLabelPosition + aDelta ]
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
