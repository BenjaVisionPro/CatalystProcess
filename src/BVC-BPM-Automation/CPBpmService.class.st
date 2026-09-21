Class {
	#name : 'CPBpmService',
	#superclass : 'CRWorkerService',
	#instVars : [
		'systemRoot'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}



{ #category : 'capabilities' }
CPBpmService class >> requiredCapabilities [
	^ { CRSchedulingCapability. CRLocalEnqueueCapability }
]

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

{ #category : 'timer delivery' }
CPBpmService >> triggerTimerWorkUnit: aCPTriggerTimerWorkUnit [
	| execution subscription occurrence |
	execution := self processExecutionForIdentifier: aCPTriggerTimerWorkUnit processExecutionIdentifier.
	execution ifNil: [ self error: 'No Process execution has the requested identifier.' ].
	subscription := execution deliverableTimerSubscriptionIdentifiedByOrNil:
		aCPTriggerTimerWorkUnit timerSubscriptionIdentifier.
	subscription ifNil: [ ^ nil ].
	subscription isDispatchPending ifTrue: [
		subscription dispatchOccurrenceIdentifier = aCPTriggerTimerWorkUnit occurrenceIdentifier ifFalse: [
			self error: 'Timer trigger occurrence identifier does not match the pending dispatch.' ] ].
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: aCPTriggerTimerWorkUnit occurrenceIdentifier;
		definition: subscription timerDefinition;
		yourself.
	^ execution
		deliverTimerOccurrence: occurrence
		toSubscriptionIdentifiedBy: subscription identifier
]


{ #category : 'lifecycle' }
CPBpmService >> start [
	| scheduling backgroundSchedule |
	super start.
	scheduling := self capability: CRSchedulingCapability.
	backgroundSchedule := CRRepeatingSchedule
		workUnitFactory: [ CPProcessBackgroundWorkUnit new ]
		key: configuration backgroundScheduleKey
		intervalMillis: configuration backgroundIntervalMillis
		scheduledMillis: scheduling currentMillis.
	scheduling addSchedule: backgroundSchedule.
	^ self
]

{ #category : 'background processing' }
CPBpmService >> processBackgroundWorkUnit: aCPProcessBackgroundWorkUnit [
	| localEnqueue |
	localEnqueue := self capability: CRLocalEnqueueCapability.
	self enqueueDueTimerWorkUnitsUsing: localEnqueue.
	^ self
]

{ #category : 'background processing' }
CPBpmService >> enqueueDueTimerWorkUnitsUsing: anEnqueueCapability [
	systemRoot processExecutions do: [ :execution |
		| currentTime dueSubscriptions |
		currentTime := execution environment currentTimerTime.
		dueSubscriptions := execution allWaitingDeliverableTimerSubscriptions
			select: [ :each | each isDueAt: currentTime ].
		dueSubscriptions do: [ :subscription |
			| occurrenceIdentifier workUnit |
			occurrenceIdentifier := UUID new asString.
			execution
				markTimerSubscriptionDispatchPending: subscription
				occurrenceIdentifier: occurrenceIdentifier.
			workUnit := CPTriggerTimerWorkUnit
				processExecutionIdentifier: execution executionIdentifier
				timerSubscriptionIdentifier: subscription identifier
				occurrenceIdentifier: occurrenceIdentifier.
			anEnqueueCapability enqueue: workUnit ] ].
	^ self
]


{ #category : 'process start' }
CPBpmService >> processDeploymentForIdentifier: aDeploymentIdentifier [
	^ systemRoot processDeploymentForIdentifier: aDeploymentIdentifier
]

{ #category : 'process start' }
CPBpmService >> startProcessWorkUnit: aCPStartProcessWorkUnit [
	| deployment process environment execution |
	deployment := self processDeploymentForIdentifier: aCPStartProcessWorkUnit processDeploymentIdentifier.
	deployment ifNil: [ self error: 'No Process deployment has the requested identifier.' ].
	deployment isActive ifFalse: [ self error: 'A Process can only be started from an active deployment.' ].
	process := deployment processDefinition.
	process ifNil: [ self error: 'The Process deployment has no executable BPMN Process definition.' ].
	environment := configuration executionEnvironment.
	environment ifNil: [ self error: 'BPM service configuration requires an execution environment to start a Process.' ].
	execution := CPProcessExecution for: process environment: environment.
	execution
		deployment: deployment;
		tenant: deployment tenant.
	execution start.
	systemRoot addProcessExecution: execution.
	^ execution
]

{ #category : 'user task completion' }
CPBpmService >> completeUserTaskWorkUnit: aCPCompleteUserTaskWorkUnit [
    | execution workItem |
    execution := self processExecutionForIdentifier: aCPCompleteUserTaskWorkUnit processExecutionIdentifier.
    execution ifNil: [ self error: 'No Process execution has the requested identifier.' ].
    workItem := execution pendingUserTaskWorkItemIdentifiedBy: aCPCompleteUserTaskWorkUnit workItemIdentifier.
    ^ workItem completeThroughExecution
]

{ #category : 'service invocation completion' }
CPBpmService >> completeServiceInvocationWorkUnit: aCPCompleteServiceInvocationWorkUnit [
	| execution invocation occurrence |
	execution := self processExecutionForIdentifier: aCPCompleteServiceInvocationWorkUnit processExecutionIdentifier.
	execution ifNil: [ self error: 'No Process execution has the requested identifier.' ].
	invocation := execution pendingExternalInvocationIdentifiedBy: aCPCompleteServiceInvocationWorkUnit invocationIdentifier.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: aCPCompleteServiceInvocationWorkUnit occurrenceIdentifier;
		definition: invocation;
		payload: aCPCompleteServiceInvocationWorkUnit payload;
		yourself.
	^ invocation completeThroughExecutionWithOccurrence: occurrence
]

{ #category : 'service invocation completion' }
CPBpmService >> faultServiceInvocationWorkUnit: aCPFaultServiceInvocationWorkUnit [
	| execution invocation operation errors error occurrence |
	execution := self processExecutionForIdentifier: aCPFaultServiceInvocationWorkUnit processExecutionIdentifier.
	execution ifNil: [ self error: 'No Process execution has the requested identifier.' ].
	invocation := execution pendingExternalInvocationIdentifiedBy: aCPFaultServiceInvocationWorkUnit invocationIdentifier.
	operation := invocation activityExecution modeledActivityExecution definition operationRef.
	errors := operation errorRefs select: [ :each |
		each identifier = aCPFaultServiceInvocationWorkUnit errorIdentifier ].
	errors isEmpty ifTrue: [ self error: 'The Service invocation Operation declares no Error with the requested identifier.' ].
	errors size = 1 ifFalse: [ self error: 'The Service invocation Operation declares more than one Error with the requested identifier.' ].
	error := errors first.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: aCPFaultServiceInvocationWorkUnit occurrenceIdentifier;
		definition: error;
		payload: aCPFaultServiceInvocationWorkUnit payload;
		yourself.
	^ invocation faultThroughExecutionWithOccurrence: occurrence
]

{ #category : 'process termination' }
CPBpmService >> terminateProcessWorkUnit: aCPTerminateProcessWorkUnit [
	| execution |
	execution := self processExecutionForIdentifier: aCPTerminateProcessWorkUnit processExecutionIdentifier.
	execution ifNil: [ self error: 'No Process execution has the requested identifier.' ].
	^ execution terminate
]

{ #category : 'process query' }
CPBpmService >> processExecutionSnapshotForIdentifier: anExecutionIdentifier [
	| execution |
	execution := self processExecutionForIdentifier: anExecutionIdentifier.
	execution ifNil: [ self error: 'No Process execution has the requested identifier.' ].
	^ CPProcessExecutionSnapshot from: execution
]

{ #category : 'process query' }
CPBpmService >> queryProcessExecutionWorkUnit: aCPQueryProcessExecutionWorkUnit [
	^ self processExecutionSnapshotForIdentifier:
		aCPQueryProcessExecutionWorkUnit processExecutionIdentifier
]
