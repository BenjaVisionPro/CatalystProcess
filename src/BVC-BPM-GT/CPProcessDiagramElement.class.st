"I render and manipulate the current staged topology of a CPProcessDesign memento.

I belong to the Process presentation layer. I own diagram geometry, selection and gestures, but semantic mutations are delegated through configured Process/Atelier operations. I read staged relation and embedded values when they already exist, without creating child mementos merely to display the diagram."
Class {
	#name : 'CPProcessDiagramElement',
	#superclass : 'BlElement',
	#instVars : [
		'memento',
		'nodesDescription',
		'edgesDescription',
		'nodeElementsByNode',
		'edgeElementsByEdge',
		'reconnectHandleElementsByEdge',
		'positionNodeOperationBlock',
		'createNodeOperationBlock',
		'activePaletteDragItem',
		'connectNodeOperationBlock',
		'connectionSourceNode',
		'reconnectEdgeOperationBlock',
		'reconnectionEdge',
		'reconnectsSource',
		'removeNodeOperationBlock',
		'removeNodesOperationBlock',
		'removeEdgeOperationBlock',
		'selectedNodes',
		'selectedEdge'
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
	reconnectHandleElementsByEdge := IdentityDictionary new.
	selectedNodes := OrderedCollection new.
	self
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical exact: 420 ];
		layout: BlFrameLayout new;
		clipChildren: false;
		padding: (BlInsets all: 20);
		beFocusable.
	self applyTheme.
	self
		installPaletteDrop;
		installKeyboardHandler
]

