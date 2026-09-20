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
