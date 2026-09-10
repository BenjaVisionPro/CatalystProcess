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
CPProcessAtelierExamples >> diagramEditingForMemento: aMemento [
	| session |
	session := CPProcessAtelierSession forProcessMemento: aMemento.
	^ CPProcessAtelierDiagramEditing
		processMemento: session processMemento
		diagramContext: session diagramContext
		collaborationContext: session collaborationContext
]

{ #category : 'private - fixture' }
CPProcessAtelierExamples >> diagramContextForMemento: aMemento [
	^ (CPProcessAtelierSession forProcessMemento: aMemento) diagramContext
]

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
	| diagramDescription diagram diagramContext |
	diagramDescription := self descriptionFor: #diagram in: aProcessMemento.
	diagram := aProcessMemento readUsing: diagramDescription.
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: aProcessMemento
		using: diagramDescription.
	^ diagramContext planeMemento
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
		diagramContext: (self diagramContextForMemento: memento).

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
		diagramContext: (self diagramContextForMemento: memento).

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
		diagramContext: (self diagramContextForMemento: memento).

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
		diagramContext: (self diagramContextForMemento: memento).

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (self stagedBoundsOf: taskShape processMemento: memento) equals: (220 @ 94 extent: 172 @ 74).
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: ({ 142 @ 121. 240 @ 131 } asOrderedCollection).
	self assert: (self stagedWaypointsOf: secondEdge processMemento: memento) equals: ({ 372 @ 131. 430 @ 121 } asOrderedCollection).
	^ memento
]


{ #category : 'examples - nested containers' }
CPProcessAtelierExamples >> resizeShapeInsideSubProcessMovesNestedIncidentEndpoints [
	<gtExample>
	| fixture memento start task finish firstFlow secondFlow rootDescription diagramDescription
	  subProcess rootElements subMemento subDescription boundsByNode waypointsByFlow
	  transferAssessment resizeAssessment |

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

	transferAssessment := (CPAtelierTransferFlowNodes
		flowNodes: { start. task. finish }
		targetContainer: subProcess
		boundsByFlowNode: boundsByNode
		waypointsBySequenceFlow: waypointsByFlow
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento)) apply.
	self assert: transferAssessment isApplicable.

	resizeAssessment := (CPAtelierResizeShape
		shape: (fixture at: 10)
		bounds: (160 @ 64 extent: 152 @ 74)
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento)) apply.

	self assert: resizeAssessment isApplicable.
	self assert: (self stagedBoundsOf: (fixture at: 10) processMemento: memento)
		equals: (160 @ 64 extent: 152 @ 74).
	self assert: (self stagedWaypointsOf: (fixture at: 12) processMemento: memento)
		equals: ({ 82 @ 81. 170 @ 101 } asOrderedCollection).
	self assert: (self stagedWaypointsOf: (fixture at: 13) processMemento: memento)
		equals: ({ 302 @ 101. 330 @ 81 } asOrderedCollection).
	^ resizeAssessment
]


