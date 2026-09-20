Class {
	#name : 'CPStartEvent',
	#superclass : 'CPCatchEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPStartEvent >> isStartEvent [ ^ true ]


{ #category : 'defaults' }
CPStartEvent class >> defaultIcon [
	^ #startEvent
]

{ #category : 'event type' }
CPStartEvent class >> startEventTypes [
	^ { CPNoneStartEvent . CPMessageStartEvent . CPTimerStartEvent . CPSignalStartEvent . CPConditionalStartEvent . CPCompensationStartEvent }
]

{ #category : 'event type' }
CPStartEvent class >> eventTypeLabel [
	^ 'None'
]

{ #category : 'event type' }
CPStartEvent class >> eventTypeIcon [
	^ #circle
]

{ #category : 'testing' }
CPStartEvent >> isStartEvent [
	^ true
]

{ #category : 'execution' }
CPStartEvent >> matchesInstantiationOccurrence: anOccurrence [
	^ false
]

{ #category : 'execution' }
CPStartEvent >> conditionAllowsInstantiationIn: anExecutionScope [
	^ false
]
