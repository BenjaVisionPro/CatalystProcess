Class {
	#name : 'CPServiceTask',
	#superclass : 'CPTask',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'task type' }
CPServiceTask class >> taskTypeLabel [
	^ 'Service'
]

{ #category : 'task type' }
CPServiceTask class >> taskTypeIcon [
	^ #gear
]

{ #category : 'defaults' }
CPServiceTask class >> defaultIcon [
	^ self taskTypeIcon
]
