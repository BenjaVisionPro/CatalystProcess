Class {
	#name : 'CPDeliverSignalWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processExecutionIdentifier',
		'signalIdentifier',
		'occurrenceIdentifier',
		'payload'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPDeliverSignalWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'instance creation' }
CPDeliverSignalWorkUnit class >> processExecutionIdentifier: aProcessExecutionIdentifier signalIdentifier: aSignalIdentifier occurrenceIdentifier: anOccurrenceIdentifier payload: aDictionary [
	^ self new
		processExecutionIdentifier: aProcessExecutionIdentifier;
		signalIdentifier: aSignalIdentifier;
		occurrenceIdentifier: anOccurrenceIdentifier;
		payload: aDictionary;
		yourself
]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> processExecutionIdentifier [
	^ processExecutionIdentifier
]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> processExecutionIdentifier: anObject [
	processExecutionIdentifier := anObject
]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> signalIdentifier [
	^ signalIdentifier
]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> signalIdentifier: anObject [
	signalIdentifier := anObject
]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> occurrenceIdentifier [
	^ occurrenceIdentifier
]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> occurrenceIdentifier: anObject [
	occurrenceIdentifier := anObject
]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> payload [
	^ payload ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> payload: aDictionary [
	payload := aDictionary
]

{ #category : 'running' }
CPDeliverSignalWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service deliverSignalWorkUnit: self
]
