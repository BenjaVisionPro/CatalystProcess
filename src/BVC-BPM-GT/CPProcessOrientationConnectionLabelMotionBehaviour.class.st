"I keep a SequenceFlow label continuous through a Pool orientation quarter-turn.

The enclosing Pool rotation already carries the label around the diagram. The
final authoritative edge can differ slightly from that rigid rotation because
FlowNodes remain upright and edge docking is re-derived. I procedurally apply
only that screen-space correction over Motion progress, ending exactly at the
CPProcessEdgeLabelPath placement used by the refreshed authoritative render."
Class {
	#name : 'CPProcessOrientationConnectionLabelMotionBehaviour',
	#superclass : 'CFMotionBehaviour',
	#instVars : [
		'label',
		'finalCorrection',
		'presentation'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessOrientationConnectionLabelMotionBehaviour class >> on: aLabel finalCorrection: aPoint [
	^ self new
		label: aLabel;
		finalCorrection: aPoint;
		yourself
]

{ #category : 'accessing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> animationTarget [
	^ label
]

{ #category : 'playing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> applyDestination [
	presentation ifNil: [ ^ self ].
	presentation translation: finalCorrection.
	presentation adoptCurrentPresentation
]

{ #category : 'playing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> applyProgress: aProgress [
	presentation translation: finalCorrection * aProgress
]

{ #category : 'playing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> captureOrigin [
	presentation := CFMotionTransformPresentation on: label
]

{ #category : 'playing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> captureOriginIn: aCoordinator [
	presentation := CFMotionTransformPresentation
		on: label
		using: (aCoordinator transformChannelFor: label)
]

{ #category : 'accessing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> finalCorrection: aPoint [
	finalCorrection := aPoint
]

{ #category : 'testing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> isAtDestination [
	^ finalCorrection isZero
]

{ #category : 'accessing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> label: anElement [
	label := anElement
]

{ #category : 'playing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> prepareFromCurrentPresentation [
	presentation translation: 0 @ 0
]

{ #category : 'accessing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> propertyKey [
	^ CFMotionPropertyKey
		element: label
		property: CFMotionTranslationProperty uniqueInstance
]

{ #category : 'playing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> preserveCurrentPresentation [
	presentation ifNotNil: [ presentation adoptCurrentPresentation ]
]

{ #category : 'playing' }
CPProcessOrientationConnectionLabelMotionBehaviour >> restoreOrigin [
	presentation ifNil: [ ^ self ].
	presentation translation: 0 @ 0.
	presentation release
]

{ #category : 'controlling' }
CPProcessOrientationConnectionLabelMotionBehaviour >> reversed [
	^ self class
		on: label
		finalCorrection: finalCorrection negated
]
