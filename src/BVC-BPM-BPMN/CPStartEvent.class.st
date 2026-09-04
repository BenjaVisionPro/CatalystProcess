Class {
	#name : 'CPStartEvent',
	#superclass : 'CPEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPStartEvent >> isStartEvent [ ^ true ]


{ #category : 'defaults' }
CPStartEvent class >> defaultIcon [
	^ #startEvent
]
