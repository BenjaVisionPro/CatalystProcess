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
		transferFlowNodeOperationFor: [ :aFlowNode :aFlowContainer :proposedBounds |
			CPAtelierTransferFlowNode
				flowNode: aFlowNode
				targetContainer: aFlowContainer
				bounds: proposedBounds
				processMemento: memento
				diagramDescription: diagramDescription ];
		transferFlowNodesOperationFor: [ :someFlowNodes :aFlowContainer :boundsByFlowNode :waypointsBySequenceFlow |
			CPAtelierTransferFlowNodes
				flowNodes: someFlowNodes
				targetContainer: aFlowContainer
				boundsByFlowNode: boundsByFlowNode
				waypointsBySequenceFlow: waypointsBySequenceFlow
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
		createFlowNodeOperationFor: [ :aFlowNode :proposedBounds :aFlowContainer |
			CPAtelierCreateFlowNode
				flowNode: aFlowNode
				bounds: proposedBounds
				flowContainer: aFlowContainer
				processMemento: memento
				diagramDescription: diagramDescription ];
		replaceFlowNodeOperationFor: [ :aFlowNode :aReplacementNode :proposedBounds :aFlowContainer |
			CPAtelierReplaceFlowNode
				flowNode: aFlowNode
				with: aReplacementNode
				bounds: proposedBounds
				flowContainer: aFlowContainer
				processMemento: memento
				diagramDescription: diagramDescription ];
		connectFlowNodesOperationFor: [ :aSource :aTarget :aFlowContainer |
			CPAtelierConnectFlowNodes
				source: aSource
				target: aTarget
				flowContainer: aFlowContainer
				processMemento: memento
				diagramDescription: diagramDescription ];
		insertFlowNodeOperationFor: [ :aSequenceFlow :aFlowNode :proposedBounds :aFlowContainer |
			CPAtelierInsertFlowNode
				sequenceFlow: aSequenceFlow
				flowNode: aFlowNode
				bounds: proposedBounds
				flowContainer: aFlowContainer
				processMemento: memento
				diagramDescription: diagramDescription ];
		removeFlowNodeOperationFor: [ :aFlowNode :aFlowContainer |
			CPAtelierRemoveFlowNode
				flowNode: aFlowNode
				flowContainer: aFlowContainer
				processMemento: memento
				diagramDescription: diagramDescription ];
		removeSequenceFlowOperationFor: [ :aSequenceFlow :aFlowContainer |
			CPAtelierRemoveSequenceFlow
				sequenceFlow: aSequenceFlow
				flowContainer: aFlowContainer
				processMemento: memento
				diagramDescription: diagramDescription ];
		reconnectSequenceFlowOperationFor: [ :aSequenceFlow :aSource :aTarget :aFlowContainer |
			CPAtelierReconnectSequenceFlow
				sequenceFlow: aSequenceFlow
				source: aSource
				target: aTarget
				flowContainer: aFlowContainer
				processMemento: memento
				diagramDescription: diagramDescription ];
		setShapeExpandedOperationFor: [ :aShape :isExpanded |
			CPAtelierSetShapeExpanded
				shape: aShape
				expanded: isExpanded
				processMemento: memento
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
	^ element
]


{ #category : 'examples - depiction' }
CPProcessVisualElementExamples >> expandedSubProcessShowsCollapseMarker [
	<gtExample>
	| subProcess shape element |
	subProcess := CPSubProcess new label: 'Fulfil order'; yourself.
	shape := CPShape new
		modelElement: subProcess;
		bounds: (100 @ 100 extent: 348 @ 168);
		isExpanded: true;
		yourself.
	element := CPProcessShapeElement new.
	element
		shape: shape
		modelElement: subProcess
		bounds: shape bounds
		background: Color transparent
		borderColor: Color black
		label: nil
		expanded: true.

	self assert: shape isExpanded.
	self assert: element normalBorderWidth equals: 1.5.
	self assert: element subProcessExpansionMarker notNil.
	^ element
]

{ #category : 'examples - type selection' }
CPProcessVisualElementExamples >> subProcessTypeSelectionDefinesRequestedTypes [
	<gtExample>
	| selection |
	selection := CPSubProcessTypeSelection typeClass: CPLoopSubProcess.

	self assert: selection typeClasses equals: {
		CPNoneSubProcess.
		CPLoopSubProcess.
		CPMultiInstanceSubProcess.
		CPCompensationSubProcess.
		CPAdHocSubProcess }.
	self assert: (selection typeLabelFor: CPNoneSubProcess) equals: 'None'.
	self assert: (selection typeIconFor: CPNoneSubProcess) equals: #circle.
	self assert: (selection typeLabelFor: CPLoopSubProcess) equals: 'Loop'.
	self assert: (selection typeIconFor: CPLoopSubProcess) equals: #arrowRotateLeft.
	self assert: (selection typeIconFor: CPMultiInstanceSubProcess) equals: #bars.
	self assert: (selection typeIconFor: CPCompensationSubProcess) equals: #anglesLeft.
	self assert: (selection typeIconFor: CPAdHocSubProcess) equals: #tilde.
	^ selection
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> nestedFlowElementsResolveThroughSubProcessMemento [
	<gtExample>
	| fixture memento flowElementsDescription subProcess start task nestedFlow subProcessMemento nestedDescription startMemento flowMemento visual labelDescription sourceDescription targetDescription |
	fixture := self fixture.
	memento := fixture second.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	start := CPNoneStartEvent new label: 'Inner start'; yourself.
	task := CPUserTask new label: 'Inner task'; yourself.
	nestedFlow := CPSequenceFlow new sourceRef: start; targetRef: task; yourself.
	subProcess
		addFlowElement: start;
		addFlowElement: task;
		addFlowElement: nestedFlow.

	memento
		write: ((memento readUsing: flowElementsDescription) asOrderedCollection copy
			add: subProcess;
			yourself)
		using: flowElementsDescription.
	self assert: subProcess container isNil.
	subProcessMemento := memento
		childMementoFor: subProcess
		inRelation: flowElementsDescription.
	nestedDescription := self descriptionFor: #flowElements in: subProcessMemento.
	subProcessMemento write: subProcess flowElements using: nestedDescription.

	visual := CPProcessVisualElement new.
	visual memento: memento.

	startMemento := visual flowElementMementoFor: start.
	labelDescription := self descriptionFor: #label in: startMemento.
	startMemento write: 'Staged inner start' using: labelDescription.

	flowMemento := visual flowElementMementoFor: nestedFlow.
	sourceDescription := self descriptionFor: #sourceRef in: flowMemento.
	targetDescription := self descriptionFor: #targetRef in: flowMemento.

	self assert: (startMemento readUsing: labelDescription) equals: 'Staged inner start'.
	self assert: start label equals: 'Inner start'.
	self assert: (flowMemento readUsing: sourceDescription) == start.
	self assert: (flowMemento readUsing: targetDescription) == task.
	self assert: (visual stagedSourceOf: nestedFlow) == start.
	self assert: (visual stagedTargetOf: nestedFlow) == task.
	^ visual
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> freshlyStagedSubProcessResolvesWithoutCommittedContainer [
	<gtExample>
	| fixture memento flowElementsDescription subProcess visual resolved |
	fixture := self fixture.
	memento := fixture second.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.
	subProcess := CPNoneSubProcess new label: 'Fresh nested'; yourself.

	memento
		write: ((memento readUsing: flowElementsDescription) asOrderedCollection copy
			add: subProcess;
			yourself)
		using: flowElementsDescription.

	self assert: subProcess container isNil.
	visual := CPProcessVisualElement new.
	visual memento: memento.
	resolved := visual flowElementMementoFor: subProcess.

	self assert: resolved notNil.
	self assert: resolved model == subProcess.
	^ resolved
]

{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> flowElementSubProcessProtocolCoversSequenceFlows [
	<gtExample>
	| sequenceFlow subProcess |
	sequenceFlow := CPSequenceFlow new.
	subProcess := CPNoneSubProcess new.

	self assert: sequenceFlow isSubProcess not.
	self assert: subProcess isSubProcess.
	^ sequenceFlow
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> expandedSubProcessExposesNestedProcessVisualAsContainmentTarget [
	<gtExample>
	| visual subProcess shapeElement nestedVisual |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcess := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	nestedVisual := shapeElement nestedProcessVisual.

	self assert: nestedVisual notNil.
	self assert: nestedVisual flowContainer == subProcess.
	self assert: nestedVisual rootVisual == visual.
	^ nestedVisual
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> collapsedAndExpandedSubProcessControlNestedDiagramVisibility [
	<gtExample>
	| fixture memento rootFlowDescription diagramMemento elementsDescription
	  subProcess subProcessMemento nestedFlowDescription innerTask subShape innerShape
	  rootFlows diagramElements shapeMemento expandedDescription visual shapeElement nestedVisual |

	fixture := self fixture.
	memento := fixture second.
	rootFlowDescription := self descriptionFor: #flowElements in: memento.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	rootFlows := (memento readUsing: rootFlowDescription) asOrderedCollection copy.
	rootFlows add: subProcess.
	memento write: rootFlows using: rootFlowDescription.
	subProcessMemento := memento
		childMementoFor: subProcess
		inRelation: rootFlowDescription.
	nestedFlowDescription := self descriptionFor: #flowElements in: subProcessMemento.

	innerTask := CPUserTask new label: 'Inner'; yourself.
	subProcessMemento write: { innerTask } asOrderedCollection using: nestedFlowDescription.

	subShape := CPShape new
		modelElement: subProcess;
		bounds: (180 @ 180 extent: 360 @ 180);
		yourself.
	innerShape := CPShape new
		modelElement: innerTask;
		bounds: (90 @ 60 extent: 132 @ 54);
		yourself.
	diagramElements := (diagramMemento readUsing: elementsDescription) asOrderedCollection copy.
	diagramElements
		add: subShape;
		add: innerShape.
	diagramMemento write: diagramElements using: elementsDescription.

	visual := self visualElementForFixture: fixture.
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	self assert: (visual shapeElementsByModelElement includesKey: subProcess).
	self assert: (visual shapeElementsByModelElement includesKey: innerTask) not.
	self assert: shapeElement nestedProcessVisual isNil.

	shapeMemento := diagramMemento childMementoFor: subShape inRelation: elementsDescription.
	expandedDescription := self descriptionFor: #isExpanded in: shapeMemento.
	shapeMemento write: true using: expandedDescription.
	visual refresh.

	shapeElement := visual shapeElementsByModelElement at: subProcess.
	nestedVisual := shapeElement nestedProcessVisual.
	self assert: nestedVisual notNil.
	self assert: nestedVisual flowContainer == subProcess.
	self assert: (visual shapeElementsByModelElement includesKey: innerTask) not.
	self assert: (nestedVisual shapeElementsByModelElement includesKey: innerTask).
	^ visual
]



{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> collapsedSubProcessExpansionAffordanceStagesExpandedShape [
	<gtExample>
	| fixture memento rootFlowDescription diagramMemento elementsDescription
	  subProcess subShape rootFlows diagramElements visual shapeElement
	  shapeMemento expandedDescription boundsDescription assessment |

	fixture := self fixture.
	memento := fixture second.
	rootFlowDescription := self descriptionFor: #flowElements in: memento.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	rootFlows := (memento readUsing: rootFlowDescription) asOrderedCollection copy.
	rootFlows add: subProcess.
	memento write: rootFlows using: rootFlowDescription.
	subShape := CPShape new
		modelElement: subProcess;
		bounds: (180 @ 180 extent: 360 @ 180);
		yourself.
	diagramElements := (diagramMemento readUsing: elementsDescription) asOrderedCollection copy.
	diagramElements add: subShape.
	diagramMemento write: diagramElements using: elementsDescription.

	visual := self visualElementForFixture: fixture.
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	self assert: shapeElement subProcessExpansionMarker notNil.

	assessment := visual setShape: subShape expanded: true.
	self assert: assessment isApplicable.
	shapeMemento := diagramMemento childMementoFor: subShape inRelation: elementsDescription.
	expandedDescription := self descriptionFor: #isExpanded in: shapeMemento.
	boundsDescription := self descriptionFor: #bounds in: shapeMemento.
	self assert: (shapeMemento readUsing: expandedDescription).
	self assert: (shapeMemento readUsing: boundsDescription) extent equals: 360 @ 180.
	self assert: (shapeMemento readUsing: boundsDescription) center equals: (180 @ 180 extent: 360 @ 180) center.
	self assert: subShape isExpanded not.
	self assert: (visual shapeElementsByModelElement at: subProcess) subProcessExpansionMarker notNil.
	^ visual
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> expandedSubProcessKeepsToggleAndPositionsLabelAtTopLeft [
	<gtExample>
	| subProcess shape label element |
	subProcess := CPNoneSubProcess new label: 'Expanded'; yourself.
	shape := CPShape new
		modelElement: subProcess;
		bounds: (100 @ 100 extent: 360 @ 180);
		isExpanded: true;
		yourself.
	label := BrLabel new text: 'Expanded'.
	element := CPProcessShapeElement new.
	element
		shape: shape
		modelElement: subProcess
		bounds: shape bounds
		background: Color transparent
		borderColor: Color black
		label: label
		expanded: true.

	self assert: element subProcessExpansionMarker notNil.
	self assert: (element children includes: label).
	^ element
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> nestedConnectionTargetWinsOverExpandedContainer [
	<gtExample>
	| visual outerContainer innerTask chosen |
	visual := CPProcessVisualElement new.
	outerContainer := CPNoneSubProcess new label: 'Container'; yourself.
	innerTask := CPUserTask new label: 'Inner'; yourself.

	chosen := visual preferredConnectionTargetFrom: {
		{ outerContainer. 0. (100 @ 100 extent: 360 @ 180) }.
		{ innerTask. 1. (220 @ 220 extent: 132 @ 54) } }.

	self assert: chosen == innerTask.
	^ chosen
]




{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> expandedSubProcessHostsNestedProcessVisual [
	<gtExample>
	| fixture memento rootDescription diagramMemento elementsDescription
	  subProcess task subMemento subDescription subShape taskShape diagramElements
	  visual subShapeElement nestedVisual |

	fixture := self fixture.
	memento := fixture second.
	rootDescription := self descriptionFor: #flowElements in: memento.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	task := CPUserTask new label: 'Inside'; yourself.
	memento
		write: ((memento readUsing: rootDescription) asOrderedCollection copy
			add: subProcess;
			yourself)
		using: rootDescription.
	subMemento := memento childMementoFor: subProcess inRelation: rootDescription.
	subDescription := self descriptionFor: #flowElements in: subMemento.
	subMemento write: { task } asOrderedCollection using: subDescription.

	subShape := CPShape new
		modelElement: subProcess;
		bounds: (100 @ 100 extent: 360 @ 180);
		isExpanded: true;
		yourself.
	taskShape := CPShape new
		modelElement: task;
		bounds: (80 @ 50 extent: 132 @ 54);
		yourself.
	diagramElements := (diagramMemento readUsing: elementsDescription) asOrderedCollection copy.
	diagramElements
		add: subShape;
		add: taskShape.
	diagramMemento write: diagramElements using: elementsDescription.

	visual := self visualElementForFixture: fixture.
	subShapeElement := visual shapeElementsByModelElement at: subProcess.
	nestedVisual := subShapeElement nestedProcessVisual.

	self assert: nestedVisual notNil.
	self assert: nestedVisual flowContainer == subProcess.
	self assert: (visual shapeElementsByModelElement includesKey: task) not.
	self assert: (nestedVisual shapeElementsByModelElement includesKey: task).
	self assert: subShapeElement nestedProcessViewport notNil.
	^ visual
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> nestedProcessVisualOwnsPaletteCreationTarget [
	<gtExample>
	| visual subProcessShape nestedVisual |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcessShape := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	nestedVisual := (visual shapeElementsByModelElement at: subProcessShape) nestedProcessVisual.

	self assert: nestedVisual flowContainer == subProcessShape.
	self assert: nestedVisual rootVisual == visual.
	^ nestedVisual
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> subProcessMoveLeavesNestedLocalBoundsUnchanged [
	<gtExample>
	| fixture memento rootDescription diagramMemento elementsDescription
	  subProcess task subMemento subDescription subShape taskShape diagramElements
	  visual assessment |

	fixture := self fixture.
	memento := fixture second.
	rootDescription := self descriptionFor: #flowElements in: memento.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	task := CPUserTask new label: 'Inside'; yourself.
	memento
		write: ((memento readUsing: rootDescription) asOrderedCollection copy
			add: subProcess;
			yourself)
		using: rootDescription.
	subMemento := memento childMementoFor: subProcess inRelation: rootDescription.
	subDescription := self descriptionFor: #flowElements in: subMemento.
	subMemento write: { task } asOrderedCollection using: subDescription.

	subShape := CPShape new
		modelElement: subProcess;
		bounds: (100 @ 100 extent: 360 @ 180);
		isExpanded: true;
		yourself.
	taskShape := CPShape new
		modelElement: task;
		bounds: (80 @ 50 extent: 132 @ 54);
		yourself.
	diagramElements := (diagramMemento readUsing: elementsDescription) asOrderedCollection copy.
	diagramElements add: subShape; add: taskShape.
	diagramMemento write: diagramElements using: elementsDescription.

	visual := self visualElementForFixture: fixture.
	assessment := visual moveShape: subShape toBounds: (125 @ 115 extent: 360 @ 180).

	self assert: assessment isApplicable.
	self assert: (visual stagedBoundsOf: subShape) equals: (125 @ 115 extent: 360 @ 180).
	self assert: (visual stagedBoundsOf: taskShape) equals: (80 @ 50 extent: 132 @ 54).
	^ visual
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> nestedProcessVisualIsHostedAsRealBlocChild [
	<gtExample>
	| visual subProcess shapeElement nestedVisual viewport |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcess := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	nestedVisual := shapeElement nestedProcessVisual.
	viewport := shapeElement nestedProcessViewport.

	self assert: nestedVisual parent == viewport.
	self assert: viewport parent == shapeElement.
	self assert: nestedVisual flowContainer == subProcess.
	^ nestedVisual
]

{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> rootCanResolveNestedShapeForCrossProcessEdge [
	<gtExample>
	| visual subProcess nestedVisual nestedTask resolved |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcess := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	nestedVisual := (visual shapeElementsByModelElement at: subProcess) nestedProcessVisual.
	nestedTask := nestedVisual shapeElementsByModelElement keys
		detect: [ :each | each isTask ].
	resolved := visual shapeElementForModelElement: nestedTask.

	self assert: resolved == (nestedVisual shapeElementsByModelElement at: nestedTask).
	^ resolved
]


{ #category : 'examples - palette' }
CPProcessVisualElementExamples >> processCanvasOwnsPaletteDropHandlerInstallation [
	<gtExample>
	| visual |
	visual := self visualElementForFixture: self fixture.
	self assert: visual notNil.
	self assert: visual flowContainer == visual memento model.
	^ visual
]

{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> nestedProcessIsResolvedFromSourceLocalDropCenter [
	<gtExample>
	| visual subProcess shapeElement nestedVisual |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcess := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	nestedVisual := shapeElement nestedProcessVisual.

	self assert: nestedVisual notNil.
	self assert: nestedVisual rootVisual == visual.
	self assert: nestedVisual flowContainer == subProcess.
	^ nestedVisual
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> directSubProcessBoundsResolveNestedTransferTarget [
	<gtExample>
	| visual subProcess shapeElement nestedVisual shape point target |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcess := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	nestedVisual := shapeElement nestedProcessVisual.
	shape := shapeElement diagramShape.
	point := (visual stagedBoundsOf: shape) center.

	target := visual
		targetProcessVisualForLocalPoint: point
		excluding: nil.

	self assert: target == nestedVisual.
	self assert: target flowContainer == subProcess.
	^ target
]



{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> transferredNodeRendersInNestedProcessAfterRefresh [
	<gtExample>
	| fixture memento rootDescription diagramDescription diagramMemento elementsDescription
	  subProcess task subMemento subDescription subShape taskShape diagramElements
	  visual assessment shapeElement nestedVisual |

	fixture := self fixture.
	memento := fixture second.
	rootDescription := self descriptionFor: #flowElements in: memento.
	diagramDescription := self descriptionFor: #diagram in: memento.
	diagramMemento := self diagramMementoFor: memento.
	elementsDescription := self diagramElementsDescriptionIn: diagramMemento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	task := CPUserTask new label: 'Move me'; yourself.
	memento
		write: ((memento readUsing: rootDescription) asOrderedCollection copy
			add: subProcess;
			add: task;
			yourself)
		using: rootDescription.
	subMemento := memento childMementoFor: subProcess inRelation: rootDescription.
	subDescription := self descriptionFor: #flowElements in: subMemento.
	subMemento write: OrderedCollection new using: subDescription.

	subShape := CPShape new
		modelElement: subProcess;
		bounds: (100 @ 100 extent: 360 @ 180);
		isExpanded: true;
		yourself.
	taskShape := CPShape new
		modelElement: task;
		bounds: (40 @ 40 extent: 132 @ 54);
		yourself.
	diagramElements := (diagramMemento readUsing: elementsDescription) asOrderedCollection copy.
	diagramElements
		add: subShape;
		add: taskShape.
	diagramMemento write: diagramElements using: elementsDescription.

	assessment := (CPAtelierTransferFlowNode
		flowNode: task
		targetContainer: subProcess
		bounds: (80 @ 50 extent: 132 @ 54)
		processMemento: memento
		diagramDescription: diagramDescription) apply.
	self assert: assessment isApplicable.

	visual := self visualElementForFixture: fixture.
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	nestedVisual := shapeElement nestedProcessVisual.

	self assert: (visual shapeElementsByModelElement includesKey: task) not.
	self assert: (nestedVisual shapeElementsByModelElement includesKey: task).
	self assert: (nestedVisual stagedBoundsOf: taskShape) equals: (80 @ 50 extent: 132 @ 54).
	^ nestedVisual
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> nestedProcessRendersWhileHosted [
	<gtExample>
	| visual subProcess shapeElement nestedVisual nestedTask taskElement |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcess := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	nestedVisual := shapeElement nestedProcessVisual.
	nestedTask := nestedVisual shapeElementsByModelElement keys
		detect: [ :each | each isTask ].
	taskElement := nestedVisual shapeElementsByModelElement at: nestedTask.

	self assert: nestedVisual parent == shapeElement nestedProcessViewport.
	self assert: taskElement parent == nestedVisual.
	self assert: (nestedVisual children includes: taskElement).
	self assert: (nestedVisual stagedBoundsOf: taskElement diagramShape)
		equals: (80 @ 50 extent: 132 @ 54).
	^ nestedVisual
]




{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> expandedSubProcessKeepsParentBorderInteraction [
	<gtExample>
	| visual subProcess shapeElement borders |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcess := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	borders := shapeElement subProcessBorderInteractionElements.

	self assert: borders size equals: 4.
	borders do: [ :each |
		self assert: each parent == shapeElement ].
	self assert: shapeElement nestedProcessViewport parent == shapeElement.
	self assert: shapeElement resizeHandles size equals: 4.
	^ shapeElement
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> nestedBackgroundSelectionTargetsHostingSubProcess [
	<gtExample>
	| visual subProcess shapeElement nestedVisual |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcess := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	nestedVisual := shapeElement nestedProcessVisual.

	nestedVisual clearLocalSelection.
	self assert: visual selectedModelElement isNil.
	self assert: nestedVisual selectedModelElement isNil.

	visual selectOnly: subProcess.
	self assert: visual selectedModelElement == subProcess.
	self assert: nestedVisual selectedModelElement == subProcess.
	^ nestedVisual
]


{ #category : 'examples - resizing' }
CPProcessVisualElementExamples >> resizableActivityHasFourCornerHandles [
	<gtExample>
	| fixture visual task shapeElement |
	fixture := self fixture.
	task := fixture fourth.
	visual := self visualElementForFixture: fixture.
	shapeElement := visual shapeElementsByModelElement at: task.

	self assert: shapeElement resizeHandles size equals: 4.
	^ shapeElement
]

{ #category : 'examples - resizing' }
CPProcessVisualElementExamples >> resizeCornersPreserveOppositeCorner [
	<gtExample>
	| shape original minimum topLeft topRight bottomLeft bottomRight |
	shape := CPProcessShapeElement new.
	original := 100 @ 100 extent: 200 @ 120.
	minimum := 80 @ 50.

	topLeft := shape topLeftBoundsFrom: original delta: 20 @ 10 minimumExtent: minimum.
	topRight := shape topRightBoundsFrom: original delta: 20 @ 10 minimumExtent: minimum.
	bottomLeft := shape bottomLeftBoundsFrom: original delta: 20 @ 10 minimumExtent: minimum.
	bottomRight := shape bottomRightBoundsFrom: original delta: 20 @ 10 minimumExtent: minimum.

	self assert: topLeft bottomRight equals: original bottomRight.
	self assert: topRight bottomLeft equals: original bottomLeft.
	self assert: bottomLeft topRight equals: original topRight.
	self assert: bottomRight topLeft equals: original topLeft.
	^ shape
]


{ #category : 'examples - resizing' }
CPProcessVisualElementExamples >> resizeHandlesRemainAvailableWithoutSelection [
	<gtExample>
	| fixture visual task shapeElement |
	fixture := self fixture.
	task := fixture fourth.
	visual := self visualElementForFixture: fixture.
	shapeElement := visual shapeElementsByModelElement at: task.

	visual clearInteractionAndSelection.
	self assert: shapeElement resizeHandles size equals: 4.
	shapeElement resizeHandles do: [ :each |
		self assert: each visibility equals: BlVisibility visible ].
	^ shapeElement
]




{ #category : 'examples - resizing' }
CPProcessVisualElementExamples >> resizeHandlesArePresentFromCreation [
	<gtExample>
	| fixture visual task shapeElement handles |
	fixture := self fixture.
	task := fixture fourth.
	visual := self visualElementForFixture: fixture.
	shapeElement := visual shapeElementsByModelElement at: task.
	handles := shapeElement resizeHandles.

	self assert: handles size equals: 4.
	handles do: [ :each |
		self assert: each parent == shapeElement.
		self assert: each visibility equals: BlVisibility visible ].
	^ shapeElement
]


{ #category : 'examples - cursor' }
CPProcessVisualElementExamples >> cursorActivationIgnoresDetachedElement [
	<gtExample>
	| element |
	element := CPProcessShapeElement new.
	element activateCursor: BlHandCursor new on: element.
	self assert: element space isNil.
	^ element
]


{ #category : 'examples - resizing' }
CPProcessVisualElementExamples >> shapeAllowsAffordancesOutsideGeometry [
	<gtExample>
	| fixture visual task shapeElement |
	fixture := self fixture.
	task := fixture fourth.
	visual := self visualElementForFixture: fixture.
	shapeElement := visual shapeElementsByModelElement at: task.

	self assert: shapeElement clipChildren not.
	self assert: shapeElement resizeHandles size equals: 4.
	^ shapeElement
]


{ #category : 'examples - resizing' }
CPProcessVisualElementExamples >> resizeHandlesAreAlwaysAvailable [
	<gtExample>
	| fixture visual task shapeElement |
	fixture := self fixture.
	task := fixture fourth.
	visual := self visualElementForFixture: fixture.
	shapeElement := visual shapeElementsByModelElement at: task.

	self assert: shapeElement resizeHandles size equals: 4.
	shapeElement resizeHandles do: [ :each |
		self assert: each visibility equals: BlVisibility visible ].
	^ shapeElement
]


{ #category : 'examples - subprocess' }
CPProcessVisualElementExamples >> expandedSubProcessBorderElementsAreConcreteDragTargets [
	<gtExample>
	| visual subProcess shapeElement borders |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcess := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	borders := shapeElement subProcessBorderInteractionElements.

	self assert: borders size equals: 4.
	borders do: [ :each |
		self assert: each parent == shapeElement.
		self assert: each geometry class == BlRectangleGeometry ].
	^ shapeElement
]










{ #category : 'examples - labels' }
CPProcessVisualElementExamples >> endingLabelEditingPreservesSelection [
	<gtExample>
	| fixture visual task shapeElement label |
	fixture := self fixture.
	task := fixture fourth.
	visual := self visualElementForFixture: fixture.
	shapeElement := visual shapeElementsByModelElement at: task.
	label := shapeElement labelElement.

	visual selectOnly: task.
	visual beginEditingLabel: label.
	visual finishEditingLabel: label.

	self assert: visual selectedModelElement == task.
	self assert: (visual selectedModelElements includes: task).
	^ visual
]


{ #category : 'examples - subprocess interaction' }
CPProcessVisualElementExamples >> nestedShapeDragPresentationLeavesViewportClipped [
	<gtExample>
	| visual subProcess shapeElement nestedVisual nestedShapeElement nestedShape
	  viewport originalParent sourceBounds expectedRootPosition proxy presentation |
	visual := self expandedSubProcessHostsNestedProcessVisual.
	subProcess := visual shapeElementsByModelElement keys
		detect: [ :each | each isSubProcess ].
	shapeElement := visual shapeElementsByModelElement at: subProcess.
	nestedVisual := shapeElement nestedProcessVisual.
	viewport := shapeElement nestedProcessViewport.
	nestedShapeElement := nestedVisual shapeElementsByModelElement values anyOne.
	nestedShape := nestedShapeElement diagramShape.
	originalParent := nestedShapeElement parent.
	sourceBounds := nestedVisual stagedBoundsOf: nestedShape.
	expectedRootPosition := nestedVisual
		rootDiagramPointForLocalPoint: sourceBounds origin.
	proxy := nestedVisual
		newDragProxyFor: nestedShapeElement modelElement
		shape: nestedShape
		bounds: sourceBounds.
	presentation := (CPProcessDragPresentation
		sourceElement: nestedShapeElement
		proxyElement: proxy
		proxyLabel: nil)
			beginIn: visual
			shapeAt: expectedRootPosition
			labelAt: nil.

	self assert: viewport clipChildren.
	self assert: nestedShapeElement parent == originalParent.
	self assert: nestedShapeElement visibility equals: BlVisibility hidden.
	self assert: presentation proxyElement parent == visual diagramPresentationParent.
	self assert: presentation dragShapePosition equals: expectedRootPosition.

	presentation moveBy: 20 @ 15.
	self assert: nestedShapeElement parent == originalParent.

	presentation finish.
	self assert: viewport clipChildren.
	self assert: nestedShapeElement parent == originalParent.
	self assert: nestedShapeElement visibility equals: BlVisibility visible.
	self assert: presentation proxyElement parent isNil.
	^ presentation
]

{ #category : 'private - fixture' }
CPProcessVisualElementExamples >> collaborationVisualFixture [
	| process start task finish firstFlow secondFlow processDiagram
	  startShape taskShape finishShape firstEdge secondEdge collaboration localParticipant
	  externalParticipant collaborationDiagram localPool externalPool messageFlow messageEdge
	  memento processVisual collaborationVisual |

	process := CPProcess new label: 'Seller process'; yourself.
	start := CPNoneStartEvent new label: 'Start'; yourself.
	task := CPUserTask new label: 'Review order'; yourself.
	finish := CPNoneEndEvent new label: 'End'; yourself.
	firstFlow := CPSequenceFlow new
		sourceRef: start;
		targetRef: task;
		yourself.
	secondFlow := CPSequenceFlow new
		sourceRef: task;
		targetRef: finish;
		yourself.
	process
		addFlowElement: start;
		addFlowElement: task;
		addFlowElement: finish;
		addFlowElement: firstFlow;
		addFlowElement: secondFlow.

	processDiagram := CPDiagram new.
	process diagram: processDiagram.
	startShape := CPShape new modelElement: start; bounds: (80 @ 70 extent: 42 @ 42); yourself.
	taskShape := CPShape new modelElement: task; bounds: (180 @ 64 extent: 132 @ 54); yourself.
	finishShape := CPShape new modelElement: finish; bounds: (370 @ 70 extent: 42 @ 42); yourself.
	firstEdge := CPEdge new modelElement: firstFlow; yourself.
	firstEdge
		addWaypoint: 122 @ 91;
		addWaypoint: 180 @ 91.
	secondEdge := CPEdge new modelElement: secondFlow; yourself.
	secondEdge
		addWaypoint: 312 @ 91;
		addWaypoint: 370 @ 91.
	processDiagram
		addElement: startShape;
		addElement: taskShape;
		addElement: finishShape;
		addElement: firstEdge;
		addElement: secondEdge.

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
	messageFlow := CPMessageFlow new
		label: 'Order';
		sourceRef: localParticipant;
		targetRef: externalParticipant;
		yourself.
	collaboration addMessageFlow: messageFlow.
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
	messageEdge := CPEdge new
		modelElement: messageFlow;
		yourself.
	messageEdge
		addWaypoint: 350 @ 270;
		addWaypoint: 350 @ 320.
	collaborationDiagram
		addElement: localPool;
		addElement: externalPool;
		addElement: messageEdge.
	process definitionalCollaborationRef: collaboration.

	memento := CFMaMemento model: process.
	processVisual := CPProcessVisualElement new
		beCollaborationHosted;
		memento: memento;
		yourself.
	collaborationVisual := CPCollaborationVisualElement new
		connectMessageFlowOperationFor: [ :aSource :aTarget :someWaypoints |
			CPAtelierConnectMessageFlow
				source: aSource
				target: aTarget
				waypoints: someWaypoints
				processMemento: memento ];
		moveParticipantShapeOperationFor: [ :aShape :proposedBounds |
			CPAtelierMoveParticipantShape
				shape: aShape
				bounds: proposedBounds
				processMemento: memento ];
		resizeParticipantShapeOperationFor: [ :aShape :proposedBounds |
			CPAtelierResizeParticipantShape
				shape: aShape
				bounds: proposedBounds
				processMemento: memento ];
		processMemento: memento
		processVisual: processVisual;
		yourself.

	^ {
		process.
		memento.
		collaboration.
		localParticipant.
		externalParticipant.
		collaborationDiagram.
		localPool.
		externalPool.
		processVisual.
		collaborationVisual.
		messageFlow.
		messageEdge.
		task
	}
]


{ #category : 'examples - collaboration visual' }
CPProcessVisualElementExamples >> collaborationDiagramAcceptsParticipantShapes [
	<gtExample>
	| fixture collaboration diagram localPool externalPool |
	fixture := self collaborationVisualFixture.
	collaboration := (fixture at: 3).
	diagram := (fixture at: 6).
	localPool := (fixture at: 7).
	externalPool := (fixture at: 8).

	self assert: collaboration diagram == diagram.
	self assert: diagram modelElement == collaboration.
	self assert: localPool modelElement == (fixture at: 4).
	self assert: externalPool modelElement == (fixture at: 5).
	self assert: (fixture at: 12) modelElement == (fixture at: 11).
	self assert: diagram elements size equals: 3.
	^ diagram
]


{ #category : 'examples - collaboration visual' }
CPProcessVisualElementExamples >> collaborationVisualHostsExistingProcessVisualInLocalParticipant [
	<gtExample>
	| fixture processVisual collaborationVisual localParticipant localElement |
	fixture := self collaborationVisualFixture.
	localParticipant := (fixture at: 4).
	processVisual := (fixture at: 9).
	collaborationVisual := (fixture at: 10).
	localElement := collaborationVisual participantElementsByParticipant
		at: localParticipant.

	self assert: collaborationVisual processVisual == processVisual.
	self assert: processVisual isCollaborationHosted.
	self assert: localElement processVisual == processVisual.
	self assert: processVisual parent == localElement processHost.
	self assert: processVisual flowContainer == (fixture at: 1).
	^ collaborationVisual
]


{ #category : 'examples - collaboration visual' }
CPProcessVisualElementExamples >> blackBoxParticipantRendersWithoutProcessVisual [
	<gtExample>
	| fixture collaborationVisual externalParticipant externalElement |
	fixture := self collaborationVisualFixture.
	externalParticipant := (fixture at: 5).
	collaborationVisual := (fixture at: 10).
	externalElement := collaborationVisual participantElementsByParticipant
		at: externalParticipant.

	self assert: externalParticipant processRef isNil.
	self assert: externalElement processVisual isNil.
	self assert: externalElement processHost children isEmpty.
	^ externalElement
]


{ #category : 'examples - collaboration visual' }
CPProcessVisualElementExamples >> collaborationPoolsUseTheirOwnDiagramBounds [
	<gtExample>
	| fixture collaborationVisual |
	fixture := self collaborationVisualFixture.
	collaborationVisual := (fixture at: 10).

	self assert: (collaborationVisual stagedBoundsOf: (fixture at: 7))
		equals: (40 @ 40 extent: 620 @ 230).
	self assert: (collaborationVisual stagedBoundsOf: (fixture at: 8))
		equals: (40 @ 320 extent: 620 @ 100).
	^ collaborationVisual
]

{ #category : 'examples - collaboration message flow' }
CPProcessVisualElementExamples >> collaborationRendersMessageFlowFromItsOwnDiagram [
	<gtExample>
	| fixture collaborationVisual messageFlow messageEdge messageVisual |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	messageFlow := fixture at: 11.
	messageEdge := fixture at: 12.
	messageVisual := collaborationVisual messageFlowVisualsByEdge
		at: messageEdge.

	self assert: messageEdge modelElement == messageFlow.
	self assert: messageVisual diagramEdge == messageEdge.
	self assert: messageVisual lineElements isEmpty not.
	self assert: messageVisual sourceMarker notNil.
	self assert: messageVisual sourceMarker parent == collaborationVisual diagramPresentationParent.
	^ messageVisual
]


{ #category : 'examples - collaboration message flow' }
CPProcessVisualElementExamples >> collaborationMessageFlowUsesStagedWaypoints [
	<gtExample>
	| fixture collaborationVisual messageEdge |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	messageEdge := fixture at: 12.

	self assert: (collaborationVisual stagedWaypointsOf: messageEdge)
		equals: ({ 350 @ 270. 350 @ 320 } asOrderedCollection).
	^ messageEdge
]


{ #category : 'examples - collaboration message flow' }
CPProcessVisualElementExamples >> collaborationMessageFlowRendersItsLabel [
	<gtExample>
	| fixture collaborationVisual messageVisual |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	messageVisual := collaborationVisual messageFlowVisualsByEdge
		at: (fixture at: 12).

	self assert: messageVisual labelHost notNil.
	self assert: messageVisual labelHost parent == collaborationVisual diagramPresentationParent.
	^ messageVisual
]


{ #category : 'examples - collaboration message flow' }
CPProcessVisualElementExamples >> collaborationMessageFlowDoesNotEnterParticipantRendering [
	<gtExample>
	| fixture collaborationVisual |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.

	self assert: collaborationVisual participantElementsByParticipant size equals: 2.
	self assert: collaborationVisual messageFlowVisualsByEdge size equals: 1.
	self assert: (collaborationVisual messageFlowVisualsByEdge
		includesKey: (fixture at: 12)).
	^ collaborationVisual
]


{ #category : 'examples - collaboration message flow connection' }
CPProcessVisualElementExamples >> collaborationConnectionResolvesExternalPoolAsMessageFlowTarget [
	<gtExample>
	| fixture collaborationVisual externalParticipant target |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	externalParticipant := fixture at: 5.

	target := collaborationVisual
		participantAtCollaborationPoint: 350 @ 350
		excludingEndpoint: (fixture at: 13).

	self assert: target == externalParticipant.
	^ target
]


{ #category : 'examples - collaboration message flow connection' }
CPProcessVisualElementExamples >> collaborationProcessCoordinatesIncludePoolContentOrigin [
	<gtExample>
	| fixture collaborationVisual |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.

	self assert: (collaborationVisual
		collaborationPointForProcessRootPoint: 180 @ 64)
		equals: 256 @ 104.
	^ collaborationVisual
]


{ #category : 'examples - collaboration message flow connection' }
CPProcessVisualElementExamples >> collaborationMessageFlowWaypointsDockAtSourceAndPoolBoundaries [
	<gtExample>
	| fixture collaborationVisual processVisual externalParticipant waypoints |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	processVisual := fixture at: 9.
	externalParticipant := fixture at: 5.

	waypoints := collaborationVisual
		messageFlowWaypointsFrom: (fixture at: 13)
		inVisual: processVisual
		toParticipant: externalParticipant.

	self assert: waypoints size equals: 2.
	self assert: waypoints first y equals: 158.
	self assert: waypoints second y equals: 320.
	^ waypoints
]


{ #category : 'examples - collaboration message flow connection' }
CPProcessVisualElementExamples >> collaborationHostedProcessKnowsItsConnectionCoordinator [
	<gtExample>
	| fixture collaborationVisual processVisual |
	fixture := self collaborationVisualFixture.
	processVisual := fixture at: 9.
	collaborationVisual := fixture at: 10.

	self assert: processVisual collaborationVisual == collaborationVisual.
	^ processVisual
]


{ #category : 'examples - collaboration message flow connection' }
CPProcessVisualElementExamples >> collaborationConnectionTargetsAreExplicitDomainObjects [
	<gtExample>
	| sequenceTarget messageTarget |
	sequenceTarget := CPCollaborationConnectionTarget
		sequenceFlowTo: CPUserTask new.
	messageTarget := CPCollaborationConnectionTarget
		messageFlowTo: CPParticipant new.

	self assert: sequenceTarget isSequenceFlowTarget.
	self assert: sequenceTarget isMessageFlowTarget not.
	self assert: messageTarget isMessageFlowTarget.
	self assert: messageTarget isSequenceFlowTarget not.
	^ messageTarget
]




{ #category : 'examples - scrolling' }
CPProcessVisualElementExamples >> processDiagramUsesExactBoundedCameraTravel [
	<gtExample>
	| fixture visual shape originalBounds viewport slack expectedExtent |
	fixture := self fixture.
	visual := self visualElementForFixture: fixture.
	shape := visual shapeElementsByModelElement values anyOne diagramShape.
	originalBounds := visual stagedBoundsOf: shape.
	viewport := 1000 @ 600.
	visual viewportExtent: viewport.
	slack := (viewport - visual diagramExtent) max: 0 @ 0.
	expectedExtent := visual diagramExtent + (slack * 2).

	self assert: visual cameraSlack equals: slack.
	self assert: visual canvasExtent equals: expectedExtent.
	self assert: (visual stagedBoundsOf: shape) equals: originalBounds.
	^ visual
]


{ #category : 'examples - scrolling' }
CPProcessVisualElementExamples >> processDiagramShapesLiveInCameraPositionedDiagramLayer [
	<gtExample>
	| fixture visual shapeElement expectedLayerOrigin |
	fixture := self fixture.
	visual := self visualElementForFixture: fixture.
	visual viewportExtent: 1000 @ 600.
	shapeElement := visual shapeElementsByModelElement values anyOne.
	expectedLayerOrigin := visual cameraSlack - visual diagramBounds origin.

	self assert: shapeElement parent == visual diagramPresentationParent.
	self assert: visual diagramPresentationParent constraints position equals: expectedLayerOrigin.
	^ shapeElement
]


{ #category : 'examples - scrolling' }
CPProcessVisualElementExamples >> collaborationDiagramUsesExactBoundedCameraTravel [
	<gtExample>
	| fixture collaborationVisual participantElement viewport slack expectedExtent |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	participantElement := collaborationVisual participantElementsByParticipant
		at: (fixture at: 4).
	viewport := 1000 @ 600.
	collaborationVisual viewportExtent: viewport.
	slack := (viewport - collaborationVisual diagramExtent) max: 0 @ 0.
	expectedExtent := collaborationVisual diagramExtent + (slack * 2).

	self assert: collaborationVisual cameraSlack equals: slack.
	self assert: collaborationVisual canvasExtent equals: expectedExtent.
	self assert: participantElement parent == collaborationVisual diagramPresentationParent.
	^ collaborationVisual
]


{ #category : 'examples - collaboration visual' }
CPProcessVisualElementExamples >> participantPoolUsesStandardObjectTreatment [
	<gtExample>
	| fixture collaborationVisual participant participantElement |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	participant := fixture at: 5.
	participantElement := collaborationVisual participantElementsByParticipant at: participant.

	self assert: participantElement resizeHandles size equals: 4.
	self assert: participantElement clipChildren not.
	self assert: participantElement processHost clipChildren.
	self assert: participantElement labelElement notNil.
	self assert: participantElement labelBand notNil.
	^ participantElement
]

{ #category : 'examples - selection' }
CPProcessVisualElementExamples >> processAndCollaborationShareOneSelectionModel [
	<gtExample>
	| fixture processVisual collaborationVisual selection participant task |
	fixture := self collaborationVisualFixture.
	processVisual := fixture at: 9.
	collaborationVisual := fixture at: 10.
	participant := fixture at: 5.
	task := fixture at: 13.
	selection := CPDiagramSelectionModel new.
	processVisual selectionModel: selection.
	collaborationVisual selectionModel: selection.

	selection selectOnly: participant.
	self assert: processVisual selectionModel == collaborationVisual selectionModel.
	self assert: processVisual selectedModelElement == participant.

	selection selectOnly: task.
	self assert: processVisual selectedModelElement == task.
	self assert: collaborationVisual selectionModel selectedModelElement == task.
	^ selection
]
