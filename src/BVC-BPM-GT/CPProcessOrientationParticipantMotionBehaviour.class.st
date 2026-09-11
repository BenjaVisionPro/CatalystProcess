"I rotate one Participant Pool around its BPMN-DI geometric centre.

The default Motion rotation origin is intentionally not used here. The
orientation handoff replaces a transformed live Bloc element with a freshly
laid-out BPMN-DI rectangle. Even a sub-pixel difference between those two
centre conventions becomes a visible one-pixel translation after a quarter
turn.

I therefore use a top-left transform origin and derive the translation from
the element's geometric centre for every Motion progress. The geometric centre
stays fixed throughout the turn, and at +/-90 degrees the transformed bounds
coincide exactly with the swapped-extent BPMN-DI bounds."
Class {
	#name : 'CPProcessOrientationParticipantMotionBehaviour',
	#superclass : 'CFMotionBehaviour',
	#instVars : [
		'element',
		'targetRotation',
		'presentation',
		'geometricCenter'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessOrientationParticipantMotionBehaviour class >> on: anElement to: aTargetRotation [
	^ self new
		element: anElement;
		targetRotation: aTargetRotation;
		yourself
]

{ #category : 'geometry' }
CPProcessOrientationParticipantMotionBehaviour class >> translationForRotation: anAngle center: aPoint [
	| radians cosine sine rotatedCenter |
	anAngle = 90 ifTrue: [ ^ aPoint - (aPoint y negated @ aPoint x) ].
	anAngle = -90 ifTrue: [ ^ aPoint - (aPoint y @ aPoint x negated) ].
	anAngle isZero ifTrue: [ ^ 0 @ 0 ].
	radians := anAngle degreesToRadians.
	cosine := radians cos.
	sine := radians sin.
	rotatedCenter :=
		((aPoint x * cosine) - (aPoint y * sine))
		@
		((aPoint x * sine) + (aPoint y * cosine)).
	^ aPoint - rotatedCenter
]

{ #category : 'accessing' }
CPProcessOrientationParticipantMotionBehaviour >> animationTarget [
	^ element
]

{ #category : 'playing' }
CPProcessOrientationParticipantMotionBehaviour >> applyDestination [
	| translation |
	presentation ifNil: [ ^ self ].
	translation := self class
		translationForRotation: targetRotation
		center: geometricCenter.
	presentation
		translation: translation
		rotation: targetRotation.
	presentation adoptCurrentPresentation
]

{ #category : 'playing' }
CPProcessOrientationParticipantMotionBehaviour >> applyProgress: aProgress [
	| rotation translation |
	rotation := targetRotation * aProgress.
	translation := self class
		translationForRotation: rotation
		center: geometricCenter.
	presentation
		translation: translation
		rotation: rotation
]

{ #category : 'playing' }
CPProcessOrientationParticipantMotionBehaviour >> captureOrigin [
	presentation := CFMotionTransformPresentation on: element
]

{ #category : 'playing' }
CPProcessOrientationParticipantMotionBehaviour >> captureOriginIn: aCoordinator [
	presentation := CFMotionTransformPresentation
		on: element
		using: (aCoordinator transformChannelFor: element)
]

{ #category : 'accessing' }
CPProcessOrientationParticipantMotionBehaviour >> element: anElement [
	element := anElement
]

{ #category : 'testing' }
CPProcessOrientationParticipantMotionBehaviour >> isAtDestination [
	^ targetRotation isZero
]

{ #category : 'playing' }
CPProcessOrientationParticipantMotionBehaviour >> prepareFromCurrentPresentation [
	geometricCenter := element extent / 2.0.
	presentation transformOrigin: BlAffineTransformationTopLeftOrigin new.
	presentation
		translation: 0 @ 0
		rotation: 0
]

{ #category : 'playing' }
CPProcessOrientationParticipantMotionBehaviour >> preserveCurrentPresentation [
	presentation ifNotNil: [ presentation adoptCurrentPresentation ]
]

{ #category : 'accessing' }
CPProcessOrientationParticipantMotionBehaviour >> propertyKey [
	^ CFMotionPropertyKey
		element: element
		property: CFMotionRotationProperty uniqueInstance
]

{ #category : 'playing' }
CPProcessOrientationParticipantMotionBehaviour >> restoreOrigin [
	presentation ifNil: [ ^ self ].
	presentation
		translation: 0 @ 0
		rotation: 0.
	presentation release
]

{ #category : 'accessing' }
CPProcessOrientationParticipantMotionBehaviour >> targetRotation: aNumber [
	targetRotation := aNumber
]
