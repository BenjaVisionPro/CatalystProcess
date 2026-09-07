"I coordinate one Process diagram intention: translate a group of existing CPShape instances by one shared delta.

Assessment validates every staged shape and its proposed Rectangle. Apply stages all shape bounds in one operation. Sequence-flow routing follows group semantics: an edge whose two endpoints move translates its complete waypoint path; an edge with one moving endpoint translates that endpoint waypoint."
Class {
	#name : 'CPAtelierMoveShapes',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'boundsByShape',
		'processMemento',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierMoveShapes class >> boundsByShape: aDictionary processMemento: aMemento diagramDescription: aDescription [
	^ self new
		boundsByShape: aDictionary;
		processMemento: aMemento;
		diagramDescription: aDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierMoveShapes >> assess [
	| diagram diagramMemento elementsDescription elements currentBoundsByShape proposedBoundsByShape proposedDelta diagramContext |
	(boundsByShape isNil or: [ boundsByShape isEmpty ]) ifTrue: [
		^ self rejectedWithCurrentBounds: IdentityDictionary new delta: nil because: 'At least one diagram shape is required.' ].
	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [
		^ self rejectedWithCurrentBounds: IdentityDictionary new delta: nil because: 'The process has no staged diagram.' ].
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	diagramMemento := diagramContext diagramMemento.
	elementsDescription := diagramContext elementsDescription.
	elements := diagramMemento readUsing: elementsDescription.
	currentBoundsByShape := IdentityDictionary new.
	proposedBoundsByShape := IdentityDictionary new.
	proposedDelta := nil.

	boundsByShape keysAndValuesDo: [ :shape :proposedBounds |
		| currentBounds shapeDelta |
		currentBounds := self
			validateShape: shape
			proposedBounds: proposedBounds
			inElements: elements
			diagramMemento: diagramMemento
			elementsDescription: elementsDescription
			currentBoundsByShape: currentBoundsByShape
			delta: proposedDelta.
		currentBounds isString ifTrue: [
			^ self rejectedWithCurrentBounds: currentBoundsByShape delta: proposedDelta because: currentBounds ].
		shapeDelta := proposedBounds origin - currentBounds origin.
		proposedDelta
			ifNil: [ proposedDelta := shapeDelta ]
			ifNotNil: [
				proposedDelta = shapeDelta ifFalse: [
					^ self rejectedWithCurrentBounds: currentBoundsByShape delta: proposedDelta because: 'All group shapes require the same translation delta.' ] ].
		proposedBoundsByShape at: shape put: proposedBounds ].

	proposedDelta isZero ifTrue: [
		^ self rejectedWithCurrentBounds: currentBoundsByShape delta: proposedDelta because: 'The group is already at the requested bounds.' ].

	self
		addAttachedBoundaryEventShapesForMovedShapesTo: proposedBoundsByShape
		currentBoundsByShape: currentBoundsByShape
		by: proposedDelta
		diagramContext: diagramContext.

	^ CPAtelierMoveShapesAssessment
		currentBoundsByShape: currentBoundsByShape
		proposedBoundsByShape: proposedBoundsByShape
		delta: proposedDelta
]

{ #category : 'private - assessing' }
CPAtelierMoveShapes >> validateShape: shape proposedBounds: proposedBounds inElements: elements diagramMemento: diagramMemento elementsDescription: elementsDescription currentBoundsByShape: currentBoundsByShape delta: proposedDelta [
	| occurrences shapeMemento boundsDescription currentBounds |
	occurrences := elements count: [ :each | each == shape ].
	occurrences = 1 ifFalse: [ ^ 'Every moved shape must occur exactly once in the diagram.' ].
	shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	currentBounds := shapeMemento readUsing: boundsDescription.
	[
		boundsDescription validate: proposedBounds
	] on: MAValidationError do: [ :anException |
		^ anException printString ].
	currentBoundsByShape at: shape put: currentBounds.
	^ currentBounds
]

{ #category : 'private - assessing' }
CPAtelierMoveShapes >> addAttachedBoundaryEventShapesForMovedShapesTo: proposedBoundsByShape currentBoundsByShape: currentBoundsByShape by: delta diagramContext: diagramContext [
	| movedActivities |
	movedActivities := IdentitySet new.
	proposedBoundsByShape keysDo: [ :aShape |
		| modelElement |
		modelElement := diagramContext modelElementOf: aShape.
		(modelElement notNil and: [ modelElement isActivity ]) ifTrue: [
			movedActivities add: modelElement ] ].
	movedActivities do: [ :anActivity |
		| flowContext |
		flowContext := CPProcessFlowContainerContext
			containingFlowElement: anActivity
			inRootMemento: processMemento.
		flowContext ifNotNil: [
			(flowContext attachedBoundaryEventsFor: anActivity) do: [ :aBoundaryEvent |
				| shapes boundaryShape currentBounds |
				shapes := diagramContext shapesForModelElement: aBoundaryEvent.
				shapes size = 1 ifTrue: [
					boundaryShape := shapes anyOne.
					(proposedBoundsByShape includesKey: boundaryShape) ifFalse: [
						currentBounds := diagramContext boundsOf: boundaryShape.
						currentBoundsByShape at: boundaryShape put: currentBounds.
						proposedBoundsByShape at: boundaryShape put: (currentBounds translateBy: delta) ] ] ] ] ]
]


{ #category : 'applying' }
CPAtelierMoveShapes >> applyAssessment: anAssessment [
	| diagram diagramMemento elementsDescription elements movedModelElements delta diagramContext |
	diagram := processMemento readUsing: diagramDescription.
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	diagramMemento := diagramContext diagramMemento.
	elementsDescription := diagramContext elementsDescription.
	elements := diagramMemento readUsing: elementsDescription.
	movedModelElements := IdentitySet new.
	delta := anAssessment delta.

	anAssessment proposedBoundsByShape keysAndValuesDo: [ :shape :proposedBounds |
		| shapeMemento boundsDescription modelElementDescription |
		shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
		boundsDescription := shapeMemento magritteDescription
			detect: [ :each | each handlesSelector: #bounds ].
		modelElementDescription := shapeMemento magritteDescription
			detect: [ :each | each handlesSelector: #modelElement ].
		movedModelElements add: (shapeMemento readUsing: modelElementDescription).
		shapeMemento write: proposedBounds using: boundsDescription ].

	elements do: [ :each |
		each isEdge ifTrue: [
			self
				translateEdge: each
				forMovedModelElements: movedModelElements
				by: delta
				in: diagramMemento
				elementsDescription: elementsDescription ] ]
]

{ #category : 'private - applying' }
CPAtelierMoveShapes >> translateEdge: anEdge forMovedModelElements: movedModelElements by: delta in: diagramMemento elementsDescription: elementsDescription [
	| sequenceFlow sourceMoves targetMoves edgeMemento waypointsDescription waypoints translated |
	sequenceFlow := anEdge modelElement.
	sourceMoves := movedModelElements includes: (self stagedSourceOf: sequenceFlow).
	targetMoves := movedModelElements includes: (self stagedTargetOf: sequenceFlow).
	(sourceMoves or: [ targetMoves ]) ifFalse: [ ^ self ].

	edgeMemento := diagramMemento childMementoFor: anEdge inRelation: elementsDescription.
	waypointsDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	waypoints := edgeMemento readUsing: waypointsDescription.
	waypoints ifEmpty: [ ^ self ].
	translated := waypoints asOrderedCollection copy.

	(sourceMoves and: [ targetMoves ])
		ifTrue: [
			1 to: translated size do: [ :index |
				translated at: index put: (translated at: index) + delta ] ]
		ifFalse: [
			sourceMoves ifTrue: [
				translated at: 1 put: translated first + delta ].
			targetMoves ifTrue: [
				translated at: translated size put: translated last + delta ] ].
	edgeMemento write: translated using: waypointsDescription
]

{ #category : 'private - staged state' }
CPAtelierMoveShapes >> stagedSourceOf: aSequenceFlow [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aSequenceFlow
		inRootMemento: processMemento.
	^ context ifNotNil: [ context stagedSourceOf: aSequenceFlow ]
]

{ #category : 'private - staged state' }
CPAtelierMoveShapes >> stagedTargetOf: aSequenceFlow [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aSequenceFlow
		inRootMemento: processMemento.
	^ context ifNotNil: [ context stagedTargetOf: aSequenceFlow ]
]

{ #category : 'private' }
CPAtelierMoveShapes >> rejectedWithCurrentBounds: currentBounds delta: aPoint because: aString [
	^ CPAtelierMoveShapesAssessment
		currentBoundsByShape: currentBounds
		proposedBoundsByShape: boundsByShape
		delta: aPoint
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierMoveShapes >> boundsByShape [ ^ boundsByShape ]
{ #category : 'accessing' }
CPAtelierMoveShapes >> boundsByShape: aDictionary [ boundsByShape := aDictionary ]
{ #category : 'accessing' }
CPAtelierMoveShapes >> processMemento [ ^ processMemento ]
{ #category : 'accessing' }
CPAtelierMoveShapes >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierMoveShapes >> diagramDescription [ ^ diagramDescription ]
{ #category : 'accessing' }
CPAtelierMoveShapes >> diagramDescription: aDescription [ diagramDescription := aDescription ]