{ #category : 'private - theme' }
CPProcessDiagramElement >> resolvedThemeColor: aThemeableColor [
	^ aThemeableColor blocResolveColorForTheme: self theme
]

{ #category : 'private - theme' }
CPProcessDiagramElement >> surfaceBackgroundColor [
	^ self resolvedThemeColor: self theme surfaces baseBackground
]

{ #category : 'private - theme' }
CPProcessDiagramElement >> nodeBackgroundColor [
	^ self resolvedThemeColor: self theme surfaces cardTint
]

{ #category : 'private - theme' }
CPProcessDiagramElement >> nodeBorderColor [
	^ self resolvedThemeColor: self theme surfaces separatorTint
]

{ #category : 'private - theme' }
CPProcessDiagramElement >> edgeColor [
	^ self resolvedThemeColor: self theme typography quaternaryForeground
]

{ #category : 'private - theme' }
CPProcessDiagramElement >> selectedBorderColor [
	^ self resolvedThemeColor: self theme interaction focusedBorderColor
]

{ #category : 'private - theme' }
CPProcessDiagramElement >> controlBackgroundColor [
	^ self resolvedThemeColor: self theme interaction controlBackgroundTint
]

{ #category : 'private - theme' }
CPProcessDiagramElement >> labelForegroundColor [
	^ self resolvedThemeColor: self theme typography primaryForeground
]

{ #category : 'private - theme' }
CPProcessDiagramElement >> applyTheme [
	self
		geometry: (BlRoundedRectangleGeometry cornerRadius: 12);
		background: self surfaceBackgroundColor;
		border: (BlBorder paint: self nodeBorderColor width: 1).
	nodeElementsByNode ifNotNil: [
		nodeElementsByNode valuesDo: [ :each |
			each background: self nodeBackgroundColor ].
		edgeElementsByEdge valuesDo: [ :each |
			each border: (BlBorder paint: self edgeColor width: 1.5) ].
		reconnectHandleElementsByEdge valuesDo: [ :handles |
			handles do: [ :each |
				each
					background: self controlBackgroundColor;
					border: (BlBorder paint: self nodeBorderColor width: 1) ] ].
		self updateSelectionAppearance ]
]

{ #category : 'api - theme' }
CPProcessDiagramElement >> onThemeChanged [
	super onThemeChanged.
	self applyTheme
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
	nodes := memento readUsing: nodesDescription.
	edges := memento readUsing: edgesDescription.
	selectedNodes := selectedNodes select: [ :node | nodes identityIncludes: node ].
	(selectedEdge isNotNil and: [ (edges identityIncludes: selectedEdge) not ]) ifTrue: [ selectedEdge := nil ].
	self
		removeNodeElementsAbsentFrom: nodes;
		removeEdgeElementsAbsentFrom: edges.
	nodes withIndexDo: [ :node :index |
		(nodeElementsByNode includesKey: node)
			ifTrue: [ self updateNodeElementFor: node index: index ]
			ifFalse: [ self addNodeElementFor: node index: index ] ].
	edges do: [ :edge |
		(edgeElementsByEdge includesKey: edge)
			ifTrue: [ self updateEdgeElementFor: edge ]
			ifFalse: [ self addEdgeElementFor: edge ] ].
	self updateSelectionAppearance.
	^ self
]

{ #category : 'private - updating' }
CPProcessDiagramElement >> refreshWithMotion [
	| participants |
	self isAttachedToSceneGraph ifFalse: [ ^ self refresh ].
	participants := OrderedCollection new.
	participants addAll: nodeElementsByNode values.
	participants addAll: edgeElementsByEdge values.
	reconnectHandleElementsByEdge valuesDo: [ :handles | participants addAll: handles ].
	participants isEmpty ifTrue: [ ^ self refresh ].
	^ (CFMotionLayoutTransaction on: self)
		affecting: participants;
		duration: 180 milliSeconds;
		mutate: [ self refresh ];
		play
]

{ #category : 'private - updating' }
CPProcessDiagramElement >> removeNodeElementsAbsentFrom: nodes [
	(nodeElementsByNode keys reject: [ :node | nodes identityIncludes: node ]) do: [ :node |
		| element |
		element := nodeElementsByNode removeKey: node.
		element parent ifNotNil: [ :parent | parent removeChild: element ] ]
]

{ #category : 'private - updating' }
CPProcessDiagramElement >> removeEdgeElementsAbsentFrom: edges [
	(edgeElementsByEdge keys reject: [ :edge | edges identityIncludes: edge ]) do: [ :edge |
		| element handles |
		element := edgeElementsByEdge removeKey: edge.
		element parent ifNotNil: [ :parent | parent removeChild: element ].
		handles := reconnectHandleElementsByEdge removeKey: edge ifAbsent: [ #() ].
		handles do: [ :handle |
			handle parent ifNotNil: [ :parent | parent removeChild: handle ] ] ]
]

{ #category : 'private - nodes' }
CPProcessDiagramElement >> updateNodeElementFor: aNode index: anIndex [
	| element position |
	element := nodeElementsByNode at: aNode.
	position := self stagedPositionOf: aNode ifAbsent: [ self fallbackPositionForIndex: anIndex ].
	element relocate: position
]

{ #category : 'private - edges' }
CPProcessDiagramElement >> updateEdgeElementFor: anEdge [
	| geometry source target |
	geometry := self edgeGeometryFor: anEdge.
	geometry ifNotNil: [ (edgeElementsByEdge at: anEdge) geometry: geometry ].
	reconnectEdgeOperationBlock ifNil: [ ^ self ].
	source := self stagedSourceOf: anEdge.
	target := self stagedTargetOf: anEdge.
	(source isNil or: [ target isNil ]) ifTrue: [ ^ self ].
	self updateReconnectHandlesFor: anEdge source: source target: target
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
	self installSelectionOn: element forNode: aNode.
	positionNodeOperationBlock ifNotNil: [ self installPositioningOn: element for: aNode ].
	(connectNodeOperationBlock isNotNil or: [ reconnectEdgeOperationBlock isNotNil ]) ifTrue: [
		self installConnectionOn: element for: aNode ].
	self addChild: element
]

{ #category : 'private - nodes' }
CPProcessDiagramElement >> newNodeElementFor: aNode [
	| element label |
	element := BlElement new
		extent: (self extentForNode: aNode);
		geometry: (self geometryForNode: aNode);
		background: self nodeBackgroundColor;
		border: (BlBorder paint: self nodeBorderColor width: 1.5);
		layout: BlFrameLayout new;
		yourself.
	label := BrLabel new
		fitContent;
		text: (aNode label ifNil: [ aNode class name ]) asRopedText;
		aptitude: (BrGlamorousLabelAptitude new
			fontSize: self theme typography bodyFontSize);
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
		border: (BlBorder paint: self edgeColor width: 1.5);
		yourself.
	edgeElementsByEdge at: anEdge put: line.
	self installSelectionOn: line forEdge: anEdge.
	self addChildFirst: line.
	reconnectEdgeOperationBlock ifNotNil: [
		self addReconnectHandlesFor: anEdge source: source target: target ]
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
	assessment isApplicable
		ifTrue: [ self refreshWithMotion ]
		ifFalse: [ self refresh ].
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
		| geometry source target |
		geometry := self edgeGeometryFor: edge.
		geometry ifNotNil: [ element geometry: geometry ].
		(reconnectEdgeOperationBlock isNotNil and: [ reconnectHandleElementsByEdge includesKey: edge ]) ifTrue: [
			source := self stagedSourceOf: edge.
			target := self stagedTargetOf: edge.
			(source isNotNil and: [ target isNotNil ]) ifTrue: [
				self updateReconnectHandlesFor: edge source: source target: target ] ] ]
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


{ #category : 'configuration' }
CPProcessDiagramElement >> connectNodeOperationFor: aBlock [
	"The block receives source node and target node and answers the Process editing operation for that connection intention."
	connectNodeOperationBlock := aBlock
]

{ #category : 'operations' }
CPProcessDiagramElement >> connectNode: aSourceNode to: aTargetNode [
	| assessment |
	connectNodeOperationBlock ifNil: [ ^ nil ].
	assessment := (connectNodeOperationBlock value: aSourceNode value: aTargetNode) apply.
	connectionSourceNode := nil.
	"Refresh for both acceptance and rejection. Connection arming changes presentation state, so a rejected semantic operation must still restore appearance from authoritative staged state."
	self refresh.
	^ assessment
]

{ #category : 'private - connection' }
CPProcessDiagramElement >> installConnectionOn: aNodeElement for: aNode [
	| port |
	port := BlElement new
		extent: 12 @ 12;
		geometry: BlCircleGeometry new;
		background: self controlBackgroundColor;
		border: (BlBorder paint: self nodeBorderColor width: 1.5);
		constraintsDo: [ :c |
			c frame horizontal alignRight.
			c frame vertical alignCenter ];
		yourself.
	port addEventHandler: (BlEventHandler
		on: BlClickEvent
		do: [ :anEvent |
			self beginConnectionFrom: aNode.
			anEvent consumed: true ]).
	aNodeElement addChild: port.
	aNodeElement addEventHandler: (BlEventHandler
		on: BlClickEvent
		do: [ :anEvent |
			reconnectionEdge ifNotNil: [
				self completeReconnectionTo: aNode.
				anEvent consumed: true ]
			ifNil: [
				connectionSourceNode ifNotNil: [
					self completeConnectionTo: aNode.
					anEvent consumed: true ] ] ])
]

{ #category : 'private - connection' }
CPProcessDiagramElement >> beginConnectionFrom: aNode [
	"Connection and reconnection are mutually exclusive transient gestures."
	reconnectionEdge := nil.
	reconnectsSource := nil.
	connectionSourceNode := aNode.
	(nodeElementsByNode at: aNode ifAbsent: [ nil ])
		ifNotNil: [ :anElement |
			anElement border: (BlBorder paint: self selectedBorderColor width: 2.5) ]
]

{ #category : 'private - connection' }
CPProcessDiagramElement >> completeConnectionTo: aNode [
	| source |
	source := connectionSourceNode.
	connectionSourceNode := nil.
	source ifNil: [ ^ self ].
	source == aNode ifTrue: [ self refresh. ^ self ].
	self connectNode: source to: aNode
]


{ #category : 'configuration' }
CPProcessDiagramElement >> reconnectEdgeOperationFor: aBlock [
	"The block receives an existing edge plus proposed source and target nodes and answers the Process editing operation for that reconnection intention."
	reconnectEdgeOperationBlock := aBlock
]

{ #category : 'operations' }
CPProcessDiagramElement >> reconnectEdge: anEdge from: aSourceNode to: aTargetNode [
	| assessment |
	reconnectEdgeOperationBlock ifNil: [ ^ nil ].
	assessment := (reconnectEdgeOperationBlock value: anEdge value: aSourceNode value: aTargetNode) apply.
	reconnectionEdge := nil.
	reconnectsSource := nil.
	assessment isApplicable
		ifTrue: [ self refreshWithMotion ]
		ifFalse: [ self refresh ].
	^ assessment
]

{ #category : 'private - reconnection' }
CPProcessDiagramElement >> addReconnectHandlesFor: anEdge source: aSourceNode target: aTargetNode [
	| sourceHandle targetHandle |
	sourceHandle := self newReconnectHandle.
	targetHandle := self newReconnectHandle.
	sourceHandle addEventHandler: (BlEventHandler
		on: BlClickEvent
		do: [ :anEvent |
			self beginReconnectSourceOf: anEdge.
			anEvent consumed: true ]).
	targetHandle addEventHandler: (BlEventHandler
		on: BlClickEvent
		do: [ :anEvent |
			self beginReconnectTargetOf: anEdge.
			anEvent consumed: true ]).
	reconnectHandleElementsByEdge at: anEdge put: { sourceHandle. targetHandle }.
	self addChild: sourceHandle.
	self addChild: targetHandle.
	self updateReconnectHandlesFor: anEdge source: aSourceNode target: aTargetNode
]

{ #category : 'private - reconnection' }
CPProcessDiagramElement >> updateReconnectHandlesFor: anEdge source: aSourceNode target: aTargetNode [
	| handles sourcePosition targetPosition |
	handles := reconnectHandleElementsByEdge at: anEdge ifAbsent: [ ^ self ].
	sourcePosition := (self displayedPositionOf: aSourceNode ifAbsent: [ ^ self ])
		+ ((self extentForNode: aSourceNode) / 2).
	targetPosition := (self displayedPositionOf: aTargetNode ifAbsent: [ ^ self ])
		+ ((self extentForNode: aTargetNode) / 2).
	handles first relocate: sourcePosition - (5 @ 5).
	handles second relocate: targetPosition - (5 @ 5)
]

{ #category : 'private - reconnection' }
CPProcessDiagramElement >> newReconnectHandle [
	^ BlElement new
		extent: 10 @ 10;
		constraintsDo: [ :c | c ignoreByLayout ];
		geometry: BlCircleGeometry new;
		background: self controlBackgroundColor;
		border: (BlBorder paint: self nodeBorderColor width: 1);
		yourself
]

{ #category : 'private - reconnection' }
CPProcessDiagramElement >> beginReconnectSourceOf: anEdge [
	reconnectionEdge := anEdge.
	reconnectsSource := true.
	connectionSourceNode := nil
]

{ #category : 'private - reconnection' }
CPProcessDiagramElement >> beginReconnectTargetOf: anEdge [
	reconnectionEdge := anEdge.
	reconnectsSource := false.
	connectionSourceNode := nil
]

{ #category : 'private - reconnection' }
CPProcessDiagramElement >> completeReconnectionTo: aNode [
	| edge source target |
	edge := reconnectionEdge.
	edge ifNil: [ ^ self ].
	source := self stagedSourceOf: edge.
	target := self stagedTargetOf: edge.
	reconnectsSource
		ifTrue: [ source := aNode ]
		ifFalse: [ target := aNode ].
	self reconnectEdge: edge from: source to: target
]


{ #category : 'configuration' }
CPProcessDiagramElement >> removeNodeOperationFor: aBlock [
	"The block receives the selected node and answers the Process editing operation for removing that node."
	removeNodeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessDiagramElement >> removeNodesOperationFor: aBlock [
	"The block receives the selected node identities in selection order and answers the Process editing operation for removing them as one semantic intention."
	removeNodesOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessDiagramElement >> removeEdgeOperationFor: aBlock [
	"The block receives the selected edge and answers the Process editing operation for removing that edge."
	removeEdgeOperationBlock := aBlock
]

{ #category : 'operations' }
CPProcessDiagramElement >> removeNode: aNode [
	| assessment |
	removeNodeOperationBlock ifNil: [ ^ nil ].
	assessment := (removeNodeOperationBlock value: aNode) apply.
	assessment isApplicable ifTrue: [
		selectedNodes := OrderedCollection new.
		self refresh ].
	^ assessment
]

{ #category : 'operations' }
CPProcessDiagramElement >> removeNodes: someNodes [
	| assessment |
	removeNodesOperationBlock ifNil: [ ^ nil ].
	assessment := (removeNodesOperationBlock value: someNodes) apply.
	assessment isApplicable ifTrue: [
		selectedNodes := OrderedCollection new.
		self refresh ].
	^ assessment
]

{ #category : 'operations' }
CPProcessDiagramElement >> removeEdge: anEdge [
	| assessment |
	removeEdgeOperationBlock ifNil: [ ^ nil ].
	assessment := (removeEdgeOperationBlock value: anEdge) apply.
	assessment isApplicable ifTrue: [
		selectedEdge := nil.
		self refresh ].
	^ assessment
]

{ #category : 'private - selection' }
CPProcessDiagramElement >> installSelectionOn: anElement forNode: aNode [
	anElement addEventHandler: (BlEventHandler
		on: BlClickEvent
		do: [ :anEvent |
			(connectionSourceNode isNil and: [ reconnectionEdge isNil ]) ifTrue: [
				self
					selectNode: aNode
					adding: (anEvent modifiers isPrimaryModifier or: [ anEvent modifiers isShift ]).
				anEvent consumed: true ] ])
]

{ #category : 'private - selection' }
CPProcessDiagramElement >> installSelectionOn: anElement forEdge: anEdge [
	anElement addEventHandler: (BlEventHandler
		on: BlClickEvent
		do: [ :anEvent |
			self selectEdge: anEdge.
			anEvent consumed: true ])
]

{ #category : 'private - selection' }
CPProcessDiagramElement >> selectNode: aNode adding: shouldAdd [
	selectedEdge := nil.
	shouldAdd
		ifTrue: [
			(selectedNodes identityIncludes: aNode)
				ifTrue: [ selectedNodes := selectedNodes reject: [ :each | each == aNode ] ]
				ifFalse: [ selectedNodes add: aNode ] ]
		ifFalse: [
			selectedNodes := OrderedCollection with: aNode ].
	self
		updateSelectionAppearance;
		requestFocus
]

{ #category : 'private - selection' }
CPProcessDiagramElement >> selectNode: aNode [
	self selectNode: aNode adding: false
]

{ #category : 'private - selection' }
CPProcessDiagramElement >> selectEdge: anEdge [
	selectedEdge := anEdge.
	selectedNodes := OrderedCollection new.
	self
		updateSelectionAppearance;
		requestFocus
]

{ #category : 'private - selection' }
CPProcessDiagramElement >> updateSelectionAppearance [
	nodeElementsByNode keysAndValuesDo: [ :node :element |
		| isSelected |
		isSelected := selectedNodes identityIncludes: node.
		element border: (BlBorder
			paint: (isSelected ifTrue: [ self selectedBorderColor ] ifFalse: [ self nodeBorderColor ])
			width: (isSelected ifTrue: [ 2.5 ] ifFalse: [ 1.5 ])) ].
	edgeElementsByEdge keysAndValuesDo: [ :edge :element |
		element border: (BlBorder
			paint: (edge == selectedEdge ifTrue: [ self selectedBorderColor ] ifFalse: [ self edgeColor ])
			width: (edge == selectedEdge ifTrue: [ 2.5 ] ifFalse: [ 1.5 ])) ]
]

{ #category : 'private - installing' }
CPProcessDiagramElement >> installKeyboardHandler [
	self addEventHandler: (BlEventHandler
		on: BlKeyDownEvent
		do: [ :anEvent |
			(anEvent key = BlKeyboardKey delete or: [ anEvent key = BlKeyboardKey backspace ]) ifTrue: [
				self removeSelection.
				anEvent consumed: true ].
			anEvent key = BlKeyboardKey escape ifTrue: [
				self cancelInteraction.
				anEvent consumed: true ] ])
]

{ #category : 'private - interaction' }
CPProcessDiagramElement >> hasPendingInteraction [
	^ activePaletteDragItem isNotNil
		or: [ connectionSourceNode isNotNil
		or: [ reconnectionEdge isNotNil ] ]
]

{ #category : 'private - interaction' }
CPProcessDiagramElement >> cancelPendingInteraction [
	activePaletteDragItem := nil.
	connectionSourceNode := nil.
	reconnectionEdge := nil.
	reconnectsSource := nil.
	self refresh
]

{ #category : 'private - interaction' }
CPProcessDiagramElement >> cancelInteraction [
	"Escape first cancels an armed/drag interaction without discarding selection.
	When no transient interaction is active, Escape clears the diagram selection."
	self hasPendingInteraction ifTrue: [ ^ self cancelPendingInteraction ].
	selectedNodes := OrderedCollection new.
	selectedEdge := nil.
	self updateSelectionAppearance
]

{ #category : 'private - selection' }
CPProcessDiagramElement >> removeSelection [
	selectedNodes ifNotEmpty: [
		selectedNodes size = 1 ifTrue: [ ^ self removeNode: selectedNodes first ].
		^ self removeNodes: selectedNodes asArray ].
	selectedEdge ifNotNil: [ :edge | ^ self removeEdge: edge ].
	^ nil
]


{ #category : 'private - accessing' }
CPProcessDiagramElement >> nodeElementFor: aNode [
	^ nodeElementsByNode at: aNode ifAbsent: [ nil ]
]

{ #category : 'private - accessing' }
CPProcessDiagramElement >> edgeElementFor: anEdge [
	^ edgeElementsByEdge at: anEdge ifAbsent: [ nil ]
]
