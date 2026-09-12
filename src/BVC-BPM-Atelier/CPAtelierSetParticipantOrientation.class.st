"I rotate one Participant Pool between BPMN-DI horizontal and vertical orientation.

Orientation conversion is a rigid quarter-turn of the Pool coordinate system, not a Lane reflow. The Participant keeps its centre and swaps width/height. Lane rectangles rotate with the Pool. FlowNode centres and Sequence Flow waypoints follow the same quarter-turn, while FlowNode extents remain unchanged so their presentation stays upright. The semantic Participant, Lane hierarchy and FlowNodes are unchanged."
Class {
	#name : 'CPAtelierSetParticipantOrientation',
	#superclass : 'CPAtelierResizeParticipantShape',
	#instVars : [
		'isHorizontal'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetParticipantOrientation class >> horizontalShape: aShape processMemento: aMemento collaborationContext: aCollaborationContext processDiagramContext: aDiagramContext [
	^ self new
		shape: aShape;
		processMemento: aMemento;
		collaborationContext: aCollaborationContext;
		processDiagramContext: aDiagramContext;
		isHorizontal: true;
		yourself
]

{ #category : 'instance creation' }
CPAtelierSetParticipantOrientation class >> verticalShape: aShape processMemento: aMemento collaborationContext: aCollaborationContext processDiagramContext: aDiagramContext [
	^ self new
		shape: aShape;
		processMemento: aMemento;
		collaborationContext: aCollaborationContext;
		processDiagramContext: aDiagramContext;
		isHorizontal: false;
		yourself
]

{ #category : 'assessing' }
CPAtelierSetParticipantOrientation >> assess [
	| context shapeMemento orientationDescription currentOrientation participant currentBounds proposedBounds laneContext diagramContext currentBodyExtent proposedLaneBounds proposedFlowNodeBounds proposedWaypoints proposedCollaborationWaypoints validationError laneShapes boundaryShapes boundaryDeltasByModelElement |
	shape ifNil: [ ^ self rejectedBecause: 'A Participant diagram shape is required.' ].
	context := self stagedCollaborationContext.
	context ifNil: [ ^ self rejectedBecause: 'The Process has no staged definitional Collaboration diagram.' ].
	(context elements identityIncludes: shape) ifFalse: [
		^ self rejectedBecause: 'The Participant shape is not in the staged Collaboration diagram.' ].
	shapeMemento := context diagramContext mementoFor: shape.
	shapeMemento ifNil: [ ^ self rejectedBecause: 'The Participant shape has no staged diagram memento.' ].
	participant := context diagramContext modelElementOf: shape.
	(participant notNil and: [ participant isParticipant ]) ifFalse: [
		^ self rejectedBecause: 'The diagram shape must depict a Participant.' ].
	orientationDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #isHorizontal ]
		ifNone: [ ^ self rejectedBecause: 'The Participant shape does not describe BPMN-DI orientation.' ].
	currentOrientation := shapeMemento readUsing: orientationDescription.
	currentOrientation = isHorizontal ifTrue: [
		^ self rejectedBecause: 'The Pool already has the requested orientation.' ].
	currentBounds := context diagramContext boundsOf: shape.
	currentBounds ifNil: [ ^ self rejectedBecause: 'The Participant shape has no staged bounds.' ].
	proposedBounds := self rotatedParticipantBoundsFrom: currentBounds.

	proposedLaneBounds := IdentityDictionary new.
	proposedFlowNodeBounds := IdentityDictionary new.
	proposedWaypoints := IdentityDictionary new.
	proposedCollaborationWaypoints := self
		proposedCollaborationWaypointsIn: context
		participant: participant
		around: currentBounds center.

	(context processRefOf: participant) == processMemento model ifTrue: [
		laneContext := CPProcessLaneContext inRootMemento: processMemento.
		diagramContext := self stagedProcessDiagramContext.
		diagramContext ifNil: [ ^ self rejectedBecause: 'The hosted Process has no staged diagram context.' ].
		currentBodyExtent := self currentProcessBodyExtentForParticipantBounds: currentBounds.
		laneShapes := IdentitySet new.
		boundaryShapes := OrderedCollection new.
		boundaryDeltasByModelElement := IdentityDictionary new.

		laneContext stagedLanes do: [ :aLane |
			| shapes laneShape laneBounds rotatedBounds |
			shapes := diagramContext shapesForModelElement: aLane.
			shapes size = 1 ifFalse: [
				^ self rejectedBecause: 'Every rotated Lane must have exactly one diagram shape.' ].
			laneShape := shapes anyOne.
			laneShapes add: laneShape.
			laneBounds := diagramContext boundsOf: laneShape.
			laneBounds ifNil: [ ^ self rejectedBecause: 'Every rotated Lane must have staged diagram bounds.' ].
			rotatedBounds := self
				rotateStructuralBounds: laneBounds
				within: currentBodyExtent.
			proposedLaneBounds at: laneShape put: rotatedBounds ].

		diagramContext elements do: [ :anElement |
			anElement isShape ifTrue: [
				(laneShapes identityIncludes: anElement) ifFalse: [
					| modelElement currentNodeBounds proposedNodeBounds |
					modelElement := diagramContext modelElementOf: anElement.
					(modelElement notNil and: [ modelElement isBoundaryEvent ])
						ifTrue: [ boundaryShapes add: anElement ]
						ifFalse: [
							currentNodeBounds := diagramContext boundsOf: anElement.
							currentNodeBounds ifNil: [
								^ self rejectedBecause: 'Every rotated FlowNode must have staged diagram bounds.' ].
							proposedNodeBounds := self
								rotateUprightBounds: currentNodeBounds
								within: currentBodyExtent.
							validationError := self
								validationErrorForBounds: proposedNodeBounds
								of: anElement
								in: diagramContext.
							validationError ifNotNil: [ ^ self rejectedBecause: validationError ].
							proposedFlowNodeBounds at: anElement put: proposedNodeBounds ] ] ] ].

		boundaryShapes do: [ :aBoundaryShape |
			| boundaryEvent flowContext activity activityShapes activityShape currentBoundaryBounds currentActivityBounds proposedActivityBounds rigidBoundaryBounds proposedBoundaryBounds delta |
			boundaryEvent := diagramContext modelElementOf: aBoundaryShape.
			flowContext := CPProcessFlowContainerContext
				containingFlowElement: boundaryEvent
				inRootMemento: processMemento.
			flowContext ifNil: [ ^ self rejectedBecause: 'Every rotated Boundary Event must have a staged flow-container context.' ].
			activity := flowContext stagedAttachedToOf: boundaryEvent.
			activity ifNil: [ ^ self rejectedBecause: 'Every rotated Boundary Event must have an attached Activity.' ].
			activityShapes := diagramContext shapesForModelElement: activity.
			activityShapes size = 1 ifFalse: [
				^ self rejectedBecause: 'Every Activity with a rotated Boundary Event must have exactly one diagram shape.' ].
			activityShape := activityShapes anyOne.
			currentBoundaryBounds := diagramContext boundsOf: aBoundaryShape.
			currentActivityBounds := diagramContext boundsOf: activityShape.
			proposedActivityBounds := proposedFlowNodeBounds at: activityShape ifAbsent: [
				^ self rejectedBecause: 'The attached Activity must have proposed bounds before its Boundary Event is rotated.' ].
			rigidBoundaryBounds := self
				rotateUprightBounds: currentBoundaryBounds
				within: currentBodyExtent.
			proposedBoundaryBounds := CPPoolLaneGeometry
				rotateBoundaryEventBounds: currentBoundaryBounds
				fromActivityBounds: currentActivityBounds
				toActivityBounds: proposedActivityBounds
				toHorizontal: isHorizontal.
			validationError := self
				validationErrorForBounds: proposedBoundaryBounds
				of: aBoundaryShape
				in: diagramContext.
			validationError ifNotNil: [ ^ self rejectedBecause: validationError ].
			proposedFlowNodeBounds at: aBoundaryShape put: proposedBoundaryBounds.
			delta := proposedBoundaryBounds origin - rigidBoundaryBounds origin.
			boundaryDeltasByModelElement at: boundaryEvent put: delta ].

		diagramContext elements do: [ :anElement |
			anElement isEdge ifTrue: [
				| modelElement flowContext waypoints source target sourceDelta targetDelta |
				waypoints := ((diagramContext waypointsOf: anElement)
					collect: [ :aPoint | self rotateProcessPoint: aPoint within: currentBodyExtent ]) asOrderedCollection.
				modelElement := diagramContext modelElementOf: anElement.
				flowContext := modelElement ifNotNil: [
					CPProcessFlowContainerContext
						containingFlowElement: modelElement
						inRootMemento: processMemento ].
				flowContext ifNotNil: [
					source := flowContext stagedSourceOf: modelElement.
					target := flowContext stagedTargetOf: modelElement.
					sourceDelta := boundaryDeltasByModelElement at: source ifAbsent: [ 0 @ 0 ].
					targetDelta := boundaryDeltasByModelElement at: target ifAbsent: [ 0 @ 0 ].
					(sourceDelta isZero or: [ waypoints isEmpty ]) ifFalse: [
						waypoints at: 1 put: waypoints first + sourceDelta ].
					(targetDelta isZero or: [ waypoints isEmpty ]) ifFalse: [
						waypoints at: waypoints size put: waypoints last + targetDelta ] ].
				proposedWaypoints at: anElement put: waypoints ] ].
	].

	^ CPAtelierResizeParticipantAssessment new
		shape: shape;
		currentBounds: currentBounds;
		proposedBounds: proposedBounds;
		proposedLaneBoundsByShape: proposedLaneBounds;
		proposedFlowNodeBoundsByShape: proposedFlowNodeBounds;
		proposedWaypointsByEdge: proposedWaypoints;
		proposedCollaborationWaypointsByEdge: proposedCollaborationWaypoints;
		yourself
]

{ #category : 'applying' }
CPAtelierSetParticipantOrientation >> applyAssessment: anAssessment [
	| context shapeMemento orientationDescription laneContext diagramContext collaborationWaypoints |
	super applyAssessment: anAssessment.

	context := self stagedCollaborationContext.
	shapeMemento := context diagramContext mementoFor: shape.
	orientationDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #isHorizontal ].
	shapeMemento write: isHorizontal using: orientationDescription.

	(context processRefOf: (context diagramContext modelElementOf: shape)) == processMemento model ifTrue: [
		diagramContext := self stagedProcessDiagramContext.
		laneContext := CPProcessLaneContext inRootMemento: processMemento.
		laneContext stagedLanes do: [ :aLane |
			| shapes laneShape laneShapeMemento laneOrientationDescription |
			shapes := diagramContext shapesForModelElement: aLane.
			shapes size = 1 ifTrue: [
				laneShape := shapes anyOne.
				laneShapeMemento := diagramContext mementoFor: laneShape.
				laneOrientationDescription := laneShapeMemento magritteDescription
					detect: [ :each | each handlesSelector: #isHorizontal ].
				laneShapeMemento write: isHorizontal using: laneOrientationDescription ] ] ].

	collaborationWaypoints := anAssessment proposedCollaborationWaypointsByEdge.
	collaborationWaypoints ifNotNil: [
		collaborationWaypoints keysAndValuesDo: [ :anEdge :waypoints |
			context diagramContext writeWaypoints: waypoints of: anEdge ] ]
]

{ #category : 'private - geometry' }
CPAtelierSetParticipantOrientation >> currentProcessBodyExtentForParticipantBounds: participantBounds [
	| currentOrientationOffset |
	currentOrientationOffset := CPPoolLaneGeometry
		participantContentOriginOffsetForHorizontal: isHorizontal not.
	^ participantBounds extent - currentOrientationOffset
]

{ #category : 'private - geometry' }
CPAtelierSetParticipantOrientation >> rotateProcessPoint: aPoint within: currentBodyExtent [
	^ CPPoolLaneGeometry
		rotateProcessPoint: aPoint
		within: currentBodyExtent
		toHorizontal: isHorizontal
]

{ #category : 'private - geometry' }
CPAtelierSetParticipantOrientation >> rotateStructuralBounds: aRectangle within: currentBodyExtent [
	^ CPPoolLaneGeometry
		rotateStructuralBounds: aRectangle
		within: currentBodyExtent
		toHorizontal: isHorizontal
]

{ #category : 'private - geometry' }
CPAtelierSetParticipantOrientation >> rotateUprightBounds: aRectangle within: currentBodyExtent [
	^ CPPoolLaneGeometry
		rotateUprightBounds: aRectangle
		within: currentBodyExtent
		toHorizontal: isHorizontal
]

{ #category : 'private - geometry' }
CPAtelierSetParticipantOrientation >> rotatedParticipantBoundsFrom: aRectangle [
	^ CPPoolLaneGeometry rotatedParticipantBoundsFrom: aRectangle
]

{ #category : 'private - geometry' }
CPAtelierSetParticipantOrientation >> rotateCollaborationPoint: aPoint around: aCenter [
	^ CPPoolLaneGeometry
		rotateCollaborationPoint: aPoint
		around: aCenter
		toHorizontal: isHorizontal
]

{ #category : 'private - assessing' }
CPAtelierSetParticipantOrientation >> proposedCollaborationWaypointsIn: context participant: participant around: participantCenter [
	| proposed |
	proposed := IdentityDictionary new.
	context elements do: [ :anElement |
		anElement isEdge ifTrue: [
			| messageFlow source target waypoints rotated changed |
			messageFlow := context diagramContext modelElementOf: anElement.
			(messageFlow notNil and: [ context messageFlows identityIncludes: messageFlow ]) ifTrue: [
				source := self stagedSourceOf: messageFlow in: context.
				target := self stagedTargetOf: messageFlow in: context.
				waypoints := context diagramContext waypointsOf: anElement.
				waypoints ifNotEmpty: [
					rotated := waypoints asOrderedCollection copy.
					changed := false.
					(self endpoint: source isRepresentedBy: participant in: context) ifTrue: [
						rotated at: 1 put: (self rotateCollaborationPoint: rotated first around: participantCenter).
						changed := true ].
					(self endpoint: target isRepresentedBy: participant in: context) ifTrue: [
						rotated at: rotated size put: (self rotateCollaborationPoint: rotated last around: participantCenter).
						changed := true ].
					changed ifTrue: [ proposed at: anElement put: rotated ] ] ] ] ].
	^ proposed
]

{ #category : 'private' }
CPAtelierSetParticipantOrientation >> rejectedBecause: aString [
	^ CPAtelierMoveShapeAssessment
		shape: shape
		currentBounds: nil
		proposedBounds: nil
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierSetParticipantOrientation >> isHorizontal: aBoolean [
	isHorizontal := aBoolean
]
