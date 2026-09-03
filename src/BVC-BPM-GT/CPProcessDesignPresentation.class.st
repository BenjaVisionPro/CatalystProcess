"I am the Foundation Magritte presentation used for CPProcessDesign.

I remain a CFMaDetailPresentation and therefore retain the normal Foundation Detail form. For Process I compose that unchanged Detail content beside the diagram so the diagram is the primary work surface and Detail is an inspector region. Atelier still does not choose or render Process UI."
Class {
	#name : 'CPProcessDesignPresentation',
	#superclass : 'CFMaDetailPresentation',
	#instVars : [
		'positionNodeOperationBlock',
		'createNodeOperationBlock',
		'connectNodeOperationBlock',
		'reconnectEdgeOperationBlock',
		'removeNodeOperationBlock',
		'removeNodesOperationBlock',
		'removeEdgeOperationBlock',
		'diagramElement',
		'detailHostElement',
		'workspaceElement'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'private - building' }
CPProcessDesignPresentation >> prepareHostElement [
	| detailScroll |
	super prepareHostElement.

	diagramElement := CPProcessDiagramElement new
		createNodeOperationFor: createNodeOperationBlock;
		positionNodeOperationFor: positionNodeOperationBlock;
		connectNodeOperationFor: connectNodeOperationBlock;
		reconnectEdgeOperationFor: reconnectEdgeOperationBlock;
		removeNodeOperationFor: removeNodeOperationBlock;
		removeNodesOperationFor: removeNodesOperationBlock;
		removeEdgeOperationFor: removeEdgeOperationBlock;
		memento: self memento.
	diagramElement constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent ].

	detailHostElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 0;
		padding: BlInsets empty;
		background: Color transparent;
		yourself.
	detailScroll := BrScrollPane new
		allowMeAndChildrenMouseEvents;
		aptitude: BrScrollPaneAptitude + BrGlamorousWithVerticalScrollbarAptitude;
		hExact: 360;
		vMatchParent;
		content: detailHostElement;
		yourself.

	workspaceElement := BrHorizontalPane new
		hMatchParent;
		vExact: 620;
		cellSpacing: 12;
		addChild: diagramElement;
		addChild: detailScroll;
		yourself.
	self hostElement addChild: workspaceElement
]

{ #category : 'private - groups' }
CPProcessDesignPresentation >> groupFor: aGroup configuredBy: aConfiguration [
	^ groups
		at: aGroup
		ifAbsentPut: [
			self
				newGroup: aGroup
				in: detailHostElement
				configuredBy: aConfiguration ]
]

{ #category : 'accessing - testing' }
CPProcessDesignPresentation >> diagramElement [
	^ diagramElement
]

{ #category : 'accessing - testing' }
CPProcessDesignPresentation >> detailHostElement [
	^ detailHostElement
]

{ #category : 'accessing - testing' }
CPProcessDesignPresentation >> workspaceElement [
	^ workspaceElement
]


{ #category : 'configuration' }
CPProcessDesignPresentation >> positionNodeOperationFor: aBlock [
	positionNodeOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessDesignPresentation >> createNodeOperationFor: aBlock [
	createNodeOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessDesignPresentation >> connectNodeOperationFor: aBlock [
	connectNodeOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessDesignPresentation >> reconnectEdgeOperationFor: aBlock [
	reconnectEdgeOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessDesignPresentation >> removeNodeOperationFor: aBlock [
	removeNodeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessDesignPresentation >> removeEdgeOperationFor: aBlock [
	removeEdgeOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessDesignPresentation >> removeNodesOperationFor: aBlock [
	removeNodesOperationBlock := aBlock
]
