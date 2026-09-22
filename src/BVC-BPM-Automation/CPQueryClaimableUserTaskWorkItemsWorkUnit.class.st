Class {
	#name : 'CPQueryClaimableUserTaskWorkItemsWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'user'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'instance creation' }
CPQueryClaimableUserTaskWorkItemsWorkUnit class >> user: aUser [
	^ self new user: aUser; yourself
]

{ #category : 'service context' }
CPQueryClaimableUserTaskWorkItemsWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'accessing' }
CPQueryClaimableUserTaskWorkItemsWorkUnit >> user [
	^ user
]

{ #category : 'accessing' }
CPQueryClaimableUserTaskWorkItemsWorkUnit >> user: aUser [
	user := aUser
]

{ #category : 'running' }
CPQueryClaimableUserTaskWorkItemsWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service queryClaimableUserTaskWorkItemsWorkUnit: self
]
