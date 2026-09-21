Class {
	#name : 'CPTriggerTimerWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'timerSubscription', 'occurrenceIdentifier' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPTriggerTimerWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPTriggerTimerWorkUnit class >> timerSubscription: aCPTimerSubscription occurrenceIdentifier: anOccurrenceIdentifier [
	^ self new timerSubscription: aCPTimerSubscription; occurrenceIdentifier: anOccurrenceIdentifier; yourself
]

{ #category : 'accessing' }
CPTriggerTimerWorkUnit >> timerSubscription [ ^ timerSubscription ]

{ #category : 'accessing' }
CPTriggerTimerWorkUnit >> timerSubscription: aCPTimerSubscription [ timerSubscription := aCPTimerSubscription ]

{ #category : 'accessing' }
CPTriggerTimerWorkUnit >> occurrenceIdentifier [ ^ occurrenceIdentifier ]

{ #category : 'accessing' }
CPTriggerTimerWorkUnit >> occurrenceIdentifier: anObject [ occurrenceIdentifier := anObject ]

{ #category : 'running' }
CPTriggerTimerWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service triggerTimerWorkUnit: self
]
