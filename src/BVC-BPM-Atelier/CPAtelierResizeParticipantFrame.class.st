"I resize only the Collaboration Participant frame for a composite Atelier operation that already owns the corresponding Lane DI changes.

Unlike CPAtelierResizeParticipantShape I do not independently reflow Lanes. This prevents a composite operation such as Lane insertion from assessing Lane geometry against a stale pre-insertion hierarchy."
Class {
	#name : 'CPAtelierResizeParticipantFrame',
	#superclass : 'CPAtelierParticipantShapeBoundsOperation',
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'private - applying' }
CPAtelierResizeParticipantFrame >> endpointDeltaFrom: currentBounds to: proposedBounds [
	^ proposedBounds center - currentBounds center
]
