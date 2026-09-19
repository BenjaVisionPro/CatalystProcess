Class {
	#name : 'CPExecutionEnvironment',
	#superclass : 'Object',
	#category : 'BVC-BPM-Execution',
	#package : 'BVC-BPM-Execution'
}

{ #category : 'evaluation' }
CPExecutionEnvironment >> evaluateExpression: anExpression in: anExecutionScope [
	self subclassResponsibility
]

{ #category : 'resolution' }
CPExecutionEnvironment >> resolveCallableElement: aCallableElement in: anExecutionScope [
	self subclassResponsibility
]
