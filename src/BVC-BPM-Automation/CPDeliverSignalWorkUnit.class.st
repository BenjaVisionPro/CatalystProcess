Class {
	#name : 'CPDeliverSignalWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'processExecution', 'signal', 'occurrenceIdentifier', 'payload' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPDeliverSignalWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPDeliverSignalWorkUnit class >> processExecution: aCPProcessExecution signal: aCPSignal occurrenceIdentifier: anOccurrenceIdentifier payload: aDictionary [
	^ self new
		processExecution: aCPProcessExecution;
		signal: aCPSignal;
		occurrenceIdentifier: anOccurrenceIdentifier;
		payload: aDictionary;
		yourself
]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> processExecution [ ^ processExecution ]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> processExecution: anObject [ processExecution := anObject ]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> signal [ ^ signal ]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> signal: anObject [ signal := anObject ]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> occurrenceIdentifier [ ^ occurrenceIdentifier ]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> occurrenceIdentifier: anObject [ occurrenceIdentifier := anObject ]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> payload [ ^ payload ifNil: [ Dictionary new ] ]

{ #category : 'accessing' }
CPDeliverSignalWorkUnit >> payload: aDictionary [ payload := aDictionary ]

{ #category : 'running' }
CPDeliverSignalWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service deliverSignalWorkUnit: self
]
