"I define Atelier's geometric layout rules for BPMN Lanes.

These are editing and auto-layout rules, not renderer rules. BPMN DI remains authoritative for projection.

I calculate one recursive LaneSet partition algorithm for both BPMN orientations. Horizontal LaneSets use the y axis as their partition axis; vertical LaneSets use x. CPPoolLaneGeometry owns that axis mapping. I return proposed DI bounds; I do not write them."
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
CPAtelierLaneLayout class >> minimumLaneLengthForHorizontal: isHorizontal [
	^ isHorizontal
		ifTrue: [ self minimumLaneHeight ]
		ifFalse: [ self minimumLaneWidth ]
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> contentClearance [
	"Minimum clear space retained between the furthest contained FlowNode and the Lane boundary along the LaneSet partition axis."
	^ 20
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumHeightForLaneSet: aLaneSet using: laneContext diagramContext: diagramContext [
	^ self
		minimumLengthForLaneSet: aLaneSet
		using: laneContext
		diagramContext: diagramContext
		horizontal: true
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumWidthForLaneSet: aLaneSet using: laneContext diagramContext: diagramContext [
	^ self
		minimumLengthForLaneSet: aLaneSet
		using: laneContext
		diagramContext: diagramContext
		horizontal: false
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumLengthForLaneSet: aLaneSet using: laneContext diagramContext: diagramContext horizontal: isHorizontal [
	^ (laneContext stagedLanesInLaneSet: aLaneSet)
		inject: 0
		into: [ :length :aLane |
			length + (self
				minimumLengthForLane: aLane
				using: laneContext
				diagramContext: diagramContext
				horizontal: isHorizontal) ]
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumHeightForLane: aLane using: laneContext diagramContext: diagramContext [
	^ self
		minimumLengthForLane: aLane
		using: laneContext
		diagramContext: diagramContext
		horizontal: true
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumWidthForLane: aLane using: laneContext diagramContext: diagramContext [
	^ self
		minimumLengthForLane: aLane
		using: laneContext
		diagramContext: diagramContext
		horizontal: false
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumLengthForLane: aLane using: laneContext diagramContext: diagramContext horizontal: isHorizontal [
	| childLaneSet childMinimum contentMinimum |
	childLaneSet := laneContext stagedChildLaneSetOf: aLane.
	childMinimum := childLaneSet
		ifNil: [ 0 ]
		ifNotNil: [
			self
				minimumLengthForLaneSet: childLaneSet
				using: laneContext
				diagramContext: diagramContext
				horizontal: isHorizontal ].
	contentMinimum := self
		minimumContentLengthForLane: aLane
		using: laneContext
		diagramContext: diagramContext
		horizontal: isHorizontal.
	^ (self minimumLaneLengthForHorizontal: isHorizontal)
		max: (childMinimum max: contentMinimum)
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumContentHeightForLane: aLane using: laneContext diagramContext: diagramContext [
	^ self
		minimumContentLengthForLane: aLane
		using: laneContext
		diagramContext: diagramContext
		horizontal: true
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumContentWidthForLane: aLane using: laneContext diagramContext: diagramContext [
	^ self
		minimumContentLengthForLane: aLane
		using: laneContext
		diagramContext: diagramContext
		horizontal: false
]

{ #category : 'geometry' }
CPAtelierLaneLayout class >> minimumContentLengthForLane: aLane using: laneContext diagramContext: diagramContext horizontal: isHorizontal [
	| laneShapes laneBounds contentBounds furthestContentEnd |
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
	furthestContentEnd := (contentBounds collect: [ :each |
		CPPoolLaneGeometry partitionEndOf: each horizontal: isHorizontal ]) max.
	^ furthestContentEnd
		- (CPPoolLaneGeometry partitionStartOf: laneBounds horizontal: isHorizontal)
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
	offset := CPPoolLaneGeometry laneBodyOriginOffsetForHorizontal: isHorizontal.
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
	| lanes laneShapes currentBoundsByLane minimumLengthByLane totalLength requiredLength extraLength cursor remainingLength remainingMinimum parentPartitionStart parentCrossStart parentCrossLength |
	lanes := laneContext stagedLanesInLaneSet: aLaneSet.
	lanes ifEmpty: [ ^ self ].

	laneShapes := IdentityDictionary new.
	currentBoundsByLane := IdentityDictionary new.
	minimumLengthByLane := IdentityDictionary new.
	lanes do: [ :aLane |
		| shapes laneShape laneBounds |
		shapes := diagramContext shapesForModelElement: aLane.
		shapes size = 1 ifFalse: [ ^ self ].
		laneShape := shapes anyOne.
		laneBounds := diagramContext boundsOf: laneShape.
		laneShapes at: aLane put: laneShape.
		currentBoundsByLane at: aLane put: laneBounds.
		minimumLengthByLane
			at: aLane
			put: (self
				minimumLengthForLane: aLane
				using: laneContext
				diagramContext: diagramContext
				horizontal: isHorizontal) ].

	totalLength := (currentBoundsByLane values collect: [ :each |
		CPPoolLaneGeometry partitionLengthOf: each horizontal: isHorizontal ]) sum.
	totalLength > 0 ifFalse: [ ^ self ].
	requiredLength := minimumLengthByLane values sum.
	parentPartitionStart := CPPoolLaneGeometry
		partitionStartOf: parentBounds
		horizontal: isHorizontal.
	parentCrossStart := CPPoolLaneGeometry
		crossStartOf: parentBounds
		horizontal: isHorizontal.
	parentCrossLength := CPPoolLaneGeometry
		crossLengthOf: parentBounds
		horizontal: isHorizontal.
	remainingLength := CPPoolLaneGeometry
		partitionLengthOf: parentBounds
		horizontal: isHorizontal.
	remainingLength >= requiredLength ifFalse: [ ^ self ].

	extraLength := remainingLength - requiredLength.
	cursor := parentPartitionStart.
	remainingMinimum := requiredLength.

	lanes withIndexDo: [ :aLane :index |
		| currentBounds minimumLength remainingMinimumAfter laneLength laneBounds childLaneSet proportionalExtra laneShape |
		currentBounds := currentBoundsByLane at: aLane.
		minimumLength := minimumLengthByLane at: aLane.
		remainingMinimumAfter := remainingMinimum - minimumLength.
		laneLength := index = lanes size
			ifTrue: [ remainingLength ]
			ifFalse: [
				proportionalExtra := (extraLength
					* (CPPoolLaneGeometry partitionLengthOf: currentBounds horizontal: isHorizontal)
					/ totalLength) rounded.
				(minimumLength + proportionalExtra)
					min: (remainingLength - remainingMinimumAfter) ].
		laneBounds := CPPoolLaneGeometry
			boundsWithPartitionStart: cursor
			partitionLength: laneLength
			crossStart: parentCrossStart
			crossLength: parentCrossLength
			horizontal: isHorizontal.
		laneShape := laneShapes at: aLane.
		proposedBounds at: laneShape put: laneBounds.

		childLaneSet := laneContext stagedChildLaneSetOf: aLane.
		childLaneSet ifNotNil: [
			self
				reflowLaneSet: childLaneSet
				withinBounds: (self
					bodyBoundsForLaneBounds: laneBounds
					horizontal: isHorizontal)
				using: laneContext
				diagramContext: diagramContext
				horizontal: isHorizontal
				into: proposedBounds ].

		cursor := cursor + laneLength.
		remainingLength := remainingLength - laneLength.
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
