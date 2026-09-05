Class {
	#name : 'CPIntermediateEvent',
	#superclass : 'CPEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPIntermediateEvent >> isIntermediateEvent [
	^ true
]

{ #category : 'defaults' }
CPIntermediateEvent class >> defaultIcon [
	^ #intermediateEvent
]
