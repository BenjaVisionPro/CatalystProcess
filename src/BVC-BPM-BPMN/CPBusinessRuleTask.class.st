Class {
	#name : 'CPBusinessRuleTask',
	#superclass : 'CPTask',
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
