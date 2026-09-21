Class {
	#name : 'CPFaultServiceInvocationWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'invocation', 'error', 'occurrenceIdentifier', 'payload' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPFaultServiceInvocationWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPFaultServiceInvocationWorkUnit class >> invocation: aCPExternalInvocation error: aCPError occurrenceIdentifier: anOccurrenceIdentifier payload: aDictionary [
	^ self new invocation: aCPExternalInvocation; error: aCPError; occurrenceIdentifier: anOccurrenceIdentifier; payload: aDictionary; yourself
]

{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> invocation [ ^ invocation ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> invocation: aCPExternalInvocation [ invocation := aCPExternalInvocation ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> error [ ^ error ]
{ #category : 'accessing' }
CPFaultServiceInvocationWorkUnit >> error: aCPError [ error := aCPError ]
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
