"I describe the rendered geometry of one authored BPMN-DI plane.

I compute the authoritative authored bounds from staged CPShape bounds and CPEdge waypoints. I also expose the normalization offset and layer extent required to render those authored coordinates without changing them."
Class {
	#name : 'CPDiagramPlaneGeometry',
	#superclass : 'Object',
	#instVars : [
		'diagramBounds',
		'diagramExtent'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPDiagramPlaneGeometry class >> shapes: someShapes edges: someEdges context: aDiagramContext [
	^ self new
		computeForShapes: someShapes
		edges: someEdges
		context: aDiagramContext;
		yourself
]

{ #category : 'initialization' }
CPDiagramPlaneGeometry >> initialize [
	super initialize.
	diagramBounds := 0 @ 0 extent: 0 @ 0.
	diagramExtent := 0 @ 0
]

{ #category : 'private - computing' }
CPDiagramPlaneGeometry >> computeForShapes: someShapes edges: someEdges context: aDiagramContext [
	| minimumX minimumY maximumX maximumY hasContent |
	hasContent := false.
	someShapes do: [ :aShape |
		| bounds |
		bounds := aDiagramContext boundsOf: aShape.
		bounds ifNotNil: [
			hasContent := true.
			minimumX := minimumX ifNil: [ bounds left ] ifNotNil: [ minimumX min: bounds left ].
			minimumY := minimumY ifNil: [ bounds top ] ifNotNil: [ minimumY min: bounds top ].
			maximumX := maximumX ifNil: [ bounds right ] ifNotNil: [ maximumX max: bounds right ].
			maximumY := maximumY ifNil: [ bounds bottom ] ifNotNil: [ maximumY max: bounds bottom ] ] ].
	someEdges do: [ :anEdge |
		(aDiagramContext waypointsOf: anEdge) do: [ :aPoint |
			hasContent := true.
			minimumX := minimumX ifNil: [ aPoint x ] ifNotNil: [ minimumX min: aPoint x ].
			minimumY := minimumY ifNil: [ aPoint y ] ifNotNil: [ minimumY min: aPoint y ].
			maximumX := maximumX ifNil: [ aPoint x ] ifNotNil: [ maximumX max: aPoint x ].
			maximumY := maximumY ifNil: [ aPoint y ] ifNotNil: [ maximumY max: aPoint y ] ] ].

	diagramBounds := hasContent
		ifTrue: [ minimumX @ minimumY corner: maximumX @ maximumY ]
		ifFalse: [ 0 @ 0 extent: 0 @ 0 ].
	diagramExtent := diagramBounds extent
]

{ #category : 'accessing' }
CPDiagramPlaneGeometry >> diagramBounds [
	^ diagramBounds
]

{ #category : 'accessing' }
CPDiagramPlaneGeometry >> diagramExtent [
	^ diagramExtent
]

{ #category : 'accessing' }
CPDiagramPlaneGeometry >> normalizationOffset [
	^ 0 @ 0 - diagramBounds origin
]

{ #category : 'accessing' }
CPDiagramPlaneGeometry >> layerExtent [
	^ diagramBounds corner max: 1 @ 1
]

