Class {
    #name : 'CPCompleteUserTaskWorkUnit',
    #superclass : 'CRWorkUnit',
    #instVars : [
        'processExecutionIdentifier',
        'workItemIdentifier'
    ],
    #category : 'BVC-BPM-Automation',
    #package : 'BVC-BPM-Automation'
}

{ #category : 'service context' }
CPCompleteUserTaskWorkUnit class >> serviceClass [
    ^ CPBpmService
]

{ #category : 'instance creation' }
CPCompleteUserTaskWorkUnit class >> processExecutionIdentifier: aProcessExecutionIdentifier workItemIdentifier: aWorkItemIdentifier [
    ^ self new
        processExecutionIdentifier: aProcessExecutionIdentifier;
        workItemIdentifier: aWorkItemIdentifier;
        yourself
]

{ #category : 'accessing' }
CPCompleteUserTaskWorkUnit >> processExecutionIdentifier [
    ^ processExecutionIdentifier
]

{ #category : 'accessing' }
CPCompleteUserTaskWorkUnit >> processExecutionIdentifier: anIdentifier [
    processExecutionIdentifier := anIdentifier
]

{ #category : 'accessing' }
CPCompleteUserTaskWorkUnit >> workItemIdentifier [
    ^ workItemIdentifier
]

{ #category : 'accessing' }
CPCompleteUserTaskWorkUnit >> workItemIdentifier: anIdentifier [
    workItemIdentifier := anIdentifier
]

{ #category : 'running' }
CPCompleteUserTaskWorkUnit >> executeInContext: aCRWorkUnitExecutionContext [
    ^ aCRWorkUnitExecutionContext service completeUserTaskWorkUnit: self
]
