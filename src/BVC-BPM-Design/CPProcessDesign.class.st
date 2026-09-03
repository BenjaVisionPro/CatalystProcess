Class {
	#name : 'CPProcessDesign',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'comment',
		'scope',
		'owner',
		'tenant',
		'licensingPolicy',
		'tailoringPolicy',
		'sourceDesign',
		'nodes',
		'edges',
		'diagram',
		'createdAt',
		'updatedAt'
	],
	#category : 'BVC-BPM-Design',
	#package : 'BVC-BPM-Design'
}

{ #category : 'accessing' }
CPProcessDesign >> comment [
	^ comment
]

{ #category : 'accessing' }
CPProcessDesign >> comment: anObject [
	comment := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> scope [
	^ scope
]

{ #category : 'accessing' }
CPProcessDesign >> scope: anObject [
	scope := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> owner [
	^ owner
]

{ #category : 'accessing' }
CPProcessDesign >> owner: anObject [
	owner := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> tenant [
	^ tenant
]

{ #category : 'accessing' }
CPProcessDesign >> tenant: anObject [
	tenant := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> licensingPolicy [
	^ licensingPolicy
]

{ #category : 'accessing' }
CPProcessDesign >> licensingPolicy: anObject [
	licensingPolicy := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> tailoringPolicy [
	^ tailoringPolicy
]

{ #category : 'accessing' }
CPProcessDesign >> tailoringPolicy: anObject [
	tailoringPolicy := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> sourceDesign [
	^ sourceDesign
]

{ #category : 'accessing' }
CPProcessDesign >> sourceDesign: anObject [
	sourceDesign := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> nodes [
	^ nodes
]

{ #category : 'accessing' }
CPProcessDesign >> nodes: anObject [
	nodes := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> edges [
	^ edges
]

{ #category : 'accessing' }
CPProcessDesign >> edges: anObject [
	edges := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> diagram [
	^ diagram
]

{ #category : 'accessing' }
CPProcessDesign >> diagram: anObject [
	diagram := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> createdAt [
	^ createdAt
]

{ #category : 'accessing' }
CPProcessDesign >> createdAt: anObject [
	createdAt := anObject
]

{ #category : 'accessing' }
CPProcessDesign >> updatedAt [
	^ updatedAt
]

{ #category : 'accessing' }
CPProcessDesign >> updatedAt: anObject [
	updatedAt := anObject
]

{ #category : 'initialization' }
CPProcessDesign >> initialize [
	super initialize.
	nodes := OrderedCollection new.
	edges := OrderedCollection new.
	createdAt := DateAndTime now.
	updatedAt := createdAt
]

{ #category : 'adding' }
CPProcessDesign >> addNode: aNode [
	nodes add: aNode.
	updatedAt := DateAndTime now.
	^ aNode
]

{ #category : 'adding' }
CPProcessDesign >> removeNode: aNode [
	nodes remove: aNode ifAbsent: [ ].
	(edges select: [ :each | each sourceNode == aNode or: [ each targetNode == aNode ] ])
		do: [ :each | edges remove: each ifAbsent: [ ] ].
	updatedAt := DateAndTime now.
	^ aNode
]

{ #category : 'adding' }
CPProcessDesign >> addEdge: anEdge [
	edges add: anEdge.
	updatedAt := DateAndTime now.
	^ anEdge
]

{ #category : 'adding' }
CPProcessDesign >> removeEdge: anEdge [
	edges remove: anEdge ifAbsent: [ ].
	updatedAt := DateAndTime now.
	^ anEdge
]

{ #category : 'accessing' }
CPProcessDesign >> startNodes [
	^ nodes select: [ :each | each isStartNode ]
]

{ #category : 'accessing' }
CPProcessDesign >> endNodes [
	^ nodes select: [ :each | each isEndNode ]
]

{ #category : 'accessing' }
CPProcessDesign >> nodeAtIdentifier: anIdentifier [
	^ nodes detect: [ :each | each identifier = anIdentifier ] ifNone: [ nil ]
]

{ #category : 'validation' }
CPProcessDesign >> validate [
	^ CPProcessDesignValidator new validateDesign: self
]

{ #category : 'compiling' }
CPProcessDesign >> compile [
	^ CPProcessCompiler new compileDesign: self
]

{ #category : 'descriptions' }
CPProcessDesign >> commentDescription [
	<magritteDescription>
	^ MAMemoDescription new
		accessor: #comment;
		label: 'Comment';
		priority: 100;
		group: 'General';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesign >> scopeDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #scope;
		label: 'Scope';
		priority: 110;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesign >> ownerDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #owner;
		label: 'Owner';
		priority: 120;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesign >> tenantDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #tenant;
		label: 'Tenant';
		priority: 130;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesign >> licensingPolicyDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #licensingPolicy;
		label: 'Licensing policy';
		priority: 140;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesign >> tailoringPolicyDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #tailoringPolicy;
		label: 'Tailoring policy';
		priority: 150;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesign >> sourceDesignDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #sourceDesign;
		label: 'Source design';
		priority: 160;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesign >> nodesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #nodes;
		classes: { CPProcessDesignNode };
		reference: self labelDescription;
		label: 'Nodes';
		priority: 170;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesign >> edgesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #edges;
		classes: { CPProcessDesignEdge };
		reference: self labelDescription;
		label: 'Edges';
		priority: 180;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPProcessDesign >> diagramDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #diagram;
		label: 'Diagram';
		priority: 190;
		group: 'Relations';
		yourself
]

