Class {
	#name : 'CPSequenceFlowActivation',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'scope',
		'producedBy',
		'consumedBy',
		'cancelled'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPSequenceFlowActivation >> initialize [
	super initialize.
	cancelled := false
]

{ #category : 'accessing' }
CPSequenceFlowActivation >> definition [ ^ definition ]
{ #category : 'accessing' }
CPSequenceFlowActivation >> definition: aSequenceFlow [ definition := aSequenceFlow ]
{ #category : 'accessing' }
CPSequenceFlowActivation >> scope [ ^ scope ]
{ #category : 'accessing' }
CPSequenceFlowActivation >> scope: anExecutionScope [ scope := anExecutionScope ]
{ #category : 'accessing' }
CPSequenceFlowActivation >> producedBy [ ^ producedBy ]
{ #category : 'accessing' }
CPSequenceFlowActivation >> producedBy: aFlowNodeExecution [ producedBy := aFlowNodeExecution ]
{ #category : 'accessing' }
CPSequenceFlowActivation >> consumedBy [ ^ consumedBy ]
{ #category : 'testing' }
CPSequenceFlowActivation >> isAvailable [ ^ consumedBy isNil and: [ cancelled not ] ]

{ #category : 'testing' }
CPSequenceFlowActivation >> isCancelled [ ^ cancelled ]

{ #category : 'control flow' }
CPSequenceFlowActivation >> consumeBy: aFlowNodeExecution [
	cancelled ifTrue: [ self error: 'A cancelled Sequence Flow activation cannot be consumed.' ].
	consumedBy ifNotNil: [ self error: 'A Sequence Flow activation can be consumed only once.' ].
	aFlowNodeExecution scope == scope ifFalse: [ self error: 'Control flow can only be consumed within its execution scope.' ].
	consumedBy := aFlowNodeExecution.
	^ self
]

{ #category : 'control flow' }
CPSequenceFlowActivation >> cancel [
	consumedBy ifNotNil: [ self error: 'A consumed Sequence Flow activation cannot be cancelled.' ].
	cancelled ifTrue: [ self error: 'A Sequence Flow activation can be cancelled only once.' ].
	cancelled := true.
	^ self
]
