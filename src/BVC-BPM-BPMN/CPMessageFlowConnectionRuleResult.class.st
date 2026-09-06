"I answer whether one proposed MessageFlow connection is permitted, with a user-facing rejection reason."
Class {
	#name : 'CPMessageFlowConnectionRuleResult',
	#superclass : 'Object',
	#instVars : [
		'allowed',
		'message'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'instance creation' }
CPMessageFlowConnectionRuleResult class >> allowed [
	^ self new allowed: true; yourself
]

{ #category : 'instance creation' }
CPMessageFlowConnectionRuleResult class >> rejectedBecause: aString [
	^ self new
		allowed: false;
		message: aString;
		yourself
]

{ #category : 'accessing' }
CPMessageFlowConnectionRuleResult >> allowed: aBoolean [
	allowed := aBoolean
]

{ #category : 'testing' }
CPMessageFlowConnectionRuleResult >> isAllowed [
	^ allowed
]

{ #category : 'accessing' }
CPMessageFlowConnectionRuleResult >> message [
	^ message
]

{ #category : 'accessing' }
CPMessageFlowConnectionRuleResult >> message: aString [
	message := aString
]
