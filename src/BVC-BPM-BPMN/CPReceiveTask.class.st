Class {
	#name : 'CPReceiveTask',
	#superclass : 'CPTask',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'task type' }
CPReceiveTask class >> taskTypeLabel [
	^ 'Receive'
]

{ #category : 'task type' }
CPReceiveTask class >> taskTypeIcon [
	^ #arrowDownToSquare
]

{ #category : 'defaults' }
CPReceiveTask class >> defaultIcon [
	^ self taskTypeIcon
]
