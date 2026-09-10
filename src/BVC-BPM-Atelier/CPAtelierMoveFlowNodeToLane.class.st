"I coordinate one drag intention that moves a FlowNode's BPMN-DI shape and
reassigns that FlowNode within one LaneSet partition.

I reuse CPAtelierMoveShapes for geometry/edge routing and
CPAtelierAssignFlowNodeToLane for Lane semantics. Both are assessed first, so a
rejected Lane assignment cannot leave the DI move partially staged."
Class {
	#name : 'CPAtelierMoveFlowNodeToLane',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNode',
		'shape',
		'bounds',
		'targetLane',
		'processMemento',
		'diagramDescription',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierMoveFlowNodeToLane class >> flowNode: aFlowNode shape: aShape bounds: aRectangle targetLane: aLane processMemento: aMemento diagramDescription: aDescription [
	^ self new
		flowNode: aFlowNode;
		shape: aShape;
		bounds: aRectangle;
		targetLane: aLane;
		processMemento: aMemento;
		diagramDescription: aDescription;
		yourself
]

{ #category : 'instance creation' }
CPAtelierMoveFlowNodeToLane class >> flowNode: aFlowNode shape: aShape bounds: aRectangle targetLane: aLane processMemento: aMemento diagramContext: aDiagramContext [
	^ self new flowNode: aFlowNode; shape: aShape; bounds: aRectangle; targetLane: aLane; processMemento: aMemento; diagramContext: aDiagramContext; yourself
]

{ #category : 'assessing' }
CPAtelierMoveFlowNodeToLane >> assess [
	| moveOperation moveAssessment laneOperation laneAssessment |
	flowNode ifNil: [ ^ self rejectedBecause: 'A FlowNode is required.' ].
	shape ifNil: [ ^ self rejectedBecause: 'A diagram shape is required.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Proposed bounds are required.' ].
	targetLane ifNil: [ ^ self rejectedBecause: 'A target Lane is required.' ].

	moveOperation := CPAtelierMoveShapes
		boundsByShape: (IdentityDictionary new at: shape put: bounds; yourself)
		processMemento: processMemento
		diagramContext: self stagedDiagramContext.
	moveAssessment := moveOperation assess.
	moveAssessment isApplicable ifFalse: [
		^ self rejectedBecause: moveAssessment rejectionMessage ].

	laneOperation := CPAtelierAssignFlowNodeToLane
		flowNode: flowNode
		targetLane: targetLane
		processMemento: processMemento.
	laneAssessment := laneOperation assess.
	laneAssessment isApplicable ifFalse: [
		^ self rejectedBecause: laneAssessment rejectionMessage ].

	^ CPAtelierMoveFlowNodeToLaneAssessment new
		moveOperation: moveOperation;
		moveAssessment: moveAssessment;
		laneOperation: laneOperation;
		laneAssessment: laneAssessment;
		yourself
]

{ #category : 'applying' }
CPAtelierMoveFlowNodeToLane >> applyAssessment: anAssessment [
	anAssessment moveOperation applyAssessment: anAssessment moveAssessment.
	anAssessment laneOperation applyAssessment: anAssessment laneAssessment
]

{ #category : 'private' }
CPAtelierMoveFlowNodeToLane >> rejectedBecause: aString [
	^ CPAtelierMoveFlowNodeToLaneAssessment new
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLane >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLane >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLane >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLane >> targetLane: anObject [ targetLane := anObject ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLane >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLane >> diagramDescription: aDescription [ diagramDescription := aDescription ]

{ #category : 'private - staged state' }
CPAtelierMoveFlowNodeToLane >> stagedDiagramContext [
	diagramContext ifNotNil: [ ^ diagramContext ].
	diagramContext := CPDiagramMementoContext
		diagram: (processMemento readUsing: diagramDescription)
		inMemento: processMemento
		using: diagramDescription.
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierMoveFlowNodeToLane >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
