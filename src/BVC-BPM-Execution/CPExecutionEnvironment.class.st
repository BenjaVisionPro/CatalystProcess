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

{ #category : 'evaluation' }
CPExecutionEnvironment >> evaluateExpression: anExpression in: anExecutionScope forActivityExecution: anActivityExecution [
	^ self evaluateExpression: anExpression in: anExecutionScope
]

{ #category : 'resolution' }
CPExecutionEnvironment >> resolveCallableElement: aCallableElement in: anExecutionScope [
	self subclassResponsibility
]

{ #category : 'resolution' }
CPExecutionEnvironment >> resolveOperation: anOperation in: anExecutionScope [
	self subclassResponsibility
]

{ #category : 'execution' }
CPExecutionEnvironment >> executeScriptTask: aScriptTask in: anExecutionScope forActivityExecution: anActivityExecution [
	self subclassResponsibility
]

{ #category : 'execution' }
CPExecutionEnvironment >> executeBusinessRuleTask: aBusinessRuleTask in: anExecutionScope forActivityExecution: anActivityExecution [
	self subclassResponsibility
]
