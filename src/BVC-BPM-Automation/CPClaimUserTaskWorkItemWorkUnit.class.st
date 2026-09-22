"I claim a pending User Task work item for an actual Process user through Catalyst Runtime. Claiming is a state-changing application command, so it crosses the Runtime WorkUnit boundary rather than mutating the work item from a presentation client."
Class {
	#name : 'CPClaimUserTaskWorkItemWorkUnit',
	#superclass : 'CRWorkUnit',
	#instVars : [
		'workItem',
		'user'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPClaimUserTaskWorkItemWorkUnit class >> serviceClass [
	^ CPBpmService
]

{ #category : 'instance creation' }
CPClaimUserTaskWorkItemWorkUnit class >> workItem: aCPUserTaskWorkItem user: aCPUser [
	^ self new
		workItem: aCPUserTaskWorkItem;
		user: aCPUser;
		yourself
]

{ #category : 'accessing' }
CPClaimUserTaskWorkItemWorkUnit >> workItem [
	^ workItem
]

{ #category : 'accessing' }
CPClaimUserTaskWorkItemWorkUnit >> workItem: aCPUserTaskWorkItem [
	workItem := aCPUserTaskWorkItem
]

{ #category : 'accessing' }
CPClaimUserTaskWorkItemWorkUnit >> user [
	^ user
]

{ #category : 'accessing' }
CPClaimUserTaskWorkItemWorkUnit >> user: aCPUser [
	user := aCPUser
]

{ #category : 'running' }
CPClaimUserTaskWorkItemWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
	^ aCRWorkUnitExecutionContext service claimUserTaskWorkItemWorkUnit: self
]
