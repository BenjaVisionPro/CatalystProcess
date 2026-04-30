Class {
	#name : 'CPProcessExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Examples',
	#package : 'BVC-BPM-Examples'
}

{ #category : 'examples' }
CPProcessExamples >> emptySystemRoot [
	<gtExample>
	^ CPSystemRoot new
		label: 'Catalyst Process';
		yourself
]

{ #category : 'examples' }
CPProcessExamples >> tenantWithUser [
	<gtExample>
	| root tenant user |
	root := self emptySystemRoot.
	tenant := CPTenant new label: 'Example tenant'; yourself.
	user := CPUser new label: 'Example user'; yourself.
	root addTenant: tenant.
	root addUser: user.
	^ root
]

{ #category : 'examples' }
CPProcessExamples >> simpleUserTaskDesign [
	<gtExample>
	| design start task end edge1 edge2 |
	design := CPProcessDesign new label: 'Simple user task'; yourself.
	start := CPStartEventDesignNode new label: 'Start'; yourself.
	task := CPUserTaskDesignNode new label: 'Review'; yourself.
	end := CPEndEventDesignNode new label: 'End'; yourself.
	edge1 := CPProcessDesignEdge new label: 'start to review'; sourceNode: start; targetNode: task; yourself.
	edge2 := CPProcessDesignEdge new label: 'review to end'; sourceNode: task; targetNode: end; yourself.
	design addNode: start; addNode: task; addNode: end.
	design addEdge: edge1; addEdge: edge2.
	^ design
]

{ #category : 'examples' }
CPProcessExamples >> compiledSimpleUserTaskDefinition [
	<gtExample>
	^ CPProcessCompiler new compileDesign: self simpleUserTaskDesign
]

{ #category : 'examples' }
CPProcessExamples >> activeSimpleUserTaskDeployment [
	<gtExample>
	| result deployment tenant |
	result := self compiledSimpleUserTaskDefinition.
	tenant := CPTenant new label: 'Example tenant'; yourself.
	deployment := CPProcessDeployment new
		label: 'Simple user task v1';
		tenant: tenant;
		version: 1;
		compiledDefinition: result compiledDefinition;
		sourceDesign: result definition sourceDesign;
		processKey: result definition processKey;
		deployedAt: DateAndTime now;
		yourself.
	deployment activate.
	^ deployment
]

{ #category : 'examples' }
CPProcessExamples >> startedSimpleUserTaskInstance [
	<gtExample>
	^ CPRuntimeEngine new
		startProcessFromDeployment: self activeSimpleUserTaskDeployment
		startedBy: (CPUser new label: 'Example user'; yourself)
		input: Dictionary new
]

{ #category : 'examples' }
CPProcessExamples >> completedSimpleUserTaskInstance [
	<gtExample>
	| instance workItem user |
	instance := self startedSimpleUserTaskInstance.
	workItem := instance workItems first.
	user := CPUser new label: 'Example user'; yourself.
	CPRuntimeEngine new completeWorkItem: workItem by: user withOutput: Dictionary new.
	^ instance
]

