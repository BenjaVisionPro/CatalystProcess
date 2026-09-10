"I coordinate one Process diagram intention: move an existing CPShape.

Assessment validates that the shape belongs exactly once to the staged CPDiagram and validates the proposed Rectangle through the shape's Magritte bounds description. Apply stages the new bounds and translates the first or last waypoint of each incident CPEdge by the same delta, preserving sequence-flow docking in diagram state."
Class {
	#name : 'CPAtelierMoveShape',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'shape',
		'bounds',
		'processMemento',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierMoveShape class >> shape: aShape bounds: aRectangle processMemento: aMemento diagramContext: aDescription [
	^ self new
		shape: aShape;
		bounds: aRectangle;
		processMemento: aMemento;
		diagramContext: aDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierMoveShape >> assess [
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
		^ self rejectedWithCurrentBounds: currentBounds because: 'The shape is already at the requested bounds.' ].
	[ boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithCurrentBounds: currentBounds because: anException printString ].
	^ CPAtelierMoveShapeAssessment
		shape: shape
		currentBounds: currentBounds
		proposedBounds: bounds
]

{ #category : 'applying' }
CPAtelierMoveShape >> applyAssessment: anAssessment [
	| diagram elements movedModelElement delta diagramContext |
	diagramContext := self stagedDiagramContext.
	elements := diagramContext elements.
	movedModelElement := diagramContext modelElementOf: shape.
	delta := anAssessment proposedBounds origin - anAssessment currentBounds origin.
	diagramContext writeBounds: anAssessment proposedBounds of: shape.
	elements do: [ :each |
		(each isEdge and: [ self edge: each isIncidentTo: movedModelElement ]) ifTrue: [
			self
				translateEndpointOf: each
				forMovedModelElement: movedModelElement
				by: delta
				context: diagramContext ] ]
]

{ #category : 'private - applying' }
CPAtelierMoveShape >> edge: anEdge isIncidentTo: aModelElement [
	| sequenceFlow |
	sequenceFlow := anEdge modelElement.
	^ (self stagedSourceOf: sequenceFlow) == aModelElement
		or: [ (self stagedTargetOf: sequenceFlow) == aModelElement ]
]

{ #category : 'private - staged state' }
CPAtelierMoveShape >> stagedSourceOf: aSequenceFlow [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aSequenceFlow
		inRootMemento: processMemento.
	^ context ifNotNil: [ context stagedSourceOf: aSequenceFlow ]
]

{ #category : 'private - staged state' }
CPAtelierMoveShape >> stagedTargetOf: aSequenceFlow [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aSequenceFlow
		inRootMemento: processMemento.
	^ context ifNotNil: [ context stagedTargetOf: aSequenceFlow ]
]

{ #category : 'private - applying' }
CPAtelierMoveShape >> translateEndpointOf: anEdge forMovedModelElement: aModelElement by: delta context: diagramContext [
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
CPAtelierMoveShape >> rejectedWithCurrentBounds: aRectangle because: aString [
	^ CPAtelierMoveShapeAssessment
		shape: shape
		currentBounds: aRectangle
		proposedBounds: bounds
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierMoveShape >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierMoveShape >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierMoveShape >> bounds [ ^ bounds ]
{ #category : 'accessing' }
CPAtelierMoveShape >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierMoveShape >> processMemento [ ^ processMemento ]
{ #category : 'accessing' }
CPAtelierMoveShape >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'private - staged state' }
CPAtelierMoveShape >> stagedDiagramContext [
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierMoveShape >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
