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
CPExecutionEnvironment >> evaluateExpression: anExpression forProcessDeployment: aProcessDeployment [
	"Evaluate an expression that exists before a Process execution/scope. In particular,
	Conditional Start Events cannot refer to Process-instance data because no instance exists yet."
	self subclassResponsibility
]

{ #category : 'evaluation' }
CPExecutionEnvironment >> evaluateExpression: anExpression in: anExecutionScope forActivityExecution: anActivityExecution [
	^ self evaluateExpression: anExpression in: anExecutionScope
]

{ #category : 'evaluation' }
CPExecutionEnvironment >> evaluateExpression: anExpression in: anExecutionScope forEventExecution: anEventExecution [
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


{ #category : 'execution' }
CPExecutionEnvironment >> distributeUserTaskWorkItem: aWorkItem in: anExecutionScope [
    self subclassResponsibility
]


{ #category : 'resolution' }
CPExecutionEnvironment >> resolveResource: aResource parameterValues: parameterValues in: anExecutionScope forActivityExecution: anActivityExecution [
	self subclassResponsibility
]


{ #category : 'timing' }
CPExecutionEnvironment >> currentTimerTime [
	^ DateAndTime now
]

{ #category : 'timing' }
CPExecutionEnvironment >> timerDueAtFor: aTimerEventDefinition armedAt: anArmingTime in: anExecutionScope [
	"BPMN Timer expressions are expressions. Their language and value interpretation
	belong to the execution environment, just as other executable BPMN expressions do.
	The semantic kernel consumes only the resulting comparable due time."
	self subclassResponsibility
]


{ #category : 'timing' }
CPExecutionEnvironment >> timerDueAtFor: aTimerEventDefinition armedAt: anArmingTime forProcessDeployment: aProcessDeployment [
	"Evaluate a Timer that exists before a Process execution/scope. Deployment-level
	initiation deliberately has no fake execution scope."
	self subclassResponsibility
]

{ #category : 'evaluation' }
CPExecutionEnvironment >> executeAssignment: anAssignment in: anExecutionScope forActivityExecution: anActivityExecution [
	"Assignment l-value semantics belong to the expression environment. The BPMN kernel
	orders assignments and supplies the Activity execution context; the environment
	interprets the from/to expression languages and performs the copy."
	self subclassResponsibility
]

{ #category : 'evaluation' }
CPExecutionEnvironment >> executeAssignment: anAssignment in: anExecutionScope forEventExecution: anEventExecution [
	"Event assignments use the same expression-language boundary, with the Event
	execution supplied so Event-owned inputs/outputs are part of the evaluation context."
	self subclassResponsibility
]
