Class {
	#name : 'CPTaskAssignment',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'workItem',
		'user',
		'state',
		'assignedAt',
		'completedAt'
	],
	#category : 'BVC-BPM-Runtime',
	#package : 'BVC-BPM-Runtime'
}

{ #category : 'accessing' }
CPTaskAssignment >> workItem [
	^ workItem
]

{ #category : 'accessing' }
CPTaskAssignment >> workItem: anObject [
	workItem := anObject
]

{ #category : 'accessing' }
CPTaskAssignment >> user [
	^ user
]

{ #category : 'accessing' }
CPTaskAssignment >> user: anObject [
	user := anObject
]

{ #category : 'accessing' }
CPTaskAssignment >> state [
	^ state
]

{ #category : 'accessing' }
CPTaskAssignment >> state: anObject [
	state := anObject
]

{ #category : 'accessing' }
CPTaskAssignment >> assignedAt [
	^ assignedAt
]

{ #category : 'accessing' }
CPTaskAssignment >> assignedAt: anObject [
	assignedAt := anObject
]

{ #category : 'accessing' }
CPTaskAssignment >> completedAt [
	^ completedAt
]

{ #category : 'accessing' }
CPTaskAssignment >> completedAt: anObject [
	completedAt := anObject
]

