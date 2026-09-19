Class {
	#name : 'CPExampleExecutionEnvironment',
	#superclass : 'CPExecutionEnvironment',
	#instVars : [
		'expressionResults',
		'callableResolutions',
		'operationResolutions'
	],
	#category : 'BVC-BPM-Examples',
	#package : 'BVC-BPM-Examples'
}

{ #category : 'initialization' }
CPExampleExecutionEnvironment >> initialize [
	super initialize.
	expressionResults := IdentityDictionary new.
	callableResolutions := IdentityDictionary new.
	operationResolutions := IdentityDictionary new
]

{ #category : 'configuration' }
CPExampleExecutionEnvironment >> expression: anExpression evaluatesTo: aBoolean [
	expressionResults at: anExpression put: aBoolean.
	^ self
]

{ #category : 'configuration' }
CPExampleExecutionEnvironment >> callableElement: aCallableElement resolvesTo: aProcess [
	callableResolutions at: aCallableElement put: aProcess.
	^ self
]

{ #category : 'evaluation' }
CPExampleExecutionEnvironment >> evaluateExpression: anExpression in: anExecutionScope [
	^ expressionResults
		at: anExpression
		ifAbsent: [ self error: 'No example expression result has been configured.' ]
]

{ #category : 'resolution' }
CPExampleExecutionEnvironment >> resolveCallableElement: aCallableElement in: anExecutionScope [
	^ callableResolutions
		at: aCallableElement
		ifAbsent: [ self error: 'No example callable resolution has been configured.' ]
]


{ #category : 'configuration' }
CPExampleExecutionEnvironment >> operation: anOperation resolvesTo: anImplementation [
	operationResolutions at: anOperation put: anImplementation.
	^ self
]

{ #category : 'resolution' }
CPExampleExecutionEnvironment >> resolveOperation: anOperation in: anExecutionScope [
	^ operationResolutions
		at: anOperation
		ifAbsent: [ self error: 'No example Operation resolution has been configured.' ]
]
