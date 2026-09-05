Class {
	#name : 'CPMultiInstanceSubProcess',
	#superclass : 'CPSubProcess',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'sub-process type' }
CPMultiInstanceSubProcess class >> subProcessTypeLabel [
	^ 'Multi Instance'
]

{ #category : 'sub-process type' }
CPMultiInstanceSubProcess class >> subProcessTypeIcon [
	^ #bars
]

{ #category : 'defaults' }
CPMultiInstanceSubProcess class >> defaultIcon [
	^ self subProcessTypeIcon
]
