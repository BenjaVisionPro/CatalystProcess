Class {
	#name : 'CPDeliverMessageWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [ 'processExecution', 'message', 'occurrenceIdentifier', 'payload' ],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPDeliverMessageWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPDeliverMessageWorkUnit class >> processExecution: aCPProcessExecution message: aCPMessage occurrenceIdentifier: anOccurrenceIdentifier payload: aDictionary [
	^ self new
		processExecution: aCPProcessExecution;
		message: aCPMessage;
		occurrenceIdentifier: anOccurrenceIdentifier;
		payload: aDictionary;
		yourself
]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> processExecution [ ^ processExecution ]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> processExecution: anObject [ processExecution := anObject ]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> message [ ^ message ]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> message: anObject [ message := anObject ]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> occurrenceIdentifier [ ^ occurrenceIdentifier ]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> occurrenceIdentifier: anObject [ occurrenceIdentifier := anObject ]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> payload [ ^ payload ifNil: [ Dictionary new ] ]

{ #category : 'accessing' }
CPDeliverMessageWorkUnit >> payload: aDictionary [ payload := aDictionary ]

{ #category : 'running' }
CPDeliverMessageWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service deliverMessageWorkUnit: self
]
