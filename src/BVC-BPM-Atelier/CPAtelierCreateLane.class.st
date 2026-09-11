"I stage creation of one supplied BPMN Lane and its CPShape in the root Process.

The first Lane creates the Process LaneSet. Later Lane creations join the sole staged top-level LaneSet. I reject an ambiguous Process with multiple top-level LaneSets rather than guessing which partition to mutate."
Class {
	#name : 'CPAtelierCreateLane',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'lane',
		'bounds',
		'processMemento',
		'diagramContext',
		'collaborationContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateLane class >> lane: aLane bounds: aRectangle processMemento: aMemento diagramContext: aDiagramContext [
	^ self new lane: aLane; bounds: aRectangle; processMemento: aMemento; diagramContext: aDiagramContext; yourself
]

{ #category : 'instance creation' }
CPAtelierCreateLane class >> lane: aLane bounds: aRectangle processMemento: aMemento diagramContext: aDiagramContext collaborationContext: aCollaborationContext [
	^ self new lane: aLane; bounds: aRectangle; processMemento: aMemento; diagramContext: aDiagramContext; collaborationContext: aCollaborationContext; yourself
]

{ #category : 'assessing' }
CPAtelierCreateLane >> assess [
	| laneSetsDescription laneSets createsLaneSet laneSet laneSetMemento lanesDescription lanes diagram diagramContext elements shape boundsDescription proposedLaneSets proposedLanes proposedElements participantResizeOperation participantResizeAssessment assessment flowElementsDescription stagedFlowElements proposedFlowNodeRefs flowNodeRefsDescription |
	lane ifNil: [ ^ self rejectedBecause: 'A Lane is required.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Lane bounds are required.' ].
	laneSetsDescription := processMemento magritteDescription
		detect: [ :each | each handlesSelector: #laneSets ].
	laneSets := processMemento readUsing: laneSetsDescription.
	laneSets ifNil: [ ^ self rejectedBecause: 'The Process has no staged LaneSet collection.' ].
	laneSets size > 1 ifTrue: [
		^ self rejectedBecause: 'Lane creation requires a Process with at most one top-level LaneSet.' ].
	createsLaneSet := laneSets isEmpty.
	laneSet := createsLaneSet ifTrue: [ CPLaneSet new ] ifFalse: [ laneSets first ].

	createsLaneSet
		ifTrue: [ lanes := OrderedCollection new ]
		ifFalse: [
			laneSetMemento := processMemento childMementoFor: laneSet inRelation: laneSetsDescription.
			lanesDescription := laneSetMemento magritteDescription
				detect: [ :each | each handlesSelector: #lanes ].
			lanes := laneSetMemento readUsing: lanesDescription ].
	lanes ifNil: [ ^ self rejectedBecause: 'The LaneSet has no staged Lane collection.' ].
	(lanes identityIncludes: lane) ifTrue: [ ^ self rejectedBecause: 'The Lane is already present in the LaneSet.' ].

	shape := CPShape new modelElement: lane; bounds: bounds; yourself.
	boundsDescription := shape magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	[ boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedLaneSets := laneSets asOrderedCollection copy.
	createsLaneSet ifTrue: [ proposedLaneSets add: laneSet ].
	[ laneSetsDescription validate: proposedLaneSets ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	proposedLanes := lanes asOrderedCollection copy.
	proposedLanes add: lane.
	lanesDescription ifNil: [
		lanesDescription := laneSet magritteDescription detect: [ :each | each handlesSelector: #lanes ] ].
	[ lanesDescription validate: proposedLanes ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [ ^ self rejectedBecause: 'The Process has no staged diagram.' ].
	elements := diagramContext elements.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedFlowNodeRefs := nil.
	createsLaneSet ifTrue: [
		flowElementsDescription := processMemento magritteDescription
			detect: [ :each | each handlesSelector: #flowElements ].
		stagedFlowElements := processMemento readUsing: flowElementsDescription.
		proposedFlowNodeRefs := stagedFlowElements reject: [ :each | each isSequenceFlow ].
		flowNodeRefsDescription := lane magritteDescription
			detect: [ :each | each handlesSelector: #flowNodeRefs ].
		[ flowNodeRefsDescription validate: proposedFlowNodeRefs ]
			on: MAValidationError
			do: [ :anException | ^ self rejectedBecause: anException printString ] ].

	participantResizeOperation := createsLaneSet
		ifTrue: [ self participantResizeOperationForFirstLane ]
		ifFalse: [ nil ].
	participantResizeOperation
		ifNil: [ participantResizeAssessment := nil ]
		ifNotNil: [
			participantResizeAssessment := participantResizeOperation assess.
			participantResizeAssessment isApplicable ifFalse: [
				^ self rejectedBecause: participantResizeAssessment rejectionMessage ] ].
	assessment := CPAtelierCreateLaneAssessment
		lane: lane
		laneSet: laneSet
		shape: shape
		createsLaneSet: createsLaneSet
		proposedLaneSets: proposedLaneSets
		proposedLanes: proposedLanes
		proposedDiagramElements: proposedElements.
	assessment
		participantResizeOperation: participantResizeOperation;
		participantResizeAssessment: participantResizeAssessment;
		proposedFlowNodeRefs: proposedFlowNodeRefs.
	^ assessment
]

{ #category : 'applying' }
CPAtelierCreateLane >> applyAssessment: anAssessment [
	| laneSetsDescription laneSetMemento lanesDescription diagram diagramContext |
	laneSetsDescription := processMemento magritteDescription
		detect: [ :each | each handlesSelector: #laneSets ].
	anAssessment createsLaneSet ifTrue: [
		processMemento write: anAssessment proposedLaneSets using: laneSetsDescription ].
	laneSetMemento := processMemento
		childMementoFor: anAssessment laneSet
		inRelation: laneSetsDescription.
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	laneSetMemento write: anAssessment proposedLanes using: lanesDescription.
	anAssessment proposedFlowNodeRefs ifNotNil: [ :flowNodeRefs |
		| laneMemento flowNodeRefsDescription |
		laneMemento := laneSetMemento
			childMementoFor: anAssessment lane
			inRelation: lanesDescription.
		flowNodeRefsDescription := laneMemento magritteDescription
			detect: [ :each | each handlesSelector: #flowNodeRefs ].
		laneMemento write: flowNodeRefs using: flowNodeRefsDescription ].

	diagramContext := self stagedDiagramContext.
	diagramContext writeElements: anAssessment proposedDiagramElements.
	anAssessment participantResizeOperation ifNotNil: [ :anOperation |
		anOperation applyAssessment: anAssessment participantResizeAssessment ]
]

{ #category : 'private - assessing' }
CPAtelierCreateLane >> participantResizeOperationForFirstLane [
	| collaborationContext participant participantShapes participantShape participantBounds headerWidth proposedLeft requiredWidth requiredHeight proposedRight proposedBottom proposedBounds |
	collaborationContext := self stagedCollaborationContext.
	collaborationContext ifNil: [ ^ nil ].
	participant := collaborationContext participantForProcess: processMemento model.
	participant ifNil: [ ^ nil ].
	participantShapes := collaborationContext diagramContext shapesForModelElement: participant.
	participantShapes size = 1 ifFalse: [ ^ nil ].
	participantShape := participantShapes anyOne.
	participantBounds := collaborationContext diagramContext boundsOf: participantShape.
	headerWidth := self laneHeaderWidth.
	proposedLeft := participantBounds left - headerWidth.
	requiredWidth := CPParticipantShapeElement processContentOriginOffset x + bounds width.
	requiredHeight := bounds height.
	proposedRight := participantBounds right max: proposedLeft + requiredWidth.
	proposedBottom := participantBounds bottom max: participantBounds top + requiredHeight.
	proposedBounds := proposedLeft @ participantBounds top
		corner: proposedRight @ proposedBottom.
	^ CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: proposedBounds
		processMemento: processMemento
		collaborationContext: collaborationContext
		processDiagramContext: diagramContext
]

{ #category : 'private - geometry' }
CPAtelierCreateLane >> laneHeaderWidth [
	^ CPLaneShapeElement laneHeaderWidth
]

{ #category : 'private' }
CPAtelierCreateLane >> rejectedBecause: aString [
	^ CPAtelierCreateLaneAssessment lane: lane rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierCreateLane >> lane: anObject [ lane := anObject ]
{ #category : 'accessing' }
CPAtelierCreateLane >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierCreateLane >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'private - staged state' }
CPAtelierCreateLane >> stagedDiagramContext [
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierCreateLane >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]

{ #category : 'private - staged state' }
CPAtelierCreateLane >> stagedCollaborationContext [
	collaborationContext ifNotNil: [ ^ collaborationContext ].
	^ CPProcessCollaborationContext inRootMemento: processMemento
]

{ #category : 'accessing' }
CPAtelierCreateLane >> collaborationContext: aContext [ collaborationContext := aContext ]
