Class {
	#name : 'CPProcessDeployment',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'tenant',
		'sourceDesign',
		'processKey',
		'version',
		'compiledDefinition',
		'processDefinition',
		'deployedAt',
		'deployedBy',
		'status',
		'initiationSubscriptions',
		'authorizedStartUsers'
	],
	#category : 'BVC-BPM-Definition',
	#package : 'BVC-BPM-Definition'
}

{ #category : 'accessing' }
CPProcessDeployment >> tenant [
	^ tenant
]

{ #category : 'accessing' }
CPProcessDeployment >> tenant: anObject [
	tenant := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> sourceDesign [
	^ sourceDesign
]

{ #category : 'accessing' }
CPProcessDeployment >> sourceDesign: anObject [
	sourceDesign := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> processKey [
	^ processKey
]

{ #category : 'accessing' }
CPProcessDeployment >> processKey: anObject [
	processKey := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> version [
	^ version
]

{ #category : 'accessing' }
CPProcessDeployment >> version: anObject [
	version := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> compiledDefinition [
	^ compiledDefinition
]

{ #category : 'accessing' }
CPProcessDeployment >> compiledDefinition: anObject [
	compiledDefinition := anObject
]


{ #category : 'accessing' }
CPProcessDeployment >> processDefinition [
	^ processDefinition
]

{ #category : 'accessing' }
CPProcessDeployment >> processDefinition: aProcess [
	processDefinition := aProcess
]

{ #category : 'accessing' }
CPProcessDeployment >> deployedAt [
	^ deployedAt
]

{ #category : 'accessing' }
CPProcessDeployment >> deployedAt: anObject [
	deployedAt := anObject
]

{ #category : 'accessing' }
CPProcessDeployment >> deployedBy [
	^ deployedBy
]

{ #category : 'accessing' }
CPProcessDeployment >> deployedBy: anObject [
	deployedBy := anObject
]

{ #category : 'initialization' }
CPProcessDeployment >> initialize [
	super initialize.
	status := #draft.
	initiationSubscriptions := OrderedCollection new.
	authorizedStartUsers := OrderedCollection new
]

{ #category : 'testing' }
CPProcessDeployment >> isDraft [
	^ status = #draft
]

{ #category : 'testing' }
CPProcessDeployment >> isActive [
	^ status = #active
]

{ #category : 'testing' }
CPProcessDeployment >> isRetired [
	^ status = #retired
]

{ #category : 'testing' }
CPProcessDeployment >> acceptsNewProcessExecutions [
	^ self isActive
]

{ #category : 'actions' }
CPProcessDeployment >> activate [
	self isDraft ifFalse: [ self error: 'Only a draft Process deployment can be activated.' ].
	status := #active
]

{ #category : 'actions' }
CPProcessDeployment >> retire [
	self isActive ifFalse: [ self error: 'Only an active Process deployment can be retired.' ].
	status := #retired
]


{ #category : 'process initiation' }
CPProcessDeployment >> initiationSubscriptions [
	^ initiationSubscriptions
]

{ #category : 'process initiation' }
CPProcessDeployment >> replaceInitiationSubscriptionsWith: aCollection [
	initiationSubscriptions := aCollection asOrderedCollection.
	^ initiationSubscriptions
]

{ #category : 'process initiation' }
CPProcessDeployment >> clearInitiationSubscriptions [
	initiationSubscriptions removeAll.
	^ self
]


{ #category : 'process start authorization' }
CPProcessDeployment >> authorizedStartUsers [
	^ authorizedStartUsers
]

{ #category : 'process start authorization' }
CPProcessDeployment >> authorizeStartFor: aUser [
	aUser ifNil: [ self error: 'A User is required.' ].
	(authorizedStartUsers includes: aUser) ifFalse: [ authorizedStartUsers add: aUser ].
	^ aUser
]

{ #category : 'process start authorization' }
CPProcessDeployment >> revokeStartFor: aUser [
	authorizedStartUsers remove: aUser ifAbsent: [ ].
	^ aUser
]

{ #category : 'process start authorization' }
CPProcessDeployment >> canBeStartedBy: aUser [
	aUser ifNil: [ ^ false ].
	^ self acceptsNewProcessExecutions and: [
		(authorizedStartUsers includes: aUser) and: [
			tenant isNil or: [ aUser isMemberOfTenant: tenant ] ] ]
]
