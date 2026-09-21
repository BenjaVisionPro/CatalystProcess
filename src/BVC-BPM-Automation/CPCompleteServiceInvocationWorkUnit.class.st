Class {
	#name : 'CPCompleteServiceInvocationWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'invocation', 'occurrenceIdentifier', 'payload' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPCompleteServiceInvocationWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPCompleteServiceInvocationWorkUnit class >> invocation: aCPExternalInvocation occurrenceIdentifier: anOccurrenceIdentifier payload: aDictionary [
	^ self new invocation: aCPExternalInvocation; occurrenceIdentifier: anOccurrenceIdentifier; payload: aDictionary; yourself
]

{ #category : 'accessing' }
CPCompleteServiceInvocationWorkUnit >> invocation [ ^ invocation ]
{ #category : 'accessing' }
CPCompleteServiceInvocationWorkUnit >> invocation: aCPExternalInvocation [ invocation := aCPExternalInvocation ]
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
