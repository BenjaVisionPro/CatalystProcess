Class {
	#name : 'CPExecutionToken',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'processInstance',
		'currentNode',
		'state',
		'createdAt',
		'completedAt'
	],
	#category : 'BVC-BPM-Runtime',
	#package : 'BVC-BPM-Runtime'
}

{ #category : 'accessing' }
CPExecutionToken >> processInstance [
	^ processInstance
]

{ #category : 'accessing' }
CPExecutionToken >> processInstance: anObject [
	processInstance := anObject
]

{ #category : 'accessing' }
CPExecutionToken >> currentNode [
	^ currentNode
]

{ #category : 'accessing' }
CPExecutionToken >> currentNode: anObject [
	currentNode := anObject
]

{ #category : 'accessing' }
CPExecutionToken >> state [
	^ state
]

{ #category : 'accessing' }
CPExecutionToken >> state: anObject [
	state := anObject
]

{ #category : 'accessing' }
CPExecutionToken >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
CPExecutionToken >> createdAt: anObject [
	createdAt := anObject
]

{ #category : 'accessing' }
CPExecutionToken >> completedAt [
	^ completedAt
]

{ #category : 'accessing' }
CPExecutionToken >> completedAt: anObject [
	completedAt := anObject
]

{ #category : 'initialization' }
CPExecutionToken >> initialize [
	super initialize.
	state := #active.
	createdAt := DateAndTime now
]

