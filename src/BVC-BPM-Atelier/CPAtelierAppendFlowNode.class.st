"I atomically append one freshly supplied CPFlowNode after one staged source node.

I stage the new flow node, its CPShape, one CPSequenceFlow from source to the new node, and the matching CPEdge as one Atelier operation. Assessment validates the complete semantic topology and diagram collections before mutation. The palette owns candidate materialisation; I receive that exact candidate identity."
Class {
	#name : 'CPAtelierAppendFlowNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'source',
		'flowNode',
		'bounds',
		'processMemento',
		'flowContainerContext',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierAppendFlowNode class >> source: aSource flowNode: aFlowNode bounds: aRectangle flowContainer: aContainer processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new
		source: aSource;
		flowNode: aFlowNode;
		bounds: aRectangle;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierAppendFlowNode >> assess [
	| flowElements topology ruleResult sequenceFlow sourceDescription targetDescription
	  diagram diagramContext elements sourceShape sourceBounds
	  shape boundsDescription edge proposedFlowElements proposedElements |
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	source ifNil: [ ^ self rejectedBecause: 'A source flow node is required.' ].
	flowNode ifNil: [ ^ self rejectedBecause: 'A flow node is required.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Diagram bounds are required.' ].
	flowElements := flowContainerContext stagedFlowElements.
	flowElements ifNil: [ ^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	(flowElements identityIncludes: source) ifFalse: [
		^ self rejectedBecause: 'The source does not belong to the target flow container.' ].
	(flowElements identityIncludes: flowNode) ifTrue: [
		^ self rejectedBecause: 'The flow node is already present in the process.' ].

	topology := self stagedTopologyFrom: flowElements.
	topology addFlowElement: flowNode.
	ruleResult := CPSequenceFlowConnectionRules new assessConnectionFrom: source to: flowNode in: topology.
	ruleResult isAllowed ifFalse: [ ^ self rejectedBecause: ruleResult message ].

	sequenceFlow := CPSequenceFlow new.
	sourceDescription := sequenceFlow magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := sequenceFlow magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	[ sourceDescription validate: source. targetDescription validate: flowNode ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramContext := CPDiagramMementoContext diagram: diagram inMemento: processMemento using: diagramDescription.
	elements := diagramContext elements.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].
	sourceShape := diagramContext shapeForModelElement: source.
	sourceShape ifNil: [ ^ self rejectedBecause: 'The source requires exactly one staged diagram shape.' ].
	sourceBounds := diagramContext boundsOf: sourceShape.
	sourceBounds ifNil: [ ^ self rejectedBecause: 'The source shape requires staged bounds.' ].

	shape := CPShape new modelElement: flowNode; bounds: bounds; yourself.
	boundsDescription := shape magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	[ boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	edge := CPEdge new modelElement: sequenceFlow; yourself.
	edge addWaypoint: sourceBounds center; addWaypoint: bounds center.

	proposedFlowElements := flowElements asOrderedCollection copy.
	proposedFlowElements add: flowNode; add: sequenceFlow.
	[ flowContainerContext flowElementsDescription validate: proposedFlowElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape; add: edge.
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierAppendFlowNodeAssessment
		source: source
		flowNode: flowNode
		shape: shape
		sequenceFlow: sequenceFlow
		edge: edge
		proposedFlowElements: proposedFlowElements
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierAppendFlowNode >> applyAssessment: anAssessment [
	| diagram diagramContext |
	flowContainerContext writeFlowElements: anAssessment proposedFlowElements.
	self
		stageEndpointsOf: anAssessment sequenceFlow
		source: source
		target: flowNode.
	self stageOutgoingIncluding: anAssessment sequenceFlow for: source.
	self stageIncoming: { anAssessment sequenceFlow } outgoing: #() for: flowNode.

	diagram := processMemento readUsing: diagramDescription.
	diagramContext := CPDiagramMementoContext diagram: diagram inMemento: processMemento using: diagramDescription.
	diagramContext writeElements: anAssessment proposedDiagramElements
]

{ #category : 'private - applying' }
CPAtelierAppendFlowNode >> stageEndpointsOf: aSequenceFlow source: aSource target: aTarget [
	| flowMemento sourceDescription targetDescription |
	flowMemento := flowContainerContext childMementoFor: aSequenceFlow.
	sourceDescription := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	flowMemento write: aSource using: sourceDescription.
	flowMemento write: aTarget using: targetDescription
]

{ #category : 'private - staged topology' }
CPAtelierAppendFlowNode >> stagedTopologyFrom: flowElements [
	| topology |
	topology := CPProcessTopology new.
	flowElements do: [ :each |
		each isSequenceFlow
			ifTrue: [ topology addSequenceFlow: each source: (flowContainerContext stagedSourceOf: each) target: (flowContainerContext stagedTargetOf: each) ]
			ifFalse: [ topology addFlowElement: each ] ].
	^ topology
]

{ #category : 'private - applying' }
CPAtelierAppendFlowNode >> stageOutgoingIncluding: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	current := nodeMemento readUsing: description.
	(current identityIncludes: aSequenceFlow) ifTrue: [ ^ self ].
	proposed := current asOrderedCollection copy.
	proposed add: aSequenceFlow.
	nodeMemento write: proposed using: description
]

{ #category : 'private - applying' }
CPAtelierAppendFlowNode >> stageIncoming: incoming outgoing: outgoing for: aFlowNode [
	| nodeMemento incomingDescription outgoingDescription |
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	incomingDescription := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	outgoingDescription := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	nodeMemento write: incoming using: incomingDescription.
	nodeMemento write: outgoing using: outgoingDescription
]




{ #category : 'private' }
CPAtelierAppendFlowNode >> rejectedBecause: aString [
	^ CPAtelierAppendFlowNodeAssessment source: source flowNode: flowNode rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierAppendFlowNode >> source: anObject [ source := anObject ]
{ #category : 'accessing' }
CPAtelierAppendFlowNode >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierAppendFlowNode >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierAppendFlowNode >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierAppendFlowNode >> flowContainerContext: aContext [ flowContainerContext := aContext ]
{ #category : 'accessing' }
CPAtelierAppendFlowNode >> diagramDescription: aDescription [ diagramDescription := aDescription ]
