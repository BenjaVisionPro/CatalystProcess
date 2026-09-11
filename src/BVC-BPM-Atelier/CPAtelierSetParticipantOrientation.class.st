"I change the BPMN-DI orientation of one Participant Pool.

The Participant and every Lane shape in its hosted Process change orientation together. When the Participant hosts the edited Process I also calculate the complete Lane reflow, FlowNode translations and Sequence Flow waypoint changes before writing anything. The semantic Participant/Lane model is unchanged."
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
	| context shapeMemento orientationDescription currentOrientation participant currentBounds laneContext diagramContext minimum proposedLaneBounds proposedFlowNodeBounds proposedWaypoints validationError |
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

	proposedLaneBounds := IdentityDictionary new.
	proposedFlowNodeBounds := IdentityDictionary new.
	proposedWaypoints := IdentityDictionary new.

	(context processRefOf: participant) == processMemento model ifTrue: [
		laneContext := CPProcessLaneContext inRootMemento: processMemento.
		diagramContext := self stagedProcessDiagramContext.
		diagramContext ifNil: [ ^ self rejectedBecause: 'The hosted Process has no staged diagram context.' ].

		laneContext stagedLaneSets ifNotEmpty: [
			minimum := isHorizontal
				ifTrue: [ laneContext stagedLaneSets inject: 0 into: [ :value :aLaneSet |
					value max: (CPAtelierLaneLayout minimumHeightForLaneSet: aLaneSet using: laneContext diagramContext: diagramContext) ] ]
				ifFalse: [ laneContext stagedLaneSets inject: 0 into: [ :value :aLaneSet |
					value max: (CPAtelierLaneLayout minimumWidthForLaneSet: aLaneSet using: laneContext diagramContext: diagramContext) ] ].
			(isHorizontal
				ifTrue: [ currentBounds height < minimum ]
				ifFalse: [ currentBounds width < minimum ]) ifTrue: [
				^ self rejectedBecause: 'The Pool is too small to preserve the computed minimum size of its Lanes in the requested orientation.' ].

			laneContext stagedLaneSets do: [ :aLaneSet |
				CPAtelierLaneLayout
					reflowLaneSet: aLaneSet
					withinExtent: (self processBodyExtentForParticipantBounds: currentBounds)
					using: laneContext
					diagramContext: diagramContext
					horizontal: isHorizontal
					into: proposedLaneBounds ].

			validationError := self
				addProposedFlowNodeBoundsForLaneBounds: proposedLaneBounds
				into: proposedFlowNodeBounds.
			validationError ifNotNil: [ ^ self rejectedBecause: validationError ].
			proposedWaypoints := self proposedWaypointsForFlowNodeBounds: proposedFlowNodeBounds ] ].

	^ CPAtelierResizeParticipantAssessment new
		shape: shape;
		currentBounds: currentBounds;
		proposedBounds: currentBounds;
		proposedLaneBoundsByShape: proposedLaneBounds;
		proposedFlowNodeBoundsByShape: proposedFlowNodeBounds;
		proposedWaypointsByEdge: proposedWaypoints;
		yourself
]

{ #category : 'applying' }
CPAtelierSetParticipantOrientation >> applyAssessment: anAssessment [
	| context shapeMemento orientationDescription laneContext diagramContext |
	context := self stagedCollaborationContext.
	shapeMemento := context diagramContext mementoFor: shape.
	orientationDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #isHorizontal ].
	shapeMemento write: isHorizontal using: orientationDescription.

	(context processRefOf: (context diagramContext modelElementOf: shape)) == processMemento model ifFalse: [ ^ self ].
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
			laneShapeMemento write: isHorizontal using: laneOrientationDescription ] ].

	anAssessment proposedLaneBoundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
		diagramContext writeBounds: proposedBounds of: aShape ].
	anAssessment proposedFlowNodeBoundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
		diagramContext writeBounds: proposedBounds of: aShape ].
	anAssessment proposedWaypointsByEdge keysAndValuesDo: [ :anEdge :proposedWaypoints |
		diagramContext writeWaypoints: proposedWaypoints of: anEdge ]
]

{ #category : 'private - geometry' }
CPAtelierSetParticipantOrientation >> processBodyExtentForParticipantBounds: participantBounds [
	| offset |
	offset := isHorizontal
		ifTrue: [ CPHorizontalPoolLaneOrientation new participantContentOriginOffset ]
		ifFalse: [ CPVerticalPoolLaneOrientation new participantContentOriginOffset ].
	^ participantBounds extent - offset
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
