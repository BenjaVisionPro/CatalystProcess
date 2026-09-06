"I temporarily lift one Process shape presentation out of its normal clipped presentation parent for an active drag.

The owning CPProcessVisualElement supplies root-diagram coordinates explicitly. I never infer diagram position from Bloc global transforms. While lifted, the shape is a child of the root Process visual and its position is therefore expressed directly in root-diagram coordinates. On restore I convert that root position back through the source Process visual's local coordinate space.

The semantic CPShape remains in its original Process/Sub-Process until the Atelier operation completes."
Class {
	#name : 'CPProcessDragPresentation',
	#superclass : 'Object',
	#instVars : [
		'shapeElement',
		'labelElement',
		'sourceVisual',
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
CPProcessDragPresentation >> liftFrom: aSourceVisual toRoot: aRootVisual shapeAt: aRootShapePosition labelAt: aRootLabelPosition [
	sourceVisual := aSourceVisual.
	originalShapeParent := shapeElement parent.
	dragShapePosition := aRootShapePosition.
	shapeElement removeFromParent.
	aRootVisual addChild: shapeElement.
	shapeElement relocate: dragShapePosition.

	labelElement := shapeElement externalLabelHost.
	labelElement ifNotNil: [
		originalLabelParent := labelElement parent.
		dragLabelPosition := aRootLabelPosition.
		labelElement removeFromParent.
		aRootVisual addChild: labelElement.
		labelElement relocate: dragLabelPosition ].
	^ self
]

{ #category : 'dragging' }
CPProcessDragPresentation >> restore [
	| rootShapePosition rootLabelPosition |
	rootShapePosition := shapeElement position.
	rootLabelPosition := labelElement ifNotNil: [ labelElement position ].

	shapeElement removeFromParent.
	originalShapeParent addChild: shapeElement.
	shapeElement relocate:
		(sourceVisual localPointForRootDiagramPoint: rootShapePosition).

	labelElement ifNotNil: [
		labelElement removeFromParent.
		originalLabelParent addChild: labelElement.
		labelElement relocate:
			(sourceVisual localPointForRootDiagramPoint: rootLabelPosition) ]
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
