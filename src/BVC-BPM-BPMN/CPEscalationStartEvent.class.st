Class {
	#name : 'CPEscalationStartEvent',
	#superclass : 'CPStartEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'event type' }
CPEscalationStartEvent class >> eventTypeLabel [
	^ 'Escalation'
]

{ #category : 'event type' }
CPEscalationStartEvent class >> eventTypeIcon [
	^ #chevronsUp
]
