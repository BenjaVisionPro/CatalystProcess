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
	execution := aCPDeliverMessageWorkUnit processExecution.
	execution ifNil: [ self error: 'A Process execution is required.' ].
	message := aCPDeliverMessageWorkUnit message.
	message ifNil: [ self error: 'A Message is required.' ].
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: aCPDeliverMessageWorkUnit occurrenceIdentifier;
		definition: message;
		payload: aCPDeliverMessageWorkUnit payload;
		yourself.
	^ execution deliverMessageOccurrence: occurrence
]

{ #category : 'signal delivery' }
CPBpmService >> deliverSignalWorkUnit: aCPDeliverSignalWorkUnit [
	| execution signal occurrence |
	execution := aCPDeliverSignalWorkUnit processExecution.
	execution ifNil: [ self error: 'A Process execution is required.' ].
	signal := aCPDeliverSignalWorkUnit signal.
	signal ifNil: [ self error: 'A Signal is required.' ].
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: aCPDeliverSignalWorkUnit occurrenceIdentifier;
		definition: signal;
		payload: aCPDeliverSignalWorkUnit payload;
		yourself.
	^ execution deliverSignalOccurrence: occurrence
]

{ #category : 'timer delivery' }
CPBpmService >> triggerTimerWorkUnit: aCPTriggerTimerWorkUnit [
	| subscription occurrence |
	subscription := aCPTriggerTimerWorkUnit timerSubscription.
	subscription ifNil: [ self error: 'A Timer subscription is required.' ].
	(subscription isWaiting or: [ subscription isDispatchPending ]) ifFalse: [ ^ nil ].
	subscription isDispatchPending ifTrue: [
		subscription dispatchOccurrenceIdentifier = aCPTriggerTimerWorkUnit occurrenceIdentifier ifFalse: [
			self error: 'Timer trigger occurrence identifier does not match the pending dispatch.' ] ].
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: aCPTriggerTimerWorkUnit occurrenceIdentifier;
		definition: subscription timerDefinition;
		yourself.
	^ subscription deliverOccurrence: occurrence
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
	self enqueueDueProcessInitiationTimerWorkUnitsUsing: localEnqueue.
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
				timerSubscription: subscription
				occurrenceIdentifier: occurrenceIdentifier.
			anEnqueueCapability enqueue: workUnit ] ].
	^ self
]


