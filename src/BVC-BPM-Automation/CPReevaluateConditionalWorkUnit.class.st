Class {
	#name : 'CPReevaluateConditionalWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'conditionalSubscription'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'instance creation' }
CPReevaluateConditionalWorkUnit class >> conditionalSubscription: aConditionalSubscription [
	^ self new
		conditionalSubscription: aConditionalSubscription;
		yourself
]

{ #category : 'service context' }
CPReevaluateConditionalWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'accessing' }
CPReevaluateConditionalWorkUnit >> conditionalSubscription [
	^ conditionalSubscription
]

{ #category : 'accessing' }
CPReevaluateConditionalWorkUnit >> conditionalSubscription: aConditionalSubscription [
	conditionalSubscription := aConditionalSubscription
]

{ #category : 'running' }
CPReevaluateConditionalWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service reevaluateConditionalWorkUnit: self
]
