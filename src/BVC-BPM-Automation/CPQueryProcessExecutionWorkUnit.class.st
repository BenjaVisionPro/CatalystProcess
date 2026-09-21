Class {
	#name : 'CPQueryProcessExecutionWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processExecutionIdentifier'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPQueryProcessExecutionWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'instance creation' }
CPQueryProcessExecutionWorkUnit class >> processExecutionIdentifier: anIdentifier [
	^ self new
		processExecutionIdentifier: anIdentifier;
		yourself
]

{ #category : 'accessing' }
CPQueryProcessExecutionWorkUnit >> processExecutionIdentifier [
	^ processExecutionIdentifier
]

{ #category : 'accessing' }
CPQueryProcessExecutionWorkUnit >> processExecutionIdentifier: anIdentifier [
	processExecutionIdentifier := anIdentifier
]

{ #category : 'running' }
CPQueryProcessExecutionWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service queryProcessExecutionWorkUnit: self
]
