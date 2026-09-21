Class {
	#name : 'CPBpmService',
	#superclass : 'CRWorkerService',
	#instVars : [
		'systemRoot'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'configuration' }
CPBpmService class >> configurationClass [
	^ CPBpmServiceConfiguration
]

{ #category : 'configuration' }
CPBpmService class >> appearsInServiceAddMenu [
	^ self == CPBpmService
]

{ #category : 'configuration' }
CPBpmService class >> isSingletonService [
	^ self == CPBpmService
]

{ #category : 'configuration' }
CPBpmService class >> serviceAddMenuDisplayName [
	^ 'BPM'
]

{ #category : 'accessing' }
CPBpmService >> systemRoot [
	^ systemRoot
]

{ #category : 'lifecycle' }
CPBpmService >> installWithConfiguration: aCPBpmServiceConfiguration [
	aCPBpmServiceConfiguration ifNil: [
		self error: 'BPM service configuration must not be nil.' ].
	aCPBpmServiceConfiguration systemRoot ifNil: [
		self error: 'BPM service configuration requires a system root.' ].
	configuration := aCPBpmServiceConfiguration.
	systemRoot := aCPBpmServiceConfiguration systemRoot.
	^ self
]

{ #category : 'execution lookup' }
CPBpmService >> processExecutionForIdentifier: anExecutionIdentifier [
	^ systemRoot processExecutionForIdentifier: anExecutionIdentifier
]

{ #category : 'message delivery' }
CPBpmService >> deliverMessageWorkUnit: aCPDeliverMessageWorkUnit [
	| execution message occurrence |
	execution := self processExecutionForIdentifier: aCPDeliverMessageWorkUnit processExecutionIdentifier.
	execution ifNil: [ self error: 'No Process execution has the requested identifier.' ].
	message := self
		waitingMessageIn: execution
		identifiedBy: aCPDeliverMessageWorkUnit messageIdentifier.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: aCPDeliverMessageWorkUnit occurrenceIdentifier;
		definition: message;
		payload: aCPDeliverMessageWorkUnit payload;
		yourself.
	^ execution deliverMessageOccurrence: occurrence
]

{ #category : 'message delivery' }
CPBpmService >> waitingMessageIn: aProcessExecution identifiedBy: aMessageIdentifier [
	| messages |
	aMessageIdentifier ifNil: [ self error: 'A Message identifier is required.' ].
	messages := (aProcessExecution allWaitingMessageSubscriptions collect: #message)
		select: [ :each | each identifier = aMessageIdentifier ].
	messages := messages asSet asOrderedCollection.
	messages isEmpty ifTrue: [ self error: 'No waiting Message has the requested identifier.' ].
	messages size = 1 ifFalse: [ self error: 'More than one waiting Message has the requested identifier.' ].
	^ messages first
]

{ #category : 'signal delivery' }
CPBpmService >> deliverSignalWorkUnit: aCPDeliverSignalWorkUnit [
	| execution signal occurrence |
	execution := self processExecutionForIdentifier: aCPDeliverSignalWorkUnit processExecutionIdentifier.
	execution ifNil: [ self error: 'No Process execution has the requested identifier.' ].
	signal := self
		waitingSignalIn: execution
		identifiedBy: aCPDeliverSignalWorkUnit signalIdentifier.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: aCPDeliverSignalWorkUnit occurrenceIdentifier;
		definition: signal;
		payload: aCPDeliverSignalWorkUnit payload;
		yourself.
	^ execution deliverSignalOccurrence: occurrence
]

{ #category : 'signal delivery' }
CPBpmService >> waitingSignalIn: aProcessExecution identifiedBy: aSignalIdentifier [
	| signals |
	aSignalIdentifier ifNil: [ self error: 'A Signal identifier is required.' ].
	signals := (aProcessExecution allWaitingDeliverableSignalSubscriptions collect: #signal)
		select: [ :each | each identifier = aSignalIdentifier ].
	signals := signals asSet asOrderedCollection.
	signals isEmpty ifTrue: [ self error: 'No waiting Signal has the requested identifier.' ].
	signals size = 1 ifFalse: [ self error: 'More than one waiting Signal has the requested identifier.' ].
	^ signals first
]
