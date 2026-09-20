Class {
	#name : 'CPActivityExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'scope',
		'subScope',
		'consumedFlowActivations',
		'state'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'instance creation' }
CPActivityExecution class >> for: anActivity in: anExecutionScope [
	^ anExecutionScope addActivityExecution: (self new
		definition: anActivity;
		yourself)
]

{ #category : 'initialization' }
CPActivityExecution >> initialize [
	super initialize.
	consumedFlowActivations := OrderedCollection new.
	state := CPActivityReadyState new
]

{ #category : 'accessing' }
CPActivityExecution >> definition [ ^ definition ]
{ #category : 'accessing' }
CPActivityExecution >> definition: anActivity [ definition := anActivity ]
{ #category : 'accessing' }
CPActivityExecution >> scope [ ^ scope ]
{ #category : 'accessing' }
CPActivityExecution >> scope: anExecutionScope [ scope := anExecutionScope ]
{ #category : 'accessing' }
CPActivityExecution >> subScope [ ^ subScope ]
{ #category : 'accessing' }
CPActivityExecution >> state [ ^ state ]
{ #category : 'accessing' }
CPActivityExecution >> consumedFlowActivations [ ^ consumedFlowActivations ]

{ #category : 'control flow' }
CPActivityExecution >> consumeFlowActivation: anActivation [
	anActivation consumeBy: self.
	consumedFlowActivations add: anActivation.
	^ anActivation
]

{ #category : 'building' }
CPActivityExecution >> createSubScopeFor: aScopeDefinition [
	subScope ifNotNil: [ self error: 'An Activity execution can own only one execution scope.' ].
	^ CPExecutionScope for: aScopeDefinition ownedBy: self
]

{ #category : 'building' }
CPActivityExecution >> attachSubScope: anExecutionScope [
	subScope ifNotNil: [ self error: 'An Activity execution already owns an execution scope.' ].
	anExecutionScope owningActivity ifNotNil: [ self error: 'The execution scope is already owned by an Activity execution.' ].
	scope ifNil: [ self error: 'The Activity execution must belong to a scope before it can own a child scope.' ].
	anExecutionScope owningActivity: self.
	scope addChildScope: anExecutionScope.
	subScope := anExecutionScope.
	^ anExecutionScope
]

{ #category : 'testing' }
CPActivityExecution >> isReady [ ^ state class = CPActivityReadyState ]
{ #category : 'testing' }
CPActivityExecution >> isActive [ ^ state class = CPActivityActiveState ]
{ #category : 'testing' }
CPActivityExecution >> isCompleting [ ^ state class = CPActivityCompletingState ]
{ #category : 'testing' }
CPActivityExecution >> isCompleted [ ^ state class = CPActivityCompletedState ]
{ #category : 'testing' }
CPActivityExecution >> isFinal [ ^ state isFinal ]

{ #category : 'lifecycle' }
CPActivityExecution >> activate [
	self isReady ifFalse: [ self error: 'Only a Ready Activity can become Active.' ].
	state := CPActivityActiveState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> withdraw [
	(self isReady or: [ self isActive ]) ifFalse: [ self error: 'Only a Ready or Active Activity can be Withdrawn.' ].
	state := CPActivityWithdrawnState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> fail [
	self isActive ifFalse: [ self error: 'Only an Active Activity can fail.' ].
	state := CPActivityFailedState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> beginCompletion [
	self isActive ifFalse: [ self error: 'Only an Active Activity can begin completion.' ].
	state := CPActivityCompletingState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> complete [
	self isCompleting ifFalse: [ self error: 'Only a Completing Activity can become Completed.' ].
	state := CPActivityCompletedState new.
	scope ifNotNil: [ scope activityExecutionDidComplete: self ]
]
{ #category : 'lifecycle' }
CPActivityExecution >> beginFailure [
	self isActive ifFalse: [ self error: 'Only an Active Activity can begin failure handling.' ].
	state := CPActivityFailingState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> finishFailure [
	state class = CPActivityFailingState ifFalse: [ self error: 'Only a Failing Activity can become Failed.' ].
	state := CPActivityFailedState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> beginTermination [
	(self isActive or: [ self isCompleting ]) ifFalse: [ self error: 'Only an Active or Completing Activity can begin termination.' ].
	state := CPActivityTerminatingState new
]
{ #category : 'lifecycle' }
CPActivityExecution >> finishTermination [
	state class = CPActivityTerminatingState ifFalse: [ self error: 'Only a Terminating Activity can become Terminated.' ].
	state := CPActivityTerminatedState new
]