{ #category : 'background processing' }
CPBpmService >> enqueueDueProcessInitiationTimerWorkUnitsUsing: anEnqueueCapability [
	| environment currentTime |
	environment := configuration executionEnvironment.
	environment ifNil: [ ^ self ].
	currentTime := environment currentTimerTime.
	systemRoot processDeployments do: [ :deployment |
		deployment acceptsNewProcessExecutions ifTrue: [
			(deployment initiationSubscriptions select: [ :each |
				each isTimerSubscription and: [ each isDueAt: currentTime using: environment ] ])
				do: [ :subscription |
					| occurrenceIdentifier occurrence workUnit |
					occurrenceIdentifier := UUID new asString.
					subscription markTimerDispatchPendingWithOccurrenceIdentifier: occurrenceIdentifier.
					occurrence := CPExecutionOccurrence new
						occurrenceIdentifier: occurrenceIdentifier;
						definition: subscription eventDefinition;
						yourself.
					workUnit := CPDeliverProcessInitiationOccurrenceWorkUnit
						initiationSubscription: subscription
						occurrence: occurrence.
					anEnqueueCapability enqueue: workUnit ] ] ].
	^ self
]


{ #category : 'process start' }
CPBpmService >> processDeploymentForIdentifier: aDeploymentIdentifier [
	^ systemRoot processDeploymentForIdentifier: aDeploymentIdentifier
]

{ #category : 'process start' }
CPBpmService >> startProcessWorkUnit: aCPStartProcessWorkUnit [
	| deployment process environment execution |
	deployment := aCPStartProcessWorkUnit processDeployment.
	deployment ifNil: [ self error: 'A Process deployment is required.' ].
	deployment acceptsNewProcessExecutions ifFalse: [ self error: 'The Process deployment does not accept new Process executions.' ].
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
    | workItem |
    workItem := aCPCompleteUserTaskWorkUnit workItem.
    workItem ifNil: [ self error: 'A User Task work item is required.' ].
    ^ workItem completeThroughExecution
]

{ #category : 'service invocation completion' }
CPBpmService >> completeServiceInvocationWorkUnit: aCPCompleteServiceInvocationWorkUnit [
	| invocation occurrence |
	invocation := aCPCompleteServiceInvocationWorkUnit invocation.
	invocation ifNil: [ self error: 'A Service invocation is required.' ].
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: aCPCompleteServiceInvocationWorkUnit occurrenceIdentifier;
		definition: invocation;
		payload: aCPCompleteServiceInvocationWorkUnit payload;
		yourself.
	^ invocation completeThroughExecutionWithOccurrence: occurrence
]

{ #category : 'service invocation completion' }
CPBpmService >> faultServiceInvocationWorkUnit: aCPFaultServiceInvocationWorkUnit [
	| invocation operation error occurrence |
	invocation := aCPFaultServiceInvocationWorkUnit invocation.
	invocation ifNil: [ self error: 'A Service invocation is required.' ].
	error := aCPFaultServiceInvocationWorkUnit error.
	error ifNil: [ self error: 'A BPMN Error is required.' ].
	operation := invocation activityExecution modeledActivityExecution definition operationRef.
	(operation errorRefs includes: error) ifFalse: [
		self error: 'The Service invocation Operation does not declare the supplied Error.' ].
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
	execution := aCPTerminateProcessWorkUnit processExecution.
	execution ifNil: [ self error: 'A Process execution is required.' ].
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
	| execution |
	execution := aCPQueryProcessExecutionWorkUnit processExecution.
	execution ifNil: [ self error: 'A Process execution is required.' ].
	^ execution
]

{ #category : 'process query' }
CPBpmService >> processExecutions [
	^ systemRoot processExecutions asArray
]

{ #category : 'process query' }
CPBpmService >> queryProcessExecutionsWorkUnit: aCPQueryProcessExecutionsWorkUnit [
	^ self processExecutions
]

{ #category : 'deployment query' }
CPBpmService >> processDeployments [
	^ systemRoot processDeployments asArray
]

{ #category : 'deployment query' }
CPBpmService >> queryProcessDeploymentsWorkUnit: aCPQueryProcessDeploymentsWorkUnit [
	^ self processDeployments
]

{ #category : 'deployment lifecycle' }
CPBpmService >> activateProcessDeploymentWorkUnit: aCPActivateProcessDeploymentWorkUnit [
	| deployment |
	deployment := aCPActivateProcessDeploymentWorkUnit processDeployment.
	deployment ifNil: [ self error: 'A Process deployment is required.' ].
	deployment activate.
	self armInitiatingEventBasedGatewaysFor: deployment.
	^ deployment
]

{ #category : 'deployment lifecycle' }
CPBpmService >> retireProcessDeploymentWorkUnit: aCPRetireProcessDeploymentWorkUnit [
	| deployment |
	deployment := aCPRetireProcessDeploymentWorkUnit processDeployment.
	deployment ifNil: [ self error: 'A Process deployment is required.' ].
	deployment retire.
	deployment clearInitiationSubscriptions.
	^ deployment
]

{ #category : 'conditional events' }
CPBpmService >> reevaluateConditionalWorkUnit: aCPReevaluateConditionalWorkUnit [
	| subscription scope |
	subscription := aCPReevaluateConditionalWorkUnit conditionalSubscription.
	subscription ifNil: [ self error: 'A Conditional subscription is required.' ].
	subscription isWaiting ifFalse: [ ^ false ].
	scope := subscription executionScope.
	scope ifNil: [ self error: 'The Conditional subscription has no execution scope.' ].
	^ subscription reevaluateInScope: scope
]

{ #category : 'process start' }
CPBpmService >> instantiateEventBasedGatewayWorkUnit: aWorkUnit [
	| deployment process gateway execution environment |
	deployment := aWorkUnit processDeployment.
	deployment ifNil: [ self error: 'A Process deployment is required.' ].
	deployment acceptsNewProcessExecutions ifFalse: [ self error: 'The Process deployment does not accept new Process executions.' ].
	process := deployment processDefinition.
	process ifNil: [ self error: 'The Process deployment has no executable BPMN Process definition.' ].
	gateway := aWorkUnit gateway.
	gateway ifNil: [ self error: 'An instantiating Event-Based Gateway is required.' ].
	(process flowElements includes: gateway) ifFalse: [ self error: 'The Event-Based Gateway does not belong to the deployed Process definition.' ].
	environment := configuration executionEnvironment.
	environment ifNil: [ self error: 'BPM service configuration requires an execution environment to start a Process.' ].
	execution := CPProcessExecution for: process environment: environment.
	execution deployment: deployment; tenant: deployment tenant.
	execution startAtInstantiatingEventBasedGateway: gateway via: aWorkUnit sequenceFlow occurrence: aWorkUnit occurrence.
	systemRoot addProcessExecution: execution.
	^ execution
]


{ #category : 'process initiation' }
CPBpmService >> armInitiatingEventBasedGatewaysFor: aDeployment [
	| process subscriptions |
	process := aDeployment processDefinition.
	subscriptions := OrderedCollection new.
	process ifNil: [
		aDeployment replaceInitiationSubscriptionsWith: subscriptions.
		^ subscriptions ].
	process flowElements do: [ :element |
		(element isEventBasedGateway and: [ element instantiate ]) ifTrue: [
			element outgoing do: [ :flow |
				| target definition subscription |
				target := flow targetRef.
				target isReceiveTask
					ifTrue: [
						target messageRef ifNil: [ self error: 'An instantiating Event-Based Gateway Receive Task requires a Message.' ].
						definition := CPMessageEventDefinition new messageRef: target messageRef; yourself ]
					ifFalse: [
						target isIntermediateEvent ifFalse: [ self error: 'An instantiating Event-Based Gateway must target a Receive Task or Intermediate Catch Event.' ].
						target eventDefinitions size = 1 ifFalse: [ self error: 'An instantiating Event-Based Gateway catch Event requires exactly one Event Definition.' ].
						definition := target eventDefinitions first ].
				(definition isMessageEventDefinition or: [ definition isSignalEventDefinition or: [ definition isTimerEventDefinition ] ]) ifFalse: [
					self error: 'This Event Definition cannot initiate through an instantiating Event-Based Gateway.' ].
				subscription := CPEventBasedGatewayInitiationSubscription new
					processDeployment: aDeployment; gateway: element; sequenceFlow: flow; eventDefinition: definition; yourself.
				subscriptions add: subscription ] ] ].
	(subscriptions anySatisfy: [ :each | each isTimerSubscription ]) ifTrue: [
		| environment armingTime |
		environment := configuration executionEnvironment.
		environment ifNil: [ self error: 'BPM service configuration requires an execution environment to arm deployment Timer initiation.' ].
		armingTime := environment currentTimerTime.
		subscriptions do: [ :each | each isTimerSubscription ifTrue: [ each armTimerAt: armingTime ] ] ].
	aDeployment replaceInitiationSubscriptionsWith: subscriptions.
	^ subscriptions
]

{ #category : 'process initiation' }
CPBpmService >> initiationSubscriptionsForMessage: aMessage [
	^ systemRoot processDeployments flatCollect: [ :deployment |
		deployment initiationSubscriptions select: [ :each |
			deployment acceptsNewProcessExecutions and: [ each isMessageSubscription and: [ each message == aMessage ] ] ] ]
]

{ #category : 'process initiation' }
CPBpmService >> initiationSubscriptionsForSignal: aSignal [
	^ systemRoot processDeployments flatCollect: [ :deployment |
		deployment initiationSubscriptions select: [ :each |
			deployment acceptsNewProcessExecutions and: [ each isSignalSubscription and: [ each signal == aSignal ] ] ] ]
]

{ #category : 'process initiation' }
CPBpmService >> deliverProcessInitiationOccurrenceWorkUnit: aWorkUnit [
	| subscription occurrence instantiateWorkUnit execution |
	subscription := aWorkUnit initiationSubscription.
	subscription ifNil: [ self error: 'A Process initiation subscription is required.' ].
	occurrence := aWorkUnit occurrence.
	occurrence ifNil: [ self error: 'A Process initiation occurrence is required.' ].
	(subscription matchesOccurrence: occurrence) ifFalse: [ self error: 'The occurrence does not match an active Process initiation subscription.' ].
	instantiateWorkUnit := CPInstantiateEventBasedGatewayWorkUnit
		processDeployment: subscription processDeployment
		gateway: subscription gateway
		sequenceFlow: subscription sequenceFlow
		occurrence: occurrence.
	execution := self instantiateEventBasedGatewayWorkUnit: instantiateWorkUnit.
	subscription isTimerSubscription ifTrue: [
		subscription acceptTimerOccurrenceAt: configuration executionEnvironment currentTimerTime ].
	^ execution
]
