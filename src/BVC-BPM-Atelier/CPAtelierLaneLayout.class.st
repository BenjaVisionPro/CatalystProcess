"I define Atelier's geometric layout rules for BPMN Lanes.

These are editing and auto-layout rules, not renderer rules. BPMN DI remains authoritative for projection.

I calculate the recursive LaneSet partition used by Participant resize for both BPMN orientations. Horizontal LaneSets partition top-to-bottom; vertical LaneSets partition left-to-right. I return proposed DI bounds; I do not write them."
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
CPAtelierLaneLayout class >> minimumLaneWidth [
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


{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumWidthForLaneSet: aLaneSet using: laneContext diagramContext: diagramContext [
	^ (laneContext stagedLanesInLaneSet: aLaneSet)
		inject: 0
		into: [ :width :aLane |
			width + (self
				minimumWidthForLane: aLane
				using: laneContext
				diagramContext: diagramContext) ]
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumWidthForLane: aLane using: laneContext diagramContext: diagramContext [
	| childLaneSet childMinimum contentMinimum |
	childLaneSet := laneContext stagedChildLaneSetOf: aLane.
	childMinimum := childLaneSet
		ifNil: [ 0 ]
		ifNotNil: [
			self
				minimumWidthForLaneSet: childLaneSet
				using: laneContext
				diagramContext: diagramContext ].
	contentMinimum := self
		minimumContentWidthForLane: aLane
		using: laneContext
		diagramContext: diagramContext.
	^ self minimumLaneWidth max: (childMinimum max: contentMinimum)
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumContentWidthForLane: aLane using: laneContext diagramContext: diagramContext [
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
	^ (contentBounds collect: [ :each | each right ]) max
		- laneBounds left
		+ self contentClearance
]


{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> bodyBoundsForLaneBounds: laneBounds shape: laneShape [
	^ self
		bodyBoundsForLaneBounds: laneBounds
		horizontal: laneShape isHorizontal
]

{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> bodyBoundsForLaneBounds: laneBounds horizontal: isHorizontal [
	| offset |
	offset := isHorizontal
		ifTrue: [ CPHorizontalPoolLaneOrientation new laneBodyOriginOffset ]
		ifFalse: [ CPVerticalPoolLaneOrientation new laneBodyOriginOffset ].
	^ (laneBounds origin + offset)
		extent: (laneBounds extent - offset)
]

{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> reflowLaneSet: aLaneSet withinExtent: anExtent using: laneContext diagramContext: diagramContext into: proposedBounds [
	| lanes shapes |
	lanes := laneContext stagedLanesInLaneSet: aLaneSet.
	lanes ifEmpty: [ ^ self ].
	shapes := diagramContext shapesForModelElement: lanes first.
	shapes size = 1 ifFalse: [ ^ self ].
	^ self
		reflowLaneSet: aLaneSet
		withinExtent: anExtent
		using: laneContext
		diagramContext: diagramContext
		horizontal: shapes anyOne isHorizontal
		into: proposedBounds
]

{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> reflowLaneSet: aLaneSet withinExtent: anExtent using: laneContext diagramContext: diagramContext horizontal: isHorizontal into: proposedBounds [
	| lanes currentBoundsByLane minX minY |
	lanes := laneContext stagedLanesInLaneSet: aLaneSet.
	lanes ifEmpty: [ ^ self ].
	currentBoundsByLane := self
		currentBoundsByLaneFor: lanes
		using: diagramContext.
	currentBoundsByLane ifNil: [ ^ self ].
	minX := (currentBoundsByLane values collect: [ :each | each left ]) min.
	minY := (currentBoundsByLane values collect: [ :each | each top ]) min.
	^ self
		reflowLaneSet: aLaneSet
		withinBounds: (minX @ minY extent: anExtent)
		using: laneContext
		diagramContext: diagramContext
		horizontal: isHorizontal
		into: proposedBounds
]

{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> reflowLaneSet: aLaneSet withinBounds: parentBounds using: laneContext diagramContext: diagramContext into: proposedBounds [
	| lanes shapes |
	lanes := laneContext stagedLanesInLaneSet: aLaneSet.
	lanes ifEmpty: [ ^ self ].
	shapes := diagramContext shapesForModelElement: lanes first.
	shapes size = 1 ifFalse: [ ^ self ].
	^ self
		reflowLaneSet: aLaneSet
		withinBounds: parentBounds
		using: laneContext
		diagramContext: diagramContext
		horizontal: shapes anyOne isHorizontal
		into: proposedBounds
]

{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> reflowLaneSet: aLaneSet withinBounds: parentBounds using: laneContext diagramContext: diagramContext horizontal: isHorizontal into: proposedBounds [
	isHorizontal
		ifTrue: [
			^ self
				reflowHorizontalLaneSet: aLaneSet
				withinBounds: parentBounds
				using: laneContext
				diagramContext: diagramContext
				into: proposedBounds ]
		ifFalse: [
			^ self
				reflowVerticalLaneSet: aLaneSet
				withinBounds: parentBounds
				using: laneContext
				diagramContext: diagramContext
				into: proposedBounds ]
]

{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> reflowHorizontalLaneSet: aLaneSet withinBounds: parentBounds using: laneContext diagramContext: diagramContext into: proposedBounds [
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
		| currentBounds minimumHeight remainingMinimumAfter laneHeight laneBounds childLaneSet proportionalExtra laneShape |
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
		laneShape := laneShapes at: aLane.
		proposedBounds at: laneShape put: laneBounds.

		childLaneSet := laneContext stagedChildLaneSetOf: aLane.
		childLaneSet ifNotNil: [
			self
				reflowLaneSet: childLaneSet
				withinBounds: (self
					bodyBoundsForLaneBounds: laneBounds
					horizontal: true)
				using: laneContext
				diagramContext: diagramContext
				horizontal: true
				into: proposedBounds ].

		cursorY := cursorY + laneHeight.
		remainingHeight := remainingHeight - laneHeight.
		remainingMinimum := remainingMinimumAfter ]
]

{ #category : 'geometry - reflow' }
CPAtelierLaneLayout class >> reflowVerticalLaneSet: aLaneSet withinBounds: parentBounds using: laneContext diagramContext: diagramContext into: proposedBounds [
	| lanes laneShapes currentBoundsByLane minimumWidthByLane totalWidth requiredWidth extraWidth cursorX remainingWidth remainingMinimum |
	lanes := laneContext stagedLanesInLaneSet: aLaneSet.
	lanes ifEmpty: [ ^ self ].

	laneShapes := IdentityDictionary new.
	currentBoundsByLane := IdentityDictionary new.
	minimumWidthByLane := IdentityDictionary new.
	lanes do: [ :aLane |
		| shapes laneShape laneBounds |
		shapes := diagramContext shapesForModelElement: aLane.
		shapes size = 1 ifFalse: [ ^ self ].
		laneShape := shapes anyOne.
		laneBounds := diagramContext boundsOf: laneShape.
		laneShapes at: aLane put: laneShape.
		currentBoundsByLane at: aLane put: laneBounds.
		minimumWidthByLane
			at: aLane
			put: (self
				minimumWidthForLane: aLane
				using: laneContext
				diagramContext: diagramContext) ].

	totalWidth := (currentBoundsByLane values collect: [ :each | each width ]) sum.
	totalWidth > 0 ifFalse: [ ^ self ].
	requiredWidth := minimumWidthByLane values sum.
	parentBounds width >= requiredWidth ifFalse: [ ^ self ].

	extraWidth := parentBounds width - requiredWidth.
	cursorX := parentBounds left.
	remainingWidth := parentBounds width.
	remainingMinimum := requiredWidth.

	lanes withIndexDo: [ :aLane :index |
		| currentBounds minimumWidth remainingMinimumAfter laneWidth laneBounds childLaneSet proportionalExtra laneShape |
		currentBounds := currentBoundsByLane at: aLane.
		minimumWidth := minimumWidthByLane at: aLane.
		remainingMinimumAfter := remainingMinimum - minimumWidth.
		laneWidth := index = lanes size
			ifTrue: [ remainingWidth ]
			ifFalse: [
				proportionalExtra := (extraWidth * currentBounds width / totalWidth) rounded.
				(minimumWidth + proportionalExtra)
					min: (remainingWidth - remainingMinimumAfter) ].
		laneBounds := cursorX @ parentBounds top
			extent: laneWidth @ parentBounds height.
		laneShape := laneShapes at: aLane.
		proposedBounds at: laneShape put: laneBounds.

		childLaneSet := laneContext stagedChildLaneSetOf: aLane.
		childLaneSet ifNotNil: [
			self
				reflowLaneSet: childLaneSet
				withinBounds: (self
					bodyBoundsForLaneBounds: laneBounds
					horizontal: false)
				using: laneContext
				diagramContext: diagramContext
				horizontal: false
				into: proposedBounds ].

		cursorX := cursorX + laneWidth.
		remainingWidth := remainingWidth - laneWidth.
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
