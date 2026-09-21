Class {
	#name : 'CPFaultServiceInvocationWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processExecutionIdentifier',
		'invocationIdentifier',
		'errorIdentifier',
		'occurrenceIdentifier',
		'payload'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPFaultServiceInvocationWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPFaultServiceInvocationWorkUnit class >> processExecutionIdentifier: aProcessExecutionIdentifier invocationIdentifier: anInvocationIdentifier errorIdentifier: anErrorIdentifier occurrenceIdentifier: anOccurrenceIdentifier payload: aDictionary [
	^ self new
		processExecutionIdentifier: aProcessExecutionIdentifier;
		invocationIdentifier: anInvocationIdentifier;
		errorIdentifier: anErrorIdentifier;
		occurrenceIdentifier: anOccurrenceIdentifier;
		payload: aDictionary;
		yourself
]

{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> processExecutionIdentifier [ ^ processExecutionIdentifier ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> processExecutionIdentifier: anIdentifier [ processExecutionIdentifier := anIdentifier ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> invocationIdentifier [ ^ invocationIdentifier ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> invocationIdentifier: anIdentifier [ invocationIdentifier := anIdentifier ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> errorIdentifier [ ^ errorIdentifier ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> errorIdentifier: anIdentifier [ errorIdentifier := anIdentifier ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> occurrenceIdentifier [ ^ occurrenceIdentifier ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> occurrenceIdentifier: anIdentifier [ occurrenceIdentifier := anIdentifier ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> payload [ ^ payload ifNil: [ Dictionary new ] ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> payload: aDictionary [ payload := aDictionary ]

{ #category : 'running' }
CPFaultServiceInvocationWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service faultServiceInvocationWorkUnit: self
]
