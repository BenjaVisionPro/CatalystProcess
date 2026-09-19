Class {
	#name : 'CPBoundaryEventExecution',
	#superclass : 'CPEventExecution',
	#instVars : [
		'attachedActivityExecution',
		'waiting',
	'withdrawn'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPBoundaryEventExecution >> initialize [
	super initialize.
	waiting := true.
	withdrawn := false
]

{ #category : 'accessing' }
CPBoundaryEventExecution >> attachedActivityExecution [ ^ attachedActivityExecution ]

{ #category : 'accessing' }
CPBoundaryEventExecution >> attachedActivityExecution: anActivityExecution [
	attachedActivityExecution := anActivityExecution
]

{ #category : 'testing' }
CPBoundaryEventExecution >> isWaiting [ ^ waiting ]

{ #category : 'testing' }
CPBoundaryEventExecution >> isTriggered [ ^ self occurrence notNil ]

{ #category : 'testing' }
CPBoundaryEventExecution >> isWithdrawn [ ^ withdrawn ]

{ #category : 'lifecycle' }
CPBoundaryEventExecution >> withdraw [
	waiting ifFalse: [ self error: 'Only a waiting Boundary Event can be withdrawn.' ].
	waiting := false.
	withdrawn := true.
	^ self
]

{ #category : 'occurrences' }
CPBoundaryEventExecution >> triggerWithAcceptedOccurrence: anOccurrence [
	waiting ifFalse: [ self error: 'This Boundary Event has already been triggered.' ].
	(self scope acceptedOccurrences identityIncludes: anOccurrence) ifFalse: [
		self error: 'The occurrence must be accepted by the execution scope before it can trigger the Boundary Event.' ].
	attachedActivityExecution isActive ifFalse: [
		self error: 'A Boundary Event can trigger only while its attached Activity is Active.' ].
	self occurrence: anOccurrence.
	waiting := false.
	self definition cancelActivity ifTrue: [
		self definition interruptsActivityWithFailure
			ifTrue: [
				attachedActivityExecution beginFailure.
				attachedActivityExecution finishFailure ]
			ifFalse: [
				attachedActivityExecution beginTermination.
				attachedActivityExecution finishTermination ] ].
	self definition outgoing do: [ :eachFlow |
		self recordProducedFlowActivation:
			(self scope activateSequenceFlow: eachFlow producedBy: self) ].
	^ anOccurrence
]

{ #category : 'testing' }
CPBoundaryEventExecution >> isBoundaryEventExecution [ ^ true ]
