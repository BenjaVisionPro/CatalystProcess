Class {
	#name : 'CPProcessExecution',
	#superclass : 'CPExecutionScope',
	#instVars : [
		'deployment',
		'tenant',
		'startedBy',
		'environment',
		'started',
		'completed'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'instance creation' }
CPProcessExecution class >> for: aProcess environment: anExecutionEnvironment [
	^ self new
		definition: aProcess;
		environment: anExecutionEnvironment;
		yourself
]

{ #category : 'accessing' }
CPProcessExecution >> deployment [ ^ deployment ]
{ #category : 'accessing' }
CPProcessExecution >> deployment: anObject [ deployment := anObject ]
{ #category : 'accessing' }
CPProcessExecution >> tenant [ ^ tenant ]
{ #category : 'accessing' }
CPProcessExecution >> tenant: anObject [ tenant := anObject ]
{ #category : 'accessing' }
CPProcessExecution >> startedBy [ ^ startedBy ]
{ #category : 'accessing' }
CPProcessExecution >> startedBy: anObject [ startedBy := anObject ]

{ #category : 'accessing' }
CPProcessExecution >> environment [ ^ environment ]
{ #category : 'accessing' }
CPProcessExecution >> environment: anExecutionEnvironment [ environment := anExecutionEnvironment ]


{ #category : 'initialization' }
CPProcessExecution >> initialize [
	super initialize.
	started := false.
	completed := false
]

{ #category : 'testing' }
CPProcessExecution >> isStarted [
	^ started
]

{ #category : 'lifecycle' }
CPProcessExecution >> start [
	| startEvents executions |
	started ifTrue: [ self error: 'A Process execution can only be started once.' ].
	startEvents := self definition flowElements select: [ :each |
		each isStartEvent and: [ each eventDefinitions isEmpty ] ].
	startEvents ifEmpty: [ self error: 'Process instantiation requires at least one None Start Event.' ].
	started := true.
	executions := startEvents collect: [ :each | self executeStartEvent: each occurrence: nil ].
	^ executions
]


{ #category : 'testing' }
CPProcessExecution >> isCompleted [
	^ completed
]

{ #category : 'lifecycle' }
CPProcessExecution >> canComplete [
	started ifFalse: [ ^ false ].
	completed ifTrue: [ ^ false ].
	(self flowActivations anySatisfy: [ :each | each isAvailable ]) ifTrue: [ ^ false ].
	(self activityExecutions anySatisfy: [ :each | each isFinal not ]) ifTrue: [ ^ false ].
	self allWaitingMessageSubscriptions ifNotEmpty: [ ^ false ].
	self allWaitingTimerSubscriptions ifNotEmpty: [ ^ false ].
	self allWaitingSignalSubscriptions ifNotEmpty: [ ^ false ].
	self allWaitingEventBasedGatewaySubscriptions ifNotEmpty: [ ^ false ].
	self hasPendingEventWork ifTrue: [ ^ false ].
	^ true
]

{ #category : 'lifecycle' }
CPProcessExecution >> complete [
	self canComplete ifFalse: [
		self error: 'A Process execution cannot complete while executable or waiting work remains.' ].
	completed := true.
	^ self
]

{ #category : 'lifecycle' }
CPProcessExecution >> finishTermination [
	self complete.
	^ self
]


{ #category : 'occurrences' }
CPProcessExecution >> processExecution [
	^ self
]

{ #category : 'lifecycle' }
CPProcessExecution >> startWithOccurrence: anOccurrence [
	| matchingStartEvents |
	started ifTrue: [ self error: 'A Process execution can only be started once.' ].
	anOccurrence ifNil: [ self error: 'Triggered Process instantiation requires an occurrence.' ].
	matchingStartEvents := self definition flowElements select: [ :each |
		each isStartEvent and: [ each matchesInstantiationOccurrence: anOccurrence ] ].
	matchingStartEvents ifEmpty: [
		self error: 'No Start Event matches the instantiating occurrence.' ].
	matchingStartEvents size > 1 ifTrue: [
		self error: 'The instantiating occurrence matches more than one Start Event.' ].
	started := true.
	^ self executeStartEvent: matchingStartEvents first occurrence: anOccurrence
]

{ #category : 'lifecycle' }
CPProcessExecution >> startWhenConditionSatisfied [
	| matchingStartEvents |
	started ifTrue: [ self error: 'A Process execution can only be started once.' ].
	matchingStartEvents := self definition flowElements select: [ :each |
		each isStartEvent and: [ each conditionAllowsInstantiationIn: self ] ].
	matchingStartEvents ifEmpty: [
		self error: 'No Conditional Start Event condition is satisfied.' ].
	matchingStartEvents size > 1 ifTrue: [
		self error: 'More than one Conditional Start Event condition is satisfied.' ].
	started := true.
	^ self executeStartEvent: matchingStartEvents first occurrence: nil
]


{ #category : 'signals' }
CPProcessExecution >> deliverSignalOccurrence: anOccurrence [
	| matches |
	anOccurrence ifNil: [ self error: 'Signal delivery requires an occurrence.' ].
	matches := self allWaitingSignalSubscriptionsFor: anOccurrence definition.
	matches isEmpty ifTrue: [
		self error: 'No waiting Signal subscription matches this occurrence.' ].
	self acceptOccurrence: anOccurrence.
	matches do: [ :each | each deliverAcceptedOccurrence: anOccurrence ].
	^ matches
]
