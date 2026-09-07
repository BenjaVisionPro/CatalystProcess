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
	aCollaboration ifNil: [ ^ self rejectedBecause: 'A Collaboration is required.' ].
	^ self
		assessConnectionFrom: aSource
		to: aTarget
		participants: aCollaboration participants
]

{ #category : 'assessing' }
CPMessageFlowConnectionRules >> assessConnectionFrom: aSource to: aTarget participants: someParticipants [
	| rejection sourceParticipant targetParticipant |
	rejection := self endpointRejectionFrom: aSource to: aTarget.
	rejection ifNotNil: [ ^ rejection ].
	sourceParticipant := self
		participantForEndpoint: aSource
		in: someParticipants.
	targetParticipant := self
		participantForEndpoint: aTarget
		in: someParticipants.
	^ self
		assessResolvedConnectionFrom: aSource
		to: aTarget
		sourceParticipant: sourceParticipant
		targetParticipant: targetParticipant
]


{ #category : 'assessing' }
CPMessageFlowConnectionRules >> assessConnectionFrom: aSource to: aTarget sourceParticipant: aSourceParticipant targetParticipant: aTargetParticipant [
	| rejection |
	rejection := self endpointRejectionFrom: aSource to: aTarget.
	rejection ifNotNil: [ ^ rejection ].
	^ self
		assessResolvedConnectionFrom: aSource
		to: aTarget
		sourceParticipant: aSourceParticipant
		targetParticipant: aTargetParticipant
]


{ #category : 'private - assessing' }
CPMessageFlowConnectionRules >> assessResolvedConnectionFrom: aSource to: aTarget sourceParticipant: aSourceParticipant targetParticipant: aTargetParticipant [
	aSourceParticipant ifNil: [
		^ self rejectedBecause: 'The source is not represented by a Participant in the Collaboration.' ].
	aTargetParticipant ifNil: [
		^ self rejectedBecause: 'The target is not represented by a Participant in the Collaboration.' ].
	aSourceParticipant == aTargetParticipant ifTrue: [
		^ self rejectedBecause: 'A MessageFlow must connect two separate Participants.' ].
	^ CPMessageFlowConnectionRuleResult allowed
]


{ #category : 'private - assessing' }
CPMessageFlowConnectionRules >> endpointRejectionFrom: aSource to: aTarget [
	aSource ifNil: [ ^ self rejectedBecause: 'A MessageFlow source is required.' ].
	aTarget ifNil: [ ^ self rejectedBecause: 'A MessageFlow target is required.' ].
	aSource == aTarget ifTrue: [
		^ self rejectedBecause: 'A MessageFlow requires distinct source and target interaction nodes.' ].
	aSource canBeMessageFlowEndpoint ifFalse: [
		^ self rejectedBecause: 'The source cannot participate in a MessageFlow.' ].
	aTarget canBeMessageFlowEndpoint ifFalse: [
		^ self rejectedBecause: 'The target cannot participate in a MessageFlow.' ].
	^ nil
]

{ #category : 'private - resolving' }
CPMessageFlowConnectionRules >> participantForEndpoint: anEndpoint in: someParticipants [
	anEndpoint isParticipant ifTrue: [
		^ someParticipants
			detect: [ :each | each == anEndpoint ]
			ifNone: [ nil ] ].
	^ someParticipants
		detect: [ :each | each processRef == anEndpoint owningProcess ]
		ifNone: [ nil ]
]
{ #category : 'private' }
CPMessageFlowConnectionRules >> rejectedBecause: aString [
	^ CPMessageFlowConnectionRuleResult rejectedBecause: aString
]
