Class {
    #name : 'CPUserTaskExecution',
    #superclass : 'CPActivityExecution',
    #instVars : [
        'workItem'
    ],
    #category : 'BVC-BPM-Execution',
    #package : 'BVC-BPM-Execution'
}

{ #category : 'accessing' }
CPUserTaskExecution >> workItem [ ^ workItem ]

{ #category : 'accessing' }
CPUserTaskExecution >> workItem: aWorkItem [
    workItem ifNotNil: [ self error: 'A User Task execution can have only one work item.' ].
    workItem := aWorkItem
]

{ #category : 'multi-instance' }
CPUserTaskExecution >> multiInstanceActivityExecutionDidBegin: anInstance [
    super multiInstanceActivityExecutionDidBegin: anInstance.
    scope distributeMultiInstanceUserTaskExecution: anInstance.
    ^ anInstance
]


{ #category : 'assignment' }
CPUserTaskExecution >> actualOwner [
    workItem ifNil: [ ^ nil ].
    ^ workItem actualOwner
]

{ #category : 'assignment' }
CPUserTaskExecution >> claimBy: anOwnerIdentifier [
    workItem ifNil: [ self error: 'The User Task execution has no distributed work item.' ].
    ^ workItem claimBy: anOwnerIdentifier
]

{ #category : 'assignment' }
CPUserTaskExecution >> taskPriority [
    workItem ifNil: [ ^ nil ].
    ^ workItem taskPriority
]

{ #category : 'assignment' }
CPUserTaskExecution >> taskPriority: anInteger [
    workItem ifNil: [ self error: 'The User Task execution has no distributed work item.' ].
    ^ workItem taskPriority: anInteger
]


{ #category : 'standard loop' }
CPUserTaskExecution >> standardLoopIterationDidBegin: anIteration [
	super standardLoopIterationDidBegin: anIteration.
	scope distributeStandardLoopUserTaskIteration: anIteration.
	^ anIteration
]

{ #category : 'work items' }
CPUserTaskExecution >> userTaskWorkItems [
    | items |
    items := OrderedCollection new.
    workItem ifNotNil: [ items add: workItem ].
    self multiInstanceActivityExecutions do: [ :each |
        each userTaskWorkItem ifNotNil: [ :item | items add: item ] ].
    self standardLoopIterations do: [ :each |
        each userTaskWorkItem ifNotNil: [ :item | items add: item ] ].
    ^ items
]

{ #category : 'work items' }
CPUserTaskExecution >> completeUserTaskWorkInScope: anExecutionScope [
    ^ anExecutionScope completeUserTaskExecution: self
]
