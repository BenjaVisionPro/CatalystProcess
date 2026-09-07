"I coordinate one Process diagram intention: resize an existing CPShape.

Assessment validates staged membership and the proposed Rectangle through the shape's Magritte bounds description. Apply stages the new bounds and moves each incident CPEdge endpoint-reference waypoint by the shape-center delta. Semantic flow-node identity is unchanged."
Class {
	#name : 'CPAtelierResizeShape',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'shape',
		'bounds',
		'processMemento',
		'diagramDescription'
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

{ #category : 'assessing' }
CPAtelierResizeShape >> assess [
	| diagram diagramMemento elementsDescription elements shapeMemento boundsDescription currentBounds occurrences diagramContext |
	shape ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'A diagram shape is required.' ].
	bounds ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'Diagram bounds are required.' ].
	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'The process has no staged diagram.' ].
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	diagramMemento := diagramContext diagramMemento.
	elementsDescription := diagramContext elementsDescription.
	elements := diagramMemento readUsing: elementsDescription.
	occurrences := elements count: [ :each | each == shape ].
	occurrences = 1 ifFalse: [
		^ self rejectedWithCurrentBounds: nil because: 'The shape must occur exactly once in the diagram.' ].
	shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	currentBounds := shapeMemento readUsing: boundsDescription.
	currentBounds = bounds ifTrue: [
		^ self rejectedWithCurrentBounds: currentBounds because: 'The shape already has the requested bounds.' ].
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
CPAtelierResizeShape >> applyAssessment: anAssessment [
	| diagram diagramMemento elementsDescription elements shapeMemento
	  boundsDescription modelElementDescription resizedModelElement centerDelta diagramContext |
	diagram := processMemento readUsing: diagramDescription.
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	diagramMemento := diagramContext diagramMemento.
	elementsDescription := diagramContext elementsDescription.
	elements := diagramMemento readUsing: elementsDescription.
	shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	modelElementDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	resizedModelElement := shapeMemento readUsing: modelElementDescription.
	centerDelta := anAssessment proposedBounds center - anAssessment currentBounds center.
	shapeMemento write: anAssessment proposedBounds using: boundsDescription.
	elements do: [ :each |
		(each isEdge and: [ self edge: each isIncidentTo: resizedModelElement ]) ifTrue: [
			self
				translateEndpointOf: each
				forResizedModelElement: resizedModelElement
				by: centerDelta
				in: diagramMemento
				elementsDescription: elementsDescription ] ]
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
CPAtelierResizeShape >> translateEndpointOf: anEdge forResizedModelElement: aModelElement by: delta in: aDiagramMemento elementsDescription: anElementsDescription [
	| edgeMemento waypointsDescription waypoints translated sequenceFlow |
	edgeMemento := aDiagramMemento childMementoFor: anEdge inRelation: anElementsDescription.
	waypointsDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	waypoints := edgeMemento readUsing: waypointsDescription.
	waypoints ifEmpty: [ ^ self ].
	translated := waypoints asOrderedCollection copy.
	sequenceFlow := anEdge modelElement.
	(self stagedSourceOf: sequenceFlow) == aModelElement ifTrue: [
		translated at: 1 put: translated first + delta ].
	(self stagedTargetOf: sequenceFlow) == aModelElement ifTrue: [
		translated at: translated size put: translated last + delta ].
	edgeMemento write: translated using: waypointsDescription
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
