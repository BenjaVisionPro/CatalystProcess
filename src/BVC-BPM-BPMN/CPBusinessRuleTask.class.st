Class {
	#name : 'CPBusinessRuleTask',
	#superclass : 'CPTask',
	#instVars : [ 'implementation' ],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'task type' }
CPBusinessRuleTask class >> taskTypeLabel [
	^ 'Business Rule'
]

{ #category : 'task type' }
CPBusinessRuleTask class >> taskTypeIcon [
	^ #buildingMemo
]

{ #category : 'defaults' }
CPBusinessRuleTask class >> defaultIcon [
	^ self taskTypeIcon
]

{ #category : 'initialization' }
CPBusinessRuleTask >> initialize [
	super initialize.
	implementation := '##unspecified'
]

{ #category : 'accessing' }
CPBusinessRuleTask >> implementation [
	^ implementation
]

{ #category : 'accessing' }
CPBusinessRuleTask >> implementation: aString [
	implementation := aString
]

{ #category : 'descriptions' }
CPBusinessRuleTask >> implementationDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #implementation;
		label: 'Implementation';
		priority: 100;
		group: 'Execution';
		beRequired;
		yourself
]
