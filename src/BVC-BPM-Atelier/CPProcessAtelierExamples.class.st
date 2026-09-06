"I lock down the executable Process Atelier contract at the semantic-operation boundary.

I exercise the production CPProcess / CPDiagram / CPShape / CPEdge model through CFMaMemento. Assessment must not mutate staged state. Applying an operation must stage the complete semantic and diagram change while leaving the committed model unchanged until commit. Reset must restore the model-backed state."
Class {
	#name : 'CPProcessAtelierExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Atelier-Examples',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Examples'
}

{ #category : 'private - fixture' }
CPProcessAtelierExamples >> fixture [
	| process start task finish firstFlow secondFlow diagram startShape taskShape finishShape firstEdge secondEdge memento |
	process := CPProcess new label: 'Atelier process'; yourself.
	start := CPNoneStartEvent new label: 'Start'; yourself.
	task := CPUserTask new label: 'Review'; yourself.
	finish := CPNoneEndEvent new label: 'End'; yourself.

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

	memento := CFMaMemento model: process.
	^ { process. memento. start. task. finish. firstFlow. secondFlow. diagram. startShape. taskShape. finishShape. firstEdge. secondEdge }
]

{ #category : 'private - accessing staged state' }
CPProcessAtelierExamples >> descriptionFor: aSelector in: aMemento [
	^ aMemento magritteDescription detect: [ :each | each handlesSelector: aSelector ]
]

{ #category : 'private - accessing staged state' }
CPProcessAtelierExamples >> diagramMementoFor: aProcessMemento [
	| diagramDescription diagram |
	diagramDescription := self descriptionFor: #diagram in: aProcessMemento.
	diagram := aProcessMemento readUsing: diagramDescription.
	^ aProcessMemento childMementoFor: diagram inRelation: diagramDescription
]

{ #category : 'private - accessing staged state' }
CPProcessAtelierExamples >> diagramElementsDescriptionIn: aDiagramMemento [
	^ self descriptionFor: #elements in: aDiagramMemento
]

{ #category : 'private - accessing staged state' }
CPProcessAtelierExamples >> stagedBoundsOf: aShape processMemento: aProcessMemento [
	| diagramMemento elementsDescription shapeMemento boundsDescription |
	diagramMemento := self diagramMementoFor: aProcessMemento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	shapeMemento := diagramMemento childMementoFor: aShape inRelation: elementsDescription.
	boundsDescription := self descriptionFor: #bounds in: shapeMemento.
	^ shapeMemento readUsing: boundsDescription
]

{ #category : 'private - accessing staged state' }
CPProcessAtelierExamples >> stagedWaypointsOf: anEdge processMemento: aProcessMemento [
	| diagramMemento elementsDescription edgeMemento waypointsDescription |
	diagramMemento := self diagramMementoFor: aProcessMemento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	edgeMemento := diagramMemento childMementoFor: anEdge inRelation: elementsDescription.
	waypointsDescription := self descriptionFor: #waypoints in: edgeMemento.
	^ edgeMemento readUsing: waypointsDescription
]

{ #category : 'examples - assessment' }
CPProcessAtelierExamples >> moveShapeAssessmentDoesNotMutateStagedState [
	<gtExample>
	| fixture memento taskShape firstEdge secondEdge diagramDescription operation assessment |
	fixture := self fixture.
	memento := fixture second.
	taskShape := fixture at: 10.
	firstEdge := fixture at: 12.
	secondEdge := fixture at: 13.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierMoveShape
		shape: taskShape
		bounds: (260 @ 124 extent: 132 @ 54)
		processMemento: memento
		diagramDescription: diagramDescription.

	assessment := operation assess.

	self assert: assessment isApplicable.
	self assert: (self stagedBoundsOf: taskShape processMemento: memento) equals: (220 @ 94 extent: 132 @ 54).
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: ({ 142 @ 121. 220 @ 121 } asOrderedCollection).
	self assert: (self stagedWaypointsOf: secondEdge processMemento: memento) equals: ({ 352 @ 121. 430 @ 121 } asOrderedCollection).
	^ assessment
]

{ #category : 'examples - diagram movement' }
CPProcessAtelierExamples >> moveShapeStagesBoundsAndIncidentEdgeEndpoints [
	<gtExample>
	| fixture process memento taskShape firstEdge secondEdge diagramDescription operation assessment |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	taskShape := fixture at: 10.
	firstEdge := fixture at: 12.
	secondEdge := fixture at: 13.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierMoveShape
		shape: taskShape
		bounds: (260 @ 124 extent: 132 @ 54)
		processMemento: memento
		diagramDescription: diagramDescription.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (self stagedBoundsOf: taskShape processMemento: memento) equals: (260 @ 124 extent: 132 @ 54).
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: ({ 142 @ 121. 260 @ 151 } asOrderedCollection).
	self assert: (self stagedWaypointsOf: secondEdge processMemento: memento) equals: ({ 392 @ 151. 430 @ 121 } asOrderedCollection).
	self assert: taskShape bounds equals: (220 @ 94 extent: 132 @ 54).
	self assert: firstEdge waypoints equals: ({ 142 @ 121. 220 @ 121 } asOrderedCollection).
	self assert: process diagram == fixture eighth.
	^ memento
]

{ #category : 'examples - diagram movement' }
CPProcessAtelierExamples >> moveConnectedShapesTranslatesCompleteInternalEdgePath [
	<gtExample>
	| fixture memento startShape taskShape firstEdge diagramDescription boundsByShape operation assessment |
	fixture := self fixture.
	memento := fixture second.
	startShape := fixture at: 9.
	taskShape := fixture at: 10.
	firstEdge := fixture at: 12.
	diagramDescription := self descriptionFor: #diagram in: memento.
	boundsByShape := IdentityDictionary new.
	boundsByShape
		at: startShape put: (130 @ 120 extent: 42 @ 42);
		at: taskShape put: (250 @ 114 extent: 132 @ 54).
	operation := CPAtelierMoveShapes
		boundsByShape: boundsByShape
		processMemento: memento
		diagramDescription: diagramDescription.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: assessment delta equals: 30 @ 20.
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: ({ 172 @ 141. 250 @ 141 } asOrderedCollection).
	^ memento
]

{ #category : 'examples - diagram movement' }
CPProcessAtelierExamples >> resizeShapeStagesBoundsAndMovesIncidentEndpointsByCenterDelta [
	<gtExample>
	| fixture memento taskShape firstEdge secondEdge diagramDescription operation assessment |
	fixture := self fixture.
	memento := fixture second.
	taskShape := fixture at: 10.
	firstEdge := fixture at: 12.
	secondEdge := fixture at: 13.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierResizeShape
		shape: taskShape
		bounds: (220 @ 94 extent: 172 @ 74)
		processMemento: memento
		diagramDescription: diagramDescription.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (self stagedBoundsOf: taskShape processMemento: memento) equals: (220 @ 94 extent: 172 @ 74).
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: ({ 142 @ 121. 240 @ 131 } asOrderedCollection).
	self assert: (self stagedWaypointsOf: secondEdge processMemento: memento) equals: ({ 372 @ 131. 430 @ 121 } asOrderedCollection).
	^ memento
]

{ #category : 'examples - routing' }
CPProcessAtelierExamples >> setEdgeWaypointsStagesRoutingWithoutMutatingModel [
	<gtExample>
	| fixture memento firstEdge diagramDescription proposed operation assessment |
	fixture := self fixture.
	memento := fixture second.
	firstEdge := fixture at: 12.
	diagramDescription := self descriptionFor: #diagram in: memento.
	proposed := { 142 @ 121. 180 @ 170. 220 @ 121 } asOrderedCollection.
	operation := CPAtelierSetEdgeWaypoints
		edge: firstEdge
		waypoints: proposed
		processMemento: memento
		diagramDescription: diagramDescription.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: proposed.
	self assert: firstEdge waypoints equals: ({ 142 @ 121. 220 @ 121 } asOrderedCollection).
	^ memento
]

{ #category : 'examples - labels' }
CPProcessAtelierExamples >> setEdgeLabelPlacementStagesAllPlacementValues [
	<gtExample>
	| fixture memento firstEdge diagramDescription operation assessment diagramMemento elementsDescription edgeMemento |
	fixture := self fixture.
	memento := fixture second.
	firstEdge := fixture at: 12.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierSetEdgeLabelPlacement
		edge: firstEdge
		segmentIndex: 1
		segmentPosition: 0.35
		offset: 18
		processMemento: memento
		diagramDescription: diagramDescription.

	assessment := operation apply.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	edgeMemento := diagramMemento childMementoFor: firstEdge inRelation: elementsDescription.

	self assert: assessment isApplicable.
	self assert: (edgeMemento readUsing: (self descriptionFor: #labelSegmentIndex in: edgeMemento)) equals: 1.
	self assert: (edgeMemento readUsing: (self descriptionFor: #labelSegmentPosition in: edgeMemento)) equals: 0.35.
	self assert: (edgeMemento readUsing: (self descriptionFor: #labelOffset in: edgeMemento)) equals: 18.
	self assert: firstEdge labelSegmentIndex isNil.
	self assert: firstEdge labelSegmentPosition isNil.
	self assert: firstEdge labelOffset isNil.
	^ memento
]

{ #category : 'examples - semantic topology' }
CPProcessAtelierExamples >> connectFlowNodesStagesSemanticFlowAndDiagramEdgeTogether [
	<gtExample>
	| fixture memento start finish flowElementsDescription diagramDescription operation assessment stagedFlowElements diagramMemento elementsDescription stagedElements flowMemento |
	fixture := self fixture.
	memento := fixture second.
	start := fixture third.
	finish := fixture fifth.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierConnectFlowNodes
		source: start
		target: finish
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramDescription: diagramDescription.

	assessment := operation apply.
	stagedFlowElements := memento readUsing: flowElementsDescription.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.
	flowMemento := memento childMementoFor: assessment sequenceFlow inRelation: flowElementsDescription.

	self assert: assessment isApplicable.
	self assert: (stagedFlowElements identityIncludes: assessment sequenceFlow).
	self assert: (stagedElements identityIncludes: assessment edge).
	self assert: (flowMemento readUsing: (self descriptionFor: #sourceRef in: flowMemento)) == start.
	self assert: (flowMemento readUsing: (self descriptionFor: #targetRef in: flowMemento)) == finish.
	self assert: (assessment edge waypoints) equals: ({ (100 @ 100 extent: 42 @ 42) center. (430 @ 100 extent: 42 @ 42) center } asOrderedCollection).
	self assert: fixture first flowElements size equals: 5.
	self assert: fixture eighth elements size equals: 5.
	^ memento
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> commitPersistsStagedMoveAndResetRestoresModelState [
	<gtExample>
	| fixture process memento taskShape diagramDescription operation |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	taskShape := fixture at: 10.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierMoveShape
		shape: taskShape
		bounds: (260 @ 124 extent: 132 @ 54)
		processMemento: memento
		diagramDescription: diagramDescription.

	self assert: operation apply isApplicable.
	self assert: taskShape bounds equals: (220 @ 94 extent: 132 @ 54).
	memento reset.
	self assert: (self stagedBoundsOf: taskShape processMemento: memento) equals: (220 @ 94 extent: 132 @ 54).

	operation := CPAtelierMoveShape
		shape: taskShape
		bounds: (260 @ 124 extent: 132 @ 54)
		processMemento: memento
		diagramDescription: diagramDescription.
	self assert: operation apply isApplicable.
	memento commit.
	self assert: process diagram elements second == taskShape.
	self assert: taskShape bounds equals: (260 @ 124 extent: 132 @ 54).
	^ process
]

{ #category : 'examples - semantic topology' }
CPProcessAtelierExamples >> reconnectSequenceFlowPreservesFlowAndEdgeIdentity [
	<gtExample>
	| fixture memento start finish firstFlow firstEdge flowElementsDescription diagramDescription operation assessment flowMemento |
	fixture := self fixture.
	memento := fixture second.
	start := fixture third.
	finish := fixture fifth.
	firstFlow := fixture sixth.
	firstEdge := fixture at: 12.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierReconnectSequenceFlow
		sequenceFlow: firstFlow
		source: start
		target: finish
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramDescription: diagramDescription.

	assessment := operation apply.
	flowMemento := memento childMementoFor: firstFlow inRelation: flowElementsDescription.

	self assert: assessment isApplicable.
	self assert: ((memento readUsing: flowElementsDescription) identityIncludes: firstFlow).
	self assert: (flowMemento readUsing: (self descriptionFor: #sourceRef in: flowMemento)) == start.
	self assert: (flowMemento readUsing: (self descriptionFor: #targetRef in: flowMemento)) == finish.
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: ({ 121 @ 121. 451 @ 121 } asOrderedCollection).
	self assert: firstFlow targetRef == fixture fourth.
	self assert: fixture eighth elements fourth == firstEdge.
	^ memento
]

{ #category : 'examples - semantic topology' }
CPProcessAtelierExamples >> insertFlowNodeReplacesOneFlowWithTwoAsOneStagedOperation [
	<gtExample>
	| fixture memento firstFlow firstEdge inserted flowElementsDescription diagramDescription operation assessment stagedFlowElements diagramMemento elementsDescription stagedElements |
	fixture := self fixture.
	memento := fixture second.
	firstFlow := fixture sixth.
	firstEdge := fixture at: 12.
	inserted := CPManualTask new label: 'Check'; yourself.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierInsertFlowNode
		sequenceFlow: firstFlow
		flowNode: inserted
		bounds: (170 @ 180 extent: 132 @ 54)
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramDescription: diagramDescription.

	assessment := operation apply.
	stagedFlowElements := memento readUsing: flowElementsDescription.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.

	self assert: assessment isApplicable.
	self assert: stagedFlowElements size equals: 7.
	self assert: (stagedFlowElements identityIncludes: firstFlow) not.
	self assert: (stagedFlowElements identityIncludes: inserted).
	self assert: (stagedFlowElements identityIncludes: assessment firstSequenceFlow).
	self assert: (stagedFlowElements identityIncludes: assessment secondSequenceFlow).
	self assert: stagedElements size equals: 7.
	self assert: (stagedElements identityIncludes: firstEdge) not.
	self assert: (stagedElements identityIncludes: assessment shape).
	self assert: (stagedElements identityIncludes: assessment firstEdge).
	self assert: (stagedElements identityIncludes: assessment secondEdge).
	self assert: fixture first flowElements size equals: 5.
	self assert: fixture eighth elements size equals: 5.
	^ memento
]

{ #category : 'examples - semantic topology' }
CPProcessAtelierExamples >> removeSequenceFlowStagesSemanticAndDiagramRemovalTogether [
	<gtExample>
	| fixture memento start task firstFlow firstEdge flowElementsDescription diagramDescription operation assessment stagedFlowElements diagramMemento elementsDescription stagedElements startMemento taskMemento |
	fixture := self fixture.
	memento := fixture second.
	start := fixture third.
	task := fixture fourth.
	firstFlow := fixture sixth.
	firstEdge := fixture at: 12.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierRemoveSequenceFlow
		sequenceFlow: firstFlow
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramDescription: diagramDescription.

	assessment := operation apply.
	stagedFlowElements := memento readUsing: flowElementsDescription.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.
	startMemento := memento childMementoFor: start inRelation: flowElementsDescription.
	taskMemento := memento childMementoFor: task inRelation: flowElementsDescription.

	self assert: assessment isApplicable.
	self assert: (stagedFlowElements identityIncludes: firstFlow) not.
	self assert: (stagedElements identityIncludes: firstEdge) not.
	self assert: (startMemento readUsing: (self descriptionFor: #outgoing in: startMemento)) isEmpty.
	self assert: (taskMemento readUsing: (self descriptionFor: #incoming in: taskMemento)) isEmpty.
	self assert: fixture first flowElements size equals: 5.
	^ memento
]

{ #category : 'examples - semantic topology' }
CPProcessAtelierExamples >> removeFlowNodeStagesIncidentFlowsAndDiagramElementsTogether [
	<gtExample>
	| fixture memento task flowElementsDescription diagramDescription operation assessment stagedFlowElements diagramMemento elementsDescription stagedElements |
	fixture := self fixture.
	memento := fixture second.
	task := fixture fourth.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierRemoveFlowNode
		flowNode: task
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramDescription: diagramDescription.

	assessment := operation apply.
	stagedFlowElements := memento readUsing: flowElementsDescription.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.

	self assert: assessment isApplicable.
	self assert: stagedFlowElements size equals: 2.
	self assert: (stagedFlowElements identityIncludes: fixture third).
	self assert: (stagedFlowElements identityIncludes: fixture fifth).
	self assert: stagedElements size equals: 2.
	self assert: (stagedElements identityIncludes: (fixture at: 9)).
	self assert: (stagedElements identityIncludes: (fixture at: 11)).
	self assert: fixture first flowElements size equals: 5.
	self assert: fixture eighth elements size equals: 5.
	^ memento
]

{ #category : 'examples - semantic topology' }
CPProcessAtelierExamples >> replaceFlowNodePreservesShapeAndIncidentFlowIdentity [
	<gtExample>
	| fixture memento task taskShape firstFlow secondFlow replacement flowElementsDescription diagramDescription operation assessment stagedFlowElements diagramMemento elementsDescription shapeMemento firstFlowMemento secondFlowMemento |
	fixture := self fixture.
	memento := fixture second.
	task := fixture fourth.
	firstFlow := fixture sixth.
	secondFlow := fixture seventh.
	taskShape := fixture at: 10.
	replacement := CPServiceTask new label: 'Temporary'; yourself.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierReplaceFlowNode
		flowNode: task
		with: replacement
		bounds: (220 @ 94 extent: 132 @ 54)
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramDescription: diagramDescription.

	assessment := operation apply.
	stagedFlowElements := memento readUsing: flowElementsDescription.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	shapeMemento := diagramMemento childMementoFor: taskShape inRelation: elementsDescription.
	firstFlowMemento := memento childMementoFor: firstFlow inRelation: flowElementsDescription.
	secondFlowMemento := memento childMementoFor: secondFlow inRelation: flowElementsDescription.

	self assert: assessment isApplicable.
	self assert: stagedFlowElements size equals: 5.
	self assert: (stagedFlowElements identityIncludes: task) not.
	self assert: (stagedFlowElements identityIncludes: replacement).
	self assert: (stagedFlowElements identityIncludes: firstFlow).
	self assert: (stagedFlowElements identityIncludes: secondFlow).
	self assert: (shapeMemento readUsing: (self descriptionFor: #modelElement in: shapeMemento)) == replacement.
	self assert: (firstFlowMemento readUsing: (self descriptionFor: #targetRef in: firstFlowMemento)) == replacement.
	self assert: (secondFlowMemento readUsing: (self descriptionFor: #sourceRef in: secondFlowMemento)) == replacement.
	self assert: ((memento childMementoFor: replacement inRelation: flowElementsDescription) readUsing: (self descriptionFor: #label in: (memento childMementoFor: replacement inRelation: flowElementsDescription))) equals: 'Review'.
	self assert: replacement label equals: 'Temporary'.
	self assert: fixture eighth elements second == taskShape.
	^ memento
]

{ #category : 'examples - creation' }
CPProcessAtelierExamples >> createCallActivityStagesSemanticNodeAndShapeTogether [
	<gtExample>
	| fixture process memento flowElementsDescription diagramDescription callActivity operation assessment stagedFlowElements diagramMemento elementsDescription stagedElements |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	callActivity := CPCallActivity new label: 'Reuse fulfilment'; yourself.

	operation := CPAtelierCreateFlowNode
		flowNode: callActivity
		bounds: (300 @ 220 extent: 132 @ 54)
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramDescription: diagramDescription.
	assessment := operation apply.

	stagedFlowElements := memento readUsing: flowElementsDescription.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.

	self assert: assessment isApplicable.
	self assert: (stagedFlowElements identityIncludes: callActivity).
	self assert: (stagedElements identityIncludes: assessment shape).
	self assert: assessment shape modelElement == callActivity.
	self assert: assessment shape bounds equals: (300 @ 220 extent: 132 @ 54).
	self assert: (process flowElements identityIncludes: callActivity) not.
	^ assessment
]


{ #category : 'examples - subprocess' }
CPProcessAtelierExamples >> subProcessOwnsNestedFlowTopology [
	<gtExample>
	| subProcess start task flow |
	subProcess := CPSubProcess new label: 'Fulfil order'; yourself.
	start := CPNoneStartEvent new label: 'Start'; yourself.
	task := CPUserTask new label: 'Pick order'; yourself.
	flow := CPSequenceFlow new
		sourceRef: start;
		targetRef: task;
		yourself.

	subProcess
		addFlowElement: start;
		addFlowElement: task;
		addFlowElement: flow.

	self assert: subProcess isActivity.
	self assert: subProcess isTask not.
	self assert: subProcess isSubProcess.
	self assert: subProcess flowElements size equals: 3.
	self assert: start container == subProcess.
	self assert: task container == subProcess.
	self assert: flow container == subProcess.
	self assert: (start outgoing identityIncludes: flow).
	self assert: (task incoming identityIncludes: flow).
	^ subProcess
]

{ #category : 'examples - creation' }
CPProcessAtelierExamples >> createSubProcessStagesSemanticNodeAndShapeTogether [
	<gtExample>
	| fixture process memento flowElementsDescription diagramDescription subProcess operation assessment stagedFlowElements diagramMemento elementsDescription stagedElements |
	fixture := self fixture.
	process := fixture first.
	memento := fixture second.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	subProcess := CPSubProcess new label: 'Fulfil order'; yourself.

	operation := CPAtelierCreateFlowNode
		flowNode: subProcess
		bounds: (300 @ 220 extent: 132 @ 72)
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramDescription: diagramDescription.
	assessment := operation apply.

	stagedFlowElements := memento readUsing: flowElementsDescription.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.

	self assert: assessment isApplicable.
	self assert: (stagedFlowElements identityIncludes: subProcess).
	self assert: (stagedElements identityIncludes: assessment shape).
	self assert: assessment shape modelElement == subProcess.
	self assert: assessment shape bounds equals: (300 @ 220 extent: 132 @ 72).
	self assert: (process flowElements identityIncludes: subProcess) not.
	^ assessment
]


{ #category : 'examples - subprocess' }
CPProcessAtelierExamples >> shapeExpansionIsStagedDiagramState [
	<gtExample>
	| fixture memento diagramMemento elementsDescription subProcess shape elements operation assessment shapeMemento expandedDescription boundsDescription |
	fixture := self fixture.
	memento := fixture second.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	subProcess := CPSubProcess new label: 'Fulfil order'; yourself.
	shape := CPShape new
		modelElement: subProcess;
		bounds: (180 @ 140 extent: 348 @ 168);
		yourself.
	elements := (diagramMemento readUsing: elementsDescription) asOrderedCollection copy.
	elements add: shape.
	diagramMemento write: elements using: elementsDescription.

	operation := CPAtelierSetShapeExpanded
		shape: shape
		expanded: true
		processMemento: memento
		diagramDescription: (self descriptionFor: #diagram in: memento).
	assessment := operation apply.
	shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
	expandedDescription := self descriptionFor: #isExpanded in: shapeMemento.
	boundsDescription := self descriptionFor: #bounds in: shapeMemento.

	self assert: assessment isApplicable.
	self assert: assessment currentExpanded equals: false.
	self assert: assessment proposedExpanded equals: true.
	self assert: assessment currentBounds equals: (180 @ 140 extent: 348 @ 168).
	self assert: assessment proposedBounds extent equals: 360 @ 180.
	self assert: assessment proposedBounds center equals: assessment currentBounds center.
	self assert: (shapeMemento readUsing: boundsDescription) equals: assessment proposedBounds.
	self assert: (shapeMemento readUsing: expandedDescription).
	self assert: shape isExpanded not.
	^ assessment
]


{ #category : 'examples - subprocess' }
CPProcessAtelierExamples >> replacingSubProcessTypePreservesNestedFlowElements [
	<gtExample>
	| fixture memento flowElementsDescription diagramDescription loopSubProcess start task nestedFlow createAssessment replaceAssessment replacement replacementMemento nestedDescription stagedNested |
	fixture := self fixture.
	memento := fixture second.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.

	loopSubProcess := CPLoopSubProcess new label: 'Fulfil order'; yourself.
	start := CPNoneStartEvent new label: 'Start'; yourself.
	task := CPUserTask new label: 'Pick'; yourself.
	nestedFlow := CPSequenceFlow new sourceRef: start; targetRef: task; yourself.
	loopSubProcess
		addFlowElement: start;
		addFlowElement: task;
		addFlowElement: nestedFlow.

	createAssessment := (CPAtelierCreateFlowNode
		flowNode: loopSubProcess
		bounds: (300 @ 220 extent: 132 @ 72)
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramDescription: diagramDescription) apply.
	self assert: createAssessment isApplicable.

	replacement := CPMultiInstanceSubProcess new.
	replaceAssessment := (CPAtelierReplaceFlowNode
		flowNode: loopSubProcess
		with: replacement
		bounds: createAssessment shape bounds
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramDescription: diagramDescription) apply.

	replacementMemento := memento
		childMementoFor: replacement
		inRelation: flowElementsDescription.
	nestedDescription := self descriptionFor: #flowElements in: replacementMemento.
	stagedNested := replacementMemento readUsing: nestedDescription.

	self assert: replaceAssessment isApplicable.
	self assert: stagedNested size equals: 3.
	self assert: (stagedNested identityIncludes: start).
	self assert: (stagedNested identityIncludes: task).
	self assert: (stagedNested identityIncludes: nestedFlow).
	self assert: replacement label equals: nil.
	^ replaceAssessment
]


{ #category : 'examples - subprocess' }
CPProcessAtelierExamples >> nestedContainerCreateConnectDeleteStagesLocally [
	<gtExample>
	| fixture memento rootFlowDescription diagramDescription diagramMemento elementsDescription
	  subProcess subProcessMemento nestedFlowDescription start task
	  createStart createTask connect delete
	  rootFlows nestedFlows diagramElements sequenceFlow |

	fixture := self fixture.
	memento := fixture second.
	rootFlowDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	memento
		write: ((memento readUsing: rootFlowDescription) asOrderedCollection copy
			add: subProcess;
			yourself)
		using: rootFlowDescription.
	subProcessMemento := memento
		childMementoFor: subProcess
		inRelation: rootFlowDescription.
	nestedFlowDescription := self descriptionFor: #flowElements in: subProcessMemento.
	subProcessMemento write: OrderedCollection new using: nestedFlowDescription.

	start := CPNoneStartEvent new label: 'Inner start'; yourself.
	task := CPUserTask new label: 'Inner task'; yourself.

	createStart := (CPAtelierCreateFlowNode
		flowNode: start
		bounds: (220 @ 220 extent: 42 @ 42)
		flowContainer: subProcess
		processMemento: memento
		diagramDescription: diagramDescription) apply.
	createTask := (CPAtelierCreateFlowNode
		flowNode: task
		bounds: (340 @ 214 extent: 132 @ 54)
		flowContainer: subProcess
		processMemento: memento
		diagramDescription: diagramDescription) apply.

	self assert: createStart isApplicable.
	self assert: createTask isApplicable.
	rootFlows := memento readUsing: rootFlowDescription.
	nestedFlows := subProcessMemento readUsing: nestedFlowDescription.
	self assert: (rootFlows identityIncludes: start) not.
	self assert: (rootFlows identityIncludes: task) not.
	self assert: (nestedFlows identityIncludes: start).
	self assert: (nestedFlows identityIncludes: task).

	connect := (CPAtelierConnectFlowNodes
		source: start
		target: task
		flowContainer: subProcess
		processMemento: memento
		diagramDescription: diagramDescription) apply.
	self assert: connect isApplicable.
	sequenceFlow := connect sequenceFlow.
	nestedFlows := subProcessMemento readUsing: nestedFlowDescription.
	self assert: (nestedFlows identityIncludes: sequenceFlow).
	self assert: (rootFlows identityIncludes: sequenceFlow) not.

	diagramElements := diagramMemento readUsing: elementsDescription.
	self assert: (diagramElements identityIncludes: createStart shape).
	self assert: (diagramElements identityIncludes: createTask shape).
	self assert: (diagramElements identityIncludes: connect edge).

	delete := (CPAtelierRemoveFlowNode
		flowNode: task
		flowContainer: subProcess
		processMemento: memento
		diagramDescription: diagramDescription) apply.
	self assert: delete isApplicable.
	nestedFlows := subProcessMemento readUsing: nestedFlowDescription.
	self assert: (nestedFlows identityIncludes: start).
	self assert: (nestedFlows identityIncludes: task) not.
	self assert: (nestedFlows identityIncludes: sequenceFlow) not.
	rootFlows := memento readUsing: rootFlowDescription.
	self assert: (rootFlows identityIncludes: subProcess).
	self assert: (rootFlows identityIncludes: task) not.
	self assert: (rootFlows identityIncludes: sequenceFlow) not.
	^ delete
]

{ #category : 'examples - subprocess' }
CPProcessAtelierExamples >> sequenceFlowCannotCrossFlowContainerBoundary [
	<gtExample>
	| fixture memento rootFlowDescription diagramDescription diagramMemento elementsDescription
	  subProcess subProcessMemento nestedFlowDescription rootTask nestedTask rootShape nestedShape operation assessment |

	fixture := self fixture.
	memento := fixture second.
	rootFlowDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.

	rootTask := fixture fourth.
	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	nestedTask := CPUserTask new label: 'Inner'; yourself.
	memento
		write: ((memento readUsing: rootFlowDescription) asOrderedCollection copy
			add: subProcess;
			yourself)
		using: rootFlowDescription.
	subProcessMemento := memento
		childMementoFor: subProcess
		inRelation: rootFlowDescription.
	nestedFlowDescription := self descriptionFor: #flowElements in: subProcessMemento.
	subProcessMemento write: { nestedTask } asOrderedCollection using: nestedFlowDescription.

	rootShape := fixture eighth elements
		detect: [ :each | each isShape and: [ each modelElement == rootTask ] ].
	nestedShape := CPShape new
		modelElement: nestedTask;
		bounds: (340 @ 214 extent: 132 @ 54);
		yourself.
	diagramMemento
		write: ((diagramMemento readUsing: elementsDescription) asOrderedCollection copy
			add: nestedShape;
			yourself)
		using: elementsDescription.

	operation := CPAtelierConnectFlowNodes
		source: rootTask
		target: nestedTask
		flowContainer: subProcess
		processMemento: memento
		diagramDescription: diagramDescription.
	assessment := operation assess.

	self assert: assessment isApplicable not.
	self assert: rootShape notNil.
	^ assessment
]


{ #category : 'examples - subprocess' }
CPProcessAtelierExamples >> transferringNodeIntoSubProcessStagesContainmentAndBounds [
	<gtExample>
	| fixture memento rootDescription diagramDescription diagramMemento elementsDescription
	  subProcess task rootElements subMemento subDescription shape diagramElements
	  operation assessment targetMemento containerDescription boundsDescription |

	fixture := self fixture.
	memento := fixture second.
	rootDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	task := CPUserTask new label: 'Move me'; yourself.
	rootElements := (memento readUsing: rootDescription) asOrderedCollection copy.
	rootElements
		add: subProcess;
		add: task.
	memento write: rootElements using: rootDescription.

	subMemento := memento childMementoFor: subProcess inRelation: rootDescription.
	subDescription := self descriptionFor: #flowElements in: subMemento.
	subMemento write: OrderedCollection new using: subDescription.

	shape := CPShape new
		modelElement: task;
		bounds: (80 @ 80 extent: 132 @ 54);
		yourself.
	diagramElements := (diagramMemento readUsing: elementsDescription) asOrderedCollection copy.
	diagramElements add: shape.
	diagramMemento write: diagramElements using: elementsDescription.

	operation := CPAtelierTransferFlowNode
		flowNode: task
		targetContainer: subProcess
		bounds: (260 @ 240 extent: 132 @ 54)
		processMemento: memento
		diagramDescription: diagramDescription.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: ((memento readUsing: rootDescription) identityIncludes: task) not.
	self assert: ((subMemento readUsing: subDescription) identityIncludes: task).
	targetMemento := subMemento childMementoFor: task inRelation: subDescription.
	containerDescription := self descriptionFor: #container in: targetMemento.
	self assert: (targetMemento readUsing: containerDescription) == subProcess.
	boundsDescription := self descriptionFor: #bounds in:
		(diagramMemento childMementoFor: shape inRelation: elementsDescription).
	self assert:
		((diagramMemento childMementoFor: shape inRelation: elementsDescription)
			readUsing: boundsDescription)
		equals: (260 @ 240 extent: 132 @ 54).
	self assert: task container isNil.
	^ assessment
]


{ #category : 'examples - subprocess' }
CPProcessAtelierExamples >> transferringConnectedNodeRejectsCrossScopeSequenceFlow [
	<gtExample>
	| fixture memento task rootDescription diagramDescription subProcess rootElements
	  subMemento subDescription operation assessment |

	fixture := self fixture.
	memento := fixture second.
	task := fixture fourth.
	rootDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	rootElements := (memento readUsing: rootDescription) asOrderedCollection copy.
	rootElements add: subProcess.
	memento write: rootElements using: rootDescription.
	subMemento := memento childMementoFor: subProcess inRelation: rootDescription.
	subDescription := self descriptionFor: #flowElements in: subMemento.
	subMemento write: OrderedCollection new using: subDescription.

	operation := CPAtelierTransferFlowNode
		flowNode: task
		targetContainer: subProcess
		bounds: (260 @ 240 extent: 132 @ 54)
		processMemento: memento
		diagramDescription: diagramDescription.
	assessment := operation apply.

	self assert: assessment isApplicable not.
	self assert: ((memento readUsing: rootDescription) identityIncludes: task).
	self assert: ((memento readUsing: rootDescription) identityIncludes: fixture sixth).
	self assert: ((memento readUsing: rootDescription) identityIncludes: fixture seventh).
	self assert: ((subMemento readUsing: subDescription) identityIncludes: task) not.
	^ assessment
]


{ #category : 'examples - nested containers' }
CPProcessAtelierExamples >> transferringClosedTopologyIntoSubProcessMovesNodesFlowsAndDiagramGeometry [
	<gtExample>
	| fixture memento start task finish firstFlow secondFlow rootDescription diagramDescription
	  subProcess rootElements subMemento subDescription boundsByNode waypointsByFlow
	  operation assessment nestedElements targetTaskMemento containerDescription |

	fixture := self fixture.
	memento := fixture second.
	start := fixture third.
	task := fixture fourth.
	finish := fixture fifth.
	firstFlow := fixture sixth.
	secondFlow := fixture seventh.
	rootDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	rootElements := (memento readUsing: rootDescription) asOrderedCollection copy.
	rootElements add: subProcess.
	memento write: rootElements using: rootDescription.
	subMemento := memento childMementoFor: subProcess inRelation: rootDescription.
	subDescription := self descriptionFor: #flowElements in: subMemento.
	subMemento write: OrderedCollection new using: subDescription.

	boundsByNode := IdentityDictionary new.
	boundsByNode
		at: start put: (40 @ 60 extent: 42 @ 42);
		at: task put: (140 @ 54 extent: 132 @ 54);
		at: finish put: (330 @ 60 extent: 42 @ 42).
	waypointsByFlow := IdentityDictionary new.
	waypointsByFlow
		at: firstFlow put: ({ 82 @ 81. 140 @ 81 } asOrderedCollection);
		at: secondFlow put: ({ 272 @ 81. 330 @ 81 } asOrderedCollection).

	operation := CPAtelierTransferFlowNodes
		flowNodes: { start. task. finish }
		targetContainer: subProcess
		boundsByFlowNode: boundsByNode
		waypointsBySequenceFlow: waypointsByFlow
		processMemento: memento
		diagramDescription: diagramDescription.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: rootDescription) size equals: 1.
	self assert: ((memento readUsing: rootDescription) identityIncludes: subProcess).
	nestedElements := subMemento readUsing: subDescription.
	self assert: nestedElements size equals: 5.
	self assert: (nestedElements identityIncludes: start).
	self assert: (nestedElements identityIncludes: task).
	self assert: (nestedElements identityIncludes: finish).
	self assert: (nestedElements identityIncludes: firstFlow).
	self assert: (nestedElements identityIncludes: secondFlow).

	targetTaskMemento := subMemento childMementoFor: task inRelation: subDescription.
	containerDescription := self descriptionFor: #container in: targetTaskMemento.
	self assert: (targetTaskMemento readUsing: containerDescription) == subProcess.
	self assert: (self stagedBoundsOf: (fixture at: 9) processMemento: memento)
		equals: (40 @ 60 extent: 42 @ 42).
	self assert: (self stagedBoundsOf: (fixture at: 10) processMemento: memento)
		equals: (140 @ 54 extent: 132 @ 54).
	self assert: (self stagedBoundsOf: (fixture at: 11) processMemento: memento)
		equals: (330 @ 60 extent: 42 @ 42).
	self assert: (self stagedWaypointsOf: (fixture at: 12) processMemento: memento)
		equals: ({ 82 @ 81. 140 @ 81 } asOrderedCollection).
	self assert: (self stagedWaypointsOf: (fixture at: 13) processMemento: memento)
		equals: ({ 272 @ 81. 330 @ 81 } asOrderedCollection).
	^ assessment
]


{ #category : 'examples - nested containers' }
CPProcessAtelierExamples >> transferringOpenTopologyRejectsBoundarySequenceFlow [
	<gtExample>
	| fixture memento start task firstFlow rootDescription diagramDescription subProcess rootElements
	  subMemento subDescription boundsByNode waypointsByFlow operation assessment |

	fixture := self fixture.
	memento := fixture second.
	start := fixture third.
	task := fixture fourth.
	firstFlow := fixture sixth.
	rootDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	rootElements := (memento readUsing: rootDescription) asOrderedCollection copy.
	rootElements add: subProcess.
	memento write: rootElements using: rootDescription.
	subMemento := memento childMementoFor: subProcess inRelation: rootDescription.
	subDescription := self descriptionFor: #flowElements in: subMemento.
	subMemento write: OrderedCollection new using: subDescription.

	boundsByNode := IdentityDictionary new.
	boundsByNode
		at: start put: (40 @ 60 extent: 42 @ 42);
		at: task put: (140 @ 54 extent: 132 @ 54).
	waypointsByFlow := IdentityDictionary new.
	waypointsByFlow
		at: firstFlow put: ({ 82 @ 81. 140 @ 81 } asOrderedCollection).

	operation := CPAtelierTransferFlowNodes
		flowNodes: { start. task }
		targetContainer: subProcess
		boundsByFlowNode: boundsByNode
		waypointsBySequenceFlow: waypointsByFlow
		processMemento: memento
		diagramDescription: diagramDescription.
	assessment := operation apply.

	self assert: assessment isApplicable not.
	self assert: ((memento readUsing: rootDescription) identityIncludes: start).
	self assert: ((memento readUsing: rootDescription) identityIncludes: task).
	self assert: ((memento readUsing: rootDescription) identityIncludes: fixture seventh).
	self assert: (subMemento readUsing: subDescription) isEmpty.
	^ assessment
]


{ #category : 'private - fixture' }
CPProcessAtelierExamples >> collaborationFixture [
	| process localTask collaboration localParticipant externalParticipant processDiagram taskShape collaborationDiagram localPool externalPool memento |
	process := CPProcess new label: 'Seller'; yourself.
	localTask := CPUserTask new label: 'Send order'; yourself.
	process addFlowElement: localTask.
	processDiagram := CPDiagram new.
	process diagram: processDiagram.
	taskShape := CPShape new
		modelElement: localTask;
		bounds: (120 @ 80 extent: 132 @ 54);
		yourself.
	processDiagram addElement: taskShape.

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
	collaborationDiagram := CPDiagram new.
	collaboration diagram: collaborationDiagram.
	localPool := CPShape new
		modelElement: localParticipant;
		bounds: (40 @ 40 extent: 620 @ 230);
		yourself.
	externalPool := CPShape new
		modelElement: externalParticipant;
		bounds: (40 @ 320 extent: 620 @ 100);
		yourself.
	collaborationDiagram
		addElement: localPool;
		addElement: externalPool.
	process definitionalCollaborationRef: collaboration.
	memento := CFMaMemento model: process.
	^ {
		process.
		memento.
		localTask.
		collaboration.
		localParticipant.
		externalParticipant.
		collaborationDiagram.
		localPool.
		externalPool
	}
]

{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> connectMessageFlowAssessmentDoesNotMutateStagedState [
	<gtExample>
	| fixture memento collaboration operation assessment context |
	fixture := self collaborationFixture.
	memento := fixture at: 2.
	collaboration := fixture at: 4.
	operation := CPAtelierConnectMessageFlow
		source: (fixture at: 3)
		target: (fixture at: 6)
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento.

	assessment := operation assess.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: assessment isApplicable.
	self assert: context messageFlows isEmpty.
	self assert: context elements size equals: 2.
	self assert: collaboration messageFlows isEmpty.
	self assert: collaboration diagram elements size equals: 2.
	^ assessment
]

{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> connectMessageFlowStagesSemanticAndDiagramStateTogether [
	<gtExample>
	| fixture memento collaboration operation assessment context messageFlow edge |
	fixture := self collaborationFixture.
	memento := fixture at: 2.
	collaboration := fixture at: 4.
	operation := CPAtelierConnectMessageFlow
		source: (fixture at: 3)
		target: (fixture at: 6)
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento.

	assessment := operation apply.
	context := CPProcessCollaborationContext inRootMemento: memento.
	messageFlow := assessment messageFlow.
	edge := assessment edge.

	self assert: assessment isApplicable.
	self assert: context messageFlows size equals: 1.
	self assert: context messageFlows first == messageFlow.
	self assert: context elements size equals: 3.
	self assert: (context elements identityIncludes: edge).
	self assert: edge modelElement == messageFlow.
	self assert: edge waypoints equals: ({ 250 @ 270. 250 @ 320 } asOrderedCollection).
	self assert: collaboration messageFlows isEmpty.
	self assert: collaboration diagram elements size equals: 2.
	^ memento
]

{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> connectMessageFlowRejectsEndpointsInsideSameParticipant [
	<gtExample>
	| fixture operation assessment |
	fixture := self collaborationFixture.
	operation := CPAtelierConnectMessageFlow
		source: (fixture at: 3)
		target: (fixture at: 5)
		waypoints: { 250 @ 100. 350 @ 100 }
		processMemento: (fixture at: 2).

	assessment := operation assess.

	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage
		equals: 'A MessageFlow must connect two separate Participants.'.
	^ assessment
]


{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> createFirstParticipantAssessmentDoesNotEstablishCollaboration [
	<gtExample>
	| process memento participant operation assessment collaborationDescription |
	process := CPProcess new label: 'Process'; yourself.
	process diagram: CPDiagram new.
	memento := CFMaMemento model: process.
	participant := CPParticipant new label: 'Pool'; yourself.
	operation := CPAtelierCreateParticipant
		participant: participant
		bounds: (40 @ 40 extent: 620 @ 230)
		processMemento: memento.

	assessment := operation assess.
	collaborationDescription := self
		descriptionFor: #definitionalCollaborationRef
		in: memento.

	self assert: assessment isApplicable.
	self assert: assessment createsCollaboration.
	self assert: assessment referencesProcess.
	self assert: (memento readUsing: collaborationDescription) isNil.
	self assert: process definitionalCollaborationRef isNil.
	self assert: participant processRef isNil.
	^ assessment
]


{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> createFirstParticipantStagesCollaborationPoolAndProcessReference [
	<gtExample>
	| process memento participant operation assessment collaborationDescription context |
	process := CPProcess new label: 'Process'; yourself.
	process diagram: CPDiagram new.
	memento := CFMaMemento model: process.
	participant := CPParticipant new label: 'Pool'; yourself.
	operation := CPAtelierCreateParticipant
		participant: participant
		bounds: (40 @ 40 extent: 620 @ 230)
		processMemento: memento.

	assessment := operation apply.
	collaborationDescription := self
		descriptionFor: #definitionalCollaborationRef
		in: memento.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: collaborationDescription) == assessment collaboration.
	self assert: context participants size equals: 1.
	self assert: context participants first == participant.
	self assert: context elements size equals: 1.
	self assert: context elements first == assessment shape.
	self assert: assessment shape modelElement == participant.
	self assert: assessment shape bounds equals: (40 @ 40 extent: 620 @ 230).
	self assert: participant processRef == process.
	self assert: process definitionalCollaborationRef isNil.
	^ assessment
]


{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> createSecondParticipantDefaultsToBlackBox [
	<gtExample>
	| fixture memento secondParticipant operation assessment context |
	fixture := self collaborationFixture.
	memento := fixture at: 2.
	secondParticipant := CPParticipant new label: 'Carrier'; yourself.
	operation := CPAtelierCreateParticipant
		participant: secondParticipant
		bounds: (40 @ 460 extent: 620 @ 100)
		processMemento: memento.

	assessment := operation apply.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: assessment isApplicable.
	self assert: assessment createsCollaboration not.
	self assert: assessment referencesProcess not.
	self assert: context participants size equals: 3.
	self assert: context participants last == secondParticipant.
	self assert: context elements size equals: 3.
	self assert: secondParticipant processRef isNil.
	^ assessment
]

{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> removeBlackBoxParticipantStagesPoolAndIncidentMessageFlowRemoval [
	<gtExample>
	| fixture memento externalParticipant connectAssessment operation assessment context |
	fixture := self collaborationFixture.
	memento := fixture at: 2.
	externalParticipant := fixture at: 6.
	connectAssessment := (CPAtelierConnectMessageFlow
		source: (fixture at: 3)
		target: externalParticipant
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento) apply.

	operation := CPAtelierRemoveParticipant
		participant: externalParticipant
		processMemento: memento.
	assessment := operation apply.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: assessment isApplicable.
	self assert: (context participants identityIncludes: externalParticipant) not.
	self assert: (context messageFlows identityIncludes: connectAssessment messageFlow) not.
	self assert: (context elements identityIncludes: (fixture at: 9)) not.
	self assert: (context elements identityIncludes: connectAssessment edge) not.
	self assert: context participants size equals: 1.
	self assert: context messageFlows isEmpty.
	^ assessment
]

{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> removeSoleParticipantReturnsProcessToStandalonePresentationState [
	<gtExample>
	| process memento participant createAssessment operation assessment collaborationDescription |
	process := CPProcess new label: 'Process'; yourself.
	process diagram: CPDiagram new.
	memento := CFMaMemento model: process.
	participant := CPParticipant new label: 'Pool'; yourself.
	createAssessment := (CPAtelierCreateParticipant
		participant: participant
		bounds: (40 @ 40 extent: 620 @ 230)
		processMemento: memento) apply.
	collaborationDescription := self
		descriptionFor: #definitionalCollaborationRef
		in: memento.

	operation := CPAtelierRemoveParticipant
		participant: participant
		processMemento: memento.
	assessment := operation apply.

	self assert: createAssessment isApplicable.
	self assert: assessment isApplicable.
	self assert: assessment removesCollaboration.
	self assert: (memento readUsing: collaborationDescription) isNil.
	^ assessment
]

{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> removingHostedParticipantWithOtherPoolsIsRejected [
	<gtExample>
	| fixture operation assessment |
	fixture := self collaborationFixture.
	operation := CPAtelierRemoveParticipant
		participant: (fixture at: 5)
		processMemento: (fixture at: 2).
	assessment := operation assess.

	self assert: assessment isApplicable not.
	self assert: assessment rejectionMessage
		equals: 'The Participant that hosts the edited Process cannot be removed while other Participants remain.'.
	^ assessment
]
