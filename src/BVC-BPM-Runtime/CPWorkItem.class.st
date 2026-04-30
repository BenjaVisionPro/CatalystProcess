Class {
	#name : 'CPWorkItem',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'tenant',
		'processInstance',
		'activityInstance',
		'state',
		'candidateUsers',
		'candidateGroups',
		'claimedBy',
		'createdAt',
		'claimedAt',
		'completedAt',
		'inputValues',
		'outputValues'
	],
	#category : 'BVC-BPM-Runtime',
	#package : 'BVC-BPM-Runtime'
}

{ #category : 'accessing' }
CPWorkItem >> tenant [
	^ tenant
]

{ #category : 'accessing' }
CPWorkItem >> tenant: anObject [
	tenant := anObject
]

{ #category : 'accessing' }
CPWorkItem >> processInstance [
	^ processInstance
]

{ #category : 'accessing' }
CPWorkItem >> processInstance: anObject [
	processInstance := anObject
]

{ #category : 'accessing' }
CPWorkItem >> activityInstance [
	^ activityInstance
]

{ #category : 'accessing' }
CPWorkItem >> activityInstance: anObject [
	activityInstance := anObject
]

{ #category : 'accessing' }
CPWorkItem >> state [
	^ state
]

{ #category : 'accessing' }
CPWorkItem >> state: anObject [
	state := anObject
]

{ #category : 'accessing' }
CPWorkItem >> candidateUsers [
	^ candidateUsers
]

{ #category : 'accessing' }
CPWorkItem >> candidateUsers: anObject [
	candidateUsers := anObject
]

{ #category : 'accessing' }
CPWorkItem >> candidateGroups [
	^ candidateGroups
]

{ #category : 'accessing' }
CPWorkItem >> candidateGroups: anObject [
	candidateGroups := anObject
]

{ #category : 'accessing' }
CPWorkItem >> claimedBy [
	^ claimedBy
]

{ #category : 'accessing' }
CPWorkItem >> claimedBy: anObject [
	claimedBy := anObject
]

{ #category : 'accessing' }
CPWorkItem >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
CPWorkItem >> createdAt: anObject [
	createdAt := anObject
]

{ #category : 'accessing' }
CPWorkItem >> claimedAt [
	^ claimedAt
]

{ #category : 'accessing' }
CPWorkItem >> claimedAt: anObject [
	claimedAt := anObject
]

{ #category : 'accessing' }
CPWorkItem >> completedAt [
	^ completedAt
]

{ #category : 'accessing' }
CPWorkItem >> completedAt: anObject [
	completedAt := anObject
]

{ #category : 'accessing' }
CPWorkItem >> inputValues [
	^ inputValues
]

{ #category : 'accessing' }
CPWorkItem >> inputValues: anObject [
	inputValues := anObject
]

{ #category : 'accessing' }
CPWorkItem >> outputValues [
	^ outputValues
]

{ #category : 'accessing' }
CPWorkItem >> outputValues: anObject [
	outputValues := anObject
]

{ #category : 'initialization' }
CPWorkItem >> initialize [
	super initialize.
	state := #available.
	candidateUsers := OrderedCollection new.
	candidateGroups := OrderedCollection new.
	inputValues := Dictionary new.
	outputValues := Dictionary new.
	createdAt := DateAndTime now
]

{ #category : 'testing' }
CPWorkItem >> isAvailable [
	^ state = #available
]

{ #category : 'testing' }
CPWorkItem >> isClaimed [
	^ state = #claimed
]

{ #category : 'testing' }
CPWorkItem >> isCompleted [
	^ state = #completed
]

{ #category : 'testing' }
CPWorkItem >> canBeClaimedBy: aUser [
	claimedBy ifNotNil: [ ^ claimedBy == aUser ].
	candidateUsers isEmpty ifTrue: [ ^ true ].
	^ candidateUsers includes: aUser
]

{ #category : 'actions' }
CPWorkItem >> claimBy: aUser [
	(self canBeClaimedBy: aUser) ifFalse: [ self error: 'Work item cannot be claimed by this user.' ].
	claimedBy := aUser.
	claimedAt := DateAndTime now.
	state := #claimed.
	^ self
]

{ #category : 'actions' }
CPWorkItem >> completeWith: aDictionary [
	outputValues := aDictionary ifNil: [ Dictionary new ].
	completedAt := DateAndTime now.
	state := #completed.
	^ self
]

