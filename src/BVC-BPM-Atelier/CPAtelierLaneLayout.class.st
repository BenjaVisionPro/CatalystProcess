"I define Atelier's geometric layout rules for BPMN Lanes.

These are editing and auto-layout rules, not renderer rules. BPMN DI remains authoritative for projection.

I also calculate the recursive horizontal LaneSet partition used by Participant resize. I return proposed DI bounds; I do not write them."
Class {
	#name : 'CPAtelierLaneLayout',
	#superclass : 'Object',
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumLaneHeight [
	^ 140
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> contentClearance [
	"Minimum clear space retained between the lowest contained FlowNode and the Lane boundary when a horizontal Lane is compressed by Atelier layout."
	^ 20
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumHeightForLaneSet: aLaneSet using: laneContext diagramContext: diagramContext [
	^ (laneContext stagedLanesInLaneSet: aLaneSet)
		inject: 0
		into: [ :height :aLane |
			height + (self minimumHeightForLane: aLane using: laneContext diagramContext: diagramContext) ]
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumHeightForLane: aLane using: laneContext diagramContext: diagramContext [
	| childLaneSet childMinimum contentMinimum |
	childLaneSet := laneContext stagedChildLaneSetOf: aLane.
	childMinimum := childLaneSet
		ifNil: [ 0 ]
		ifNotNil: [ self minimumHeightForLaneSet: childLaneSet using: laneContext diagramContext: diagramContext ].
	contentMinimum := self minimumContentHeightForLane: aLane using: laneContext diagramContext: diagramContext.
	^ self minimumLaneHeight max: (childMinimum max: contentMinimum)
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumContentHeightForLane: aLane using: laneContext diagramContext: diagramContext [
	| laneShapes laneBounds contentBounds |
	laneShapes := diagramContext shapesForModelElement: aLane.
	laneShapes size = 1 ifFalse: [ ^ 0 ].
	laneBounds := diagramContext boundsOf: laneShapes anyOne.
	contentBounds := OrderedCollection new.
	(laneContext stagedFlowNodeRefsOf: aLane) do: [ :aFlowNode |
		| shapes |
		shapes := diagramContext shapesForModelElement: aFlowNode.
		shapes size = 1 ifTrue: [
			contentBounds add: (diagramContext boundsOf: shapes anyOne) ] ].
	contentBounds ifEmpty: [ ^ 0 ].
	^ (contentBounds collect: [ :each | each bottom ]) max
		- laneBounds top
		+ self contentClearance
]


{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> bodyBoundsForLaneBounds: laneBounds [
	| headerWidth |
	headerWidth := CPLaneShapeElement laneHeaderWidth.
	^ (laneBounds origin + (headerWidth @ 0))
		extent: ((laneBounds width - headerWidth) @ laneBounds height)
]

{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> reflowLaneSet: aLaneSet withinExtent: anExtent using: laneContext diagramContext: diagramContext into: proposedBounds [
	| lanes currentBoundsByLane minX minY |
	lanes := laneContext stagedLanesInLaneSet: aLaneSet.
	lanes ifEmpty: [ ^ self ].
	currentBoundsByLane := self
		currentBoundsByLaneFor: lanes
		using: diagramContext.
	currentBoundsByLane ifNil: [ ^ self ].
	minX := (currentBoundsByLane values collect: [ :each | each left ]) min.
	minY := (currentBoundsByLane values collect: [ :each | each top ]) min.
	self
		reflowLaneSet: aLaneSet
		withinBounds: (minX @ minY extent: anExtent)
		using: laneContext
		diagramContext: diagramContext
		into: proposedBounds
]

{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> reflowLaneSet: aLaneSet withinBounds: parentBounds using: laneContext diagramContext: diagramContext into: proposedBounds [
	| lanes laneShapes currentBoundsByLane minimumHeightByLane totalHeight requiredHeight extraHeight cursorY remainingHeight remainingMinimum |
	lanes := laneContext stagedLanesInLaneSet: aLaneSet.
	lanes ifEmpty: [ ^ self ].

	laneShapes := IdentityDictionary new.
	currentBoundsByLane := IdentityDictionary new.
	minimumHeightByLane := IdentityDictionary new.
	lanes do: [ :aLane |
		| shapes laneShape laneBounds |
		shapes := diagramContext shapesForModelElement: aLane.
		shapes size = 1 ifFalse: [ ^ self ].
		laneShape := shapes anyOne.
		laneBounds := diagramContext boundsOf: laneShape.
		laneShapes at: aLane put: laneShape.
		currentBoundsByLane at: aLane put: laneBounds.
		minimumHeightByLane
			at: aLane
			put: (self
				minimumHeightForLane: aLane
				using: laneContext
				diagramContext: diagramContext) ].

	totalHeight := (currentBoundsByLane values collect: [ :each | each height ]) sum.
	totalHeight > 0 ifFalse: [ ^ self ].
	requiredHeight := minimumHeightByLane values sum.
	parentBounds height >= requiredHeight ifFalse: [ ^ self ].

	extraHeight := parentBounds height - requiredHeight.
	cursorY := parentBounds top.
	remainingHeight := parentBounds height.
	remainingMinimum := requiredHeight.

	lanes withIndexDo: [ :aLane :index |
		| currentBounds minimumHeight remainingMinimumAfter laneHeight laneBounds childLaneSet proportionalExtra |
		currentBounds := currentBoundsByLane at: aLane.
		minimumHeight := minimumHeightByLane at: aLane.
		remainingMinimumAfter := remainingMinimum - minimumHeight.
		laneHeight := index = lanes size
			ifTrue: [ remainingHeight ]
			ifFalse: [
				proportionalExtra := (extraHeight * currentBounds height / totalHeight) rounded.
				(minimumHeight + proportionalExtra)
					min: (remainingHeight - remainingMinimumAfter) ].
		laneBounds := parentBounds left @ cursorY
			extent: parentBounds width @ laneHeight.
		proposedBounds
			at: (laneShapes at: aLane)
			put: laneBounds.

		childLaneSet := laneContext stagedChildLaneSetOf: aLane.
		childLaneSet ifNotNil: [
			self
				reflowLaneSet: childLaneSet
				withinBounds: (self bodyBoundsForLaneBounds: laneBounds)
				using: laneContext
				diagramContext: diagramContext
				into: proposedBounds ].

		cursorY := cursorY + laneHeight.
		remainingHeight := remainingHeight - laneHeight.
		remainingMinimum := remainingMinimumAfter ]
]

{ #category : 'private - geometry' }
CPAtelierLaneLayout class >> currentBoundsByLaneFor: lanes using: diagramContext [
	| currentBoundsByLane |
	currentBoundsByLane := IdentityDictionary new.
	lanes do: [ :aLane |
		| shapes bounds |
		shapes := diagramContext shapesForModelElement: aLane.
		shapes size = 1 ifFalse: [ ^ nil ].
		bounds := diagramContext boundsOf: shapes anyOne.
		bounds ifNil: [ ^ nil ].
		currentBoundsByLane at: aLane put: bounds ].
	^ currentBoundsByLane
]
