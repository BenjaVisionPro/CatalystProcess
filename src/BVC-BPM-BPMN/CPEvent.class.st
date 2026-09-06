Class {
	#name : 'CPEvent',
	#superclass : 'CPFlowNode',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPEvent >> isEvent [
	^ true
]


{ #category : 'message flow' }
CPEvent >> canBeMessageFlowEndpoint [
	^ true
]
