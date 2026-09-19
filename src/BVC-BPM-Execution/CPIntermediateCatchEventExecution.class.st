Class {
	#name : 'CPIntermediateCatchEventExecution',
	#superclass : 'CPEventExecution',
	#instVars : [ 'waiting', 'subscription' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPIntermediateCatchEventExecution >> initialize [
	super initialize.
	waiting := true
]

{ #category : 'testing' }
CPIntermediateCatchEventExecution >> isWaiting [ ^ waiting ]

{ #category : 'testing' }
CPIntermediateCatchEventExecution >> isTriggered [ ^ waiting not ]

{ #category : 'occurrences' }
CPIntermediateCatchEventExecution >> triggerWithAcceptedOccurrence: anOccurrence [
	waiting ifFalse: [ self error: 'This Intermediate Catch Event has already been triggered.' ].
	(self scope acceptedOccurrences identityIncludes: anOccurrence) ifFalse: [
		self error: 'The occurrence must be accepted by the execution scope before it can trigger the Intermediate Catch Event.' ].
	self occurrence: anOccurrence.
	waiting := false.
	self definition outgoing do: [ :eachFlow |
		self recordProducedFlowActivation:
			(self scope activateSequenceFlow: eachFlow producedBy: self) ].
	^ anOccurrence
]

{ #category : 'accessing' }
CPIntermediateCatchEventExecution >> subscription [ ^ subscription ]

{ #category : 'accessing' }
CPIntermediateCatchEventExecution >> subscription: aSubscription [ subscription := aSubscription ]
