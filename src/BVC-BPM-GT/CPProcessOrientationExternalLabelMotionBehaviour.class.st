"I keep an external FlowNode label's owner-relative offset fixed in screen
coordinates while its enclosing Pool rotates.

The Pool rotation moves the label around the diagram. The FlowNode itself is
counter-rotated and therefore stays upright. I contribute only the changing
local translation required to keep the label's original screen-space offset
from that upright FlowNode. Motion remains the sole owner of time and
presentation transforms."
Class {
	#name : 'CPProcessOrientationExternalLabelMotionBehaviour',
	#superclass : 'CFMotionBehaviour',
	#instVars : [
		'label',
		'offset',
		'parentRotation',
		'presentation'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessOrientationExternalLabelMotionBehaviour class >> on: aLabel offset: anOffset parentRotation: aRotation [
	^ self new
		label: aLabel;
		offset: anOffset;
		parentRotation: aRotation;
		yourself
]

{ #category : 'accessing' }
CPProcessOrientationExternalLabelMotionBehaviour >> animationTarget [
	^ label
]

{ #category : 'playing' }
CPProcessOrientationExternalLabelMotionBehaviour >> applyDestination [
	presentation ifNil: [ ^ self ].
	presentation translation: (self translationAtProgress: 1.0).
	presentation adoptCurrentPresentation
]

{ #category : 'playing' }
CPProcessOrientationExternalLabelMotionBehaviour >> applyProgress: aProgress [
	presentation translation: (self translationAtProgress: aProgress)
]

{ #category : 'playing' }
CPProcessOrientationExternalLabelMotionBehaviour >> captureOrigin [
	presentation := CFMotionTransformPresentation on: label
]

{ #category : 'playing' }
CPProcessOrientationExternalLabelMotionBehaviour >> captureOriginIn: aCoordinator [
	presentation := CFMotionTransformPresentation
		on: label
		using: (aCoordinator transformChannelFor: label)
]

{ #category : 'testing' }
CPProcessOrientationExternalLabelMotionBehaviour >> isAtDestination [
	^ parentRotation isZero
]

{ #category : 'accessing' }
CPProcessOrientationExternalLabelMotionBehaviour >> label: anElement [
	label := anElement
]

{ #category : 'private - geometry' }
CPProcessOrientationExternalLabelMotionBehaviour >> localOffsetAtProgress: aProgress [
	| radians cosine sine |
	radians := parentRotation negated * aProgress * Float pi / 180.0.
	cosine := radians cos.
	sine := radians sin.
	^ ((offset x * cosine) - (offset y * sine))
		@ ((offset x * sine) + (offset y * cosine))
]

{ #category : 'accessing' }
CPProcessOrientationExternalLabelMotionBehaviour >> offset: aPoint [
	offset := aPoint
]

{ #category : 'accessing' }
CPProcessOrientationExternalLabelMotionBehaviour >> parentRotation: aNumber [
	parentRotation := aNumber
]

{ #category : 'playing' }
CPProcessOrientationExternalLabelMotionBehaviour >> prepareFromCurrentPresentation [
	presentation translation: 0 @ 0
]

{ #category : 'accessing' }
CPProcessOrientationExternalLabelMotionBehaviour >> propertyKey [
	^ CFMotionPropertyKey
		element: label
		property: CFMotionTranslationProperty uniqueInstance
]


{ #category : 'playing' }
CPProcessOrientationExternalLabelMotionBehaviour >> preserveCurrentPresentation [
	presentation ifNotNil: [ presentation adoptCurrentPresentation ]
]

{ #category : 'playing' }
CPProcessOrientationExternalLabelMotionBehaviour >> restoreOrigin [
	presentation ifNil: [ ^ self ].
	presentation translation: 0 @ 0.
	presentation release
]

{ #category : 'controlling' }
CPProcessOrientationExternalLabelMotionBehaviour >> reversed [
	^ self class
		on: label
		offset: offset
		parentRotation: parentRotation negated
]

{ #category : 'private - geometry' }
CPProcessOrientationExternalLabelMotionBehaviour >> translationAtProgress: aProgress [
	^ (self localOffsetAtProgress: aProgress) - offset
]
