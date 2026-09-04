Class {
	#name : 'CPManualTask',
	#superclass : 'CPTask',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'task type' }
CPManualTask class >> taskTypeLabel [
	^ 'Manual'
]

{ #category : 'task type' }
CPManualTask class >> taskTypeIcon [
	^ #personDigging
]

{ #category : 'defaults' }
CPManualTask class >> defaultIcon [
	^ self taskTypeIcon
]
