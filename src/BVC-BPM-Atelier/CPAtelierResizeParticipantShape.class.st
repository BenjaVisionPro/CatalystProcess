"I resize one Participant Pool in the staged Collaboration diagram.

When the Participant hosts the edited Process, I also reflow every staged top-level LaneSet so its ordered Lanes continue to partition the complete Pool body. Nested LaneSets are reflowed inside their parent Lane."
Class {
	#name : 'CPAtelierResizeParticipantShape',
	#superclass : 'CPAtelierParticipantShapeBoundsOperation',
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'assessing' }
CPAtelierResizeParticipantShape >> assess [
	| baseAssessment proposedLaneBounds |
	baseAssessment := super assess.
	baseAssessment isApplicable ifFalse: [ ^ baseAssessment ].
	proposedLaneBounds := self
		proposedLaneBoundsFromParticipantBounds: baseAssessment currentBounds
		to: baseAssessment proposedBounds.
	proposedLaneBounds ifNil: [ proposedLaneBounds := IdentityDictionary new ].
	^ CPAtelierResizeParticipantAssessment new
		shape: baseAssessment shape;
		currentBounds: baseAssessment currentBounds;
		proposedBounds: baseAssessment proposedBounds;
		proposedLaneBoundsByShape: proposedLaneBounds;
		yourself
]

{ #category : 'applying' }
CPAtelierResizeParticipantShape >> applyAssessment: anAssessment [
	| diagramDescription diagram diagramContext |
	super applyAssessment: anAssessment.
	(anAssessment isKindOf: CPAtelierResizeParticipantAssessment) ifFalse: [ ^ self ].
	anAssessment proposedLaneBoundsByShape ifEmpty: [ ^ self ].
	diagramDescription := processMemento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self ].
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	anAssessment proposedLaneBoundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
		| shapeMemento boundsDescription |
		shapeMemento := diagramContext mementoFor: aShape.
		boundsDescription := shapeMemento magritteDescription
			detect: [ :each | each handlesSelector: #bounds ].
		shapeMemento write: proposedBounds using: boundsDescription ]
]

{ #category : 'private - assessing' }
CPAtelierResizeParticipantShape >> proposedLaneBoundsFromParticipantBounds: currentParticipantBounds to: proposedParticipantBounds [
	| collaborationContext participant laneContext diagramDescription diagram diagramContext proposedBounds bodyExtent |
	collaborationContext := CPProcessCollaborationContext inRootMemento: processMemento.
	collaborationContext ifNil: [ ^ nil ].
	participant := collaborationContext diagramContext modelElementOf: shape.
	(collaborationContext processRefOf: participant) == processMemento model ifFalse: [ ^ nil ].
	laneContext := CPProcessLaneContext inRootMemento: processMemento.
	laneContext stagedLaneSets ifEmpty: [ ^ IdentityDictionary new ].

	diagramDescription := processMemento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ nil ].
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	bodyExtent := (proposedParticipantBounds width - 36) @ proposedParticipantBounds height.
	bodyExtent x > 0 ifFalse: [ ^ nil ].
	bodyExtent y > 0 ifFalse: [ ^ nil ].
	proposedBounds := IdentityDictionary new.
	laneContext stagedLaneSets do: [ :aLaneSet |
		self
			reflowLaneSet: aLaneSet
			withinExtent: bodyExtent
			using: laneContext
			diagramContext: diagramContext
			into: proposedBounds ].
	^ proposedBounds
]

