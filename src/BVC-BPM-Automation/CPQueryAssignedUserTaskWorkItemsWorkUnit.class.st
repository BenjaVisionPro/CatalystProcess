Class {
	#name : 'CPQueryAssignedUserTaskWorkItemsWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'user'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'instance creation' }
CPQueryAssignedUserTaskWorkItemsWorkUnit class >> user: aUser [
	^ self new user: aUser; yourself
]

{ #category : 'service context' }
CPQueryAssignedUserTaskWorkItemsWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'accessing' }
CPQueryAssignedUserTaskWorkItemsWorkUnit >> user [
	^ user
]

{ #category : 'accessing' }
CPQueryAssignedUserTaskWorkItemsWorkUnit >> user: aUser [
	user := aUser
]

{ #category : 'running' }
CPQueryAssignedUserTaskWorkItemsWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service queryAssignedUserTaskWorkItemsWorkUnit: self
]
