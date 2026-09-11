"I define Atelier's geometric layout rules for BPMN Lanes.

These are editing and auto-layout rules, not renderer rules. BPMN DI remains authoritative for projection."
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
