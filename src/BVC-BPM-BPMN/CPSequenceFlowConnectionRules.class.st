"I own the Process semantic rules that decide whether a new CPSequenceFlow may connect two flow nodes in a resolved CPProcessTopology."
Class {
	#name : 'CPSequenceFlowConnectionRules',
	#superclass : 'Object',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'assessing' }
CPSequenceFlowConnectionRules >> assessConnectionFrom: aSource to: aTarget in: aTopology [
	aSource ifNil: [ ^ self rejectedBecause: 'A source flow node is required.' ].
	aTarget ifNil: [ ^ self rejectedBecause: 'A target flow node is required.' ].
	aSource == aTarget ifTrue: [ ^ self rejectedBecause: 'A sequence flow requires distinct source and target nodes.' ].
	aSource isEndEvent ifTrue: [ ^ self rejectedBecause: 'An end event cannot be the source of a sequence flow.' ].
	aTarget isStartEvent ifTrue: [ ^ self rejectedBecause: 'A start event cannot be the target of a sequence flow.' ].
	((aTopology includesFlowElement: aSource) and: [ aTopology includesFlowElement: aTarget ]) ifFalse: [
		^ self rejectedBecause: 'Both connection endpoints must belong to the process.' ].
	(aTopology hasSequenceFlowFrom: aSource to: aTarget) ifTrue: [
		^ self rejectedBecause: 'A sequence flow already connects these source and target nodes.' ].
	^ CPSequenceFlowConnectionRuleResult allowed
]

{ #category : 'private' }
CPSequenceFlowConnectionRules >> rejectedBecause: aString [
	^ CPSequenceFlowConnectionRuleResult rejectedBecause: aString
]


{ #category : 'assessing' }
CPSequenceFlowConnectionRules >> assessConnectionFrom: aSource to: aTarget in: aTopology ignoring: aSequenceFlow [
	^ self
		assessConnectionFrom: aSource
		to: aTarget
		in: (aTopology withoutSequenceFlow: aSequenceFlow)
]
