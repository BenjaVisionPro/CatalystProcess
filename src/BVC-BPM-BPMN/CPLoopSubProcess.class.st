Class {
	#name : 'CPLoopSubProcess',
	#superclass : 'CPSubProcess',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'sub-process type' }
CPLoopSubProcess class >> subProcessTypeLabel [
	^ 'Loop'
]

{ #category : 'sub-process type' }
CPLoopSubProcess class >> subProcessTypeIcon [
	^ #arrowRotateLeft
]

{ #category : 'defaults' }
CPLoopSubProcess class >> defaultIcon [
	^ self subProcessTypeIcon
]
