Class {
	#name : 'CPTerminateProcessWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processExecutionIdentifier'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPTerminateProcessWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'instance creation' }
CPTerminateProcessWorkUnit class >> processExecutionIdentifier: anExecutionIdentifier [
	^ self new
		processExecutionIdentifier: anExecutionIdentifier;
		yourself
]

{ #category : 'accessing' }
CPTerminateProcessWorkUnit >> processExecutionIdentifier [
	^ processExecutionIdentifier
]

{ #category : 'accessing' }
CPTerminateProcessWorkUnit >> processExecutionIdentifier: anExecutionIdentifier [
	processExecutionIdentifier := anExecutionIdentifier
]

{ #category : 'running' }
CPTerminateProcessWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service terminateProcessWorkUnit: self
]
