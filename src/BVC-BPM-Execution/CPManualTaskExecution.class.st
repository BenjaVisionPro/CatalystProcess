Class {
	#name : 'CPManualTaskExecution',
	#superclass : 'CPActivityExecution',
	#instVars : [ 'resourceAssignments' ],
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'assignment' }
CPManualTaskExecution >> resourceAssignments [
	^ resourceAssignments ifNil: [ #() ]
]

{ #category : 'assignment' }
CPManualTaskExecution >> resourceAssignments: aCollection [
	resourceAssignments ifNotNil: [
		self error: 'A Manual Task execution can resolve its resource assignments only once.' ].
	resourceAssignments := aCollection asOrderedCollection.
	^ resourceAssignments
]

{ #category : 'multi-instance' }
CPManualTaskExecution >> multiInstanceActivityExecutionDidBegin: anInstance [
	super multiInstanceActivityExecutionDidBegin: anInstance.
	scope assignMultiInstanceManualTaskExecution: anInstance.
	^ anInstance
]
