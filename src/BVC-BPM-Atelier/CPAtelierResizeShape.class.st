"I coordinate one Process diagram intention: resize an existing CPShape.

Assessment validates staged membership and the proposed Rectangle through the shape's Magritte bounds description. Apply stages the new bounds and moves each incident CPEdge endpoint-reference waypoint by the shape-center delta. When the resized shape depicts an Activity, attached Boundary Event shapes stay on the same host side at the same normalized position along that side, and their incident edge endpoints follow them. Semantic flow-node identity is unchanged."
Class {
	#name : 'CPAtelierResizeShape',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'shape',
		'bounds',
		'processMemento',
		'diagramDescription',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierResizeShape class >> shape: aShape bounds: aRectangle processMemento: aMemento diagramDescription: aDescription [
	^ self new
		shape: aShape;
		bounds: aRectangle;
		processMemento: aMemento;
		diagramDescription: aDescription;
		yourself
]

{ #category : 'instance creation' }
CPAtelierResizeShape class >> shape: aShape bounds: aRectangle processMemento: aMemento diagramContext: aDiagramContext [
	^ self new shape: aShape; bounds: aRectangle; processMemento: aMemento; diagramContext: aDiagramContext; yourself
]

{ #category : 'assessing' }
CPAtelierResizeShape >> assess [
	| diagram elements shapeMemento boundsDescription currentBounds occurrences diagramContext |
	shape ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'A diagram shape is required.' ].
	bounds ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'Diagram bounds are required.' ].
	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'The process has no staged diagram.' ].
	elements := diagramContext elements.
	occurrences := elements count: [ :each | each == shape ].
	occurrences = 1 ifFalse: [
		^ self rejectedWithCurrentBounds: nil because: 'The shape must occur exactly once in the diagram.' ].
	shapeMemento := diagramContext mementoFor: shape.
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	currentBounds := shapeMemento readUsing: boundsDescription.
	currentBounds = bounds ifTrue: [
		^ self rejectedWithCurrentBounds: currentBounds because: 'The shape already has the requested bounds.' ].
	[ boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithCurrentBounds: currentBounds because: anException printString ].
	(self validateAttachedBoundaryEventShapesFor: (diagramContext modelElementOf: shape) in: diagramContext)
		ifNotNil: [ :reason |
			^ self rejectedWithCurrentBounds: currentBounds because: reason ].
	^ CPAtelierMoveShapeAssessment
		shape: shape
		currentBounds: currentBounds
		proposedBounds: bounds
]

