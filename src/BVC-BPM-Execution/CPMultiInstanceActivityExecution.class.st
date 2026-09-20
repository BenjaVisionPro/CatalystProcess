Class {
	#name : 'CPMultiInstanceActivityExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'activityExecution',
		'index',
		'itemValues',
		'subScope',
		'completed',
		'cancelled'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPMultiInstanceActivityExecution >> initialize [
	super initialize.
	itemValues := IdentityDictionary new.
	completed := false.
	cancelled := false
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> activityExecution [
	^ activityExecution
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> activityExecution: anActivityExecution [
	activityExecution := anActivityExecution
]


{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> scope [
	^ activityExecution scope
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> subScope [
	^ subScope
]

{ #category : 'building' }
CPMultiInstanceActivityExecution >> createSubScopeFor: aScopeDefinition [
	subScope ifNotNil: [ self error: 'A Multi-Instance Activity instance can own only one execution scope.' ].
	^ CPExecutionScope for: aScopeDefinition ownedBy: self
]

{ #category : 'building' }
CPMultiInstanceActivityExecution >> attachSubScope: anExecutionScope [
	subScope ifNotNil: [ self error: 'A Multi-Instance Activity instance already owns an execution scope.' ].
	anExecutionScope owningActivity ifNotNil: [ self error: 'The execution scope is already owned by an Activity execution.' ].
	self scope ifNil: [ self error: 'The Multi-Instance Activity execution must belong to a scope before its instance can own a child scope.' ].
	anExecutionScope owningActivity: self.
	self scope addChildScope: anExecutionScope.
	subScope := anExecutionScope.
	^ anExecutionScope
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> index [
	^ index
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> index: anInteger [
	index := anInteger
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> ownsItemValueFor: anItemAwareElement [
	| loop |
	loop := activityExecution definition loopCharacteristics.
	^ loop inputDataItem == anItemAwareElement
		or: [ loop outputDataItem == anItemAwareElement ]
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> hasItemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Multi-Instance Activity instance.' ].
	^ itemValues includesKey: anItemAwareElement
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> itemValueFor: anItemAwareElement [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Multi-Instance Activity instance.' ].
	^ itemValues at: anItemAwareElement ifAbsent: [ nil ]
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> itemValueFor: anItemAwareElement put: aValue [
	(self ownsItemValueFor: anItemAwareElement) ifFalse: [
		self error: 'The item-aware element does not belong to this Multi-Instance Activity instance.' ].
	itemValues at: anItemAwareElement put: aValue.
	^ aValue
]


{ #category : 'lifecycle' }
CPMultiInstanceActivityExecution >> isCompleted [
	^ completed
]

{ #category : 'lifecycle' }
CPMultiInstanceActivityExecution >> complete [
	completed ifTrue: [ self error: 'A Multi-Instance Activity instance cannot complete twice.' ].
	cancelled ifTrue: [ self error: 'A cancelled Multi-Instance Activity instance cannot complete.' ].
	activityExecution prepareMultiInstanceActivityExecutionCompletion: self.
	completed := true.
	activityExecution multiInstanceActivityExecutionDidComplete: self.
	^ self
]


{ #category : 'lifecycle' }
CPMultiInstanceActivityExecution >> isCancelled [
	^ cancelled
]

{ #category : 'lifecycle' }
CPMultiInstanceActivityExecution >> isActive [
	^ completed not and: [ cancelled not ]
]

{ #category : 'lifecycle' }
CPMultiInstanceActivityExecution >> cancel [
	self isActive ifFalse: [ self error: 'Only an active Multi-Instance Activity instance can be cancelled.' ].
	cancelled := true.
	^ self
]
