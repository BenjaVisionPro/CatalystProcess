"I provide staged access to one BPMN DI diagram through its Foundation memento.

I keep diagram-element reads in the Magritte layer so renderers and semantic editing code do not duplicate child-memento traversal and description lookup. I make no assumptions that a semantic BPMN element has only one DI depiction."
Class {
	#name : 'CPDiagramMementoContext',
	#superclass : 'Object',
	#instVars : [
		'diagram',
		'diagramMemento',
		'elementsDescription'
	],
	#category : 'BVC-BPM-Magritte-Diagram',
	#package : 'BVC-BPM-Magritte',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPDiagramMementoContext class >> diagram: aDiagram memento: aDiagramMemento elementsDescription: aDescription [
	^ self new
		diagram: aDiagram;
		diagramMemento: aDiagramMemento;
		elementsDescription: aDescription;
		yourself
]


{ #category : 'instance creation' }
CPDiagramMementoContext class >> diagram: aDiagram inMemento: anOwnerMemento using: aDiagramDescription [
	| diagramMemento elementsDescription |
	diagramMemento := anOwnerMemento
		childMementoFor: aDiagram
		inRelation: aDiagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	^ self
		diagram: aDiagram
		memento: diagramMemento
		elementsDescription: elementsDescription
]

{ #category : 'accessing' }
CPDiagramMementoContext >> diagram [
	^ diagram
]

{ #category : 'accessing' }
CPDiagramMementoContext >> diagram: anObject [
	diagram := anObject
]

{ #category : 'accessing' }
CPDiagramMementoContext >> diagramMemento [
	^ diagramMemento
]

{ #category : 'accessing' }
CPDiagramMementoContext >> diagramMemento: anObject [
	diagramMemento := anObject
]

{ #category : 'accessing' }
CPDiagramMementoContext >> elementsDescription [
	^ elementsDescription
]

{ #category : 'accessing' }
CPDiagramMementoContext >> elementsDescription: aDescription [
	elementsDescription := aDescription
]

{ #category : 'staged state' }
CPDiagramMementoContext >> elements [
	^ diagramMemento readUsing: elementsDescription
]

{ #category : 'staged state' }
CPDiagramMementoContext >> mementoFor: aDiagramElement [
	^ diagramMemento
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
