Class {
	#name : 'CPUserTaskWorkItemSnapshot',
	#superclass : 'CFObject',
	#instVars : [
		'workItemIdentifier',
		'userTaskIdentifier',
		'actualOwner',
		'taskPriority',
		'potentialOwners'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'instance creation' }
CPUserTaskWorkItemSnapshot class >> from: aCPUserTaskWorkItem [
	^ self new
		initializeFrom: aCPUserTaskWorkItem;
		yourself
]

{ #category : 'initialization' }
CPUserTaskWorkItemSnapshot >> initializeFrom: aCPUserTaskWorkItem [
	workItemIdentifier := aCPUserTaskWorkItem identifier.
	userTaskIdentifier := aCPUserTaskWorkItem activityExecution modeledActivityExecution definition identifier.
	actualOwner := aCPUserTaskWorkItem actualOwner.
	taskPriority := aCPUserTaskWorkItem taskPriority.
	potentialOwners := aCPUserTaskWorkItem potentialOwners asArray.
	^ self
]

{ #category : 'accessing' }
CPUserTaskWorkItemSnapshot >> workItemIdentifier [ ^ workItemIdentifier ]
{ #category : 'accessing' }
CPUserTaskWorkItemSnapshot >> userTaskIdentifier [ ^ userTaskIdentifier ]
{ #category : 'accessing' }
CPUserTaskWorkItemSnapshot >> actualOwner [ ^ actualOwner ]
{ #category : 'accessing' }
CPUserTaskWorkItemSnapshot >> taskPriority [ ^ taskPriority ]
{ #category : 'accessing' }
CPUserTaskWorkItemSnapshot >> potentialOwners [ ^ potentialOwners copy ]
