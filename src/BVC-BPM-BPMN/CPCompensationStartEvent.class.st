Class {
	#name : 'CPCompensationStartEvent',
	#superclass : 'CPStartEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'event type' }
CPCompensationStartEvent class >> eventTypeLabel [
	^ 'Compensation'
]

{ #category : 'event type' }
CPCompensationStartEvent class >> eventTypeIcon [
	^ #rotateLeft
]
