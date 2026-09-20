"I represent the abstract BPMN LoopCharacteristics owned by an Activity. Runtime loop counters belong to Activity execution state, not to me."
Class {
	#name : 'CPLoopCharacteristics',
	#superclass : 'CFIdentifiableObject',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}


{ #category : 'testing' }
CPLoopCharacteristics >> isStandardLoop [
	^ false
]