{ #category : 'private - assessing' }
CPAtelierResizeParticipantShape >> reflowLaneSet: aLaneSet withinExtent: anExtent using: laneContext diagramContext: diagramContext into: proposedBounds [
	| lanes laneShapes currentBoundsByLane minX minY totalHeight cursorY remainingHeight |
	lanes := laneContext stagedLanesInLaneSet: aLaneSet.
	lanes ifEmpty: [ ^ self ].
	laneShapes := IdentityDictionary new.
	currentBoundsByLane := IdentityDictionary new.
	lanes do: [ :aLane |
		| shapes laneShape laneBounds |
		shapes := diagramContext shapesForModelElement: aLane.
		shapes size = 1 ifFalse: [ ^ self ].
		laneShape := shapes anyOne.
		laneBounds := diagramContext boundsOf: laneShape.
		laneShapes at: aLane put: laneShape.
		currentBoundsByLane at: aLane put: laneBounds ].
	minX := (currentBoundsByLane values collect: [ :each | each left ]) min.
	minY := (currentBoundsByLane values collect: [ :each | each top ]) min.
	totalHeight := (currentBoundsByLane values collect: [ :each | each height ]) sum.
	totalHeight > 0 ifFalse: [ ^ self ].
	cursorY := minY.
	remainingHeight := anExtent y.
	lanes withIndexDo: [ :aLane :index |
		| currentBounds laneHeight laneBounds childLaneSet |
		currentBounds := currentBoundsByLane at: aLane.
		laneHeight := index = lanes size
			ifTrue: [ remainingHeight ]
			ifFalse: [
				((anExtent y * currentBounds height / totalHeight) rounded)
					min: remainingHeight ].
		laneBounds := minX @ cursorY extent: anExtent x @ laneHeight.
		proposedBounds at: (laneShapes at: aLane) put: laneBounds.
		childLaneSet := laneContext stagedChildLaneSetOf: aLane.
		childLaneSet ifNotNil: [
			self
				reflowLaneSet: childLaneSet
				withinBounds: laneBounds
				using: laneContext
				diagramContext: diagramContext
				into: proposedBounds ].
		cursorY := cursorY + laneHeight.
		remainingHeight := remainingHeight - laneHeight ]
]

{ #category : 'private - assessing' }
CPAtelierResizeParticipantShape >> reflowLaneSet: aLaneSet withinBounds: parentBounds using: laneContext diagramContext: diagramContext into: proposedBounds [
	| lanes laneShapes currentBoundsByLane totalHeight cursorY remainingHeight |
	lanes := laneContext stagedLanesInLaneSet: aLaneSet.
	lanes ifEmpty: [ ^ self ].
	laneShapes := IdentityDictionary new.
	currentBoundsByLane := IdentityDictionary new.
	lanes do: [ :aLane |
		| shapes laneShape laneBounds |
		shapes := diagramContext shapesForModelElement: aLane.
		shapes size = 1 ifFalse: [ ^ self ].
		laneShape := shapes anyOne.
		laneBounds := diagramContext boundsOf: laneShape.
		laneShapes at: aLane put: laneShape.
		currentBoundsByLane at: aLane put: laneBounds ].
	totalHeight := (currentBoundsByLane values collect: [ :each | each height ]) sum.
	totalHeight > 0 ifFalse: [ ^ self ].
	cursorY := parentBounds top.
	remainingHeight := parentBounds height.
	lanes withIndexDo: [ :aLane :index |
		| currentBounds laneHeight laneBounds childLaneSet |
		currentBounds := currentBoundsByLane at: aLane.
		laneHeight := index = lanes size
			ifTrue: [ remainingHeight ]
			ifFalse: [
				((parentBounds height * currentBounds height / totalHeight) rounded)
					min: remainingHeight ].
		laneBounds := parentBounds left @ cursorY extent: parentBounds width @ laneHeight.
		proposedBounds at: (laneShapes at: aLane) put: laneBounds.
		childLaneSet := laneContext stagedChildLaneSetOf: aLane.
		childLaneSet ifNotNil: [
			self
				reflowLaneSet: childLaneSet
				withinBounds: laneBounds
				using: laneContext
				diagramContext: diagramContext
				into: proposedBounds ].
		cursorY := cursorY + laneHeight.
		remainingHeight := remainingHeight - laneHeight ]
]

{ #category : 'private - applying' }
CPAtelierResizeParticipantShape >> endpointDeltaFrom: currentBounds to: proposedBounds [
	^ proposedBounds center - currentBounds center
]
