"I describe one Participant resize together with the Lane DI reflow required to keep every LaneSet covering the full Pool body."
Class {
	#name : 'CPAtelierResizeParticipantAssessment',
	#superclass : 'CPAtelierMoveShapeAssessment',
	#instVars : [
		'proposedLaneBoundsByShape'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> proposedLaneBoundsByShape [
	^ proposedLaneBoundsByShape
]

{ #category : 'accessing' }
CPAtelierResizeParticipantAssessment >> proposedLaneBoundsByShape: aDictionary [
	proposedLaneBoundsByShape := aDictionary
]
