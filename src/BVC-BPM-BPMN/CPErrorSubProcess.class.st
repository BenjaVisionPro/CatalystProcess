"I represent an interrupting BPMN Event Sub-Process triggered by an Error Start Event."
Class {
	#name : 'CPErrorSubProcess',
	#superclass : 'CPSubProcess',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'sub-process type' }
CPErrorSubProcess class >> subProcessTypeLabel [
	^ 'Error Event'
]

{ #category : 'sub-process type' }
CPErrorSubProcess class >> subProcessTypeIcon [
	^ #circleExclamation
]

{ #category : 'defaults' }
CPErrorSubProcess class >> defaultIcon [
	^ self subProcessTypeIcon
]

{ #category : 'testing' }
CPErrorSubProcess >> isErrorEventSubProcess [
	^ true
]

{ #category : 'testing' }
CPErrorSubProcess >> isEventSubProcess [
	^ true
]
