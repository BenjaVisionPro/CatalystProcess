Class {
	#name : 'CPEndEvent',
	#superclass : 'CPEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPEndEvent >> isEndEvent [
	^ true
]


{ #category : 'defaults' }
CPEndEvent class >> defaultIcon [
	^ #endEvent
]

{ #category : 'event type' }
CPEndEvent class >> endEventTypes [
	^ { CPNoneEndEvent . CPMessageEndEvent . CPErrorEndEvent . CPTerminateEndEvent . CPSignalEndEvent }
]
