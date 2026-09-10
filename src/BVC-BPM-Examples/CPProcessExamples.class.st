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

{ #category : 'examples - process validation' }
CPProcessExamples >> simpleProcessValidationIsValid [
	<gtExample>
	| result |
	result := self simpleProcess validationResult.
	self assert: result isValid.
	^ result
]

{ #category : 'examples - process validation' }
CPProcessExamples >> incompleteStartAndEndAreReported [
	<gtExample>
	| process start finish result |
	process := CPProcess new label: 'Incomplete process'; yourself.
	start := CPStartEvent new label: 'Start'; yourself.
	finish := CPEndEvent new label: 'End'; yourself.
	process addFlowElement: start; addFlowElement: finish.
	result := process validationResult.
	self assert: result errors size equals: 2.
	self assert: (result errors anySatisfy: [ :each | each subject == start ]).
	self assert: (result errors anySatisfy: [ :each | each subject == finish ]).
	^ result
]

{ #category : 'examples - process validation' }
CPProcessExamples >> duplicateSequenceFlowConnectionIsRejected [
	<gtExample>
	| process topology start task existing result |
	process := CPProcess new.
	start := CPStartEvent new label: 'Start'; yourself.
	task := CPUserTask new label: 'Task'; yourself.
	existing := CPSequenceFlow new sourceRef: start; targetRef: task; yourself.
	process addFlowElement: start; addFlowElement: task; addFlowElement: existing.
	topology := CPProcessTopology fromProcess: process.
	result := CPSequenceFlowConnectionRules new assessConnectionFrom: start to: task in: topology.
	self assert: result isAllowed not.
	^ result
]

{ #category : 'examples - process validation' }
CPProcessExamples >> multipleOutgoingTaskSequenceFlowsAreAllowed [
	<gtExample>
	| process topology task firstTarget secondTarget existing result |
	process := CPProcess new.
	task := CPUserTask new label: 'Task'; yourself.
	firstTarget := CPUserTask new label: 'First'; yourself.
	secondTarget := CPUserTask new label: 'Second'; yourself.
	existing := CPSequenceFlow new sourceRef: task; targetRef: firstTarget; yourself.
	process addFlowElement: task; addFlowElement: firstTarget; addFlowElement: secondTarget; addFlowElement: existing.
	topology := CPProcessTopology fromProcess: process.
	result := CPSequenceFlowConnectionRules new assessConnectionFrom: task to: secondTarget in: topology.
	self assert: result isAllowed.
	^ result
]


{ #category : 'examples - collaboration' }
CPProcessExamples >> definitionalCollaborationReferencesProcessAndParticipants [
	<gtExample>
	| process collaboration localParticipant externalParticipant |
	process := CPProcess new label: 'Order handling'; yourself.
	collaboration := CPCollaboration new label: 'Order collaboration'; yourself.
	localParticipant := CPParticipant new
		label: 'Seller';
		processRef: process;
		yourself.
	externalParticipant := CPParticipant new
		label: 'Buyer';
		yourself.
	collaboration
		addParticipant: localParticipant;
		addParticipant: externalParticipant.
	process definitionalCollaborationRef: collaboration.

	self assert: process definitionalCollaborationRef == collaboration.
	self assert: collaboration participants size equals: 2.
	self assert: localParticipant processRef == process.
	self assert: externalParticipant processRef isNil.
	^ collaboration
]


{ #category : 'examples - collaboration' }
CPProcessExamples >> messageFlowBetweenSeparateParticipantsIsAllowed [
	<gtExample>
	| process collaboration localParticipant externalParticipant task result |
	process := CPProcess new label: 'Seller process'; yourself.
	task := CPUserTask new label: 'Send quote'; yourself.
	process addFlowElement: task.
	localParticipant := CPParticipant new label: 'Seller'; processRef: process; yourself.
	externalParticipant := CPParticipant new label: 'Buyer'; yourself.
	collaboration := CPCollaboration new label: 'Sale'; yourself.
	collaboration
		addParticipant: localParticipant;
		addParticipant: externalParticipant.

	result := CPMessageFlowConnectionRules new
		assessConnectionFrom: task
		to: externalParticipant
		in: collaboration.

	self assert: result isAllowed.
	self assert: (collaboration participantForEndpoint: task) == localParticipant.
	self assert: (collaboration participantForEndpoint: externalParticipant) == externalParticipant.
	^ result
]


{ #category : 'examples - collaboration' }
CPProcessExamples >> messageFlowInsideSameParticipantIsRejected [
	<gtExample>
	| process collaboration participant sender receiver result |
	process := CPProcess new label: 'Seller process'; yourself.
	sender := CPUserTask new label: 'Prepare quote'; yourself.
	receiver := CPUserTask new label: 'Send quote'; yourself.
	process
		addFlowElement: sender;
		addFlowElement: receiver.
	participant := CPParticipant new label: 'Seller'; processRef: process; yourself.
	collaboration := CPCollaboration new.
	collaboration addParticipant: participant.

	result := CPMessageFlowConnectionRules new
		assessConnectionFrom: sender
		to: receiver
		in: collaboration.

	self assert: result isAllowed not.
	^ result
]


{ #category : 'examples - collaboration' }
CPProcessExamples >> nestedFlowNodeResolvesToOwningParticipant [
	<gtExample>
	| process subProcess nestedTask collaboration participant |
	process := CPProcess new label: 'Seller process'; yourself.
	subProcess := CPNoneSubProcess new label: 'Fulfil'; yourself.
	nestedTask := CPUserTask new label: 'Pack'; yourself.
	process addFlowElement: subProcess.
	subProcess addFlowElement: nestedTask.
	participant := CPParticipant new label: 'Seller'; processRef: process; yourself.
	collaboration := CPCollaboration new.
	collaboration addParticipant: participant.

	self assert: nestedTask owningProcess == process.
	self assert: (collaboration participantForEndpoint: nestedTask) == participant.
	^ participant
]


{ #category : 'examples - collaboration' }
CPProcessExamples >> gatewayCannotBeMessageFlowEndpoint [
	<gtExample>
	| firstProcess secondProcess collaboration firstParticipant secondParticipant gateway task result |
	firstProcess := CPProcess new.
	secondProcess := CPProcess new.
	gateway := CPExclusiveGateway new.
	task := CPUserTask new.
	firstProcess addFlowElement: gateway.
	secondProcess addFlowElement: task.
	firstParticipant := CPParticipant new processRef: firstProcess; yourself.
	secondParticipant := CPParticipant new processRef: secondProcess; yourself.
	collaboration := CPCollaboration new.
	collaboration
		addParticipant: firstParticipant;
		addParticipant: secondParticipant.

	result := CPMessageFlowConnectionRules new
		assessConnectionFrom: gateway
		to: task
		in: collaboration.

	self assert: result isAllowed not.
	^ result
]


{ #category : 'examples - collaboration' }
CPProcessExamples >> collaborationOwnsMessageFlowSemanticRelationship [
	<gtExample>
	| firstParticipant secondParticipant collaboration flow |
	firstParticipant := CPParticipant new label: 'Buyer'; yourself.
	secondParticipant := CPParticipant new label: 'Seller'; yourself.
	collaboration := CPCollaboration new label: 'Purchase'; yourself.
	collaboration
		addParticipant: firstParticipant;
		addParticipant: secondParticipant.
	flow := CPMessageFlow new
		label: 'Order';
		sourceRef: firstParticipant;
		targetRef: secondParticipant;
		yourself.
	collaboration addMessageFlow: flow.

	self assert: collaboration messageFlows size equals: 1.
	self assert: collaboration messageFlows first == flow.
	self assert: flow sourceRef == firstParticipant.
	self assert: flow targetRef == secondParticipant.
	^ collaboration
]

{ #category : 'examples - lanes' }
CPProcessExamples >> processWithTwoLanes [
	<gtExample>
	| process laneSet reviewLane approveLane review approve diagram reviewLaneShape approveLaneShape |
	process := CPProcess new label: 'Lane process'; yourself.
	review := CPUserTask new label: 'Review'; yourself.
	approve := CPUserTask new label: 'Approve'; yourself.
	process
		addFlowElement: review;
		addFlowElement: approve.

	laneSet := CPLaneSet new label: 'Responsibilities'; yourself.
	reviewLane := CPLane new label: 'Reviewer'; yourself.
	approveLane := CPLane new label: 'Approver'; yourself.
	reviewLane addFlowNodeRef: review.
	approveLane addFlowNodeRef: approve.
	laneSet
		addLane: reviewLane;
		addLane: approveLane.
	process addLaneSet: laneSet.

	diagram := CPDiagram new.
	process diagram: diagram.
	reviewLaneShape := CPShape new
		modelElement: reviewLane;
		bounds: (40 @ 40 extent: 500 @ 140);
		yourself.
	approveLaneShape := CPShape new
		modelElement: approveLane;
		bounds: (40 @ 180 extent: 500 @ 140);
		yourself.
	diagram
		addElement: reviewLaneShape;
		addElement: approveLaneShape.

	self assert: process laneSets equals: { laneSet } asOrderedCollection.
	self assert: laneSet process == process.
	self assert: laneSet lanes equals: { reviewLane. approveLane } asOrderedCollection.
	self assert: reviewLane laneSet == laneSet.
	self assert: approveLane laneSet == laneSet.
	self assert: reviewLane flowNodeRefs equals: { review } asOrderedCollection.
	self assert: approveLane flowNodeRefs equals: { approve } asOrderedCollection.
	self assert: review container == process.
	self assert: approve container == process.
	self assert: diagram elements size equals: 2.

	^ process
]

{ #category : 'examples - lanes' }
CPProcessExamples >> nestedLaneSetBelongsToParentLane [
	<gtExample>
	| process outerSet parentLane childSet firstChild secondChild |
	process := CPProcess new.
	outerSet := CPLaneSet new.
	parentLane := CPLane new label: 'Operations'; yourself.
	childSet := CPLaneSet new.
	firstChild := CPLane new label: 'Morning'; yourself.
	secondChild := CPLane new label: 'Evening'; yourself.

	childSet
		addLane: firstChild;
		addLane: secondChild.
	parentLane childLaneSet: childSet.
	outerSet addLane: parentLane.
	process addLaneSet: outerSet.

	self assert: outerSet process == process.
	self assert: outerSet parentLane isNil.
	self assert: childSet process isNil.
	self assert: childSet parentLane == parentLane.
	self assert: parentLane childLaneSet == childSet.
	self assert: firstChild laneSet == childSet.
	self assert: secondChild laneSet == childSet.

	^ parentLane
]

{ #category : 'examples - bpmn conformance' }
CPProcessExamples >> subProcessSupportsLaneSets [
	<gtExample>
	| process subProcess laneSet lane task |
	process := CPProcess new label: 'Process'; yourself.
	subProcess := CPNoneSubProcess new label: 'Sub process'; yourself.
	laneSet := CPLaneSet new label: 'Sub-process lanes'; yourself.
	lane := CPLane new label: 'Reviewer'; yourself.
	task := CPUserTask new label: 'Review'; yourself.

	process addFlowElement: subProcess.
	subProcess addFlowElement: task.
	lane addFlowNodeRef: task.
	laneSet addLane: lane.
	subProcess addLaneSet: laneSet.

	self assert: subProcess laneSets size equals: 1.
	self assert: subProcess laneSets first == laneSet.
	self assert: laneSet lanes first == lane.
	self assert: lane flowNodeRefs first == task.
	^ subProcess
]

{ #category : 'examples - bpmn conformance' }
CPProcessExamples >> laneSetDescriptionIsOrdered [
	<gtExample>
	| description |
	description := CPLaneSet new lanesDescription.
	self assert: description isOrdered.
	^ description
]

{ #category : 'examples - bpmn conformance' }
CPProcessExamples >> messageFlowDescriptionsUseInteractionNodeClasses [
	<gtExample>
	| messageFlow expectedClasses |
	messageFlow := CPMessageFlow new.
	expectedClasses := { CPParticipant. CPActivity. CPEvent } asSet.
	self assert: messageFlow sourceRefDescription classes asSet equals: expectedClasses.
	self assert: messageFlow targetRefDescription classes asSet equals: expectedClasses.
	self deny: (messageFlow sourceRefDescription classes includes: CPGateway).
	^ messageFlow
]

{ #category : 'examples - bpmn conformance' }
CPProcessExamples >> definitionsOwnSemanticRootsAndDiagrams [
	<gtExample>
	| definitions process collaboration diagram |
	definitions := CPDefinitions new targetNamespace: 'urn:catalyst:example'; yourself.
	process := CPProcess new label: 'Process'; yourself.
	collaboration := CPCollaboration new label: 'Collaboration'; yourself.
	diagram := CPDiagram new.

	definitions
		addRootElement: process;
		addRootElement: collaboration;
		addDiagram: diagram.

	self assert: definitions rootElements size equals: 2.
	self assert: definitions rootElements first == process.
	self assert: definitions rootElements second == collaboration.
	self assert: definitions diagrams size equals: 1.
	self assert: definitions diagrams first == diagram.
	^ definitions
]
