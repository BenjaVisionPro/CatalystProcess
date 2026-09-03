"I render the current staged topology of a CPProcessDesign memento as a simple diagram surface.

I am a Process presentation element, not an Atelier operation surface. I read staged relation and embedded values when they already exist, without creating child mementos merely to display the diagram."
Class {
	#name : 'CPProcessDiagramElement',
	#superclass : 'BlElement',
	#instVars : [
		'memento',
		'nodesDescription',
		'edgesDescription',
		'nodeElementsByNode',
		'edgeElementsByEdge',
		'positionNodeOperationBlock',
		'createNodeOperationBlock',
		'activePaletteDragItem'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessDiagramElement >> initialize [
	super initialize.
	nodeElementsByNode := IdentityDictionary new.
	edgeElementsByEdge := IdentityDictionary new.
	self
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical exact: 420 ];
		layout: BlFrameLayout new;
		clipChildren: false;
		padding: (BlInsets all: 20);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
		background: (Color white alpha: 0.04);
		border: (BlBorder paint: (Color gray alpha: 0.20) width: 1).
	self installPaletteDrop
]

{ #category : 'accessing' }
CPProcessDiagramElement >> memento: aMemento [
	memento := aMemento.
	nodesDescription := aMemento magritteDescription
		detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := aMemento magritteDescription
		detect: [ :each | each handlesSelector: #edges ].
	self refresh
]

{ #category : 'updating' }
CPProcessDiagramElement >> refresh [
	| nodes edges |
	memento ifNil: [ ^ self ].
	self removeChildren.
	nodeElementsByNode removeAll.
	edgeElementsByEdge removeAll.
	nodes := memento readUsing: nodesDescription.
	edges := memento readUsing: edgesDescription.
	edges do: [ :edge | self addEdgeElementFor: edge ].
	nodes withIndexDo: [ :node :index | self addNodeElementFor: node index: index ].
	^ self
]

{ #category : 'private - nodes' }
CPProcessDiagramElement >> addNodeElementFor: aNode index: anIndex [
	| element position |
	position := self stagedPositionOf: aNode ifAbsent: [ self fallbackPositionForIndex: anIndex ].
	element := self newNodeElementFor: aNode.
	element
		constraintsDo: [ :c | c ignoreByLayout ];
		relocate: position.
	nodeElementsByNode at: aNode put: element.
	positionNodeOperationBlock ifNotNil: [ self installPositioningOn: element for: aNode ].
	self addChild: element
]

{ #category : 'private - nodes' }
CPProcessDiagramElement >> newNodeElementFor: aNode [
	| element label |
	element := BlElement new
		extent: (self extentForNode: aNode);
		geometry: (self geometryForNode: aNode);
		background: (Color white alpha: 0.10);
		border: (BlBorder paint: (Color gray alpha: 0.65) width: 1.5);
		layout: BlFrameLayout new;
		yourself.
	label := BrLabel new
		fitContent;
		text: (aNode label ifNil: [ aNode class name ]) asRopedText;
		aptitude: (BrGlamorousLabelAptitude new fontSize: 12);
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		yourself.
	element addChild: label.
	^ element
]

{ #category : 'private - nodes' }
CPProcessDiagramElement >> extentForNode: aNode [
	(aNode isStartNode or: [ aNode isEndNode ]) ifTrue: [ ^ 42 @ 42 ].
	aNode isGatewayNode ifTrue: [ ^ 54 @ 54 ].
	^ 132 @ 54
]

{ #category : 'private - nodes' }
CPProcessDiagramElement >> geometryForNode: aNode [
	(aNode isStartNode or: [ aNode isEndNode ]) ifTrue: [ ^ BlCircleGeometry new ].
	aNode isGatewayNode ifTrue: [
		^ BlPolygonGeometry vertices: { 27 @ 0. 54 @ 27. 27 @ 54. 0 @ 27 } ].
	^ BlRoundedRectangleGeometry cornerRadius: 8
]

{ #category : 'private - nodes' }
CPProcessDiagramElement >> fallbackPositionForIndex: anIndex [
	^ (60 + ((anIndex - 1) * 180)) @ 170
]

{ #category : 'private - staged state' }
CPProcessDiagramElement >> stagedPositionOf: aNode ifAbsent: aBlock [
	| positionDescription |
	(memento hasChildMementoFor: aNode inRelation: nodesDescription) ifFalse: [
		^ aNode position ifNil: aBlock ].
	positionDescription := aNode magritteDescription
		detect: [ :each | each handlesSelector: #position ].
	^ ((memento childMementoFor: aNode inRelation: nodesDescription)
		readUsing: positionDescription) ifNil: aBlock
]

{ #category : 'private - staged state' }
CPProcessDiagramElement >> stagedSourceOf: anEdge [
	| description |
	(memento hasChildMementoFor: anEdge inRelation: edgesDescription) ifFalse: [ ^ anEdge sourceNode ].
	description := anEdge magritteDescription
		detect: [ :each | each handlesSelector: #sourceNode ].
	^ (memento childMementoFor: anEdge inRelation: edgesDescription) readUsing: description
]

{ #category : 'private - staged state' }
CPProcessDiagramElement >> stagedTargetOf: anEdge [
	| description |
	(memento hasChildMementoFor: anEdge inRelation: edgesDescription) ifFalse: [ ^ anEdge targetNode ].
	description := anEdge magritteDescription
		detect: [ :each | each handlesSelector: #targetNode ].
	^ (memento childMementoFor: anEdge inRelation: edgesDescription) readUsing: description
]

{ #category : 'private - edges' }
CPProcessDiagramElement >> addEdgeElementFor: anEdge [
	| source target sourcePosition targetPosition line |
	source := self stagedSourceOf: anEdge.
	target := self stagedTargetOf: anEdge.
	(source isNil or: [ target isNil ]) ifTrue: [ ^ self ].
	sourcePosition := self stagedPositionOf: source ifAbsent: [ ^ self ].
	targetPosition := self stagedPositionOf: target ifAbsent: [ ^ self ].
	sourcePosition := sourcePosition + ((self extentForNode: source) / 2).
	targetPosition := targetPosition + ((self extentForNode: target) / 2).
	line := BlElement new
		constraintsDo: [ :c | c ignoreByLayout ];
		geometry: (BlLineGeometry from: sourcePosition to: targetPosition);
		border: (BlBorder paint: (Color gray alpha: 0.55) width: 1.5);
		yourself.
	edgeElementsByEdge at: anEdge put: line.
	self addChildFirst: line
]


{ #category : 'configuration' }
CPProcessDiagramElement >> createNodeOperationFor: aBlock [
	"The block receives the exact palette candidate and proposed diagram position and answers the Process editing operation for that intention."
	createNodeOperationBlock := aBlock
]

{ #category : 'operations' }
CPProcessDiagramElement >> createNode: aNode at: aPoint [
	| assessment |
	createNodeOperationBlock ifNil: [ ^ nil ].
	assessment := (createNodeOperationBlock value: aNode value: aPoint) apply.
	assessment isApplicable ifTrue: [ self refresh ].
	^ assessment
]

{ #category : 'private - installing' }
CPProcessDiagramElement >> installPaletteDrop [
	self addEventHandler: (BlDropHandler new
		acceptItemsSuchThat: [ :aDragItem :aDropArea | self acceptsPaletteDragItem: aDragItem ];
		whenDragLeftDo: [ :anEvent | activePaletteDragItem := nil ];
		whenDroppedDo: [ :anEvent | self dropPaletteEvent: anEvent ];
		yourself)
]

{ #category : 'private - testing' }
CPProcessDiagramElement >> acceptsPaletteDragItem: aDragItem [
	| sourceElement assessment |
	createNodeOperationBlock ifNil: [ ^ false ].
	sourceElement := aDragItem sourceElement.
	sourceElement ifNil: [ ^ false ].
	(sourceElement userData includesKey: #atelierPaletteSource) ifFalse: [ ^ false ].
	assessment := (createNodeOperationBlock value: aDragItem domainObject value: 0 @ 0) assess.
	assessment isApplicable ifTrue: [ activePaletteDragItem := aDragItem ].
	^ assessment isApplicable
]

{ #category : 'private - interaction' }
CPProcessDiagramElement >> dropPaletteEvent: anEvent [
	| dragItem candidate |
	anEvent domainObjects size = 1 ifFalse: [ activePaletteDragItem := nil. ^ self ].
	dragItem := activePaletteDragItem.
	activePaletteDragItem := nil.
	dragItem ifNil: [ ^ self ].
	candidate := dragItem domainObject.
	^ self createNode: candidate at: anEvent position
]


{ #category : 'configuration' }
CPProcessDiagramElement >> positionNodeOperationFor: aBlock [
	"The block receives node and proposed diagram position and answers the Process editing operation for that intention."
	positionNodeOperationBlock := aBlock
]

{ #category : 'operations' }
CPProcessDiagramElement >> positionNode: aNode at: aPoint [
	| assessment |
	positionNodeOperationBlock ifNil: [ ^ nil ].
	assessment := (positionNodeOperationBlock value: aNode value: aPoint) apply.
	self refresh.
	^ assessment
]

{ #category : 'private - positioning' }
CPProcessDiagramElement >> installPositioningOn: anElement for: aNode [
	| dragStartEventPosition dragStartNodePosition |
	anElement
		addEventHandler: (BlEventHandler
			on: BlDragStartEvent
			do: [ :anEvent |
				dragStartEventPosition := anEvent position.
				dragStartNodePosition := anElement position.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEvent
			do: [ :anEvent |
				| proposedPosition |
				proposedPosition := dragStartNodePosition + anEvent position - dragStartEventPosition.
				anElement relocate: proposedPosition.
				self refreshEdgeGeometry.
				anEvent consumed: true ]);
		addEventHandler: (BlEventHandler
			on: BlDragEndEvent
			do: [ :anEvent |
				anEvent consumed: true.
				self positionNode: aNode at: anElement position ])
]

{ #category : 'private - edges' }
CPProcessDiagramElement >> refreshEdgeGeometry [
	edgeElementsByEdge keysAndValuesDo: [ :edge :element |
		| geometry |
		geometry := self edgeGeometryFor: edge.
		geometry ifNotNil: [ element geometry: geometry ] ]
]

{ #category : 'private - edges' }
CPProcessDiagramElement >> edgeGeometryFor: anEdge [
	| source target sourcePosition targetPosition |
	source := self stagedSourceOf: anEdge.
	target := self stagedTargetOf: anEdge.
	(source isNil or: [ target isNil ]) ifTrue: [ ^ nil ].
	sourcePosition := self displayedPositionOf: source ifAbsent: [ ^ nil ].
	targetPosition := self displayedPositionOf: target ifAbsent: [ ^ nil ].
	sourcePosition := sourcePosition + ((self extentForNode: source) / 2).
	targetPosition := targetPosition + ((self extentForNode: target) / 2).
	^ BlLineGeometry from: sourcePosition to: targetPosition
]

{ #category : 'private - nodes' }
CPProcessDiagramElement >> displayedPositionOf: aNode ifAbsent: aBlock [
	(nodeElementsByNode at: aNode ifAbsent: [ nil ])
		ifNotNil: [ :anElement | ^ anElement position ].
	^ self stagedPositionOf: aNode ifAbsent: aBlock
]