{ #category : 'examples - routing' }
CPProcessAtelierExamples >> setEdgeWaypointsStagesRoutingWithoutMutatingModel [
	<gtExample>
	| fixture memento firstEdge diagramDescription diagram diagramContext proposed operation assessment |
	fixture := self fixture.
	memento := fixture second.
	firstEdge := fixture at: 12.
	diagramDescription := self descriptionFor: #diagram in: memento.
	diagram := memento readUsing: diagramDescription.
	diagramContext := CPDiagramMementoContext diagram: diagram inMemento: memento using: diagramDescription.
	proposed := { 142 @ 121. 180 @ 170. 220 @ 121 } asOrderedCollection.
	operation := CPAtelierSetEdgeWaypoints
		edge: firstEdge
		waypoints: proposed
		diagramContext: diagramContext.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: proposed.
	self assert: firstEdge waypoints equals: ({ 142 @ 121. 220 @ 121 } asOrderedCollection).
	^ memento
]

{ #category : 'examples - labels' }
CPProcessAtelierExamples >> setEdgeLabelPlacementStagesAllPlacementValues [
	<gtExample>
	| fixture memento firstEdge diagramDescription diagram diagramContext operation assessment diagramMemento elementsDescription edgeMemento |
	fixture := self fixture.
	memento := fixture second.
	firstEdge := fixture at: 12.
	diagramDescription := self descriptionFor: #diagram in: memento.
	diagram := memento readUsing: diagramDescription.
	diagramContext := CPDiagramMementoContext diagram: diagram inMemento: memento using: diagramDescription.
	operation := CPAtelierSetEdgeLabelPlacement
		edge: firstEdge
		segmentIndex: 1
		segmentPosition: 0.35
		offset: 18
		diagramContext: diagramContext.

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
		diagramContext: (self diagramContextForMemento: memento).

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
		diagramContext: (self diagramContextForMemento: memento).

	self assert: operation apply isApplicable.
	self assert: taskShape bounds equals: (220 @ 94 extent: 132 @ 54).
	memento reset.
	self assert: (self stagedBoundsOf: taskShape processMemento: memento) equals: (220 @ 94 extent: 132 @ 54).

	operation := CPAtelierMoveShape
		shape: taskShape
		bounds: (260 @ 124 extent: 132 @ 54)
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).
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
		waypoints: ({ 121 @ 121. 451 @ 121 } asOrderedCollection)
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramContext: (self diagramContextForMemento: memento).

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
CPProcessAtelierExamples >> appendFlowNodeCreatesNodeAndConnectionAsOneStagedOperation [
	<gtExample>
	| fixture memento task appended flowElementsDescription diagramDescription operation assessment stagedFlowElements diagramMemento elementsDescription stagedElements taskMemento appendedMemento flowContainerContext |
	fixture := self fixture.
	memento := fixture second.
	task := fixture fourth.
	appended := CPUserTask new label: 'Follow up'; yourself.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierAppendFlowNode
		source: task
		flowNode: appended
		bounds: (390 @ 180 extent: 132 @ 54)
		flowContainer: fixture first
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).

	assessment := operation apply.
	stagedFlowElements := memento readUsing: flowElementsDescription.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.
	taskMemento := memento childMementoFor: task inRelation: flowElementsDescription.
	appendedMemento := memento childMementoFor: appended inRelation: flowElementsDescription.

	self assert: assessment isApplicable.
	self assert: (stagedFlowElements identityIncludes: appended).
	self assert: (stagedFlowElements identityIncludes: assessment sequenceFlow).
	self assert: (stagedElements identityIncludes: assessment shape).
	self assert: (stagedElements identityIncludes: assessment edge).
	self assert: ((taskMemento readUsing: (self descriptionFor: #outgoing in: taskMemento)) identityIncludes: assessment sequenceFlow).
	self assert: (appendedMemento readUsing: (self descriptionFor: #incoming in: appendedMemento)) first == assessment sequenceFlow.
	self assert: (flowContainerContext := CPProcessFlowContainerContext rootFor: memento) notNil.
	self assert: (flowContainerContext stagedSourceOf: assessment sequenceFlow) == task.
	self assert: (flowContainerContext stagedTargetOf: assessment sequenceFlow) == appended.
	self assert: (diagramMemento childMementoFor: assessment shape inRelation: elementsDescription) notNil.
	self assert: ((diagramMemento childMementoFor: assessment shape inRelation: elementsDescription)
		readUsing: (self descriptionFor: #modelElement in: (diagramMemento childMementoFor: assessment shape inRelation: elementsDescription))) == appended.
	self assert: ((diagramMemento childMementoFor: assessment edge inRelation: elementsDescription)
		readUsing: (self descriptionFor: #modelElement in: (diagramMemento childMementoFor: assessment edge inRelation: elementsDescription))) == assessment sequenceFlow.
	self assert: ((diagramMemento childMementoFor: assessment edge inRelation: elementsDescription)
		readUsing: (self descriptionFor: #waypoints in: (diagramMemento childMementoFor: assessment edge inRelation: elementsDescription))) size equals: 2.
	self assert: assessment sequenceFlow sourceRef isNil.
	self assert: assessment sequenceFlow targetRef isNil.
	self assert: appended incoming isEmpty.
	self assert: fixture first flowElements size equals: 5.
	self assert: fixture eighth elements size equals: 5.
	^ memento
]

{ #category : 'examples - semantic topology' }
CPProcessAtelierExamples >> appendFlowNodeAssessmentHasNoSemanticSideEffects [
	<gtExample>
	| fixture memento task appended diagramDescription operation originalOutgoingCount |
	fixture := self fixture.
	memento := fixture second.
	task := fixture fourth.
	appended := CPUserTask new label: 'Follow up'; yourself.
	diagramDescription := self descriptionFor: #diagram in: memento.
	originalOutgoingCount := task outgoing size.
	operation := CPAtelierAppendFlowNode
		source: task
		flowNode: appended
		bounds: (390 @ 180 extent: 132 @ 54)
		flowContainer: fixture first
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).

	1 to: 100 do: [ :anIndex | self assert: operation assess isApplicable ].

	self assert: task outgoing size equals: originalOutgoingCount.
	self assert: appended incoming isEmpty.
	^ operation
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
		diagramContext: (self diagramContextForMemento: memento).

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
		diagramContext: (self diagramContextForMemento: memento).

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
		diagramContext: (self diagramContextForMemento: memento).

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
CPProcessAtelierExamples >> removeDiagramSelectionSuppressesSelectedIncidentSequenceFlow [
	<gtExample>
	| fixture memento taskShape firstEdge diagramDescription operation assessment stagedFlowElements diagramMemento elementsDescription stagedElements |
	fixture := self fixture.
	memento := fixture second.
	taskShape := fixture at: 10.
	firstEdge := fixture at: 12.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierRemoveDiagramElements
		diagramElements: { taskShape. firstEdge }
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).

	assessment := operation apply.
	stagedFlowElements := memento readUsing: (self descriptionFor: #flowElements in: memento).
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.

	self assert: assessment isApplicable.
	self assert: assessment operations size equals: 1.
	self assert: (stagedFlowElements identityIncludes: fixture fourth) not.
	self assert: (stagedFlowElements identityIncludes: fixture sixth) not.
	self assert: (stagedFlowElements identityIncludes: fixture seventh) not.
	self assert: (stagedElements identityIncludes: taskShape) not.
	self assert: (stagedElements identityIncludes: firstEdge) not.
	self assert: (stagedElements identityIncludes: (fixture at: 13)) not.
	^ assessment
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
		diagramContext: (self diagramContextForMemento: memento).

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


{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> replacingActivityReattachesBoundaryEventsToReplacement [
	<gtExample>
	| process task boundary diagram taskShape boundaryShape memento diagramDescription flowContext createAssessment replacement replaceAssessment boundaryMemento attachedDescription |
	process := CPProcess new.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: task.
	diagram := CPDiagram new.
	taskShape := CPShape new modelElement: task; bounds: (100 @ 100 extent: 140 @ 80); yourself.
	diagram addElement: taskShape.
	process diagram: diagram.
	memento := CFMaMemento model: process.
	diagramDescription := memento magritteDescription detect: [ :each | each handlesSelector: #diagram ].
	boundary := CPBoundaryEvent new eventDefinitions: { CPTimerEventDefinition new } asOrderedCollection; yourself.
	createAssessment := (CPAtelierCreateBoundaryEvent
		boundaryEvent: boundary
		attachedTo: task
		bounds: (124 @ 84 extent: 32 @ 32)
		flowContainer: process
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento)) apply.
	self assert: createAssessment isApplicable.
	boundaryShape := createAssessment shape.

	replacement := CPServiceTask new label: 'Temporary'; yourself.
	replaceAssessment := (CPAtelierReplaceFlowNode
		flowNode: task
		with: replacement
		bounds: taskShape bounds
		flowContainer: process
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento)) apply.

	flowContext := CPProcessFlowContainerContext rootFor: memento.
	boundaryMemento := flowContext childMementoFor: boundary.
	attachedDescription := boundaryMemento magritteDescription detect: [ :each | each handlesSelector: #attachedToRef ].
	self assert: replaceAssessment isApplicable.
	self assert: replaceAssessment attachedBoundaryEvents size equals: 1.
	self assert: replaceAssessment attachedBoundaryEvents first == boundary.
	self assert: (boundaryMemento readUsing: attachedDescription) == replacement.
	self assert: (flowContext stagedFlowElements identityIncludes: task) not.
	self assert: (flowContext stagedFlowElements identityIncludes: replacement).
	self assert: boundaryShape modelElement == boundary.
	^ replaceAssessment
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
		diagramContext: (self diagramContextForMemento: memento).
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
		diagramContext: (self diagramContextForMemento: memento).
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
	| fixture memento diagramDescription diagram diagramContext subProcess shape elements operation assessment shapeMemento expandedDescription boundsDescription |
	fixture := self fixture.
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	diagram := memento readUsing: diagramDescription.
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: memento
		using: diagramDescription.
	subProcess := CPSubProcess new label: 'Fulfil order'; yourself.
	shape := CPShape new
		modelElement: subProcess;
		bounds: (180 @ 140 extent: 348 @ 168);
		yourself.
	elements := diagramContext elements asOrderedCollection copy.
	elements add: shape.
	diagramContext writeElements: elements.

	operation := CPAtelierSetShapeExpanded
		shape: shape
		expanded: true
		processMemento: memento
		diagramContext: diagramContext.
	assessment := operation apply.
	shapeMemento := diagramContext mementoFor: shape.
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
		diagramContext: (self diagramContextForMemento: memento)) apply.
	self assert: createAssessment isApplicable.

	replacement := CPMultiInstanceSubProcess new.
	replaceAssessment := (CPAtelierReplaceFlowNode
		flowNode: loopSubProcess
		with: replacement
		bounds: createAssessment shape bounds
		processMemento: memento
		flowElementsDescription: flowElementsDescription
		diagramContext: (self diagramContextForMemento: memento)) apply.

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
		diagramContext: (self diagramContextForMemento: memento)) apply.
	createTask := (CPAtelierCreateFlowNode
		flowNode: task
		bounds: (340 @ 214 extent: 132 @ 54)
		flowContainer: subProcess
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento)) apply.

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
		diagramContext: (self diagramContextForMemento: memento)) apply.
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
		diagramContext: (self diagramContextForMemento: memento)) apply.
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
		diagramContext: (self diagramContextForMemento: memento).
	assessment := operation assess.

	self assert: assessment isApplicable not.
	self assert: rootShape notNil.
	^ assessment
]


{ #category : 'examples - subprocess' }
CPProcessAtelierExamples >> transferringNodeIntoSubProcessStagesContainmentAndBounds [
	<gtExample>
	| fixture memento rootDescription diagramDescription diagram diagramContext
	  subProcess task rootElements subMemento subDescription shape diagramElements
	  operation assessment targetMemento containerDescription boundsDescription |

	fixture := self fixture.
	memento := fixture second.
	rootDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	diagram := memento readUsing: diagramDescription.
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: memento
		using: diagramDescription.

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
	diagramElements := diagramContext elements asOrderedCollection copy.
	diagramElements add: shape.
	diagramContext writeElements: diagramElements.

	operation := CPAtelierTransferFlowNode
		flowNode: task
		targetContainer: subProcess
		bounds: (260 @ 240 extent: 132 @ 54)
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: ((memento readUsing: rootDescription) identityIncludes: task) not.
	self assert: ((subMemento readUsing: subDescription) identityIncludes: task).
	targetMemento := subMemento childMementoFor: task inRelation: subDescription.
	containerDescription := self descriptionFor: #container in: targetMemento.
	self assert: (targetMemento readUsing: containerDescription) == subProcess.
	boundsDescription := self descriptionFor: #bounds in:
		(diagramContext mementoFor: shape).
	self assert:
		((diagramContext mementoFor: shape)
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
		diagramContext: (self diagramContextForMemento: memento).
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
		diagramContext: (self diagramContextForMemento: memento).
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
		diagramContext: (self diagramContextForMemento: memento).
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
CPProcessAtelierExamples >> collaborationContextReadsCurrentStagedCollections [
	<gtExample>
	| fixture memento context operation assessment |
	fixture := self collaborationFixture.
	memento := fixture at: 2.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: context messageFlows isEmpty.
	self assert: context elements size equals: 2.

	operation := CPAtelierConnectMessageFlow
		source: (fixture at: 3)
		target: (fixture at: 6)
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: context messageFlows size equals: 1.
	self assert: context messageFlows first == assessment messageFlow.
	self assert: (context stagedSourceOf: assessment messageFlow) == (fixture at: 3).
	self assert: (context stagedTargetOf: assessment messageFlow) == (fixture at: 6).
	self assert: context elements size equals: 3.
	self assert: (context elements identityIncludes: assessment edge).
	^ context
]

{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> collaborationContextResolvesFreshStagedFlowNodeToRootParticipant [
	<gtExample>
	| fixture process memento localParticipant freshTask diagramDescription createAssessment context |
	fixture := self collaborationFixture.
	process := fixture first.
	memento := fixture second.
	localParticipant := fixture fifth.
	freshTask := CPUserTask new label: 'Pack order'; yourself.
	diagramDescription := self descriptionFor: #diagram in: memento.

	createAssessment := (CPAtelierCreateFlowNode
		flowNode: freshTask
		bounds: (300 @ 80 extent: 132 @ 54)
		flowContainer: process
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento)) apply.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: createAssessment isApplicable.
	self assert: freshTask owningProcess isNil.
	self assert: (context participantForEndpoint: freshTask) == localParticipant.
	^ context
]


{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> collaborationContextUsesCommittedOwnershipForExternalProcessEndpoint [
	<gtExample>
	| fixture memento externalParticipant externalProcess externalTask context |
	fixture := self collaborationFixture.
	memento := fixture second.
	externalParticipant := fixture sixth.
	externalProcess := CPProcess new label: 'Buyer'; yourself.
	externalTask := CPUserTask new label: 'Receive order'; yourself.
	externalProcess addFlowElement: externalTask.
	externalParticipant processRef: externalProcess.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: externalTask owningProcess == externalProcess.
	self assert: (context participantForEndpoint: externalTask) == externalParticipant.
	^ context
]


{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> connectMessageFlowObservesFreshStagedFlowNodeContainment [
	<gtExample>
	| fixture process memento externalParticipant freshTask diagramDescription createAssessment operation assessment |
	fixture := self collaborationFixture.
	process := fixture first.
	memento := fixture second.
	externalParticipant := fixture sixth.
	freshTask := CPUserTask new label: 'Pack order'; yourself.
	diagramDescription := self descriptionFor: #diagram in: memento.
	createAssessment := (CPAtelierCreateFlowNode
		flowNode: freshTask
		bounds: (300 @ 80 extent: 132 @ 54)
		flowContainer: process
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento)) apply.

	operation := CPAtelierConnectMessageFlow
		source: freshTask
		target: externalParticipant
		waypoints: { 430 @ 107. 430 @ 320 }
		processMemento: memento.
	assessment := operation assess.

	self assert: createAssessment isApplicable.
	self assert: freshTask owningProcess isNil.
	self assert: assessment isApplicable.
	^ assessment
]


{ #category : 'examples - staged diagram context' }
CPProcessAtelierExamples >> diagramMementoContextReadsCurrentStagedDiagramState [
	<gtExample>
	| fixture memento collaborationContext diagramContext operation assessment edge |
	fixture := self collaborationFixture.
	memento := fixture at: 2.
	collaborationContext := CPProcessCollaborationContext inRootMemento: memento.
	diagramContext := collaborationContext diagramContext.

	self assert: diagramContext elements size equals: 2.

	operation := CPAtelierConnectMessageFlow
		source: (fixture at: 3)
		target: (fixture at: 6)
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento.
	assessment := operation apply.
	edge := assessment edge.

	self assert: assessment isApplicable.
	self assert: diagramContext elements size equals: 3.
	self assert: (diagramContext elements identityIncludes: edge).
	self assert: (diagramContext modelElementOf: edge) == assessment messageFlow.
	self assert: (diagramContext waypointsOf: edge) equals: ({ 250 @ 270. 250 @ 320 } asOrderedCollection).
	self assert: (diagramContext edgesForModelElement: assessment messageFlow) size equals: 1.
	self assert: (diagramContext edgesForModelElement: assessment messageFlow) first == edge.
	^ diagramContext
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


{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> diagramEditingStagesMessageFlowWaypointsInCollaborationDiagram [
	<gtExample>
	| fixture memento diagramDescription connectAssessment editing proposed operation assessment context |
	fixture := self collaborationFixture.
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	connectAssessment := (CPAtelierConnectMessageFlow
		source: fixture third
		target: fixture sixth
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento) apply.
	editing := self diagramEditingForMemento: memento.
	proposed := { 250 @ 270. 360 @ 290. 250 @ 320 } asOrderedCollection.
	operation := editing setWaypoints: proposed forEdge: connectAssessment edge.
	assessment := operation apply.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: assessment isApplicable.
	self assert: (context diagramContext waypointsOf: connectAssessment edge) equals: proposed.
	self assert: connectAssessment edge waypoints equals: ({ 250 @ 270. 250 @ 320 } asOrderedCollection).
	^ assessment
]


{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> diagramEditingStagesMessageFlowLabelPlacementInCollaborationDiagram [
	<gtExample>
	| fixture memento diagramDescription connectAssessment editing operation assessment context edge |
	fixture := self collaborationFixture.
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	connectAssessment := (CPAtelierConnectMessageFlow
		source: fixture third
		target: fixture sixth
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento) apply.
	edge := connectAssessment edge.
	editing := self diagramEditingForMemento: memento.
	operation := editing
		setLabelSegmentIndex: 1
		segmentPosition: 0.4
		offset: 16
		forEdge: edge.
	assessment := operation apply.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: assessment isApplicable.
	self assert: (context diagramContext labelSegmentIndexOf: edge) equals: 1.
	self assert: (context diagramContext labelSegmentPositionOf: edge) equals: 0.4.
	self assert: (context diagramContext labelOffsetOf: edge) equals: 16.
	self assert: edge labelSegmentIndex isNil.
	self assert: edge labelSegmentPosition isNil.
	self assert: edge labelOffset isNil.
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
	self assert: (context processRefOf: participant) == process.
	self assert: participant processRef isNil.
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
CPProcessAtelierExamples >> createParticipantObservesStagedParticipantProcessReference [
	<gtExample>
	| fixture process memento localParticipant replacementParticipant context localMemento processRefDescription operation assessment |
	fixture := self collaborationFixture.
	process := fixture first.
	memento := fixture second.
	localParticipant := fixture fifth.
	context := CPProcessCollaborationContext inRootMemento: memento.
	localMemento := context mementoForMember: localParticipant.
	processRefDescription := self descriptionFor: #processRef in: localMemento.
	localMemento write: nil using: processRefDescription.
	replacementParticipant := CPParticipant new label: 'Replacement seller'; yourself.

	operation := CPAtelierCreateParticipant
		participant: replacementParticipant
		bounds: (40 @ 460 extent: 620 @ 100)
		processMemento: memento.
	assessment := operation apply.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: assessment isApplicable.
	self assert: assessment referencesProcess.
	self assert: (context processRefOf: localParticipant) isNil.
	self assert: localParticipant processRef == process.
	self assert: (context processRefOf: replacementParticipant) == process.
	self assert: replacementParticipant processRef isNil.
	^ assessment
]


{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> createFirstParticipantCommitPersistsStagedProcessReference [
	<gtExample>
	| process memento participant operation assessment |
	process := CPProcess new label: 'Process'; yourself.
	process diagram: CPDiagram new.
	memento := CFMaMemento model: process.
	participant := CPParticipant new label: 'Pool'; yourself.
	operation := CPAtelierCreateParticipant
		participant: participant
		bounds: (40 @ 40 extent: 620 @ 230)
		processMemento: memento.

	assessment := operation apply.
	self assert: assessment isApplicable.
	self assert: participant processRef isNil.
	memento commit.
	self assert: process definitionalCollaborationRef == assessment collaboration.
	self assert: participant processRef == process.
	^ assessment
]


{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> createFirstParticipantResetDiscardsStagedProcessReference [
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

	assessment := operation apply.
	collaborationDescription := self descriptionFor: #definitionalCollaborationRef in: memento.
	self assert: assessment isApplicable.
	self assert: participant processRef isNil.
	memento reset.
	self assert: (memento readUsing: collaborationDescription) isNil.
	self assert: process definitionalCollaborationRef isNil.
	self assert: participant processRef isNil.
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
CPProcessAtelierExamples >> removeDiagramSelectionRemovesMessageFlow [
	<gtExample>
	| fixture memento connectAssessment diagramDescription operation assessment context |
	fixture := self collaborationFixture.
	memento := fixture at: 2.
	connectAssessment := (CPAtelierConnectMessageFlow
		source: (fixture at: 3)
		target: (fixture at: 6)
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento) apply.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierRemoveDiagramElements
		diagramElements: { connectAssessment edge }
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).

	assessment := operation apply.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: assessment isApplicable.
	self assert: (context messageFlows identityIncludes: connectAssessment messageFlow) not.
	self assert: (context elements identityIncludes: connectAssessment edge) not.
	^ assessment
]


{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> removeDiagramSelectionDoesNotDoubleRemoveParticipantMessageFlow [
	<gtExample>
	| fixture memento externalPool connectAssessment diagramDescription operation assessment context |
	fixture := self collaborationFixture.
	memento := fixture at: 2.
	externalPool := fixture at: 9.
	connectAssessment := (CPAtelierConnectMessageFlow
		source: (fixture at: 3)
		target: (fixture at: 6)
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento) apply.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierRemoveDiagramElements
		diagramElements: { externalPool. connectAssessment edge }
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).

	assessment := operation apply.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: assessment isApplicable.
	self assert: assessment operations size equals: 1.
	self assert: (context participants identityIncludes: (fixture at: 6)) not.
	self assert: (context messageFlows identityIncludes: connectAssessment messageFlow) not.
	self assert: (context elements identityIncludes: externalPool) not.
	self assert: (context elements identityIncludes: connectAssessment edge) not.
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


{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> reconnectMessageFlowPreservesSemanticAndDiagramIdentity [
	<gtExample>
	| fixture memento context connectAssessment operation assessment flowMemento sourceDescription targetDescription |
	fixture := self collaborationFixture.
	memento := fixture second.
	connectAssessment := (CPAtelierConnectMessageFlow
		source: fixture third
		target: fixture sixth
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento) apply.
	context := CPProcessCollaborationContext inRootMemento: memento.
	operation := CPAtelierReconnectMessageFlow
		messageFlow: connectAssessment messageFlow
		source: fixture fifth
		target: fixture sixth
		waypoints: { 180 @ 270. 180 @ 320 }
		processMemento: memento.

	assessment := operation apply.
	flowMemento := context mementoForMember: connectAssessment messageFlow.
	sourceDescription := self descriptionFor: #sourceRef in: flowMemento.
	targetDescription := self descriptionFor: #targetRef in: flowMemento.

	self assert: assessment isApplicable.
	self assert: (context messageFlows identityIncludes: connectAssessment messageFlow).
	self assert: (context elements identityIncludes: connectAssessment edge).
	self assert: (flowMemento readUsing: sourceDescription) == fixture fifth.
	self assert: (flowMemento readUsing: targetDescription) == fixture sixth.
	self assert: (context diagramContext waypointsOf: connectAssessment edge)
		equals: ({ 180 @ 270. 180 @ 320 } asOrderedCollection).
	^ assessment
]

{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> reconnectMessageFlowRejectsEndpointsInSameParticipant [
	<gtExample>
	| fixture memento connectAssessment operation assessment |
	fixture := self collaborationFixture.
	memento := fixture second.
	connectAssessment := (CPAtelierConnectMessageFlow
		source: fixture third
		target: fixture sixth
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento) apply.
	operation := CPAtelierReconnectMessageFlow
		messageFlow: connectAssessment messageFlow
		source: fixture third
		target: fixture fifth
		waypoints: { 250 @ 270. 300 @ 270 }
		processMemento: memento.
	assessment := operation assess.

	self assert: assessment isApplicable not.
	^ assessment
]

{ #category : 'examples - collaboration message flow' }
CPProcessAtelierExamples >> diagramEditingReconnectsCollaborationEdgeThroughMessageFlowOperation [
	<gtExample>
	| fixture memento diagramDescription context connectAssessment editing operation assessment |
	fixture := self collaborationFixture.
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	connectAssessment := (CPAtelierConnectMessageFlow
		source: fixture third
		target: fixture sixth
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento) apply.
	editing := self diagramEditingForMemento: memento.
	operation := editing
		reconnectEdge: connectAssessment edge
		sourceShape: fixture eighth
		targetShape: fixture ninth
		waypoints: { 300 @ 270. 300 @ 320 }.
	assessment := operation apply.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: assessment isApplicable.
	self assert: (context stagedSourceOf: connectAssessment messageFlow) == fixture fifth.
	self assert: (context stagedTargetOf: connectAssessment messageFlow) == fixture sixth.
	self assert: (context diagramContext waypointsOf: connectAssessment edge)
		equals: ({ 300 @ 270. 300 @ 320 } asOrderedCollection).
	^ assessment
]

{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> createBoundaryEventStagesAttachmentAndDiagramShape [
	<gtExample>
	| process task diagram taskShape memento diagramDescription event operation assessment context eventMemento attachedDescription |
	process := CPProcess new.
	task := CPUserTask new label: 'Task'; yourself.
	process addFlowElement: task.
	diagram := CPDiagram new.
	taskShape := CPShape new modelElement: task; bounds: (100 @ 100 extent: 140 @ 80); yourself.
	diagram addElement: taskShape.
	process diagram: diagram.
	memento := CFMaMemento model: process.
	diagramDescription := memento magritteDescription detect: [ :each | each handlesSelector: #diagram ].
	event := CPBoundaryEvent new eventDefinitions: { CPTimerEventDefinition new } asOrderedCollection; yourself.
	operation := CPAtelierCreateBoundaryEvent boundaryEvent: event attachedTo: task bounds: (84 @ 124 extent: 32 @ 32) flowContainer: process processMemento: memento diagramContext: (self diagramContextForMemento: memento).
	assessment := operation apply.
	self assert: assessment isApplicable.
	context := CPProcessFlowContainerContext rootFor: memento.
	self assert: (context stagedFlowElements identityIncludes: event).
	eventMemento := context childMementoFor: event.
	attachedDescription := eventMemento magritteDescription detect: [ :each | each handlesSelector: #attachedToRef ].
	self assert: (eventMemento readUsing: attachedDescription) == task.
	self assert: assessment shape bounds center equals: 100 @ 140.
	self assert: event attachedToRef isNil.
	^ assessment
]

{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> assessingBoundaryEventCreationDoesNotMutateStagedState [
	<gtExample>
	| process task diagram taskShape memento diagramDescription event operation firstAssessment secondAssessment flowContext diagramContext |
	process := CPProcess new.
	task := CPUserTask new label: 'Task'; yourself.
	process addFlowElement: task.
	diagram := CPDiagram new.
	taskShape := CPShape new modelElement: task; bounds: (100 @ 100 extent: 140 @ 80); yourself.
	diagram addElement: taskShape.
	process diagram: diagram.
	memento := CFMaMemento model: process.
	diagramDescription := memento magritteDescription detect: [ :each | each handlesSelector: #diagram ].
	event := CPBoundaryEvent new eventDefinitions: { CPTimerEventDefinition new } asOrderedCollection; yourself.
	operation := CPAtelierCreateBoundaryEvent
		boundaryEvent: event
		attachedTo: task
		bounds: (84 @ 124 extent: 32 @ 32)
		flowContainer: process
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).
	flowContext := CPProcessFlowContainerContext rootFor: memento.
	diagramContext := CPDiagramMementoContext
		diagram: (memento readUsing: diagramDescription)
		inMemento: memento
		using: diagramDescription.

	firstAssessment := operation assess.
	secondAssessment := operation assess.

	self assert: firstAssessment isApplicable.
	self assert: secondAssessment isApplicable.
	self assert: (flowContext stagedFlowElements identityIncludes: event) not.
	self assert: flowContext stagedFlowElements size equals: 1.
	self assert: diagramContext elements size equals: 1.
	self assert: (diagramContext elements anySatisfy: [ :each | (diagramContext modelElementOf: each) == event ]) not.
	^ secondAssessment
]

{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> boundaryEventCannotBeSequenceFlowTarget [
	<gtExample>
	| process source boundary topology result |
	process := CPProcess new.
	source := CPUserTask new.
	boundary := CPBoundaryEvent new eventDefinitions: { CPTimerEventDefinition new } asOrderedCollection; yourself.
	process addFlowElement: source; addFlowElement: boundary.
	topology := CPProcessTopology fromProcess: process.
	result := CPSequenceFlowConnectionRules new assessConnectionFrom: source to: boundary in: topology.
	self assert: result isAllowed not.
	^ result
]

{ #category : 'private - fixture' }
CPProcessAtelierExamples >> boundaryEventFixture [
	| process task boundary finish flow diagram taskShape boundaryShape finishShape edge memento |
	process := CPProcess new label: 'Boundary event process'; yourself.
	task := CPUserTask new label: 'Work'; yourself.
	boundary := CPBoundaryEvent new
		label: 'Timeout';
		attachedToRef: task;
		eventDefinitions: { CPTimerEventDefinition new } asOrderedCollection;
		yourself.
	finish := CPNoneEndEvent new label: 'Escalated'; yourself.
	flow := CPSequenceFlow new
		sourceRef: boundary;
		targetRef: finish;
		yourself.
	process
		addFlowElement: task;
		addFlowElement: boundary;
		addFlowElement: finish;
		addFlowElement: flow.
	diagram := CPDiagram new.
	process diagram: diagram.
	taskShape := CPShape new modelElement: task; bounds: (100 @ 100 extent: 140 @ 80); yourself.
	boundaryShape := CPShape new modelElement: boundary; bounds: (79 @ 119 extent: 42 @ 42); yourself.
	finishShape := CPShape new modelElement: finish; bounds: (350 @ 119 extent: 42 @ 42); yourself.
	edge := CPEdge new modelElement: flow; yourself.
	edge addWaypoint: 100 @ 140; addWaypoint: 350 @ 140.
	diagram
		addElement: taskShape;
		addElement: boundaryShape;
		addElement: finishShape;
		addElement: edge.
	memento := CFMaMemento model: process.
	^ { process. memento. task. boundary. finish. flow. diagram. taskShape. boundaryShape. finishShape. edge }
]

{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> movingActivityCarriesAttachedBoundaryEventAndItsEdgeEndpoint [
	<gtExample>
	| fixture memento diagramDescription operation assessment boundsByShape |
	fixture := self boundaryEventFixture.
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	boundsByShape := IdentityDictionary new
		at: fixture eighth put: (140 @ 130 extent: 140 @ 80);
		yourself.
	operation := CPAtelierMoveShapes
		boundsByShape: boundsByShape
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (self stagedBoundsOf: fixture eighth processMemento: memento)
		equals: (140 @ 130 extent: 140 @ 80).
	self assert: (self stagedBoundsOf: fixture ninth processMemento: memento)
		equals: (119 @ 149 extent: 42 @ 42).
	self assert: (self stagedWaypointsOf: (fixture at: 11) processMemento: memento)
		equals: ({ 140 @ 170. 350 @ 140 } asOrderedCollection).
	self assert: fixture ninth bounds equals: (79 @ 119 extent: 42 @ 42).
	^ assessment
]

{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> resizingActivityPreservesAttachedBoundaryEventSideAndRelativePosition [
	<gtExample>
	| fixture memento diagramDescription operation assessment |
	fixture := self boundaryEventFixture.
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierResizeShape
		shape: (fixture at: 8)
		bounds: (120 @ 90 extent: 200 @ 120)
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (self stagedBoundsOf: (fixture at: 8) processMemento: memento)
		equals: (120 @ 90 extent: 200 @ 120).
	self assert: (self stagedBoundsOf: (fixture at: 9) processMemento: memento)
		equals: (99 @ 129 extent: 42 @ 42).
	self assert: (self stagedWaypointsOf: (fixture at: 11) processMemento: memento)
		equals: ({ 120 @ 150. 350 @ 140 } asOrderedCollection).
	self assert: (fixture at: 9) bounds equals: (79 @ 119 extent: 42 @ 42).
	^ assessment
]

{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> removingActivityOwnsAttachedBoundaryEventAndIncidentSequenceFlow [
	<gtExample>
	| fixture memento diagramDescription operation assessment context diagramContext |
	fixture := self boundaryEventFixture.
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierRemoveFlowNode
		flowNode: fixture third
		flowContainer: fixture first
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).

	assessment := operation apply.
	context := CPProcessFlowContainerContext rootFor: memento.
	diagramContext := CPDiagramMementoContext
		diagram: (memento readUsing: diagramDescription)
		inMemento: memento
		using: diagramDescription.

	self assert: assessment isApplicable.
	self assert: (assessment removedFlowNodes includes: fixture third).
	self assert: (assessment removedFlowNodes includes: fixture fourth).
	self assert: (assessment removedSequenceFlows identityIncludes: fixture sixth).
	self assert: (context stagedFlowElements identityIncludes: fixture third) not.
	self assert: (context stagedFlowElements identityIncludes: fixture fourth) not.
	self assert: (context stagedFlowElements identityIncludes: fixture sixth) not.
	self assert: (context stagedFlowElements identityIncludes: fixture fifth).
	self assert: (diagramContext elements identityIncludes: fixture eighth) not.
	self assert: (diagramContext elements identityIncludes: fixture ninth) not.
	self assert: (diagramContext elements identityIncludes: (fixture at: 11)) not.
	self assert: (diagramContext elements identityIncludes: (fixture at: 10)).
	^ assessment
]

{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> removingSelectedActivitySuppressesDependentBoundaryEventAndFlowOperations [
	<gtExample>
	| fixture memento diagramDescription operation assessment |
	fixture := self boundaryEventFixture.
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	operation := CPAtelierRemoveDiagramElements
		diagramElements: { fixture eighth. fixture ninth. (fixture at: 11) }
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: assessment operations size equals: 1.
	self assert: assessment operationAssessments first removedFlowNodes size equals: 2.
	^ assessment
]

{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> reattachingBoundaryEventStagesNewActivityBoundsAndIncidentEdgeEndpoint [
	<gtExample>
	| fixture process memento diagramDescription secondTask secondTaskShape context diagramContext eventMemento attachedDescription operation assessment stagedElements |
	fixture := self boundaryEventFixture.
	process := fixture first.
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	context := CPProcessFlowContainerContext rootFor: memento.
	diagramContext := CPDiagramMementoContext
		diagram: (memento readUsing: diagramDescription)
		inMemento: memento
		using: diagramDescription.

	secondTask := CPUserTask new label: 'Other work'; yourself.
	secondTaskShape := CPShape new
		modelElement: secondTask;
		bounds: (220 @ 260 extent: 160 @ 90);
		yourself.
	context writeFlowElements: (context stagedFlowElements asOrderedCollection copy add: secondTask; yourself).
	context childMementoFor: secondTask.
	stagedElements := diagramContext elements asOrderedCollection copy
		add: secondTaskShape;
		yourself.
	diagramContext writeElements: stagedElements.

	operation := CPAtelierReattachBoundaryEvent
		boundaryEvent: fixture fourth
		shape: (fixture at: 9)
		attachedTo: secondTask
		bounds: (199 @ 284 extent: 42 @ 42)
		flowContainer: process
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).
	assessment := operation apply.

	self assert: assessment isApplicable.
	eventMemento := context childMementoFor: fixture fourth.
	attachedDescription := eventMemento magritteDescription detect: [ :each | each handlesSelector: #attachedToRef ].
	self assert: (eventMemento readUsing: attachedDescription) == secondTask.
	self assert: fixture fourth attachedToRef == fixture third.
	self assert: (diagramContext boundsOf: (fixture at: 9)) equals: (199 @ 284 extent: 42 @ 42).
	self assert: (diagramContext waypointsOf: (fixture at: 11))
		equals: ({ 220 @ 305. 350 @ 140 } asOrderedCollection).
	^ assessment
]

{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> diagramEditingBuildsBoundaryEventReattachmentOperation [
	<gtExample>
	| fixture memento diagramDescription secondTask secondTaskShape context diagramContext editing operation assessment |
	fixture := self boundaryEventFixture.
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	context := CPProcessFlowContainerContext rootFor: memento.
	diagramContext := CPDiagramMementoContext
		diagram: (memento readUsing: diagramDescription)
		inMemento: memento
		using: diagramDescription.
	secondTask := CPUserTask new label: 'Other work'; yourself.
	secondTaskShape := CPShape new modelElement: secondTask; bounds: (220 @ 260 extent: 160 @ 90); yourself.
	context writeFlowElements: (context stagedFlowElements asOrderedCollection copy add: secondTask; yourself).
	context childMementoFor: secondTask.
	diagramContext writeElements: (diagramContext elements asOrderedCollection copy add: secondTaskShape; yourself).

	editing := self diagramEditingForMemento: memento.
	operation := editing
		reattachBoundaryEvent: (fixture at: 9)
		toActivityShape: secondTaskShape
		bounds: (199 @ 284 extent: 42 @ 42).
	self assert: operation notNil.
	assessment := operation assess.
	self assert: assessment isApplicable.
	^ assessment
]


{ #category : 'examples - boundary events' }
CPProcessAtelierExamples >> changingBoundaryEventDefinitionPreservesBoundaryIdentity [
	<gtExample>
	| fixture memento context boundary eventMemento description operation assessment definitions |
	fixture := self boundaryEventFixture.
	memento := fixture second.
	boundary := fixture fourth.
	context := CPProcessFlowContainerContext rootFor: memento.
	operation := CPAtelierSetBoundaryEventDefinition
		boundaryEvent: boundary
		definitionClass: CPEscalationEventDefinition
		flowContainer: fixture first
		processMemento: memento.
	assessment := operation apply.
	self assert: assessment isApplicable.
	eventMemento := context childMementoFor: boundary.
	description := eventMemento magritteDescription detect: [ :each | each handlesSelector: #eventDefinitions ].
	definitions := eventMemento readUsing: description.
	self assert: definitions size equals: 1.
	self assert: definitions first class equals: CPEscalationEventDefinition.
	self assert: boundary eventDefinitions first class equals: CPTimerEventDefinition.
	self assert: (context stagedFlowElements identityIncludes: boundary).
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessAtelierExamples >> createLaneStagesLaneSetLaneAndShapeAtomically [
	<gtExample>
	| process diagram memento diagramDescription lane operation assessment laneSetsDescription stagedLaneSets laneSetMemento lanesDescription stagedLanes diagramMemento elementsDescription stagedElements laneShape |
	process := CPProcess new label: 'Lane creation'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	lane := CPLane new label: 'Review'; yourself.
	operation := CPAtelierCreateLane
		lane: lane
		bounds: (40 @ 40 extent: 500 @ 140)
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).

	assessment := operation assess.
	self assert: assessment isApplicable.
	self assert: process laneSets isEmpty.
	self assert: diagram elements isEmpty.

	assessment := operation apply.
	self assert: assessment isApplicable.
	self assert: process laneSets isEmpty.
	self assert: diagram elements isEmpty.

	laneSetsDescription := self descriptionFor: #laneSets in: memento.
	stagedLaneSets := memento readUsing: laneSetsDescription.
	self assert: stagedLaneSets size equals: 1.
	laneSetMemento := memento childMementoFor: stagedLaneSets first inRelation: laneSetsDescription.
	lanesDescription := self descriptionFor: #lanes in: laneSetMemento.
	stagedLanes := laneSetMemento readUsing: lanesDescription.
	self assert: stagedLanes size equals: 1.
	self assert: stagedLanes first == lane.

	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.
	laneShape := stagedElements detect: [ :each | each modelElement == lane ].
	self assert: laneShape bounds equals: (40 @ 40 extent: 500 @ 140).
	^ assessment
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> boundaryEventDefinitionCommitAndReset [
	<gtExample>
	| fixture root event child description original operation |
	fixture := self boundaryEventFixture.
	root := fixture second.
	event := fixture fourth.
	child := (CPProcessFlowContainerContext rootFor: root) childMementoFor: event.
	description := self descriptionFor: #eventDefinitions in: child.
	original := event eventDefinitions first.
	operation := CPAtelierSetBoundaryEventDefinition boundaryEvent: event definitionClass: CPEscalationEventDefinition flowContainer: fixture first processMemento: root.
	self assert: operation apply isApplicable.
	self assert: root hasChangesToCommit.
	self assert: event eventDefinitions first == original.
	root reset.
	self assert: (child readUsing: description) first == original.
	self assert: root hasChangesToCommit not.
	self assert: operation apply isApplicable.
	root commit.
	self assert: event eventDefinitions first class equals: CPEscalationEventDefinition.
	self assert: root hasChangesToCommit not.
	self assert: ((CPAtelierSetBoundaryEventDefinition boundaryEvent: event definitionClass: CPMessageEventDefinition flowContainer: fixture first processMemento: root) apply) isApplicable.
	root reset.
	self assert: (child readUsing: description) first class equals: CPEscalationEventDefinition.
	^ root
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> transactionTransferFixture [
	| process moving target nested call companion flow diagram root context movingContext child callMemento called |
	process := CPProcess new label: 'Transfer transaction'; yourself.
	moving := CPNoneSubProcess new label: 'Moving'; yourself.
	target := CPNoneSubProcess new label: 'Target'; yourself.
	nested := CPUserTask new label: 'Original child'; yourself.
	call := CPCallActivity new label: 'Call'; yourself.
	companion := CPUserTask new label: 'Companion'; yourself.
	moving addFlowElement: nested.
	process addFlowElement: moving; addFlowElement: target; addFlowElement: call; addFlowElement: companion.
	flow := CPSequenceFlow new sourceRef: moving; targetRef: companion; yourself.
	process addFlowElement: flow.
	diagram := CPDiagram new.
	process diagram: diagram.
	{ moving. target. nested. call. companion } do: [ :each |
		diagram addElement: (CPShape new modelElement: each; bounds: (50 @ 50 extent: 160 @ 100); yourself) ].
	diagram addElement: (CPEdge new modelElement: flow; waypoints: { 100 @ 100. 300 @ 100 } asOrderedCollection; yourself).
	root := CFMaMemento model: process.
	context := CPProcessFlowContainerContext rootFor: root.
	movingContext := context childContextForSubProcess: moving.
	child := movingContext childMementoFor: nested.
	child write: 'Staged child edit' using: (self descriptionFor: #label in: child).
	called := CPProcess new label: 'Staged called process'; yourself.
	callMemento := context childMementoFor: call.
	callMemento write: called using: (self descriptionFor: #calledElement in: callMemento).
	^ { process. root. moving. target. nested. call. companion. flow. child. callMemento. called }
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> transferFixtureGroup: fixture [
	| bounds waypoints |
	bounds := IdentityDictionary new.
	{ fixture third. fixture seventh } do: [ :each | bounds at: each put: (20 @ 20 extent: 160 @ 100) ].
	waypoints := IdentityDictionary new at: fixture eighth put: { 50 @ 50. 200 @ 50 } asOrderedCollection; yourself.
	^ CPAtelierTransferFlowNodes flowNodes: { fixture third. fixture seventh } targetContainer: fixture fourth boundsByFlowNode: bounds waypointsBySequenceFlow: waypoints processMemento: fixture second diagramContext: (self diagramContextForMemento: fixture second)
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> groupTransferPreservesEditingTreeThroughCommit [
	<gtExample>
	| f root source movingMemento destination child |
	f := self transactionTransferFixture.
	root := f second.
	source := CPProcessFlowContainerContext rootFor: root.
	movingMemento := source childMementoFor: f third.
	self assert: (self transferFixtureGroup: f) apply isApplicable.
	destination := (CPProcessFlowContainerContext rootFor: root) childContextForSubProcess: f fourth.
	self assert: (destination childMementoFor: f third) == movingMemento.
	child := (destination childContextForSubProcess: f third) childMementoFor: f fifth.
	self assert: child == f ninth.
	self assert: (child readUsing: (self descriptionFor: #label in: child)) equals: 'Staged child edit'.
	self assert: (root hasChildMementoFor: f third inRelation: source flowElementsDescription) not.
	self assert: f fifth label equals: 'Original child'.
	root commit.
	self assert: f fifth label equals: 'Staged child edit'.
	self assert: f third container == f fourth.
	self assert: f seventh container == f fourth.
	self assert: f eighth container == f fourth.
	self assert: f eighth sourceRef == f third.
	self assert: f eighth targetRef == f seventh.
	self assert: (f third outgoing identityIncludes: f eighth).
	self assert: (f seventh incoming identityIncludes: f eighth).
	self assert: (destination childMementoFor: f third) == movingMemento.
	self assert: root hasChangesToCommit not.
	^ root
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> singleTransferPreservesAllFieldsThroughCommit [
	<gtExample>
	| f root operation destination |
	f := self transactionTransferFixture.
	root := f second.
	operation := CPAtelierTransferFlowNode flowNode: f sixth targetContainer: f fourth bounds: (20 @ 20 extent: 160 @ 100) processMemento: root diagramContext: (self diagramContextForMemento: root).
	self assert: operation apply isApplicable.
	destination := (CPProcessFlowContainerContext rootFor: root) childContextForSubProcess: f fourth.
	self assert: (destination childMementoFor: f sixth) == (f at: 10).
	self assert: f sixth calledElement isNil.
	root commit.
	self assert: f sixth calledElement == (f at: 11).
	self assert: f sixth container == f fourth.
	self assert: f eighth sourceRef == f third.
	self assert: f eighth targetRef == f seventh.
	self assert: root hasChangesToCommit not.
	^ root
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> groupTransferResetRestoresOriginalEditingTree [
	<gtExample>
	| f root source movingMemento destination child |
	f := self transactionTransferFixture.
	root := f second.
	source := CPProcessFlowContainerContext rootFor: root.
	movingMemento := source childMementoFor: f third.
	self assert: (self transferFixtureGroup: f) apply isApplicable.
	destination := (CPProcessFlowContainerContext rootFor: root) childContextForSubProcess: f fourth.
	root reset.
	self assert: (source childMementoFor: f third) == movingMemento.
	child := (source childContextForSubProcess: f third) childMementoFor: f fifth.
	self assert: child == f ninth.
	self assert: (child readUsing: (self descriptionFor: #label in: child)) equals: 'Original child'.
	self assert: (destination memento hasChildMementoFor: f third inRelation: destination flowElementsDescription) not.
	self assert: (source stagedFlowElements identityIncludes: f third).
	self assert: destination stagedFlowElements isEmpty.
	self assert: root hasChangesToCommit not.
	^ root
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> singleTransferRoundTripResetPreservesIdentity [
	<gtExample>
	| f root diagramDescription source destination original |
	f := self transactionTransferFixture.
	root := f second.
	diagramDescription := self descriptionFor: #diagram in: root.
	source := CPProcessFlowContainerContext rootFor: root.
	original := f at: 10.
	self assert: (CPAtelierTransferFlowNode flowNode: f sixth targetContainer: f fourth bounds: (20 @ 20 extent: 160 @ 100) processMemento: root diagramContext: (self diagramContextForMemento: root)) apply isApplicable.
	destination := source childContextForSubProcess: f fourth.
	self assert: (CPAtelierTransferFlowNode flowNode: f sixth targetContainer: f first bounds: (70 @ 70 extent: 160 @ 100) processMemento: root diagramContext: (self diagramContextForMemento: root)) apply isApplicable.
	self assert: (source childMementoFor: f sixth) == original.
	root reset.
	self assert: (source childMementoFor: f sixth) == original.
	self assert: (original readUsing: (self descriptionFor: #calledElement in: original)) isNil.
	self assert: (destination memento hasChildMementoFor: f sixth inRelation: destination flowElementsDescription) not.
	self assert: f sixth container == f first.
	self assert: root hasChangesToCommit not.
	^ root
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> transferThenRemoveResetRestoresDescendantIdentity [
	<gtExample>
	| f root diagramDescription source original |
	f := self transactionTransferFixture.
	root := f second.
	diagramDescription := self descriptionFor: #diagram in: root.
	source := CPProcessFlowContainerContext rootFor: root.
	original := source childMementoFor: f third.
	self assert: (self transferFixtureGroup: f) apply isApplicable.
	self assert: (CPAtelierRemoveFlowNode flowNode: f third flowContainer: f fourth processMemento: root diagramContext: (self diagramContextForMemento: root)) apply isApplicable.
	root reset.
	self assert: (source childMementoFor: f third) == original.
	self assert: ((source childContextForSubProcess: f third) childMementoFor: f fifth) == f ninth.
	self assert: f fifth label equals: 'Original child'.
	self assert: f eighth sourceRef == f third.
	self assert: f eighth targetRef == f seventh.
	self assert: root hasChangesToCommit not.
	^ root
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> transferThenRemoveCommitDiscardsRemovedDescendantEdits [
	<gtExample>
	| f root diagramDescription |
	f := self transactionTransferFixture.
	root := f second.
	diagramDescription := self descriptionFor: #diagram in: root.
	self assert: (self transferFixtureGroup: f) apply isApplicable.
	self assert: (CPAtelierRemoveFlowNode flowNode: f third flowContainer: f fourth processMemento: root diagramContext: (self diagramContextForMemento: root)) apply isApplicable.
	root commit.
	self assert: f fifth label equals: 'Original child'.
	self assert: (f first flowElements identityIncludes: f third) not.
	self assert: (f fourth flowElements identityIncludes: f third) not.
	self assert: f third container isNil.
	self assert: f eighth sourceRef isNil.
	self assert: f eighth targetRef isNil.
	self assert: root hasChangesToCommit not.
	^ root
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> groupTransferBetweenSiblingContainersCommitsTopology [
	<gtExample>
	| f root destination original bounds waypoints nested source |
	f := self transactionTransferFixture.
	root := f second.
	original := f ninth.
	self assert: (self transferFixtureGroup: f) apply isApplicable.
	root commit.
	source := f fourth.
	destination := CPNoneSubProcess new label: 'Sibling'; yourself.
	"Create a second committed container and a fresh transaction for the sibling move."
	f first addFlowElement: destination.
	root := CFMaMemento model: f first.
	nested := ((CPProcessFlowContainerContext rootFor: root) childContextForSubProcess: source) childContextForSubProcess: f third.
	original := nested childMementoFor: f fifth.
	original write: 'Sibling edit' using: (self descriptionFor: #label in: original).
	bounds := IdentityDictionary new.
	{ f third. f seventh } do: [ :each | bounds at: each put: (30 @ 30 extent: 160 @ 100) ].
	waypoints := IdentityDictionary new at: f eighth put: { 60 @ 60. 210 @ 60 } asOrderedCollection; yourself.
	self assert: (CPAtelierTransferFlowNodes flowNodes: { f third. f seventh } targetContainer: destination boundsByFlowNode: bounds waypointsBySequenceFlow: waypoints processMemento: root diagramContext: (self diagramContextForMemento: root)) apply isApplicable.
	root commit.
	self assert: source flowElements isEmpty.
	self assert: f third container == destination.
	self assert: f eighth container == destination.
	self assert: f eighth sourceRef == f third.
	self assert: f eighth targetRef == f seventh.
	self assert: (f third outgoing identityIncludes: f eighth).
	self assert: (f seventh incoming identityIncludes: f eighth).
	self assert: f fifth label equals: 'Sibling edit'.
	self assert: root hasChangesToCommit not.
	^ root
]

{ #category : 'examples - transaction' }
CPProcessAtelierExamples >> reversingNestedContainerOwnershipCommitsWithoutLosingLinks [
	<gtExample>
	| process outer inner root diagramDescription originalChild |
	process := CPProcess new label: 'Rotation'; yourself.
	outer := CPNoneSubProcess new label: 'Outer'; yourself.
	inner := CPNoneSubProcess new label: 'Inner'; yourself.
	outer addFlowElement: inner.
	process addFlowElement: outer.
	process diagram: CPDiagram new.
	{ outer. inner } do: [ :each | process diagram addElement: (CPShape new modelElement: each; bounds: (50 @ 50 extent: 160 @ 100); yourself) ].
	root := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: root.
	originalChild := ((CPProcessFlowContainerContext rootFor: root) childContextForSubProcess: outer) childMementoFor: inner.
	self assert: (CPAtelierTransferFlowNode flowNode: inner targetContainer: process bounds: (60 @ 60 extent: 160 @ 100) processMemento: root diagramContext: (self diagramContextForMemento: root)) apply isApplicable.
	self assert: (CPAtelierTransferFlowNode flowNode: outer targetContainer: inner bounds: (20 @ 20 extent: 160 @ 100) processMemento: root diagramContext: (self diagramContextForMemento: root)) apply isApplicable.
	root commit.
	self assert: inner container == process.
	self assert: outer container == inner.
	self assert: outer flowElements isEmpty.
	self assert: inner flowElements first == outer.
	self assert: process flowElements first == inner.
	self assert: (root childMementoFor: inner inRelation: (self descriptionFor: #flowElements in: root)) == originalChild.
	self assert: root hasChangesToCommit not.
	^ root
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> editingSessionCarriesProcessAndDepictionExplicitly [
	<gtExample>
	| fixture memento session |
	fixture := self fixture.
	memento := fixture second.
	session := CPProcessAtelierSession forProcessMemento: memento.
	self assert: session rootMemento == memento.
	self assert: session processMemento == memento.
	self assert: session diagramContext diagram == fixture eighth.
	^ session
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> editingSessionAllowsSemanticFocusWithoutDepiction [
	<gtExample>
	| process memento session |
	process := CPProcess new label: 'Undepicted process'; yourself.
	memento := CFMaMemento model: process.
	session := CPProcessAtelierSession forProcessMemento: memento.
	self assert: session rootMemento == memento.
	self assert: session processMemento == memento.
	self assert: session diagramContext isNil.
	^ session
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> legacyProcessEntryRetainsConfiguredPalette [
	<gtExample>
	| process diagram viewModel |
	process := CPProcess new label: 'Legacy entry'; yourself.
	diagram := CPDiagram new modelElement: process; yourself.
	process diagram: diagram.

	viewModel := process asAtelier.

	self assert: viewModel object == process.
	self assert: viewModel palette notNil.
	self assert: viewModel palette items isEmpty not.
	^ viewModel
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> legacyProcessNavigationCanBeRepresentedByDefinitionsSession [
	<gtExample>
	| process diagram definitions session |
	process := CPProcess new label: 'Legacy navigation'; yourself.
	diagram := CPDiagram new modelElement: process; yourself.
	process diagram: diagram.
	definitions := CPDefinitions new
		addRootElement: process;
		addDiagram: diagram;
		yourself.

	session := CPProcessAtelierSession
		forDefinitions: definitions
		process: process
		diagram: diagram.

	self assert: session rootMemento model == definitions.
	self assert: session processMemento model == process.
	self assert: (session processMemento == session rootMemento) not.
	self assert: session diagramContext diagram == diagram.
	^ session
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> definitionsIsCanonicalAtelierEntry [
	<gtExample>
	| definitions process diagram viewModel session |
	definitions := CPDefinitions new
		targetNamespace: 'urn:catalyst:document-entry';
		yourself.
	process := CPProcess new label: 'Focused process'; yourself.
	diagram := CPDiagram new modelElement: process; yourself.
	definitions
		addRootElement: process;
		addDiagram: diagram.

	session := CPProcessAtelierSession
		forDefinitions: definitions
		process: process
		diagram: diagram.
	viewModel := definitions asAtelierForProcess: process diagram: diagram.

	self assert: viewModel object == process.
	self assert: session rootMemento model == definitions.
	self assert: session processMemento model == process.
	self assert: session processMemento ~~ session rootMemento.
	self assert: session diagramContext diagram == diagram.
	self assert: session documentContext definitionsMemento == session rootMemento.
	^ viewModel
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> definitionsEditingSessionUsesDocumentRootAndChosenDepiction [
	<gtExample>
	| definitions process diagram root session |
	definitions := CPDefinitions new
		targetNamespace: 'urn:catalyst:session';
		yourself.
	process := CPProcess new label: 'Focused process'; yourself.
	diagram := CPDiagram new.
	diagram modelElement: process.
	definitions
		addRootElement: process;
		addDiagram: diagram.
	root := CFMaMemento model: definitions.
	session := CPProcessAtelierSession
		forDefinitionsMemento: root
		process: process
		diagram: diagram.
	self assert: session rootMemento == root.
	self assert: session documentContext definitionsMemento == root.
	self assert: session processMemento model == process.
	self assert: session diagramContext diagram == diagram.
	self assert: session diagramContext planeModelElement == process.
	^ session
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> definitionsEditingSessionKeepsExplicitDepictionChoice [
	<gtExample>
	| definitions process firstDiagram secondDiagram root session |
	definitions := CPDefinitions new
		targetNamespace: 'urn:catalyst:multiple-depictions';
		yourself.
	process := CPProcess new label: 'Shared semantic process'; yourself.
	firstDiagram := CPDiagram new modelElement: process; yourself.
	secondDiagram := CPDiagram new modelElement: process; yourself.
	definitions
		addRootElement: process;
		addDiagram: firstDiagram;
		addDiagram: secondDiagram.
	root := CFMaMemento model: definitions.
	session := CPProcessAtelierSession
		forDefinitionsMemento: root
		process: process
		diagram: secondDiagram.
	self assert: session documentContext diagrams size equals: 2.
	self assert: (session documentContext diagramsDepicting: process) size equals: 2.
	self assert: session diagramContext diagram == secondDiagram.
	^ session
]


{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> documentRootedSessionCreatesProcessFocusedViewModel [
	<gtExample>
	| definitions process diagram root session viewModel |
	definitions := CPDefinitions new
		targetNamespace: 'urn:catalyst:view-model-session';
		yourself.
	process := CPProcess new label: 'Focused process'; yourself.
	diagram := CPDiagram new.
	diagram plane modelElement: process.
	definitions
		addRootElement: process;
		addDiagram: diagram.
	root := CFMaMemento model: definitions.
	session := CPProcessAtelierSession
		forDefinitionsMemento: root
		process: process
		diagram: diagram.
	viewModel := session asViewModel.

	self assert: viewModel object == process.
	self assert: session rootMemento == root.
	self assert: session processMemento ~~ root.
	^ viewModel
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> definitionsEditingSessionUsesCanonicalCollaborationMemento [
	<gtExample>
	| definitions process collaboration participant diagram shape root session documentContext collaborationContext |
	definitions := CPDefinitions new
		targetNamespace: 'urn:catalyst:canonical-collaboration';
		yourself.
	process := CPProcess new label: 'Focused process'; yourself.
	collaboration := CPCollaboration new label: 'Collaboration'; yourself.
	participant := CPParticipant new
		label: 'Pool';
		processRef: process;
		yourself.
	collaboration addParticipant: participant.
	process definitionalCollaborationRef: collaboration.
	diagram := CPDiagram new modelElement: collaboration; yourself.
	shape := CPShape new
		modelElement: participant;
		bounds: (40 @ 40 extent: 500 @ 240);
		yourself.
	diagram addElement: shape.
	definitions
		addRootElement: process;
		addRootElement: collaboration;
		addDiagram: diagram.
	root := CFMaMemento model: definitions.
	session := CPProcessAtelierSession
		forDefinitionsMemento: root
		process: process
		diagram: diagram.
	documentContext := session documentContext.
	collaborationContext := session collaborationContext.

	self assert: collaborationContext notNil.
	self assert: collaborationContext collaboration == collaboration.
	self assert: collaborationContext collaborationMemento == (documentContext mementoForRootElement: collaboration).
	self assert: collaborationContext diagramContext == session diagramContext.
	self assert: collaborationContext participants first == participant.
	^ session
]

{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> documentRootedCreateFirstParticipantUsesDefinitionsOwnership [
	<gtExample>
	| definitions process processDiagram root session participant operation assessment collaboration collaborationDiagram |
	definitions := CPDefinitions new
		targetNamespace: 'urn:catalyst:participant-create';
		yourself.
	process := CPProcess new label: 'Process'; yourself.
	processDiagram := CPDiagram new modelElement: process; yourself.
	definitions
		addRootElement: process;
		addDiagram: processDiagram.
	root := CFMaMemento model: definitions.
	session := CPProcessAtelierSession
		forDefinitionsMemento: root
		process: process
		diagram: processDiagram.
	participant := CPParticipant new label: 'Pool'; yourself.
	operation := CPAtelierCreateParticipant
		participant: participant
		bounds: (40 @ 40 extent: 620 @ 230)
		processMemento: session processMemento
		documentContext: session documentContext
		collaborationContext: session collaborationContext.

	assessment := operation apply.
	collaboration := assessment collaboration.
	collaborationDiagram := assessment diagram.

	self assert: assessment isApplicable.
	self assert: assessment createsCollaboration.
	self assert: (session documentContext rootElements identityIncludes: collaboration).
	self assert: (session documentContext diagrams identityIncludes: collaborationDiagram).
	self assert: (session processMemento readUsing: process definitionalCollaborationRefDescription) == collaboration.
	self assert: (session documentContext mementoForRootElement: collaboration) model == collaboration.
	self assert: collaboration diagram isNil.
	^ assessment
]

{ #category : 'examples - collaboration participants' }
CPProcessAtelierExamples >> documentRootedRemoveSoleParticipantRemovesDefinitionsOwnedCollaboration [
	<gtExample>
	| definitions process collaboration participant diagram shape root session operation assessment |
	definitions := CPDefinitions new
		targetNamespace: 'urn:catalyst:participant-remove';
		yourself.
	process := CPProcess new label: 'Process'; yourself.
	collaboration := CPCollaboration new label: 'Collaboration'; yourself.
	participant := CPParticipant new
		label: 'Pool';
		processRef: process;
		yourself.
	collaboration addParticipant: participant.
	process definitionalCollaborationRef: collaboration.
	diagram := CPDiagram new modelElement: collaboration; yourself.
	shape := CPShape new
		modelElement: participant;
		bounds: (40 @ 40 extent: 620 @ 230);
		yourself.
	diagram addElement: shape.
	definitions
		addRootElement: process;
		addRootElement: collaboration;
		addDiagram: diagram.
	root := CFMaMemento model: definitions.
	session := CPProcessAtelierSession
		forDefinitionsMemento: root
		process: process
		diagram: diagram.
	operation := CPAtelierRemoveParticipant
		participant: participant
		processMemento: session processMemento
		documentContext: session documentContext
		collaborationContext: session collaborationContext.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: assessment removesCollaboration.
	self assert: (session documentContext rootElements identityIncludes: collaboration) not.
	self assert: (session documentContext diagrams identityIncludes: diagram) not.
	self assert: (session processMemento readUsing: process definitionalCollaborationRefDescription) isNil.
	self assert: process definitionalCollaborationRef == collaboration.
	^ assessment
]

{ #category : 'examples - collaboration message flows' }
CPProcessAtelierExamples >> documentRootedMessageFlowUsesSessionCollaborationContext [
	<gtExample>
	| definitions process collaboration sourceParticipant targetParticipant diagram sourceShape targetShape root session editing operation assessment |
	definitions := CPDefinitions new
		targetNamespace: 'urn:catalyst:message-flow-context';
		yourself.
	process := CPProcess new label: 'Process'; yourself.
	collaboration := CPCollaboration new label: 'Collaboration'; yourself.
	sourceParticipant := CPParticipant new label: 'Source'; processRef: process; yourself.
	targetParticipant := CPParticipant new label: 'Target'; yourself.
	collaboration
		addParticipant: sourceParticipant;
		addParticipant: targetParticipant.
	process definitionalCollaborationRef: collaboration.
	diagram := CPDiagram new modelElement: collaboration; yourself.
	sourceShape := CPShape new modelElement: sourceParticipant; bounds: (20 @ 20 extent: 400 @ 180); yourself.
	targetShape := CPShape new modelElement: targetParticipant; bounds: (520 @ 20 extent: 400 @ 180); yourself.
	diagram
		addElement: sourceShape;
		addElement: targetShape.
	definitions
		addRootElement: process;
		addRootElement: collaboration;
		addDiagram: diagram.
	root := CFMaMemento model: definitions.
	session := CPProcessAtelierSession
		forDefinitionsMemento: root
		process: process
		diagram: diagram.
	editing := CPProcessAtelierDiagramEditing
		processMemento: session processMemento
		diagramContext: session diagramContext
		collaborationContext: session collaborationContext
		documentContext: session documentContext.
	operation := editing
		connectFrom: sourceShape
		to: targetShape
		waypoints: (OrderedCollection with: 420 @ 110 with: 520 @ 110).
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (session collaborationContext messageFlows identityIncludes: assessment messageFlow).
	self assert: session collaborationContext collaborationMemento == (session documentContext mementoForRootElement: collaboration).
	^ assessment
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> definitionsEntryChoosesOnlyAvailableProcessDepiction [
	<gtExample>
	| definitions process diagram session viewModel |
	definitions := CPDefinitions new targetNamespace: 'urn:catalyst:unique-depiction'; yourself.
	process := CPProcess new label: 'Focused process'; yourself.
	diagram := CPDiagram new modelElement: process; yourself.
	definitions addRootElement: process; addDiagram: diagram.

	session := CPProcessAtelierSession forDefinitions: definitions process: process.
	viewModel := definitions asAtelierForProcess: process.

	self assert: session diagramContext diagram == diagram.
	self assert: viewModel object == process.
	self assert: viewModel palette notNil.
	self assert: viewModel palette items isEmpty not.
	^ viewModel
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> definitionsEntryRequiresChoiceBetweenMultipleDepictions [
	<gtExample>
	| definitions process firstDiagram secondDiagram raised |
	definitions := CPDefinitions new targetNamespace: 'urn:catalyst:multiple-depictions'; yourself.
	process := CPProcess new label: 'Focused process'; yourself.
	firstDiagram := CPDiagram new modelElement: process; yourself.
	secondDiagram := CPDiagram new modelElement: process; yourself.
	definitions addRootElement: process; addDiagram: firstDiagram; addDiagram: secondDiagram.

	raised := false.
	[ CPProcessAtelierSession forDefinitions: definitions process: process ]
		on: Error
		do: [ :anError | raised := true ].

	self assert: raised.
	^ definitions
]

{ #category : 'examples - editing session' }
CPProcessAtelierExamples >> definitionsEntryRecognizesCollaborationDepictionForProcess [
	<gtExample>
	| definitions process collaboration diagram session |
	definitions := CPDefinitions new targetNamespace: 'urn:catalyst:collaboration-depiction'; yourself.
	process := CPProcess new label: 'Hosted process'; yourself.
	collaboration := CPCollaboration new label: 'Collaboration'; yourself.
	process definitionalCollaborationRef: collaboration.
	diagram := CPDiagram new modelElement: collaboration; yourself.
	definitions addRootElement: process; addRootElement: collaboration; addDiagram: diagram.

	session := CPProcessAtelierSession forDefinitions: definitions process: process.

	self assert: session diagramContext diagram == diagram.
	self assert: session collaborationContext collaboration == collaboration.
	^ session
]

