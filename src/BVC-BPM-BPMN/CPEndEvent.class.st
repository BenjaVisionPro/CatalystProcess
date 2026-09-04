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
