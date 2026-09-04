"I insert one fresh CPFlowNode into one staged CPSequenceFlow.

I replace source->target with source->flowNode and flowNode->target as one Atelier operation. The old Sequence Flow and CPEdge are removed, a new CPShape is added at the proposed bounds, and both replacement Sequence Flows and CPEdges are staged together. Assessment validates both resulting connections against the staged Process topology before any mutation."
Class {
	#name : 'CPAtelierInsertFlowNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'sequenceFlow',
		'flowNode',
		'bounds',
		'processMemento',
		'flowElementsDescription',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierInsertFlowNode class >> sequenceFlow: aSequenceFlow flowNode: aFlowNode bounds: aRectangle processMemento: aMemento flowElementsDescription: aFlowElementsDescription diagramDescription: aDiagramDescription [
	^ self new
		sequenceFlow: aSequenceFlow;
		flowNode: aFlowNode;
		bounds: aRectangle;
		processMemento: aMemento;
		flowElementsDescription: aFlowElementsDescription;
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierInsertFlowNode >> assess [
	| flowElements source target topology rules firstRule secondRule
	  firstFlow secondFlow sourceDescription targetDescription
	  diagram diagramMemento elementsDescription elements removedEdges removedEdge
	  shape boundsDescription sourceShape targetShape sourceBounds targetBounds
	  firstEdge secondEdge proposedFlowElements proposedElements |

	sequenceFlow ifNil: [ ^ self rejectedBecause: 'A sequence flow is required.' ].
	flowNode ifNil: [ ^ self rejectedBecause: 'A flow node is required.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Diagram bounds are required.' ].

	flowElements := processMemento readUsing: flowElementsDescription.
	flowElements ifNil: [ ^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	(flowElements identityIncludes: sequenceFlow) ifFalse: [
		^ self rejectedBecause: 'The sequence flow does not belong to the staged process.' ].
	(flowElements identityIncludes: flowNode) ifTrue: [
		^ self rejectedBecause: 'The inserted flow node already belongs to the staged process.' ].

	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	(source isNil or: [ target isNil ]) ifTrue: [
		^ self rejectedBecause: 'The sequence flow requires staged source and target nodes.' ].

	topology := self stagedTopologyFrom: flowElements excluding: sequenceFlow.
	topology addFlowElement: flowNode.
	rules := CPSequenceFlowConnectionRules new.
	firstRule := rules assessConnectionFrom: source to: flowNode in: topology.
	firstRule isAllowed ifFalse: [ ^ self rejectedBecause: firstRule message ].

	firstFlow := CPSequenceFlow new.
	topology addSequenceFlow: firstFlow source: source target: flowNode.
	secondRule := rules assessConnectionFrom: flowNode to: target in: topology.
	secondRule isAllowed ifFalse: [ ^ self rejectedBecause: secondRule message ].
	secondFlow := CPSequenceFlow new.

	{ firstFlow. secondFlow } do: [ :aFlow |
		sourceDescription := aFlow magritteDescription
			detect: [ :each | each handlesSelector: #sourceRef ].
		targetDescription := aFlow magritteDescription
			detect: [ :each | each handlesSelector: #targetRef ].
		aFlow == firstFlow
			ifTrue: [
				[ sourceDescription validate: source. targetDescription validate: flowNode ]
					on: MAValidationError
					do: [ :anException | ^ self rejectedBecause: anException printString ] ]
			ifFalse: [
				[ sourceDescription validate: flowNode. targetDescription validate: target ]
					on: MAValidationError
					do: [ :anException | ^ self rejectedBecause: anException printString ] ] ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].

	removedEdges := elements select: [ :each |
		each isEdge and: [ each modelElement == sequenceFlow ] ].
	removedEdges size = 1 ifFalse: [
		^ self rejectedBecause: 'The inserted sequence flow requires exactly one staged diagram edge.' ].
	removedEdge := removedEdges first.

	sourceShape := self
		shapeFor: source
		in: elements
		diagramMemento: diagramMemento
		elementsDescription: elementsDescription.
	targetShape := self
		shapeFor: target
		in: elements
		diagramMemento: diagramMemento
		elementsDescription: elementsDescription.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [
		^ self rejectedBecause: 'Both sequence-flow endpoints require staged diagram shapes.' ].
	sourceBounds := self stagedBoundsOf: sourceShape in: diagramMemento elementsDescription: elementsDescription.
	targetBounds := self stagedBoundsOf: targetShape in: diagramMemento elementsDescription: elementsDescription.
	(sourceBounds isNil or: [ targetBounds isNil ]) ifTrue: [
		^ self rejectedBecause: 'Both endpoint shapes require staged bounds.' ].

	shape := CPShape new modelElement: flowNode; bounds: bounds; yourself.
	boundsDescription := shape magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	[ boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	firstEdge := CPEdge new modelElement: firstFlow; yourself.
	firstEdge
		addWaypoint: sourceBounds center;
		addWaypoint: bounds center.
	secondEdge := CPEdge new modelElement: secondFlow; yourself.
	secondEdge
		addWaypoint: bounds center;
		addWaypoint: targetBounds center.

	proposedFlowElements := flowElements species withAll:
		(flowElements reject: [ :each | each == sequenceFlow ]).
	proposedFlowElements
		add: flowNode;
		add: firstFlow;
		add: secondFlow.
	[ flowElementsDescription validate: proposedFlowElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedElements := elements species withAll:
		(elements reject: [ :each | each == removedEdge ]).
	proposedElements
		add: shape;
		add: firstEdge;
		add: secondEdge.
	[ elementsDescription validate: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierInsertFlowNodeAssessment
		sequenceFlow: sequenceFlow
		flowNode: flowNode
		shape: shape
		firstSequenceFlow: firstFlow
		secondSequenceFlow: secondFlow
		firstEdge: firstEdge
		secondEdge: secondEdge
		removedEdge: removedEdge
		proposedFlowElements: proposedFlowElements
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierInsertFlowNode >> applyAssessment: anAssessment [
	| source target firstFlow secondFlow diagram diagramMemento elementsDescription |
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.
	firstFlow := anAssessment firstSequenceFlow.
	secondFlow := anAssessment secondSequenceFlow.

	processMemento write: anAssessment proposedFlowElements using: flowElementsDescription.
	self stageEndpointsOf: firstFlow source: source target: flowNode.
	self stageEndpointsOf: secondFlow source: flowNode target: target.

	self stageOutgoingReplacing: sequenceFlow with: firstFlow for: source.
	self stageIncomingReplacing: sequenceFlow with: secondFlow for: target.
	self stageIncoming: { firstFlow } outgoing: { secondFlow } for: flowNode.

	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	diagramMemento write: anAssessment proposedDiagramElements using: elementsDescription.

	processMemento detachChildMementoFor: sequenceFlow inRelation: flowElementsDescription.
	diagramMemento detachChildMementoFor: anAssessment removedEdge inRelation: elementsDescription
]

{ #category : 'private - staged topology' }
CPAtelierInsertFlowNode >> stagedTopologyFrom: flowElements excluding: excludedFlow [
	| topology |
	topology := CPProcessTopology new.
	flowElements do: [ :each |
		each isSequenceFlow
			ifTrue: [
				each == excludedFlow ifFalse: [
					topology
						addSequenceFlow: each
						source: (self stagedSourceOf: each)
						target: (self stagedTargetOf: each) ] ]
			ifFalse: [ topology addFlowElement: each ] ].
	^ topology
]

{ #category : 'private - staged topology' }
CPAtelierInsertFlowNode >> stagedSourceOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := processMemento childMementoFor: aSequenceFlow inRelation: flowElementsDescription.
	description := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged topology' }
CPAtelierInsertFlowNode >> stagedTargetOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := processMemento childMementoFor: aSequenceFlow inRelation: flowElementsDescription.
	description := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - applying' }
CPAtelierInsertFlowNode >> stageEndpointsOf: aSequenceFlow source: aSource target: aTarget [
	| flowMemento sourceDescription targetDescription |
	flowMemento := processMemento childMementoFor: aSequenceFlow inRelation: flowElementsDescription.
	sourceDescription := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	flowMemento write: aSource using: sourceDescription.
	flowMemento write: aTarget using: targetDescription
]

{ #category : 'private - applying' }
CPAtelierInsertFlowNode >> stageOutgoingReplacing: oldFlow with: newFlow for: aFlowNode [
	| nodeMemento description current proposed |
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	current := nodeMemento readUsing: description.
	proposed := current species withAll: (current collect: [ :each |
		each == oldFlow ifTrue: [ newFlow ] ifFalse: [ each ] ]).
	nodeMemento write: proposed using: description
]

{ #category : 'private - applying' }
CPAtelierInsertFlowNode >> stageIncomingReplacing: oldFlow with: newFlow for: aFlowNode [
	| nodeMemento description current proposed |
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	current := nodeMemento readUsing: description.
	proposed := current species withAll: (current collect: [ :each |
		each == oldFlow ifTrue: [ newFlow ] ifFalse: [ each ] ]).
	nodeMemento write: proposed using: description
]

{ #category : 'private - applying' }
CPAtelierInsertFlowNode >> stageIncoming: incoming outgoing: outgoing for: aFlowNode [
	| nodeMemento incomingDescription outgoingDescription |
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	incomingDescription := nodeMemento magritteDescription
		detect: [ :each | each handlesSelector: #incoming ].
	outgoingDescription := nodeMemento magritteDescription
		detect: [ :each | each handlesSelector: #outgoing ].
	nodeMemento write: incoming using: incomingDescription.
	nodeMemento write: outgoing using: outgoingDescription
]

{ #category : 'private - staged state' }
CPAtelierInsertFlowNode >> stagedBoundsOf: aShape in: diagramMemento elementsDescription: elementsDescription [
	| shapeMemento description |
	shapeMemento := diagramMemento childMementoFor: aShape inRelation: elementsDescription.
	description := shapeMemento magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	^ shapeMemento readUsing: description
]

{ #category : 'private' }
CPAtelierInsertFlowNode >> shapeFor: aFlowNode in: elements diagramMemento: aDiagramMemento elementsDescription: anElementsDescription [
	| matches |
	matches := elements select: [ :each |
		each isShape and: [
			(self
				stagedModelElementOf: each
				in: aDiagramMemento
				elementsDescription: anElementsDescription) == aFlowNode ] ].
	^ matches size = 1 ifTrue: [ matches first ] ifFalse: [ nil ]
]

{ #category : 'private - staged state' }
CPAtelierInsertFlowNode >> stagedModelElementOf: aShape in: aDiagramMemento elementsDescription: anElementsDescription [
	| shapeMemento description |
	shapeMemento := aDiagramMemento childMementoFor: aShape inRelation: anElementsDescription.
	description := shapeMemento magritteDescription detect: [ :each | each handlesSelector: #modelElement ].
	^ shapeMemento readUsing: description
]

{ #category : 'private' }
CPAtelierInsertFlowNode >> rejectedBecause: aString [
	^ CPAtelierInsertFlowNodeAssessment
		sequenceFlow: sequenceFlow
		flowNode: flowNode
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierInsertFlowNode >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierInsertFlowNode >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierInsertFlowNode >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierInsertFlowNode >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierInsertFlowNode >> flowElementsDescription: aDescription [ flowElementsDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierInsertFlowNode >> diagramDescription: aDescription [ diagramDescription := aDescription ]
