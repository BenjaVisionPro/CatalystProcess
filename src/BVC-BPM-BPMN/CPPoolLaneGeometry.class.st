"I define the presentation-independent BPMN-DI geometry shared by Pool/Lane editing and projection.

I know the standard Participant and Lane header/body offsets and the exact rigid quarter-turn used when a Participant changes BPMNShape isHorizontal. I contain no Bloc layout or Motion behavior."
Class {
	#name : 'CPPoolLaneGeometry',
	#superclass : 'Object',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'geometry - offsets' }
CPPoolLaneGeometry class >> participantContentOriginOffsetForHorizontal: isHorizontal [
	^ isHorizontal
		ifTrue: [ 36 @ 0 ]
		ifFalse: [ 0 @ 36 ]
]

{ #category : 'geometry - offsets' }
CPPoolLaneGeometry class >> laneBodyOriginOffsetForHorizontal: isHorizontal [
	^ isHorizontal
		ifTrue: [ 30 @ 0 ]
		ifFalse: [ 0 @ 30 ]
]

{ #category : 'geometry - rotation' }
CPPoolLaneGeometry class >> rotateProcessPoint: aPoint within: currentBodyExtent toHorizontal: isHorizontal [
	"Horizontal -> vertical is clockwise so the left Pool header becomes the top header. The reverse transition is the exact inverse."
	^ isHorizontal
		ifTrue: [ aPoint y @ (currentBodyExtent x - aPoint x) ]
		ifFalse: [ (currentBodyExtent y - aPoint y) @ aPoint x ]
]

{ #category : 'geometry - rotation' }
CPPoolLaneGeometry class >> rotateProcessVector: aPoint toHorizontal: isHorizontal [
	"Rotate a displacement vector through the same quarter-turn as Process
	coordinates, without an origin or extent term."
	^ isHorizontal
		ifTrue: [ aPoint y @ aPoint x negated ]
		ifFalse: [ aPoint y negated @ aPoint x ]
]

{ #category : 'geometry - rotation' }
CPPoolLaneGeometry class >> rotateStructuralBounds: aRectangle within: currentBodyExtent toHorizontal: isHorizontal [
	"Pool/Lane structure rotates with the coordinate system, so width and height exchange."
	^ isHorizontal
		ifTrue: [
			aRectangle top @ (currentBodyExtent x - aRectangle right)
				extent: aRectangle height @ aRectangle width ]
		ifFalse: [
			(currentBodyExtent y - aRectangle bottom) @ aRectangle left
				extent: aRectangle height @ aRectangle width ]
]

{ #category : 'geometry - rotation' }
CPPoolLaneGeometry class >> rotateUprightBounds: aRectangle within: currentBodyExtent toHorizontal: isHorizontal [
	"An upright BPMN node follows the Pool rotation by its centre without rotating its own extent."
	| proposedCenter |
	proposedCenter := self
		rotateProcessPoint: aRectangle center
		within: currentBodyExtent
		toHorizontal: isHorizontal.
	^ (proposedCenter - (aRectangle extent / 2)) extent: aRectangle extent
]


{ #category : 'geometry - rotation' }
CPPoolLaneGeometry class >> rotateBoundaryEventBounds: eventBounds fromActivityBounds: currentActivityBounds toActivityBounds: proposedActivityBounds toHorizontal: isHorizontal [
	"Keep an attached Boundary Event on the perimeter of an upright Activity while
	the Pool coordinate system quarter-turns. The attachment side rotates with the
	Pool and the normalized position along that side is preserved."
	| center leftDistance rightDistance topDistance bottomDistance minimum verticalSide ratio proposedCenter |
	center := eventBounds center.
	leftDistance := (center x - currentActivityBounds left) abs.
	rightDistance := (center x - currentActivityBounds right) abs.
	topDistance := (center y - currentActivityBounds top) abs.
	bottomDistance := (center y - currentActivityBounds bottom) abs.
	minimum := { leftDistance. rightDistance. topDistance. bottomDistance } min.
	verticalSide := leftDistance = minimum or: [ rightDistance = minimum ].
	verticalSide
		ifTrue: [
			ratio := currentActivityBounds height isZero
				ifTrue: [ 0.5 ]
				ifFalse: [ (center y - currentActivityBounds top) / currentActivityBounds height ].
			ratio := (ratio max: 0) min: 1.
			isHorizontal
				ifTrue: [
					proposedCenter := (proposedActivityBounds left + (proposedActivityBounds width * ratio))
						@ ((leftDistance = minimum)
							ifTrue: [ proposedActivityBounds bottom ]
							ifFalse: [ proposedActivityBounds top ]) ]
				ifFalse: [
					proposedCenter := (proposedActivityBounds left + (proposedActivityBounds width * (1 - ratio)))
						@ ((leftDistance = minimum)
							ifTrue: [ proposedActivityBounds top ]
							ifFalse: [ proposedActivityBounds bottom ]) ] ]
		ifFalse: [
			ratio := currentActivityBounds width isZero
				ifTrue: [ 0.5 ]
				ifFalse: [ (center x - currentActivityBounds left) / currentActivityBounds width ].
			ratio := (ratio max: 0) min: 1.
			isHorizontal
				ifTrue: [
					proposedCenter := ((topDistance = minimum)
						ifTrue: [ proposedActivityBounds left ]
						ifFalse: [ proposedActivityBounds right ])
						@ (proposedActivityBounds top + (proposedActivityBounds height * (1 - ratio))) ]
				ifFalse: [
					proposedCenter := ((topDistance = minimum)
						ifTrue: [ proposedActivityBounds right ]
						ifFalse: [ proposedActivityBounds left ])
						@ (proposedActivityBounds top + (proposedActivityBounds height * ratio)) ] ].
	^ (proposedCenter - (eventBounds extent / 2)) extent: eventBounds extent
]

{ #category : 'geometry - rotation' }
CPPoolLaneGeometry class >> rotatedParticipantBoundsFrom: aRectangle [
	| proposedExtent |
	proposedExtent := aRectangle height @ aRectangle width.
	^ (aRectangle center - (proposedExtent / 2)) extent: proposedExtent
]

{ #category : 'geometry - rotation' }
CPPoolLaneGeometry class >> rotateCollaborationPoint: aPoint around: aCenter toHorizontal: isHorizontal [
	| relative rotated |
	relative := aPoint - aCenter.
	rotated := isHorizontal
		ifTrue: [ relative y @ relative x negated ]
		ifFalse: [ relative y negated @ relative x ].
	^ aCenter + rotated
]