{ #category : 'applying' }
CPAtelierResizeShape >> applyAssessment: anAssessment [
	| diagram elements resizedModelElement centerDelta diagramContext |
	diagramContext := self stagedDiagramContext.
	elements := diagramContext elements.
	resizedModelElement := diagramContext modelElementOf: shape.
	centerDelta := anAssessment proposedBounds center - anAssessment currentBounds center.
	diagramContext writeBounds: anAssessment proposedBounds of: shape.
	elements do: [ :each |
		(each isEdge and: [ self edge: each isIncidentTo: resizedModelElement ]) ifTrue: [
			self
				translateEndpointOf: each
				forResizedModelElement: resizedModelElement
				by: centerDelta
				context: diagramContext ] ].
	self
		repositionAttachedBoundaryEventsFor: resizedModelElement
		fromActivityBounds: anAssessment currentBounds
		toActivityBounds: anAssessment proposedBounds
		in: diagramContext
]


{ #category : 'private - assessing' }
CPAtelierResizeShape >> validateAttachedBoundaryEventShapesFor: aModelElement in: aDiagramContext [
	| flowContext |
	aModelElement isActivity ifFalse: [ ^ nil ].
	flowContext := CPProcessFlowContainerContext
		containingFlowElement: aModelElement
		inRootMemento: processMemento.
	flowContext ifNil: [ ^ nil ].
	(flowContext attachedBoundaryEventsFor: aModelElement) do: [ :aBoundaryEvent |
		(aDiagramContext shapesForModelElement: aBoundaryEvent) size = 1 ifFalse: [
			^ 'Every attached boundary event must have exactly one diagram shape.' ] ].
	^ nil
]

{ #category : 'private - applying' }
CPAtelierResizeShape >> repositionAttachedBoundaryEventsFor: aModelElement fromActivityBounds: currentActivityBounds toActivityBounds: proposedActivityBounds in: aDiagramContext [
	| flowContext |
	aModelElement isActivity ifFalse: [ ^ self ].
	flowContext := CPProcessFlowContainerContext
		containingFlowElement: aModelElement
		inRootMemento: processMemento.
	flowContext ifNil: [ ^ self ].
	(flowContext attachedBoundaryEventsFor: aModelElement) do: [ :aBoundaryEvent |
		| boundaryShape currentBoundaryBounds proposedBoundaryBounds delta |
		boundaryShape := (aDiagramContext shapesForModelElement: aBoundaryEvent) anyOne.
		currentBoundaryBounds := aDiagramContext boundsOf: boundaryShape.
		proposedBoundaryBounds := self
			boundaryEventBounds: currentBoundaryBounds
			fromActivityBounds: currentActivityBounds
			toActivityBounds: proposedActivityBounds.
		delta := proposedBoundaryBounds origin - currentBoundaryBounds origin.
		aDiagramContext writeBounds: proposedBoundaryBounds of: boundaryShape.
		delta isZero ifFalse: [
			aDiagramContext elements do: [ :each |
				(each isEdge and: [ self edge: each isIncidentTo: aBoundaryEvent ]) ifTrue: [
					self
						translateEndpointOf: each
						forResizedModelElement: aBoundaryEvent
						by: delta
						context: aDiagramContext ] ] ] ]
]

{ #category : 'private - geometry' }
CPAtelierResizeShape >> boundaryEventBounds: eventBounds fromActivityBounds: currentActivityBounds toActivityBounds: proposedActivityBounds [
	| center leftDistance rightDistance topDistance bottomDistance minimum verticalSide ratio proposedCenter |
	center := eventBounds center.
	leftDistance := (center x - currentActivityBounds left) abs.
	rightDistance := (center x - currentActivityBounds right) abs.
	topDistance := (center y - currentActivityBounds top) abs.
	bottomDistance := (center y - currentActivityBounds bottom) abs.
	minimum := { leftDistance. rightDistance. topDistance. bottomDistance } min.
	verticalSide := leftDistance = minimum or: [ rightDistance = minimum ].
	verticalSide
		ifTrue: [
			ratio := currentActivityBounds height isZero
				ifTrue: [ 0.5 ]
				ifFalse: [ (center y - currentActivityBounds top) / currentActivityBounds height ].
			ratio := (ratio max: 0) min: 1.
			proposedCenter := ((leftDistance = minimum)
				ifTrue: [ proposedActivityBounds left ]
				ifFalse: [ proposedActivityBounds right ])
				@ (proposedActivityBounds top + (proposedActivityBounds height * ratio)) ]
		ifFalse: [
			ratio := currentActivityBounds width isZero
				ifTrue: [ 0.5 ]
				ifFalse: [ (center x - currentActivityBounds left) / currentActivityBounds width ].
			ratio := (ratio max: 0) min: 1.
			proposedCenter := (proposedActivityBounds left + (proposedActivityBounds width * ratio))
				@ ((topDistance = minimum)
					ifTrue: [ proposedActivityBounds top ]
					ifFalse: [ proposedActivityBounds bottom ]) ].
	^ (proposedCenter - (eventBounds extent / 2)) extent: eventBounds extent
]

{ #category : 'private - applying' }
CPAtelierResizeShape >> edge: anEdge isIncidentTo: aModelElement [
	| sequenceFlow |
	sequenceFlow := anEdge modelElement.
	^ (self stagedSourceOf: sequenceFlow) == aModelElement
		or: [ (self stagedTargetOf: sequenceFlow) == aModelElement ]
]

{ #category : 'private - staged state' }
CPAtelierResizeShape >> stagedSourceOf: aSequenceFlow [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aSequenceFlow
		inRootMemento: processMemento.
	^ context ifNotNil: [ context stagedSourceOf: aSequenceFlow ]
]

{ #category : 'private - staged state' }
CPAtelierResizeShape >> stagedTargetOf: aSequenceFlow [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aSequenceFlow
		inRootMemento: processMemento.
	^ context ifNotNil: [ context stagedTargetOf: aSequenceFlow ]
]

{ #category : 'private - applying' }
CPAtelierResizeShape >> translateEndpointOf: anEdge forResizedModelElement: aModelElement by: delta context: diagramContext [
	| waypoints translated sequenceFlow |
	waypoints := diagramContext waypointsOf: anEdge.
	waypoints ifEmpty: [ ^ self ].
	translated := waypoints asOrderedCollection copy.
	sequenceFlow := anEdge modelElement.
	(self stagedSourceOf: sequenceFlow) == aModelElement ifTrue: [
		translated at: 1 put: translated first + delta ].
	(self stagedTargetOf: sequenceFlow) == aModelElement ifTrue: [
		translated at: translated size put: translated last + delta ].
	diagramContext writeWaypoints: translated of: anEdge
]

{ #category : 'private' }
CPAtelierResizeShape >> rejectedWithCurrentBounds: aRectangle because: aString [
	^ CPAtelierMoveShapeAssessment
		shape: shape
		currentBounds: aRectangle
		proposedBounds: bounds
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierResizeShape >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierResizeShape >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierResizeShape >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierResizeShape >> diagramDescription: aDescription [ diagramDescription := aDescription ]

{ #category : 'private - staged state' }
CPAtelierResizeShape >> stagedDiagramContext [
	diagramContext ifNotNil: [ ^ diagramContext ].
	diagramContext := self stagedDiagramContext.
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierResizeShape >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
