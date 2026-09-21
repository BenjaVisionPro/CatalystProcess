Class {
	#name : 'CPDeliverMessageWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processExecutionIdentifier',
		'messageIdentifier',
		'occurrenceIdentifier',
		'payload'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPDeliverMessageWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'instance creation' }
CPDeliverMessageWorkUnit class >> processExecutionIdentifier: aProcessExecutionIdentifier messageIdentifier: aMessageIdentifier occurrenceIdentifier: anOccurrenceIdentifier payload: aDictionary [
	^ self new
		processExecutionIdentifier: aProcessExecutionIdentifier;
		messageIdentifier: aMessageIdentifier;
		occurrenceIdentifier: anOccurrenceIdentifier;
		payload: aDictionary;
		yourself
]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> processExecutionIdentifier [
	^ processExecutionIdentifier
]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> processExecutionIdentifier: anObject [
	processExecutionIdentifier := anObject
]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> messageIdentifier [
	^ messageIdentifier
]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> messageIdentifier: anObject [
	messageIdentifier := anObject
]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> occurrenceIdentifier [
	^ occurrenceIdentifier
]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> occurrenceIdentifier: anObject [
	occurrenceIdentifier := anObject
]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> payload [
	^ payload ifNil: [ Dictionary new ]
]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> payload: aDictionary [
	payload := aDictionary
]

{ #category : 'running' }
CPDeliverMessageWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service deliverMessageWorkUnit: self
]
