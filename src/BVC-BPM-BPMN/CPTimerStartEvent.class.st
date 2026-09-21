Class {
	#name : 'CPTimerStartEvent',
	#superclass : 'CPStartEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'event type' }
CPTimerStartEvent class >> eventTypeLabel [ ^ 'Timer' ]
{ #category : 'event type' }
CPTimerStartEvent class >> eventTypeIcon [ ^ #timer ]

{ #category : 'execution' }
CPTimerStartEvent >> matchesInstantiationOccurrence: anOccurrence [
	| definitions |
	definitions := self eventDefinitions.
	definitions size = 1 ifFalse: [ ^ false ].
	^ definitions first == anOccurrence definition
]

{ #category : 'testing' }
CPTimerStartEvent >> isTimerStartEvent [
	^ true
]
