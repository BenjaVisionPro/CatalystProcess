"I resize one Participant Pool in the staged Collaboration diagram."
Class {
	#name : 'CPAtelierResizeParticipantShape',
	#superclass : 'CPAtelierParticipantShapeBoundsOperation',
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'private - applying' }
CPAtelierResizeParticipantShape >> endpointDeltaFrom: currentBounds to: proposedBounds [
	^ proposedBounds center - currentBounds center
]
