Class {
	#name : 'CPStartProcessWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processDeploymentIdentifier'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPStartProcessWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'instance creation' }
CPStartProcessWorkUnit class >> processDeploymentIdentifier: aProcessDeploymentIdentifier [
	^ self new
		processDeploymentIdentifier: aProcessDeploymentIdentifier;
		yourself
]

{ #category : 'accessing' }
CPStartProcessWorkUnit >> processDeploymentIdentifier [
	^ processDeploymentIdentifier
]

{ #category : 'accessing' }
CPStartProcessWorkUnit >> processDeploymentIdentifier: anIdentifier [
	processDeploymentIdentifier := anIdentifier
]

{ #category : 'running' }
CPStartProcessWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service startProcessWorkUnit: self
]
