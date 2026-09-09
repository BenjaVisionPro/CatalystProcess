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
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierInsertLane class >> lane: aLane relativeTo: aTargetLane after: aBoolean processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new
		lane: aLane;
		targetLane: aTargetLane;
		insertAfter: aBoolean;
		processMemento: aMemento;
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierInsertLane >> assess [
	| laneContext laneSet laneSetMemento lanesDescription lanes targetIndex insertionIndex diagram diagramContext targetShapes targetShape targetBounds laneHeight newBounds shape elements proposedElements proposedLanes shiftedLanes proposedLaneBoundsByShape flowNodeBoundsByShape moveOperation moveAssessment participantResizeOperation participantResizeAssessment |
	lane ifNil: [ ^ self rejectedBecause: 'A fresh Lane is required.' ].
	targetLane ifNil: [ ^ self rejectedBecause: 'A target Lane is required.' ].
	lane == targetLane ifTrue: [ ^ self rejectedBecause: 'The inserted Lane must differ from the target Lane.' ].

	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	laneSet := laneContext laneSetContainingLane: targetLane.
	laneSet ifNil: [ ^ self rejectedBecause: 'The target Lane is not in the staged Process Lane hierarchy.' ].
	laneSetMemento := laneContext mementoForLaneSet: laneSet.
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	lanes := laneSetMemento readUsing: lanesDescription.
	(lanes identityIncludes: lane) ifTrue: [ ^ self rejectedBecause: 'The Lane is already present in the target LaneSet.' ].
	targetIndex := lanes identityIndexOf: targetLane.
	targetIndex = 0 ifTrue: [ ^ self rejectedBecause: 'The target Lane has no staged ordering position.' ].
	insertionIndex := insertAfter ifTrue: [ targetIndex + 1 ] ifFalse: [ targetIndex ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The Process has no staged diagram.' ].
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	targetShapes := diagramContext shapesForModelElement: targetLane.
	targetShapes size = 1 ifFalse: [ ^ self rejectedBecause: 'The target Lane must have exactly one diagram shape.' ].
	targetShape := targetShapes anyOne.
	targetBounds := diagramContext boundsOf: targetShape.
	laneHeight := targetBounds height.
	laneHeight > 0 ifFalse: [ ^ self rejectedBecause: 'The target Lane must have positive height.' ].
	newBounds := (targetBounds origin
		+ (0 @ (insertAfter ifTrue: [ laneHeight ] ifFalse: [ 0 ])))
		extent: targetBounds extent.
	shape := CPShape new modelElement: lane; bounds: newBounds; yourself.

	proposedLanes := lanes asOrderedCollection copy.
	proposedLanes add: lane beforeIndex: insertionIndex.
	[ lanesDescription validate: proposedLanes ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	elements := diagramContext elements.
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ diagramContext elementsDescription validate: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	shiftedLanes := OrderedCollection new.
	(insertAfter ifTrue: [ targetIndex + 1 ] ifFalse: [ targetIndex ])
		to: lanes size
		do: [ :index |
			self
				addLaneSubtree: (lanes at: index)
				using: laneContext
				to: shiftedLanes ].

	proposedLaneBoundsByShape := IdentityDictionary new.
	shiftedLanes do: [ :aLane |
		| shapes laneShape currentBounds |
		shapes := diagramContext shapesForModelElement: aLane.
		shapes size = 1 ifFalse: [
			^ self rejectedBecause: 'Every shifted Lane must have exactly one diagram shape.' ].
		laneShape := shapes anyOne.
		currentBounds := diagramContext boundsOf: laneShape.
		proposedLaneBoundsByShape
			at: laneShape
			put: (currentBounds translateBy: 0 @ laneHeight) ].

	flowNodeBoundsByShape := IdentityDictionary new.
	shiftedLanes do: [ :aLane |
		(laneContext stagedFlowNodeRefsOf: aLane) do: [ :aFlowNode |
			(diagramContext shapesForModelElement: aFlowNode) do: [ :aFlowNodeShape |
				flowNodeBoundsByShape
					at: aFlowNodeShape
					put: ((diagramContext boundsOf: aFlowNodeShape) translateBy: 0 @ laneHeight) ] ] ].
	flowNodeBoundsByShape
		ifEmpty: [
			moveOperation := nil.
			moveAssessment := nil ]
		ifNotEmpty: [
			moveOperation := CPAtelierMoveShapes
				boundsByShape: flowNodeBoundsByShape
				processMemento: processMemento
				diagramDescription: diagramDescription.
			moveAssessment := moveOperation assess.
			moveAssessment isApplicable ifFalse: [ ^ self rejectedBecause: moveAssessment rejectionMessage ] ].

	participantResizeOperation := self
		participantResizeOperationForNewLaneBounds: newBounds
		shiftedLaneBounds: proposedLaneBoundsByShape
		diagramContext: diagramContext.
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

	diagram := processMemento readUsing: diagramDescription.
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	diagramContext diagramMemento
		write: anAssessment proposedDiagramElements
		using: diagramContext elementsDescription.

	anAssessment proposedLaneBoundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
		| shapeMemento boundsDescription |
		shapeMemento := diagramContext mementoFor: aShape.
		boundsDescription := shapeMemento magritteDescription
			detect: [ :each | each handlesSelector: #bounds ].
		shapeMemento write: proposedBounds using: boundsDescription ].

	anAssessment flowNodeMoveOperation ifNotNil: [ :anOperation |
		anOperation applyAssessment: anAssessment flowNodeMoveAssessment ].
	anAssessment participantResizeOperation ifNotNil: [ :anOperation |
		anOperation applyAssessment: anAssessment participantResizeAssessment ]
]

{ #category : 'private - assessing' }
CPAtelierInsertLane >> addLaneSubtree: aLane using: laneContext to: someLanes [
	someLanes add: aLane.
	(laneContext stagedChildLaneSetOf: aLane) ifNotNil: [ :aChildLaneSet |
		(laneContext stagedLanesInLaneSet: aChildLaneSet) do: [ :aChildLane |
			self addLaneSubtree: aChildLane using: laneContext to: someLanes ] ]
]

{ #category : 'private - assessing' }
CPAtelierInsertLane >> participantResizeOperationForNewLaneBounds: newBounds shiftedLaneBounds: proposedLaneBoundsByShape diagramContext: diagramContext [
	| collaborationContext participant participantShapes participantShape participantBounds laneBounds minimumY maximumY requiredLaneHeight inset requiredPoolHeight proposedParticipantBounds |
	collaborationContext := CPProcessCollaborationContext inRootMemento: processMemento.
	collaborationContext ifNil: [ ^ nil ].
	participant := collaborationContext participantForProcess: processMemento model.
	participant ifNil: [ ^ nil ].
	participantShapes := collaborationContext diagramContext shapesForModelElement: participant.
	participantShapes size = 1 ifFalse: [ ^ nil ].
	participantShape := participantShapes anyOne.
	participantBounds := collaborationContext diagramContext boundsOf: participantShape.

	laneBounds := OrderedCollection with: newBounds.
	(CPProcessLaneContext inRootMemento: processMemento) stagedLanes do: [ :eachLane |
		(diagramContext shapesForModelElement: eachLane) do: [ :aShape |
			laneBounds add: (proposedLaneBoundsByShape
				at: aShape
				ifAbsent: [ diagramContext boundsOf: aShape ]) ] ].
	minimumY := laneBounds first top.
	maximumY := laneBounds first bottom.
	laneBounds do: [ :aRectangle |
		minimumY := minimumY min: aRectangle top.
		maximumY := maximumY max: aRectangle bottom ].
	requiredLaneHeight := maximumY - minimumY.
	inset := 24.
	requiredPoolHeight := requiredLaneHeight + (inset * 2).
	requiredPoolHeight <= participantBounds height ifTrue: [ ^ nil ].
	proposedParticipantBounds := participantBounds origin
		extent: participantBounds width @ requiredPoolHeight.
	^ CPAtelierResizeParticipantShape
		shape: participantShape
		bounds: proposedParticipantBounds
		processMemento: processMemento
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
{ #category : 'accessing' }
CPAtelierInsertLane >> diagramDescription: aDescription [ diagramDescription := aDescription ]
