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
		'acceptedOccurrences'
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
	acceptedOccurrences := OrderedCollection new
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
CPExecutionScope >> executeExclusiveGateway: aGateway consuming: anActivation conditionEvaluator: anEvaluator [
	| execution selectedFlow |
	(anActivation isAvailable and: [ aGateway incoming identityIncludes: anActivation definition ]) ifFalse: [
		self error: 'An Exclusive Gateway requires an available activation from one of its incoming Sequence Flows.' ].
	selectedFlow := self
		selectedOutgoingFlowForExclusiveGateway: aGateway
		conditionEvaluator: anEvaluator.
	execution := self createGatewayExecutionFor: aGateway.
	execution consumeFlowActivation: anActivation.
	execution recordProducedFlowActivation:
		(self activateSequenceFlow: selectedFlow producedBy: execution).
	^ execution
]

{ #category : 'gateways - exclusive' }
CPExecutionScope >> selectedOutgoingFlowForExclusiveGateway: aGateway conditionEvaluator: anEvaluator [
	aGateway outgoing do: [ :eachFlow |
		(aGateway isDefaultFlow: eachFlow) ifFalse: [
			eachFlow conditionExpression ifNotNil: [ :anExpression |
				(anEvaluator value: anExpression) ifTrue: [ ^ eachFlow ] ] ] ].
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
CPExecutionScope >> executeInclusiveGateway: aGateway conditionEvaluator: anEvaluator [
	| execution selectedFlows |
	(self canExecuteInclusiveGateway: aGateway) ifFalse: [
		self error: 'The Inclusive Gateway cannot execute while an unrepresented incoming branch can still reach it.' ].
	selectedFlows := self
		selectedOutgoingFlowsForInclusiveGateway: aGateway
		conditionEvaluator: anEvaluator.
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
CPExecutionScope >> selectedOutgoingFlowsForInclusiveGateway: aGateway conditionEvaluator: anEvaluator [
	| selected |
	selected := OrderedCollection new.
	aGateway outgoing do: [ :eachFlow |
		(aGateway isDefaultFlow: eachFlow) ifFalse: [
			eachFlow conditionExpression ifNotNil: [ :expression |
				(anEvaluator value: expression) ifTrue: [ selected add: eachFlow ] ] ] ].
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
