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


{ #category : 'examples - process model' }
CPProcessExamples >> simpleProcess [
	<gtExample>
	| process start task finish firstFlow secondFlow diagram startShape taskShape finishShape firstEdge secondEdge |
	process := CPProcess new label: 'Simple process'; yourself.
	start := CPStartEvent new label: 'Start'; yourself.
	task := CPUserTask new label: 'Review'; yourself.
	finish := CPEndEvent new label: 'End'; yourself.

	firstFlow := CPSequenceFlow new
		label: 'start to review';
		sourceRef: start;
		targetRef: task;
		yourself.
	secondFlow := CPSequenceFlow new
		label: 'review to end';
		sourceRef: task;
		targetRef: finish;
		yourself.

	process
		addFlowElement: start;
		addFlowElement: task;
		addFlowElement: finish;
		addFlowElement: firstFlow;
		addFlowElement: secondFlow.

	diagram := CPDiagram new.
	process diagram: diagram.

	startShape := CPShape new modelElement: start; bounds: (100 @ 100 extent: 42 @ 42); yourself.
	taskShape := CPShape new modelElement: task; bounds: (220 @ 94 extent: 132 @ 54); yourself.
	finishShape := CPShape new modelElement: finish; bounds: (430 @ 100 extent: 42 @ 42); yourself.

	firstEdge := CPEdge new modelElement: firstFlow; yourself.
	firstEdge addWaypoint: 142 @ 121; addWaypoint: 220 @ 121.
	secondEdge := CPEdge new modelElement: secondFlow; yourself.
	secondEdge addWaypoint: 352 @ 121; addWaypoint: 430 @ 121.

	diagram
		addElement: startShape;
		addElement: taskShape;
		addElement: finishShape;
		addElement: firstEdge;
		addElement: secondEdge.

	self assert: process flowElements size equals: 5.
	self assert: start outgoing equals: { firstFlow } asOrderedCollection.
	self assert: task incoming equals: { firstFlow } asOrderedCollection.
	self assert: task outgoing equals: { secondFlow } asOrderedCollection.
	self assert: finish incoming equals: { secondFlow } asOrderedCollection.
	self assert: diagram modelElement equals: process.
	self assert: diagram elements size equals: 5.

	^ process
]
