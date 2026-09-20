Class {
	#name : 'CPEventExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'scope',
		'consumedFlowActivation',
		'producedFlowActivations',
		'occurrence'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPEventExecution >> initialize [
	super initialize.
	producedFlowActivations := OrderedCollection new
]

{ #category : 'accessing' }
CPEventExecution >> definition [ ^ definition ]
{ #category : 'accessing' }
CPEventExecution >> definition: anEvent [ definition := anEvent ]
{ #category : 'accessing' }
CPEventExecution >> scope [ ^ scope ]
{ #category : 'accessing' }
CPEventExecution >> scope: anExecutionScope [ scope := anExecutionScope ]
{ #category : 'accessing' }
CPEventExecution >> consumedFlowActivation [ ^ consumedFlowActivation ]
{ #category : 'accessing' }
CPEventExecution >> producedFlowActivations [ ^ producedFlowActivations ]
{ #category : 'accessing' }
CPEventExecution >> occurrence [ ^ occurrence ]
{ #category : 'accessing' }
CPEventExecution >> occurrence: anOccurrence [ occurrence := anOccurrence ]

{ #category : 'control flow' }
CPEventExecution >> consumeFlowActivation: anActivation [
	consumedFlowActivation ifNotNil: [ self error: 'An Event execution can consume only one incoming control-flow activation.' ].
	anActivation consumeBy: self.
	consumedFlowActivation := anActivation.
	^ anActivation
]

{ #category : 'control flow' }
CPEventExecution >> recordProducedFlowActivation: anActivation [
	anActivation producedBy == self ifFalse: [ self error: 'The control-flow activation was not produced by this Event execution.' ].
	producedFlowActivations add: anActivation.
	^ anActivation
]

{ #category : 'testing' }
CPEventExecution >> isBoundaryEventExecution [ ^ false ]

{ #category : 'testing' }
CPEventExecution >> isPendingWork [
	^ false
]

{ #category : 'lifecycle' }
CPEventExecution >> terminatePendingWork [
	^ self
]

{ #category : 'testing' }
CPEventExecution >> isCompensationThrowEventExecution [
	^ false
]

{ #category : 'testing' }
CPEventExecution >> isErrorEndEventExecution [
	^ false
]


{ #category : 'testing' }
CPEventExecution >> isErrorPropagationExecution [
	^ false
]
