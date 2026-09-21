Class {
    #name : 'CPCompleteUserTaskWorkUnit',
    #superclass : 'CRWorkUnit',
    #instVars : [ 'workItem' ],
    #category : 'BVC-BPM-Automation',
    #package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPCompleteUserTaskWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPCompleteUserTaskWorkUnit class >> workItem: aCPUserTaskWorkItem [
    ^ self new workItem: aCPUserTaskWorkItem; yourself
]

{ #category : 'accessing' }
CPCompleteUserTaskWorkUnit >> workItem [ ^ workItem ]

{ #category : 'accessing' }
CPCompleteUserTaskWorkUnit >> workItem: aCPUserTaskWorkItem [ workItem := aCPUserTaskWorkItem ]

{ #category : 'running' }
CPCompleteUserTaskWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
    ^ aCRWorkUnitExecutionContext service completeUserTaskWorkUnit: self
]
