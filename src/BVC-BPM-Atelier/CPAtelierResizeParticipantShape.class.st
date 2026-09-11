"I resize one Participant Pool in the staged Collaboration diagram.

When the Participant hosts the edited Process, I derive one coherent resize plan before writing anything: Lane bounds, FlowNode bounds translated with their owning Lanes, and Sequence Flow waypoint changes implied by those FlowNode translations. Nested LaneSets are reflowed inside their parent Lane body, preserving the parent Lane header."
Class {
	#name : 'CPAtelierResizeParticipantShape',
	#superclass : 'CPAtelierParticipantShapeBoundsOperation',
	#instVars : [
		'processDiagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}


{ #category : 'instance creation' }
CPAtelierResizeParticipantShape class >> shape: aShape bounds: aRectangle processMemento: aMemento collaborationContext: aCollaborationContext processDiagramContext: aDiagramContext [
	^ self new
		shape: aShape;
		bounds: aRectangle;
		processMemento: aMemento;
		collaborationContext: aCollaborationContext;
		processDiagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierResizeParticipantShape >> assess [
	| baseAssessment proposedLaneBounds proposedFlowNodeBounds proposedWaypoints minimumHeight minimumWidth validationError |
	baseAssessment := super assess.
	baseAssessment isApplicable ifFalse: [ ^ baseAssessment ].

	minimumHeight := self minimumParticipantHeightForStagedLanes.
	(minimumHeight notNil and: [ baseAssessment proposedBounds height < minimumHeight ]) ifTrue: [
		^ self
			rejectedWithCurrentBounds: baseAssessment currentBounds
			because: 'The Pool is too short to preserve the computed minimum heights of its Lanes.' ].

	minimumWidth := self minimumParticipantWidthForStagedLanes.
	(minimumWidth notNil and: [ baseAssessment proposedBounds width < minimumWidth ]) ifTrue: [
		^ self
			rejectedWithCurrentBounds: baseAssessment currentBounds
			because: 'The Pool is too narrow to preserve the computed minimum widths of its Lanes.' ].

	proposedLaneBounds := self
		proposedLaneBoundsForParticipantBounds: baseAssessment proposedBounds.
	proposedLaneBounds ifNil: [ proposedLaneBounds := IdentityDictionary new ].

	proposedFlowNodeBounds := IdentityDictionary new.
	validationError := self
		addProposedFlowNodeBoundsForLaneBounds: proposedLaneBounds
		into: proposedFlowNodeBounds.
	validationError ifNotNil: [
		^ self
			rejectedWithCurrentBounds: baseAssessment currentBounds
			because: validationError ].

	proposedWaypoints := self
		proposedWaypointsForFlowNodeBounds: proposedFlowNodeBounds.

	^ CPAtelierResizeParticipantAssessment new
		shape: baseAssessment shape;
		currentBounds: baseAssessment currentBounds;
		proposedBounds: baseAssessment proposedBounds;
		proposedLaneBoundsByShape: proposedLaneBounds;
		proposedFlowNodeBoundsByShape: proposedFlowNodeBounds;
		proposedWaypointsByEdge: proposedWaypoints;
		yourself
]

{ #category : 'private - applying' }
CPAtelierResizeParticipantShape >> endpointDeltaFrom: currentBounds to: proposedBounds [
	"Required by CPAtelierParticipantShapeBoundsOperation>>applyAssessment:.
	A resize keeps Message Flow endpoints attached to the Participant by
	translating them with the Participant center."
	^ proposedBounds center - currentBounds center
]


{ #category : 'applying' }
CPAtelierResizeParticipantShape >> applyAssessment: anAssessment [
	| diagramContext |
	super applyAssessment: anAssessment.
	diagramContext := self stagedProcessDiagramContext.
	diagramContext ifNil: [ ^ self ].

	anAssessment proposedLaneBoundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
		diagramContext writeBounds: proposedBounds of: aShape ].
	anAssessment proposedFlowNodeBoundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
		diagramContext writeBounds: proposedBounds of: aShape ].
	anAssessment proposedWaypointsByEdge keysAndValuesDo: [ :anEdge :proposedWaypoints |
		diagramContext writeWaypoints: proposedWaypoints of: anEdge ]
]

{ #category : 'private - assessing' }
CPAtelierResizeParticipantShape >> proposedLaneBoundsForParticipantBounds: proposedParticipantBounds [
	| collaborationContext participant laneContext diagramContext proposedBounds bodyExtent |
	collaborationContext := self stagedCollaborationContext.
	collaborationContext ifNil: [ ^ nil ].
	participant := collaborationContext diagramContext modelElementOf: shape.
	(collaborationContext processRefOf: participant) == processMemento model ifFalse: [ ^ nil ].
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	laneContext stagedLaneSets ifEmpty: [ ^ IdentityDictionary new ].

	diagramContext := self stagedProcessDiagramContext.
	diagramContext ifNil: [ ^ nil ].
	bodyExtent := proposedParticipantBounds extent
		- (self participantContentOriginOffset).
	bodyExtent x > 0 ifFalse: [ ^ nil ].
	bodyExtent y > 0 ifFalse: [ ^ nil ].
	proposedBounds := IdentityDictionary new.
	laneContext stagedLaneSets do: [ :aLaneSet |
		CPAtelierLaneLayout
			reflowLaneSet: aLaneSet
			withinExtent: bodyExtent
			using: laneContext
			diagramContext: diagramContext
			horizontal: self participantIsHorizontal
			into: proposedBounds ].
	^ proposedBounds
]

{ #category : 'private - assessing' }
CPAtelierResizeParticipantShape >> reflowLaneSet: aLaneSet withinExtent: anExtent using: laneContext diagramContext: diagramContext into: proposedBounds [
	^ CPAtelierLaneLayout
		reflowLaneSet: aLaneSet
		withinExtent: anExtent
		using: laneContext
		diagramContext: diagramContext
		into: proposedBounds
]

{ #category : 'private - assessing' }
CPAtelierResizeParticipantShape >> reflowLaneSet: aLaneSet withinBounds: parentBounds using: laneContext diagramContext: diagramContext into: proposedBounds [
	^ CPAtelierLaneLayout
		reflowLaneSet: aLaneSet
		withinBounds: parentBounds
		using: laneContext
		diagramContext: diagramContext
		into: proposedBounds
]

{ #category : 'private - geometry' }
CPAtelierResizeParticipantShape >> minimumParticipantHeightForStagedLanes [
	| laneContext laneSets diagramContext |
	self participantIsHorizontal ifFalse: [ ^ nil ].
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	laneSets := laneContext stagedLaneSets.
	laneSets ifEmpty: [ ^ CPAtelierLaneLayout minimumLaneHeight ].
	diagramContext := self stagedProcessDiagramContext.
	diagramContext ifNil: [ ^ nil ].
	^ laneSets
		inject: 0
		into: [ :minimum :aLaneSet |
			minimum max: (self
				minimumHeightForLaneSet: aLaneSet
				using: laneContext
				diagramContext: diagramContext) ]
]

{ #category : 'private - geometry' }
CPAtelierResizeParticipantShape >> minimumParticipantWidthForStagedLanes [
	| laneContext laneSets diagramContext |
	self participantIsHorizontal ifTrue: [ ^ nil ].
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	laneSets := laneContext stagedLaneSets.
	laneSets ifEmpty: [ ^ CPAtelierLaneLayout minimumLaneWidth ].
	diagramContext := self stagedProcessDiagramContext.
	diagramContext ifNil: [ ^ nil ].
	^ laneSets
		inject: 0
		into: [ :minimum :aLaneSet |
			minimum max: (CPAtelierLaneLayout
				minimumWidthForLaneSet: aLaneSet
				using: laneContext
				diagramContext: diagramContext) ]
]

{ #category : 'private - geometry' }
CPAtelierResizeParticipantShape >> minimumHeightForLaneSet: aLaneSet using: laneContext diagramContext: diagramContext [
	^ CPAtelierLaneLayout
		minimumHeightForLaneSet: aLaneSet
		using: laneContext
		diagramContext: diagramContext
]

{ #category : 'private - geometry' }
CPAtelierResizeParticipantShape >> minimumHeightForLane: aLane using: laneContext diagramContext: diagramContext [
	^ CPAtelierLaneLayout
		minimumHeightForLane: aLane
		using: laneContext
		diagramContext: diagramContext
]


{ #category : 'private - assessing' }
CPAtelierResizeParticipantShape >> addProposedFlowNodeBoundsForLaneBounds: proposedLaneBounds into: proposedFlowNodeBounds [
	| laneContext diagramContext |
	proposedLaneBounds isEmpty ifTrue: [ ^ nil ].
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	diagramContext := self stagedProcessDiagramContext.
	diagramContext ifNil: [ ^ nil ].

	laneContext stagedLanes do: [ :aLane |
		| laneShapes laneShape currentLaneBounds proposedLaneBoundsForShape delta |
		laneShapes := diagramContext shapesForModelElement: aLane.
		laneShapes size = 1 ifFalse: [
			^ 'Every resized Lane must have exactly one diagram shape.' ].
		laneShape := laneShapes anyOne.
		currentLaneBounds := diagramContext boundsOf: laneShape.
		proposedLaneBoundsForShape := proposedLaneBounds
			at: laneShape
			ifAbsent: [ currentLaneBounds ].
		delta := proposedLaneBoundsForShape origin - currentLaneBounds origin.
		delta isZero ifFalse: [
			(laneContext stagedFlowNodeRefsOf: aLane) do: [ :aFlowNode |
				| flowNodeShapes |
				flowNodeShapes := diagramContext shapesForModelElement: aFlowNode.
				flowNodeShapes do: [ :aFlowNodeShape |
					| currentBounds proposedBounds existing |
					currentBounds := diagramContext boundsOf: aFlowNodeShape.
					currentBounds ifNil: [
						^ 'Every FlowNode moved with a Lane must have staged diagram bounds.' ].
					proposedBounds := currentBounds translateBy: delta.
					(self
						validationErrorForBounds: proposedBounds
						of: aFlowNodeShape
						in: diagramContext) ifNotNil: [ :anError | ^ anError ].
					existing := proposedFlowNodeBounds
						at: aFlowNodeShape
						ifAbsent: [ nil ].
					(existing notNil and: [ existing ~= proposedBounds ]) ifTrue: [
						^ 'A FlowNode cannot follow two resized Lanes with different translations.' ].
					proposedFlowNodeBounds at: aFlowNodeShape put: proposedBounds ] ] ] ].

	^ self
		addAttachedBoundaryEventBoundsTo: proposedFlowNodeBounds
		using: diagramContext
]

{ #category : 'private - assessing' }
CPAtelierResizeParticipantShape >> validationErrorForBounds: proposedBounds of: aShape in: diagramContext [
	| shapeMemento boundsDescription |
	shapeMemento := diagramContext mementoFor: aShape.
	shapeMemento ifNil: [ ^ 'Every FlowNode moved with a Lane must have a staged diagram memento.' ].
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ]
		ifNone: [ ^ 'Every FlowNode moved with a Lane must describe diagram bounds.' ].
	[
		boundsDescription validate: proposedBounds
	] on: MAValidationError do: [ :anException |
		^ anException printString ].
	^ nil
]


{ #category : 'private - assessing' }
CPAtelierResizeParticipantShape >> addAttachedBoundaryEventBoundsTo: proposedFlowNodeBounds using: diagramContext [
	| movedActivities |
	movedActivities := IdentityDictionary new.
	proposedFlowNodeBounds keysAndValuesDo: [ :aShape :proposedBounds |
		| modelElement currentBounds |
		modelElement := diagramContext modelElementOf: aShape.
		modelElement ifNotNil: [
			currentBounds := diagramContext boundsOf: aShape.
			(modelElement isActivity and: [ currentBounds notNil ]) ifTrue: [
				movedActivities
					at: modelElement
					put: proposedBounds origin - currentBounds origin ] ] ].

	movedActivities keysAndValuesDo: [ :anActivity :delta |
		| flowContext |
		flowContext := CPProcessFlowContainerContext
			containingFlowElement: anActivity
			inRootMemento: processMemento.
		flowContext ifNotNil: [
			(flowContext attachedBoundaryEventsFor: anActivity) do: [ :aBoundaryEvent |
				| shapes boundaryShape currentBounds proposedBounds existing |
				shapes := diagramContext shapesForModelElement: aBoundaryEvent.
				shapes size = 1 ifTrue: [
					boundaryShape := shapes anyOne.
					currentBounds := diagramContext boundsOf: boundaryShape.
					currentBounds ifNotNil: [
						proposedBounds := currentBounds translateBy: delta.
						existing := proposedFlowNodeBounds
							at: boundaryShape
							ifAbsent: [ nil ].
						(existing notNil and: [ existing ~= proposedBounds ]) ifTrue: [
							^ 'A Boundary Event cannot follow two resized Activities with different translations.' ].
						proposedFlowNodeBounds at: boundaryShape put: proposedBounds ] ] ] ] ].
	^ nil
]

{ #category : 'private - assessing' }
CPAtelierResizeParticipantShape >> proposedWaypointsForFlowNodeBounds: proposedFlowNodeBounds [
	| diagramContext deltaByModelElement proposedWaypoints |
	proposedWaypoints := IdentityDictionary new.
	proposedFlowNodeBounds isEmpty ifTrue: [ ^ proposedWaypoints ].
	diagramContext := self stagedProcessDiagramContext.
	diagramContext ifNil: [ ^ proposedWaypoints ].

	deltaByModelElement := IdentityDictionary new.
	proposedFlowNodeBounds keysAndValuesDo: [ :aShape :proposedBounds |
		| modelElement currentBounds delta existing |
		modelElement := diagramContext modelElementOf: aShape.
		currentBounds := diagramContext boundsOf: aShape.
		(modelElement notNil and: [ currentBounds notNil ]) ifTrue: [
			delta := proposedBounds origin - currentBounds origin.
			existing := deltaByModelElement at: modelElement ifAbsent: [ nil ].
			(existing isNil or: [ existing = delta ]) ifTrue: [
				deltaByModelElement at: modelElement put: delta ] ] ].

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
						(sourceDelta notNil
							and: [ targetDelta notNil and: [ sourceDelta = targetDelta ] ])
							ifTrue: [
								1 to: translated size do: [ :index |
									translated
										at: index
										put: (translated at: index) + sourceDelta ] ]
							ifFalse: [
								sourceDelta ifNotNil: [
									translated
										at: 1
										put: translated first + sourceDelta ].
								targetDelta ifNotNil: [
									translated
										at: translated size
										put: translated last + targetDelta ] ].
						proposedWaypoints at: anElement put: translated ] ] ] ] ].
	^ proposedWaypoints
]

{ #category : 'private - staged state' }
CPAtelierResizeParticipantShape >> stagedProcessDiagramContext [
	| diagramDescription diagram |
	processDiagramContext ifNotNil: [ ^ processDiagramContext ].
	diagramDescription := processMemento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ nil ].
	^ CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription
]

{ #category : 'accessing' }
CPAtelierResizeParticipantShape >> processDiagramContext: aContext [ processDiagramContext := aContext ]

{ #category : 'applying' }
CPAtelierResizeParticipantShape >> applyLaneReflowForParticipantBounds: participantBounds [
	| proposedLaneBounds diagramContext |
	proposedLaneBounds := self proposedLaneBoundsForParticipantBounds: participantBounds.
	proposedLaneBounds ifNil: [ ^ self ].
	diagramContext := self stagedProcessDiagramContext.
	diagramContext ifNil: [ ^ self ].
	proposedLaneBounds keysAndValuesDo: [ :aShape :proposedBounds |
		| shapeMemento boundsDescription |
		shapeMemento := diagramContext mementoFor: aShape.
		boundsDescription := shapeMemento magritteDescription
			detect: [ :each | each handlesSelector: #bounds ].
		shapeMemento write: proposedBounds using: boundsDescription ]
]


{ #category : 'private - staged state' }
CPAtelierResizeParticipantShape >> participantIsHorizontal [
	| context shapeMemento description |
	context := self stagedCollaborationContext.
	context ifNil: [ ^ shape isHorizontal ].
	shapeMemento := context diagramContext mementoFor: shape.
	shapeMemento ifNil: [ ^ shape isHorizontal ].
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #isHorizontal ]
		ifNone: [ ^ shape isHorizontal ].
	^ shapeMemento readUsing: description
]

{ #category : 'private - geometry' }
CPAtelierResizeParticipantShape >> participantContentOriginOffset [
	^ self participantIsHorizontal
		ifTrue: [ CPHorizontalPoolLaneOrientation new participantContentOriginOffset ]
		ifFalse: [ CPVerticalPoolLaneOrientation new participantContentOriginOffset ]
]
