"I answer whether one proposed sequence-flow connection is permitted by the Process semantic rules, together with a user-facing reason when it is rejected."
Class {
	#name : 'CPSequenceFlowConnectionRuleResult',
	#superclass : 'Object',
	#instVars : [
		'allowed',
		'message'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'instance creation' }
CPSequenceFlowConnectionRuleResult class >> allowed [
	^ self new allowed: true; yourself
]

{ #category : 'instance creation' }
CPSequenceFlowConnectionRuleResult class >> rejectedBecause: aString [
	^ self new allowed: false; message: aString; yourself
]

{ #category : 'accessing' }
CPSequenceFlowConnectionRuleResult >> allowed: aBoolean [
	allowed := aBoolean
]

{ #category : 'testing' }
CPSequenceFlowConnectionRuleResult >> isAllowed [
	^ allowed
]

{ #category : 'accessing' }
CPSequenceFlowConnectionRuleResult >> message [
	^ message
]

{ #category : 'accessing' }
CPSequenceFlowConnectionRuleResult >> message: aString [
	message := aString
]
