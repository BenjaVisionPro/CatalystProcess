Class {
	#name : 'CPErrorStartEvent',
	#superclass : 'CPStartEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'event type' }
CPErrorStartEvent class >> eventTypeLabel [
	^ 'Error'
]

{ #category : 'event type' }
CPErrorStartEvent class >> eventTypeIcon [
	^ #circleExclamation
]
