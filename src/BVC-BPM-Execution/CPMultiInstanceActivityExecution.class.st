Class {
	#name : 'CPMultiInstanceActivityExecution',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'activityExecution',
		'index',
		'itemValues',
		'completed'
	],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPMultiInstanceActivityExecution >> initialize [
	super initialize.
	itemValues := IdentityDictionary new.
	completed := false
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
CPMultiInstanceActivityExecution >> index [
	^ index
]

{ #category : 'accessing' }
CPMultiInstanceActivityExecution >> index: anInteger [
	index := anInteger
]

{ #category : 'data' }
CPMultiInstanceActivityExecution >> ownsItemValueFor: anItemAwareElement [
	^ activityExecution definition loopCharacteristics inputDataItem == anItemAwareElement
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
	completed := true.
	activityExecution multiInstanceActivityExecutionDidComplete: self.
	^ self
]
