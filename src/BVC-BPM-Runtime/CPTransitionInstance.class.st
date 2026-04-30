Class {
	#name : 'CPTransitionInstance',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'processInstance',
		'transitionDefinition',
		'token',
		'createdAt'
	],
	#category : 'BVC-BPM-Runtime',
	#package : 'BVC-BPM-Runtime'
}

{ #category : 'accessing' }
CPTransitionInstance >> processInstance [
	^ processInstance
]

{ #category : 'accessing' }
CPTransitionInstance >> processInstance: anObject [
	processInstance := anObject
]

{ #category : 'accessing' }
CPTransitionInstance >> transitionDefinition [
	^ transitionDefinition
]

{ #category : 'accessing' }
CPTransitionInstance >> transitionDefinition: anObject [
	transitionDefinition := anObject
]

{ #category : 'accessing' }
CPTransitionInstance >> token [
	^ token
]

{ #category : 'accessing' }
CPTransitionInstance >> token: anObject [
	token := anObject
]

{ #category : 'accessing' }
CPTransitionInstance >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
CPTransitionInstance >> createdAt: anObject [
	createdAt := anObject
]

