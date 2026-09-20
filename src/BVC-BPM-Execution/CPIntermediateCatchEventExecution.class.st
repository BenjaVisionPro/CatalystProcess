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
	(self scope processExecution hasAcceptedOccurrenceAnywhere: anOccurrence) ifFalse: [
		self error: 'The occurrence must be accepted by the Process execution before it can trigger the Intermediate Catch Event.' ].
	self occurrence: anOccurrence.
	self populateCatchEventDataFrom: anOccurrence.
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


{ #category : 'messages' }
CPIntermediateCatchEventExecution >> acceptMessageSubscription: aSubscription occurrence: anOccurrence [
	subscription == aSubscription ifFalse: [ self error: 'The Message subscription does not belong to this Intermediate Catch Event execution.' ].
	^ self scope triggerMessageIntermediateCatchEventExecution: self with: anOccurrence
]


{ #category : 'events - timer' }
CPIntermediateCatchEventExecution >> acceptTimerSubscription: aSubscription occurrence: anOccurrence [
	subscription == aSubscription ifFalse: [ self error: 'The Timer subscription does not belong to this Intermediate Catch Event execution.' ].
	^ self scope triggerTimerIntermediateCatchEventExecution: self with: anOccurrence
]


{ #category : 'signals' }
CPIntermediateCatchEventExecution >> acceptSignalSubscription: aSubscription occurrence: anOccurrence [
	subscription == aSubscription ifFalse: [ self error: 'The Signal subscription does not belong to this Intermediate Catch Event execution.' ].
	^ self scope triggerSignalIntermediateCatchEventExecution: self with: anOccurrence
]

{ #category : 'signals' }
CPIntermediateCatchEventExecution >> acceptSignalSubscription: aSubscription acceptedOccurrence: anOccurrence [
	subscription == aSubscription ifFalse: [ self error: 'The Signal subscription does not belong to this Intermediate Catch Event execution.' ].
	^ self scope triggerSignalIntermediateCatchEventExecution: self withAcceptedOccurrence: anOccurrence
]


{ #category : 'conditional events' }
CPIntermediateCatchEventExecution >> triggerWithoutOccurrence [
	waiting ifFalse: [ self error: 'This Intermediate Catch Event has already been triggered.' ].
	waiting := false.
	self definition outgoing do: [ :eachFlow |
		self recordProducedFlowActivation:
			(self scope activateSequenceFlow: eachFlow producedBy: self) ].
	^ self
]
