"I own the BPMN semantic rules for creating a MessageFlow in one Collaboration.

A MessageFlow endpoint must be a message-capable InteractionNode represented by one of the Collaboration's Participants. Source and target must resolve to different Participants because BPMN MessageFlows connect separate Pools."
Class {
	#name : 'CPMessageFlowConnectionRules',
	#superclass : 'Object',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'assessing' }
CPMessageFlowConnectionRules >> assessConnectionFrom: aSource to: aTarget in: aCollaboration [
	| sourceParticipant targetParticipant |
	aCollaboration ifNil: [ ^ self rejectedBecause: 'A Collaboration is required.' ].
	aSource ifNil: [ ^ self rejectedBecause: 'A MessageFlow source is required.' ].
	aTarget ifNil: [ ^ self rejectedBecause: 'A MessageFlow target is required.' ].
	aSource == aTarget ifTrue: [
		^ self rejectedBecause: 'A MessageFlow requires distinct source and target interaction nodes.' ].
	aSource canBeMessageFlowEndpoint ifFalse: [
		^ self rejectedBecause: 'The source cannot participate in a MessageFlow.' ].
	aTarget canBeMessageFlowEndpoint ifFalse: [
		^ self rejectedBecause: 'The target cannot participate in a MessageFlow.' ].

	sourceParticipant := aCollaboration participantForEndpoint: aSource.
	targetParticipant := aCollaboration participantForEndpoint: aTarget.
	sourceParticipant ifNil: [
		^ self rejectedBecause: 'The source is not represented by a Participant in the Collaboration.' ].
	targetParticipant ifNil: [
		^ self rejectedBecause: 'The target is not represented by a Participant in the Collaboration.' ].
	sourceParticipant == targetParticipant ifTrue: [
		^ self rejectedBecause: 'A MessageFlow must connect two separate Participants.' ].
	^ CPMessageFlowConnectionRuleResult allowed
]

{ #category : 'private' }
CPMessageFlowConnectionRules >> rejectedBecause: aString [
	^ CPMessageFlowConnectionRuleResult rejectedBecause: aString
]
