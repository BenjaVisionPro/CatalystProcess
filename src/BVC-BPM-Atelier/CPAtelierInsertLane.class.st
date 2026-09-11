"I insert one fresh Lane before or after an existing Lane in the same staged LaneSet.

I preserve Lane ordering, create the Lane CPShape, shift later Lane DI to make space, move the FlowNodes referenced by shifted Lane subtrees through CPAtelierMoveShapes, and grow the hosting Participant only when the proposed Lane structure no longer fits its current height."
Class {
	#name : 'CPAtelierInsertLane',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'lane',
		'targetLane',
		'insertAfter',
		'processMemento',
		'diagramContext',
		'collaborationContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierInsertLane class >> lane: aLane relativeTo: aTargetLane after: aBoolean processMemento: aMemento diagramContext: aDiagramContext [
	^ self new lane: aLane; targetLane: aTargetLane; insertAfter: aBoolean; processMemento: aMemento; diagramContext: aDiagramContext; yourself
]

{ #category : 'instance creation' }
CPAtelierInsertLane class >> lane: aLane relativeTo: aTargetLane after: aBoolean processMemento: aMemento diagramContext: aDiagramContext collaborationContext: aCollaborationContext [
	^ self new lane: aLane; targetLane: aTargetLane; insertAfter: aBoolean; processMemento: aMemento; diagramContext: aDiagramContext; collaborationContext: aCollaborationContext; yourself
]

{ #category : 'assessing' }
CPAtelierInsertLane >> assess [
	| laneContext laneSet laneSetMemento lanesDescription lanes targetIndex insertionIndex diagram diagramContext targetShapes targetShape targetBounds minimumLaneHeight targetMinimumHeight canSplit newLaneHeight newBounds targetProposedBounds shape elements proposedElements proposedLanes proposedLaneBoundsByShape shiftedLanes shiftAmount flowNodeBoundsByShape moveOperation moveAssessment participantResizeOperation participantResizeAssessment |
	lane ifNil: [ ^ self rejectedBecause: 'A fresh Lane is required.' ].
	targetLane ifNil: [ ^ self rejectedBecause: 'A target Lane is required.' ].
	lane == targetLane ifTrue: [ ^ self rejectedBecause: 'The inserted Lane must differ from the target Lane.' ].

	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	laneSet := laneContext laneSetContainingLane: targetLane.
	laneSet ifNil: [ ^ self rejectedBecause: 'The target Lane is not in the staged Process Lane hierarchy.' ].
	(laneContext stagedChildLaneSetOf: targetLane) ifNotNil: [
		^ self rejectedBecause: 'Insertion into a Lane with a nested LaneSet is not yet supported.' ].
	laneSetMemento := laneContext mementoForLaneSet: laneSet.
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	lanes := laneSetMemento readUsing: lanesDescription.
	(lanes identityIncludes: lane) ifTrue: [ ^ self rejectedBecause: 'The Lane is already present in the target LaneSet.' ].
	targetIndex := lanes identityIndexOf: targetLane.
	targetIndex = 0 ifTrue: [ ^ self rejectedBecause: 'The target Lane has no staged ordering position.' ].
	insertionIndex := insertAfter ifTrue: [ targetIndex + 1 ] ifFalse: [ targetIndex ].

	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [ ^ self rejectedBecause: 'The Process has no staged diagram.' ].
	targetShapes := diagramContext shapesForModelElement: targetLane.
	targetShapes size = 1 ifFalse: [ ^ self rejectedBecause: 'The target Lane must have exactly one diagram shape.' ].
	targetShape := targetShapes anyOne.
	targetBounds := diagramContext boundsOf: targetShape.
	targetBounds height > 0 ifFalse: [ ^ self rejectedBecause: 'The target Lane must have positive height.' ].

	minimumLaneHeight := self minimumLaneHeight.
	targetMinimumHeight := CPAtelierLaneLayout
		minimumHeightForLane: targetLane
		using: laneContext
		diagramContext: diagramContext.
	canSplit := targetBounds height >= (targetMinimumHeight + minimumLaneHeight).
	proposedLaneBoundsByShape := IdentityDictionary new.
	shiftedLanes := OrderedCollection new.
	shiftAmount := 0.

	canSplit
		ifTrue: [
			newLaneHeight := (targetBounds height / 2)
				max: minimumLaneHeight.
			newLaneHeight := newLaneHeight
				min: (targetBounds height - targetMinimumHeight).
			insertAfter
				ifTrue: [
					targetProposedBounds := targetBounds origin
						extent: targetBounds width @ newLaneHeight.
					newBounds := (targetBounds origin + (0 @ newLaneHeight))
						extent: targetBounds width @ newLaneHeight ]
				ifFalse: [
					newBounds := targetBounds origin
						extent: targetBounds width @ newLaneHeight.
					targetProposedBounds := (targetBounds origin + (0 @ newLaneHeight))
						extent: targetBounds width @ newLaneHeight.
					shiftedLanes add: targetLane.
					shiftAmount := newLaneHeight ].
			proposedLaneBoundsByShape at: targetShape put: targetProposedBounds ]
		ifFalse: [
			newLaneHeight := minimumLaneHeight.
			insertAfter
				ifTrue: [
					newBounds := (targetBounds origin + (0 @ targetBounds height))
						extent: targetBounds width @ newLaneHeight.
					(targetIndex + 1) to: lanes size do: [ :index |
						shiftedLanes add: (lanes at: index) ] ]
				ifFalse: [
					newBounds := targetBounds origin
						extent: targetBounds width @ newLaneHeight.
					targetIndex to: lanes size do: [ :index |
						shiftedLanes add: (lanes at: index) ] ].
			shiftAmount := newLaneHeight.
			shiftedLanes do: [ :aLane |
				| shapes laneShape currentBounds |
				shapes := diagramContext shapesForModelElement: aLane.
				shapes size = 1 ifFalse: [
					^ self rejectedBecause: 'Every shifted Lane must have exactly one diagram shape.' ].
				laneShape := shapes anyOne.
				currentBounds := diagramContext boundsOf: laneShape.
				proposedLaneBoundsByShape
					at: laneShape
					put: (currentBounds translateBy: 0 @ shiftAmount) ] ].

	shape := CPShape new modelElement: lane; bounds: newBounds; yourself.
	proposedLanes := lanes asOrderedCollection copy.
	proposedLanes add: lane beforeIndex: insertionIndex.
	[ lanesDescription validate: proposedLanes ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	elements := diagramContext elements.
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	flowNodeBoundsByShape := IdentityDictionary new.
	shiftedLanes do: [ :aLane |
		(laneContext stagedFlowNodeRefsOf: aLane) do: [ :aFlowNode |
			(diagramContext shapesForModelElement: aFlowNode) do: [ :aFlowNodeShape |
				flowNodeBoundsByShape
					at: aFlowNodeShape
					put: ((diagramContext boundsOf: aFlowNodeShape) translateBy: 0 @ shiftAmount) ] ] ].
	flowNodeBoundsByShape
		ifEmpty: [
			moveOperation := nil.
			moveAssessment := nil ]
		ifNotEmpty: [
			moveOperation := CPAtelierMoveShapes
				boundsByShape: flowNodeBoundsByShape
				processMemento: processMemento
				diagramContext: diagramContext.
			moveAssessment := moveOperation assess.
			moveAssessment isApplicable ifFalse: [
				^ self rejectedBecause: moveAssessment rejectionMessage ] ].

	participantResizeOperation := canSplit
		ifTrue: [ nil ]
		ifFalse: [ self participantResizeOperationGrowingBy: newLaneHeight ].
	participantResizeOperation
		ifNil: [ participantResizeAssessment := nil ]
		ifNotNil: [
			participantResizeAssessment := participantResizeOperation assess.
			participantResizeAssessment isApplicable ifFalse: [
				^ self rejectedBecause: participantResizeAssessment rejectionMessage ] ].

	^ CPAtelierInsertLaneAssessment new
		lane: lane;
		laneSet: laneSet;
		shape: shape;
		proposedLanes: proposedLanes;
		proposedDiagramElements: proposedElements;
		proposedLaneBoundsByShape: proposedLaneBoundsByShape;
		flowNodeMoveOperation: moveOperation;
		flowNodeMoveAssessment: moveAssessment;
		participantResizeOperation: participantResizeOperation;
		participantResizeAssessment: participantResizeAssessment;
		yourself
]

{ #category : 'applying' }
CPAtelierInsertLane >> applyAssessment: anAssessment [
	| laneContext laneSetMemento lanesDescription diagram diagramContext |
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	laneSetMemento := laneContext mementoForLaneSet: anAssessment laneSet.
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	laneSetMemento write: anAssessment proposedLanes using: lanesDescription.

	diagramContext := self stagedDiagramContext.
	diagramContext writeElements: anAssessment proposedDiagramElements.

	anAssessment proposedLaneBoundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
		| shapeMemento boundsDescription |
		shapeMemento := diagramContext mementoFor: aShape.
		boundsDescription := shapeMemento magritteDescription
			detect: [ :each | each handlesSelector: #bounds ].
		shapeMemento write: proposedBounds using: boundsDescription ].

	anAssessment flowNodeMoveOperation ifNotNil: [ :anOperation |
		anOperation applyAssessment: anAssessment flowNodeMoveAssessment ].
	anAssessment participantResizeOperation ifNotNil: [ :anOperation |
		| resizeAssessment reflowOperation |
		resizeAssessment := anAssessment participantResizeAssessment.
		anOperation applyAssessment: resizeAssessment.
		reflowOperation := CPAtelierResizeParticipantShape
			shape: resizeAssessment shape
			bounds: resizeAssessment proposedBounds
			processMemento: processMemento
			collaborationContext: self stagedCollaborationContext
			processDiagramContext: diagramContext.
		reflowOperation applyLaneReflowForParticipantBounds: resizeAssessment proposedBounds ]
]

{ #category : 'private - assessing' }
CPAtelierInsertLane >> participantResizeOperationGrowingBy: aHeight [
	| collaborationContext participant participantShapes participantShape participantBounds proposedBounds |
	collaborationContext := self stagedCollaborationContext.
	collaborationContext ifNil: [ ^ nil ].
	participant := collaborationContext participantForProcess: processMemento model.
	participant ifNil: [ ^ nil ].
	participantShapes := collaborationContext diagramContext shapesForModelElement: participant.
	participantShapes size = 1 ifFalse: [ ^ nil ].
	participantShape := participantShapes anyOne.
	participantBounds := collaborationContext diagramContext boundsOf: participantShape.
	proposedBounds := participantBounds origin
		extent: participantBounds width @ (participantBounds height + aHeight).
	^ CPAtelierResizeParticipantFrame
		shape: participantShape
		bounds: proposedBounds
		processMemento: processMemento
		collaborationContext: collaborationContext
]

{ #category : 'private - geometry' }
CPAtelierInsertLane >> minimumLaneHeight [
	^ CPAtelierLaneLayout minimumLaneHeight
]

{ #category : 'private' }
CPAtelierInsertLane >> rejectedBecause: aString [
	^ CPAtelierInsertLaneAssessment new
		lane: lane;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierInsertLane >> lane: anObject [ lane := anObject ]
{ #category : 'accessing' }
CPAtelierInsertLane >> targetLane: anObject [ targetLane := anObject ]
{ #category : 'accessing' }
CPAtelierInsertLane >> insertAfter: aBoolean [ insertAfter := aBoolean ]
{ #category : 'accessing' }
CPAtelierInsertLane >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'private - staged state' }
CPAtelierInsertLane >> stagedDiagramContext [
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierInsertLane >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]

{ #category : 'private - staged state' }
CPAtelierInsertLane >> stagedCollaborationContext [
	collaborationContext ifNotNil: [ ^ collaborationContext ].
	^ CPProcessCollaborationContext inRootMemento: processMemento
]

{ #category : 'accessing' }
CPAtelierInsertLane >> collaborationContext: aContext [ collaborationContext := aContext ]
