Class {
	#name : 'CPExecutionScope',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'parentScope',
		'owningActivity',
		'childScopes',
		'activityExecutions',
		'gatewayExecutions',
		'eventExecutions',
		'flowActivations',
		'acceptedOccurrences',
		'timerSubscriptions',
		'messageSubscriptions'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'instance creation' }
CPExecutionScope class >> for: aScopeDefinition ownedBy: anActivityExecution [
	^ anActivityExecution attachSubScope: (self new
		definition: aScopeDefinition;
		yourself)
]

{ #category : 'initialization' }
CPExecutionScope >> initialize [
	super initialize.
	childScopes := OrderedCollection new.
	activityExecutions := OrderedCollection new.
	gatewayExecutions := OrderedCollection new.
	eventExecutions := OrderedCollection new.
	flowActivations := OrderedCollection new.
	acceptedOccurrences := OrderedCollection new.
	timerSubscriptions := OrderedCollection new.
	messageSubscriptions := OrderedCollection new
]

{ #category : 'accessing' }
CPExecutionScope >> definition [ ^ definition ]
{ #category : 'accessing' }
CPExecutionScope >> definition: anObject [ definition := anObject ]
{ #category : 'accessing' }
CPExecutionScope >> parentScope [ ^ parentScope ]
{ #category : 'accessing' }
CPExecutionScope >> parentScope: anExecutionScope [ parentScope := anExecutionScope ]

{ #category : 'accessing' }
CPExecutionScope >> environment [
	parentScope ifNil: [ self error: 'An execution scope requires a parent Process execution to resolve its environment.' ].
	^ parentScope environment
]
{ #category : 'accessing' }
CPExecutionScope >> owningActivity [ ^ owningActivity ]
{ #category : 'accessing' }
CPExecutionScope >> owningActivity: anActivityExecution [ owningActivity := anActivityExecution ]
{ #category : 'accessing' }
CPExecutionScope >> childScopes [ ^ childScopes ]
{ #category : 'accessing' }
CPExecutionScope >> activityExecutions [ ^ activityExecutions ]
{ #category : 'accessing' }
CPExecutionScope >> gatewayExecutions [ ^ gatewayExecutions ]
{ #category : 'accessing' }
CPExecutionScope >> eventExecutions [ ^ eventExecutions ]
{ #category : 'accessing' }
CPExecutionScope >> acceptedOccurrences [ ^ acceptedOccurrences ]

{ #category : 'gateways - event based' }
CPExecutionScope >> waitingEventBasedGatewaySubscriptions [
	| subscriptions |
	subscriptions := OrderedCollection new.
	gatewayExecutions do: [ :eachExecution |
		subscriptions addAll: (eachExecution subscriptions select: #isWaiting) ].
	^ subscriptions
]

{ #category : 'gateways - event based' }
CPExecutionScope >> allWaitingEventBasedGatewaySubscriptions [
	| subscriptions |
	subscriptions := self waitingEventBasedGatewaySubscriptions asOrderedCollection.
	childScopes do: [ :eachScope |
		subscriptions addAll: eachScope allWaitingEventBasedGatewaySubscriptions ].
	^ subscriptions
]

{ #category : 'accessing' }
CPExecutionScope >> timerSubscriptions [ ^ timerSubscriptions ]

{ #category : 'events - timer' }
CPExecutionScope >> waitingTimerSubscriptions [
	^ timerSubscriptions select: #isWaiting
]

{ #category : 'events - timer' }
CPExecutionScope >> allWaitingTimerSubscriptions [
	| subscriptions |
	subscriptions := self waitingTimerSubscriptions asOrderedCollection.
	childScopes do: [ :eachScope |
		subscriptions addAll: eachScope allWaitingTimerSubscriptions ].
	^ subscriptions
]

{ #category : 'events - timer' }
CPExecutionScope >> allWaitingTimerSubscriptionsFor: aTimerDefinition [
	^ self allWaitingTimerSubscriptions select: [ :each | each timerDefinition == aTimerDefinition ]
]

{ #category : 'accessing' }
CPExecutionScope >> messageSubscriptions [ ^ messageSubscriptions ]

{ #category : 'messages' }
CPExecutionScope >> waitingMessageSubscriptions [
	^ messageSubscriptions select: #isWaiting
]

{ #category : 'messages' }
CPExecutionScope >> allWaitingMessageSubscriptions [
	| subscriptions |
	subscriptions := self waitingMessageSubscriptions asOrderedCollection.
	childScopes do: [ :eachScope |
		subscriptions addAll: eachScope allWaitingMessageSubscriptions ].
	^ subscriptions
]

{ #category : 'messages' }
CPExecutionScope >> allWaitingMessageSubscriptionsFor: aMessage [
	^ self allWaitingMessageSubscriptions select: [ :each | each message == aMessage ]
]


{ #category : 'messages' }
CPExecutionScope >> deliverMessageOccurrence: anOccurrence [
	| matches |
	matches := self allWaitingMessageSubscriptionsFor: anOccurrence definition.
	matches isEmpty ifTrue: [
		self error: 'No waiting Message subscription matches this occurrence.' ].
	matches size = 1 ifFalse: [
		self error: 'More than one waiting Message subscription matches this occurrence; correlation is required.' ].
	^ matches first deliverOccurrence: anOccurrence
]


{ #category : 'accessing' }
CPExecutionScope >> flowActivations [ ^ flowActivations ]

{ #category : 'control flow' }
CPExecutionScope >> activateSequenceFlow: aSequenceFlow producedBy: aFlowNodeExecution [
	| activation |
	aFlowNodeExecution ifNotNil: [
		aFlowNodeExecution scope == self ifFalse: [ self error: 'Sequence Flow activation must be produced within this execution scope.' ] ].
	activation := CPSequenceFlowActivation new
		definition: aSequenceFlow;
		scope: self;
		producedBy: aFlowNodeExecution;
		yourself.
	flowActivations add: activation.
	^ activation
]

{ #category : 'control flow' }
CPExecutionScope >> availableFlowActivationsOn: aSequenceFlow [
	^ flowActivations select: [ :each |
		each definition == aSequenceFlow and: [ each isAvailable ] ]
]

{ #category : 'control flow' }
CPExecutionScope >> availableIncomingFlowActivationsFor: anActivity [
	| available |
	available := OrderedCollection new.
	anActivity incoming do: [ :eachFlow |
		available addAll: (self availableFlowActivationsOn: eachFlow) ].
	^ available
]

{ #category : 'control flow' }
CPExecutionScope >> canReadyActivity: anActivity [
	^ (self availableIncomingFlowActivationsFor: anActivity) size >= anActivity startQuantity
]

{ #category : 'control flow' }
CPExecutionScope >> readyActivityExecutionFor: anActivity [
	| available execution |
	available := self availableIncomingFlowActivationsFor: anActivity.
	available size < anActivity startQuantity ifTrue: [
		self error: 'The Activity does not have enough incoming control-flow activations to become Ready.' ].
	execution := self createActivityExecutionFor: anActivity.
	1 to: anActivity startQuantity do: [ :index |
		execution consumeFlowActivation: (available at: index) ].
	^ execution
]

{ #category : 'control flow' }
CPExecutionScope >> produceOutgoingControlFor: anActivityExecution [
	anActivityExecution scope == self ifFalse: [ self error: 'The Activity execution does not belong to this execution scope.' ].
	anActivityExecution isCompleted ifFalse: [ self error: 'Only a Completed Activity can produce outgoing control flow.' ].
	self withdrawBoundaryEventsAttachedTo: anActivityExecution.
	anActivityExecution definition outgoing do: [ :eachFlow |
		1 to: anActivityExecution definition completionQuantity do: [ :index |
			self activateSequenceFlow: eachFlow producedBy: anActivityExecution ] ].
	^ anActivityExecution
]

{ #category : 'building' }
CPExecutionScope >> createActivityExecutionFor: anActivity [
	^ CPActivityExecution for: anActivity in: self
]

{ #category : 'building' }
CPExecutionScope >> addActivityExecution: anActivityExecution [
	anActivityExecution scope ifNotNil: [ self error: 'The Activity execution already belongs to an execution scope.' ].
	anActivityExecution scope: self.
	activityExecutions add: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'building' }
CPExecutionScope >> addChildScope: aScope [
	aScope parentScope ifNotNil: [ self error: 'The execution scope already has a parent scope.' ].
	aScope owningActivity ifNil: [ self error: 'A child execution scope must be owned by an Activity execution.' ].
	aScope owningActivity scope == self ifFalse: [ self error: 'A child execution scope must be owned by an Activity execution in its parent scope.' ].
	aScope parentScope: self.
	childScopes add: aScope.
	^ aScope
]

{ #category : 'occurrences' }
CPExecutionScope >> hasAcceptedOccurrenceIdentifiedBy: anIdentifier [
	^ acceptedOccurrences anySatisfy: [ :each | each occurrenceIdentifier = anIdentifier ]
]

{ #category : 'occurrences' }
CPExecutionScope >> acceptOccurrence: anOccurrence [
	anOccurrence occurrenceIdentifier ifNil: [ self error: 'An occurrence requires an occurrence identifier.' ].
	(self hasAcceptedOccurrenceIdentifiedBy: anOccurrence occurrenceIdentifier)
		ifTrue: [ self error: 'This occurrence has already been accepted in the scope.' ].
	acceptedOccurrences add: anOccurrence.
	^ anOccurrence
]


{ #category : 'building' }
CPExecutionScope >> createGatewayExecutionFor: aGateway [
	| execution |
	execution := CPGatewayExecution new
		definition: aGateway;
		scope: self;
		yourself.
	gatewayExecutions add: execution.
	^ execution
]

{ #category : 'gateways - parallel' }
CPExecutionScope >> canExecuteParallelGateway: aGateway [
	^ aGateway incoming allSatisfy: [ :eachFlow |
		(self availableFlowActivationsOn: eachFlow) notEmpty ]
]

{ #category : 'gateways - parallel' }
CPExecutionScope >> executeParallelGateway: aGateway [
	| execution |
	(self canExecuteParallelGateway: aGateway) ifFalse: [
		self error: 'A Parallel Gateway requires one available control-flow activation on every incoming Sequence Flow.' ].
	execution := self createGatewayExecutionFor: aGateway.
	aGateway incoming do: [ :eachFlow |
		execution consumeFlowActivation: (self availableFlowActivationsOn: eachFlow) first ].
	aGateway outgoing do: [ :eachFlow |
		execution recordProducedFlowActivation:
			(self activateSequenceFlow: eachFlow producedBy: execution) ].
	^ execution
]

{ #category : 'gateways - exclusive' }
CPExecutionScope >> executeExclusiveGateway: aGateway consuming: anActivation [
	| execution selectedFlow |
	(anActivation isAvailable and: [ aGateway incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'An Exclusive Gateway requires an available activation from one of its incoming Sequence Flows.' ].
	selectedFlow := self
		selectedOutgoingFlowForExclusiveGateway: aGateway.
	execution := self createGatewayExecutionFor: aGateway.
	execution consumeFlowActivation: anActivation.
	execution recordProducedFlowActivation:
		(self activateSequenceFlow: selectedFlow producedBy: execution).
	^ execution
]

{ #category : 'gateways - exclusive' }
CPExecutionScope >> selectedOutgoingFlowForExclusiveGateway: aGateway [
	aGateway outgoing do: [ :eachFlow |
		(aGateway isDefaultFlow: eachFlow) ifFalse: [
			eachFlow conditionExpression ifNotNil: [ :anExpression |
				(self environment evaluateExpression: anExpression in: self) ifTrue: [ ^ eachFlow ] ] ] ].
	aGateway default ifNotNil: [ ^ aGateway default ].
	self error: 'No Exclusive Gateway condition evaluated to true and no default Sequence Flow is defined.'
]


{ #category : 'gateways - event based' }
CPExecutionScope >> beginExclusiveEventBasedGateway: aGateway consuming: anActivation [
	| execution |
	aGateway instantiate ifTrue: [ self error: 'An instantiating Event-Based Gateway belongs to Process instantiation, not an existing execution scope.' ].
	aGateway eventGatewayType = 'Exclusive' ifFalse: [ self error: 'A non-instantiating Event-Based Gateway must be Exclusive.' ].
	(anActivation isAvailable and: [ aGateway incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'An Event-Based Gateway requires an available activation from one of its incoming Sequence Flows.' ].
	execution := CPEventBasedGatewayExecution new
		definition: aGateway;
		scope: self;
		yourself.
	gatewayExecutions add: execution.
	execution consumeFlowActivation: anActivation.
	aGateway outgoing do: [ :eachFlow | execution subscribeToOutgoingFlow: eachFlow ].
	^ execution
]


{ #category : 'building' }
CPExecutionScope >> createEventExecutionFor: anEvent [
	| execution |
	execution := CPEventExecution new
		definition: anEvent;
		scope: self;
		yourself.
	eventExecutions add: execution.
	^ execution
]

{ #category : 'events - start' }
CPExecutionScope >> executeStartEvent: aStartEvent occurrence: anOccurrence [
	| execution |
	aStartEvent incoming isEmpty ifFalse: [ self error: 'A Start Event cannot consume incoming Sequence Flow.' ].
	anOccurrence ifNotNil: [
		(self acceptedOccurrences identityIncludes: anOccurrence) ifFalse: [ self acceptOccurrence: anOccurrence ] ].
	execution := self createEventExecutionFor: aStartEvent.
	execution occurrence: anOccurrence.
	aStartEvent outgoing do: [ :eachFlow |
		execution recordProducedFlowActivation:
			(self activateSequenceFlow: eachFlow producedBy: execution) ].
	^ execution
]

{ #category : 'events - end' }
CPExecutionScope >> executeEndEvent: anEndEvent consuming: anActivation [
	| execution |
	anEndEvent outgoing isEmpty ifFalse: [ self error: 'An End Event cannot produce outgoing Sequence Flow.' ].
	(anActivation isAvailable and: [ anEndEvent incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'An End Event requires an available activation from one of its incoming Sequence Flows.' ].
	execution := self createEventExecutionFor: anEndEvent.
	execution consumeFlowActivation: anActivation.
	^ execution
]

{ #category : 'gateways - inclusive' }
CPExecutionScope >> canExecuteInclusiveGateway: aGateway [
	| availableIncoming |
	availableIncoming := aGateway incoming select: [ :eachFlow |
		(self availableFlowActivationsOn: eachFlow) notEmpty ].
	availableIncoming isEmpty ifTrue: [ ^ false ].
	^ aGateway incoming allSatisfy: [ :eachFlow |
		(availableIncoming identityIncludes: eachFlow) or: [
			(self controlCanStillReachInclusiveGateway: aGateway through: eachFlow) not ] ]
]

{ #category : 'gateways - inclusive' }
CPExecutionScope >> controlCanStillReachInclusiveGateway: aGateway through: anIncomingFlow [
	| targetSource |
	targetSource := anIncomingFlow sourceRef.
	flowActivations do: [ :activation |
		activation isAvailable ifTrue: [
			(self
				flowNode: activation definition targetRef
				canReach: targetSource
				withoutPassing: aGateway)
				ifTrue: [ ^ true ] ] ].
	activityExecutions do: [ :activityExecution |
		activityExecution isFinal ifFalse: [
			(self
				flowNode: activityExecution definition
				canReach: targetSource
				withoutPassing: aGateway)
				ifTrue: [ ^ true ] ] ].
	^ false
]

{ #category : 'gateways - inclusive' }
CPExecutionScope >> flowNode: aFlowNode canReach: aTargetNode withoutPassing: aGateway [
	^ self
		flowNode: aFlowNode
		canReach: aTargetNode
		withoutPassing: aGateway
		visited: IdentitySet new
]

{ #category : 'gateways - inclusive' }
CPExecutionScope >> flowNode: aFlowNode canReach: aTargetNode withoutPassing: aGateway visited: visited [
	aFlowNode == aTargetNode ifTrue: [ ^ true ].
	aFlowNode == aGateway ifTrue: [ ^ false ].
	(visited includes: aFlowNode) ifTrue: [ ^ false ].
	visited add: aFlowNode.
	aFlowNode outgoing do: [ :eachFlow |
		(self
			flowNode: eachFlow targetRef
			canReach: aTargetNode
			withoutPassing: aGateway
			visited: visited)
			ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'gateways - inclusive' }
CPExecutionScope >> executeInclusiveGateway: aGateway [
	| execution selectedFlows |
	(self canExecuteInclusiveGateway: aGateway) ifFalse: [
		self error: 'The Inclusive Gateway cannot execute while an unrepresented incoming branch can still reach it.' ].
	selectedFlows := self
		selectedOutgoingFlowsForInclusiveGateway: aGateway.
	execution := self createGatewayExecutionFor: aGateway.
	aGateway incoming do: [ :eachFlow |
		| available |
		available := self availableFlowActivationsOn: eachFlow.
		available ifNotEmpty: [ execution consumeFlowActivation: available first ] ].
	selectedFlows do: [ :eachFlow |
		execution recordProducedFlowActivation:
			(self activateSequenceFlow: eachFlow producedBy: execution) ].
	^ execution
]

{ #category : 'gateways - inclusive' }
CPExecutionScope >> selectedOutgoingFlowsForInclusiveGateway: aGateway [
	| selected |
	selected := OrderedCollection new.
	aGateway outgoing do: [ :eachFlow |
		(aGateway isDefaultFlow: eachFlow) ifFalse: [
			eachFlow conditionExpression ifNotNil: [ :expression |
				(self environment evaluateExpression: expression in: self) ifTrue: [ selected add: eachFlow ] ] ] ].
	selected ifNotEmpty: [ ^ selected ].
	aGateway default ifNotNil: [ :defaultFlow | ^ OrderedCollection with: defaultFlow ].
	self error: 'No Inclusive Gateway condition evaluated to true and no default Sequence Flow is defined.'
]

{ #category : 'events - intermediate catch' }
CPExecutionScope >> beginIntermediateCatchEvent: anEvent consuming: anActivation [
	| execution |
	(anActivation isAvailable and: [ anEvent incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'An Intermediate Catch Event requires an available activation from one of its incoming Sequence Flows.' ].
	execution := CPIntermediateCatchEventExecution new
		definition: anEvent;
		scope: self;
		yourself.
	eventExecutions add: execution.
	execution consumeFlowActivation: anActivation.
	^ execution
]

{ #category : 'events - intermediate catch' }
CPExecutionScope >> triggerIntermediateCatchEventExecution: anEventExecution with: anOccurrence [
	(eventExecutions identityIncludes: anEventExecution) ifFalse: [
		self error: 'The Intermediate Catch Event execution does not belong to this execution scope.' ].
	anEventExecution isWaiting ifFalse: [
		self error: 'Only a waiting Intermediate Catch Event can accept an occurrence.' ].
	self acceptOccurrence: anOccurrence.
	anEventExecution triggerWithAcceptedOccurrence: anOccurrence.
	^ anEventExecution
]

{ #category : 'events - event based' }
CPExecutionScope >> triggerEventBasedGatewayExecution: aGatewayExecution subscription: aSubscription with: anOccurrence [
	| eventExecution |
	(gatewayExecutions identityIncludes: aGatewayExecution) ifFalse: [
		self error: 'The Event-Based Gateway execution does not belong to this execution scope.' ].
	aGatewayExecution acceptOccurrence: anOccurrence for: aSubscription.
	eventExecution := CPIntermediateCatchEventExecution new
		definition: aSubscription target;
		scope: self;
		yourself.
	eventExecutions add: eventExecution.
	eventExecution triggerWithAcceptedOccurrence: anOccurrence.
	^ eventExecution
]

{ #category : 'events - intermediate throw' }
CPExecutionScope >> beginIntermediateThrowEvent: anEvent consuming: anActivation [
	| execution |
	(anActivation isAvailable and: [ anEvent incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'An Intermediate Throw Event requires an available activation from one of its incoming Sequence Flows.' ].
	execution := CPIntermediateThrowEventExecution new
		definition: anEvent;
		scope: self;
		yourself.
	eventExecutions add: execution.
	execution consumeFlowActivation: anActivation.
	^ execution
]

{ #category : 'events - intermediate throw' }
CPExecutionScope >> completeIntermediateThrowEventExecution: anEventExecution [
	(eventExecutions identityIncludes: anEventExecution) ifFalse: [
		self error: 'The Intermediate Throw Event execution does not belong to this execution scope.' ].
	anEventExecution isPending ifFalse: [
		self error: 'Only a pending Intermediate Throw Event execution can complete.' ].
	anEventExecution complete.
	anEventExecution definition outgoing do: [ :eachFlow |
		anEventExecution recordProducedFlowActivation:
			(self activateSequenceFlow: eachFlow producedBy: anEventExecution) ].
	^ anEventExecution
]

{ #category : 'events - boundary' }
CPExecutionScope >> withdrawBoundaryEventsAttachedTo: anActivityExecution [
	eventExecutions do: [ :eachExecution |
		(eachExecution isBoundaryEventExecution
			and: [ eachExecution attachedActivityExecution == anActivityExecution
			and: [ eachExecution isWaiting ] ]) ifTrue: [ eachExecution withdraw ] ].
	^ anActivityExecution
]

{ #category : 'events - boundary' }
CPExecutionScope >> beginBoundaryEvent: aBoundaryEvent attachedTo: anActivityExecution [
	| execution |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The attached Activity execution does not belong to this execution scope.' ].
	aBoundaryEvent attachedToRef == anActivityExecution definition ifFalse: [
		self error: 'The Boundary Event is not attached to this Activity definition.' ].
	anActivityExecution isActive ifFalse: [
		self error: 'A Boundary Event can wait only while its attached Activity is Active.' ].
	execution := CPBoundaryEventExecution new
		definition: aBoundaryEvent;
		scope: self;
		attachedActivityExecution: anActivityExecution;
		yourself.
	eventExecutions add: execution.
	^ execution
]

{ #category : 'events - boundary' }
CPExecutionScope >> triggerBoundaryEventExecution: aBoundaryEventExecution with: anOccurrence [
	(eventExecutions identityIncludes: aBoundaryEventExecution) ifFalse: [
		self error: 'The Boundary Event execution does not belong to this execution scope.' ].
	aBoundaryEventExecution isWaiting ifFalse: [
		self error: 'Only a waiting Boundary Event can accept an occurrence.' ].
	self acceptOccurrence: anOccurrence.
	aBoundaryEventExecution triggerWithAcceptedOccurrence: anOccurrence.
	aBoundaryEventExecution definition cancelActivity ifTrue: [
		self withdrawBoundaryEventsAttachedTo: aBoundaryEventExecution attachedActivityExecution ].
	^ aBoundaryEventExecution
]

{ #category : 'activities - sub-process' }
CPExecutionScope >> activateSubProcessExecution: anActivityExecution [
	| subProcess startEvents subScope |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Sub-Process Activity execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Sub-Process Activity can be activated.' ].
	subProcess := anActivityExecution definition.
	startEvents := subProcess flowElements select: [ :each | each isStartEvent ].
	startEvents size > 1 ifTrue: [
		self error: 'A control-flow Sub-Process can have at most one Start Event.' ].
	startEvents ifNotEmpty: [
		startEvents first eventDefinitions ifNotEmpty: [
			self error: 'A control-flow Sub-Process Start Event must be empty.' ] ].
	anActivityExecution activate.
	subScope := anActivityExecution createSubScopeFor: subProcess.
	startEvents
		ifNotEmpty: [ subScope executeStartEvent: startEvents first occurrence: nil ]
		ifEmpty: [ subScope activateImplicitSubProcessStart ].
	^ anActivityExecution
]

{ #category : 'activities - sub-process' }
CPExecutionScope >> activateImplicitSubProcessStart [
	definition flowElements do: [ :each |
		(each incoming isEmpty and: [ each isActivity ]) ifTrue: [
			| activation |
			activation := CPSequenceFlowActivation new
				definition: nil;
				scope: self;
				producedBy: nil;
				yourself.
			flowActivations add: activation ] ].
	^ self
]

{ #category : 'activities - sub-process' }
CPExecutionScope >> canCompleteSubProcessActivity: anActivityExecution [
	| subScope |
	anActivityExecution isActive ifFalse: [ ^ false ].
	subScope := anActivityExecution subScope.
	subScope ifNil: [ ^ false ].
	(subScope flowActivations anySatisfy: [ :each | each isAvailable ]) ifTrue: [ ^ false ].
	(subScope activityExecutions anySatisfy: [ :each | each isFinal not ]) ifTrue: [ ^ false ].
	subScope allWaitingMessageSubscriptions ifNotEmpty: [ ^ false ].
	subScope allWaitingTimerSubscriptions ifNotEmpty: [ ^ false ].
	subScope allWaitingEventBasedGatewaySubscriptions ifNotEmpty: [ ^ false ].
	^ true
]

{ #category : 'activities - sub-process' }
CPExecutionScope >> completeSubProcessActivity: anActivityExecution [
	(self canCompleteSubProcessActivity: anActivityExecution) ifFalse: [
		self error: 'The Sub-Process cannot complete while nested control flow or Activities remain active.' ].
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'activities - call' }
CPExecutionScope >> activateCallActivityExecution: anActivityExecution [
	| callActivity calledProcess startEvents calledScope |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Call Activity execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Call Activity can be activated.' ].
	callActivity := anActivityExecution definition.
	callActivity calledElement ifNil: [ self error: 'A Call Activity requires a called element.' ].
	calledProcess := self environment
		resolveCallableElement: callActivity calledElement
		in: self.
	startEvents := calledProcess flowElements select: [ :each | each isStartEvent ].
	startEvents := startEvents select: [ :each | each eventDefinitions isEmpty ].
	startEvents size > 1 ifTrue: [
		self error: 'A called Process can have at most one empty Start Event for control-flow invocation.' ].
	anActivityExecution activate.
	calledScope := anActivityExecution createSubScopeFor: calledProcess.
	startEvents
		ifNotEmpty: [ calledScope executeStartEvent: startEvents first occurrence: nil ]
		ifEmpty: [ calledScope activateImplicitSubProcessStart ].
	^ anActivityExecution
]

{ #category : 'activities - call' }
CPExecutionScope >> canCompleteCallActivity: anActivityExecution [
	^ self canCompleteSubProcessActivity: anActivityExecution
]

{ #category : 'activities - call' }
CPExecutionScope >> completeCallActivity: anActivityExecution [
	(self canCompleteCallActivity: anActivityExecution) ifFalse: [
		self error: 'The Call Activity cannot complete while called Process control flow or Activities remain active.' ].
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'building' }
CPExecutionScope >> createServiceTaskExecutionFor: aServiceTask [
	^ self addActivityExecution: (CPServiceTaskExecution new
		definition: aServiceTask;
		yourself)
]

{ #category : 'activities - service' }
CPExecutionScope >> activateServiceTaskExecution: anActivityExecution [
	| serviceTask operation implementation |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Service Task execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Service Task execution can become Active.' ].
	serviceTask := anActivityExecution definition.
	operation := serviceTask operationRef.
	operation ifNil: [ self error: 'A Service Task requires an Operation.' ].
	implementation := self environment resolveOperation: operation in: self.
	anActivityExecution resolvedImplementation: implementation.
	anActivityExecution activate.
	^ anActivityExecution
]


{ #category : 'activities - service' }
CPExecutionScope >> completeServiceTaskExecution: anActivityExecution withResultOccurrence: anOccurrence [
	| invocation |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Service Task execution does not belong to this execution scope.' ].
	anActivityExecution isActive ifFalse: [
		self error: 'Only an Active Service Task execution can accept an external result.' ].
	invocation := anActivityExecution externalInvocation.
	invocation ifNil: [ self error: 'The Service Task has no pending external invocation.' ].
	invocation isPending ifFalse: [ self error: 'The Service Task external invocation has already accepted a result.' ].
	self acceptOccurrence: anOccurrence.
	invocation acceptResultOccurrence: anOccurrence.
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'building' }
CPExecutionScope >> createReceiveTaskExecutionFor: aReceiveTask [
	^ self addActivityExecution: (CPReceiveTaskExecution new
		definition: aReceiveTask;
		yourself)
]

{ #category : 'activities - receive' }
CPExecutionScope >> activateReceiveTaskExecution: anActivityExecution [
	| subscription |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Receive Task execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Receive Task execution can become Active.' ].
	anActivityExecution definition messageRef ifNil: [
		self error: 'A Receive Task requires a Message.' ].
	anActivityExecution activate.
	subscription := CPMessageSubscription new
		waitingExecution: anActivityExecution;
		message: anActivityExecution definition messageRef;
		yourself.
	anActivityExecution subscription: subscription.
	messageSubscriptions add: subscription.
	^ anActivityExecution
]

{ #category : 'activities - receive' }
CPExecutionScope >> triggerReceiveTaskExecution: anActivityExecution with: anOccurrence [
	| subscription |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Receive Task execution does not belong to this execution scope.' ].
	anActivityExecution isWaitingForMessage ifFalse: [
		self error: 'Only a waiting Receive Task can accept a message occurrence.' ].
	subscription := anActivityExecution subscription.
	subscription ifNil: [ self error: 'The Receive Task has no Message subscription.' ].
	anOccurrence definition == subscription message ifFalse: [
		self error: 'The occurrence does not carry the Message awaited by this Receive Task.' ].
	self acceptOccurrence: anOccurrence.
	subscription triggerWith: anOccurrence.
	anActivityExecution acceptReceivedOccurrence: anOccurrence.
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]


{ #category : 'events - timer' }
CPExecutionScope >> beginTimerIntermediateCatchEvent: anEvent consuming: anActivation [
	| execution timerDefinition subscription |
	anEvent eventDefinitions size = 1 ifFalse: [
		self error: 'A Timer Intermediate Catch Event requires exactly one Timer Event Definition.' ].
	timerDefinition := anEvent eventDefinitions first.
	execution := self beginIntermediateCatchEvent: anEvent consuming: anActivation.
	subscription := CPTimerSubscription new
		eventExecution: execution;
		timerDefinition: timerDefinition;
		yourself.
	execution subscription: subscription.
	timerSubscriptions add: subscription.
	^ execution
]

{ #category : 'events - timer' }
CPExecutionScope >> triggerTimerIntermediateCatchEventExecution: anEventExecution with: anOccurrence [
	| subscription |
	(eventExecutions identityIncludes: anEventExecution) ifFalse: [
		self error: 'The Timer Intermediate Catch Event execution does not belong to this execution scope.' ].
	anEventExecution isWaiting ifFalse: [
		self error: 'Only a waiting Timer Intermediate Catch Event can accept an occurrence.' ].
	subscription := anEventExecution subscription.
	subscription ifNil: [ self error: 'The Timer Intermediate Catch Event has no Timer subscription.' ].
	anOccurrence definition == subscription timerDefinition ifFalse: [
		self error: 'The occurrence does not match this Timer subscription.' ].
	self acceptOccurrence: anOccurrence.
	subscription triggerWith: anOccurrence.
	anEventExecution triggerWithAcceptedOccurrence: anOccurrence.
	^ anEventExecution
]


{ #category : 'events - message' }
CPExecutionScope >> beginMessageIntermediateCatchEvent: anEvent consuming: anActivation [
	| execution messageDefinition subscription |
	anEvent eventDefinitions size = 1 ifFalse: [
		self error: 'A Message Intermediate Catch Event requires exactly one Message Event Definition.' ].
	messageDefinition := anEvent eventDefinitions first.
	messageDefinition messageRef ifNil: [
		self error: 'A Message Intermediate Catch Event requires a Message.' ].
	execution := self beginIntermediateCatchEvent: anEvent consuming: anActivation.
	subscription := CPMessageSubscription new
		waitingExecution: execution;
		message: messageDefinition messageRef;
		yourself.
	execution subscription: subscription.
	messageSubscriptions add: subscription.
	^ execution
]

{ #category : 'events - message' }
CPExecutionScope >> triggerMessageIntermediateCatchEventExecution: anEventExecution with: anOccurrence [
	| subscription |
	(eventExecutions identityIncludes: anEventExecution) ifFalse: [
		self error: 'The Message Intermediate Catch Event execution does not belong to this execution scope.' ].
	anEventExecution isWaiting ifFalse: [
		self error: 'Only a waiting Message Intermediate Catch Event can accept an occurrence.' ].
	subscription := anEventExecution subscription.
	subscription ifNil: [ self error: 'The Message Intermediate Catch Event has no Message subscription.' ].
	anOccurrence definition == subscription message ifFalse: [
		self error: 'The occurrence does not match this Message subscription.' ].
	self acceptOccurrence: anOccurrence.
	subscription triggerWith: anOccurrence.
	anEventExecution triggerWithAcceptedOccurrence: anOccurrence.
	^ anEventExecution
]

{ #category : 'lifecycle' }
CPExecutionScope >> terminateRemainingWork [
	childScopes do: [ :eachScope | eachScope terminateRemainingWork ].
	activityExecutions do: [ :eachExecution |
		eachExecution isFinal ifFalse: [
			eachExecution isReady
				ifTrue: [ eachExecution withdraw ]
				ifFalse: [
					eachExecution beginTermination.
					eachExecution finishTermination ] ] ].
	flowActivations do: [ :eachActivation |
		eachActivation isAvailable ifTrue: [ eachActivation cancel ] ].
	messageSubscriptions do: [ :eachSubscription |
		eachSubscription isWaiting ifTrue: [ eachSubscription cancel ] ].
	timerSubscriptions do: [ :eachSubscription |
		eachSubscription isWaiting ifTrue: [ eachSubscription cancel ] ].
	gatewayExecutions do: [ :eachExecution |
		eachExecution subscriptions do: [ :eachSubscription |
			eachSubscription isWaiting ifTrue: [ eachSubscription withdraw ] ] ].
	eventExecutions do: [ :eachExecution |
		(eachExecution isBoundaryEventExecution and: [ eachExecution isWaiting ]) ifTrue: [
			eachExecution withdraw ] ].
	^ self
]

{ #category : 'lifecycle' }
CPExecutionScope >> finishTermination [
	owningActivity ifNil: [ self error: 'Only a nested execution scope can finish termination through an owning Activity.' ].
	owningActivity isActive ifFalse: [ self error: 'A terminated nested scope requires an Active owning Activity.' ].
	owningActivity beginCompletion.
	owningActivity complete.
	parentScope produceOutgoingControlFor: owningActivity.
	^ self
]

{ #category : 'events - end' }
CPExecutionScope >> executeTerminateEndEvent: aTerminateEndEvent consuming: anActivation [
	| execution |
	aTerminateEndEvent outgoing isEmpty ifFalse: [ self error: 'A Terminate End Event cannot produce outgoing Sequence Flow.' ].
	(anActivation isAvailable and: [ aTerminateEndEvent incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'A Terminate End Event requires an available activation from one of its incoming Sequence Flows.' ].
	execution := self createEventExecutionFor: aTerminateEndEvent.
	execution consumeFlowActivation: anActivation.
	self terminateRemainingWork.
	self finishTermination.
	^ execution
]
