Class {
	#name : 'CPAdHocSubProcess',
	#superclass : 'CPSubProcess',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'sub-process type' }
CPAdHocSubProcess class >> subProcessTypeLabel [
	^ 'AdHoc'
]

{ #category : 'sub-process type' }
CPAdHocSubProcess class >> subProcessTypeIcon [
	^ #tilde
]

{ #category : 'defaults' }
CPAdHocSubProcess class >> defaultIcon [
	^ self subProcessTypeIcon
]
