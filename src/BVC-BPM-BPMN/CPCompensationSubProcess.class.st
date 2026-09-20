Class {
	#name : 'CPCompensationSubProcess',
	#superclass : 'CPSubProcess',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}


{ #category : 'initialization' }
CPCompensationSubProcess >> initialize [
	super initialize.
	self triggeredByEvent: true.
	self isForCompensation: true
]

{ #category : 'sub-process type' }
CPCompensationSubProcess class >> subProcessTypeLabel [
	^ 'Compensation'
]

{ #category : 'sub-process type' }
CPCompensationSubProcess class >> subProcessTypeIcon [
	^ #anglesLeft
]

{ #category : 'defaults' }
CPCompensationSubProcess class >> defaultIcon [
	^ self subProcessTypeIcon
]

