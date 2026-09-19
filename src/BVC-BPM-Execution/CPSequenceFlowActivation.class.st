Class {
	#name : 'CPSequenceFlowActivation',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'definition',
		'scope',
		'producedBy',
		'consumedBy'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

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
CPSequenceFlowActivation >> isAvailable [ ^ consumedBy isNil ]

{ #category : 'control flow' }
CPSequenceFlowActivation >> consumeBy: aFlowNodeExecution [
	consumedBy ifNotNil: [ self error: 'A Sequence Flow activation can be consumed only once.' ].
	aFlowNodeExecution scope == scope ifFalse: [ self error: 'Control flow can only be consumed within its execution scope.' ].
	consumedBy := aFlowNodeExecution.
	^ self
]
