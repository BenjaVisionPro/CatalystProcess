"I resize one Participant Pool in the staged Collaboration diagram.

When the Participant hosts the edited Process, I also reflow every staged top-level LaneSet so its ordered Lanes continue to partition the complete Pool body. Nested LaneSets are reflowed inside their parent Lane."
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
	| baseAssessment proposedLaneBounds |
	baseAssessment := super assess.
	baseAssessment isApplicable ifFalse: [ ^ baseAssessment ].
	proposedLaneBounds := self
		proposedLaneBoundsForParticipantBounds: baseAssessment proposedBounds.
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
	| diagramContext |
	super applyAssessment: anAssessment.
	anAssessment proposedLaneBoundsByShape ifEmpty: [ ^ self ].
	diagramContext := self stagedProcessDiagramContext.
	diagramContext ifNil: [ ^ self ].
	anAssessment proposedLaneBoundsByShape keysAndValuesDo: [ :aShape :proposedBounds |
		| shapeMemento boundsDescription |
		shapeMemento := diagramContext mementoFor: aShape.
		boundsDescription := shapeMemento magritteDescription
			detect: [ :each | each handlesSelector: #bounds ].
		shapeMemento write: proposedBounds using: boundsDescription ]
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
	bodyExtent := (proposedParticipantBounds width - CPParticipantShapeElement processContentOriginOffset x)
		@ proposedParticipantBounds height.
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
