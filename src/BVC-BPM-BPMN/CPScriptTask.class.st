Class {
	#name : 'CPScriptTask',
	#superclass : 'CPTask',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'task type' }
CPScriptTask class >> taskTypeLabel [
	^ 'Script'
]

{ #category : 'task type' }
CPScriptTask class >> taskTypeIcon [
	^ #scroll
]

{ #category : 'defaults' }
CPScriptTask class >> defaultIcon [
	^ self taskTypeIcon
]
