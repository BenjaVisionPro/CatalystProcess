"I configure Foundation Atelier with BPM-specific editing semantics that are already proven by BPM operations.

I do not choose a presentation and I do not inspect object classes to discover behavior. The client gives me the process relation descriptions explicitly. For the exact nodes relation I translate fresh insertion to CPAtelierCreateNode and removal to CPAtelierRemoveNode or CPAtelierRemoveNodes, preserving BPM semantics. I also provide the explicit BPM connection intention that creates CPAtelierConnectNodes from a fresh edge plus the two endpoint identities. Other relations retain Foundation Atelier's ordinary relation operations."
Class {
	#name : 'CPAtelierConfiguration',
	#superclass : 'CFAtelierConfiguration',
	#instVars : [
		'nodesDescription',
		'edgesDescription'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

{ #category : 'instance creation' }
CPAtelierConfiguration class >> nodesDescription: aNodesDescription edgesDescription: anEdgesDescription [
	^ self new
		nodesDescription: aNodesDescription;
		edgesDescription: anEdgesDescription;
		yourself
]

{ #category : 'applying' }
CPAtelierConfiguration >> applyEditingTo: anAtelierViewModel [
	super applyEditingTo: anAtelierViewModel.
	anAtelierViewModel
		insertOperationFor: [ :candidate :aMemento :aDescription :anIndex |
			self insertOperationFor: candidate into: aMemento description: aDescription at: anIndex ];
		removeOperationFor: [ :someObjects :aSourceContext |
			self removeOperationFor: someObjects from: aSourceContext ];
		replaceOperationFor: [ :candidate :currentObject :aMemento :aDescription |
			self replaceOperationFor: currentObject with: candidate in: aMemento description: aDescription ];
		presentationDo: [ :aPresentation |
			aPresentation
				createNodeOperationFor: [ :aNode :aPoint |
					self createNodeOperationFor: aNode at: aPoint in: aPresentation memento ];
				positionNodeOperationFor: [ :aNode :aPoint |
					self positionNodeOperationFor: aNode at: aPoint in: aPresentation memento ];
				connectNodeOperationFor: [ :aSourceNode :aTargetNode |
					self connectOperationFrom: aSourceNode to: aTargetNode in: aPresentation memento ];
				reconnectEdgeOperationFor: [ :anEdge :aSourceNode :aTargetNode |
					self reconnectOperationFor: anEdge from: aSourceNode to: aTargetNode in: aPresentation memento ];
				removeNodeOperationFor: [ :aNode |
					self removeNodeOperationFor: aNode in: aPresentation memento ];
				removeNodesOperationFor: [ :someNodes |
					self removeNodesOperationFor: someNodes in: aPresentation memento ];
				removeEdgeOperationFor: [ :anEdge |
					self removeEdgeOperationFor: anEdge in: aPresentation memento ] ].
	^ anAtelierViewModel
]




{ #category : 'operations' }
CPAtelierConfiguration >> createNodeOperationFor: aNode at: aPoint in: aProcessMemento [
	^ CPAtelierCreateNode
		node: aNode
		position: aPoint
		processMemento: aProcessMemento
		nodesDescription: nodesDescription
]

{ #category : 'operations' }
CPAtelierConfiguration >> connectOperationFor: anEdge from: aSourceNode to: aTargetNode in: aProcessMemento [
	^ CPAtelierConnectNodes
		edge: anEdge
		sourceNode: aSourceNode
		targetNode: aTargetNode
		processMemento: aProcessMemento
		nodesDescription: nodesDescription
		edgesDescription: edgesDescription
		sourceNodeDescription: anEdge sourceNodeDescription
		targetNodeDescription: anEdge targetNodeDescription
]

{ #category : 'operations' }
CPAtelierConfiguration >> insertOperationFor: aCandidate into: aMemento description: aDescription at: anIndex [
	aDescription == nodesDescription ifTrue: [
		anIndex ifNil: [
			^ self createNodeOperationFor: aCandidate at: nil in: aMemento ].
		^ CPAtelierCreateNode
			node: aCandidate
			position: nil
			processMemento: aMemento
			nodesDescription: nodesDescription
			at: anIndex ].
	aDescription == edgesDescription ifTrue: [
		^ self
			connectOperationFor: aCandidate
			from: aCandidate sourceNode
			to: aCandidate targetNode
			in: aMemento ].
	anIndex ifNil: [
		^ CFAtelierInsert
			object: aCandidate
			memento: aMemento
			description: aDescription ].
	^ CFAtelierInsert
		object: aCandidate
		memento: aMemento
		description: aDescription
		at: anIndex
]

{ #category : 'operations' }
CPAtelierConfiguration >> removeOperationFor: someObjects from: aSourceContext [
	aSourceContext description == nodesDescription ifTrue: [
		someObjects size = 1 ifTrue: [
			^ CPAtelierRemoveNode
				node: someObjects first
				processMemento: aSourceContext memento
				nodesDescription: nodesDescription
				edgesDescription: edgesDescription ].
		^ CPAtelierRemoveNodes
			nodes: someObjects
			processMemento: aSourceContext memento
			nodesDescription: nodesDescription
			edgesDescription: edgesDescription ].
	^ CFAtelierRemove
		objects: someObjects
		memento: aSourceContext memento
		description: aSourceContext description
]



{ #category : 'operations' }
CPAtelierConfiguration >> replaceOperationFor: anObject with: aCandidate in: aMemento description: aDescription [
	aDescription == nodesDescription ifTrue: [
		^ CPAtelierReplaceNode
			node: anObject
			with: aCandidate
			processMemento: aMemento
			nodesDescription: nodesDescription
			edgesDescription: edgesDescription ].
	aDescription == edgesDescription ifTrue: [
		^ CPAtelierReplaceEdge
			edge: anObject
			with: aCandidate
			processMemento: aMemento
			nodesDescription: nodesDescription
			edgesDescription: edgesDescription ].
	^ CFAtelierReplace object: anObject with: aCandidate memento: aMemento description: aDescription
]
{ #category : 'accessing' }
CPAtelierConfiguration >> nodesDescription [
	^ nodesDescription
]

{ #category : 'accessing' }
CPAtelierConfiguration >> nodesDescription: aDescription [
	nodesDescription := aDescription
]

{ #category : 'accessing' }
CPAtelierConfiguration >> edgesDescription [
	^ edgesDescription
]

{ #category : 'accessing' }
CPAtelierConfiguration >> edgesDescription: aDescription [
	edgesDescription := aDescription
]

{ #category : 'instance creation' }
CPAtelierConfiguration class >> forProcessMemento: aProcessMemento [
	| nodesDescription edgesDescription |
	nodesDescription := aProcessMemento magritteDescription
		detect: [ :each | each handlesSelector: #nodes ].
	edgesDescription := aProcessMemento magritteDescription
		detect: [ :each | each handlesSelector: #edges ].
	^ (self
		nodesDescription: nodesDescription
		edgesDescription: edgesDescription)
		palette: self processNodePalette;
		yourself
]

{ #category : 'instance creation' }
CPAtelierConfiguration class >> processNodePalette [
	| palette |
	palette := CFAtelierPalette new.
	palette
		add: (CFAtelierPaletteItem
			label: 'Start event'
			provider: (CFAtelierFactoryProvider factory: [ CPStartEventDesignNode new ]));
		add: (CFAtelierPaletteItem
			label: 'End event'
			provider: (CFAtelierFactoryProvider factory: [ CPEndEventDesignNode new ]));
		add: (CFAtelierPaletteItem
			label: 'User task'
			provider: (CFAtelierFactoryProvider factory: [ CPUserTaskDesignNode new ]));
		add: (CFAtelierPaletteItem
			label: 'Service task'
			provider: (CFAtelierFactoryProvider factory: [ CPServiceTaskDesignNode new ]));
		add: (CFAtelierPaletteItem
			label: 'Exclusive gateway'
			provider: (CFAtelierFactoryProvider factory: [ CPExclusiveGatewayDesignNode new ]));
		add: (CFAtelierPaletteItem
			label: 'Parallel gateway'
			provider: (CFAtelierFactoryProvider factory: [ CPParallelGatewayDesignNode new ])).
	^ palette
]

{ #category : 'operations' }
CPAtelierConfiguration >> positionNodeOperationFor: aNode at: aPoint in: aProcessMemento [
	^ CPAtelierPositionNode
		node: aNode
		position: aPoint
		processMemento: aProcessMemento
		nodesDescription: nodesDescription
]

{ #category : 'operations' }
CPAtelierConfiguration >> reconnectOperationFor: anEdge from: aSourceNode to: aTargetNode in: aProcessMemento [
	^ CPAtelierReconnectEdge
		edge: anEdge
		sourceNode: aSourceNode
		targetNode: aTargetNode
		processMemento: aProcessMemento
		nodesDescription: nodesDescription
		edgesDescription: edgesDescription
]


{ #category : 'operations' }
CPAtelierConfiguration >> connectOperationFrom: aSourceNode to: aTargetNode in: aProcessMemento [
	"The Process client owns fresh edge materialization for a diagram connection gesture. The operation itself still receives an already-supplied edge."
	^ self
		connectOperationFor: CPProcessDesignEdge new
		from: aSourceNode
		to: aTargetNode
		in: aProcessMemento
]


{ #category : 'operations' }
CPAtelierConfiguration >> removeNodeOperationFor: aNode in: aProcessMemento [
	^ self
		removeOperationFor: { aNode }
		from: (CFAtelierRelationDragContext
			memento: aProcessMemento
			description: nodesDescription)
]



{ #category : 'operations' }
CPAtelierConfiguration >> removeNodesOperationFor: someNodes in: aProcessMemento [
	^ self
		removeOperationFor: someNodes
		from: (CFAtelierRelationDragContext
			memento: aProcessMemento
			description: nodesDescription)
]
{ #category : 'operations' }
CPAtelierConfiguration >> removeEdgeOperationFor: anEdge in: aProcessMemento [
	^ self
		removeOperationFor: { anEdge }
		from: (CFAtelierRelationDragContext
			memento: aProcessMemento
			description: edgesDescription)
]
