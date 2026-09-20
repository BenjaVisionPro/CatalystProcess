Class {
    #name : 'CPUserTaskWorkItem',
    #superclass : 'CFIdentifiableObject',
    #instVars : [
        'userTask',
        'activityExecution',
        'distributed',
        'completed',
        'actualOwner',
        'taskPriority'
    ],
    #category : 'BVC-BPM-Execution',
    #package : 'BVC-BPM-Execution'
}

{ #category : 'initialization' }
CPUserTaskWorkItem >> initialize [
    super initialize.
    distributed := false.
    completed := false
]

{ #category : 'accessing' }
CPUserTaskWorkItem >> userTask [ ^ userTask ]

{ #category : 'accessing' }
CPUserTaskWorkItem >> userTask: aUserTask [
    userTask ifNotNil: [ self error: 'A User Task work item can reference only one User Task.' ].
    aUserTask ifNil: [ self error: 'A User Task work item requires a User Task.' ].
    userTask := aUserTask
]

{ #category : 'accessing' }
CPUserTaskWorkItem >> activityExecution [ ^ activityExecution ]

{ #category : 'accessing' }
CPUserTaskWorkItem >> activityExecution: anActivityExecution [
    activityExecution ifNotNil: [ self error: 'A User Task work item can belong to only one Activity execution.' ].
    activityExecution := anActivityExecution
]

{ #category : 'testing' }
CPUserTaskWorkItem >> isDistributed [ ^ distributed ]

{ #category : 'testing' }
CPUserTaskWorkItem >> isPending [ ^ distributed and: [ completed not ] ]

{ #category : 'testing' }
CPUserTaskWorkItem >> isCompleted [ ^ completed ]

{ #category : 'lifecycle' }
CPUserTaskWorkItem >> markDistributed [
    distributed ifTrue: [ self error: 'A User Task work item can be distributed only once.' ].
    distributed := true.
    ^ self
]

{ #category : 'lifecycle' }
CPUserTaskWorkItem >> complete [
    distributed ifFalse: [ self error: 'A User Task work item must be distributed before it can complete.' ].
    completed ifTrue: [ self error: 'A User Task work item can complete only once.' ].
    completed := true.
    ^ self
]


{ #category : 'assignment' }
CPUserTaskWorkItem >> actualOwner [
    ^ actualOwner
]

{ #category : 'assignment' }
CPUserTaskWorkItem >> claimBy: anOwnerIdentifier [
    self isPending ifFalse: [ self error: 'Only a pending User Task work item can be claimed.' ].
    actualOwner ifNotNil: [ self error: 'A User Task work item can be claimed only once.' ].
    anOwnerIdentifier ifNil: [ self error: 'A User Task work item requires an actual owner when claimed.' ].
    actualOwner := anOwnerIdentifier.
    ^ actualOwner
]

{ #category : 'assignment' }
CPUserTaskWorkItem >> taskPriority [
    ^ taskPriority
]

{ #category : 'assignment' }
CPUserTaskWorkItem >> taskPriority: anInteger [
    self isCompleted ifTrue: [ self error: 'A completed User Task work item cannot change priority.' ].
    taskPriority := anInteger.
    ^ taskPriority
]
