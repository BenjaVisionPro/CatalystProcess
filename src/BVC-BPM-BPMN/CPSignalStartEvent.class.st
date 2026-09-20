Class {
	#name : 'CPSignalStartEvent',
	#superclass : 'CPStartEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}
{ #category : 'event type' }
CPSignalStartEvent class >> eventTypeLabel [ ^ 'Signal' ]
{ #category : 'event type' }
CPSignalStartEvent class >> eventTypeIcon [ ^ #towerReceive ]

{ #category : 'execution' }
CPSignalStartEvent >> matchesInstantiationOccurrence: anOccurrence [
	| definitions |
	definitions := self eventDefinitions.
	definitions size = 1 ifFalse: [ ^ false ].
	^ definitions first signalRef == anOccurrence definition
]
