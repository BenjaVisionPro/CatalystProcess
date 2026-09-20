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
		'messageSubscriptions',
		'signalSubscriptions',
		'conditionalSubscriptions',
		'compensationRecords',
		'itemValues',
		'itemValueProducers'
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
	messageSubscriptions := OrderedCollection new.
	signalSubscriptions := OrderedCollection new.
	conditionalSubscriptions := OrderedCollection new.
	compensationRecords := OrderedCollection new.
	itemValues := IdentityDictionary new.
	itemValueProducers := IdentityDictionary new
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


{ #category : 'data' }
CPExecutionScope >> ownsItemValueFor: anItemAwareElement [
	((definition flowElements identityIncludes: anItemAwareElement)
		and: [ anItemAwareElement isDataObject ]) ifTrue: [ ^ true ].
	definition isSubProcess ifTrue: [ ^ false ].
	(definition properties identityIncludes: anItemAwareElement) ifTrue: [ ^ true ].
	definition ioSpecification ifNotNil: [ :specification |
		(specification dataInputs identityIncludes: anItemAwareElement) ifTrue: [ ^ true ].
		(specification dataOutputs identityIncludes: anItemAwareElement) ifTrue: [ ^ true ] ].
	^ false
]

{ #category : 'data' }
CPExecutionScope >> executionContextForAccessibleItemValue: anItemAwareElement [
	anItemAwareElement isDataObjectReference ifTrue: [
		(self hasAccessibleDataObjectReference: anItemAwareElement) ifFalse: [
			self error: 'The Data Object Reference is not accessible from this execution scope.' ].
		anItemAwareElement dataObjectRef ifNil: [
			self error: 'An accessible Data Object Reference requires a referenced Data Object.' ].
		^ self executionContextForAccessibleItemValue: anItemAwareElement dataObjectRef ].
	(self ownsItemValueFor: anItemAwareElement) ifTrue: [ ^ self ].
	(owningActivity notNil and: [ owningActivity ownsItemValueFor: anItemAwareElement ]) ifTrue: [
		^ owningActivity ].
	parentScope ifNotNil: [
		^ parentScope executionContextForAccessibleItemValue: anItemAwareElement ].
	self error: 'The item-aware element is not accessible from this execution scope.'
]

{ #category : 'data' }
CPExecutionScope >> hasAccessibleDataObjectReference: aDataObjectReference [
	(definition flowElements identityIncludes: aDataObjectReference) ifTrue: [ ^ true ].
	parentScope ifNotNil: [
		^ parentScope hasAccessibleDataObjectReference: aDataObjectReference ].
	^ false
]

{ #category : 'data' }
CPExecutionScope >> accessibleItemValueAvailableFor: anItemAwareElement [
	| context item |
	item := anItemAwareElement isDataObjectReference
		ifTrue: [ anItemAwareElement dataObjectRef ]
		ifFalse: [ anItemAwareElement ].
	context := self executionContextForAccessibleItemValue: anItemAwareElement.
	^ context hasItemValueFor: item
]

{ #category : 'data' }
CPExecutionScope >> hasItemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this execution scope.' ].
	^ itemValues includesKey: anItemAwareElement
]

{ #category : 'data' }
CPExecutionScope >> accessibleItemValueFor: anItemAwareElement [
	| context item |
	item := anItemAwareElement isDataObjectReference
		ifTrue: [ anItemAwareElement dataObjectRef ]
		ifFalse: [ anItemAwareElement ].
	context := self executionContextForAccessibleItemValue: anItemAwareElement.
	^ context itemValueFor: item
]

{ #category : 'data' }
CPExecutionScope >> accessibleItemValueFor: anItemAwareElement put: aValue [
	| context item |
	item := anItemAwareElement isDataObjectReference
		ifTrue: [ anItemAwareElement dataObjectRef ]
		ifFalse: [ anItemAwareElement ].
	context := self executionContextForAccessibleItemValue: anItemAwareElement.
	^ context itemValueFor: item put: aValue
]

{ #category : 'data - provenance' }
CPExecutionScope >> accessibleItemValueProducerFor: anItemAwareElement [
	| context item |
	item := anItemAwareElement isDataObjectReference
		ifTrue: [ anItemAwareElement dataObjectRef ]
		ifFalse: [ anItemAwareElement ].
	context := self executionContextForAccessibleItemValue: anItemAwareElement.
	^ context itemValueProducerFor: item
]

{ #category : 'data - provenance' }
CPExecutionScope >> accessibleItemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution [
	| context item |
	item := anItemAwareElement isDataObjectReference
		ifTrue: [ anItemAwareElement dataObjectRef ]
		ifFalse: [ anItemAwareElement ].
	context := self executionContextForAccessibleItemValue: anItemAwareElement.
	^ context itemValueFor: item put: aValue producedBy: anActivityExecution
]

{ #category : 'data' }
CPExecutionScope >> itemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this execution scope.' ].
	^ itemValues at: anItemAwareElement ifAbsent: [ nil ]
]

{ #category : 'data' }
CPExecutionScope >> itemValueFor: anItemAwareElement put: aValue [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this execution scope.' ].
	itemValues at: anItemAwareElement put: aValue.
	itemValueProducers at: anItemAwareElement put: nil.
	^ aValue
]

{ #category : 'data - provenance' }
CPExecutionScope >> itemValueProducerFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this execution scope.' ].
	^ itemValueProducers at: anItemAwareElement ifAbsent: [ nil ]
]

{ #category : 'data - provenance' }
CPExecutionScope >> itemValueFor: anItemAwareElement put: aValue producedBy: anActivityExecution [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this execution scope.' ].
	itemValues at: anItemAwareElement put: aValue.
	itemValueProducers at: anItemAwareElement put: anActivityExecution.
	^ aValue
]

{ #category : 'accessing' }
CPExecutionScope >> compensationRecords [ ^ compensationRecords ]
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
CPExecutionScope >> signalSubscriptions [ ^ signalSubscriptions ]

{ #category : 'accessing' }
CPExecutionScope >> conditionalSubscriptions [ ^ conditionalSubscriptions ]

{ #category : 'conditional events' }
CPExecutionScope >> waitingConditionalSubscriptions [
	^ conditionalSubscriptions select: #isWaiting
]

{ #category : 'conditional events' }
CPExecutionScope >> allWaitingConditionalSubscriptions [
	| subscriptions |
	subscriptions := self waitingConditionalSubscriptions asOrderedCollection.
	childScopes do: [ :eachScope |
		subscriptions addAll: eachScope allWaitingConditionalSubscriptions ].
	^ subscriptions
]

{ #category : 'conditional events' }
CPExecutionScope >> evaluateConditionalSubscription: aSubscription [
	(conditionalSubscriptions identityIncludes: aSubscription) ifFalse: [
		self error: 'The Conditional subscription does not belong to this execution scope.' ].
	aSubscription isWaiting ifFalse: [
		self error: 'Only a waiting Conditional subscription can be evaluated.' ].
	(self environment evaluateExpression: aSubscription condition in: self) ifFalse: [ ^ false ].
	aSubscription trigger.
	aSubscription waitingExecution triggerWithoutOccurrence.
	^ true
]


{ #category : 'signals' }
CPExecutionScope >> waitingSignalSubscriptions [
	^ signalSubscriptions select: #isWaiting
]

{ #category : 'signals' }
CPExecutionScope >> allWaitingSignalSubscriptions [
	| subscriptions |
	subscriptions := self waitingSignalSubscriptions asOrderedCollection.
	childScopes do: [ :eachScope |
		subscriptions addAll: eachScope allWaitingSignalSubscriptions ].
	^ subscriptions
]

{ #category : 'signals' }
CPExecutionScope >> allWaitingSignalSubscriptionsFor: aSignal [
	^ self allWaitingSignalSubscriptions select: [ :each | each signal == aSignal ]
]

{ #category : 'signals' }
CPExecutionScope >> triggerSignalIntermediateCatchEventExecution: anEventExecution withAcceptedOccurrence: anOccurrence [
	| subscription |
	(eventExecutions identityIncludes: anEventExecution) ifFalse: [
		self error: 'The Signal Intermediate Catch Event execution does not belong to this execution scope.' ].
	anEventExecution isWaiting ifFalse: [
		self error: 'Only a waiting Signal Intermediate Catch Event can accept an occurrence.' ].
	subscription := anEventExecution subscription.
	subscription ifNil: [ self error: 'The Signal Intermediate Catch Event has no Signal subscription.' ].
	anOccurrence definition == subscription signal ifFalse: [
		self error: 'The occurrence does not match this Signal subscription.' ].
	(self processExecution hasAcceptedOccurrenceAnywhere: anOccurrence) ifFalse: [
		self error: 'A broadcast Signal occurrence must be accepted by the Process execution before delivery.' ].
	subscription triggerWith: anOccurrence.
	anEventExecution triggerWithAcceptedOccurrence: anOccurrence.
	^ anEventExecution
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
	anActivity isForCompensation ifTrue: [
		self error: 'A Compensation Activity cannot become Ready from normal Sequence Flow.' ].
	(anActivity isSubProcess and: [ anActivity isEventSubProcess ]) ifTrue: [
		self error: 'An Event SubProcess cannot become Ready from normal Sequence Flow.' ].
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
CPExecutionScope >> hasAcceptedOccurrenceIdentifiedByAnywhere: anIdentifier [
	(self hasAcceptedOccurrenceIdentifiedBy: anIdentifier) ifTrue: [ ^ true ].
	^ childScopes anySatisfy: [ :eachScope |
		eachScope hasAcceptedOccurrenceIdentifiedByAnywhere: anIdentifier ]
]

{ #category : 'occurrences' }
CPExecutionScope >> hasAcceptedOccurrenceAnywhere: anOccurrence [
	(acceptedOccurrences identityIncludes: anOccurrence) ifTrue: [ ^ true ].
	^ childScopes anySatisfy: [ :eachScope |
		eachScope hasAcceptedOccurrenceAnywhere: anOccurrence ]
]

{ #category : 'occurrences' }
CPExecutionScope >> processExecution [
	parentScope ifNil: [ self error: 'A nested execution scope requires a parent Process execution.' ].
	^ parentScope processExecution
]

{ #category : 'occurrences' }
CPExecutionScope >> acceptOccurrence: anOccurrence [
	| rootExecution |
	anOccurrence occurrenceIdentifier ifNil: [ self error: 'An occurrence requires an occurrence identifier.' ].
	rootExecution := self processExecution.
	(rootExecution hasAcceptedOccurrenceIdentifiedByAnywhere: anOccurrence occurrenceIdentifier)
		ifTrue: [ self error: 'This occurrence has already been accepted by the Process execution.' ].
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
	anOccurrence ifNotNil: [ execution populateCatchEventDataFrom: anOccurrence ].
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
	execution prepareThrowData.
	execution prepareThrownOccurrences.
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


{ #category : 'events - link' }
CPExecutionScope >> executeLinkThrowEvent: aLinkThrowEvent consuming: anActivation [
	| sourceDefinitions sourceDefinition targetDefinition targetEvents targetEvent throwExecution catchExecution |
	(anActivation isAvailable and: [ aLinkThrowEvent incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'A Link Intermediate Throw Event requires an available activation from one of its incoming Sequence Flows.' ].
	sourceDefinitions := aLinkThrowEvent eventDefinitions.
	sourceDefinitions size = 1 ifFalse: [
		self error: 'A Link Intermediate Throw Event requires exactly one Link Event Definition.' ].
	sourceDefinition := sourceDefinitions first.
	targetDefinition := sourceDefinition target.
	targetDefinition ifNil: [ self error: 'A source Link Event Definition requires a target Link Event Definition.' ].
	(targetDefinition sources identityIncludes: sourceDefinition) ifFalse: [
		self error: 'The target Link Event Definition must reference the source Link Event Definition.' ].
	targetEvents := definition flowElements select: [ :each |
		each isEvent and: [
			each isCatchEvent and: [ each eventDefinitions identityIncludes: targetDefinition ] ] ].
	targetEvents size = 1 ifFalse: [
		self error: 'A source Link Event Definition must resolve to exactly one target Link Catch Event in the same execution scope.' ].
	targetEvent := targetEvents first.
	targetEvent container == aLinkThrowEvent container ifFalse: [
		self error: 'Source and target Link Events must be in the same BPMN flow-elements container.' ].
	throwExecution := self beginIntermediateThrowEvent: aLinkThrowEvent consuming: anActivation.
	throwExecution complete.
	catchExecution := CPIntermediateCatchEventExecution new
		definition: targetEvent;
		scope: self;
		yourself.
	eventExecutions add: catchExecution.
	catchExecution triggerWithoutOccurrence.
	^ throwExecution
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
	execution prepareThrowData.
	execution prepareThrownOccurrences.
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
	aBoundaryEventExecution definition cancelActivity ifTrue: [
		aBoundaryEventExecution attachedActivityExecution subScope ifNotNil: [ :aSubScope |
			aSubScope terminateRemainingWork ] ].
	self acceptOccurrence: anOccurrence.
	aBoundaryEventExecution triggerWithAcceptedOccurrence: anOccurrence.
	aBoundaryEventExecution definition cancelActivity ifTrue: [
		self withdrawBoundaryEventsAttachedTo: aBoundaryEventExecution attachedActivityExecution ].
	^ aBoundaryEventExecution
]

{ #category : 'activities - sub-process' }
CPExecutionScope >> activateCompensationSubProcessExecution: anActivityExecution [
	| subProcess startEvents compensationDefinitions subScope |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Compensation Event SubProcess execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Compensation Event SubProcess execution can be activated.' ].
	subProcess := anActivityExecution definition.
	(subProcess isSubProcess and: [ subProcess isForCompensation ]) ifFalse: [
		self error: 'Compensation Event SubProcess execution requires a compensation-only SubProcess.' ].
	subProcess validateEventSubProcessStructure.
	startEvents := subProcess flowElements select: [ :each | each isStartEvent ].
	startEvents size = 1 ifFalse: [
		self error: 'A Compensation Event SubProcess requires exactly one Start Event.' ].
	compensationDefinitions := startEvents first eventDefinitions select: [ :each | each isCompensationEventDefinition ].
	(startEvents first eventDefinitions size = 1 and: [ compensationDefinitions size = 1 ]) ifFalse: [
		self error: 'A Compensation Event SubProcess Start Event requires exactly one Compensation Event Definition.' ].
	startEvents first incoming isEmpty ifFalse: [
		self error: 'A Compensation Event SubProcess Start Event cannot have incoming Sequence Flow.' ].
	anActivityExecution activate.
	subScope := anActivityExecution createSubScopeFor: subProcess.
	subScope executeStartEvent: startEvents first occurrence: nil.
	^ anActivityExecution
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
	(anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
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
		(each isActivity and: [ each incoming isEmpty and: [ each isForCompensation not ] ]) ifTrue: [
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
	subScope allWaitingSignalSubscriptions ifNotEmpty: [ ^ false ].
	subScope allWaitingConditionalSubscriptions ifNotEmpty: [ ^ false ].
	subScope allWaitingEventBasedGatewaySubscriptions ifNotEmpty: [ ^ false ].
	subScope hasPendingEventWork ifTrue: [ ^ false ].
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
	(anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
	calledProcess := self environment
		resolveCallableElement: callActivity calledElement
		in: self.
	startEvents := calledProcess flowElements select: [ :each | each isStartEvent ].
	startEvents := startEvents select: [ :each | each eventDefinitions isEmpty ].
	startEvents size > 1 ifTrue: [
		self error: 'A called Process can have at most one empty Start Event for control-flow invocation.' ].
	self validateCallActivityDataInterface: anActivityExecution against: calledProcess.
	anActivityExecution activate.
	calledScope := anActivityExecution createSubScopeFor: calledProcess.
	self mapCallActivityInputsFrom: anActivityExecution to: calledScope.
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
	self mapCallActivityOutputsFrom: anActivityExecution subScope to: anActivityExecution.
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]


{ #category : 'activities - call - data' }
CPExecutionScope >> validateCallActivityDataInterface: anActivityExecution against: aCallableElement [
	| activitySpecification callableSpecification |
	activitySpecification := anActivityExecution definition ioSpecification.
	callableSpecification := aCallableElement ioSpecification.
	activitySpecification ifNil: [
		callableSpecification ifNil: [ ^ self ].
		self error: 'The Call Activity InputOutputSpecification must exactly match the called Process.' ].
	callableSpecification ifNil: [
		self error: 'The Call Activity InputOutputSpecification must exactly match the called Process.' ].
	activitySpecification dataInputs size = callableSpecification dataInputs size ifFalse: [
		self error: 'The Call Activity DataInputs must exactly match the called Process DataInputs.' ].
	activitySpecification dataOutputs size = callableSpecification dataOutputs size ifFalse: [
		self error: 'The Call Activity DataOutputs must exactly match the called Process DataOutputs.' ].
	activitySpecification inputSets size = callableSpecification inputSets size ifFalse: [
		self error: 'The Call Activity InputSets must exactly match the called Process InputSets.' ].
	activitySpecification outputSets size = callableSpecification outputSets size ifFalse: [
		self error: 'The Call Activity OutputSets must exactly match the called Process OutputSets.' ].
	1 to: activitySpecification inputSets size do: [ :index |
		| activitySet callableSet |
		activitySet := activitySpecification inputSets at: index.
		callableSet := callableSpecification inputSets at: index.
		activitySet dataInputRefs size = callableSet dataInputRefs size ifFalse: [
			self error: 'Corresponding Call Activity and called Process InputSets must contain the same number of DataInputs.' ].
		activitySet optionalInputRefs size = callableSet optionalInputRefs size ifFalse: [
			self error: 'Corresponding Call Activity and called Process InputSets must have matching optional DataInputs.' ].
		activitySet whileExecutingInputRefs size = callableSet whileExecutingInputRefs size ifFalse: [
			self error: 'Corresponding Call Activity and called Process InputSets must have matching while-executing DataInputs.' ].
		1 to: activitySpecification dataInputs size do: [ :inputIndex |
			((activitySet dataInputRefs identityIncludes: (activitySpecification dataInputs at: inputIndex))
				= (callableSet dataInputRefs identityIncludes: (callableSpecification dataInputs at: inputIndex))) ifFalse: [
				self error: 'Corresponding Call Activity and called Process InputSets must reference corresponding DataInputs.' ].
			((activitySet optionalInputRefs identityIncludes: (activitySpecification dataInputs at: inputIndex))
				= (callableSet optionalInputRefs identityIncludes: (callableSpecification dataInputs at: inputIndex))) ifFalse: [
				self error: 'Corresponding Call Activity and called Process InputSets must mark corresponding DataInputs optional.' ].
			((activitySet whileExecutingInputRefs identityIncludes: (activitySpecification dataInputs at: inputIndex))
				= (callableSet whileExecutingInputRefs identityIncludes: (callableSpecification dataInputs at: inputIndex))) ifFalse: [
				self error: 'Corresponding Call Activity and called Process InputSets must mark corresponding DataInputs while-executing.' ] ].
		1 to: activitySpecification outputSets size do: [ :outputSetIndex |
			((activitySet outputSetRefs identityIncludes: (activitySpecification outputSets at: outputSetIndex))
				= (callableSet outputSetRefs identityIncludes: (callableSpecification outputSets at: outputSetIndex))) ifFalse: [
				self error: 'Corresponding Call Activity and called Process InputSets must reference corresponding OutputSets.' ] ] ].
	1 to: activitySpecification outputSets size do: [ :index |
		| activitySet callableSet |
		activitySet := activitySpecification outputSets at: index.
		callableSet := callableSpecification outputSets at: index.
		activitySet dataOutputRefs size = callableSet dataOutputRefs size ifFalse: [
			self error: 'Corresponding Call Activity and called Process OutputSets must contain the same number of DataOutputs.' ].
		activitySet optionalOutputRefs size = callableSet optionalOutputRefs size ifFalse: [
			self error: 'Corresponding Call Activity and called Process OutputSets must have matching optional DataOutputs.' ].
		activitySet whileExecutingOutputRefs size = callableSet whileExecutingOutputRefs size ifFalse: [
			self error: 'Corresponding Call Activity and called Process OutputSets must have matching while-executing DataOutputs.' ].
		1 to: activitySpecification dataOutputs size do: [ :outputIndex |
			((activitySet dataOutputRefs identityIncludes: (activitySpecification dataOutputs at: outputIndex))
				= (callableSet dataOutputRefs identityIncludes: (callableSpecification dataOutputs at: outputIndex))) ifFalse: [
				self error: 'Corresponding Call Activity and called Process OutputSets must reference corresponding DataOutputs.' ].
			((activitySet optionalOutputRefs identityIncludes: (activitySpecification dataOutputs at: outputIndex))
				= (callableSet optionalOutputRefs identityIncludes: (callableSpecification dataOutputs at: outputIndex))) ifFalse: [
				self error: 'Corresponding Call Activity and called Process OutputSets must mark corresponding DataOutputs optional.' ].
			((activitySet whileExecutingOutputRefs identityIncludes: (activitySpecification dataOutputs at: outputIndex))
				= (callableSet whileExecutingOutputRefs identityIncludes: (callableSpecification dataOutputs at: outputIndex))) ifFalse: [
				self error: 'Corresponding Call Activity and called Process OutputSets must mark corresponding DataOutputs while-executing.' ] ].
		1 to: activitySpecification inputSets size do: [ :inputSetIndex |
			((activitySet inputSetRefs identityIncludes: (activitySpecification inputSets at: inputSetIndex))
				= (callableSet inputSetRefs identityIncludes: (callableSpecification inputSets at: inputSetIndex))) ifFalse: [
				self error: 'Corresponding Call Activity and called Process OutputSets must reference corresponding InputSets.' ] ] ].
	^ self
]

{ #category : 'activities - call - data' }
CPExecutionScope >> mapCallActivityInputsFrom: anActivityExecution to: calledScope [
	| activitySpecification callableSpecification activityInputs callableInputs |
	activitySpecification := anActivityExecution definition ioSpecification.
	callableSpecification := calledScope definition ioSpecification.
	activitySpecification ifNil: [
		callableSpecification ifNil: [ ^ self ].
		callableSpecification dataInputs ifEmpty: [ ^ self ].
		self error: 'The Call Activity data interface does not match the called Process.' ].
	callableSpecification ifNil: [
		activitySpecification dataInputs ifEmpty: [ ^ self ].
		self error: 'The Call Activity data interface does not match the called Process.' ].
	activityInputs := activitySpecification dataInputs.
	callableInputs := callableSpecification dataInputs.
	activityInputs size = callableInputs size ifFalse: [
		self error: 'The Call Activity DataInputs must exactly match the called Process DataInputs.' ].
	1 to: activityInputs size do: [ :index |
		(anActivityExecution hasItemValueFor: (activityInputs at: index)) ifFalse: [
			self error: 'A Call Activity DataInput is unavailable for invocation.' ].
		calledScope
			itemValueFor: (callableInputs at: index)
			put: (anActivityExecution itemValueFor: (activityInputs at: index)) ].
	^ self
]

{ #category : 'activities - call - data' }
CPExecutionScope >> mapCallActivityOutputsFrom: calledScope to: anActivityExecution [
	| activitySpecification callableSpecification activityOutputs callableOutputs |
	activitySpecification := anActivityExecution definition ioSpecification.
	callableSpecification := calledScope definition ioSpecification.
	activitySpecification ifNil: [
		callableSpecification ifNil: [ ^ self ].
		callableSpecification dataOutputs ifEmpty: [ ^ self ].
		self error: 'The Call Activity data interface does not match the called Process.' ].
	callableSpecification ifNil: [
		activitySpecification dataOutputs ifEmpty: [ ^ self ].
		self error: 'The Call Activity data interface does not match the called Process.' ].
	activityOutputs := activitySpecification dataOutputs.
	callableOutputs := callableSpecification dataOutputs.
	activityOutputs size = callableOutputs size ifFalse: [
		self error: 'The Call Activity DataOutputs must exactly match the called Process DataOutputs.' ].
	1 to: callableOutputs size do: [ :index |
		(calledScope hasItemValueFor: (callableOutputs at: index)) ifFalse: [
			self error: 'A called Process DataOutput is unavailable at Call Activity completion.' ].
		anActivityExecution
			itemValueFor: (activityOutputs at: index)
			put: (calledScope itemValueFor: (callableOutputs at: index))
			producedBy: anActivityExecution ].
	^ self
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
	(anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
	implementation := self environment resolveOperation: operation in: self.
	anActivityExecution resolvedImplementation: implementation.
	anActivityExecution activate.
	(serviceTask loopCharacteristics notNil and: [ serviceTask loopCharacteristics isStandardLoop ]) ifTrue: [
		anActivityExecution standardLoopMayBeginNextIteration
			ifTrue: [ anActivityExecution beginStandardLoopIteration ]
			ifFalse: [ self completeStandardLoopExecution: anActivityExecution ].
		^ anActivityExecution ].
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
	anActivityExecution definition operationRef outMessageRef ifNotNil: [
		anActivityExecution populateSingleDataOutputFromOccurrence: anOccurrence ].
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]


{ #category : 'activities - service' }
CPExecutionScope >> completeStandardLoopServiceTaskIteration: anIteration withResultOccurrence: anOccurrence [
	| invocation outerExecution |
	outerExecution := anIteration activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Standard Loop Service Task iteration does not belong to this execution scope.' ].
	(outerExecution standardLoopIterations identityIncludes: anIteration) ifFalse: [
		self error: 'The Standard Loop Service Task iteration does not belong to its outer Activity execution.' ].
	anIteration isActive ifFalse: [
		self error: 'Only an active Standard Loop Service Task iteration can accept an external result.' ].
	invocation := anIteration externalInvocation.
	invocation ifNil: [ self error: 'The Standard Loop Service Task iteration has no pending external invocation.' ].
	invocation isPending ifFalse: [ self error: 'The Standard Loop Service Task external invocation has already accepted a result.' ].
	self acceptOccurrence: anOccurrence.
	invocation acceptResultOccurrence: anOccurrence.
	outerExecution definition operationRef outMessageRef ifNotNil: [
		outerExecution populateSingleDataOutputFromOccurrence: anOccurrence ].
	self completeStandardLoopIteration: anIteration of: outerExecution.
	^ anIteration
]

{ #category : 'activities - service' }
CPExecutionScope >> completeMultiInstanceServiceTaskExecution: anInstance withResultOccurrence: anOccurrence [
	| invocation outerExecution |
	outerExecution := anInstance activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Multi-Instance Service Task instance does not belong to this execution scope.' ].
	(outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
		self error: 'The Multi-Instance Service Task instance does not belong to its outer Activity execution.' ].
	anInstance isActive ifFalse: [
		self error: 'Only an active Multi-Instance Service Task instance can accept an external result.' ].
	invocation := anInstance externalInvocation.
	invocation ifNil: [ self error: 'The Multi-Instance Service Task instance has no pending external invocation.' ].
	invocation isPending ifFalse: [ self error: 'The Multi-Instance Service Task external invocation has already accepted a result.' ].
	self acceptOccurrence: anOccurrence.
	invocation acceptResultOccurrence: anOccurrence.
	outerExecution definition operationRef outMessageRef ifNotNil: [
		anInstance populateSingleDataOutputFromOccurrence: anOccurrence ].
	anInstance complete.
	^ anInstance
]

{ #category : 'building' }
CPExecutionScope >> createReceiveTaskExecutionFor: aReceiveTask [
	^ self addActivityExecution: (CPReceiveTaskExecution new
		definition: aReceiveTask;
		yourself)
]

{ #category : 'activities - receive' }
CPExecutionScope >> activateReceiveTaskExecution: anActivityExecution [
	| subscription loop |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Receive Task execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Receive Task execution can become Active.' ].
	anActivityExecution definition messageRef ifNil: [
		self error: 'A Receive Task requires a Message.' ].
	(anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
	anActivityExecution activate.
	loop := anActivityExecution definition loopCharacteristics.
	(loop notNil and: [ loop isMultiInstance ]) ifTrue: [
		anActivityExecution beginMultiInstanceActivityExecutions.
		^ anActivityExecution ].
	(loop notNil and: [ loop isStandardLoop ]) ifTrue: [
		anActivityExecution standardLoopMayBeginNextIteration
			ifTrue: [ anActivityExecution beginStandardLoopIteration ]
			ifFalse: [ self completeStandardLoopExecution: anActivityExecution ].
		^ anActivityExecution ].
	subscription := CPMessageSubscription new
		waitingExecution: anActivityExecution;
		message: anActivityExecution definition messageRef;
		yourself.
	anActivityExecution subscription: subscription.
	messageSubscriptions add: subscription.
	^ anActivityExecution
]


{ #category : 'activities - receive' }
CPExecutionScope >> subscribeMultiInstanceReceiveTaskExecution: anInstance [
	| outerExecution subscription |
	outerExecution := anInstance activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Multi-Instance Receive Task instance does not belong to this execution scope.' ].
	(outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
		self error: 'The Multi-Instance Receive Task instance does not belong to its outer Activity execution.' ].
	anInstance isActive ifFalse: [
		self error: 'Only an active Multi-Instance Receive Task instance can wait for a Message.' ].
	anInstance messageSubscription ifNotNil: [
		self error: 'A Multi-Instance Receive Task instance can have only one Message subscription.' ].
	subscription := CPMessageSubscription new
		waitingExecution: anInstance;
		message: outerExecution definition messageRef;
		yourself.
	anInstance messageSubscription: subscription.
	messageSubscriptions add: subscription.
	^ subscription
]

{ #category : 'activities - receive' }
CPExecutionScope >> triggerMultiInstanceReceiveTaskExecution: anInstance with: anOccurrence [
	| outerExecution subscription |
	outerExecution := anInstance activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Multi-Instance Receive Task instance does not belong to this execution scope.' ].
	(outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
		self error: 'The Multi-Instance Receive Task instance does not belong to its outer Activity execution.' ].
	anInstance isWaitingForMessage ifFalse: [
		self error: 'Only a waiting Multi-Instance Receive Task instance can accept a message occurrence.' ].
	subscription := anInstance messageSubscription.
	anOccurrence definition == subscription message ifFalse: [
		self error: 'The occurrence does not carry the Message awaited by this Multi-Instance Receive Task instance.' ].
	self acceptOccurrence: anOccurrence.
	anInstance acceptReceivedOccurrence: anOccurrence.
	subscription triggerWith: anOccurrence.
	anInstance populateSingleDataOutputFromOccurrence: anOccurrence.
	anInstance complete.
	^ anInstance
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
	anActivityExecution populateSingleDataOutputFromOccurrence: anOccurrence.
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]


{ #category : 'events - conditional' }
CPExecutionScope >> beginConditionalIntermediateCatchEvent: anEvent consuming: anActivation [
	| execution conditionalDefinition subscription |
	anEvent eventDefinitions size = 1 ifFalse: [
		self error: 'A Conditional Intermediate Catch Event requires exactly one Conditional Event Definition.' ].
	conditionalDefinition := anEvent eventDefinitions first.
	conditionalDefinition condition ifNil: [
		self error: 'A Conditional Intermediate Catch Event requires a condition.' ].
	execution := self beginIntermediateCatchEvent: anEvent consuming: anActivation.
	subscription := CPConditionalSubscription new
		waitingExecution: execution;
		condition: conditionalDefinition condition;
		yourself.
	execution subscription: subscription.
	conditionalSubscriptions add: subscription.
	self evaluateConditionalSubscription: subscription.
	^ execution
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

{ #category : 'events - signal' }
CPExecutionScope >> beginSignalIntermediateCatchEvent: anEvent consuming: anActivation [
	| execution signalDefinition subscription |
	anEvent eventDefinitions size = 1 ifFalse: [
		self error: 'A Signal Intermediate Catch Event requires exactly one Signal Event Definition.' ].
	signalDefinition := anEvent eventDefinitions first.
	signalDefinition signalRef ifNil: [
		self error: 'A Signal Intermediate Catch Event requires a Signal.' ].
	execution := self beginIntermediateCatchEvent: anEvent consuming: anActivation.
	subscription := CPSignalSubscription new
		waitingExecution: execution;
		signal: signalDefinition signalRef;
		yourself.
	execution subscription: subscription.
	signalSubscriptions add: subscription.
	^ execution
]

{ #category : 'events - signal' }
CPExecutionScope >> triggerSignalIntermediateCatchEventExecution: anEventExecution with: anOccurrence [
	| subscription |
	(eventExecutions identityIncludes: anEventExecution) ifFalse: [
		self error: 'The Signal Intermediate Catch Event execution does not belong to this execution scope.' ].
	anEventExecution isWaiting ifFalse: [
		self error: 'Only a waiting Signal Intermediate Catch Event can accept an occurrence.' ].
	subscription := anEventExecution subscription.
	subscription ifNil: [ self error: 'The Signal Intermediate Catch Event has no Signal subscription.' ].
	anOccurrence definition == subscription signal ifFalse: [
		self error: 'The occurrence does not match this Signal subscription.' ].
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
	signalSubscriptions do: [ :eachSubscription |
		eachSubscription isWaiting ifTrue: [ eachSubscription cancel ] ].
	conditionalSubscriptions do: [ :eachSubscription |
		eachSubscription isWaiting ifTrue: [ eachSubscription cancel ] ].
	gatewayExecutions do: [ :eachExecution |
		eachExecution subscriptions do: [ :eachSubscription |
			eachSubscription isWaiting ifTrue: [ eachSubscription withdraw ] ] ].
	eventExecutions do: [ :eachExecution |
		eachExecution terminatePendingWork.
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

{ #category : 'testing' }
CPExecutionScope >> hasPendingEventWork [
	(eventExecutions anySatisfy: [ :eachExecution | eachExecution isPendingWork ]) ifTrue: [ ^ true ].
	^ childScopes anySatisfy: [ :eachScope | eachScope hasPendingEventWork ]
]

{ #category : 'events - error' }
CPExecutionScope >> errorStartEventFor: anErrorSubProcess [
	| startEvents startEvent |
	anErrorSubProcess validateEventSubProcessStructure.
	startEvents := anErrorSubProcess flowElements select: [ :each | each isStartEvent ].
	startEvents size = 1 ifFalse: [
		self error: 'An Error Event SubProcess requires exactly one Start Event.' ].
	startEvent := startEvents first.
	startEvent isErrorStartEvent ifFalse: [
		self error: 'An Error Event SubProcess requires an Error Start Event.' ].
	startEvent incoming isEmpty ifFalse: [
		self error: 'An Error Event SubProcess Start Event cannot have incoming Sequence Flow.' ].
	startEvent eventDefinitions size = 1 ifFalse: [
		self error: 'An Error Start Event requires exactly one Error Event Definition.' ].
	^ startEvent
]

{ #category : 'events - error' }
CPExecutionScope >> matchingErrorEventSubProcessFor: anError [
	| matches |
	matches := definition flowElements select: [ :each |
		each isSubProcess and: [
			each isErrorEventSubProcess and: [
				| startEvent |
				startEvent := self errorStartEventFor: each.
				startEvent eventDefinitions first catchesError: anError ] ] ].
	matches size > 1 ifTrue: [
		self error: 'More than one Error Event SubProcess matches the propagated Error in the same execution scope.' ].
	^ matches ifEmpty: [ nil ] ifNotEmpty: [ matches first ]
]

{ #category : 'events - error' }
CPExecutionScope >> beginErrorEventSubProcess: anErrorSubProcess occurrence: anOccurrence [
	| startEvent handlerExecution handlerScope |
	startEvent := self errorStartEventFor: anErrorSubProcess.
	owningActivity ifNotNil: [
		owningActivity isActive ifFalse: [
			self error: 'An interrupting Error Event SubProcess requires an Active owning Activity.' ].
		owningActivity beginFailure ].
	self terminateRemainingWork.
	handlerExecution := self createActivityExecutionFor: anErrorSubProcess.
	handlerExecution activate.
	handlerScope := handlerExecution createSubScopeFor: anErrorSubProcess.
	handlerScope executeStartEvent: startEvent occurrence: anOccurrence.
	^ handlerExecution
]

{ #category : 'events - error' }
CPExecutionScope >> completeErrorEventSubProcessActivity: anActivityExecution [
	(self canCompleteSubProcessActivity: anActivityExecution) ifFalse: [
		self error: 'The Error Event SubProcess cannot complete while nested control flow or Activities remain active.' ].
	anActivityExecution definition isErrorEventSubProcess ifFalse: [
		self error: 'Only an Error Event SubProcess can complete through error-handler completion.' ].
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	owningActivity ifNotNil: [ owningActivity finishFailure ].
	^ anActivityExecution
]

{ #category : 'events - error' }
CPExecutionScope >> waitingErrorBoundaryExecutionFor: anError attachedTo: anActivityExecution [
	| matches |
	matches := eventExecutions select: [ :eachExecution |
		eachExecution isBoundaryEventExecution
			and: [ eachExecution isWaiting
				and: [ eachExecution attachedActivityExecution == anActivityExecution
					and: [ eachExecution definition catchesError: anError ] ] ] ].
	matches size > 1 ifTrue: [
		self error: 'More than one waiting Error Boundary Event matches the propagated Error on the same Activity execution.' ].
	^ matches ifEmpty: [ nil ] ifNotEmpty: [ matches first ]
]

{ #category : 'events - error' }
CPExecutionScope >> errorBoundaryExecutionFor: anError propagatingFrom: aNestedScope [
	| boundaryExecution |
	boundaryExecution := self
		waitingErrorBoundaryExecutionFor: anError
		attachedTo: aNestedScope owningActivity.
	boundaryExecution ifNotNil: [ ^ boundaryExecution ].
	parentScope ifNil: [ ^ nil ].
	^ parentScope
		errorBoundaryExecutionFor: anError
		propagatingFrom: self
]

{ #category : 'events - error' }
CPExecutionScope >> validateErrorPropagationFor: anError toBoundary: aBoundaryExecution fromNestedScope: aNestedScope [
	| handler records |
	(aBoundaryExecution notNil and: [ eventExecutions identityIncludes: aBoundaryExecution ]) ifTrue: [ ^ aBoundaryExecution ].
	handler := self matchingErrorEventSubProcessFor: anError.
	handler ifNotNil: [
		self errorStartEventFor: handler.
		^ handler ].
	records := self defaultCompensationRecords.
	records do: [ :eachRecord |
		eachRecord activityExecution scope validateCompensationRecord: eachRecord ].
	parentScope ifNil: [ self error: 'No matching Error Event SubProcess or Error Boundary Event is available in the containing execution hierarchy.' ].
	^ parentScope
		validateErrorPropagationFor: anError
		toBoundary: aBoundaryExecution
		fromNestedScope: self
]

{ #category : 'events - error' }
CPExecutionScope >> propagateErrorOccurrence: anOccurrence fromNestedScope: aNestedScope toBoundary: aBoundaryExecution [
	| handler records propagationExecution |
	(aBoundaryExecution notNil and: [ eventExecutions identityIncludes: aBoundaryExecution ]) ifTrue: [
		^ self triggerBoundaryEventExecution: aBoundaryExecution with: anOccurrence ].
	aNestedScope owningActivity isActive ifTrue: [
		aNestedScope owningActivity beginFailure.
		aNestedScope owningActivity finishFailure ].
	handler := self matchingErrorEventSubProcessFor: anOccurrence definition.
	handler ifNotNil: [
		^ self beginErrorEventSubProcess: handler occurrence: anOccurrence ].
	records := self defaultCompensationRecords.
	self terminateRemainingWork.
	parentScope ifNil: [ self error: 'No matching Error Event SubProcess or Error Boundary Event is available in the containing execution hierarchy.' ].
	records ifEmpty: [
		^ parentScope
			propagateErrorOccurrence: anOccurrence
			fromNestedScope: self
			toBoundary: aBoundaryExecution ].
	propagationExecution := CPErrorPropagationExecution new
		scope: self;
		occurrence: anOccurrence;
		boundaryExecution: aBoundaryExecution;
		compensationRecords: records;
		yourself.
	eventExecutions add: propagationExecution.
	(self readyDefaultCompensationRecordsIn: records) do: [ :eachRecord |
		self beginCompensationFor: eachRecord ].
	^ propagationExecution
]

{ #category : 'events - error' }
CPExecutionScope >> executeErrorEndEvent: anErrorEndEvent consuming: anActivation [
	| definitions errorDefinition thrownError execution handler occurrence boundaryExecution records |
	definitions := anErrorEndEvent eventDefinitions.
	definitions size = 1 ifFalse: [
		self error: 'An Error End Event requires exactly one Error Event Definition.' ].
	errorDefinition := definitions first.
	thrownError := errorDefinition error.
	thrownError ifNil: [ self error: 'An Error End Event requires an Error reference.' ].
	handler := self matchingErrorEventSubProcessFor: thrownError.
	handler ifNil: [
		parentScope ifNil: [ self error: 'Uncaught Process-level Error End Event execution is not implemented yet.' ].
		boundaryExecution := parentScope
			errorBoundaryExecutionFor: thrownError
			propagatingFrom: self.
		records := self defaultCompensationRecords.
		records do: [ :eachRecord |
			eachRecord activityExecution scope validateCompensationRecord: eachRecord ].
		parentScope
			validateErrorPropagationFor: thrownError
			toBoundary: boundaryExecution
			fromNestedScope: self ].
	(anActivation isAvailable and: [ anErrorEndEvent incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'An Error End Event requires an available activation from one of its incoming Sequence Flows.' ].
	execution := CPErrorEndEventExecution new
		definition: anErrorEndEvent;
		scope: self;
		yourself.
	eventExecutions add: execution.
	execution consumeFlowActivation: anActivation.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: UUID new asString;
		definition: thrownError;
		yourself.
	execution occurrence: occurrence.
	handler ifNotNil: [
		execution complete.
		self beginErrorEventSubProcess: handler occurrence: occurrence.
		^ execution ].
	self terminateRemainingWork.
	records ifEmpty: [
		execution complete.
		parentScope
			propagateErrorOccurrence: occurrence
			fromNestedScope: self
			toBoundary: boundaryExecution.
		^ execution ].
	execution boundaryExecution: boundaryExecution.
	execution compensationRecords: records.
	(self readyDefaultCompensationRecordsIn: records) do: [ :eachRecord |
		self beginCompensationFor: eachRecord ].
	^ execution
]

{ #category : 'events - error' }
CPExecutionScope >> completeErrorPropagationExecution: anErrorEndEventExecution [
	anErrorEndEventExecution complete.
	parentScope ifNil: [ self error: 'Presumed-abort Error propagation requires a containing execution scope.' ].
	^ parentScope
		propagateErrorOccurrence: anErrorEndEventExecution occurrence
		fromNestedScope: self
		toBoundary: anErrorEndEventExecution boundaryExecution
]

{ #category : 'events - error' }
CPExecutionScope >> completePropagatedErrorExecution: anErrorPropagationExecution [
	anErrorPropagationExecution complete.
	parentScope ifNil: [ self error: 'Presumed-abort Error propagation requires a containing execution scope.' ].
	^ parentScope
		propagateErrorOccurrence: anErrorPropagationExecution occurrence
		fromNestedScope: self
		toBoundary: anErrorPropagationExecution boundaryExecution
]

{ #category : 'events - escalation' }
CPExecutionScope >> waitingEscalationBoundaryExecutionFor: anEscalation attachedTo: anActivityExecution [
	| matches |
	matches := eventExecutions select: [ :eachExecution |
		eachExecution isBoundaryEventExecution
			and: [ eachExecution isWaiting
				and: [ eachExecution attachedActivityExecution == anActivityExecution
					and: [ eachExecution definition catchesEscalation: anEscalation ] ] ] ].
	matches size > 1 ifTrue: [
		self error: 'More than one waiting Escalation Boundary Event matches the propagated Escalation on the same Activity execution.' ].
	^ matches ifEmpty: [ nil ] ifNotEmpty: [ matches first ]
]

{ #category : 'events - escalation' }
CPExecutionScope >> escalationBoundaryExecutionFor: anEscalation propagatingFrom: aNestedScope [
	| boundaryExecution |
	boundaryExecution := self
		waitingEscalationBoundaryExecutionFor: anEscalation
		attachedTo: aNestedScope owningActivity.
	boundaryExecution ifNotNil: [ ^ boundaryExecution ].
	parentScope ifNil: [ ^ nil ].
	^ parentScope
		escalationBoundaryExecutionFor: anEscalation
		propagatingFrom: self
]

{ #category : 'events - escalation' }
CPExecutionScope >> propagateEscalationOccurrence: anOccurrence fromNestedScope: aNestedScope toBoundary: aBoundaryExecution [
	(eventExecutions identityIncludes: aBoundaryExecution) ifTrue: [
		^ self triggerBoundaryEventExecution: aBoundaryExecution with: anOccurrence ].
	parentScope ifNil: [ self error: 'The resolved Escalation Boundary Event is not reachable from this execution scope.' ].
	^ parentScope
		propagateEscalationOccurrence: anOccurrence
		fromNestedScope: self
		toBoundary: aBoundaryExecution
]

{ #category : 'events - escalation' }
CPExecutionScope >> executeEscalationEndEvent: anEscalationEndEvent consuming: anActivation [
	| definitions escalationDefinition thrownEscalation execution boundaryExecution occurrence |
	definitions := anEscalationEndEvent eventDefinitions.
	definitions size = 1 ifFalse: [
		self error: 'An Escalation End Event requires exactly one Escalation Event Definition.' ].
	escalationDefinition := definitions first.
	thrownEscalation := escalationDefinition escalationRef.
	thrownEscalation ifNil: [ self error: 'An Escalation End Event requires an Escalation reference.' ].
	parentScope ifNil: [ self error: 'Uncaught Process-level Escalation End Event execution is not implemented yet.' ].
	boundaryExecution := parentScope
		escalationBoundaryExecutionFor: thrownEscalation
		propagatingFrom: self.
	boundaryExecution ifNil: [
		self error: 'No matching Escalation Boundary Event is waiting in the containing execution hierarchy.' ].
	execution := self executeEndEvent: anEscalationEndEvent consuming: anActivation.
	occurrence := CPExecutionOccurrence new
		occurrenceIdentifier: UUID new asString;
		definition: thrownEscalation;
		yourself.
	parentScope
		propagateEscalationOccurrence: occurrence
		fromNestedScope: self
		toBoundary: boundaryExecution.
	^ execution
]



{ #category : 'data - snapshot' }
CPExecutionScope >> itemValuesSnapshot [
	^ itemValues copy
]

{ #category : 'data - snapshot' }
CPExecutionScope >> restoreItemValuesFromSnapshot: aDictionary [
	itemValues := aDictionary copy.
	itemValueProducers := IdentityDictionary new.
	^ self
]

{ #category : 'activities - compensation' }
CPExecutionScope >> activityExecutionDidComplete: anActivityExecution [
	self ensureCompensationRecordsFor: anActivityExecution.
	self completeCompensationRecordHandledBy: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'activities - compensation' }
CPExecutionScope >> completeCompensationRecordHandledBy: anActivityExecution [
	| handledRecord |
	handledRecord := compensationRecords
		detect: [ :each | (each isHandledByExecution: anActivityExecution) and: [ each isHandling ] ]
		ifNone: [ nil ].
	handledRecord ifNotNil: [
		handledRecord handlerExecutions isEmpty
			ifTrue: [ handledRecord completeHandling ]
			ifFalse: [ handledRecord handlerExecutionDidComplete: anActivityExecution ].
		handledRecord isHandled ifTrue: [ self compensationRecordDidComplete: handledRecord ].
		^ handledRecord ].
	parentScope ifNotNil: [ ^ parentScope completeCompensationRecordHandledBy: anActivityExecution ].
	^ nil
]

{ #category : 'activities - compensation' }
CPExecutionScope >> customCompensationHandlerFor: aCompensationRecord [
	| completedSubProcess handlers startEvents compensationDefinitions |
	aCompensationRecord boundaryEvent ifNotNil: [
		self error: 'A compensation Boundary Event record uses its associated compensation-handler Activity.' ].
	completedSubProcess := aCompensationRecord activityExecution definition.
	handlers := completedSubProcess flowElements select: [ :each |
		each isSubProcess and: [ each isForCompensation ] ].
	handlers size = 1 ifFalse: [
		self error: 'A completed SubProcess with custom compensation requires exactly one Compensation Event SubProcess.' ].
	startEvents := handlers first flowElements select: [ :each | each isStartEvent ].
	startEvents size = 1 ifFalse: [
		self error: 'A Compensation Event SubProcess requires exactly one Start Event.' ].
	compensationDefinitions := startEvents first eventDefinitions select: [ :each | each isCompensationEventDefinition ].
	(startEvents first eventDefinitions size = 1 and: [ compensationDefinitions size = 1 ]) ifFalse: [
		self error: 'A Compensation Event SubProcess Start Event requires exactly one Compensation Event Definition.' ].
	startEvents first incoming isEmpty ifFalse: [
		self error: 'A Compensation Event SubProcess Start Event cannot have incoming Sequence Flow.' ].
	^ handlers first
]

{ #category : 'activities - compensation' }
CPExecutionScope >> ensureCompensationRecordsFor: anActivityExecution [
	| newBoundaries completionSequence record |
	anActivityExecution scope == self ifFalse: [
		self error: 'The completed Activity execution does not belong to this execution scope.' ].
	anActivityExecution isCompleted ifFalse: [
		self error: 'Compensation history can be recorded only for a completed Activity execution.' ].
	anActivityExecution isCompensationEligibleCompletion ifFalse: [ ^ anActivityExecution ].
	"A compensation handler is compensation work, not newly completed normal work.
	 Recording it would make compensation recursively compensate its own handlers."
	anActivityExecution definition isForCompensation ifTrue: [ ^ anActivityExecution ].
	newBoundaries := anActivityExecution definition boundaryEventRefs select: [ :eachBoundary |
		(eachBoundary eventDefinitions anySatisfy: [ :eachDefinition | eachDefinition isCompensationEventDefinition ])
			and: [ compensationRecords noneSatisfy: [ :eachRecord |
				eachRecord activityExecution == anActivityExecution
					and: [ eachRecord boundaryEvent == eachBoundary ] ] ] ].
	(newBoundaries isEmpty and: [ anActivityExecution definition hasEmbeddedCompensationHandler not ]) ifTrue: [
		^ anActivityExecution ].
	completionSequence := self processExecution nextCompensationCompletionSequence.
	newBoundaries
		ifEmpty: [
			record := CPCompensationRecord new
				activityExecution: anActivityExecution;
				completionSequence: completionSequence;
				yourself.
			(anActivityExecution definition loopCharacteristics notNil
				and: [ anActivityExecution definition loopCharacteristics isMultiInstance
				and: [ anActivityExecution definition isSubProcess ] ]) ifTrue: [
				record captureMultiInstanceActivityExecutionsFrom: anActivityExecution ].
			anActivityExecution definition hasCustomCompensationHandler ifTrue: [
				record multiInstanceActivityExecutions isEmpty ifTrue: [
					record captureDataSnapshotFrom: anActivityExecution ] ].
			compensationRecords add: record ]
		ifNotEmpty: [
			newBoundaries do: [ :eachBoundary |
				record := CPCompensationRecord new
					activityExecution: anActivityExecution;
					boundaryEvent: eachBoundary;
					completionSequence: completionSequence;
					yourself.
				(anActivityExecution definition loopCharacteristics notNil
					and: [ anActivityExecution definition loopCharacteristics isMultiInstance
						and: [ anActivityExecution definition isSubProcess ] ]) ifTrue: [
					record captureMultiInstanceActivityExecutionsFrom: anActivityExecution ].
				compensationRecords add: record ] ].
	^ anActivityExecution
]

{ #category : 'activities - compensation' }
CPExecutionScope >> availableCompensationRecords [
	^ compensationRecords select: [ :each | each isAvailable ]
]

{ #category : 'activities - compensation' }
CPExecutionScope >> availableCompensationRecordsFor: anActivity [
	^ self availableCompensationRecords select: [ :each |
		each activityExecution definition == anActivity ]
]

{ #category : 'activities - compensation' }
CPExecutionScope >> allAvailableCompensationRecords [
	| records |
	records := self availableCompensationRecords asOrderedCollection.
	childScopes do: [ :eachScope |
		records addAll: eachScope allAvailableCompensationRecords ].
	^ records
]

{ #category : 'activities - compensation' }
CPExecutionScope >> allAvailableCompensationRecordsFor: anActivity [
	^ self allAvailableCompensationRecords select: [ :each |
		each activityExecution definition == anActivity ]
]


{ #category : 'activities - compensation' }
CPExecutionScope >> allAvailableCompensationRecordsInReverseCompletionOrder [
	^ self allAvailableCompensationRecords sorted: [ :earlier :later |
		earlier completionSequence > later completionSequence ]
]

{ #category : 'activities - compensation' }
CPExecutionScope >> claimCompensationRecord: aCompensationRecord [
	(compensationRecords identityIncludes: aCompensationRecord) ifFalse: [
		self error: 'The compensation record does not belong to this execution scope.' ].
	aCompensationRecord activityExecution scope == self ifFalse: [
		self error: 'The compensation record Activity execution does not belong to this execution scope.' ].
	^ aCompensationRecord claim
]

{ #category : 'activities - compensation' }
CPExecutionScope >> compensationHandlerFor: aCompensationRecord [
	| completedActivity container associations handlers |
	aCompensationRecord boundaryEvent ifNil: [
		self error: 'Only a compensation Boundary Event record resolves an associated compensation-handler Activity.' ].
	completedActivity := aCompensationRecord activityExecution definition.
	container := completedActivity container.
	container ifNil: [
		self error: 'A compensatable Activity must belong to a BPMN flow-elements container.' ].
	associations := container artifacts select: [ :each |
		each isAssociation and: [ each sourceRef == aCompensationRecord boundaryEvent ] ].
	handlers := associations collect: [ :each | each targetRef ].
	(handlers size = 1
		and: [ handlers first isActivity
		and: [ handlers first isForCompensation ] ]) ifFalse: [
		self error: 'A compensation Boundary Event must resolve to exactly one compensation-handler Activity.' ].
	^ handlers first
]

{ #category : 'activities - compensation' }
CPExecutionScope >> allFlowActivations [
	| activations |
	activations := flowActivations asOrderedCollection.
	childScopes do: [ :eachScope |
		activations addAll: eachScope allFlowActivations ].
	^ activations
]

{ #category : 'activities - compensation' }
CPExecutionScope >> allBoundaryEventExecutions [
	| executions |
	executions := eventExecutions
		select: [ :eachExecution | eachExecution isBoundaryEventExecution ]
		thenCollect: [ :eachExecution | eachExecution ].
	childScopes do: [ :eachScope |
		executions addAll: eachScope allBoundaryEventExecutions ].
	^ executions
]

{ #category : 'activities - compensation' }
CPExecutionScope >> flowActivation: anActivation wasProducedByActivityExecution: anActivityExecution [
	anActivation producedBy == anActivityExecution ifTrue: [ ^ true ].
	^ self allBoundaryEventExecutions anySatisfy: [ :eachExecution |
		eachExecution == anActivation producedBy
			and: [ eachExecution attachedActivityExecution == anActivityExecution ] ]
]

{ #category : 'activities - compensation' }
CPExecutionScope >> compensationRecord: aRecord mustPrecede: anotherRecord [
	(aRecord activityExecution hasDataDependencyOn: anotherRecord activityExecution) ifTrue: [ ^ true ].
	^ self allFlowActivations anySatisfy: [ :activation |
		(self
			flowActivation: activation
			wasProducedByActivityExecution: anotherRecord activityExecution)
			and: [ activation consumedBy == aRecord activityExecution ] ]
]

{ #category : 'activities - compensation' }
CPExecutionScope >> readyDefaultCompensationRecordsIn: compensationRecordCollection [
	^ compensationRecordCollection select: [ :candidate |
		(compensationRecordCollection anySatisfy: [ :other |
			other ~~ candidate and: [ self compensationRecord: other mustPrecede: candidate ] ]) not ]
]

{ #category : 'activities - compensation' }
CPExecutionScope >> nextDefaultCompensationRecordFrom: readyCompensationRecords [
	| next |
	readyCompensationRecords isEmpty ifTrue: [
		self error: 'Default compensation requires at least one ready compensation record.' ].
	next := readyCompensationRecords first.
	readyCompensationRecords do: [ :candidate |
		candidate completionSequence > next completionSequence ifTrue: [ next := candidate ] ].
	^ next
]

{ #category : 'activities - compensation' }
CPExecutionScope >> orderDefaultCompensationRecords: compensationRecordCollection [
	| remaining ordered ready next |
	remaining := compensationRecordCollection asOrderedCollection.
	ordered := OrderedCollection new.
	[ remaining isEmpty ] whileFalse: [
		ready := self readyDefaultCompensationRecordsIn: remaining.
		ready isEmpty ifTrue: [
			self error: 'Default compensation dependencies contain a cycle.' ].
		next := self nextDefaultCompensationRecordFrom: ready.
		ordered add: next.
		remaining remove: next ].
	^ ordered
]

{ #category : 'activities - compensation' }
CPExecutionScope >> defaultCompensationRecords [
	| records |
	records := self availableCompensationRecords asOrderedCollection.
	childScopes do: [ :eachScope |
		(compensationRecords anySatisfy: [ :eachRecord | eachRecord activityExecution == eachScope owningActivity ]) ifFalse: [
			records addAll: eachScope defaultCompensationRecords ] ].
	^ self orderDefaultCompensationRecords: records
]

{ #category : 'activities - compensation' }
CPExecutionScope >> validateCompensationRecord: aCompensationRecord [
	| definition nestedRecords |
	(compensationRecords identityIncludes: aCompensationRecord) ifFalse: [
		self error: 'The compensation record does not belong to this execution scope.' ].
	aCompensationRecord isAvailable ifFalse: [
		self error: 'Only an available compensation record can begin compensation.' ].
	aCompensationRecord boundaryEvent ifNotNil: [
		self compensationHandlerFor: aCompensationRecord.
		^ aCompensationRecord ].
	definition := aCompensationRecord activityExecution definition.
	definition usesDefaultCompensationHandler ifTrue: [
		aCompensationRecord activityExecution subScope ifNil: [
			self error: 'Default SubProcess compensation requires the exact completed SubProcess execution scope.' ].
		nestedRecords := aCompensationRecord activityExecution subScope defaultCompensationRecords.
		nestedRecords do: [ :eachRecord |
			eachRecord activityExecution scope validateCompensationRecord: eachRecord ].
		^ aCompensationRecord ].
	definition hasCustomCompensationHandler ifTrue: [
		self customCompensationHandlerFor: aCompensationRecord.
		^ aCompensationRecord ].
	self error: 'The compensation record has no BPMN compensation handler.'
]

{ #category : 'activities - compensation' }
CPExecutionScope >> beginCompensationFor: aCompensationRecord [
	| owningScope handler handlerExecution nestedRecords claimedRecord |
	owningScope := aCompensationRecord activityExecution scope.
	"keep the exact execution scope as the authority for this record"
	owningScope ifNil: [
		self error: 'A compensation record requires its completed Activity execution to belong to an execution scope.' ].
	owningScope validateCompensationRecord: aCompensationRecord.
	claimedRecord := owningScope claimCompensationRecord: aCompensationRecord.
	claimedRecord boundaryEvent ifNotNil: [
		handler := owningScope compensationHandlerFor: claimedRecord.
		claimedRecord multiInstanceActivityExecutions ifNotEmpty: [
			| handlerExecutions |
			handlerExecutions := claimedRecord multiInstanceActivityExecutions collect: [ :eachInstance |
				owningScope createActivityExecutionFor: handler ].
			claimedRecord beginHandlingWithAll: handlerExecutions.
			handlerExecutions do: [ :eachExecution | eachExecution activate ].
			^ handlerExecutions ].
		handlerExecution := owningScope createActivityExecutionFor: handler.
		claimedRecord beginHandlingWith: handlerExecution.
		handlerExecution activate.
		^ handlerExecution ].
	claimedRecord activityExecution definition hasCustomCompensationHandler ifTrue: [
		handler := owningScope customCompensationHandlerFor: claimedRecord.
		claimedRecord multiInstanceActivityExecutions ifNotEmpty: [
			| handlerExecutions |
			handlerExecutions := claimedRecord multiInstanceActivityExecutions collect: [ :eachInstance |
				eachInstance restoreCompensationDataSnapshot.
				eachInstance subScope createActivityExecutionFor: handler ].
			claimedRecord beginHandlingWithAll: handlerExecutions.
			1 to: claimedRecord multiInstanceActivityExecutions size do: [ :index |
				(claimedRecord multiInstanceActivityExecutions at: index) subScope
					activateCompensationSubProcessExecution: (handlerExecutions at: index) ].
			^ handlerExecutions ].
		claimedRecord restoreDataSnapshot.
		handlerExecution := claimedRecord activityExecution subScope createActivityExecutionFor: handler.
		claimedRecord beginHandlingWith: handlerExecution.
		claimedRecord activityExecution subScope activateCompensationSubProcessExecution: handlerExecution.
		^ handlerExecution ].
	nestedRecords := claimedRecord activityExecution subScope defaultCompensationRecords.
	claimedRecord beginHandling.
	claimedRecord compensationRecords: nestedRecords.
	nestedRecords ifEmpty: [
		claimedRecord completeHandling.
		owningScope compensationRecordDidComplete: claimedRecord.
		^ claimedRecord ].
	(claimedRecord activityExecution subScope readyDefaultCompensationRecordsIn: nestedRecords) do: [ :eachRecord |
		self beginCompensationFor: eachRecord ].
	^ claimedRecord
]

{ #category : 'activities - compensation' }
CPExecutionScope >> beginDetachedCompensationFor: compensationRecordCollection [
	| execution |
	compensationRecordCollection ifEmpty: [ ^ nil ].
	execution := CPCompensationExecution new
		scope: self;
		compensationRecords: compensationRecordCollection;
		yourself.
	eventExecutions add: execution.
	(self readyDefaultCompensationRecordsIn: compensationRecordCollection) do: [ :eachRecord |
		self beginCompensationFor: eachRecord ].
	^ execution
]

{ #category : 'events - compensation' }
CPExecutionScope >> executeCompensationThrowEvent: aCompensationThrowEvent consuming: anActivation [
	| definitions compensationDefinition targetActivity records record throwExecution handlerExecution |
	(anActivation isAvailable and: [ aCompensationThrowEvent incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'A Compensation Intermediate Throw Event requires an available activation from one of its incoming Sequence Flows.' ].
	definitions := aCompensationThrowEvent eventDefinitions select: [ :each | each isCompensationEventDefinition ].
	definitions size = 1 ifFalse: [
		self error: 'A Compensation Intermediate Throw Event requires exactly one Compensation Event Definition.' ].
	compensationDefinition := definitions first.
	targetActivity := compensationDefinition activityRef.
	targetActivity
		ifNil: [
			records := self defaultCompensationRecords.
			"Resolve every handler before consuming control flow so an invalid compensation model cannot partially execute."
			records do: [ :eachRecord |
				eachRecord activityExecution scope validateCompensationRecord: eachRecord ] ]
		ifNotNil: [
			records := self allAvailableCompensationRecordsFor: targetActivity.
			records size = 1 ifFalse: [
				self error: 'Targeted compensation must resolve to exactly one available completed Activity execution.' ].
			record := records first.
			"Resolve the handler before consuming control flow so an invalid compensation model cannot partially execute."
			record activityExecution scope validateCompensationRecord: record ].
	throwExecution := CPCompensationThrowEventExecution new
		definition: aCompensationThrowEvent;
		scope: self;
		yourself.
	eventExecutions add: throwExecution.
	throwExecution consumeFlowActivation: anActivation.
	compensationDefinition waitForCompletion
		ifTrue: [
			targetActivity
				ifNil: [
					records
						ifEmpty: [ self completeIntermediateThrowEventExecution: throwExecution ]
						ifNotEmpty: [
							throwExecution compensationRecords: records.
							(self readyDefaultCompensationRecordsIn: records) do: [ :eachRecord |
								self beginCompensationFor: eachRecord ] ] ]
				ifNotNil: [
					throwExecution compensationRecord: record.
					handlerExecution := self beginCompensationFor: record ] ]
		ifFalse: [
			targetActivity
				ifNil: [ self beginDetachedCompensationFor: records ]
				ifNotNil: [ handlerExecution := self beginCompensationFor: record ].
			self completeIntermediateThrowEventExecution: throwExecution ].
	^ throwExecution
]



{ #category : 'events - compensation' }
CPExecutionScope >> executeCompensationEndEvent: aCompensationEndEvent consuming: anActivation [
	| definitions compensationDefinition targetActivity records record endExecution handlerExecution |
	aCompensationEndEvent outgoing isEmpty ifFalse: [
		self error: 'A Compensation End Event cannot produce outgoing Sequence Flow.' ].
	(anActivation isAvailable and: [ aCompensationEndEvent incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'A Compensation End Event requires an available activation from one of its incoming Sequence Flows.' ].
	definitions := aCompensationEndEvent eventDefinitions select: [ :each | each isCompensationEventDefinition ].
	definitions size = 1 ifFalse: [
		self error: 'A Compensation End Event requires exactly one Compensation Event Definition.' ].
	compensationDefinition := definitions first.
	targetActivity := compensationDefinition activityRef.
	targetActivity
		ifNil: [
			records := self defaultCompensationRecords.
			records do: [ :eachRecord |
				eachRecord activityExecution scope validateCompensationRecord: eachRecord ] ]
		ifNotNil: [
			records := self allAvailableCompensationRecordsFor: targetActivity.
			records size = 1 ifFalse: [
				self error: 'Targeted compensation must resolve to exactly one available completed Activity execution.' ].
			record := records first.
			record activityExecution scope validateCompensationRecord: record ].
	endExecution := CPCompensationThrowEventExecution new
		definition: aCompensationEndEvent;
		scope: self;
		yourself.
	eventExecutions add: endExecution.
	endExecution consumeFlowActivation: anActivation.
	compensationDefinition waitForCompletion
		ifTrue: [
			targetActivity
				ifNil: [
					records
						ifEmpty: [ self completeIntermediateThrowEventExecution: endExecution ]
						ifNotEmpty: [
							endExecution compensationRecords: records.
							(self readyDefaultCompensationRecordsIn: records) do: [ :eachRecord |
								self beginCompensationFor: eachRecord ] ] ]
				ifNotNil: [
					endExecution compensationRecord: record.
					handlerExecution := self beginCompensationFor: record ] ]
		ifFalse: [
			targetActivity
				ifNil: [ self beginDetachedCompensationFor: records ]
				ifNotNil: [ handlerExecution := self beginCompensationFor: record ].
			self completeIntermediateThrowEventExecution: endExecution ].
	^ endExecution
]

{ #category : 'events - compensation' }
CPExecutionScope >> compensationRecordDidComplete: aCompensationRecord [
	| completedOuterRecord |
	eventExecutions do: [ :eachExecution |
		eachExecution isCompensationExecution ifTrue: [
			(eachExecution isWaitingForCompensationRecord: aCompensationRecord) ifTrue: [
				| remaining ready |
				remaining := eachExecution compensationRecords reject: [ :each | each isHandled ].
				remaining
					ifEmpty: [ eachExecution complete ]
					ifNotEmpty: [
						ready := self readyDefaultCompensationRecordsIn: remaining.
						ready do: [ :eachRecord |
							eachRecord isAvailable ifTrue: [ self beginCompensationFor: eachRecord ] ] ].
				^ aCompensationRecord ] ] ].
	eventExecutions do: [ :eachExecution |
		(eachExecution isCompensationThrowEventExecution) ifTrue: [
			(eachExecution isWaitingForCompensationRecord: aCompensationRecord) ifTrue: [
				| remaining ready |
				remaining := eachExecution compensationRecords reject: [ :each | each isHandled ].
				remaining
					ifEmpty: [ self completeIntermediateThrowEventExecution: eachExecution ]
					ifNotEmpty: [
						ready := self readyDefaultCompensationRecordsIn: remaining.
						ready do: [ :eachRecord |
							eachRecord isAvailable ifTrue: [ self beginCompensationFor: eachRecord ] ] ] ] ] ].
	eventExecutions do: [ :eachExecution |
		(eachExecution isErrorEndEventExecution) ifTrue: [
			(eachExecution isWaitingForCompensationRecord: aCompensationRecord) ifTrue: [
				| remaining ready |
				remaining := eachExecution compensationRecords reject: [ :each | each isHandled ].
				remaining
					ifEmpty: [ self completeErrorPropagationExecution: eachExecution ]
					ifNotEmpty: [
						ready := self readyDefaultCompensationRecordsIn: remaining.
						ready do: [ :eachRecord |
							eachRecord isAvailable ifTrue: [ self beginCompensationFor: eachRecord ] ] ].
				^ aCompensationRecord ] ] ].
	eventExecutions do: [ :eachExecution |
		(eachExecution isErrorPropagationExecution) ifTrue: [
			(eachExecution isWaitingForCompensationRecord: aCompensationRecord) ifTrue: [
				| remaining ready |
				remaining := eachExecution compensationRecords reject: [ :each | each isHandled ].
				remaining
					ifEmpty: [ self completePropagatedErrorExecution: eachExecution ]
					ifNotEmpty: [
						ready := self readyDefaultCompensationRecordsIn: remaining.
						ready do: [ :eachRecord |
							eachRecord isAvailable ifTrue: [ self beginCompensationFor: eachRecord ] ] ].
				^ aCompensationRecord ] ] ].
	completedOuterRecord := compensationRecords
		detect: [ :eachRecord | eachRecord isWaitingForCompensationRecord: aCompensationRecord ]
		ifNone: [ nil ].
	completedOuterRecord ifNotNil: [
		| remaining ready nestedScope |
		remaining := completedOuterRecord compensationRecords reject: [ :each | each isHandled ].
		remaining
			ifEmpty: [
				completedOuterRecord completeHandling.
				self compensationRecordDidComplete: completedOuterRecord ]
			ifNotEmpty: [
				nestedScope := completedOuterRecord activityExecution subScope.
				ready := nestedScope readyDefaultCompensationRecordsIn: remaining.
				ready do: [ :eachRecord |
					eachRecord isAvailable ifTrue: [ self beginCompensationFor: eachRecord ] ] ].
		^ aCompensationRecord ].
	parentScope ifNotNil: [ parentScope compensationRecordDidComplete: aCompensationRecord ].
	^ aCompensationRecord
]


{ #category : 'activities - standard loop' }
CPExecutionScope >> activateStandardLoopExecution: anActivityExecution [
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Standard Loop Activity execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Standard Loop Activity execution can become Active.' ].
	anActivityExecution definition loopCharacteristics ifNil: [
		self error: 'The Activity has no loop characteristics.' ].
	anActivityExecution definition loopCharacteristics isStandardLoop ifFalse: [
		self error: 'The Activity does not have BPMN Standard Loop characteristics.' ].
	(anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
	anActivityExecution activate.
	anActivityExecution standardLoopMayBeginNextIteration
		ifTrue: [ anActivityExecution beginStandardLoopIteration ]
		ifFalse: [ self completeStandardLoopExecution: anActivityExecution ].
	^ anActivityExecution
]

{ #category : 'activities - standard loop' }
CPExecutionScope >> completeStandardLoopIteration: anIteration of: anActivityExecution [
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Standard Loop Activity execution does not belong to this execution scope.' ].
	anIteration activityExecution == anActivityExecution ifFalse: [
		self error: 'The Standard Loop iteration belongs to another Activity execution.' ].
	anActivityExecution completeStandardLoopIteration: anIteration.
	anActivityExecution standardLoopMayBeginNextIteration
		ifTrue: [ anActivityExecution beginStandardLoopIteration ]
		ifFalse: [ self completeStandardLoopExecution: anActivityExecution ].
	^ anActivityExecution
]

{ #category : 'activities - standard loop' }
CPExecutionScope >> completeStandardLoopExecution: anActivityExecution [
	anActivityExecution isActive ifFalse: [
		self error: 'Only an Active Standard Loop Activity execution can complete.' ].
	anActivityExecution activeStandardLoopIteration ifNotNil: [
		self error: 'A Standard Loop Activity cannot complete while an iteration remains active.' ].
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]


{ #category : 'building' }
CPExecutionScope >> createSendTaskExecutionFor: aSendTask [
	^ self addActivityExecution: (CPSendTaskExecution new
		definition: aSendTask;
		yourself)
]

{ #category : 'activities - send' }
CPExecutionScope >> activateSendTaskExecution: anActivityExecution [
	| loop |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Send Task execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Send Task execution can become Active.' ].
	anActivityExecution definition messageRef ifNil: [
		self error: 'A Send Task requires a Message.' ].
	(anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
	anActivityExecution activate.
	loop := anActivityExecution definition loopCharacteristics.
	(loop notNil and: [ loop isMultiInstance ]) ifTrue: [
		anActivityExecution beginMultiInstanceActivityExecutions.
		^ anActivityExecution ].
	(loop notNil and: [ loop isStandardLoop ]) ifTrue: [
		anActivityExecution standardLoopMayBeginNextIteration
			ifTrue: [ anActivityExecution beginStandardLoopIteration ]
			ifFalse: [ self completeStandardLoopExecution: anActivityExecution ].
		^ anActivityExecution ].
	anActivityExecution prepareMessageDispatch.
	^ anActivityExecution
]

{ #category : 'activities - send' }
CPExecutionScope >> completeSendTaskExecution: anActivityExecution [
	| dispatch |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Send Task execution does not belong to this execution scope.' ].
	anActivityExecution isActive ifFalse: [
		self error: 'Only an Active Send Task execution can complete its Message dispatch.' ].
	dispatch := anActivityExecution messageDispatch.
	dispatch ifNil: [ self error: 'The Send Task has no pending Message dispatch.' ].
	dispatch isPending ifFalse: [ self error: 'The Send Task Message has already been sent.' ].
	dispatch markSent.
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'activities - send' }
CPExecutionScope >> completeMultiInstanceSendTaskExecution: anInstance [
	| dispatch outerExecution |
	outerExecution := anInstance activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Multi-Instance Send Task instance does not belong to this execution scope.' ].
	(outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
		self error: 'The Multi-Instance Send Task instance does not belong to its outer Activity execution.' ].
	anInstance isActive ifFalse: [
		self error: 'Only an active Multi-Instance Send Task instance can complete its Message dispatch.' ].
	dispatch := anInstance messageDispatch.
	dispatch ifNil: [ self error: 'The Multi-Instance Send Task instance has no pending Message dispatch.' ].
	dispatch isPending ifFalse: [ self error: 'The Multi-Instance Send Task Message has already been sent.' ].
	dispatch markSent.
	anInstance complete.
	^ anInstance
]


{ #category : 'building' }
CPExecutionScope >> createScriptTaskExecutionFor: aScriptTask [
	^ self addActivityExecution: (CPScriptTaskExecution new
		definition: aScriptTask;
		yourself)
]

{ #category : 'activities - script' }
CPExecutionScope >> activateScriptTaskExecution: anActivityExecution [
	| scriptTask loop |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Script Task execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Script Task execution can become Active.' ].
	scriptTask := anActivityExecution definition.
	scriptTask script ifNotNil: [
		scriptTask scriptFormat ifNil: [
			self error: 'A Script Task with a script requires a scriptFormat.' ] ].
	(anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
	anActivityExecution activate.
	loop := scriptTask loopCharacteristics.
	(loop notNil and: [ loop isMultiInstance ]) ifTrue: [
		anActivityExecution beginMultiInstanceActivityExecutions.
		^ anActivityExecution ].
	(loop notNil and: [ loop isStandardLoop ]) ifTrue: [
		anActivityExecution standardLoopMayBeginNextIteration
			ifTrue: [ anActivityExecution beginStandardLoopIteration ]
			ifFalse: [ self completeStandardLoopExecution: anActivityExecution ].
		^ anActivityExecution ].
	self environment
		executeScriptTask: scriptTask
		in: self
		forActivityExecution: anActivityExecution.
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'activities - script' }
CPExecutionScope >> executeStandardLoopScriptTaskIteration: anIteration [
	| outerExecution |
	outerExecution := anIteration activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Standard Loop Script Task iteration does not belong to this execution scope.' ].
	(outerExecution standardLoopIterations identityIncludes: anIteration) ifFalse: [
		self error: 'The Standard Loop Script Task iteration does not belong to its outer Activity execution.' ].
	anIteration isActive ifFalse: [
		self error: 'Only an active Standard Loop Script Task iteration can execute its script.' ].
	self environment
		executeScriptTask: outerExecution definition
		in: self
		forActivityExecution: outerExecution.
	self completeStandardLoopIteration: anIteration of: outerExecution.
	^ anIteration
]

{ #category : 'activities - script' }
CPExecutionScope >> executeMultiInstanceScriptTaskExecution: anInstance [
	| outerExecution |
	outerExecution := anInstance activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Multi-Instance Script Task instance does not belong to this execution scope.' ].
	(outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
		self error: 'The Multi-Instance Script Task instance does not belong to its outer Activity execution.' ].
	anInstance isActive ifFalse: [
		self error: 'Only an active Multi-Instance Script Task instance can execute its script.' ].
	self environment
		executeScriptTask: outerExecution definition
		in: self
		forActivityExecution: anInstance.
	anInstance complete.
	^ anInstance
]

{ #category : 'building' }
CPExecutionScope >> createBusinessRuleTaskExecutionFor: aBusinessRuleTask [
	^ self addActivityExecution: (CPBusinessRuleTaskExecution new
		definition: aBusinessRuleTask;
		yourself)
]

{ #category : 'activities - business rule' }
CPExecutionScope >> activateBusinessRuleTaskExecution: anActivityExecution [
	| businessRuleTask loop |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Business Rule Task execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Business Rule Task execution can become Active.' ].
	(anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
	anActivityExecution activate.
	businessRuleTask := anActivityExecution definition.
	loop := businessRuleTask loopCharacteristics.
	(loop notNil and: [ loop isMultiInstance ]) ifTrue: [
		anActivityExecution beginMultiInstanceActivityExecutions.
		^ anActivityExecution ].
	(loop notNil and: [ loop isStandardLoop ]) ifTrue: [
		anActivityExecution standardLoopMayBeginNextIteration
			ifTrue: [ anActivityExecution beginStandardLoopIteration ]
			ifFalse: [ self completeStandardLoopExecution: anActivityExecution ].
		^ anActivityExecution ].
	self environment
		executeBusinessRuleTask: businessRuleTask
		in: self
		forActivityExecution: anActivityExecution.
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'activities - business rule' }
CPExecutionScope >> executeStandardLoopBusinessRuleTaskIteration: anIteration [
	| outerExecution |
	outerExecution := anIteration activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Standard Loop Business Rule Task iteration does not belong to this execution scope.' ].
	(outerExecution standardLoopIterations identityIncludes: anIteration) ifFalse: [
		self error: 'The Standard Loop Business Rule Task iteration does not belong to its outer Activity execution.' ].
	anIteration isActive ifFalse: [
		self error: 'Only an active Standard Loop Business Rule Task iteration can execute its business rule.' ].
	self environment
		executeBusinessRuleTask: outerExecution definition
		in: self
		forActivityExecution: outerExecution.
	self completeStandardLoopIteration: anIteration of: outerExecution.
	^ anIteration
]

{ #category : 'activities - business rule' }
CPExecutionScope >> executeMultiInstanceBusinessRuleTaskExecution: anInstance [
	| outerExecution |
	outerExecution := anInstance activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Multi-Instance Business Rule Task instance does not belong to this execution scope.' ].
	(outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
		self error: 'The Multi-Instance Business Rule Task instance does not belong to its outer Activity execution.' ].
	anInstance isActive ifFalse: [
		self error: 'Only an active Multi-Instance Business Rule Task instance can execute its business rule.' ].
	self environment
		executeBusinessRuleTask: outerExecution definition
		in: self
		forActivityExecution: anInstance.
	anInstance complete.
	^ anInstance
]


{ #category : 'building' }
CPExecutionScope >> createUserTaskExecutionFor: aUserTask [
    ^ self addActivityExecution: (CPUserTaskExecution new
        definition: aUserTask;
        yourself)
]

{ #category : 'activities - user' }
CPExecutionScope >> activateUserTaskExecution: anActivityExecution [
    | userTask loop workItem |
    (activityExecutions identityIncludes: anActivityExecution) ifFalse: [
        self error: 'The User Task execution does not belong to this execution scope.' ].
    anActivityExecution isReady ifFalse: [
        self error: 'Only a Ready User Task execution can become Active.' ].
    userTask := anActivityExecution definition.
    self validateResourceAssignmentsFor: userTask.
    (anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
    anActivityExecution activate.
    loop := userTask loopCharacteristics.
    (loop notNil and: [ loop isMultiInstance ]) ifTrue: [
        anActivityExecution beginMultiInstanceActivityExecutions.
        ^ anActivityExecution ].
    (loop notNil and: [ loop isStandardLoop ]) ifTrue: [
        anActivityExecution standardLoopMayBeginNextIteration
            ifTrue: [ anActivityExecution beginStandardLoopIteration ]
            ifFalse: [ self completeStandardLoopExecution: anActivityExecution ].
        ^ anActivityExecution ].
    workItem := CPUserTaskWorkItem new
        userTask: userTask;
        activityExecution: anActivityExecution;
        resourceAssignments: (self resourceAssignmentsFor: userTask activityExecution: anActivityExecution);
        yourself.
    anActivityExecution workItem: workItem.
    self environment distributeUserTaskWorkItem: workItem in: self.
    workItem markDistributed.
    ^ anActivityExecution
]

{ #category : 'activities - user' }
CPExecutionScope >> completeUserTaskExecution: anActivityExecution [
    | workItem |
    anActivityExecution scope == self ifFalse: [
        self error: 'The User Task execution does not belong to this execution scope.' ].
    anActivityExecution isActive ifFalse: [
        self error: 'Only an active User Task execution can complete.' ].
    workItem := anActivityExecution workItem.
    workItem ifNil: [ self error: 'The User Task execution has no distributed work item.' ].
    workItem isPending ifFalse: [ self error: 'The User Task work item is not pending.' ].
    workItem complete.
    anActivityExecution beginCompletion.
    anActivityExecution complete.
    self produceOutgoingControlFor: anActivityExecution.
    ^ anActivityExecution
]

{ #category : 'activities - user' }
CPExecutionScope >> distributeMultiInstanceUserTaskExecution: anInstance [
    | outerExecution workItem |
    outerExecution := anInstance activityExecution.
    outerExecution scope == self ifFalse: [
        self error: 'The Multi-Instance User Task instance does not belong to this execution scope.' ].
    (outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
        self error: 'The Multi-Instance User Task instance does not belong to its outer Activity execution.' ].
    anInstance isActive ifFalse: [
        self error: 'Only an active Multi-Instance User Task instance can distribute work.' ].
    workItem := CPUserTaskWorkItem new
        userTask: outerExecution definition;
        activityExecution: anInstance;
        resourceAssignments: (self resourceAssignmentsFor: outerExecution definition activityExecution: anInstance);
        yourself.
    anInstance userTaskWorkItem: workItem.
    self environment distributeUserTaskWorkItem: workItem in: self.
    workItem markDistributed.
    ^ workItem
]

{ #category : 'activities - user' }
CPExecutionScope >> completeMultiInstanceUserTaskExecution: anInstance [
    | outerExecution workItem |
    outerExecution := anInstance activityExecution.
    outerExecution scope == self ifFalse: [
        self error: 'The Multi-Instance User Task instance does not belong to this execution scope.' ].
    (outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
        self error: 'The Multi-Instance User Task instance does not belong to its outer Activity execution.' ].
    anInstance isActive ifFalse: [
        self error: 'Only an active Multi-Instance User Task instance can complete.' ].
    workItem := anInstance userTaskWorkItem.
    workItem ifNil: [ self error: 'The Multi-Instance User Task instance has no distributed work item.' ].
    workItem isPending ifFalse: [ self error: 'The Multi-Instance User Task work item is not pending.' ].
    workItem complete.
    anInstance complete.
    ^ anInstance
]


{ #category : 'resources' }
CPExecutionScope >> validateResourceAssignmentsFor: anActivity [
	anActivity resources do: [ :resourceRole |
		resourceRole hasValidAssignment ifFalse: [
			self error: 'A ResourceRole must use either a Resource reference or a ResourceAssignmentExpression, and parameter bindings require a Resource reference.' ].
		resourceRole hasValidResourceParameterBindings ifFalse: [
			self error: 'Each ResourceParameterBinding must reference a parameter defined by the Resource and must contain an Expression.' ].
		(resourceRole usesResourceAssignmentExpression
			and: [ resourceRole resourceAssignmentExpression expression isNil ]) ifTrue: [
			self error: 'A ResourceAssignmentExpression requires an Expression.' ] ].
	^ anActivity
]

{ #category : 'resources' }
CPExecutionScope >> resourceAssignmentsFor: anActivity activityExecution: anActivityExecution [
	^ anActivity resources collect: [ :resourceRole |
		CPResourceRoleAssignment new
			role: resourceRole;
			resources: (self resourcesForRole: resourceRole activityExecution: anActivityExecution);
			yourself ]
]

{ #category : 'resources' }
CPExecutionScope >> resourcesForRole: aResourceRole activityExecution: anActivityExecution [
	| assignmentExpression parameterValues |
	aResourceRole hasValidAssignment ifFalse: [
		self error: 'A ResourceRole must use either a Resource reference or a ResourceAssignmentExpression, and parameter bindings require a Resource reference.' ].
	aResourceRole hasValidResourceParameterBindings ifFalse: [
		self error: 'Each ResourceParameterBinding must reference a parameter defined by the Resource and must contain an Expression.' ].
	aResourceRole usesResourceAssignmentExpression ifTrue: [
		assignmentExpression := aResourceRole resourceAssignmentExpression expression.
		assignmentExpression ifNil: [ self error: 'A ResourceAssignmentExpression requires an Expression.' ].
		^ (self environment
			evaluateExpression: assignmentExpression
			in: self
			forActivityExecution: anActivityExecution) asOrderedCollection ].
	aResourceRole usesResourceReference ifFalse: [ ^ #() ].
	parameterValues := aResourceRole resourceParameterBindings collect: [ :binding |
		CPResourceParameterValue new
			parameter: binding parameterRef;
			value: (self environment
				evaluateExpression: binding expression
				in: self
				forActivityExecution: anActivityExecution);
			yourself ].
	^ self environment
		resolveResource: aResourceRole resourceRef
		parameterValues: parameterValues
		in: self
		forActivityExecution: anActivityExecution
]

{ #category : 'building' }
CPExecutionScope >> createTaskExecutionFor: aTask [
	^ self addActivityExecution: (CPTaskExecution new
		definition: aTask;
		yourself)
]

{ #category : 'activities - abstract task' }
CPExecutionScope >> activateTaskExecution: anActivityExecution [
	| task loop |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Abstract Task execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Abstract Task execution can become Active.' ].
	(anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
	anActivityExecution activate.
	task := anActivityExecution definition.
	loop := task loopCharacteristics.
	(loop notNil and: [ loop isMultiInstance ]) ifTrue: [
		anActivityExecution beginMultiInstanceActivityExecutions.
		^ anActivityExecution ].
	(loop notNil and: [ loop isStandardLoop ]) ifTrue: [
		anActivityExecution standardLoopMayBeginNextIteration
			ifTrue: [ anActivityExecution beginStandardLoopIteration ]
			ifFalse: [ self completeStandardLoopExecution: anActivityExecution ].
		^ anActivityExecution ].
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'activities - abstract task' }
CPExecutionScope >> completeMultiInstanceAbstractTaskExecution: anInstance [
	| outerExecution |
	outerExecution := anInstance activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Multi-Instance Abstract Task instance does not belong to this execution scope.' ].
	(outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
		self error: 'The Multi-Instance Abstract Task instance does not belong to its outer Activity execution.' ].
	anInstance isActive ifFalse: [
		self error: 'Only an active Multi-Instance Abstract Task instance can complete.' ].
	anInstance complete.
	^ anInstance
]

{ #category : 'building' }
CPExecutionScope >> createManualTaskExecutionFor: aManualTask [
	^ self addActivityExecution: (CPManualTaskExecution new
		definition: aManualTask;
		yourself)
]

{ #category : 'activities - manual' }
CPExecutionScope >> activateManualTaskExecution: anActivityExecution [
	| manualTask loop |
	(activityExecutions identityIncludes: anActivityExecution) ifFalse: [
		self error: 'The Manual Task execution does not belong to this execution scope.' ].
	anActivityExecution isReady ifFalse: [
		self error: 'Only a Ready Manual Task execution can become Active.' ].
	manualTask := anActivityExecution definition.
	self validateResourceAssignmentsFor: manualTask.
	(anActivityExecution prepareForActivation) ifFalse: [ ^ false ].
	anActivityExecution activate.
	loop := manualTask loopCharacteristics.
	(loop notNil and: [ loop isMultiInstance ]) ifTrue: [
		anActivityExecution beginMultiInstanceActivityExecutions.
		^ anActivityExecution ].
	(loop notNil and: [ loop isStandardLoop ]) ifTrue: [
		anActivityExecution standardLoopMayBeginNextIteration
			ifTrue: [ anActivityExecution beginStandardLoopIteration ]
			ifFalse: [ self completeStandardLoopExecution: anActivityExecution ].
		^ anActivityExecution ].
	anActivityExecution resourceAssignments:
		(self resourceAssignmentsFor: manualTask activityExecution: anActivityExecution).
	^ anActivityExecution
]

{ #category : 'activities - manual' }
CPExecutionScope >> completeManualTaskExecution: anActivityExecution [
	anActivityExecution scope == self ifFalse: [
		self error: 'The Manual Task execution does not belong to this execution scope.' ].
	anActivityExecution isActive ifFalse: [
		self error: 'Only an active Manual Task execution can complete.' ].
	anActivityExecution beginCompletion.
	anActivityExecution complete.
	self produceOutgoingControlFor: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'activities - manual' }
CPExecutionScope >> assignMultiInstanceManualTaskExecution: anInstance [
	| outerExecution |
	outerExecution := anInstance activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Multi-Instance Manual Task instance does not belong to this execution scope.' ].
	(outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
		self error: 'The Multi-Instance Manual Task instance does not belong to its outer Activity execution.' ].
	anInstance isActive ifFalse: [
		self error: 'Only an active Multi-Instance Manual Task instance can resolve its resource assignments.' ].
	anInstance manualTaskResourceAssignments:
		(self resourceAssignmentsFor: outerExecution definition activityExecution: anInstance).
	^ anInstance
]

{ #category : 'activities - manual' }
CPExecutionScope >> completeMultiInstanceManualTaskExecution: anInstance [
	| outerExecution |
	outerExecution := anInstance activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Multi-Instance Manual Task instance does not belong to this execution scope.' ].
	(outerExecution multiInstanceActivityExecutions identityIncludes: anInstance) ifFalse: [
		self error: 'The Multi-Instance Manual Task instance does not belong to its outer Activity execution.' ].
	anInstance isActive ifFalse: [
		self error: 'Only an active Multi-Instance Manual Task instance can complete.' ].
	anInstance complete.
	^ anInstance
]


{ #category : 'activities - send' }
CPExecutionScope >> completeStandardLoopSendTaskIteration: anIteration [
	| outerExecution dispatch |
	outerExecution := anIteration activityExecution.
	outerExecution scope == self ifFalse: [ self error: 'The Standard Loop Send Task iteration does not belong to this execution scope.' ].
	(outerExecution standardLoopIterations identityIncludes: anIteration) ifFalse: [ self error: 'The Standard Loop Send Task iteration does not belong to its outer Activity execution.' ].
	anIteration isActive ifFalse: [ self error: 'Only an active Standard Loop Send Task iteration can complete its Message dispatch.' ].
	dispatch := anIteration messageDispatch.
	dispatch ifNil: [ self error: 'The Standard Loop Send Task iteration has no pending Message dispatch.' ].
	dispatch isPending ifFalse: [ self error: 'The Standard Loop Send Task Message has already been sent.' ].
	dispatch markSent.
	self completeStandardLoopIteration: anIteration of: outerExecution.
	^ anIteration
]

{ #category : 'activities - receive' }
CPExecutionScope >> subscribeStandardLoopReceiveTaskIteration: anIteration [
	| outerExecution subscription |
	outerExecution := anIteration activityExecution.
	outerExecution scope == self ifFalse: [ self error: 'The Standard Loop Receive Task iteration does not belong to this execution scope.' ].
	(outerExecution standardLoopIterations identityIncludes: anIteration) ifFalse: [ self error: 'The Standard Loop Receive Task iteration does not belong to its outer Activity execution.' ].
	anIteration isActive ifFalse: [ self error: 'Only an active Standard Loop Receive Task iteration can wait for a Message.' ].
	subscription := CPMessageSubscription new
		waitingExecution: anIteration;
		message: outerExecution definition messageRef;
		yourself.
	anIteration messageSubscription: subscription.
	messageSubscriptions add: subscription.
	^ subscription
]

{ #category : 'activities - receive' }
CPExecutionScope >> triggerStandardLoopReceiveTaskIteration: anIteration with: anOccurrence [
	| outerExecution subscription |
	outerExecution := anIteration activityExecution.
	outerExecution scope == self ifFalse: [ self error: 'The Standard Loop Receive Task iteration does not belong to this execution scope.' ].
	(outerExecution standardLoopIterations identityIncludes: anIteration) ifFalse: [ self error: 'The Standard Loop Receive Task iteration does not belong to its outer Activity execution.' ].
	anIteration isWaitingForMessage ifFalse: [ self error: 'Only a waiting Standard Loop Receive Task iteration can accept a message occurrence.' ].
	subscription := anIteration messageSubscription.
	anOccurrence definition == subscription message ifFalse: [ self error: 'The occurrence does not carry the Message awaited by this Standard Loop Receive Task iteration.' ].
	self acceptOccurrence: anOccurrence.
	anIteration acceptReceivedOccurrence: anOccurrence.
	subscription triggerWith: anOccurrence.
	self completeStandardLoopIteration: anIteration of: outerExecution.
	^ anIteration
]


{ #category : 'activities - user' }
CPExecutionScope >> distributeStandardLoopUserTaskIteration: anIteration [
	| outerExecution workItem |
	outerExecution := anIteration activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Standard Loop User Task iteration does not belong to this execution scope.' ].
	(outerExecution standardLoopIterations identityIncludes: anIteration) ifFalse: [
		self error: 'The Standard Loop User Task iteration does not belong to its outer Activity execution.' ].
	anIteration isActive ifFalse: [
		self error: 'Only an active Standard Loop User Task iteration can distribute work.' ].
	workItem := CPUserTaskWorkItem new
		userTask: outerExecution definition;
		activityExecution: anIteration;
		resourceAssignments: (self resourceAssignmentsFor: outerExecution definition activityExecution: anIteration);
		yourself.
	anIteration userTaskWorkItem: workItem.
	self environment distributeUserTaskWorkItem: workItem in: self.
	workItem markDistributed.
	^ workItem
]

{ #category : 'activities - user' }
CPExecutionScope >> completeStandardLoopUserTaskIteration: anIteration [
	| outerExecution workItem |
	outerExecution := anIteration activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Standard Loop User Task iteration does not belong to this execution scope.' ].
	(outerExecution standardLoopIterations identityIncludes: anIteration) ifFalse: [
		self error: 'The Standard Loop User Task iteration does not belong to its outer Activity execution.' ].
	anIteration isActive ifFalse: [
		self error: 'Only an active Standard Loop User Task iteration can complete.' ].
	workItem := anIteration userTaskWorkItem.
	workItem ifNil: [ self error: 'The Standard Loop User Task iteration has no distributed work item.' ].
	workItem isPending ifFalse: [ self error: 'The Standard Loop User Task work item is not pending.' ].
	workItem complete.
	self completeStandardLoopIteration: anIteration of: outerExecution.
	^ anIteration
]

{ #category : 'activities - manual' }
CPExecutionScope >> assignStandardLoopManualTaskIteration: anIteration [
	| outerExecution |
	outerExecution := anIteration activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Standard Loop Manual Task iteration does not belong to this execution scope.' ].
	(outerExecution standardLoopIterations identityIncludes: anIteration) ifFalse: [
		self error: 'The Standard Loop Manual Task iteration does not belong to its outer Activity execution.' ].
	anIteration isActive ifFalse: [
		self error: 'Only an active Standard Loop Manual Task iteration can resolve its resource assignments.' ].
	anIteration manualTaskResourceAssignments:
		(self resourceAssignmentsFor: outerExecution definition activityExecution: anIteration).
	^ anIteration
]

{ #category : 'activities - manual' }
CPExecutionScope >> completeStandardLoopManualTaskIteration: anIteration [
	| outerExecution |
	outerExecution := anIteration activityExecution.
	outerExecution scope == self ifFalse: [
		self error: 'The Standard Loop Manual Task iteration does not belong to this execution scope.' ].
	(outerExecution standardLoopIterations identityIncludes: anIteration) ifFalse: [
		self error: 'The Standard Loop Manual Task iteration does not belong to its outer Activity execution.' ].
	anIteration isActive ifFalse: [
		self error: 'Only an active Standard Loop Manual Task iteration can complete.' ].
	self completeStandardLoopIteration: anIteration of: outerExecution.
	^ anIteration
]
