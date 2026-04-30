Class {
	#name : 'CPActivityInstance',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'processInstance',
		'nodeDefinition',
		'token',
		'state',
		'startedAt',
		'completedAt'
	],
	#category : 'BVC-BPM-Runtime',
	#package : 'BVC-BPM-Runtime'
}

{ #category : 'accessing' }
CPActivityInstance >> processInstance [
	^ processInstance
]

{ #category : 'accessing' }
CPActivityInstance >> processInstance: anObject [
	processInstance := anObject
]

{ #category : 'accessing' }
CPActivityInstance >> nodeDefinition [
	^ nodeDefinition
]

{ #category : 'accessing' }
CPActivityInstance >> nodeDefinition: anObject [
	nodeDefinition := anObject
]

{ #category : 'accessing' }
CPActivityInstance >> token [
	^ token
]

{ #category : 'accessing' }
CPActivityInstance >> token: anObject [
	token := anObject
]

{ #category : 'accessing' }
CPActivityInstance >> state [
	^ state
]

{ #category : 'accessing' }
CPActivityInstance >> state: anObject [
	state := anObject
]

{ #category : 'accessing' }
CPActivityInstance >> startedAt [
	^ startedAt
]

{ #category : 'accessing' }
CPActivityInstance >> startedAt: anObject [
	startedAt := anObject
]

{ #category : 'accessing' }
CPActivityInstance >> completedAt [
	^ completedAt
]

{ #category : 'accessing' }
CPActivityInstance >> completedAt: anObject [
	completedAt := anObject
]

{ #category : 'initialization' }
CPActivityInstance >> initialize [
	super initialize.
	state := #created
]

{ #category : 'testing' }
CPActivityInstance >> isCompleted [
	^ state = #completed
]

{ #category : 'actions' }
CPActivityInstance >> start [
	state := #running.
	startedAt := DateAndTime now
]

{ #category : 'actions' }
CPActivityInstance >> complete [
	state := #completed.
	completedAt := DateAndTime now
]

