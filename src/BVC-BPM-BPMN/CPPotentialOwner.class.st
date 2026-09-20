"I represent people eligible to claim and work on a User Task. Actual ownership is runtime instance state, not BPMN definition state."
Class {
	#name : 'CPPotentialOwner',
	#superclass : 'CPHumanPerformer',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPPotentialOwner >> isPotentialOwner [ ^ true ]
