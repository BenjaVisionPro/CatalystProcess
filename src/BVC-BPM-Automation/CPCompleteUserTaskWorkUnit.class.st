Class {
    #name : 'CPCompleteUserTaskWorkUnit',
    #superclass : 'CRWorkUnit',
    #instVars : [ 'workItem', 'outputValue' ],
    #category : 'BVC-BPM-Automation',
    #package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPCompleteUserTaskWorkUnit class >> serviceClass [ ^ CPBpmService ]

{ #category : 'instance creation' }
CPCompleteUserTaskWorkUnit class >> workItem: aCPUserTaskWorkItem [
    ^ self new workItem: aCPUserTaskWorkItem; yourself
]


{ #category : 'instance creation' }
CPCompleteUserTaskWorkUnit class >> workItem: aCPUserTaskWorkItem outputValue: anObject [
    ^ self new
        workItem: aCPUserTaskWorkItem;
        outputValue: anObject;
        yourself
]

{ #category : 'accessing' }
CPCompleteUserTaskWorkUnit >> workItem [ ^ workItem ]

{ #category : 'accessing' }
CPCompleteUserTaskWorkUnit >> workItem: aCPUserTaskWorkItem [ workItem := aCPUserTaskWorkItem ]

{ #category : 'accessing' }
CPCompleteUserTaskWorkUnit >> outputValue [ ^ outputValue ]

{ #category : 'accessing' }
CPCompleteUserTaskWorkUnit >> outputValue: anObject [ outputValue := anObject ]

{ #category : 'running' }
CPCompleteUserTaskWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
    ^ aCRWorkUnitExecutionContext service completeUserTaskWorkUnit: self
]
