Class {
	#name : 'CPCompleteServiceInvocationWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processExecutionIdentifier',
		'invocationIdentifier',
		'occurrenceIdentifier',
		'payload'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPCompleteServiceInvocationWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'instance creation' }
CPCompleteServiceInvocationWorkUnit class >> processExecutionIdentifier: aProcessExecutionIdentifier invocationIdentifier: anInvocationIdentifier occurrenceIdentifier: anOccurrenceIdentifier payload: aDictionary [
	^ self new
		processExecutionIdentifier: aProcessExecutionIdentifier;
		invocationIdentifier: anInvocationIdentifier;
		occurrenceIdentifier: anOccurrenceIdentifier;
		payload: aDictionary;
		yourself
]

{ #category : 'accessing' }
CPCompleteServiceInvocationWorkUnit >> processExecutionIdentifier [ ^ processExecutionIdentifier ]
{ #category : 'accessing' }
CPCompleteServiceInvocationWorkUnit >> processExecutionIdentifier: anIdentifier [ processExecutionIdentifier := anIdentifier ]
{ #category : 'accessing' }
CPCompleteServiceInvocationWorkUnit >> invocationIdentifier [ ^ invocationIdentifier ]
{ #category : 'accessing' }
CPCompleteServiceInvocationWorkUnit >> invocationIdentifier: anIdentifier [ invocationIdentifier := anIdentifier ]
{ #category : 'accessing' }
CPCompleteServiceInvocationWorkUnit >> occurrenceIdentifier [ ^ occurrenceIdentifier ]
{ #category : 'accessing' }
CPCompleteServiceInvocationWorkUnit >> occurrenceIdentifier: anIdentifier [ occurrenceIdentifier := anIdentifier ]
{ #category : 'accessing' }
CPCompleteServiceInvocationWorkUnit >> payload [ ^ payload ifNil: [ Dictionary new ] ]
{ #category : 'accessing' }
CPCompleteServiceInvocationWorkUnit >> payload: aDictionary [ payload := aDictionary ]

{ #category : 'running' }
CPCompleteServiceInvocationWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service completeServiceInvocationWorkUnit: self
]
