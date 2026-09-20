"I represent an interrupting BPMN Event Sub-Process triggered by an Error Start Event."
Class {
	#name : 'CPErrorSubProcess',
	#superclass : 'CPSubProcess',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPErrorSubProcess >> initialize [
	super initialize.
	self triggeredByEvent: true
]

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


