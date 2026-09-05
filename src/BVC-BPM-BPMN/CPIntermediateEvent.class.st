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
{ #category : 'event type' }
CPIntermediateEvent class >> eventTypes [
	^ { CPTimerIntermediateEvent. CPMessageCatchIntermediateEvent. CPMessageThrowIntermediateEvent. CPSignalIntermediateEvent. CPLinkIntermediateEvent }
]
