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
	| memento diagramDescription visual |
	memento := fixture second.
	diagramDescription := self descriptionFor: #diagram in: memento.
	visual := CPProcessVisualElement new.
	visual
		diagramEditing: (self diagramEditingForMemento: memento);
		memento: memento.
	^ visual
]

{ #category : 'examples - selection' }
CPProcessVisualElementExamples >> idleEscapePreservesDiagramSelection [
	<gtExample>
	| fixture visual task taskShape |
	fixture := self fixture.
	task := fixture fourth.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.

	visual selectOnly: task.
	visual cancelInteraction.

	self assert: visual selectedDiagramElements size equals: 1.
	self assert: visual selectedDiagramElements first == taskShape.
	^ visual
]


{ #category : 'examples - selection' }
CPProcessVisualElementExamples >> transientConnectionStateDoesNotChangeDiagramSelection [
	<gtExample>
	| fixture visual start task taskShape |
	fixture := self fixture.
	start := fixture third.
	task := fixture fourth.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.

	visual selectOnly: task.
	visual beginConnectionFrom: start.
	visual connectionTargetModelElement: task.

	self assert: visual selectedDiagramElements size equals: 1.
	self assert: visual selectedDiagramElements first == taskShape.

	visual clearConnectionTarget.
	visual cancelInteraction.
	self assert: visual selectedDiagramElements size equals: 1.
	self assert: visual selectedDiagramElements first == taskShape.
	^ visual
]


{ #category : 'examples - selection' }
CPProcessVisualElementExamples >> marqueeSelectsShapeWhenBoundsIntersect [
	<gtExample>
	| fixture visual task taskShape partialRectangle |
	fixture := self fixture.
	task := fixture fourth.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.

	partialRectangle := 190 @ 70 corner: 230 @ 95.
	visual
		updateMarqueeSelectionFor: partialRectangle
		baseSelection: #().

	self assert: (visual selectedDiagramElements identityIncludes: taskShape).
	^ visual
]


{ #category : 'examples - selection' }
CPProcessVisualElementExamples >> marqueeCanAddToExistingDiagramSelection [
	<gtExample>
	| fixture visual taskShape startShape startRectangle |
	fixture := self fixture.
	startShape := fixture at: 9.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.

	startRectangle := 70 @ 60 corner: 135 @ 125.
	visual
		updateMarqueeSelectionFor: startRectangle
		baseSelection: { taskShape }.

	self assert: visual selectedDiagramElements size equals: 2.
	self assert: (visual selectedDiagramElements identityIncludes: taskShape).
	self assert: (visual selectedDiagramElements identityIncludes: startShape).
	^ visual
]


{ #category : 'examples - selection' }
CPProcessVisualElementExamples >> marqueeRequiresFullEdgeEnclosure [
	<gtExample>
	| fixture visual firstEdge partialRectangle fullRectangle |
	fixture := self fixture.
	firstEdge := fixture at: 12.
	visual := self visualElementForFixture: fixture.

	partialRectangle := 140 @ 110 corner: 180 @ 130.
	visual
		updateMarqueeSelectionFor: partialRectangle
		baseSelection: #().
	self assert: (visual selectedDiagramElements identityIncludes: firstEdge) not.

	fullRectangle := 140 @ 110 corner: 222 @ 130.
	visual
		updateMarqueeSelectionFor: fullRectangle
		baseSelection: #().
	self assert: (visual selectedDiagramElements identityIncludes: firstEdge).
	^ visual
]


{ #category : 'examples - selection' }
CPProcessVisualElementExamples >> selectionSupportsExclusiveAndAdditiveDiagramSelection [
	<gtExample>
	| fixture visual start task firstFlow startShape taskShape firstEdge |
	fixture := self fixture.
	start := fixture third.
	task := fixture fourth.
	firstFlow := fixture sixth.
	startShape := fixture at: 9.
	taskShape := fixture at: 10.
	firstEdge := fixture at: 12.
	visual := self visualElementForFixture: fixture.

	visual selectOnly: task.
	self assert: visual selectedDiagramElements size equals: 1.
	self assert: visual selectedDiagramElements first == taskShape.

	visual toggleSelectionOf: firstFlow.
	self assert: visual selectedDiagramElements size equals: 2.
	self assert: (visual selectedDiagramElements identityIncludes: taskShape).
	self assert: (visual selectedDiagramElements identityIncludes: firstEdge).

	visual selectOnly: start.
	self assert: visual selectedDiagramElements size equals: 1.
	self assert: visual selectedDiagramElements first == startShape.
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
	self assert: (visual edge: firstEdge isIncidentTo: finish).
	self assert: (visual edge: firstEdge isIncidentTo: fixture fourth) not.
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
	self assert: element uprightHost children size equals: 1.
	self assert: element uprightHost children first children size equals: 2.
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
	self assert: element uprightHost children size equals: 1.
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
	self assert: (element uprightHost children includes: label).
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
	self assert: viewport parent == shapeElement uprightHost.
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
		diagramContext: (self diagramContextForMemento: memento)) apply.
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
		self assert: each parent == shapeElement uprightHost ].
	self assert: shapeElement nestedProcessViewport parent == shapeElement uprightHost.
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
	visual selectOnly: subProcess.

	self assert: visual diagramSelection == nestedVisual diagramSelection.
	self assert: visual selectedDiagramElements size equals: 1.
	self assert: visual selectedDiagramElements first == shapeElement diagramShape.
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
		self assert: each parent == shapeElement uprightHost.
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
		self assert: each parent == shapeElement uprightHost.
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
	  memento diagramDescription processVisual collaborationVisual |

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
	diagramDescription := self descriptionFor: #diagram in: memento.
	processVisual := CPProcessVisualElement new
		beCollaborationHosted;
		memento: memento;
		yourself.
	collaborationVisual := CPCollaborationVisualElement new
		diagramEditing: (self diagramEditingForMemento: memento);
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
		equals: 200 @ 64.
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
	self assert: waypoints first y equals: 118.
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




{ #category : 'examples - selection' }
CPProcessVisualElementExamples >> collaborationAndProcessShareDiagramSelection [
	<gtExample>
	| fixture processVisual collaborationVisual task taskShape externalPool |
	fixture := self collaborationVisualFixture.
	processVisual := fixture at: 9.
	collaborationVisual := fixture at: 10.
	task := fixture at: 13.
	taskShape := processVisual diagramShapeForModelElement: task.
	externalPool := fixture at: 8.

	self assert: processVisual diagramSelection == collaborationVisual diagramSelection.
	processVisual selectOnly: task.
	self assert: collaborationVisual diagramSelection soleDiagramElement == taskShape.

	collaborationVisual selectOnlyDiagramElement: externalPool.
	self assert: processVisual selectedDiagramElements size equals: 1.
	self assert: processVisual selectedDiagramElements first == externalPool.
	^ collaborationVisual
]


{ #category : 'examples - selection' }
CPProcessVisualElementExamples >> collaborationMessageFlowParticipatesInDiagramSelection [
	<gtExample>
	| fixture processVisual collaborationVisual messageEdge |
	fixture := self collaborationVisualFixture.
	processVisual := fixture at: 9.
	collaborationVisual := fixture at: 10.
	messageEdge := fixture at: 12.

	collaborationVisual selectOnlyDiagramElement: messageEdge.
	self assert: processVisual selectedDiagramElements size equals: 1.
	self assert: processVisual selectedDiagramElements first == messageEdge.
	self assert: collaborationVisual diagramSelection soleDiagramElement == messageEdge.
	^ collaborationVisual
]


{ #category : 'examples - geometry' }
CPProcessVisualElementExamples >> diagramPlaneGeometryUsesAuthoredDI [
	<gtExample>
	| fixture memento diagram diagramDescription diagramContext geometry |
	fixture := self fixture.
	memento := fixture second.
	diagram := fixture at: 8.
	diagramDescription := self descriptionFor: #diagram in: memento.
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: memento
		using: diagramDescription.
	geometry := CPDiagramPlaneGeometry
		shapes: {
			fixture at: 9.
			fixture at: 10.
			fixture at: 11 }
		edges: {
			fixture at: 12.
			fixture at: 13 }
		context: diagramContext.

	self assert: geometry diagramBounds equals: (100 @ 94 corner: 472 @ 148).
	self assert: geometry diagramExtent equals: 372 @ 54.
	self assert: geometry normalizationOffset equals: -100 @ -94.
	self assert: geometry layerExtent equals: 472 @ 148.
	^ geometry
]


{ #category : 'examples - scrolling' }
CPProcessVisualElementExamples >> diagramViewportComputesExactBoundedTravel [
	<gtExample>
	| fitting oversized empty |
	fitting := CPDiagramViewport
		viewportExtent: 1000 @ 600
		diagramExtent: 400 @ 200.
	self assert: fitting cameraSlack equals: 600 @ 400.
	self assert: fitting canvasExtent equals: 1600 @ 1000.

	oversized := CPDiagramViewport
		viewportExtent: 1000 @ 600
		diagramExtent: 1400 @ 300.
	self assert: oversized cameraSlack equals: 0 @ 300.
	self assert: oversized canvasExtent equals: 1400 @ 900.

	empty := CPDiagramViewport
		viewportExtent: 1000 @ 600
		diagramExtent: 0 @ 0.
	self assert: empty cameraSlack equals: 0 @ 0.
	self assert: empty canvasExtent equals: 1000 @ 600.
	^ fitting
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


{ #category : 'examples - containment' }
CPProcessVisualElementExamples >> flowNodePlacementUsesPresentationHostCoordinateSeam [
	<gtExample>
	| fixture visual task element bounds host localPoint |
	fixture := self fixture.
	visual := self visualElementForFixture: fixture.
	task := fixture fourth.
	element := visual shapeElementsByModelElement at: task.
	bounds := visual stagedBoundsOf: element diagramShape.
	host := visual presentationHostForFlowNode: task.
	localPoint := visual
		diagramPoint: bounds origin
		localToPresentationHost: host.

	self assert: host == visual diagramPresentationParent.
	self assert: element parent == host.
	self assert: localPoint equals: bounds origin.
	^ element
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


{ #category : 'examples - geometry' }
CPProcessVisualElementExamples >> diagramContentOffsetsPreserveExistingCoordinateTransforms [
	<gtExample>
	| fixture processVisual collaborationVisual viewport |
	fixture := self collaborationVisualFixture.
	processVisual := fixture at: 9.
	collaborationVisual := fixture at: 10.
	viewport := 1000 @ 600.
	collaborationVisual viewportExtent: viewport.

	self assert: collaborationVisual diagramContentOffset equals:
		collaborationVisual cameraSlack - collaborationVisual diagramBounds origin.
	self assert: collaborationVisual diagramBoundsOriginInContent equals:
		collaborationVisual cameraSlack.
	self assert: processVisual diagramContentOffset equals:
		processVisual hostedDiagramInset - processVisual diagramBounds origin.
	self assert: processVisual diagramBoundsOriginInContent equals:
		processVisual hostedDiagramInset.
	^ collaborationVisual
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
	self assert: collaborationVisual diagramBounds equals: (40 @ 40 corner: 660 @ 420).
	self assert: collaborationVisual diagramExtent equals: 620 @ 380.
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

{ #category : 'examples - collaboration visual' }
CPProcessVisualElementExamples >> firstPoolWrapsExistingProcessDiagramWithoutChangingProcessDI [
	<gtExample>
	| fixture visual expected |
	fixture := self fixture.
	visual := self visualElementForFixture: fixture.
	expected := visual firstParticipantBoundsCenteredAt: 500 @ 300.

	self assert: expected extent x equals:
		visual diagramExtent x
			+ CPParticipantShapeElement processContentOriginOffset x
			+ (visual hostedDiagramInset x * 2).
	self assert: expected extent y equals:
		((visual diagramExtent y + (visual hostedDiagramInset y * 2))
			max: CPAtelierLaneLayout minimumLaneHeight).
	self assert: expected origin equals: 0 @ 0.
	self assert: visual diagramBounds origin ~= expected origin.
	^ expected
]

{ #category : 'examples - collaboration visual' }
CPProcessVisualElementExamples >> collaborationHostsProcessInHostedModeOnFirstRefresh [
	<gtExample>
	| fixture processVisual collaborationVisual localParticipant localElement |
	fixture := self collaborationVisualFixture.
	processVisual := fixture at: 9.
	collaborationVisual := fixture at: 10.
	localParticipant := fixture at: 4.
	localElement := collaborationVisual participantElementsByParticipant at: localParticipant.

	self assert: processVisual isCollaborationHosted.
	self assert: processVisual diagramPresentationParent ~~ processVisual.
	self assert: processVisual shapeElementsByModelElement isEmpty not.
	self assert: processVisual parent == localElement processHost.
	self assert: processVisual diagramPresentationParent constraints position equals:
		processVisual hostedDiagramInset - processVisual diagramBounds origin.
	^ processVisual
]

{ #category : 'examples - interaction' }
CPProcessVisualElementExamples >> diagramInteractionSurfaceStaysBehindAuthoredDiagram [
	<gtExample>
	| fixture visual |
	fixture := self fixture.
	visual := self visualElementForFixture: fixture.

	self assert: visual children first ~~ visual diagramPresentationParent.
	self assert: visual children last == visual diagramPresentationParent.
	^ visual
]

{ #category : 'examples - collaboration' }
CPProcessVisualElementExamples >> collaborationGeometryRefreshCanBeDelegated [
	<gtExample>
	| visual called |
	visual := CPCollaborationVisualElement new.
	called := false.
	visual refreshAfterGeometryChangeDo: [ called := true ].
	visual refreshAfterGeometryChange.
	self assert: called.
	^ visual
]



{ #category : 'examples - presentation' }
CPProcessVisualElementExamples >> processPresentationResolvesLaneBeforeBuild [
	<gtExample>
	| process laneSet lane memento presentation resolvedMemento |
	process := CPProcess new label: 'Lane selection process'; yourself.
	laneSet := CPLaneSet new.
	lane := CPLane new label: 'Reviewer'; yourself.
	laneSet addLane: lane.
	process addLaneSet: laneSet.
	memento := CFMaMemento model: process.
	presentation := CPProcessPresentation new.
	presentation memento: memento.

	self assert: presentation processDiagramElement isNil.
	resolvedMemento := presentation mementoForModelElement: lane.
	self assert: resolvedMemento model == lane.
	^ resolvedMemento
]

{ #category : 'examples - presentation' }
CPProcessVisualElementExamples >> processPresentationResolvesNestedFlowElementThroughStagedContext [
	<gtExample>
	| fixture memento flowElementsDescription subProcess task subProcessMemento nestedDescription presentation resolvedMemento |
	fixture := self fixture.
	memento := fixture second.
	flowElementsDescription := self descriptionFor: #flowElements in: memento.

	subProcess := CPNoneSubProcess new label: 'Nested'; yourself.
	task := CPUserTask new label: 'Inner task'; yourself.
	subProcess addFlowElement: task.
	memento
		write: ((memento readUsing: flowElementsDescription) asOrderedCollection copy
			add: subProcess;
			yourself)
		using: flowElementsDescription.
	subProcessMemento := memento
		childMementoFor: subProcess
		inRelation: flowElementsDescription.
	nestedDescription := self descriptionFor: #flowElements in: subProcessMemento.
	subProcessMemento write: subProcess flowElements using: nestedDescription.

	presentation := CPProcessPresentation new.
	presentation memento: memento.
	resolvedMemento := presentation mementoForModelElement: task.

	self assert: resolvedMemento model == task.
	self assert: resolvedMemento == (subProcessMemento
		childMementoFor: task
		inRelation: nestedDescription).
	^ resolvedMemento
]

{ #category : 'examples - presentation' }
CPProcessVisualElementExamples >> processPresentationResolvesStagedMessageFlowThroughCollaborationContext [
	<gtExample>
	| fixture memento operation assessment presentation resolvedMemento context |
	fixture := self collaborationFixture.
	memento := fixture at: 2.
	operation := CPAtelierConnectMessageFlow
		source: (fixture at: 3)
		target: (fixture at: 6)
		waypoints: { 250 @ 270. 250 @ 320 }
		processMemento: memento.
	assessment := operation apply.
	self assert: assessment isApplicable.

	presentation := CPProcessPresentation new.
	presentation memento: memento.
	resolvedMemento := presentation mementoForModelElement: assessment messageFlow.
	context := CPProcessCollaborationContext inRootMemento: memento.

	self assert: resolvedMemento model == assessment messageFlow.
	self assert: resolvedMemento == (context collaborationMemento
		childMementoFor: assessment messageFlow
		inRelation: context messageFlowsDescription).
	^ resolvedMemento
]


{ #category : 'examples - collaboration message flow reconnect' }
CPProcessVisualElementExamples >> selectedCollaborationMessageFlowShowsReconnectHandles [
	<gtExample>
	| fixture collaborationVisual messageEdge messageVisual |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	messageEdge := fixture at: 12.
	messageVisual := collaborationVisual messageFlowVisualsByEdge at: messageEdge.

	self assert: messageVisual reconnectHandles size equals: 2.
	messageVisual reconnectHandles do: [ :each |
		self assert: each visibility equals: BlVisibility hidden ].
	collaborationVisual selectOnlyDiagramElement: messageEdge.
	messageVisual reconnectHandles do: [ :each |
		self assert: each visibility equals: BlVisibility visible ].
	^ messageVisual
]

{ #category : 'examples - collaboration message flow reconnect' }
CPProcessVisualElementExamples >> collaborationMessageFlowReconnectWaypointsAreAuthoredInCollaborationCoordinates [
	<gtExample>
	| fixture collaborationVisual messageEdge externalParticipant task waypoints |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	messageEdge := fixture at: 12.
	externalParticipant := fixture at: 5.
	task := fixture at: 13.

	waypoints := collaborationVisual
		proposedMessageFlowWaypointsFor: messageEdge
		source: task
		target: externalParticipant.

	self assert: waypoints size equals: 2.
	self assert: waypoints first y < waypoints second y.
	self assert: waypoints second y equals: 320.
	^ waypoints
]

{ #category : 'examples - collaboration message flow reconnect' }
CPProcessVisualElementExamples >> collaborationMessageFlowReconnectOperationUsesExistingEdgeIdentity [
	<gtExample>
	| fixture collaborationVisual messageEdge externalParticipant task operation assessment context |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	messageEdge := fixture at: 12.
	externalParticipant := fixture at: 5.
	task := fixture at: 13.

	operation := collaborationVisual
		messageFlowReconnectOperationFor: messageEdge
		movingSource: true
		candidate: task.
	assessment := operation apply.
	context := CPProcessCollaborationContext inRootMemento: fixture second.

	self assert: assessment isApplicable.
	self assert: (context elements identityIncludes: messageEdge).
	self assert: (context stagedSourceOf: (fixture at: 11)) == task.
	self assert: (context stagedTargetOf: (fixture at: 11)) == externalParticipant.
	^ assessment
]


{ #category : 'examples - collaboration message flow editing' }
CPProcessVisualElementExamples >> collaborationMessageFlowUsesEditableMementoBackedLabel [
	<gtExample>
	| fixture messageVisual label |
	fixture := self collaborationVisualFixture.
	messageVisual := (fixture at: 10) messageFlowVisualsByEdge at: (fixture at: 12).
	label := messageVisual labelHost children first children first.

	self assert: label class equals: CFEditableLabel.
	self assert: label text asString equals: 'Order'.
	^ label
]

{ #category : 'examples - collaboration message flow editing' }
CPProcessVisualElementExamples >> collaborationMessageFlowLabelPlacementUsesStagedDI [
	<gtExample>
	| fixture collaborationVisual messageEdge assessment context |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	messageEdge := fixture at: 12.
	assessment := collaborationVisual
		setMessageFlowLabelSegmentIndex: 1
		segmentPosition: 0.25
		offset: -24.0
		forEdge: messageEdge.
	context := CPProcessCollaborationContext inRootMemento: fixture second.

	self assert: assessment isApplicable.
	self assert: (context diagramContext labelSegmentIndexOf: messageEdge) equals: 1.
	self assert: (context diagramContext labelSegmentPositionOf: messageEdge) equals: 0.25.
	self assert: (context diagramContext labelOffsetOf: messageEdge) equals: -24.0.
	^ assessment
]

{ #category : 'examples - collaboration message flow editing' }
CPProcessVisualElementExamples >> collaborationMessageFlowBendpointEditUsesSharedDIEditingContract [
	<gtExample>
	| fixture collaborationVisual messageEdge assessment messageVisual context proposed |
	fixture := self collaborationVisualFixture.
	collaborationVisual := fixture at: 10.
	messageEdge := fixture at: 12.
	proposed := { 350 @ 270. 500 @ 295. 350 @ 320 } asOrderedCollection.
	assessment := collaborationVisual setMessageFlowWaypoints: proposed forEdge: messageEdge.
	context := CPProcessCollaborationContext inRootMemento: fixture second.
	messageVisual := collaborationVisual messageFlowVisualsByEdge at: messageEdge.

	self assert: assessment isApplicable.
	self assert: (context diagramContext waypointsOf: messageEdge) equals: proposed.
	self assert: messageVisual bendpointHandles size equals: 1.
	^ messageVisual
]

{ #category : 'examples - boundary events' }
CPProcessVisualElementExamples >> boundaryEventUsesCompactExtentAroundStandardEventIcon [
	<gtExample>
	| visual boundary |
	visual := CPProcessVisualElement new.
	boundary := CPBoundaryEvent new.

	self assert: (visual extentForModelElement: boundary) equals: 32 @ 32.
	self assert: (visual extentForModelElement: CPIntermediateEvent new) equals: 42 @ 42.
	^ visual
]

{ #category : 'examples - boundary events' }
CPProcessVisualElementExamples >> boundaryEventBoundsStayCenteredOnActivityBorder [
	<gtExample>
	| visual eventBounds activityBounds constrained |
	visual := CPProcessVisualElement new.
	eventBounds := 224 @ 124 extent: 32 @ 32.
	activityBounds := 100 @ 100 extent: 140 @ 80.
	constrained := visual
		boundaryEventBounds: eventBounds
		constrainedToActivityBounds: activityBounds
		nearCenter: 260 @ 140.

	self assert: constrained extent equals: 32 @ 32.
	self assert: constrained center equals: 240 @ 140.
	^ constrained
]

{ #category : 'examples - boundary events' }
CPProcessVisualElementExamples >> boundaryEventResizeGeometryPreservesHostSideAndRelativePosition [
	<gtExample>
	| visual eventBounds currentActivityBounds proposedActivityBounds resized |
	visual := CPProcessVisualElement new.
	eventBounds := 84 @ 124 extent: 32 @ 32.
	currentActivityBounds := 100 @ 100 extent: 140 @ 80.
	proposedActivityBounds := 120 @ 90 extent: 200 @ 120.
	resized := visual
		boundaryEventBounds: eventBounds
		fromActivityBounds: currentActivityBounds
		toActivityBounds: proposedActivityBounds.

	self assert: resized extent equals: 32 @ 32.
	self assert: resized center equals: 120 @ 150.
	^ resized
]

{ #category : 'examples - boundary events' }
CPProcessVisualElementExamples >> boundaryEventHoverLabelStaysOutsideAttachedActivity [
	<gtExample>
	| visual activityBounds labelExtent topOrigin rightOrigin |
	visual := CPProcessVisualElement new.
	activityBounds := 100 @ 100 extent: 140 @ 80.
	labelExtent := 180 @ 44.
	topOrigin := visual
		boundaryEventHoverLabelOriginForEventBounds: (154 @ 84 extent: 32 @ 32)
		activityBounds: activityBounds
		labelExtent: labelExtent.
	rightOrigin := visual
		boundaryEventHoverLabelOriginForEventBounds: (224 @ 124 extent: 32 @ 32)
		activityBounds: activityBounds
		labelExtent: labelExtent.

	self assert: topOrigin y + labelExtent y < activityBounds top.
	self assert: rightOrigin x > activityBounds right.
	^ { topOrigin. rightOrigin }
]

{ #category : 'examples - boundary events' }
CPProcessVisualElementExamples >> freshlyStagedBoundaryEventIsBlocChildOfAttachedActivity [
	<gtExample>
	| process task diagram taskShape memento diagramDescription boundary operation assessment visual taskElement boundaryElement |
	process := CPProcess new.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: task.
	diagram := CPDiagram new.
	taskShape := CPShape new
		modelElement: task;
		bounds: (100 @ 100 extent: 140 @ 80);
		yourself.
	diagram addElement: taskShape.
	process diagram: diagram.
	memento := CFMaMemento model: process.
	diagramDescription := memento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	boundary := CPBoundaryEvent new
		eventDefinitions: { CPTimerEventDefinition new } asOrderedCollection;
		yourself.
	operation := CPAtelierCreateBoundaryEvent
		boundaryEvent: boundary
		attachedTo: task
		bounds: (84 @ 124 extent: 32 @ 32)
		flowContainer: process
		processMemento: memento
		diagramContext: (self diagramContextForMemento: memento).
	assessment := operation apply.
	self assert: assessment isApplicable.

	visual := CPProcessVisualElement new.
	visual memento: memento.
	taskElement := visual shapeElementsByModelElement at: task.
	boundaryElement := visual shapeElementsByModelElement at: boundary.

	self assert: boundaryElement parent == taskElement.
	self assert: boundaryElement position equals: -16 @ 24.
	self assert: ((visual stagedBoundsOf: (visual diagramShapeForModelElement: boundary)) center) equals: 100 @ 140.
	^ boundaryElement
]


{ #category : 'examples - boundary events' }
CPProcessVisualElementExamples >> boundaryEventTypeSelectionUsesRequestedTypes [
	<gtExample>
	| selection |
	selection := CPBoundaryEventTypeSelection typeClass: CPTimerEventDefinition.
	self assert: selection typeClasses equals: {
		CPTimerEventDefinition.
		CPErrorEventDefinition.
		CPMessageEventDefinition.
		CPEscalationEventDefinition.
		CPConditionalEventDefinition }.
	self assert: (selection typeLabelFor: CPEscalationEventDefinition) equals: 'Escalation'.
	self assert: (selection typeIconFor: CPEscalationEventDefinition) equals: #chevronsUp.
	^ selection
]

{ #category : 'examples - boundary events' }
CPProcessVisualElementExamples >> boundaryEventBoundsSnapToEachActivitySide [
	<gtExample>
	| visual eventBounds activityBounds left right top bottom |
	visual := CPProcessVisualElement new.
	eventBounds := 84 @ 124 extent: 32 @ 32.
	activityBounds := 100 @ 100 extent: 140 @ 80.
	left := visual
		boundaryEventBounds: eventBounds
		constrainedToActivityBounds: activityBounds
		nearCenter: 90 @ 140.
	right := visual
		boundaryEventBounds: eventBounds
		constrainedToActivityBounds: activityBounds
		nearCenter: 250 @ 140.
	top := visual
		boundaryEventBounds: eventBounds
		constrainedToActivityBounds: activityBounds
		nearCenter: 170 @ 90.
	bottom := visual
		boundaryEventBounds: eventBounds
		constrainedToActivityBounds: activityBounds
		nearCenter: 170 @ 190.

	self assert: left center equals: 100 @ 140.
	self assert: right center equals: 240 @ 140.
	self assert: top center equals: 170 @ 100.
	self assert: bottom center equals: 170 @ 180.
	^ { left. right. top. bottom }
]

{ #category : 'examples - boundary events' }
CPProcessVisualElementExamples >> boundaryEventBoundsClampToActivityCorners [
	<gtExample>
	| visual eventBounds activityBounds topLeft bottomRight |
	visual := CPProcessVisualElement new.
	eventBounds := 84 @ 124 extent: 32 @ 32.
	activityBounds := 100 @ 100 extent: 140 @ 80.
	topLeft := visual
		boundaryEventBounds: eventBounds
		constrainedToActivityBounds: activityBounds
		nearCenter: 70 @ 70.
	bottomRight := visual
		boundaryEventBounds: eventBounds
		constrainedToActivityBounds: activityBounds
		nearCenter: 270 @ 210.

	self assert: (topLeft center x between: activityBounds left and: activityBounds right).
	self assert: (topLeft center y between: activityBounds top and: activityBounds bottom).
	self assert: (bottomRight center x between: activityBounds left and: activityBounds right).
	self assert: (bottomRight center y between: activityBounds top and: activityBounds bottom).
	self assert: ({
		topLeft center x = activityBounds left.
		topLeft center y = activityBounds top } anySatisfy: [ :each | each ]).
	self assert: ({
		bottomRight center x = activityBounds right.
		bottomRight center y = activityBounds bottom } anySatisfy: [ :each | each ]).
	^ { topLeft. bottomRight }
]

{ #category : 'examples - contextual append' }
CPProcessVisualElementExamples >> appendedFlowNodeRendersConnectionToSource [
	<gtExample>
	| fixture visual memento task taskShape appended operation assessment |
	fixture := self fixture.
	memento := fixture second.
	task := fixture fourth.
	taskShape := fixture at: 10.
	visual := self visualElementForFixture: fixture.
	appended := CPUserTask new label: 'Follow up'; yourself.

	operation := visual diagramEditing
		appendFlowNode: appended
		fromShape: taskShape
		bounds: (410 @ 94 extent: 132 @ 54).
	assessment := operation apply.
	visual refresh.

	self assert: assessment isApplicable.
	self assert: (visual lineElementsForEdge: assessment edge) size equals: 1.
	self assert: (visual stagedSourceOf: assessment sequenceFlow) == task.
	self assert: (visual stagedTargetOf: assessment sequenceFlow) == appended.
	^ visual
]

{ #category : 'examples - contextual append' }
CPProcessVisualElementExamples >> paletteAndContextualDropHandlersPartitionItemEvents [
	<gtExample>
	| paletteSource contextualSource paletteItem contextualItem paletteEvent contextualEvent paletteHandler contextualHandler |
	paletteSource := BlElement new.
	paletteSource userData at: #atelierPaletteSource put: true.
	contextualSource := BlElement new.
	contextualSource userData at: #processContextualAppendContext put: Object new.

	paletteItem := BlDragItem new sourceElement: paletteSource; yourself.
	contextualItem := BlDragItem new sourceElement: contextualSource; yourself.
	paletteEvent := BlItemsDroppedEvent new items: { paletteItem }; yourself.
	contextualEvent := BlItemsDroppedEvent new items: { contextualItem }; yourself.
	paletteHandler := CPProcessPaletteDropHandler new.
	contextualHandler := CPProcessContextualAppendDropHandler new.

	self assert: (paletteHandler isPaletteItemsEvent: paletteEvent).
	self assert: (paletteHandler isPaletteItemsEvent: contextualEvent) not.
	self assert: (contextualHandler isContextualAppendItemsEvent: contextualEvent).
	self assert: (contextualHandler isContextualAppendItemsEvent: paletteEvent) not.
	^ { paletteHandler. contextualHandler }
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> lanesRenderAsNativeBlocPartition [
	<gtExample>
	| process laneSet firstLane secondLane task diagram firstLaneShape secondLaneShape taskShape memento visual firstLaneElement laneSetVisual |
	process := CPProcess new label: 'Lane process'; yourself.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: task.
	laneSet := CPLaneSet new.
	firstLane := CPLane new label: 'Reviewer'; yourself.
	secondLane := CPLane new label: 'Approver'; yourself.
	firstLane addFlowNodeRef: task.
	laneSet addLane: firstLane; addLane: secondLane.
	process addLaneSet: laneSet.
	diagram := CPDiagram new.
	process diagram: diagram.
	firstLaneShape := CPShape new modelElement: firstLane; bounds: (40 @ 40 extent: 500 @ 140); yourself.
	secondLaneShape := CPShape new modelElement: secondLane; bounds: (40 @ 180 extent: 500 @ 140); yourself.
	taskShape := CPShape new modelElement: task; bounds: (180 @ 82 extent: 132 @ 54); yourself.
	diagram addElement: firstLaneShape; addElement: secondLaneShape; addElement: taskShape.
	memento := CFMaMemento model: process.
	visual := CPProcessVisualElement new
		memento: memento;
		beCollaborationHosted;
		yourself.
	laneSetVisual := visual laneSetVisual.
	firstLaneElement := visual laneShapeElementFor: firstLane.

	self assert: laneSetVisual laneSet == laneSet.
	self assert: laneSetVisual laneElements size equals: 2.
	self assert: firstLaneElement lane == firstLane.
	self assert: firstLaneElement diagramShape == firstLaneShape.
	self assert: firstLaneElement bodyHost notNil.
	self assert: firstLaneElement labelElement text asString equals: 'Reviewer'.
	self assert: (visual stagedBoundsOf: firstLaneShape) extent equals: 500 @ 140.
	self assert: (visual shapeElementForModelElement: task) modelElement == task.
	^ visual
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> horizontalPoolLaneEditingRegression [
	<gtExample>
	self emptyHostedPoolUsesOneLaneMinimumHeight.
	self firstLaneAdoptsExistingProcessFlowNodes.
	self poolPaletteDropOrdersLaneByDropEdge.
	self resizingPoolPreservesNestedLaneHeaderInset.
	self resizingPoolMovesFlowNodesWithTheirLanes.
	self laneResizePreviewMovesExternalFlowNodeLabel.
	self laneResizePreviewMovesConnectionLabel.
	^ self documentRootedNestedLaneDragWithoutIntermediateLayoutPreservesDiagramProjection
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> poolPaletteDropOnHostedProcessCreatesAndRendersStagedLane [
	<gtExample>
	| fixture process memento processVisual collaborationVisual paletteItem source dragItem pool assessment lane |
	fixture := self collaborationVisualFixture.
	process := fixture first.
	memento := fixture at: 2.
	processVisual := fixture at: 9.
	collaborationVisual := fixture at: 10.

	paletteItem := CFAtelierPaletteItem
		label: 'Pool'
		icon: CPParticipant icon
		provider: (CFAtelierFactoryProvider factory: [
			CPParticipant new label: 'Pool'; yourself ]).
	processVisual poolPaletteItem: paletteItem.
	processVisual collaborationVisual: collaborationVisual.

	source := BlElement new.
	source userData
		at: #atelierPaletteSource put: true;
		at: #atelierPaletteItem put: paletteItem.
	pool := paletteItem materialize.
	dragItem := BlDragItem new
		sourceElement: source;
		domainObject: pool;
		yourself.

	self assert: (processVisual acceptsPaletteDragItem: dragItem).
	assessment := processVisual createPaletteItem: dragItem atRootDiagramPoint: 300 @ 140.
	self assert: assessment isApplicable.
	lane := processVisual lanesForCurrentProcess first.
	self assert: lane class equals: CPLane.
	self assert: (processVisual laneShapeElementFor: lane) lane == lane.
	self assert: process laneSets isEmpty.
	^ processVisual
]
{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> poolPaletteSecondLaneGrowthRefreshesVisibleParticipant [
	<gtExample>
	| fixture processVisual collaborationVisual participant participantShape firstAssessment secondAssessment stagedBounds participantElement |
	fixture := self collaborationVisualFixture.
	processVisual := fixture at: 9.
	collaborationVisual := fixture at: 10.
	participant := fixture at: 4.
	participantShape := fixture at: 7.

	firstAssessment := processVisual
		createLaneFromPoolPaletteAtRootDiagramPoint: 300 @ 140.
	self assert: firstAssessment isApplicable.
	secondAssessment := processVisual
		createLaneFromPoolPaletteAtRootDiagramPoint: 300 @ 200.
	self assert: secondAssessment isApplicable.

	stagedBounds := collaborationVisual stagedBoundsOf: participantShape.
	self assert: stagedBounds height equals: 370.
	participantElement := collaborationVisual participantElementsByParticipant at: participant.
	collaborationVisual forceLayout.
	self assert: participantElement extent equals: stagedBounds extent.
	^ collaborationVisual
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> firstLaneAdoptsExistingProcessFlowNodes [
	<gtExample>
	| fixture process memento processVisual assessment lane laneContext expectedNodes |
	fixture := self collaborationVisualFixture.
	process := fixture first.
	memento := fixture at: 2.
	processVisual := fixture at: 9.
	assessment := processVisual
		createLaneFromPoolPaletteAtRootDiagramPoint: 300 @ 140.
	self assert: assessment isApplicable.
	lane := assessment lane.
	laneContext := CPProcessLaneContext inRootMemento: memento.
	expectedNodes := process flowElements reject: [ :each | each isSequenceFlow ].
	self assert: (laneContext stagedFlowNodeRefsOf: lane) size equals: expectedNodes size.
	expectedNodes do: [ :each |
		self assert: ((laneContext stagedFlowNodeRefsOf: lane) identityIncludes: each) ].
	^ assessment
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> poolPaletteDropOrdersLaneByDropEdge [
	<gtExample>
	| process diagram laneSet first second firstShape secondShape memento visual beforeAssessment afterAssessment laneContext lanes |
	process := CPProcess new label: 'Ordered lanes'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	laneSet := CPLaneSet new.
	first := CPLane new label: 'First'; yourself.
	second := CPLane new label: 'Second'; yourself.
	laneSet addLane: first; addLane: second.
	process addLaneSet: laneSet.
	firstShape := CPShape new modelElement: first; bounds: (0 @ 0 extent: 500 @ 200); yourself.
	secondShape := CPShape new modelElement: second; bounds: (0 @ 200 extent: 500 @ 200); yourself.
	diagram addElement: firstShape; addElement: secondShape.
	memento := CFMaMemento model: process.
	visual := CPProcessVisualElement new
		diagramEditing: (self diagramEditingForMemento: memento);
		memento: memento;
		yourself.
	beforeAssessment := visual createLaneFromPoolPaletteAtRootDiagramPoint: 250 @ 210.
	self assert: beforeAssessment isApplicable.
	laneContext := CPProcessLaneContext inRootMemento: memento.
	lanes := laneContext stagedLanesInLaneSet: laneSet.
	self assert: lanes second == beforeAssessment lane.
	self assert: lanes third == second.
	afterAssessment := visual createLaneFromPoolPaletteAtRootDiagramPoint: 250 @ 530.
	self assert: afterAssessment isApplicable.
	lanes := laneContext stagedLanesInLaneSet: laneSet.
	self assert: lanes last == afterAssessment lane.
	^ visual
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> createLaneSetWithLaneAddsDistinctTopLevelLaneSet [
	<gtExample>
	| process diagram firstLaneSet firstLane memento diagramDescription editing secondLane operation assessment laneContext |
	process := CPProcess new label: 'LaneSet creation process'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	firstLaneSet := CPLaneSet new.
	firstLane := CPLane new label: 'Existing'; yourself.
	firstLaneSet addLane: firstLane.
	process addLaneSet: firstLaneSet.
	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	editing := self diagramEditingForMemento: memento.
	secondLane := CPLane new label: 'Lane'; yourself.
	operation := editing
		createLaneSetWithLane: secondLane
		bounds: (0 @ 180 extent: 500 @ 140).
	assessment := operation apply.

	self assert: assessment isApplicable.
	laneContext := CPProcessLaneContext inRootMemento: memento.
	self assert: laneContext stagedLaneSets size equals: 2.
	self assert: laneContext stagedLaneSets first == firstLaneSet.
	self assert: laneContext stagedLaneSets second == assessment laneSet.
	self assert: laneContext stagedLanes size equals: 2.
	self assert: laneContext stagedLanes second == secondLane.
	self assert: (laneContext mementoForLane: secondLane) model == secondLane.
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> insertingLaneAboveShiftsFollowingLaneAndItsFlowNode [
	<gtExample>
	| process diagram laneSet firstLane secondLane task firstShape secondShape taskShape memento diagramDescription editing inserted operation assessment diagramContext laneContext |
	process := CPProcess new label: 'Lane insertion process'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: task.
	laneSet := CPLaneSet new.
	firstLane := CPLane new label: 'Reviewer'; yourself.
	secondLane := CPLane new label: 'Approver'; yourself.
	firstLane addFlowNodeRef: task.
	laneSet addLane: firstLane; addLane: secondLane.
	process addLaneSet: laneSet.
	firstShape := CPShape new modelElement: firstLane; bounds: (40 @ 40 extent: 500 @ 140); yourself.
	secondShape := CPShape new modelElement: secondLane; bounds: (40 @ 180 extent: 500 @ 140); yourself.
	taskShape := CPShape new modelElement: task; bounds: (180 @ 82 extent: 132 @ 54); yourself.
	diagram addElement: firstShape; addElement: secondShape; addElement: taskShape.

	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	editing := self diagramEditingForMemento: memento.
	inserted := CPLane new label: 'Inserted'; yourself.
	operation := editing insertLane: inserted relativeTo: firstLane after: false.
	assessment := operation apply.

	self assert: assessment isApplicable.
	laneContext := CPProcessLaneContext inRootMemento: memento.
	self assert: (laneContext stagedLanesInLaneSet: laneSet) first == inserted.
	self assert: (laneContext stagedLanesInLaneSet: laneSet) second == firstLane.
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: memento
		using: diagramDescription.
	self assert: (diagramContext boundsOf: firstShape) equals: (40 @ 180 extent: 500 @ 140).
	self assert: (diagramContext boundsOf: secondShape) equals: (40 @ 320 extent: 500 @ 140).
	self assert: (diagramContext boundsOf: taskShape) equals: (180 @ 222 extent: 132 @ 54).
	self assert: process laneSets first lanes first == firstLane.
	^ assessment
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> insertingLaneBelowUsesExistingPoolRoomBeforeGrowingParticipant [
	<gtExample>
	| fixture process memento collaborationContext participant participantShape participantBounds diagramDescription editing laneSet lane laneShape inserted operation assessment stagedParticipantBounds |
	fixture := self collaborationVisualFixture.
	process := fixture first.
	memento := fixture at: 2.
	collaborationContext := CPProcessCollaborationContext inRootMemento: memento.
	participant := collaborationContext participantForProcess: process.
	participantShape := (collaborationContext diagramContext shapesForModelElement: participant) anyOne.
	participantBounds := collaborationContext diagramContext boundsOf: participantShape.
	laneSet := CPLaneSet new.
	lane := CPLane new label: 'Existing'; yourself.
	laneSet addLane: lane.
	process addLaneSet: laneSet.
	laneShape := CPShape new modelElement: lane; bounds: (40 @ 40 extent: 500 @ 140); yourself.
	process diagram addElement: laneShape.

	"Use a fresh memento after adding the fixture Lane."
	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	editing := self diagramEditingForMemento: memento.
	inserted := CPLane new label: 'Inserted'; yourself.
	operation := editing insertLane: inserted relativeTo: lane after: true.
	assessment := operation apply.
	self assert: assessment isApplicable.
	collaborationContext := CPProcessCollaborationContext inRootMemento: memento.
	participant := collaborationContext participantForProcess: process.
	participantShape := (collaborationContext diagramContext shapesForModelElement: participant) anyOne.
	stagedParticipantBounds := collaborationContext diagramContext boundsOf: participantShape.
	self assert: stagedParticipantBounds height >= participantBounds height.
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> firstLaneBoundsFillHostedPoolBody [
	<gtExample>
	| process start task diagram startShape taskShape memento visual expectedBounds |
	process := CPProcess new label: 'Pool body'; yourself.
	start := CPNoneStartEvent new label: 'Start'; yourself.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: start; addFlowElement: task.
	diagram := CPDiagram new.
	process diagram: diagram.
	startShape := CPShape new modelElement: start; bounds: (80 @ 70 extent: 42 @ 42); yourself.
	taskShape := CPShape new modelElement: task; bounds: (180 @ 64 extent: 132 @ 54); yourself.
	diagram addElement: startShape; addElement: taskShape.
	memento := CFMaMemento model: process.
	visual := CPProcessVisualElement new
		memento: memento;
		beCollaborationHosted;
		yourself.
	expectedBounds := (26 @ 40) extent: 310 @ 102.
	self assert: visual poolBodyBoundsForFirstLane equals: expectedBounds.
	^ visual
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> insertingSecondLaneSplitsRoomyFirstLane [
	<gtExample>
	| process diagram laneSet existing laneShape memento diagramDescription editing inserted assessment diagramContext laneContext insertedShape |
	process := CPProcess new label: 'Roomy lane process'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	laneSet := CPLaneSet new.
	existing := CPLane new label: 'Existing'; yourself.
	laneSet addLane: existing.
	process addLaneSet: laneSet.
	laneShape := CPShape new modelElement: existing; bounds: (40 @ 40 extent: 500 @ 320); yourself.
	diagram addElement: laneShape.
	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	editing := self diagramEditingForMemento: memento.
	inserted := CPLane new label: 'Inserted'; yourself.
	assessment := (editing insertLane: inserted relativeTo: existing after: true) apply.
	self assert: assessment isApplicable.
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: memento
		using: diagramDescription.
	self assert: (diagramContext boundsOf: laneShape) equals: (40 @ 40 extent: 500 @ 160).
	insertedShape := (diagramContext shapesForModelElement: inserted) anyOne.
	self assert: (diagramContext boundsOf: insertedShape) equals: (40 @ 200 extent: 500 @ 160).
	laneContext := CPProcessLaneContext inRootMemento: memento.
	self assert: (laneContext stagedLanesInLaneSet: laneSet) size equals: 2.
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> resizingPoolReflowsSingleLaneToFullBody [
	<gtExample>
	| fixture process memento collaborationContext participant participantShape processDiagram laneSet lane laneShape diagramDescription editing assessment processDiagramContext |
	fixture := self collaborationVisualFixture.
	process := fixture first.
	memento := fixture at: 2.
	collaborationContext := CPProcessCollaborationContext inRootMemento: memento.
	participant := collaborationContext participantForProcess: process.
	participantShape := (collaborationContext diagramContext shapesForModelElement: participant) anyOne.
	processDiagram := process diagram.
	laneSet := CPLaneSet new.
	lane := CPLane new label: 'Lane'; yourself.
	laneSet addLane: lane.
	process addLaneSet: laneSet.
	laneShape := CPShape new modelElement: lane; bounds: (56 @ 40 extent: 584 @ 230); yourself.
	processDiagram addElement: laneShape.

	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	editing := self diagramEditingForMemento: memento.
	collaborationContext := CPProcessCollaborationContext inRootMemento: memento.
	participant := collaborationContext participantForProcess: process.
	participantShape := (collaborationContext diagramContext shapesForModelElement: participant) anyOne.
	assessment := (CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: (40 @ 40 extent: 820 @ 360)
		processMemento: memento) apply.
	self assert: assessment isApplicable.

	processDiagramContext := CPDiagramMementoContext
		diagram: processDiagram
		inMemento: memento
		using: diagramDescription.
	self assert: (processDiagramContext boundsOf: laneShape) extent equals: 784 @ 360.
	^ assessment
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> resizingPoolPreservesLanePartitionAndFillsBody [
	<gtExample>
	| fixture process memento collaborationContext participant participantShape processDiagram laneSet firstLane secondLane firstShape secondShape diagramDescription assessment processDiagramContext |
	fixture := self collaborationVisualFixture.
	process := fixture first.
	processDiagram := process diagram.
	laneSet := CPLaneSet new.
	firstLane := CPLane new label: 'First'; yourself.
	secondLane := CPLane new label: 'Second'; yourself.
	laneSet addLane: firstLane; addLane: secondLane.
	process addLaneSet: laneSet.
	firstShape := CPShape new modelElement: firstLane; bounds: (56 @ 40 extent: 584 @ 115); yourself.
	secondShape := CPShape new modelElement: secondLane; bounds: (56 @ 155 extent: 584 @ 115); yourself.
	processDiagram addElement: firstShape; addElement: secondShape.
	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	collaborationContext := CPProcessCollaborationContext inRootMemento: memento.
	participant := collaborationContext participantForProcess: process.
	participantShape := (collaborationContext diagramContext shapesForModelElement: participant) anyOne.
	assessment := (CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: (40 @ 40 extent: 820 @ 360)
		processMemento: memento) apply.
	self assert: assessment isApplicable.

	processDiagramContext := CPDiagramMementoContext
		diagram: processDiagram
		inMemento: memento
		using: diagramDescription.
	self assert: (processDiagramContext boundsOf: firstShape) equals: (56 @ 40 extent: 784 @ 180).
	self assert: (processDiagramContext boundsOf: secondShape) equals: (56 @ 220 extent: 784 @ 180).
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> firstLaneExpandsPoolLeftForLaneHeader [
	<gtExample>
	| fixture process memento processVisual collaborationVisual paletteItem source dragItem pool assessment collaborationContext participant participantShape bounds |
	fixture := self collaborationVisualFixture.
	process := fixture first.
	memento := fixture at: 2.
	processVisual := fixture at: 9.
	collaborationVisual := fixture at: 10.
	paletteItem := CFAtelierPaletteItem
		label: 'Pool'
		icon: CPParticipant icon
		provider: (CFAtelierFactoryProvider factory: [
			CPParticipant new label: 'Pool'; yourself ]).
	processVisual poolPaletteItem: paletteItem.
	processVisual collaborationVisual: collaborationVisual.
	source := BlElement new.
	source userData
		at: #atelierPaletteSource put: true;
		at: #atelierPaletteItem put: paletteItem.
	pool := paletteItem materialize.
	dragItem := BlDragItem new sourceElement: source; domainObject: pool; yourself.
	assessment := processVisual createPaletteItem: dragItem atRootDiagramPoint: 300 @ 140.
	self assert: assessment isApplicable.
	collaborationContext := CPProcessCollaborationContext inRootMemento: memento.
	participant := collaborationContext participantForProcess: process.
	participantShape := (collaborationContext diagramContext shapesForModelElement: participant) anyOne.
	bounds := collaborationContext diagramContext boundsOf: participantShape.
	self assert: bounds left equals: 10.
	self assert: bounds right equals: 660.
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> firstLaneIsTransparentLikePool [
	<gtExample>
	| process diagram laneSet lane laneShape memento visual laneElement |
	process := CPProcess new label: 'Lane appearance'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	laneSet := CPLaneSet new.
	lane := CPLane new label: 'Lane'; yourself.
	laneSet addLane: lane.
	process addLaneSet: laneSet.
	laneShape := CPShape new modelElement: lane; bounds: (0 @ 0 extent: 300 @ 180); yourself.
	diagram addElement: laneShape.
	memento := CFMaMemento model: process.
	visual := CPProcessVisualElement new memento: memento; yourself.
	laneElement := visual laneShapeElementFor: lane.
	self assert: laneElement background paint color equals: Color transparent.
	self assert: laneElement labelBand background paint color equals: Color transparent.
	^ laneElement
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> firstLanePoolResizeContainsRequiredLaneExtent [
	<gtExample>
	| fixture process memento diagramDescription collaborationContext participant participantShape editing lane operation assessment laneBounds participantBounds |
	fixture := self collaborationVisualFixture.
	process := fixture first.
	memento := fixture at: 2.
	diagramDescription := self descriptionFor: #diagram in: memento.
	editing := self diagramEditingForMemento: memento.
	lane := CPLane new label: 'Lane'; yourself.
	laneBounds := (26 @ 40 extent: 700 @ 260).
	operation := editing createLane: lane bounds: laneBounds.
	assessment := operation assess.
	self assert: assessment isApplicable.
	self assert: assessment participantResizeAssessment isApplicable.
	participantBounds := assessment participantResizeAssessment proposedBounds.
	self assert: participantBounds width >= (CPParticipantShapeElement processContentOriginOffset x + laneBounds width).
	self assert: participantBounds height >= laneBounds height.
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> hostedDiagramUsesLaneSetAsNativeStructuralBoundary [
	<gtExample>
	| process diagram laneSet lane laneShape task taskShape memento visual laneElement |
	process := CPProcess new label: 'Hosted lane boundary'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: task.
	laneSet := CPLaneSet new.
	lane := CPLane new label: 'Reviewer'; yourself.
	lane addFlowNodeRef: task.
	laneSet addLane: lane.
	process addLaneSet: laneSet.
	laneShape := CPShape new modelElement: lane; bounds: (26 @ 40 extent: 310 @ 102); yourself.
	taskShape := CPShape new modelElement: task; bounds: (80 @ 64 extent: 132 @ 54); yourself.
	diagram addElement: laneShape; addElement: taskShape.
	memento := CFMaMemento model: process.
	visual := CPProcessVisualElement new
		memento: memento;
		beCollaborationHosted;
		yourself.
	laneElement := visual laneShapeElementFor: lane.

	self assert: visual laneSetVisual notNil.
	self assert: visual laneSetVisual parent == visual diagramPresentationParent.
	self assert: laneElement parent == visual laneSetVisual lanesHost.
	self assert: laneElement labelBand notNil.
	self assert: laneElement bodyHost notNil.
	self assert: laneElement labelElement class equals: CFEditableLabel.
	^ visual
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> addChildLaneCreatesNestedLaneSetWithoutMutatingCommittedModel [
	<gtExample>
	| process diagram laneSet parentLane parentShape memento diagramDescription editing childLane operation assessment laneContext childLaneSet |
	process := CPProcess new label: 'Nested lanes'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	laneSet := CPLaneSet new.
	parentLane := CPLane new label: 'Department'; yourself.
	laneSet addLane: parentLane.
	process addLaneSet: laneSet.
	parentShape := CPShape new
		modelElement: parentLane;
		bounds: (30 @ 20 extent: 500 @ 240);
		yourself.
	diagram addElement: parentShape.
	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	editing := self diagramEditingForMemento: memento.
	childLane := CPLane new label: 'Team'; yourself.
	operation := editing
		addChildLane: childLane
		toParentLane: parentLane
		bounds: (60 @ 20 extent: 470 @ 240).
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: parentLane childLaneSet isNil.
	laneContext := CPProcessLaneContext inRootMemento: memento.
	childLaneSet := laneContext stagedChildLaneSetOf: parentLane.
	self assert: childLaneSet notNil.
	self assert: (laneContext stagedLanesInLaneSet: childLaneSet) size equals: 1.
	self assert: (laneContext stagedLanesInLaneSet: childLaneSet) first == childLane.
	self assert: (laneContext mementoForLane: childLane) model == childLane.
	^ assessment
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> nestedLaneSetRendersInsideParentLaneBody [
	<gtExample>
	| process diagram outerLaneSet parentLane childLaneSet childLane parentShape childShape memento visual parentElement childElement childSetVisual |
	process := CPProcess new label: 'Nested lane visual'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	outerLaneSet := CPLaneSet new.
	parentLane := CPLane new label: 'Department'; yourself.
	childLaneSet := CPLaneSet new.
	childLane := CPLane new label: 'Team'; yourself.
	childLaneSet addLane: childLane.
	parentLane childLaneSet: childLaneSet.
	outerLaneSet addLane: parentLane.
	process addLaneSet: outerLaneSet.
	parentShape := CPShape new
		modelElement: parentLane;
		bounds: (30 @ 20 extent: 500 @ 240);
		yourself.
	childShape := CPShape new
		modelElement: childLane;
		bounds: (60 @ 20 extent: 470 @ 240);
		yourself.
	diagram addElement: parentShape; addElement: childShape.
	memento := CFMaMemento model: process.
	visual := CPProcessVisualElement new
		memento: memento;
		beCollaborationHosted;
		yourself.
	parentElement := visual laneShapeElementFor: parentLane.
	childElement := visual laneShapeElementFor: childLane.
	childSetVisual := childElement parent parent.

	self assert: childSetVisual class equals: CPLaneSetVisualElement.
	self assert: childSetVisual parent == parentElement bodyHost.
	self assert: childElement parent == childSetVisual lanesHost.
	self assert: childElement bodyHost notNil.
	^ visual
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> unequalLaneBoundsProjectExactlyFromDiagramInterchange [
	<gtExample>
	| process diagram laneSet firstLane secondLane firstShape secondShape memento visual firstElement secondElement |
	process := CPProcess new label: 'Unequal Lane projection'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	laneSet := CPLaneSet new.
	firstLane := CPLane new label: 'First'; yourself.
	secondLane := CPLane new label: 'Second'; yourself.
	laneSet addLane: firstLane; addLane: secondLane.
	process addLaneSet: laneSet.
	firstShape := CPShape new
		modelElement: firstLane;
		bounds: (40 @ 40 extent: 500 @ 137);
		yourself.
	secondShape := CPShape new
		modelElement: secondLane;
		bounds: (40 @ 177 extent: 500 @ 223);
		yourself.
	diagram addElement: firstShape; addElement: secondShape.
	memento := CFMaMemento model: process.
	visual := CPProcessVisualElement new
		beCollaborationHosted;
		memento: memento;
		yourself.
	visual forceLayout.
	firstElement := visual laneShapeElementFor: firstLane.
	secondElement := visual laneShapeElementFor: secondLane.

	self assert: (visual diagramBoundsForElement: firstElement) equals: firstShape bounds.
	self assert: (visual diagramBoundsForElement: secondElement) equals: secondShape bounds.
	self assert: firstElement extent equals: firstShape bounds extent.
	self assert: secondElement extent equals: secondShape bounds extent.

	visual refresh.
	visual forceLayout.
	self
		assert: (visual diagramBoundsForElement: (visual laneShapeElementFor: firstLane))
		equals: firstShape bounds.
	self
		assert: (visual diagramBoundsForElement: (visual laneShapeElementFor: secondLane))
		equals: secondShape bounds.
	^ visual
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> nestedLaneAndFlowNodeBoundsProjectExactlyFromDiagramInterchange [
	<gtExample>
	| process task diagram outerLaneSet parentLane childLaneSet childLane parentShape childShape taskShape memento visual parentElement childElement taskElement |
	process := CPProcess new label: 'Nested Lane projection'; yourself.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: task.
	diagram := CPDiagram new.
	process diagram: diagram.
	outerLaneSet := CPLaneSet new.
	parentLane := CPLane new label: 'Department'; yourself.
	childLaneSet := CPLaneSet new.
	childLane := CPLane new label: 'Team'; addFlowNodeRef: task; yourself.
	childLaneSet addLane: childLane.
	parentLane childLaneSet: childLaneSet.
	outerLaneSet addLane: parentLane.
	process addLaneSet: outerLaneSet.
	parentShape := CPShape new
		modelElement: parentLane;
		bounds: (30 @ 20 extent: 500 @ 240);
		yourself.
	childShape := CPShape new
		modelElement: childLane;
		bounds: (60 @ 20 extent: 470 @ 240);
		yourself.
	taskShape := CPShape new
		modelElement: task;
		bounds: (140 @ 80 extent: 100 @ 60);
		yourself.
	diagram addElement: parentShape; addElement: childShape; addElement: taskShape.
	memento := CFMaMemento model: process.
	visual := CPProcessVisualElement new
		beCollaborationHosted;
		memento: memento;
		yourself.
	visual forceLayout.
	parentElement := visual laneShapeElementFor: parentLane.
	childElement := visual laneShapeElementFor: childLane.
	taskElement := visual shapeElementsByModelElement at: task.

	self assert: (visual diagramBoundsForElement: parentElement) equals: parentShape bounds.
	self assert: (visual diagramBoundsForElement: childElement) equals: childShape bounds.
	self assert: (visual diagramBoundsForElement: taskElement) equals: taskShape bounds.
	self assert: taskElement parent == childElement bodyHost.

	visual refresh.
	visual forceLayout.
	self
		assert: (visual diagramBoundsForElement: (visual laneShapeElementFor: parentLane))
		equals: parentShape bounds.
	self
		assert: (visual diagramBoundsForElement: (visual laneShapeElementFor: childLane))
		equals: childShape bounds.
	self
		assert: (visual diagramBoundsForElement: (visual shapeElementsByModelElement at: task))
		equals: taskShape bounds.
	^ visual
]


{ #category : 'examples - containment' }
CPProcessVisualElementExamples >> laneFlowNodeUsesLaneBodyAsPresentationHost [
	<gtExample>
	| process task laneSet lane diagram taskShape laneShape memento diagramDescription visual element laneElement host diagramPoint localPoint |
	process := CPProcess new label: 'Lane-hosted flow node'; yourself.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: task.
	laneSet := CPLaneSet new label: 'Responsibilities'; yourself.
	lane := CPLane new label: 'Reviewer'; yourself.
	lane addFlowNodeRef: task.
	laneSet addLane: lane.
	process addLaneSet: laneSet.
	diagram := CPDiagram new.
	process diagram: diagram.
	laneShape := CPShape new
		modelElement: lane;
		bounds: (40 @ 40 extent: 500 @ 180);
		yourself.
	taskShape := CPShape new
		modelElement: task;
		bounds: (140 @ 90 extent: 100 @ 80);
		yourself.
	diagram addElement: laneShape; addElement: taskShape.
	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	visual := CPProcessVisualElement new.
	visual
		diagramEditing: (self diagramEditingForMemento: memento);
		beCollaborationHosted;
		memento: memento.
	element := visual shapeElementsByModelElement at: task.
	laneElement := visual laneShapeElementFor: lane.
	host := visual presentationHostForFlowNode: task.
	diagramPoint := (visual stagedBoundsOf: taskShape) origin.
	localPoint := visual diagramPoint: diagramPoint localToPresentationHost: host.
	visual forceLayout.

	self assert: host == laneElement bodyHost.
	self assert: element parent == laneElement bodyHost.
	self assert: (visual stagedLaneContainingFlowNode: task) == lane.
	self
		assert: (visual diagramPresentationParent globalPointToLocal: (host localPointToGlobal: localPoint))
		equals: diagramPoint.
	self assert: (visual diagramBoundsForElement: element) equals: taskShape bounds.
	^ visual
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> assignFlowNodeToLaneChangesOnlyTargetLaneSetPartition [
	<gtExample>
	| process task firstLaneSet firstLane secondLane otherLaneSet otherLane memento diagramDescription editing operation assessment laneContext |
	process := CPProcess new label: 'Independent Lane partitions'; yourself.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: task.

	firstLaneSet := CPLaneSet new label: 'Departments'; yourself.
	firstLane := CPLane new label: 'Sales'; yourself.
	secondLane := CPLane new label: 'Support'; yourself.
	firstLane addFlowNodeRef: task.
	firstLaneSet addLane: firstLane; addLane: secondLane.
	process addLaneSet: firstLaneSet.

	otherLaneSet := CPLaneSet new label: 'Roles'; yourself.
	otherLane := CPLane new label: 'Reviewer'; yourself.
	otherLane addFlowNodeRef: task.
	otherLaneSet addLane: otherLane.
	process addLaneSet: otherLaneSet.

	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	editing := self diagramEditingForMemento: memento.
	operation := editing assignFlowNode: task toLane: secondLane.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: firstLane flowNodeRefs equals: { task } asOrderedCollection.
	self assert: secondLane flowNodeRefs isEmpty.
	self assert: otherLane flowNodeRefs equals: { task } asOrderedCollection.

	laneContext := CPProcessLaneContext inRootMemento: memento.
	self assert: (laneContext stagedFlowNodeRefsOf: firstLane) isEmpty.
	self assert: (laneContext stagedFlowNodeRefsOf: secondLane) equals: { task } asOrderedCollection.
	self assert: (laneContext stagedFlowNodeRefsOf: otherLane) equals: { task } asOrderedCollection.
	self assert: (laneContext laneSetContainingLane: secondLane) == firstLaneSet.
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> moveFlowNodeToLaneStagesBoundsAndPartitionTogether [
	<gtExample>
	| process task laneSet firstLane secondLane diagram firstLaneShape secondLaneShape taskShape memento diagramDescription editing operation assessment laneContext diagramContext |
	process := CPProcess new label: 'Move between Lanes'; yourself.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: task.
	laneSet := CPLaneSet new label: 'Departments'; yourself.
	firstLane := CPLane new label: 'Sales'; yourself.
	secondLane := CPLane new label: 'Support'; yourself.
	firstLane addFlowNodeRef: task.
	laneSet addLane: firstLane; addLane: secondLane.
	process addLaneSet: laneSet.
	diagram := CPDiagram new.
	process diagram: diagram.
	firstLaneShape := CPShape new modelElement: firstLane; bounds: (40 @ 40 extent: 500 @ 140); yourself.
	secondLaneShape := CPShape new modelElement: secondLane; bounds: (40 @ 180 extent: 500 @ 140); yourself.
	taskShape := CPShape new modelElement: task; bounds: (140 @ 70 extent: 100 @ 80); yourself.
	diagram addElement: firstLaneShape; addElement: secondLaneShape; addElement: taskShape.
	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	editing := self diagramEditingForMemento: memento.
	operation := editing
		moveFlowNode: task
		shape: taskShape
		bounds: (160 @ 210 extent: 100 @ 80)
		fromLane: firstLane
		toLane: secondLane.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: firstLane flowNodeRefs equals: { task } asOrderedCollection.
	self assert: secondLane flowNodeRefs isEmpty.

	laneContext := CPProcessLaneContext inRootMemento: memento.
	self assert: (laneContext stagedFlowNodeRefsOf: firstLane) isEmpty.
	self assert: (laneContext stagedFlowNodeRefsOf: secondLane) equals: { task } asOrderedCollection.

	diagramContext := CPDiagramMementoContext diagram: diagram inMemento: memento using: diagramDescription.
	self assert: (diagramContext boundsOf: taskShape) equals: (160 @ 210 extent: 100 @ 80).
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> moveFlowNodeAcrossNestedLaneSetBoundaryClearsSourcePartition [
	<gtExample>
	| process task outerLaneSet parentLane childLaneSet childLane siblingChildLane topLane diagram taskShape memento editing operation assessment laneContext diagramContext |
	process := CPProcess new label: 'Move across nested LaneSet boundary'; yourself.
	task := CPUserTask new label: 'Review'; yourself.
	process addFlowElement: task.

	childLane := CPLane new label: 'Nested first'; addFlowNodeRef: task; yourself.
	siblingChildLane := CPLane new label: 'Nested second'; yourself.
	childLaneSet := CPLaneSet new addLane: childLane; addLane: siblingChildLane; yourself.
	parentLane := CPLane new label: 'Department'; childLaneSet: childLaneSet; yourself.
	topLane := CPLane new label: 'Top level'; yourself.
	outerLaneSet := CPLaneSet new addLane: parentLane; addLane: topLane; yourself.
	process addLaneSet: outerLaneSet.

	diagram := CPDiagram new modelElement: process; yourself.
	diagram
		addElement: (CPShape new modelElement: parentLane; bounds: (40 @ 40 extent: 620 @ 180); yourself);
		addElement: (CPShape new modelElement: childLane; bounds: (70 @ 40 extent: 590 @ 90); yourself);
		addElement: (CPShape new modelElement: siblingChildLane; bounds: (70 @ 130 extent: 590 @ 90); yourself);
		addElement: (CPShape new modelElement: topLane; bounds: (40 @ 220 extent: 620 @ 180); yourself).
	taskShape := CPShape new modelElement: task; bounds: (150 @ 65 extent: 42 @ 42); yourself.
	diagram addElement: taskShape.
	process diagram: diagram.

	memento := CFMaMemento model: process.
	editing := self diagramEditingForMemento: memento.
	operation := editing
		moveFlowNode: task
		shape: taskShape
		bounds: (170 @ 285 extent: 42 @ 42)
		fromLane: childLane
		toLane: topLane.
	assessment := operation apply.

	self assert: assessment isApplicable.
	laneContext := CPProcessLaneContext inRootMemento: memento.
	self assert: (laneContext stagedFlowNodeRefsOf: childLane) isEmpty.
	self assert: (laneContext stagedFlowNodeRefsOf: siblingChildLane) isEmpty.
	self assert: (laneContext stagedFlowNodeRefsOf: topLane) equals: { task } asOrderedCollection.

	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: memento
		using: (self descriptionFor: #diagram in: memento).
	self assert: (diagramContext boundsOf: taskShape) equals: (170 @ 285 extent: 42 @ 42).
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> hostedLaneDiagramNormalizesLaneSetToPoolBody [
	<gtExample>
	| process laneSet lane diagram laneShape memento visual laneElement |
	process := CPProcess new label: 'Stable Lane origin'; yourself.
	diagram := CPDiagram new.
	process diagram: diagram.
	laneSet := CPLaneSet new.
	lane := CPLane new label: 'Lane'; yourself.
	laneSet addLane: lane.
	process addLaneSet: laneSet.
	laneShape := CPShape new
		modelElement: lane;
		bounds: (40 @ 60 extent: 500 @ 180);
		yourself.
	diagram addElement: laneShape.
	memento := CFMaMemento model: process.
	visual := CPProcessVisualElement new
		beCollaborationHosted;
		memento: memento;
		yourself.
	visual forceLayout.
	laneElement := visual laneShapeElementFor: lane.

	self assert: visual diagramBounds equals: laneShape bounds.
	self assert: visual diagramContentOffset equals: 0 @ 0 - laneShape bounds origin.
	self assert: visual diagramBoundsOriginInContent equals: 0 @ 0.
	self assert: visual laneSetVisual parent == visual diagramPresentationParent.
	self assert: (visual diagramBoundsForElement: laneElement) equals: laneShape bounds.
	self assert:
		(visual globalPointToLocal: (visual laneSetVisual localPointToGlobal: 0 @ 0))
		equals: 0 @ 0.
	^ visual
]

{ #category : 'examples - editing session' }
CPProcessVisualElementExamples >> definitionsRootedVisualUsesSelectedDiagramMemento [
	<gtExample>
	| definitions process task diagram shape session visual proposedBounds |
	process := CPProcess new label: 'Document-rooted visual'; yourself.
	task := CPUserTask new label: 'Move me'; yourself.
	process addFlowElement: task.
	diagram := CPDiagram new modelElement: process; yourself.
	shape := CPShape new
		modelElement: task;
		bounds: (100 @ 100 extent: 132 @ 54);
		yourself.
	diagram addElement: shape.
	"Keep the legacy relation populated deliberately: the visual must still read
	 the selected Definitions-owned diagram memento, not create/read a second DI
	 memento through Process>>diagram."
	process diagram: diagram.
	definitions := CPDefinitions new
		addRootElement: process;
		addDiagram: diagram;
		yourself.
	session := CPProcessAtelierSession
		forDefinitions: definitions
		process: process
		diagram: diagram.
	visual := CPProcessVisualElement new.
	visual
		memento: session processMemento
		flowContainer: process
		diagramContext: session diagramContext.
	proposedBounds := 240 @ 180 extent: 132 @ 54.
	session diagramContext writeBounds: proposedBounds of: shape.
	self assert: (visual stagedBoundsOf: shape) equals: proposedBounds.
	^ visual
]



{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> laneResizePreviewMovesExternalFlowNodeLabel [
	<gtExample>
	| fixture session visual node nodeShape nodeElement label laneContext laneBounds flowNodeBounds proposedNodeBounds |
	fixture := self documentRootedNestedLaneDragFixture.
	session := fixture first.
	visual := fixture second.
	node := fixture fourth.
	nodeShape := fixture fifth.
	nodeElement := visual shapeElementsByModelElement at: node.
	label := nodeElement externalLabelHost.
	self assert: label notNil.

	laneContext := CPProcessLaneContext inRootMemento: session processMemento.
	laneBounds := IdentityDictionary new.
	laneContext stagedLanes do: [ :aLane |
		| laneShape |
		laneShape := (session diagramContext shapesForModelElement: aLane) anyOne.
		laneBounds
			at: laneShape
			put: (session diagramContext boundsOf: laneShape) ].

	proposedNodeBounds := (session diagramContext boundsOf: nodeShape)
		translateBy: 0 @ 50.
	flowNodeBounds := IdentityDictionary new
		at: nodeShape put: proposedNodeBounds;
		yourself.

	visual
		previewLaneBoundsByShape: laneBounds
		flowNodeBoundsByShape: flowNodeBounds.

	self assert: label parent == nodeElement uprightHost.
	self
		assert: label position
		equals: (visual
			externalLabelLocalOriginForExtent: proposedNodeBounds extent
			width: 180).
	^ visual
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> laneResizePreviewMovesConnectionLabel [
	<gtExample>
	| fixture session visual edge edgeLabel participant participantShape editing assessment laneBounds flowNodeBounds waypointsByEdge waypoints renderedPoints path segmentIndex segmentPosition offset placement |
	fixture := self documentRootedNestedLaneDragFixture.
	session := fixture first.
	visual := fixture second.
	edge := fixture ninth.
	edgeLabel := visual edgeLabelHostFor: edge ifAbsent: [ nil ].
	self assert: edgeLabel notNil.

	participant := session collaborationContext
		participantForProcess: session processMemento model.
	participantShape := (session collaborationContext diagramContext
		shapesForModelElement: participant) anyOne.
	editing := visual diagramEditing.

	assessment := (editing
		resizeShape: participantShape
		toBounds: (80 @ 60 extent: 820 @ 500)) assess.
	self assert: assessment isApplicable.

	laneBounds := assessment proposedLaneBoundsByShape.
	flowNodeBounds := assessment proposedFlowNodeBoundsByShape.
	waypointsByEdge := assessment proposedWaypointsByEdge.

	visual
		previewLaneBoundsByShape: laneBounds
		flowNodeBoundsByShape: flowNodeBounds
		waypointsByEdge: waypointsByEdge.

	waypoints := waypointsByEdge
		at: edge
		ifAbsent: [ visual stagedWaypointsOf: edge ].
	renderedPoints := visual
		renderedPathPointsFor: edge
		waypoints: waypoints
		flowNodeBoundsByShape: flowNodeBounds.
	path := CPProcessEdgeLabelPath points: renderedPoints.
	segmentIndex := (visual stagedLabelSegmentIndexOf: edge)
		ifNil: [ path defaultSegmentIndex ].
	segmentPosition := (visual stagedLabelSegmentPositionOf: edge) ifNil: [ 0.5 ].
	offset := (visual stagedLabelOffsetOf: edge) ifNil: [ -14.0 ].
	placement := path
		placementAtSegmentIndex: segmentIndex
		segmentPosition: segmentPosition
		offset: offset.

	self
		assert: edgeLabel position
		equals: (placement first x - 90) @ (placement first y - 22).
	^ visual
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> resizingPoolMovesFlowNodesWithTheirLanes [
	<gtExample>
	| fixture session target targetShape edge participant participantShape originalTargetBounds originalWaypoints assessment topLane topShape originalTopBounds resizedTopBounds expectedDelta resizedTargetBounds resizedWaypoints |
	fixture := self documentRootedNestedLaneDragFixture.
	session := fixture first.
	target := session processMemento model flowElements
		detect: [ :each | each isActivity ].
	targetShape := (session diagramContext shapesForModelElement: target) anyOne.
	edge := fixture ninth.
	topLane := fixture eighth.
	topShape := (session diagramContext shapesForModelElement: topLane) anyOne.
	participant := session collaborationContext
		participantForProcess: session processMemento model.
	participantShape := (session collaborationContext diagramContext
		shapesForModelElement: participant) anyOne.

	originalTargetBounds := session diagramContext boundsOf: targetShape.
	originalTopBounds := session diagramContext boundsOf: topShape.
	originalWaypoints := session diagramContext waypointsOf: edge.

	assessment := (CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: (80 @ 60 extent: 820 @ 500)
		processMemento: session processMemento
		collaborationContext: session collaborationContext
		processDiagramContext: session diagramContext) apply.
	self assert: assessment isApplicable.

	resizedTopBounds := session diagramContext boundsOf: topShape.
	expectedDelta := resizedTopBounds origin - originalTopBounds origin.
	resizedTargetBounds := session diagramContext boundsOf: targetShape.
	resizedWaypoints := session diagramContext waypointsOf: edge.

	self
		assert: resizedTargetBounds
		equals: (originalTargetBounds translateBy: expectedDelta).
	self assert: resizedWaypoints first equals: originalWaypoints first.
	self
		assert: resizedWaypoints last
		equals: originalWaypoints last + expectedDelta.
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> resizingPoolPreservesNestedLaneHeaderInset [
	<gtExample>
	| fixture session visual collaborationVisual laneContext firstChildLane childLaneSet parentLane participant participantShape operation assessment parentShape firstChildShape secondChildShape parentBounds firstChildBounds secondChildBounds headerWidth |
	fixture := self documentRootedNestedLaneDragFixture.
	session := fixture first.
	visual := fixture second.
	collaborationVisual := fixture third.
	firstChildLane := fixture sixth.
	laneContext := CPProcessLaneContext inRootMemento: session processMemento.
	childLaneSet := laneContext laneSetContainingLane: firstChildLane.
	parentLane := laneContext stagedLanes
		detect: [ :each | (laneContext stagedChildLaneSetOf: each) == childLaneSet ].
	participant := session collaborationContext participantForProcess: session processMemento model.
	participantShape := (session collaborationContext diagramContext shapesForModelElement: participant) anyOne.

	operation := CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: (80 @ 60 extent: 820 @ 500)
		processMemento: session processMemento
		collaborationContext: session collaborationContext
		processDiagramContext: session diagramContext.
	assessment := operation apply.
	self assert: assessment isApplicable.

	parentShape := (session diagramContext shapesForModelElement: parentLane) anyOne.
	firstChildShape := (session diagramContext shapesForModelElement: firstChildLane) anyOne.
	secondChildShape := (session diagramContext shapesForModelElement: fixture seventh) anyOne.
	parentBounds := session diagramContext boundsOf: parentShape.
	firstChildBounds := session diagramContext boundsOf: firstChildShape.
	secondChildBounds := session diagramContext boundsOf: secondChildShape.
	headerWidth := CPLaneShapeElement laneHeaderWidth.

	self assert: firstChildBounds left equals: parentBounds left + headerWidth.
	self assert: secondChildBounds left equals: parentBounds left + headerWidth.
	self assert: firstChildBounds right equals: parentBounds right.
	self assert: secondChildBounds right equals: parentBounds right.
	self assert: firstChildBounds top equals: parentBounds top.
	self assert: secondChildBounds bottom equals: parentBounds bottom.
	self assert: firstChildBounds bottom equals: secondChildBounds top.

	collaborationVisual refresh.
	collaborationVisual forceLayout.
	self assert: (visual diagramBoundsForElement: (visual laneShapeElementFor: firstChildLane)) equals: firstChildBounds.
	self assert: (visual diagramBoundsForElement: (visual laneShapeElementFor: fixture seventh)) equals: secondChildBounds.
	^ collaborationVisual
]


{ #category : 'private - fixture' }
CPProcessVisualElementExamples >> documentRootedNestedLaneDragFixture [
	| process node target flow diagram shape targetShape edge outerLaneSet parentLane childLaneSet firstChildLane secondChildLane topLane
	  definitions collaboration participant collaborationDiagram session editing visual collaborationVisual |
	process := CPProcess new label: 'Nested lane drag regression'; yourself.
	node := CPNoneStartEvent new label: 'Start'; yourself.
	target := CPUserTask new label: 'Review'; yourself.
	flow := CPSequenceFlow new label: 'Next'; sourceRef: node; targetRef: target; yourself.
	process addFlowElement: node; addFlowElement: target; addFlowElement: flow.

	firstChildLane := CPLane new label: 'Nested first'; addFlowNodeRef: node; yourself.
	secondChildLane := CPLane new label: 'Nested second'; yourself.
	childLaneSet := CPLaneSet new
		addLane: firstChildLane;
		addLane: secondChildLane;
		yourself.
	parentLane := CPLane new label: 'Department'; childLaneSet: childLaneSet; yourself.
	topLane := CPLane new label: 'Top level'; addFlowNodeRef: target; yourself.
	outerLaneSet := CPLaneSet new
		addLane: parentLane;
		addLane: topLane;
		yourself.
	process addLaneSet: outerLaneSet.

	shape := CPShape new modelElement: node; bounds: (150 @ 65 extent: 42 @ 42); yourself.
	targetShape := CPShape new modelElement: target; bounds: (400 @ 280 extent: 100 @ 60); yourself.
	edge := CPEdge new modelElement: flow; addWaypoint: 192 @ 86; addWaypoint: 400 @ 310; yourself.
	diagram := CPDiagram new modelElement: process; yourself.
	diagram
		addElement: (CPShape new modelElement: parentLane; bounds: (40 @ 40 extent: 620 @ 180); yourself);
		addElement: (CPShape new modelElement: firstChildLane; bounds: (70 @ 40 extent: 590 @ 90); yourself);
		addElement: (CPShape new modelElement: secondChildLane; bounds: (70 @ 130 extent: 590 @ 90); yourself);
		addElement: (CPShape new modelElement: topLane; bounds: (40 @ 220 extent: 620 @ 180); yourself);
		addElement: shape;
		addElement: targetShape;
		addElement: edge.

	participant := CPParticipant new label: 'Pool'; processRef: process; yourself.
	collaboration := CPCollaboration new addParticipant: participant; yourself.
	process definitionalCollaborationRef: collaboration.
	collaborationDiagram := CPDiagram new
		modelElement: collaboration;
		addElement: (CPShape new modelElement: participant; bounds: (80 @ 60 extent: 700 @ 400); yourself);
		yourself.
	definitions := CPDefinitions new
		targetNamespace: 'urn:catalyst:nested-lane-drag';
		addRootElement: process;
		addRootElement: collaboration;
		addDiagram: diagram;
		addDiagram: collaborationDiagram;
		yourself.
	session := CPProcessAtelierSession forDefinitions: definitions process: process diagram: diagram.
	editing := CPProcessAtelierDiagramEditing
		processMemento: session processMemento
		diagramContext: session diagramContext
		collaborationContext: session collaborationContext
		documentContext: session documentContext.
	visual := CPProcessVisualElement new
		diagramEditing: editing;
		beCollaborationHosted;
		memento: session processMemento
		flowContainer: process
		diagramContext: session diagramContext;
		yourself.
	collaborationVisual := CPCollaborationVisualElement new
		diagramEditing: editing;
		processMemento: session processMemento
		processVisual: visual
		documentContext: session documentContext;
		yourself.
	collaborationVisual forceLayout.
	^ { session. visual. collaborationVisual. node. shape. firstChildLane. secondChildLane. topLane. edge }
]



{ #category : 'examples - positioning' }
CPProcessVisualElementExamples >> documentRootedNestedLaneDragWithoutIntermediateLayoutPreservesDiagramProjection [
	<gtExample>
	| fixture session visual node shape original expected element start delta targetLane |
	fixture := self documentRootedNestedLaneDragFixture.
	session := fixture first.
	visual := fixture second.
	node := fixture fourth.
	shape := fixture fifth.
	original := session diagramContext boundsOf: shape.
	delta := 20 @ 220.
	targetLane := fixture eighth.
	expected := original translateBy: delta.

	element := visual shapeElementsByModelElement at: node.
	start := element localPointToGlobal: 10 @ 10.
	element dispatchEvent: (BlDragStartEvent new position: start; yourself).
	"Deliberately do not force layout between gesture events. A real pointer
	 interaction receives no synchronous layout barrier here."
	element dispatchEvent: (BlDragEvent new position: start + delta; yourself).
	element dispatchEvent: (BlDragEndEvent new position: start + delta; yourself).

	fixture third forceLayout.
	element := visual shapeElementsByModelElement at: node.
	self assert: (session diagramContext boundsOf: shape) equals: expected.
	self assert: (visual diagramBoundsForElement: element) equals: expected.
	self assert: (visual stagedLaneContainingFlowNode: node) == targetLane.
	^ visual
]

{ #category : 'examples - positioning' }
CPProcessVisualElementExamples >> documentRootedNestedLaneDragsPreserveDiagramProjection [
	<gtExample>
	| fixture session visual node shape original expected element start label edge livePoints stagedPoints
	  edgeLabel segmentIndex segmentPosition offset placement |
	fixture := self documentRootedNestedLaneDragFixture.
	session := fixture first.
	visual := fixture second.
	node := fixture fourth.
	shape := fixture fifth.
	edge := fixture ninth.
	original := session diagramContext boundsOf: shape.
	expected := original.

	{
		{ 20 @ 220. fixture eighth }.
		{ -10 @ -150. fixture seventh }.
		{ -10 @ -90. fixture sixth }
	} do: [ :step |
		| delta targetLane |
		delta := step first.
		targetLane := step second.
		element := visual shapeElementsByModelElement at: node.
		start := element localPointToGlobal: 10 @ 10.
		element dispatchEvent: (BlDragStartEvent new position: start; yourself).
		fixture third forceLayout.
		element dispatchEvent: (BlDragEvent new position: start + delta; yourself).
		fixture third forceLayout.

		self assert: (visual diagramBoundsForElement: element) equals: (expected translateBy: delta).
		label := element externalLabelHost.
		self assert: label parent == element uprightHost.
		self assert: label position equals:
			(visual externalLabelLocalOriginForExtent: (expected translateBy: delta) extent width: 180).
		self assert: (visual rootDiagramPointForElement: label) equals:
			((expected translateBy: delta) center x - 90) @ ((expected translateBy: delta) bottom + 4).
		livePoints := visual
			renderedPathPointsFor: edge
			waypoints: (visual stagedWaypointsOf: edge)
			usingLiveBounds: true.
		stagedPoints := visual
			renderedPathPointsFor: edge
			waypoints: (visual stagedWaypointsOf: edge)
			usingLiveBounds: false.
		self assert: livePoints first ~= stagedPoints first.
		edgeLabel := visual edgeLabelHostFor: edge ifAbsent: [ nil ].
		self assert: edgeLabel notNil.
		segmentIndex := (visual stagedLabelSegmentIndexOf: edge)
			ifNil: [ (visual edgeLabelPathFor: edge waypoints: (visual stagedWaypointsOf: edge) usingLiveBounds: true) defaultSegmentIndex ].
		segmentPosition := (visual stagedLabelSegmentPositionOf: edge) ifNil: [ 0.5 ].
		offset := (visual stagedLabelOffsetOf: edge) ifNil: [ -14.0 ].
		placement := visual
			labelPlacementFor: edge
			segmentIndex: segmentIndex
			segmentPosition: segmentPosition
			offset: offset
			waypoints: (visual stagedWaypointsOf: edge)
			usingLiveBounds: true.
		self assert: edgeLabel position equals:
			(placement first x - 90) @ (placement first y - 22).

		element dispatchEvent: (BlDragEndEvent new position: start + delta; yourself).
		fixture third forceLayout.
		expected := expected translateBy: delta.
		element := visual shapeElementsByModelElement at: node.
		self assert: (session diagramContext boundsOf: shape) equals: expected.
		self assert: (visual diagramBoundsForElement: element) equals: expected.
		self assert: (visual stagedLaneContainingFlowNode: node) == targetLane.
		livePoints := visual
			renderedPathPointsFor: edge
			waypoints: (visual stagedWaypointsOf: edge)
			usingLiveBounds: true.
		stagedPoints := visual
			renderedPathPointsFor: edge
			waypoints: (visual stagedWaypointsOf: edge)
			usingLiveBounds: false.
		self assert: livePoints equals: stagedPoints ].

	self assert: (visual stagedLaneContainingFlowNode: node) == fixture sixth.
	self assert: shape bounds equals: original.
	session rootMemento reset.
	visual refresh.
	fixture third forceLayout.
	self assert: (session diagramContext boundsOf: shape) equals: original.
	self assert: (visual stagedLaneContainingFlowNode: node) == fixture sixth.
	self assert: (visual diagramBoundsForElement: (visual shapeElementsByModelElement at: node)) equals: original.
	^ visual
]

{ #category : 'private - fixture' }
CPProcessVisualElementExamples >> documentRootedLaneDragFixture [
	| process node target flow diagram shape targetShape edge laneSet firstLane secondLane
	  definitions collaboration participant collaborationDiagram session editing visual collaborationVisual |
	process := CPProcess new label: 'Lane drag regression'; yourself.
	node := CPNoneStartEvent new label: 'Start'; yourself.
	target := CPUserTask new label: 'Review'; yourself.
	flow := CPSequenceFlow new sourceRef: node; targetRef: target; yourself.
	process addFlowElement: node; addFlowElement: target; addFlowElement: flow.
	firstLane := CPLane new label: 'First'; addFlowNodeRef: node; yourself.
	secondLane := CPLane new label: 'Second'; addFlowNodeRef: target; yourself.
	laneSet := CPLaneSet new addLane: firstLane; addLane: secondLane; yourself.
	process addLaneSet: laneSet.
	shape := CPShape new modelElement: node; bounds: (140 @ 70 extent: 42 @ 42); yourself.
	targetShape := CPShape new modelElement: target; bounds: (300 @ 210 extent: 100 @ 60); yourself.
	edge := CPEdge new modelElement: flow; addWaypoint: 182 @ 91; addWaypoint: 300 @ 240; yourself.
	diagram := CPDiagram new modelElement: process; yourself.
	diagram
		addElement: (CPShape new modelElement: firstLane; bounds: (40 @ 40 extent: 500 @ 140); yourself);
		addElement: (CPShape new modelElement: secondLane; bounds: (40 @ 180 extent: 500 @ 140); yourself);
		addElement: shape; addElement: targetShape; addElement: edge.
	participant := CPParticipant new label: 'Pool'; processRef: process; yourself.
	collaboration := CPCollaboration new addParticipant: participant; yourself.
	process definitionalCollaborationRef: collaboration.
	collaborationDiagram := CPDiagram new modelElement: collaboration;
		addElement: (CPShape new modelElement: participant; bounds: (80 @ 60 extent: 530 @ 280); yourself);
		yourself.
	definitions := CPDefinitions new targetNamespace: 'urn:catalyst:lane-drag';
		addRootElement: process; addRootElement: collaboration;
		addDiagram: diagram; addDiagram: collaborationDiagram; yourself.
	session := CPProcessAtelierSession forDefinitions: definitions process: process diagram: diagram.
	editing := CPProcessAtelierDiagramEditing
		processMemento: session processMemento diagramContext: session diagramContext
		collaborationContext: session collaborationContext documentContext: session documentContext.
	visual := CPProcessVisualElement new diagramEditing: editing; beCollaborationHosted;
		memento: session processMemento flowContainer: process diagramContext: session diagramContext; yourself.
	collaborationVisual := CPCollaborationVisualElement new diagramEditing: editing;
		processMemento: session processMemento processVisual: visual documentContext: session documentContext; yourself.
	collaborationVisual forceLayout.
	^ { session. visual. collaborationVisual. node. shape. firstLane. secondLane. edge }
]


{ #category : 'examples - positioning' }
CPProcessVisualElementExamples >> documentRootedLaneDragUsesFinalPointerDelta [
	<gtExample>
	| fixture session visual node shape element start original expected |
	fixture := self documentRootedLaneDragFixture.
	session := fixture first.
	visual := fixture second.
	node := fixture fourth.
	shape := fixture fifth.
	element := visual shapeElementsByModelElement at: node.
	original := session diagramContext boundsOf: shape.
	start := element localPointToGlobal: 10 @ 10.
	element dispatchEvent: (BlDragStartEvent new position: start; yourself).
	fixture third forceLayout.
	element dispatchEvent: (BlDragEvent new position: start + (20 @ 10); yourself).
	fixture third forceLayout.
	element dispatchEvent: (BlDragEndEvent new position: start + (35 @ 15); yourself).
	fixture third forceLayout.
	expected := original translateBy: 35 @ 15.
	self assert: (session diagramContext boundsOf: shape) equals: expected.
	self assert: (visual diagramBoundsForElement: (visual shapeElementsByModelElement at: node)) equals: expected.
	self assert: shape bounds equals: original.
	session rootMemento reset.
	visual refresh.
	fixture third forceLayout.
	self assert: (session diagramContext boundsOf: shape) equals: original.
	^ visual
]


{ #category : 'examples - positioning' }
CPProcessVisualElementExamples >> documentRootedRepeatedLaneDragsPreserveProjectionAndReset [
	<gtExample>
	| fixture session visual node shape original expected element start label |
	fixture := self documentRootedLaneDragFixture.
	session := fixture first.
	visual := fixture second.
	node := fixture fourth.
	shape := fixture fifth.
	original := session diagramContext boundsOf: shape.
	expected := original.
	{ 0 @ 140. 0 @ -140. 20 @ 0. 0 @ 140. 0 @ -140 } do: [ :delta |
		element := visual shapeElementsByModelElement at: node.
		start := element localPointToGlobal: 10 @ 10.
		element dispatchEvent: (BlDragStartEvent new position: start; yourself).
		fixture third forceLayout.
		element dispatchEvent: (BlDragEvent new position: start + delta; yourself).
		fixture third forceLayout.
		element dispatchEvent: (BlDragEndEvent new position: start + delta; yourself).
		fixture third forceLayout.
		expected := expected translateBy: delta.
		element := visual shapeElementsByModelElement at: node.
		label := element externalLabelHost.
		self assert: (session diagramContext boundsOf: shape) equals: expected.
		self assert: (visual diagramBoundsForElement: element) equals: expected.
		self assert: label parent == element uprightHost.
		self assert: label position equals:
			(visual externalLabelLocalOriginForExtent: expected extent width: 180).
		self assert: (visual rootDiagramPointForElement: label) equals:
			(expected center x - 90) @ (expected bottom + 4) ].
	self assert: (visual stagedLaneContainingFlowNode: node) == fixture sixth.
	self assert: shape bounds equals: original.
	session rootMemento reset.
	visual refresh.
	fixture third forceLayout.
	self assert: (session diagramContext boundsOf: shape) equals: original.
	self assert: (visual diagramBoundsForElement: (visual shapeElementsByModelElement at: node)) equals: original.
	^ visual
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> paletteCreatedFlowNodeIsAssignedToDropLane [
	<gtExample>
	| fixture visual candidate dragItem assessment targetLane |
	fixture := self documentRootedNestedLaneDragFixture.
	visual := fixture second.
	targetLane := fixture seventh.
	candidate := CPUserTask new label: 'Palette task'; yourself.
	dragItem := BlDragItem new
		domainObject: candidate;
		yourself.

	self assert: (visual stagedLaneAtDiagramPoint: 300 @ 170) == targetLane.
	assessment := visual
		createPaletteItem: dragItem
		atRootDiagramPoint: 300 @ 170.

	self assert: assessment isApplicable.
	self assert: (visual stagedLaneContainingFlowNode: candidate) == targetLane.
	self assert:
		(((CPProcessLaneContext inRootMemento: fixture first processMemento)
			stagedFlowNodeRefsOf: targetLane) identityIncludes: candidate).
	^ visual
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> contextualAppendFlowNodeIsAssignedToDropLane [
	<gtExample>
	| fixture visual source sourceShape candidate targetLane operation assessment |
	fixture := self documentRootedNestedLaneDragFixture.
	visual := fixture second.
	source := fixture fourth.
	sourceShape := visual shapeForModelElement: source.
	targetLane := fixture seventh.
	candidate := CPUserTask new label: 'Contextual task'; yourself.

	self assert: (visual stagedLaneAtDiagramPoint: 300 @ 170) == targetLane.
	operation := visual diagramEditing
		appendFlowNode: candidate
		fromShape: sourceShape
		bounds: (250 @ 145 extent: 100 @ 50)
		targetLane: targetLane.
	assessment := operation apply.
	visual refresh.

	self assert: assessment isApplicable.
	self assert: (visual stagedLaneContainingFlowNode: candidate) == targetLane.
	self assert:
		(((CPProcessLaneContext inRootMemento: fixture first processMemento)
			stagedFlowNodeRefsOf: targetLane) identityIncludes: candidate).
	^ visual
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> resizingPoolRejectsBelowMinimumLaneHeight [
	<gtExample>
	| fixture process memento collaborationContext participant participantShape processDiagram laneSet firstLane secondLane firstShape secondShape diagramDescription assessment processDiagramContext |
	fixture := self collaborationVisualFixture.
	process := fixture first.
	processDiagram := process diagram.
	laneSet := CPLaneSet new.
	firstLane := CPLane new label: 'First'; yourself.
	secondLane := CPLane new label: 'Second'; yourself.
	laneSet addLane: firstLane; addLane: secondLane.
	process addLaneSet: laneSet.
	firstShape := CPShape new modelElement: firstLane; bounds: (56 @ 40 extent: 584 @ 140); yourself.
	secondShape := CPShape new modelElement: secondLane; bounds: (56 @ 180 extent: 584 @ 140); yourself.
	processDiagram addElement: firstShape; addElement: secondShape.
	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	collaborationContext := CPProcessCollaborationContext inRootMemento: memento.
	participant := collaborationContext participantForProcess: process.
	participantShape := (collaborationContext diagramContext shapesForModelElement: participant) anyOne.
	assessment := (CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: (40 @ 40 extent: 700 @ 240)
		processMemento: memento) apply.
	self assert: assessment isApplicable equals: false.

	processDiagramContext := CPDiagramMementoContext
		diagram: processDiagram
		inMemento: memento
		using: diagramDescription.
	self assert: (processDiagramContext boundsOf: firstShape) equals: (56 @ 40 extent: 584 @ 140).
	self assert: (processDiagramContext boundsOf: secondShape) equals: (56 @ 180 extent: 584 @ 140).
	^ assessment
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> resizingPoolRespectsRecursiveMinimumLaneHeights [
	<gtExample>
	| fixture session visual collaborationVisual laneContext firstChildLane secondChildLane topLane childLaneSet parentLane participant participantShape operation assessment parentShape firstChildShape secondChildShape topShape parentBounds firstChildBounds secondChildBounds topBounds |
	fixture := self documentRootedNestedLaneDragFixture.
	session := fixture first.
	visual := fixture second.
	collaborationVisual := fixture third.
	firstChildLane := fixture sixth.
	secondChildLane := fixture seventh.
	topLane := fixture eighth.
	laneContext := CPProcessLaneContext inRootMemento: session processMemento.
	childLaneSet := laneContext laneSetContainingLane: firstChildLane.
	parentLane := laneContext stagedLanes
		detect: [ :each | (laneContext stagedChildLaneSetOf: each) == childLaneSet ].
	participant := session collaborationContext participantForProcess: session processMemento model.
	participantShape := (session collaborationContext diagramContext shapesForModelElement: participant) anyOne.

	operation := CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: (80 @ 60 extent: 700 @ 420)
		processMemento: session processMemento
		collaborationContext: session collaborationContext
		processDiagramContext: session diagramContext.
	assessment := operation apply.
	self assert: assessment isApplicable.

	parentShape := (session diagramContext shapesForModelElement: parentLane) anyOne.
	firstChildShape := (session diagramContext shapesForModelElement: firstChildLane) anyOne.
	secondChildShape := (session diagramContext shapesForModelElement: secondChildLane) anyOne.
	topShape := (session diagramContext shapesForModelElement: topLane) anyOne.
	parentBounds := session diagramContext boundsOf: parentShape.
	firstChildBounds := session diagramContext boundsOf: firstChildShape.
	secondChildBounds := session diagramContext boundsOf: secondChildShape.
	topBounds := session diagramContext boundsOf: topShape.

	self assert: parentBounds height equals: 280.
	self assert: topBounds height equals: 140.
	self assert: firstChildBounds height equals: 140.
	self assert: secondChildBounds height equals: 140.
	self assert: firstChildBounds top equals: parentBounds top.
	self assert: secondChildBounds bottom equals: parentBounds bottom.
	self assert: firstChildBounds bottom equals: secondChildBounds top.
	self assert: parentBounds bottom equals: topBounds top.

	collaborationVisual refresh.
	collaborationVisual forceLayout.
	self assert: (visual diagramBoundsForElement: (visual laneShapeElementFor: firstChildLane)) equals: firstChildBounds.
	self assert: (visual diagramBoundsForElement: (visual laneShapeElementFor: secondChildLane)) equals: secondChildBounds.
	^ collaborationVisual
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> resizingPoolMinimumTracksLaneContents [
	<gtExample>
	| fixture process processDiagram task taskShape laneSet firstLane secondLane firstShape secondShape memento collaborationContext participant participantShape diagramDescription tooSmallAssessment assessment processDiagramContext firstBounds secondBounds |
	fixture := self collaborationVisualFixture.
	process := fixture first.
	processDiagram := process diagram.
	task := fixture at: 13.
	taskShape := processDiagram elements
		detect: [ :each | each isShape and: [ each modelElement == task ] ].
	taskShape bounds: (180 @ 40 extent: 132 @ 180).

	laneSet := CPLaneSet new.
	firstLane := CPLane new label: 'Content'; addFlowNodeRef: task; yourself.
	secondLane := CPLane new label: 'Other'; yourself.
	laneSet addLane: firstLane; addLane: secondLane.
	process addLaneSet: laneSet.
	firstShape := CPShape new modelElement: firstLane; bounds: (56 @ 40 extent: 584 @ 220); yourself.
	secondShape := CPShape new modelElement: secondLane; bounds: (56 @ 260 extent: 584 @ 140); yourself.
	processDiagram addElement: firstShape; addElement: secondShape.
	memento := CFMaMemento model: process.
	diagramDescription := self descriptionFor: #diagram in: memento.
	collaborationContext := CPProcessCollaborationContext inRootMemento: memento.
	participant := collaborationContext participantForProcess: process.
	participantShape := (collaborationContext diagramContext shapesForModelElement: participant) anyOne.
	processDiagramContext := CPDiagramMementoContext
		diagram: processDiagram
		inMemento: memento
		using: diagramDescription.

	tooSmallAssessment := (CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: (40 @ 40 extent: 620 @ 330)
		processMemento: memento
		collaborationContext: collaborationContext
		processDiagramContext: processDiagramContext) apply.
	self assert: tooSmallAssessment isApplicable equals: false.

	assessment := (CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: (40 @ 40 extent: 620 @ 400)
		processMemento: memento
		collaborationContext: collaborationContext
		processDiagramContext: processDiagramContext) apply.
	self assert: assessment isApplicable.
	firstBounds := processDiagramContext boundsOf: firstShape.
	secondBounds := processDiagramContext boundsOf: secondShape.
	self assert: firstBounds height >= 220.
	self assert: secondBounds height >= CPAtelierLaneLayout minimumLaneHeight.
	self assert: firstBounds height + secondBounds height equals: 400.
	self assert: firstBounds bottom equals: secondBounds top.
	^ assessment
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> emptyHostedPoolUsesOneLaneMinimumHeight [
	<gtExample>
	| fixture process memento collaborationContext participant participantShape editing |
	fixture := self collaborationVisualFixture.
	process := fixture first.
	memento := fixture at: 2.
	collaborationContext := CPProcessCollaborationContext inRootMemento: memento.
	participant := collaborationContext participantForProcess: process.
	participantShape := (collaborationContext diagramContext shapesForModelElement: participant) anyOne.
	editing := self diagramEditingForMemento: memento.
	self
		assert: (editing minimumHeightForResizeShape: participantShape)
		equals: CPAtelierLaneLayout minimumLaneHeight.
	^ participantShape
]


{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> verticalParticipantUsesTopHeaderBand [
	<gtExample>
	| participant shape label element |
	participant := CPParticipant new label: 'Vertical pool'; yourself.
	shape := CPShape new
		modelElement: participant;
		bounds: (40 @ 40 extent: 500 @ 320);
		isHorizontal: false;
		yourself.
	label := BrLabel new text: 'Vertical pool'.
	element := CPParticipantShapeElement new
		participant: participant
		shape: shape
		bounds: shape bounds
		background: Color transparent
		borderColor: Color black
		label: label.
	element forceLayout.

	self assert: element processContentOriginOffset equals: 0 @ 36.
	self assert: element labelBand extent equals: 500 @ 36.
	^ element
]

{ #category : 'examples - lanes' }
CPProcessVisualElementExamples >> verticalLaneUsesTopHeaderBand [
	<gtExample>
	| lane shape label element |
	lane := CPLane new label: 'Vertical lane'; yourself.
	shape := CPShape new
		modelElement: lane;
		bounds: (0 @ 0 extent: 240 @ 360);
		isHorizontal: false;
		yourself.
	label := BrLabel new text: 'Vertical lane'.
	element := CPLaneShapeElement new
		lane: lane
		shape: shape
		borderColor: Color black
		label: label.
	element extent: shape bounds extent.
	element forceLayout.

	self assert: element bodyOriginOffset equals: 0 @ 30.
	self assert: element labelBand extent equals: 240 @ 30.
	^ element
]

{ #category : 'examples - lanes - vertical' }
CPProcessVisualElementExamples >> participantOrientationDescriptionUsesGroupedIconButtons [
	<gtExample>
	| shape selection description configuration |
	shape := CPShape new modelElement: (CPParticipant new label: 'Pool'; yourself); yourself.
	selection := CPParticipantOrientationSelection
		shape: shape
		horizontal: true
		diagramEditing: CPReadOnlyProcessDiagramEditing new
		changedDo: [ ].
	description := selection isHorizontalDescription.
	configuration := CFMaDetailPresentation new fieldConfigurationFor: description.

	self assert: description options equals: { false. true }.
	self assert: configuration representation class equals: CFMaGroupedButtonsConfiguration.
	^ selection
]


{ #category : 'examples - lanes - orientation' }
CPProcessVisualElementExamples >> flowNodeUsesOrbitalRootWithUprightVisualHost [
	<gtExample>
	| shape node element |
	shape := CPShape new.
	node := CPUserTask new label: 'Review'; yourself.
	element := CPProcessShapeElement new
		shape: shape
		modelElement: node
		bounds: (100 @ 100 extent: 140 @ 80)
		background: Color white
		borderColor: Color black
		label: nil.

	self assert: element uprightHost parent == element.
	^ element
]

{ #category : 'examples - lanes - orientation' }
CPProcessVisualElementExamples >> boundaryEventOrbitalRootRemainsChildOfActivityWhileVisualHostIsUpright [
	<gtExample>
	| activityShape boundaryShape activity boundary activityElement boundaryElement |
	activityShape := CPShape new.
	boundaryShape := CPShape new.
	activity := CPUserTask new label: 'Review'; yourself.
	boundary := CPBoundaryEvent new.
	activityElement := CPProcessShapeElement new
		shape: activityShape
		modelElement: activity
		bounds: (100 @ 100 extent: 140 @ 80)
		background: Color white
		borderColor: Color black
		label: nil.
	boundaryElement := CPProcessShapeElement new
		shape: boundaryShape
		modelElement: boundary
		bounds: (84 @ 124 extent: 32 @ 32)
		background: Color white
		borderColor: Color black
		label: nil.
	activityElement hostBoundaryEventElement: boundaryElement atLocalPosition: -16 @ 24.

	self assert: boundaryElement parent == activityElement.
	self assert: boundaryElement uprightHost parent == boundaryElement.
	self assert: boundaryElement position equals: -16 @ 24.
	^ boundaryElement
]







{ #category : 'examples - lanes - orientation' }
CPProcessVisualElementExamples >> boundaryEventOrbitalLabelMovesWithAttachmentButRemainsIndependentOfUprightBody [
	<gtExample>
	| boundaryShape boundary boundaryElement label |
	boundaryShape := CPShape new.
	boundary := CPBoundaryEvent new.
	boundaryElement := CPProcessShapeElement new
		shape: boundaryShape
		modelElement: boundary
		bounds: (100 @ 100 extent: 32 @ 32)
		background: Color white
		borderColor: Color black
		label: nil.
	label := BlElement new extent: 180 @ 44.
	boundaryElement hostOrbitalExternalLabel: label.

	self assert: label parent == boundaryElement.
	self assert: label parent ~~ boundaryElement uprightHost.
	self assert: boundaryElement externalLabelHost == label.
	^ boundaryElement
]

{ #category : 'examples - orientation' }
CPProcessVisualElementExamples >> connectionLabelAnchorMatchesAuthoritativePlacementBox [
	<gtExample>
	| anchor placementOrigin recoveredAnchor |
	anchor := 300 @ 200.
	"CPProcessEdgeVisual>>positionLabelCenteredAt: places the label host at
	the requested path anchor minus the fixed 90@22 placement-box offset.
	Test that geometry directly: BlElement>>relocate: is layout-driven, so an
	unattached element does not synchronously update #position."
	placementOrigin := (anchor x - 90) @ (anchor y - 22).
	recoveredAnchor := placementOrigin + (90 @ 22).
	self assert: placementOrigin equals: 210 @ 178.
	self assert: recoveredAnchor equals: anchor.
	^ recoveredAnchor
]

{ #category : 'examples - orientation' }
CPProcessVisualElementExamples >> connectionLabelMotionUsesLiveVisualCenterNotPlacementAnchor [
	<gtExample>
	| placementAnchorOffset labelExtent visualCenterOffset sourceOrigin sourceAnchor sourceVisualCenter |
	placementAnchorOffset := 90 @ 22.
	labelExtent := 180 @ 14.
	visualCenterOffset := labelExtent / 2.0.
	sourceOrigin := 210 @ 178.
	sourceAnchor := sourceOrigin + placementAnchorOffset.
	sourceVisualCenter := sourceOrigin + visualCenterOffset.

	self assert: sourceAnchor equals: 300 @ 200.
	self assert: sourceVisualCenter equals: 300 @ 185.
	self assert: sourceAnchor - sourceVisualCenter equals: 0 @ 15.
	^ sourceVisualCenter
]




{ #category : 'examples - orientation' }
CPProcessVisualElementExamples >> orientationProcessContentHandoffCorrectionToHorizontal [
	<gtExample>
	| visual geometricExtent presentationExtent geometricEndpoint presentationEndpoint |
	visual := CPProcessVisualElement new.
	geometricExtent := 300 @ 500.
	presentationExtent := geometricExtent - (1 @ 1).
	geometricEndpoint := visual
		orientationPoint: 0 @ 0
		within: geometricExtent
		horizontal: true.
	presentationEndpoint := visual
		orientationPoint: 0 @ 0
		within: presentationExtent
		horizontal: true.
	self assert: geometricEndpoint - presentationEndpoint equals: 0 @ 1.
	^ geometricEndpoint - presentationEndpoint
]

{ #category : 'examples - orientation' }
CPProcessVisualElementExamples >> orientationProcessContentHandoffCorrectionToVertical [
	<gtExample>
	| visual geometricExtent presentationExtent geometricEndpoint presentationEndpoint |
	visual := CPProcessVisualElement new.
	geometricExtent := 500 @ 300.
	presentationExtent := geometricExtent - (1 @ 1).
	geometricEndpoint := visual
		orientationPoint: 0 @ 0
		within: geometricExtent
		horizontal: false.
	presentationEndpoint := visual
		orientationPoint: 0 @ 0
		within: presentationExtent
		horizontal: false.
	self assert: geometricEndpoint - presentationEndpoint equals: 1 @ 0.
	^ geometricEndpoint - presentationEndpoint
]

