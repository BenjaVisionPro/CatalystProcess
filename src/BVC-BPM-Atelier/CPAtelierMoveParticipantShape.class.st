"I move one Participant Pool in the staged Collaboration diagram."
Class {
	#name : 'CPAtelierMoveParticipantShape',
	#superclass : 'CPAtelierParticipantShapeBoundsOperation',
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'private - applying' }
CPAtelierMoveParticipantShape >> endpointDeltaFrom: currentBounds to: proposedBounds [
	^ proposedBounds origin - currentBounds origin
]
