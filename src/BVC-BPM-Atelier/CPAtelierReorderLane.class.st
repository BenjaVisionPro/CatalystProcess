"
I reorder one existing Lane before or after one sibling Lane in the same staged LaneSet.

Lane ordering is semantic state, but reordering also changes the physical partition
occupied by each Lane. I preserve each Lane's current partition length and translate
each reordered Lane subtree into its new slot. FlowNodes referenced by that subtree
move by the same translation. Sequence-flow routing follows those per-node translations:
a path whose endpoints move together translates completely; otherwise only moved
terminal waypoints translate.

I do not move a Lane between LaneSets. Hierarchy changes are a different operation.
"
Class {
	#name : 'CPAtelierReorderLane',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'lane',
		'targetLane',
		'insertAfter',
		'processMemento',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReorderLane class >> lane: aLane relativeTo: aTargetLane after: aBoolean processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		lane: aLane;
		targetLane: aTargetLane;
		insertAfter: aBoolean;
		processMemento: aMemento;
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierReorderLane >> assess [
	| laneContext laneSet targetLaneSet laneSetMemento lanesDescription lanes proposedLanes targetIndex
	  sourceShapes sourceShape isHorizontal cursor proposedLaneBoundsByShape proposedFlowNodeBoundsByShape
	  deltaByModelElement proposedWaypointsByEdge |
	lane ifNil: [ ^ self rejectedBecause: 'A Lane is required.' ].
	targetLane ifNil: [ ^ self rejectedBecause: 'A target Lane is required.' ].
	lane == targetLane ifTrue: [ ^ self rejectedBecause: 'The Lane is already at the requested target.' ].

	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	laneSet := laneContext laneSetContainingLane: lane.
	targetLaneSet := laneContext laneSetContainingLane: targetLane.
	laneSet ifNil: [ ^ self rejectedBecause: 'The Lane is not in the staged Lane hierarchy.' ].
	targetLaneSet == laneSet ifFalse: [ ^ self rejectedBecause: 'A Lane can only be reordered within its current LaneSet.' ].

	laneSetMemento := laneContext mementoForLaneSet: laneSet.
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	lanes := laneSetMemento readUsing: lanesDescription.
	((lanes identityIncludes: lane) and: [ lanes identityIncludes: targetLane ]) ifFalse: [
		^ self rejectedBecause: 'Both Lanes must have staged ordering positions.' ].

	proposedLanes := lanes asOrderedCollection copy.
	proposedLanes remove: lane.
	targetIndex := proposedLanes identityIndexOf: targetLane.
	targetIndex = 0 ifTrue: [ ^ self rejectedBecause: 'The target Lane has no staged ordering position.' ].
	proposedLanes
		add: lane
		beforeIndex: (insertAfter ifTrue: [ targetIndex + 1 ] ifFalse: [ targetIndex ]).
	(proposedLanes size = lanes size
		and: [ (1 to: lanes size) allSatisfy: [ :index | (proposedLanes at: index) == (lanes at: index) ] ])
		ifTrue: [ ^ self rejectedBecause: 'The Lane is already at the requested position.' ].
	[ lanesDescription validate: proposedLanes ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	sourceShapes := diagramContext shapesForModelElement: lane.
	sourceShapes size = 1 ifFalse: [ ^ self rejectedBecause: 'The reordered Lane must have exactly one diagram shape.' ].
	sourceShape := sourceShapes anyOne.
	isHorizontal := self stagedIsHorizontalOf: sourceShape.
	cursor := (lanes collect: [ :each |
		| shapes |
		shapes := diagramContext shapesForModelElement: each.
		shapes size = 1 ifFalse: [ ^ self rejectedBecause: 'Every sibling Lane must have exactly one diagram shape.' ].
		CPPoolLaneGeometry
			partitionStartOf: (diagramContext boundsOf: shapes anyOne)
			horizontal: isHorizontal ]) min.

	proposedLaneBoundsByShape := IdentityDictionary new.
	proposedFlowNodeBoundsByShape := IdentityDictionary new.
	deltaByModelElement := IdentityDictionary new.

	proposedLanes do: [ :aLane |
		| shapes laneShape currentBounds currentStart laneLength delta |
		shapes := diagramContext shapesForModelElement: aLane.
		shapes size = 1 ifFalse: [ ^ self rejectedBecause: 'Every sibling Lane must have exactly one diagram shape.' ].
		laneShape := shapes anyOne.
		currentBounds := diagramContext boundsOf: laneShape.
		currentStart := CPPoolLaneGeometry partitionStartOf: currentBounds horizontal: isHorizontal.
		laneLength := CPPoolLaneGeometry partitionLengthOf: currentBounds horizontal: isHorizontal.
		delta := cursor - currentStart.
		delta isZero ifFalse: [
			(self
				addLaneSubtree: aLane
				translatedBy: delta
				horizontal: isHorizontal
				using: laneContext
				intoLaneBounds: proposedLaneBoundsByShape
				flowNodeBounds: proposedFlowNodeBoundsByShape
				modelDeltas: deltaByModelElement) ifFalse: [
					^ self rejectedBecause: 'Every reordered Lane subtree must have valid diagram shapes.' ] ].
		cursor := cursor + laneLength ].

	self
		addAttachedBoundaryEventsForModelDeltas: deltaByModelElement
		intoBounds: proposedFlowNodeBoundsByShape.

	proposedWaypointsByEdge := self
		proposedWaypointsForModelDeltas: deltaByModelElement.

	^ CPAtelierReorderLaneAssessment new
		lane: lane;
		laneSet: laneSet;
		proposedLanes: proposedLanes;
		proposedLaneBoundsByShape: proposedLaneBoundsByShape;
		proposedFlowNodeBoundsByShape: proposedFlowNodeBoundsByShape;
		proposedWaypointsByEdge: proposedWaypointsByEdge;
		yourself
]

{ #category : 'applying' }
CPAtelierReorderLane >> applyAssessment: anAssessment [
	| laneContext laneSetMemento lanesDescription |
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	laneSetMemento := laneContext mementoForLaneSet: anAssessment laneSet.
	lanesDescription := laneSetMemento magritteDescription
		detect: [ :each | each handlesSelector: #lanes ].
	laneSetMemento write: anAssessment proposedLanes using: lanesDescription.

	anAssessment proposedLaneBoundsByShape keysAndValuesDo: [ :aShape :aRectangle |
		diagramContext writeBounds: aRectangle of: aShape ].
	anAssessment proposedFlowNodeBoundsByShape keysAndValuesDo: [ :aShape :aRectangle |
		diagramContext writeBounds: aRectangle of: aShape ].
	anAssessment proposedWaypointsByEdge keysAndValuesDo: [ :anEdge :someWaypoints |
		diagramContext writeWaypoints: someWaypoints of: anEdge ]
]

{ #category : 'private - assessing' }
CPAtelierReorderLane >> addLaneSubtree: aLane translatedBy: aLength horizontal: isHorizontal using: laneContext intoLaneBounds: laneBounds flowNodeBounds: flowNodeBounds modelDeltas: deltaByModelElement [
	| shapes laneShape translation childLaneSet |
	shapes := diagramContext shapesForModelElement: aLane.
	shapes size = 1 ifFalse: [ ^ false ].
	laneShape := shapes anyOne.
	translation := CPPoolLaneGeometry
		translationAlongPartitionBy: aLength
		horizontal: isHorizontal.
	laneBounds
		at: laneShape
		put: ((diagramContext boundsOf: laneShape) translateBy: translation).

	(laneContext stagedFlowNodeRefsOf: aLane) do: [ :aFlowNode |
		deltaByModelElement at: aFlowNode put: translation.
		(diagramContext shapesForModelElement: aFlowNode) do: [ :aShape |
			flowNodeBounds
				at: aShape
				put: ((diagramContext boundsOf: aShape) translateBy: translation) ] ].

	childLaneSet := laneContext stagedChildLaneSetOf: aLane.
	childLaneSet ifNotNil: [
		(laneContext stagedLanesInLaneSet: childLaneSet) do: [ :aChildLane |
			(self
				addLaneSubtree: aChildLane
				translatedBy: aLength
				horizontal: isHorizontal
				using: laneContext
				intoLaneBounds: laneBounds
				flowNodeBounds: flowNodeBounds
				modelDeltas: deltaByModelElement) ifFalse: [ ^ false ] ] ].
	^ true
]

{ #category : 'private - assessing' }
CPAtelierReorderLane >> addAttachedBoundaryEventsForModelDeltas: deltaByModelElement intoBounds: proposedBounds [
	deltaByModelElement keys copy do: [ :aModelElement |
		| flowContext delta |
		aModelElement isActivity ifTrue: [
			flowContext := CPProcessFlowContainerContext
				containingFlowElement: aModelElement
				inRootMemento: processMemento.
			flowContext ifNotNil: [
				delta := deltaByModelElement at: aModelElement.
				(flowContext attachedBoundaryEventsFor: aModelElement) do: [ :aBoundaryEvent |
					deltaByModelElement at: aBoundaryEvent put: delta.
					(diagramContext shapesForModelElement: aBoundaryEvent) do: [ :aShape |
						proposedBounds
							at: aShape
							put: ((diagramContext boundsOf: aShape) translateBy: delta) ] ] ] ] ]
]

{ #category : 'private - assessing' }
CPAtelierReorderLane >> proposedWaypointsForModelDeltas: deltaByModelElement [
	| proposed |
	proposed := IdentityDictionary new.
	diagramContext elements do: [ :anElement |
		anElement isEdge ifTrue: [
			| sequenceFlow flowContext source target sourceDelta targetDelta waypoints translated |
			sequenceFlow := diagramContext modelElementOf: anElement.
			flowContext := CPProcessFlowContainerContext
				containingFlowElement: sequenceFlow
				inRootMemento: processMemento.
			flowContext ifNotNil: [
				source := flowContext stagedSourceOf: sequenceFlow.
				target := flowContext stagedTargetOf: sequenceFlow.
				sourceDelta := deltaByModelElement at: source ifAbsent: [ nil ].
				targetDelta := deltaByModelElement at: target ifAbsent: [ nil ].
				(sourceDelta notNil or: [ targetDelta notNil ]) ifTrue: [
					waypoints := diagramContext waypointsOf: anElement.
					waypoints ifNotEmpty: [
						translated := waypoints asOrderedCollection copy.
						(sourceDelta notNil and: [ sourceDelta = targetDelta ])
							ifTrue: [
								1 to: translated size do: [ :index |
									translated at: index put: (translated at: index) + sourceDelta ] ]
							ifFalse: [
								sourceDelta ifNotNil: [
									translated at: 1 put: translated first + sourceDelta ].
								targetDelta ifNotNil: [
									translated at: translated size put: translated last + targetDelta ] ].
						proposed at: anElement put: translated ] ] ] ] ].
	^ proposed
]

{ #category : 'private - staged state' }
CPAtelierReorderLane >> stagedIsHorizontalOf: aShape [
	| shapeMemento description |
	shapeMemento := diagramContext mementoFor: aShape.
	shapeMemento ifNil: [ ^ aShape isHorizontal ].
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #isHorizontal ]
		ifNone: [ ^ aShape isHorizontal ].
	^ shapeMemento readUsing: description
]

{ #category : 'private' }
CPAtelierReorderLane >> rejectedBecause: aString [
	^ CPAtelierReorderLaneAssessment new
		lane: lane;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierReorderLane >> lane: anObject [ lane := anObject ]
{ #category : 'accessing' }
CPAtelierReorderLane >> targetLane: anObject [ targetLane := anObject ]
{ #category : 'accessing' }
CPAtelierReorderLane >> insertAfter: aBoolean [ insertAfter := aBoolean ]
{ #category : 'accessing' }
CPAtelierReorderLane >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierReorderLane >> diagramContext: aContext [ diagramContext := aContext ]
