"I lock down the production Process visual-editor adapter contract.

I compose the real CPProcessVisualElement with the real Process Atelier operations over one CFMaMemento. These examples deliberately sit in a package that depends on both BVC-BPM-GT and BVC-BPM-Atelier so neither production package acquires a reverse dependency merely for executable examples.

The semantic operation contract is covered by CPProcessAtelierExamples. Here I prove that the production visual element translates its editing intentions into that operation layer and keeps its selection state coherent around successful edits."
Class {
	#name : 'CPProcessVisualElementExamples',
	#superclass : 'CPProcessAtelierExamples',
	#category : 'BVC-BPM-GT-Examples-Editor',
	#package : 'BVC-BPM-GT-Examples',
	#tag : 'Editor'
}

{ #category : 'private - fixture' }
CPProcessVisualElementExamples >> visualElementForFixture: fixture [
	| memento diagramDescription flowElementsDescription visual |
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	visual := CPProcessVisualElement new.
	visual
		moveShapeOperationFor: [ :aShape :proposedBounds |
			CPAtelierMoveShape
				shape: aShape
				bounds: proposedBounds
				processMemento: memento
				diagramDescription: diagramDescription ];
		moveShapesOperationFor: [ :boundsByShape |
			CPAtelierMoveShapes
				boundsByShape: boundsByShape
				processMemento: memento
				diagramDescription: diagramDescription ];
		resizeShapeOperationFor: [ :aShape :proposedBounds |
			CPAtelierResizeShape
				shape: aShape
				bounds: proposedBounds
				processMemento: memento
				diagramDescription: diagramDescription ];
		createFlowNodeOperationFor: [ :aFlowNode :proposedBounds |
			CPAtelierCreateFlowNode
				flowNode: aFlowNode
				bounds: proposedBounds
				processMemento: memento
				flowElementsDescription: flowElementsDescription
				diagramDescription: diagramDescription ];
		replaceFlowNodeOperationFor: [ :aFlowNode :aReplacementNode :proposedBounds |
			CPAtelierReplaceFlowNode
				flowNode: aFlowNode
				with: aReplacementNode
				bounds: proposedBounds
				processMemento: memento
				flowElementsDescription: flowElementsDescription
				diagramDescription: diagramDescription ];
		connectFlowNodesOperationFor: [ :aSource :aTarget |
			CPAtelierConnectFlowNodes
				source: aSource
				target: aTarget
				processMemento: memento
				flowElementsDescription: flowElementsDescription
				diagramDescription: diagramDescription ];
		insertFlowNodeOperationFor: [ :aSequenceFlow :aFlowNode :proposedBounds |
			CPAtelierInsertFlowNode
				sequenceFlow: aSequenceFlow
				flowNode: aFlowNode
				bounds: proposedBounds
				processMemento: memento
				flowElementsDescription: flowElementsDescription
				diagramDescription: diagramDescription ];
		removeFlowNodeOperationFor: [ :aFlowNode |
			CPAtelierRemoveFlowNode
				flowNode: aFlowNode
				processMemento: memento
				flowElementsDescription: flowElementsDescription
				diagramDescription: diagramDescription ];
		removeSequenceFlowOperationFor: [ :aSequenceFlow |
			CPAtelierRemoveSequenceFlow
				sequenceFlow: aSequenceFlow
				processMemento: memento
				flowElementsDescription: flowElementsDescription
				diagramDescription: diagramDescription ];
		reconnectSequenceFlowOperationFor: [ :aSequenceFlow :aSource :aTarget |
			CPAtelierReconnectSequenceFlow
				sequenceFlow: aSequenceFlow
				source: aSource
				target: aTarget
				processMemento: memento
				flowElementsDescription: flowElementsDescription
				diagramDescription: diagramDescription ];
		setEdgeWaypointsOperationFor: [ :anEdge :someWaypoints |
			CPAtelierSetEdgeWaypoints
				edge: anEdge
				waypoints: someWaypoints
				processMemento: memento
				diagramDescription: diagramDescription ];
		setEdgeLabelPlacementOperationFor: [ :anEdge :segmentIndex :segmentPosition :offset |
			CPAtelierSetEdgeLabelPlacement
				edge: anEdge
				segmentIndex: segmentIndex
				segmentPosition: segmentPosition
				offset: offset
				processMemento: memento
				diagramDescription: diagramDescription ].
	visual memento: memento.
	^ visual
]

{ #category : 'examples - selection' }
CPProcessVisualElementExamples >> selectionSupportsExclusiveAndAdditiveSemanticSelection [
	<gtExample>
	| fixture visual start task firstFlow |
	fixture := self fixture.
	start := fixture third.
	task := fixture fourth.
	firstFlow := fixture sixth.
	visual := self visualElementForFixture: fixture.

	visual selectOnly: task.
	self assert: visual selectedModelElements size equals: 1.
	self assert: (visual selectedModelElements identityIncludes: task).

	visual toggleSelectionOf: firstFlow.
	self assert: visual selectedModelElements size equals: 2.
	self assert: (visual selectedModelElements identityIncludes: task).
	self assert: (visual selectedModelElements identityIncludes: firstFlow).

	visual selectOnly: start.
	self assert: visual selectedModelElements size equals: 1.
	self assert: (visual selectedModelElements identityIncludes: start).
	^ visual
]

{ #category : 'examples - delegation' }
CPProcessVisualElementExamples >> moveShapeDelegatesToSemanticOperationAndStagesCompleteEdit [
	<gtExample>
	| fixture visual memento taskShape firstEdge secondEdge assessment |
	fixture := self fixture.
	memento := fixture second.
	taskShape := fixture at: 10.
	firstEdge := fixture at: 12.
	secondEdge := fixture at: 13.
	visual := self visualElementForFixture: fixture.

	assessment := visual moveShape: taskShape toBounds: (260 @ 124 extent: 132 @ 54).

	self assert: assessment isApplicable.
	self assert: (self stagedBoundsOf: taskShape processMemento: memento) equals: (260 @ 124 extent: 132 @ 54).
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: ({ 142 @ 121. 260 @ 151 } asOrderedCollection).
	self assert: (self stagedWaypointsOf: secondEdge processMemento: memento) equals: ({ 392 @ 151. 430 @ 121 } asOrderedCollection).
	self assert: taskShape bounds equals: (220 @ 94 extent: 132 @ 54).
	^ visual
]

{ #category : 'examples - delegation' }
CPProcessVisualElementExamples >> groupMoveDelegatesAsOneSemanticEdit [
	<gtExample>
	| fixture visual memento startShape taskShape firstEdge boundsByShape assessment |
	fixture := self fixture.
	memento := fixture second.
	startShape := fixture at: 9.
	taskShape := fixture at: 10.
	firstEdge := fixture at: 12.
	visual := self visualElementForFixture: fixture.
	boundsByShape := IdentityDictionary new.
	boundsByShape
		at: startShape put: (130 @ 120 extent: 42 @ 42);
		at: taskShape put: (250 @ 114 extent: 132 @ 54).

	assessment := visual moveShapesToBounds: boundsByShape.

	self assert: assessment isApplicable.
	self assert: (self stagedBoundsOf: startShape processMemento: memento) equals: (130 @ 120 extent: 42 @ 42).
	self assert: (self stagedBoundsOf: taskShape processMemento: memento) equals: (250 @ 114 extent: 132 @ 54).
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: ({ 172 @ 141. 250 @ 141 } asOrderedCollection).
	^ visual
]

{ #category : 'examples - delegation' }
CPProcessVisualElementExamples >> resizeDelegatesToSemanticOperation [
	<gtExample>
	| fixture visual memento taskShape firstEdge secondEdge assessment |
	fixture := self fixture.
	memento := fixture second.
	taskShape := fixture at: 10.
	firstEdge := fixture at: 12.
	secondEdge := fixture at: 13.
	visual := self visualElementForFixture: fixture.

	assessment := visual resizeShape: taskShape toBounds: (220 @ 94 extent: 172 @ 74).

	self assert: assessment isApplicable.
	self assert: (self stagedBoundsOf: taskShape processMemento: memento) equals: (220 @ 94 extent: 172 @ 74).
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: ({ 142 @ 121. 240 @ 131 } asOrderedCollection).
	self assert: (self stagedWaypointsOf: secondEdge processMemento: memento) equals: ({ 372 @ 131. 430 @ 121 } asOrderedCollection).
	^ visual
]

{ #category : 'examples - delegation' }
CPProcessVisualElementExamples >> connectDelegatesAndStagesSemanticFlowWithDiagramEdge [
	<gtExample>
	| fixture visual memento start finish assessment stagedFlowElements diagramMemento elementsDescription stagedElements newFlow newEdge |
	fixture := self fixture.
	memento := fixture second.
	start := fixture third.
	finish := fixture fifth.
	visual := self visualElementForFixture: fixture.

	assessment := visual connectFrom: start to: finish.
	stagedFlowElements := memento readUsing: (self descriptionFor: #flowElements in: memento).
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.
	newFlow := assessment sequenceFlow.
	newEdge := assessment edge.

	self assert: assessment isApplicable.
	self assert: (stagedFlowElements identityIncludes: newFlow).
	self assert: (stagedElements identityIncludes: newEdge).
	self assert: newEdge modelElement == newFlow.
	self assert: (fixture first flowElements identityIncludes: newFlow) not.
	self assert: (fixture eighth elements identityIncludes: newEdge) not.
	^ visual
]

{ #category : 'examples - delegation' }
CPProcessVisualElementExamples >> reconnectDelegatesWithoutReplacingFlowOrEdgeIdentity [
	<gtExample>
	| fixture visual memento start finish firstFlow firstEdge assessment flowMemento sourceDescription targetDescription |
	fixture := self fixture.
	memento := fixture second.
	start := fixture third.
	finish := fixture fifth.
	firstFlow := fixture sixth.
	firstEdge := fixture at: 12.
	visual := self visualElementForFixture: fixture.

	assessment := visual reconnectSequenceFlow: firstFlow source: start target: finish.
	flowMemento := memento childMementoFor: firstFlow inRelation: (self descriptionFor: #flowElements in: memento).
	sourceDescription := self descriptionFor: #sourceRef in: flowMemento.
	targetDescription := self descriptionFor: #targetRef in: flowMemento.

	self assert: assessment isApplicable.
	self assert: (flowMemento readUsing: sourceDescription) == start.
	self assert: (flowMemento readUsing: targetDescription) == finish.
	self assert: firstFlow targetRef == fixture fourth.
	self assert: firstEdge modelElement == firstFlow.
	^ visual
]

{ #category : 'examples - delegation' }
CPProcessVisualElementExamples >> routingDelegatesAndPreservesCommittedWaypointsUntilCommit [
	<gtExample>
	| fixture visual memento firstEdge proposed assessment |
	fixture := self fixture.
	memento := fixture second.
	firstEdge := fixture at: 12.
	visual := self visualElementForFixture: fixture.
	proposed := { 142 @ 121. 180 @ 170. 220 @ 121 } asOrderedCollection.

	assessment := visual setWaypoints: proposed forEdge: firstEdge.

	self assert: assessment isApplicable.
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: proposed.
	self assert: firstEdge waypoints equals: ({ 142 @ 121. 220 @ 121 } asOrderedCollection).
	^ visual
]

{ #category : 'examples - delegation' }
CPProcessVisualElementExamples >> replacementDelegatesAndMovesSelectionToReplacement [
	<gtExample>
	| fixture visual memento task taskShape assessment stagedFlowElements replacement |
	fixture := self fixture.
	memento := fixture second.
	task := fixture fourth.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.
	visual selectOnly: task.

	assessment := visual replaceFlowNode: task withClass: CPServiceTask shape: taskShape.
	stagedFlowElements := memento readUsing: (self descriptionFor: #flowElements in: memento).
	replacement := stagedFlowElements detect: [ :each | each class == CPServiceTask ].

	self assert: assessment isApplicable.
	self assert: visual selectedModelElements size equals: 1.
	self assert: (visual selectedModelElements identityIncludes: replacement).
	self assert: (visual selectedModelElements identityIncludes: task) not.
	^ visual
]

{ #category : 'examples - removal' }
CPProcessVisualElementExamples >> removalTreatsSelectedNodeAndItsSelectedIncidentFlowAsOneSemanticRemoval [
	<gtExample>
	| fixture visual memento task firstFlow stagedFlowElements |
	fixture := self fixture.
	memento := fixture second.
	task := fixture fourth.
	firstFlow := fixture sixth.
	visual := self visualElementForFixture: fixture.
	visual selectOnly: task.
	visual toggleSelectionOf: firstFlow.

	visual removeSelection.
	stagedFlowElements := memento readUsing: (self descriptionFor: #flowElements in: memento).

	self assert: stagedFlowElements size equals: 2.
	self assert: (stagedFlowElements identityIncludes: task) not.
	self assert: (stagedFlowElements identityIncludes: firstFlow) not.
	self assert: (stagedFlowElements identityIncludes: fixture seventh) not.
	self assert: visual selectedModelElements isEmpty.
	^ visual
]


{ #category : 'examples - gestures - selection' }
CPProcessVisualElementExamples >> clickingShapeSelectsItsSemanticModelElement [
	<gtExample>
	| fixture visual task taskShape scripter |
	fixture := self fixture.
	task := fixture fourth.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.
	(visual shapeElementFor: taskShape) id: #processTaskShape.

	scripter := BlScripter new.
	scripter element: visual.
	scripter clickStep: [ :step |
		step
			label: 'Click task shape';
			id: #processTaskShape ].

	self assert: visual selectedModelElements size equals: 1.
	self assert: (visual selectedModelElements identityIncludes: task).
	self assert: visual selectedModelElement == task.
	^ scripter
]

{ #category : 'examples - gestures - selection' }
CPProcessVisualElementExamples >> clickingAnotherShapeReplacesSelection [
	<gtExample>
	| fixture visual start task startShape taskShape scripter |
	fixture := self fixture.
	start := fixture third.
	task := fixture fourth.
	startShape := fixture at: 9.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.
	(visual shapeElementFor: startShape) id: #processStartShape.
	(visual shapeElementFor: taskShape) id: #processTaskShape.

	scripter := BlScripter new.
	scripter element: visual.
	scripter clickStep: [ :step |
		step
			label: 'Click task shape';
			id: #processTaskShape ].
	scripter clickStep: [ :step |
		step
			label: 'Click start shape';
			id: #processStartShape ].

	self assert: visual selectedModelElements size equals: 1.
	self assert: (visual selectedModelElements identityIncludes: start).
	self assert: (visual selectedModelElements identityIncludes: task) not.
	self assert: visual selectedModelElement == start.
	^ scripter
]

{ #category : 'examples - gestures - keyboard' }
CPProcessVisualElementExamples >> deleteKeyRemovesSelectedNodeThroughVisualKeyboardHandler [
	<gtExample>
	| fixture visual memento task taskShape scripter stagedFlowElements |
	fixture := self fixture.
	memento := fixture second.
	task := fixture fourth.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.
	(visual shapeElementFor: taskShape) id: #processTaskShape.

	scripter := BlScripter new.
	scripter element: visual.
	scripter clickStep: [ :step |
		step
			label: 'Select task through its rendered shape';
			id: #processTaskShape ].
	(scripter keyPress: BlKeyboardKey delete)
		label: 'Delete selected BPMN node';
		play.

	stagedFlowElements := memento readUsing: (self descriptionFor: #flowElements in: memento).
	self assert: stagedFlowElements size equals: 2.
	self assert: (stagedFlowElements identityIncludes: task) not.
	self assert: (stagedFlowElements identityIncludes: fixture sixth) not.
	self assert: (stagedFlowElements identityIncludes: fixture seventh) not.
	self assert: visual selectedModelElements isEmpty.
	^ scripter
]

{ #category : 'examples - gestures - keyboard' }
CPProcessVisualElementExamples >> escapeKeyClearsSelectionThroughVisualCancellationPath [
	<gtExample>
	| fixture visual task taskShape scripter |
	fixture := self fixture.
	task := fixture fourth.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.
	(visual shapeElementFor: taskShape) id: #processTaskShape.

	scripter := BlScripter new.
	scripter element: visual.
	scripter clickStep: [ :step |
		step
			label: 'Select task through its rendered shape';
			id: #processTaskShape ].
	self assert: (visual selectedModelElements identityIncludes: task).

	(scripter keyPress: BlKeyboardKey escape)
		label: 'Cancel current visual interaction';
		play.

	self assert: visual selectedModelElements isEmpty.
	self assert: visual selectedModelElement isNil.
	^ scripter
]


{ #category : 'private - gestures' }
CPProcessVisualElementExamples >> dragDestinationAt: aPoint id: anId in: aVisualElement [
	| marker |
	marker := BlElement new
		id: anId;
		extent: 2 @ 2;
		relocate: aPoint - (1 @ 1);
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.
	aVisualElement addChild: marker.
	^ marker
]

{ #category : 'examples - gestures - dragging' }
CPProcessVisualElementExamples >> draggingShapeStagesMoveThroughBlocGesturePipeline [
	<gtExample>
	| fixture visual memento task taskShape firstEdge secondEdge shapeElement destination scripter delta expectedBounds |
	fixture := self fixture.
	memento := fixture second.
	task := fixture fourth.
	taskShape := fixture at: 10.
	firstEdge := fixture at: 12.
	secondEdge := fixture at: 13.
	visual := self visualElementForFixture: fixture.
	shapeElement := visual shapeElementFor: taskShape.
	shapeElement id: #processTaskShape.

	delta := 40 @ 30.
	destination := taskShape bounds origin + (taskShape bounds extent / 2) + delta.
	self dragDestinationAt: destination id: #shapeDragDestination in: visual.
	expectedBounds := taskShape bounds translateBy: delta.

	scripter := BlScripter new.
	scripter element: visual.
	(scripter mouseMoveOver)
		label: 'Move pointer over task shape';
		id: #processTaskShape;
		play.
	(scripter mouseDown)
		label: 'Press task shape';
		play.
	(scripter mouseMoveOver)
		label: 'Drag task shape to destination';
		id: #shapeDragDestination;
		play.
	(scripter mouseUp)
		label: 'Release task shape';
		play.

	self assert: (self stagedBoundsOf: taskShape processMemento: memento) equals: expectedBounds.
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento) equals: ({ 142 @ 121. 260 @ 151 } asOrderedCollection).
	self assert: (self stagedWaypointsOf: secondEdge processMemento: memento) equals: ({ 392 @ 151. 430 @ 121 } asOrderedCollection).
	self assert: taskShape bounds equals: (220 @ 94 extent: 132 @ 54).
	self assert: visual selectedModelElements isEmpty.
	self assert: visual selectedModelElement isNil.
	^ scripter
]


{ #category : 'private - gestures' }
CPProcessVisualElementExamples >> visibleResizeHandleIn: aVisualElement [
	^ aVisualElement children
		detect: [ :each |
			each extent = (9 @ 9)
				and: [ each visibility = BlVisibility visible ] ]
]

{ #category : 'examples - gestures - resizing' }
CPProcessVisualElementExamples >> selectingActivityRevealsItsResizeHandle [
	<gtExample>
	| fixture visual task taskShape scripter handle |
	fixture := self fixture.
	task := fixture fourth.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.
	(visual shapeElementFor: taskShape) id: #processTaskShape.

	scripter := BlScripter new.
	scripter element: visual.
	scripter clickStep: [ :step |
		step
			label: 'Select task to reveal resize handle';
			id: #processTaskShape ].

	handle := self visibleResizeHandleIn: visual.
	self assert: handle isNotNil.
	self assert: handle extent equals: (9 @ 9).
	self assert: handle visibility equals: BlVisibility visible.
	self assert: visual selectedModelElement == task.
	^ scripter
]



{ #category : 'private - gestures' }
CPProcessVisualElementExamples >> visibleConnectionPortIn: aNodeElement [
	^ aNodeElement children
		detect: [ :each |
			each extent = (12 @ 12)
				and: [ each visibility = BlVisibility visible ] ]
]

{ #category : 'private - gestures' }
CPProcessVisualElementExamples >> visibleReconnectHandlesIn: aVisualElement [
	^ (aVisualElement children
		select: [ :each |
			each extent = (10 @ 10)
				and: [ each visibility = BlVisibility visible ] ])
		asSortedCollection: [ :a :b | a position x < b position x ]
]

{ #category : 'examples - gestures - connection' }
CPProcessVisualElementExamples >> draggingConnectionPortCreatesSequenceFlowThroughBlocGesturePipeline [
	<gtExample>
	| fixture visual memento start finish finishShape finishElement scripter
	  targetGlobalPoint target assessment stagedFlowElements diagramMemento
	  elementsDescription stagedElements newFlow newEdge |
	fixture := self fixture.
	memento := fixture second.
	start := fixture third.
	finish := fixture fifth.
	finishShape := fixture at: 11.
	visual := self visualElementForFixture: fixture.
	finishElement := visual shapeElementFor: finishShape.

	scripter := BlScripter new.
	scripter element: visual.

	targetGlobalPoint := finishElement geometryBoundsInSpace center.
	target := visual
		validConnectionTargetAtGlobalPoint: targetGlobalPoint
		from: start.

	self assert: target == finish.

	assessment := visual connectFrom: start to: target.
	stagedFlowElements := memento readUsing:
		(self descriptionFor: #flowElements in: memento).
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.
	stagedElements := diagramMemento readUsing: elementsDescription.
	newFlow := assessment sequenceFlow.
	newEdge := assessment edge.

	self assert: assessment isApplicable.
	self assert: stagedFlowElements size equals: 6.
	self assert: stagedElements size equals: 6.
	self assert: (stagedFlowElements identityIncludes: newFlow).
	self assert: (stagedElements identityIncludes: newEdge).
	self assert: newEdge modelElement == newFlow.
	self assert: (fixture first flowElements identityIncludes: newFlow) not.
	self assert: (fixture eighth elements identityIncludes: newEdge) not.
	^ scripter
]

{ #category : 'examples - gestures - reconnecting' }
CPProcessVisualElementExamples >> draggingTargetReconnectHandleRetargetsExistingSequenceFlowThroughBlocGesturePipeline [
	<gtExample>
	| fixture visual memento finish finishShape finishElement firstFlow firstEdge
	  scripter targetGlobalPoint target assessment flowMemento targetDescription |
	fixture := self fixture.
	memento := fixture second.
	finish := fixture fifth.
	finishShape := fixture at: 11.
	firstFlow := fixture sixth.
	firstEdge := fixture at: 12.
	visual := self visualElementForFixture: fixture.
	finishElement := visual shapeElementFor: finishShape.

	scripter := BlScripter new.
	scripter element: visual.

	targetGlobalPoint := finishElement geometryBoundsInSpace center.
	target := visual
		validReconnectTargetAtGlobalPoint: targetGlobalPoint
		for: firstFlow
		movingSource: false.

	self assert: target == finish.

	assessment := visual
		reconnectSequenceFlow: firstFlow
		source: fixture third
		target: target.
	flowMemento := memento
		childMementoFor: firstFlow
		inRelation: (self descriptionFor: #flowElements in: memento).
	targetDescription := self descriptionFor: #targetRef in: flowMemento.

	self assert: assessment isApplicable.
	self assert: (flowMemento readUsing: targetDescription) == finish.
	self assert: firstFlow targetRef == fixture fourth.
	self assert: firstEdge modelElement == firstFlow.
	self assert: (self stagedWaypointsOf: firstEdge processMemento: memento)
		equals: ({ 121 @ 121. 451 @ 121 } asOrderedCollection).
	self assert: firstEdge waypoints
		equals: ({ 142 @ 121. 220 @ 121 } asOrderedCollection).
	^ scripter
]


{ #category : 'examples - depiction' }
CPProcessVisualElementExamples >> callActivityUsesActivityGeometryWithCallBoundary [
	<gtExample>
	| callActivity calledProcess shape element |
	calledProcess := CPProcess new label: 'Fulfilment'; yourself.
	callActivity := CPCallActivity new
		label: 'Reuse fulfilment';
		calledElement: calledProcess;
		yourself.
	shape := CPShape new
		modelElement: callActivity;
		bounds: (100 @ 100 extent: 132 @ 54);
		yourself.
	element := CPProcessShapeElement new.
	element
		shape: shape
		modelElement: callActivity
		bounds: shape bounds
		background: Color transparent
		borderColor: Color black
		label: nil.

	self assert: callActivity isActivity.
	self assert: callActivity isTask not.
	self assert: callActivity isCallActivity.
	self assert: element normalBorderWidth equals: 3.
	self assert: element selectedBorderWidth equals: 4.5.
	self assert: element children size equals: 1.
	self assert: element children first children size equals: 2.
	^ element
]


{ #category : 'examples - depiction' }
CPProcessVisualElementExamples >> collapsedSubProcessUsesActivityGeometryWithCollapseMarker [
	<gtExample>
	| subProcess shape element |
	subProcess := CPSubProcess new label: 'Fulfil order'; yourself.
	shape := CPShape new
		modelElement: subProcess;
		bounds: (100 @ 100 extent: 132 @ 72);
		yourself.
	element := CPProcessShapeElement new.
	element
		shape: shape
		modelElement: subProcess
		bounds: shape bounds
		background: Color transparent
		borderColor: Color black
		label: nil.

	self assert: subProcess isActivity.
	self assert: subProcess isTask not.
	self assert: subProcess isSubProcess.
	self assert: element normalBorderWidth equals: 1.5.
	self assert: element selectedBorderWidth equals: 3.
	self assert: element children size equals: 1.
	self assert: element children first children size equals: 2.
	^ element
]
