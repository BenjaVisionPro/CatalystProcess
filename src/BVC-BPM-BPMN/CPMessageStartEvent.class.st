Class {
	#name : 'CPMessageStartEvent',
	#superclass : 'CPStartEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'event type' }
CPMessageStartEvent class >> eventTypeLabel [ ^ 'Message' ]
{ #category : 'event type' }
CPMessageStartEvent class >> eventTypeIcon [ ^ #message ]

{ #category : 'execution' }
CPMessageStartEvent >> matchesInstantiationOccurrence: anOccurrence [
	| definitions |
	definitions := self eventDefinitions.
	definitions size = 1 ifFalse: [ ^ false ].
	^ definitions first messageRef == anOccurrence definition
]

{ #category : 'testing' }
CPMessageStartEvent >> isMessageStartEvent [
	^ true
]
