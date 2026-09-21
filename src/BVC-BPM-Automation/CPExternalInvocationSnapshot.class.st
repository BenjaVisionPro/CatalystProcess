Class {
	#name : 'CPExternalInvocationSnapshot',
	#superclass : 'CFObject',
	#instVars : [
		'invocationIdentifier',
		'serviceTaskIdentifier',
		'operationIdentifier',
		'implementation',
		'hasInputValue',
		'inputValue'
	],
	#category : 'BVC-BPM-Automation',
	#package : 'BVC-BPM-Automation'
}

{ #category : 'instance creation' }
CPExternalInvocationSnapshot class >> from: aCPExternalInvocation [
	^ self new
		initializeFrom: aCPExternalInvocation;
		yourself
]

{ #category : 'initialization' }
CPExternalInvocationSnapshot >> initializeFrom: aCPExternalInvocation [
	| serviceTask operation |
	serviceTask := aCPExternalInvocation activityExecution modeledActivityExecution definition.
	operation := serviceTask operationRef.
	invocationIdentifier := aCPExternalInvocation invocationIdentifier.
	serviceTaskIdentifier := serviceTask identifier.
	operationIdentifier := operation ifNotNil: [ operation identifier ].
	implementation := aCPExternalInvocation implementation.
	hasInputValue := aCPExternalInvocation hasInputValue.
	hasInputValue ifTrue: [ inputValue := aCPExternalInvocation inputValue ].
	^ self
]

{ #category : 'accessing' }
CPExternalInvocationSnapshot >> invocationIdentifier [ ^ invocationIdentifier ]
{ #category : 'accessing' }
CPExternalInvocationSnapshot >> serviceTaskIdentifier [ ^ serviceTaskIdentifier ]
{ #category : 'accessing' }
CPExternalInvocationSnapshot >> operationIdentifier [ ^ operationIdentifier ]

{ #category : 'accessing' }
CPExternalInvocationSnapshot >> implementation [ ^ implementation ]
{ #category : 'testing' }
CPExternalInvocationSnapshot >> hasInputValue [ ^ hasInputValue ]
{ #category : 'accessing' }
CPExternalInvocationSnapshot >> inputValue [
	hasInputValue ifFalse: [ self error: 'The external invocation snapshot has no input value.' ].
	^ inputValue
]
