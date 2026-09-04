"I coordinate one Process diagram intention: move an existing CPShape.

Assessment validates that the shape belongs exactly once to the staged CPDiagram and validates the proposed Rectangle through the shape's Magritte bounds description. Apply stages the new bounds and translates the first or last waypoint of each incident CPEdge by the same delta, preserving sequence-flow docking in diagram state."
Class {
	#name : 'CPAtelierMoveShape',
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
CPAtelierMoveShape class >> shape: aShape bounds: aRectangle processMemento: aMemento diagramDescription: aDescription [
	^ self new
		shape: aShape;
		bounds: aRectangle;
		processMemento: aMemento;
		diagramDescription: aDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierMoveShape >> assess [
	| diagram diagramMemento elementsDescription elements shapeMemento boundsDescription currentBounds occurrences |
	shape ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'A diagram shape is required.' ].
	bounds ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'Diagram bounds are required.' ].
	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	occurrences := elements count: [ :each | each == shape ].
	occurrences = 1 ifFalse: [
		^ self rejectedWithCurrentBounds: nil because: 'The shape must occur exactly once in the diagram.' ].
	shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
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
	| diagram diagramMemento elementsDescription elements shapeMemento boundsDescription delta |
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	delta := anAssessment proposedBounds origin - anAssessment currentBounds origin.
	shapeMemento write: anAssessment proposedBounds using: boundsDescription.
	elements do: [ :each |
		(each isEdge and: [ self edge: each isIncidentTo: shape modelElement ]) ifTrue: [
			self
				translateEndpointOf: each
				forMovedModelElement: shape modelElement
				by: delta
				in: diagramMemento
				elementsDescription: elementsDescription ] ]
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
	| flowElementsDescription flowMemento description |
	flowElementsDescription := processMemento magritteDescription detect: [ :each | each handlesSelector: #flowElements ].
	flowMemento := processMemento childMementoFor: aSequenceFlow inRelation: flowElementsDescription.
	description := flowMemento magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierMoveShape >> stagedTargetOf: aSequenceFlow [
	| flowElementsDescription flowMemento description |
	flowElementsDescription := processMemento magritteDescription detect: [ :each | each handlesSelector: #flowElements ].
	flowMemento := processMemento childMementoFor: aSequenceFlow inRelation: flowElementsDescription.
	description := flowMemento magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - applying' }
CPAtelierMoveShape >> translateEndpointOf: anEdge forMovedModelElement: aModelElement by: delta in: diagramMemento elementsDescription: elementsDescription [
	| edgeMemento waypointsDescription waypoints translated sequenceFlow |
	edgeMemento := diagramMemento childMementoFor: anEdge inRelation: elementsDescription.
	waypointsDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	waypoints := edgeMemento readUsing: waypointsDescription.
	waypoints ifEmpty: [ ^ self ].
	translated := waypoints asOrderedCollection.
	sequenceFlow := anEdge modelElement.
	(self stagedSourceOf: sequenceFlow) == aModelElement ifTrue: [
		translated at: 1 put: translated first + delta ].
	(self stagedTargetOf: sequenceFlow) == aModelElement ifTrue: [
		translated at: translated size put: translated last + delta ].
	edgeMemento write: translated using: waypointsDescription
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
{ #category : 'accessing' }
CPAtelierMoveShape >> diagramDescription [ ^ diagramDescription ]
{ #category : 'accessing' }
CPAtelierMoveShape >> diagramDescription: aDescription [ diagramDescription := aDescription ]
