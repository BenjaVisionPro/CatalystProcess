"I render the current staged topology of a CPProcessDesign memento as a simple diagram surface.

I am a Process presentation element, not an Atelier operation surface. I read staged relation and embedded values when they already exist, without creating child mementos merely to display the diagram."
Class {
	#name : 'CPProcessDiagramElement',
	#superclass : 'BlElement',
	#instVars : [
		'memento',
		'nodesDescription',
		'edgesDescription',
		'nodeElementsByNode'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessDiagramElement >> initialize [
	super initialize.
	nodeElementsByNode := IdentityDictionary new.
	self
		hMatchParent;
		vExact: 420;
		layout: BlFrameLayout new;
		clipChildren: false;
		padding: (BlInsets all: 20);
		geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
		background: (Color white alpha: 0.04);
		border: (BlBorder paint: (Color gray alpha: 0.20) width: 1)
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
	self addChild: line
]
