Class {
	#name : 'CPExampleExecutionEnvironment',
	#superclass : 'CPExecutionEnvironment',
	#instVars : [
		'expressionResults',
		'callableResolutions',
		'operationResolutions',
		'lastActivityExecutionUsedForExpressionEvaluation',
		'lastLoopCounterAtExpressionEvaluation',
		'scriptTaskExecutions',
		'businessRuleTaskExecutions',
		'userTaskWorkItems',
		'resourceResolutions',
		'lastResolvedResource',
		'lastResourceParameterValues',
		'currentTimerTime',
		'timerDueTimes'
	],
	#category : 'BVC-BPM-Examples',
	#package : 'BVC-BPM-Examples'
}

{ #category : 'initialization' }
CPExampleExecutionEnvironment >> initialize [
	super initialize.
	expressionResults := IdentityDictionary new.
	callableResolutions := IdentityDictionary new.
	operationResolutions := IdentityDictionary new.
	scriptTaskExecutions := OrderedCollection new.
	businessRuleTaskExecutions := OrderedCollection new.
	userTaskWorkItems := OrderedCollection new.
	resourceResolutions := IdentityDictionary new.
	lastResourceParameterValues := OrderedCollection new.
	currentTimerTime := DateAndTime now.
	timerDueTimes := IdentityDictionary new
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


{ #category : 'evaluation' }
CPExampleExecutionEnvironment >> evaluateExpression: anExpression in: anExecutionScope forActivityExecution: anActivityExecution [
	lastActivityExecutionUsedForExpressionEvaluation := anActivityExecution.
	lastLoopCounterAtExpressionEvaluation := anActivityExecution loopCounter.
	^ self evaluateExpression: anExpression in: anExecutionScope
]

{ #category : 'accessing' }
CPExampleExecutionEnvironment >> lastActivityExecutionUsedForExpressionEvaluation [
	^ lastActivityExecutionUsedForExpressionEvaluation
]

{ #category : 'accessing' }
CPExampleExecutionEnvironment >> lastLoopCounterAtExpressionEvaluation [
	^ lastLoopCounterAtExpressionEvaluation
]


{ #category : 'execution' }
CPExampleExecutionEnvironment >> executeScriptTask: aScriptTask in: anExecutionScope forActivityExecution: anActivityExecution [
	scriptTaskExecutions add: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'accessing' }
CPExampleExecutionEnvironment >> scriptTaskExecutions [
	^ scriptTaskExecutions
]


{ #category : 'execution' }
CPExampleExecutionEnvironment >> executeBusinessRuleTask: aBusinessRuleTask in: anExecutionScope forActivityExecution: anActivityExecution [
	businessRuleTaskExecutions add: anActivityExecution.
	^ anActivityExecution
]

{ #category : 'accessing' }
CPExampleExecutionEnvironment >> businessRuleTaskExecutions [
	^ businessRuleTaskExecutions
]


{ #category : 'execution' }
CPExampleExecutionEnvironment >> distributeUserTaskWorkItem: aWorkItem in: anExecutionScope [
    userTaskWorkItems add: aWorkItem.
    ^ aWorkItem
]

{ #category : 'accessing' }
CPExampleExecutionEnvironment >> userTaskWorkItems [
    ^ userTaskWorkItems
]


{ #category : 'configuration' }
CPExampleExecutionEnvironment >> resource: aResource resolvesTo: aCollection [
	resourceResolutions at: aResource put: aCollection asOrderedCollection.
	^ self
]

{ #category : 'resolution' }
CPExampleExecutionEnvironment >> resolveResource: aResource parameterValues: parameterValues in: anExecutionScope forActivityExecution: anActivityExecution [
	lastResolvedResource := aResource.
	lastResourceParameterValues := parameterValues asOrderedCollection.
	^ resourceResolutions
		at: aResource
		ifAbsent: [ #() ]
]

{ #category : 'accessing' }
CPExampleExecutionEnvironment >> lastResolvedResource [
	^ lastResolvedResource
]

{ #category : 'accessing' }
CPExampleExecutionEnvironment >> lastResourceParameterValues [
	^ lastResourceParameterValues
]


{ #category : 'configuration' }
CPExampleExecutionEnvironment >> currentTimerTime: aTime [
	currentTimerTime := aTime.
	^ self
]

{ #category : 'timing' }
CPExampleExecutionEnvironment >> currentTimerTime [
	^ currentTimerTime
]

{ #category : 'configuration' }
CPExampleExecutionEnvironment >> timerDefinition: aTimerDefinition dueAt: aTime [
	timerDueTimes at: aTimerDefinition put: aTime.
	^ self
]

{ #category : 'timing' }
CPExampleExecutionEnvironment >> timerDueAtFor: aTimerEventDefinition armedAt: anArmingTime in: anExecutionScope [
	^ timerDueTimes
		at: aTimerEventDefinition
		ifAbsent: [ self error: 'No example Timer due time has been configured.' ]
]
