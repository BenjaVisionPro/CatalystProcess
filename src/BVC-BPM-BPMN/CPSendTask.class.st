Class {
	#name : 'CPSendTask',
	#superclass : 'CPTask',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'task type' }
CPSendTask class >> taskTypeLabel [
	^ 'Send'
]

{ #category : 'task type' }
CPSendTask class >> taskTypeIcon [
	^ #arrowUpFromSquare
]

{ #category : 'defaults' }
CPSendTask class >> defaultIcon [
	^ self taskTypeIcon
]
