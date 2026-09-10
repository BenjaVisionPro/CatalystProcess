"I provide staged access to one BPMN depiction through its CPDiagram and CPPlane mementos.

CPPlane owns the diagram elements. I own the memento/description pairing for CPPlane elements. Callers use staged access and mutation messages rather than reconstructing that ownership path."
Class {
	#name : 'CPDiagramMementoContext',
	#superclass : 'Object',
	#instVars : [
		'diagram',
		'diagramMemento',
		'plane',
		'planeMemento',
		'elementsDescription'
	],
	#category : 'BVC-BPM-Magritte-Diagram',
	#package : 'BVC-BPM-Magritte',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPDiagramMementoContext class >> diagram: aDiagram owningDiagramMemento: aDiagramMemento plane: aPlane planeMemento: aPlaneMemento planeElementsDescription: aDescription [
	^ self new
		diagram: aDiagram;
		owningDiagramMemento: aDiagramMemento;
		plane: aPlane;
		planeMemento: aPlaneMemento;
		planeElementsDescription: aDescription;
		yourself
]

{ #category : 'instance creation' }
CPDiagramMementoContext class >> diagram: aDiagram inMemento: anOwnerMemento using: aDiagramDescription [
	| diagramMemento planeDescription plane planeMemento elementsDescription |
	diagramMemento := anOwnerMemento
		childMementoFor: aDiagram
		inRelation: aDiagramDescription.
	planeDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #plane ].
	plane := diagramMemento readUsing: planeDescription.
	planeMemento := diagramMemento
		childMementoFor: plane
		inRelation: planeDescription.
	elementsDescription := planeMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	^ self
		diagram: aDiagram
		owningDiagramMemento: diagramMemento
		plane: plane
		planeMemento: planeMemento
		planeElementsDescription: elementsDescription
]

{ #category : 'accessing' }
CPDiagramMementoContext >> diagram [ ^ diagram ]
{ #category : 'accessing' }
CPDiagramMementoContext >> diagram: anObject [ diagram := anObject ]

{ #category : 'accessing' }
CPDiagramMementoContext >> plane [ ^ plane ]
{ #category : 'accessing' }
CPDiagramMementoContext >> plane: anObject [ plane := anObject ]

{ #category : 'accessing' }
CPDiagramMementoContext >> planeMemento [ ^ planeMemento ]
{ #category : 'accessing' }
CPDiagramMementoContext >> planeMemento: aMemento [ planeMemento := aMemento ]

{ #category : 'accessing' }
CPDiagramMementoContext >> owningDiagramMemento [ ^ diagramMemento ]

{ #category : 'private - initialization' }
CPDiagramMementoContext >> owningDiagramMemento: aMemento [ diagramMemento := aMemento ]

{ #category : 'private - initialization' }
CPDiagramMementoContext >> planeElementsDescription: aDescription [ elementsDescription := aDescription ]

{ #category : 'staged state' }
CPDiagramMementoContext >> elements [
	^ planeMemento readUsing: elementsDescription
]

{ #category : 'staged state' }
CPDiagramMementoContext >> mementoFor: aDiagramElement [
	^ planeMemento
		childMementoFor: aDiagramElement
		inRelation: elementsDescription
]

{ #category : 'staged state' }
CPDiagramMementoContext >> modelElementOf: aDiagramElement [
	| elementMemento description |
	elementMemento := self mementoFor: aDiagramElement.
	description := elementMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	^ elementMemento readUsing: description
]

{ #category : 'staged state' }
CPDiagramMementoContext >> boundsOf: aShape [
	| shapeMemento description |
	shapeMemento := self mementoFor: aShape.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	^ shapeMemento readUsing: description
]

{ #category : 'staged state' }
CPDiagramMementoContext >> waypointsOf: anEdge [
	| edgeMemento description |
	edgeMemento := self mementoFor: anEdge.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	^ (edgeMemento readUsing: description) ifNil: [ #() ]
]

{ #category : 'staged state' }
CPDiagramMementoContext >> labelSegmentIndexOf: anEdge [
	| edgeMemento description |
	edgeMemento := self mementoFor: anEdge.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelSegmentIndex ].
	^ edgeMemento readUsing: description
]

{ #category : 'staged state' }
CPDiagramMementoContext >> labelSegmentPositionOf: anEdge [
	| edgeMemento description |
	edgeMemento := self mementoFor: anEdge.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelSegmentPosition ].
	^ edgeMemento readUsing: description
]

{ #category : 'staged state' }
CPDiagramMementoContext >> labelOffsetOf: anEdge [
	| edgeMemento description |
	edgeMemento := self mementoFor: anEdge.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelOffset ].
	^ edgeMemento readUsing: description
]

{ #category : 'staged state' }
CPDiagramMementoContext >> expandedOf: aShape [
	| shapeMemento description |
	shapeMemento := self mementoFor: aShape.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #isExpanded ].
	^ shapeMemento readUsing: description
]

{ #category : 'resolving' }
CPDiagramMementoContext >> shapesForModelElement: aModelElement [
	^ self elements select: [ :each |
		each isShape and: [ (self modelElementOf: each) == aModelElement ] ]
]

{ #category : 'resolving' }
CPDiagramMementoContext >> edgesForModelElement: aModelElement [
	^ self elements select: [ :each |
		each isEdge and: [ (self modelElementOf: each) == aModelElement ] ]
]

{ #category : 'staged state' }
CPDiagramMementoContext >> validateElements: aCollection [
	^ elementsDescription validate: aCollection
]

{ #category : 'staged state' }
CPDiagramMementoContext >> writeElements: aCollection [
	planeMemento write: aCollection using: elementsDescription
]

{ #category : 'staged state' }
CPDiagramMementoContext >> detachElement: aDiagramElement [
	planeMemento detachChildMementoFor: aDiagramElement inRelation: elementsDescription
]

{ #category : 'staged state' }
CPDiagramMementoContext >> writeBounds: aRectangle of: aShape [
	| shapeMemento description |
	shapeMemento := self mementoFor: aShape.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	shapeMemento write: aRectangle using: description
]

{ #category : 'staged state' }
CPDiagramMementoContext >> writeWaypoints: aCollection of: anEdge [
	| edgeMemento description |
	edgeMemento := self mementoFor: anEdge.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	edgeMemento write: aCollection using: description
]

{ #category : 'staged state' }
CPDiagramMementoContext >> writeExpanded: aBoolean of: aShape [
	| shapeMemento description |
	shapeMemento := self mementoFor: aShape.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #isExpanded ].
	shapeMemento write: aBoolean using: description
]

{ #category : 'resolving' }
CPDiagramMementoContext >> shapeForModelElement: aModelElement [
	| matches |
	matches := self shapesForModelElement: aModelElement.
	^ matches size = 1 ifTrue: [ matches first ] ifFalse: [ nil ]
]

{ #category : 'resolving' }
CPDiagramMementoContext >> edgeForModelElement: aModelElement [
	| matches |
	matches := self edgesForModelElement: aModelElement.
	^ matches size = 1 ifTrue: [ matches first ] ifFalse: [ nil ]
]
