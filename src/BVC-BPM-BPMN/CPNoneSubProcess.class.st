Class {
	#name : 'CPNoneSubProcess',
	#superclass : 'CPSubProcess',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'sub-process type' }
CPNoneSubProcess class >> subProcessTypeLabel [ ^ 'None' ]

{ #category : 'sub-process type' }
CPNoneSubProcess class >> subProcessTypeIcon [ ^ #circle ]

{ #category : 'defaults' }
CPNoneSubProcess class >> defaultIcon [ ^ self subProcessTypeIcon ]
