"I prove that BPM installs its proven domain editing intentions through Atelier configuration without changing Atelier or Foundation presentation code. Node insertion and removal translate at the exact process relations; connection creation remains an explicit BPM intention because its source and target endpoints come from the BPM interaction rather than generic relation insertion."
Class {
	#name : 'CPAtelierConfigurationExamples',
	#superclass : 'Object',
	#category : 'BVC-BPM-Atelier-Examples',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Examples'
}

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> nodeRemovalUsesProcessSemanticOperation [
	<gtExample>
	| process node other edge memento nodesDescription edgesDescription configuration context operation assessment |
	process := CPProcessDesign new.
	node := CPUserTaskDesignNode new.
	other := CPServiceTaskDesignNode new.
	edge := CPProcessDesignEdge new
		sourceNode: node;
		targetNode: other;
		yourself.
	process
		nodes: (OrderedCollection with: node with: other);
		edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration
		nodesDescription: nodesDescription
		edgesDescription: edgesDescription.
	context := CFAtelierRelationDragContext
		memento: memento
		description: nodesDescription.

	operation := configuration removeOperationFor: { node } from: context.
	assessment := operation assess.

	self assert: operation class equals: CPAtelierRemoveNode.
	self assert: assessment isApplicable.
	self assert: assessment removedEdges size equals: 1.
	self assert: process nodes size equals: 2.
	self assert: process edges size equals: 1.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> otherRelationRemovalKeepsGenericAtelierSemantics [
	<gtExample>
	| process edge memento nodesDescription edgesDescription configuration context operation assessment |
	process := CPProcessDesign new.
	edge := CPProcessDesignEdge new.
	process edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration
		nodesDescription: nodesDescription
		edgesDescription: edgesDescription.
	context := CFAtelierRelationDragContext
		memento: memento
		description: edgesDescription.

	operation := configuration removeOperationFor: { edge } from: context.
	assessment := operation assess.

	self assert: operation class equals: CFAtelierRemove.
	self assert: assessment isApplicable.
	self assert: process edges size equals: 1.
	self assert: (memento readUsing: edgesDescription) size equals: 1.
	^ operation
]


{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> multiNodeRemovalUsesOneProcessSemanticOperation [
	<gtExample>
	| process first second third firstEdge secondEdge memento nodesDescription edgesDescription configuration context operation assessment |
	process := CPProcessDesign new.
	first := CPUserTaskDesignNode new.
	second := CPServiceTaskDesignNode new.
	third := CPUserTaskDesignNode new.
	firstEdge := CPProcessDesignEdge new sourceNode: first; targetNode: second; yourself.
	secondEdge := CPProcessDesignEdge new sourceNode: second; targetNode: third; yourself.
	process
		nodes: (OrderedCollection with: first with: second with: third);
		edges: (OrderedCollection with: firstEdge with: secondEdge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	context := CFAtelierRelationDragContext memento: memento description: nodesDescription.

	operation := configuration removeOperationFor: { first. third } from: context.
	assessment := operation apply.

	self assert: operation class equals: CPAtelierRemoveNodes.
	self assert: assessment isApplicable.
	self assert: assessment removedEdges size equals: 2.
	self assert: (memento readUsing: nodesDescription) size equals: 1.
	self assert: (memento readUsing: nodesDescription) first == second.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 2.
	^ operation
]


{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> nodeInsertionUsesProcessCreateOperation [
	<gtExample>
	| process first candidate memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	first := CPUserTaskDesignNode new.
	candidate := CPServiceTaskDesignNode new position: 240@120; yourself.
	process nodes: (OrderedCollection with: first).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		insertOperationFor: candidate
		into: memento
		description: nodesDescription
		at: nil.
	assessment := operation apply.

	self assert: operation class equals: CPAtelierCreateNode.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: nodesDescription) first == first.
	self assert: (memento readUsing: nodesDescription) second == candidate.
	self assert: candidate position equals: 240@120.
	self assert: process nodes size equals: 1.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> connectionUsesProcessConnectOperation [
	<gtExample>
	| process source target edge memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new.
	target := CPUserTaskDesignNode new.
	edge := CPProcessDesignEdge new.
	process nodes: (OrderedCollection with: source with: target).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		connectOperationFor: edge
		from: source
		to: target
		in: memento.
	assessment := operation assess.

	self assert: operation class equals: CPAtelierConnectNodes.
	self assert: assessment isApplicable.
	self assert: operation edge == edge.
	self assert: operation sourceNode == source.
	self assert: operation targetNode == target.
	self assert: operation processMemento == memento.
	self assert: operation nodesDescription == nodesDescription.
	self assert: operation edgesDescription == edgesDescription.
	self assert: process edges isEmpty.
	self assert: edge sourceNode isNil.
	self assert: edge targetNode isNil.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> connectionApplyStagesOneProcessEdgeWithExactEndpoints [
	<gtExample>
	| process source target edge memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new.
	target := CPServiceTaskDesignNode new.
	edge := CPProcessDesignEdge new.
	process nodes: (OrderedCollection with: source with: target).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		connectOperationFor: edge
		from: source
		to: target
		in: memento.
	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: edgesDescription) size equals: 1.
	self assert: (memento readUsing: edgesDescription) first == edge.
	self assert: edge sourceNode == source.
	self assert: edge targetNode == target.
	self assert: process edges isEmpty.
	^ operation
]

{ #category : 'examples - entry' }
CPAtelierConfigurationExamples >> processAtelierEntryInstallsProcessPalette [
	<gtExample>
	| process atelier palette |
	process := CPProcessDesign new.
	atelier := process asAtelier.
	palette := atelier palette.

	self assert: palette items size equals: 6.
	self assert: palette items first label equals: 'Start event'.
	self assert: palette items second label equals: 'End event'.
	self assert: palette items third label equals: 'User task'.
	self assert: palette items fourth label equals: 'Service task'.
	self assert: palette items fifth label equals: 'Exclusive gateway'.
	self assert: palette items sixth label equals: 'Parallel gateway'.
	^ atelier
]

{ #category : 'examples - entry' }
CPAtelierConfigurationExamples >> processNodePaletteMaterializesFreshIdentities [
	<gtExample>
	| palette first second |
	palette := CPAtelierConfiguration processNodePalette.
	first := palette items third materialize.
	second := palette items third materialize.

	self assert: first class equals: CPUserTaskDesignNode.
	self assert: second class equals: CPUserTaskDesignNode.
	self assert: first ~~ second.
	^ palette
]

{ #category : 'examples - showcase' }
CPAtelierConfigurationExamples >> interactiveProcessAtelier [
	<gtExample>
	| process start task finish edge1 edge2 atelier element |
	process := CPProcessDesign new
		label: 'Interactive Atelier process';
		yourself.
	start := CPStartEventDesignNode new
		label: 'Start';
		position: 60 @ 170;
		yourself.
	task := CPUserTaskDesignNode new
		label: 'Review request';
		position: 250 @ 164;
		yourself.
	finish := CPEndEventDesignNode new
		label: 'Done';
		position: 470 @ 170;
		yourself.
	edge1 := CPProcessDesignEdge new
		label: 'Start to review';
		sourceNode: start;
		targetNode: task;
		yourself.
	edge2 := CPProcessDesignEdge new
		label: 'Review to done';
		sourceNode: task;
		targetNode: finish;
		yourself.
	process
		addNode: start;
		addNode: task;
		addNode: finish;
		addEdge: edge1;
		addEdge: edge2.

	atelier := process asAtelier.
	element := atelier asElement.

	self assert: atelier palette items size equals: 6.
	self assert: atelier class equals: CFAtelierViewModel.
	self assert: process nodes size equals: 3.
	self assert: process edges size equals: 2.
	^ element
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> nodeReplacementRetargetsIncidentEdgesInOneProcessTransaction [
	<gtExample>
	| process source oldNode replacement target incoming outgoing memento nodesDescription edgesDescription configuration operation assessment incomingMemento outgoingMemento |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new.
	oldNode := CPUserTaskDesignNode new.
	replacement := CPServiceTaskDesignNode new.
	target := CPEndEventDesignNode new.
	incoming := CPProcessDesignEdge new sourceNode: source; targetNode: oldNode; yourself.
	outgoing := CPProcessDesignEdge new sourceNode: oldNode; targetNode: target; yourself.
	process nodes: (OrderedCollection with: source with: oldNode with: target); edges: (OrderedCollection with: incoming with: outgoing).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration replaceOperationFor: oldNode with: replacement in: memento description: nodesDescription.
	assessment := operation apply.
	incomingMemento := memento childMementoFor: incoming inRelation: edgesDescription.
	outgoingMemento := memento childMementoFor: outgoing inRelation: edgesDescription.

	self assert: operation class equals: CPAtelierReplaceNode.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: nodesDescription) second == replacement.
	self assert: (incomingMemento readUsing: incoming targetNodeDescription) == replacement.
	self assert: (outgoingMemento readUsing: outgoing sourceNodeDescription) == replacement.
	self assert: incoming targetNode == oldNode.
	self assert: outgoing sourceNode == oldNode.
	self assert: process nodes second == oldNode.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> nodeReplacementCommitPreservesTopologyWithReplacementIdentity [
	<gtExample>
	| process oldNode replacement target edge memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	oldNode := CPUserTaskDesignNode new.
	replacement := CPServiceTaskDesignNode new.
	target := CPEndEventDesignNode new.
	edge := CPProcessDesignEdge new sourceNode: oldNode; targetNode: target; yourself.
	process nodes: (OrderedCollection with: oldNode with: target); edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration replaceOperationFor: oldNode with: replacement in: memento description: nodesDescription.
	assessment := operation apply.
	self assert: assessment isApplicable.
	memento commit.

	self assert: process nodes first == replacement.
	self assert: edge sourceNode == replacement.
	self assert: edge targetNode == target.
	^ process
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> edgeInsertionUsesConnectSemantics [
	<gtExample>
	| process source target edge memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new.
	target := CPEndEventDesignNode new.
	process
		addNode: source;
		addNode: target.
	edge := CPProcessDesignEdge new
		sourceNode: source;
		targetNode: target;
		yourself.
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		insertOperationFor: edge
		into: memento
		description: edgesDescription
		at: nil.
	assessment := operation assess.

	self assert: operation class equals: CPAtelierConnectNodes.
	self assert: assessment isApplicable.
	self assert: process edges isEmpty.
	self assert: (memento readUsing: edgesDescription) isEmpty.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> edgeReplacementUsesProcessEndpointSemantics [
	<gtExample>
	| process source target oldEdge replacement memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new.
	target := CPEndEventDesignNode new.
	oldEdge := CPProcessDesignEdge new sourceNode: source; targetNode: target; yourself.
	process addNode: source; addNode: target; addEdge: oldEdge.
	replacement := CPProcessDesignEdge new sourceNode: source; targetNode: target; yourself.
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		replaceOperationFor: oldEdge
		with: replacement
		in: memento
		description: edgesDescription.
	assessment := operation apply.

	self assert: operation class equals: CPAtelierReplaceEdge.
	self assert: assessment isApplicable.
	self assert: (memento readUsing: edgesDescription) first == replacement.
	self assert: process edges first == oldEdge.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> edgeReplacementRejectsEndpointOutsideProcess [
	<gtExample>
	| process source target outsider oldEdge replacement memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new.
	target := CPEndEventDesignNode new.
	outsider := CPUserTaskDesignNode new.
	oldEdge := CPProcessDesignEdge new sourceNode: source; targetNode: target; yourself.
	process addNode: source; addNode: target; addEdge: oldEdge.
	replacement := CPProcessDesignEdge new sourceNode: source; targetNode: outsider; yourself.
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		replaceOperationFor: oldEdge
		with: replacement
		in: memento
		description: edgesDescription.
	assessment := operation apply.

	self assert: assessment isApplicable not.
	self assert: (memento readUsing: edgesDescription) first == oldEdge.
	self assert: process edges first == oldEdge.
	^ assessment
]

{ #category : 'examples - staged edge state' }
CPAtelierConfigurationExamples >> nodeReplacementUsesStagedEdgeEndpoints [
	<gtExample>
	| process oldNode replacement other edge memento nodesDescription edgesDescription configuration edgeMemento assessment |
	process := CPProcessDesign new.
	oldNode := CPUserTaskDesignNode new.
	replacement := CPServiceTaskDesignNode new.
	other := CPEndEventDesignNode new.
	edge := CPProcessDesignEdge new sourceNode: oldNode; targetNode: other; yourself.
	process nodes: (OrderedCollection with: oldNode with: other); edges: (OrderedCollection with: edge).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	edgeMemento := memento childMementoFor: edge inRelation: edgesDescription.
	edgeMemento write: other using: edge sourceNodeDescription.

	assessment := (configuration replaceOperationFor: oldNode with: replacement in: memento description: nodesDescription) apply.

	self assert: assessment isApplicable.
	self assert: assessment incidentEdges isEmpty.
	self assert: (edgeMemento readUsing: edge sourceNodeDescription) == other.
	self assert: edge sourceNode == oldNode.
	self assert: (memento readUsing: nodesDescription) first == replacement.
	^ assessment
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> nodeReplacementPreservesStagedDiagramPosition [
	<gtExample>
	| process oldNode replacement memento nodesDescription edgesDescription configuration oldNodeMemento replacementMemento operation assessment stagedPosition |
	process := CPProcessDesign new.
	oldNode := CPUserTaskDesignNode new position: 120@80; yourself.
	replacement := CPServiceTaskDesignNode new.
	process nodes: (OrderedCollection with: oldNode).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.
	oldNodeMemento := memento childMementoFor: oldNode inRelation: nodesDescription.
	stagedPosition := 360@220.
	oldNodeMemento write: stagedPosition using: oldNode positionDescription.

	operation := configuration
		replaceOperationFor: oldNode
		with: replacement
		in: memento
		description: nodesDescription.
	assessment := operation apply.
	replacementMemento := memento childMementoFor: replacement inRelation: nodesDescription.

	self assert: assessment isApplicable.
	self assert: assessment preservedPosition equals: stagedPosition.
	self assert: (memento readUsing: nodesDescription) first == replacement.
	self assert: (replacementMemento readUsing: replacement positionDescription) equals: stagedPosition.
	self assert: replacement position isNil.
	self assert: oldNode position equals: 120@80.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> nodeReplacementCommitsPreservedDiagramPosition [
	<gtExample>
	| process oldNode replacement memento nodesDescription edgesDescription configuration operation assessment |
	process := CPProcessDesign new.
	oldNode := CPUserTaskDesignNode new position: 180@140; yourself.
	replacement := CPServiceTaskDesignNode new.
	process nodes: (OrderedCollection with: oldNode).
	memento := CFMaMemento model: process.
	nodesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := memento magritteDescription detect: [ :each | each handlesSelector: #edges ].
	configuration := CPAtelierConfiguration nodesDescription: nodesDescription edgesDescription: edgesDescription.

	operation := configuration
		replaceOperationFor: oldNode
		with: replacement
		in: memento
		description: nodesDescription.
	assessment := operation apply.
	self assert: assessment isApplicable.
	memento commit.

	self assert: process nodes first == replacement.
	self assert: replacement position equals: 180@140.
	^ process
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> diagramNodeCreationCarriesExactDropPosition [
	<gtExample>
	| process memento configuration candidate operation assessment nodesDescription |
	process := CPProcessDesign new.
	memento := CPProcessDesignMemento model: process.
	nodesDescription := memento magritteDescription
		detect: [ :each | each handlesSelector: #nodes ].
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	candidate := CPServiceTaskDesignNode new.

	operation := configuration
		createNodeOperationFor: candidate
		at: 420@260
		in: memento.
	assessment := operation assess.

	self assert: operation class equals: CPAtelierCreateNode.
	self assert: operation node == candidate.
	self assert: operation position equals: 420@260.
	self assert: assessment isApplicable.
	self assert: process nodes isEmpty.
	self assert: candidate position isNil.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> diagramNodeCreationStagesPositionOnlyOnApply [
	<gtExample>
	| process memento configuration candidate operation assessment nodesDescription |
	process := CPProcessDesign new.
	memento := CPProcessDesignMemento model: process.
	nodesDescription := memento magritteDescription
		detect: [ :each | each handlesSelector: #nodes ].
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	candidate := CPUserTaskDesignNode new.
	operation := configuration
		createNodeOperationFor: candidate
		at: 300@180
		in: memento.

	assessment := operation apply.

	self assert: assessment isApplicable.
	self assert: candidate position equals: 300@180.
	self assert: (memento readUsing: nodesDescription) size equals: 1.
	self assert: (memento readUsing: nodesDescription) first == candidate.
	self assert: process nodes isEmpty.
	^ operation
]


{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> diagramNodePositionAssessmentIsPure [
	<gtExample>
	| process node memento configuration operation assessment |
	process := CPProcessDesign new.
	node := CPUserTaskDesignNode new position: 120@80; yourself.
	process addNode: node.
	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.

	operation := configuration
		positionNodeOperationFor: node
		at: 420@260
		in: memento.
	assessment := operation assess.

	self assert: operation class equals: CPAtelierPositionNode.
	self assert: assessment isApplicable.
	self assert: assessment currentPosition equals: 120@80.
	self assert: assessment proposedPosition equals: 420@260.
	self assert: node position equals: 120@80.
	self assert: (memento hasChildMementoFor: node inRelation: configuration nodesDescription) not.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> diagramNodePositionStagesThroughChildMemento [
	<gtExample>
	| process node memento configuration operation assessment nodeMemento |
	process := CPProcessDesign new.
	node := CPServiceTaskDesignNode new position: 100@100; yourself.
	process addNode: node.
	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	operation := configuration
		positionNodeOperationFor: node
		at: 360@220
		in: memento.

	assessment := operation apply.
	nodeMemento := memento childMementoFor: node inRelation: configuration nodesDescription.

	self assert: assessment isApplicable.
	self assert: (nodeMemento readUsing: node positionDescription) equals: 360@220.
	self assert: node position equals: 100@100.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> diagramNodePositionReassessesStagedPosition [
	<gtExample>
	| process node memento configuration nodeMemento operation assessment |
	process := CPProcessDesign new.
	node := CPUserTaskDesignNode new position: 80@60; yourself.
	process addNode: node.
	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	nodeMemento := memento childMementoFor: node inRelation: configuration nodesDescription.
	nodeMemento write: 200@140 using: node positionDescription.

	operation := configuration
		positionNodeOperationFor: node
		at: 500@300
		in: memento.
	assessment := operation assess.

	self assert: assessment isApplicable.
	self assert: assessment currentPosition equals: 200@140.
	self assert: node position equals: 80@60.
	^ assessment
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> diagramEdgeReconnectAssessmentIsPure [
	<gtExample>
	| process first second third edge memento configuration operation assessment |
	process := CPProcessDesign new.
	first := CPStartEventDesignNode new.
	second := CPUserTaskDesignNode new.
	third := CPEndEventDesignNode new.
	edge := CPProcessDesignEdge new sourceNode: first; targetNode: second; yourself.
	process nodes: (OrderedCollection with: first with: second with: third); edges: (OrderedCollection with: edge).
	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.

	operation := configuration
		reconnectOperationFor: edge
		from: first
		to: third
		in: memento.
	assessment := operation assess.

	self assert: operation class equals: CPAtelierReconnectEdge.
	self assert: assessment isApplicable.
	self assert: assessment currentSourceNode == first.
	self assert: assessment currentTargetNode == second.
	self assert: assessment proposedTargetNode == third.
	self assert: edge targetNode == second.
	self assert: (memento hasChildMementoFor: edge inRelation: configuration edgesDescription) not.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> diagramEdgeReconnectStagesEndpoints [
	<gtExample>
	| process first second third edge memento configuration operation assessment edgeMemento |
	process := CPProcessDesign new.
	first := CPStartEventDesignNode new.
	second := CPUserTaskDesignNode new.
	third := CPEndEventDesignNode new.
	edge := CPProcessDesignEdge new sourceNode: first; targetNode: second; yourself.
	process nodes: (OrderedCollection with: first with: second with: third); edges: (OrderedCollection with: edge).
	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	operation := configuration
		reconnectOperationFor: edge
		from: second
		to: third
		in: memento.

	assessment := operation apply.
	edgeMemento := memento childMementoFor: edge inRelation: configuration edgesDescription.

	self assert: assessment isApplicable.
	self assert: (edgeMemento readUsing: edge sourceNodeDescription) == second.
	self assert: (edgeMemento readUsing: edge targetNodeDescription) == third.
	self assert: edge sourceNode == first.
	self assert: edge targetNode == second.
	^ operation
]

{ #category : 'examples - configuration' }
CPAtelierConfigurationExamples >> diagramEdgeReconnectReassessesStagedEndpoints [
	<gtExample>
	| process first second third fourth edge memento configuration edgeMemento operation assessment |
	process := CPProcessDesign new.
	first := CPStartEventDesignNode new.
	second := CPUserTaskDesignNode new.
	third := CPServiceTaskDesignNode new.
	fourth := CPEndEventDesignNode new.
	edge := CPProcessDesignEdge new sourceNode: first; targetNode: second; yourself.
	process nodes: (OrderedCollection with: first with: second with: third with: fourth); edges: (OrderedCollection with: edge).
	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	edgeMemento := memento childMementoFor: edge inRelation: configuration edgesDescription.
	edgeMemento write: third using: edge targetNodeDescription.

	operation := configuration
		reconnectOperationFor: edge
		from: first
		to: fourth
		in: memento.
	assessment := operation assess.

	self assert: assessment isApplicable.
	self assert: assessment currentTargetNode == third.
	self assert: edge targetNode == second.
	^ assessment
]

{ #category : 'examples - diagram integration' }
CPAtelierConfigurationExamples >> diagramPositionSurfaceUsesConfiguredOperation [
	<gtExample>
	| process node memento configuration diagram assessment nodeMemento |
	process := CPProcessDesign new.
	node := CPUserTaskDesignNode new position: 80@60; yourself.
	process addNode: node.
	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	diagram := CPProcessDiagramElement new
		positionNodeOperationFor: [ :aNode :aPoint |
			configuration positionNodeOperationFor: aNode at: aPoint in: memento ];
		memento: memento.

	assessment := diagram positionNode: node at: 320@210.
	nodeMemento := memento childMementoFor: node inRelation: configuration nodesDescription.

	self assert: assessment isApplicable.
	self assert: (nodeMemento readUsing: node positionDescription) equals: 320@210.
	self assert: node position equals: 80@60.
	^ diagram
]

{ #category : 'examples - diagram integration' }
CPAtelierConfigurationExamples >> diagramCreateSurfaceUsesConfiguredOperation [
	<gtExample>
	| process memento configuration candidate diagram assessment nodeMemento |
	process := CPProcessDesign new.
	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	candidate := CPServiceTaskDesignNode new.
	diagram := CPProcessDiagramElement new
		createNodeOperationFor: [ :aNode :aPoint |
			configuration createNodeOperationFor: aNode at: aPoint in: memento ];
		memento: memento.

	assessment := diagram createNode: candidate at: 340@190.
	nodeMemento := memento childMementoFor: candidate inRelation: configuration nodesDescription.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: configuration nodesDescription) first == candidate.
	self assert: (nodeMemento readUsing: candidate positionDescription) equals: 340@190.
	self assert: candidate position equals: 340@190.
	self assert: process nodes isEmpty.
	^ diagram
]

{ #category : 'examples - diagram integration' }
CPAtelierConfigurationExamples >> diagramConnectSurfaceUsesConfiguredOperation [
	<gtExample>
	| process source target memento configuration diagram assessment edge |
	process := CPProcessDesign new.
	source := CPStartEventDesignNode new position: 80 @ 160; yourself.
	target := CPUserTaskDesignNode new position: 280 @ 160; yourself.
	process nodes: (OrderedCollection with: source with: target).
	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	diagram := CPProcessDiagramElement new
		connectNodeOperationFor: [ :aSourceNode :aTargetNode |
			configuration connectOperationFrom: aSourceNode to: aTargetNode in: memento ];
		memento: memento.

	assessment := diagram connectNode: source to: target.
	edge := assessment edge.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: configuration edgesDescription) size equals: 1.
	self assert: (memento readUsing: configuration edgesDescription) first == edge.
	self assert: edge sourceNode == source.
	self assert: edge targetNode == target.
	self assert: process edges isEmpty.
	^ diagram
]


{ #category : 'examples - diagram integration' }
CPAtelierConfigurationExamples >> diagramReconnectSurfaceUsesConfiguredOperation [
	<gtExample>
	| process first second third edge memento configuration diagram assessment edgeMemento |
	process := CPProcessDesign new.
	first := CPStartEventDesignNode new position: 80 @ 160; yourself.
	second := CPUserTaskDesignNode new position: 280 @ 160; yourself.
	third := CPEndEventDesignNode new position: 480 @ 160; yourself.
	edge := CPProcessDesignEdge new sourceNode: first; targetNode: second; yourself.
	process
		nodes: (OrderedCollection with: first with: second with: third);
		edges: (OrderedCollection with: edge).
	memento := CPProcessDesignMemento model: process.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	diagram := CPProcessDiagramElement new
		reconnectEdgeOperationFor: [ :anEdge :aSourceNode :aTargetNode |
			configuration reconnectOperationFor: anEdge from: aSourceNode to: aTargetNode in: memento ];
		memento: memento.

	assessment := diagram reconnectEdge: edge from: first to: third.
	edgeMemento := memento childMementoFor: edge inRelation: configuration edgesDescription.

	self assert: assessment isApplicable.
	self assert: (memento readUsing: configuration edgesDescription) first == edge.
	self assert: (edgeMemento readUsing: edge sourceNodeDescription) == first.
	self assert: (edgeMemento readUsing: edge targetNodeDescription) == third.
	self assert: edge sourceNode == first.
	self assert: edge targetNode == second.
	^ diagram
]
