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
