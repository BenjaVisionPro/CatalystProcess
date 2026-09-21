Class {
	#name : 'CPTriggerTimerWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'processExecutionIdentifier',
		'timerSubscriptionIdentifier',
		'occurrenceIdentifier'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPTriggerTimerWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'instance creation' }
CPTriggerTimerWorkUnit class >> processExecutionIdentifier: aProcessExecutionIdentifier timerSubscriptionIdentifier: aTimerSubscriptionIdentifier occurrenceIdentifier: anOccurrenceIdentifier [
	^ self new
		processExecutionIdentifier: aProcessExecutionIdentifier;
		timerSubscriptionIdentifier: aTimerSubscriptionIdentifier;
		occurrenceIdentifier: anOccurrenceIdentifier;
		yourself
]

{ #category : 'accessing' }
CPTriggerTimerWorkUnit >> processExecutionIdentifier [
	^ processExecutionIdentifier
]

{ #category : 'accessing' }
CPTriggerTimerWorkUnit >> processExecutionIdentifier: anObject [
	processExecutionIdentifier := anObject
]

{ #category : 'accessing' }
CPTriggerTimerWorkUnit >> timerSubscriptionIdentifier [
	^ timerSubscriptionIdentifier
]

{ #category : 'accessing' }
CPTriggerTimerWorkUnit >> timerSubscriptionIdentifier: anObject [
	timerSubscriptionIdentifier := anObject
]

{ #category : 'accessing' }
CPTriggerTimerWorkUnit >> occurrenceIdentifier [
	^ occurrenceIdentifier
]

{ #category : 'accessing' }
CPTriggerTimerWorkUnit >> occurrenceIdentifier: anObject [
	occurrenceIdentifier := anObject
]

{ #category : 'running' }
CPTriggerTimerWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service triggerTimerWorkUnit: self
]
