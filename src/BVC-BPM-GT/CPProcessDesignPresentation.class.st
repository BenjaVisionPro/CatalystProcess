"I am the Foundation Magritte presentation used for CPProcessDesign.

For Process I compose a two-part Atelier work surface: the diagram fills the available primary area and a resizable GT Tree Pager forms the detail strip on the right. The pager's root pane hosts the ordinary Foundation Detail content built against this presentation's existing memento, so editing remains in the same transaction while relation navigation continues through standard Phlow/Tree Pager behaviour.

The Atelier palette is not one of these layout regions; CFAtelierElement floats it over the primary surface."
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
		'detailPagerElement',
		'detailPagerModel',
		'canvasScrollElement',
		'workspaceElement'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'private - building' }
CPProcessDesignPresentation >> prepareHostElement [
	| detailScroll rootPaneModel resizer surfaceColor |
	super prepareHostElement.
	surfaceColor := self workspaceSurfaceColor.

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
		c horizontal exact: 2200.
		c vertical exact: 1400 ].

	canvasScrollElement := BrScrollPane new
		background: surfaceColor;
		allowMeAndChildrenMouseEvents;
		aptitude: BrScrollPaneAptitude
			+ BrGlamorousWithHorizontalScrollbarAptitude
			+ BrGlamorousWithVerticalScrollbarAptitude;
		hMatchParent;
		vMatchParent;
		content: diagramElement;
		yourself.

	detailHostElement := BrVerticalPane new
		hMatchParent;
		vFitContent;
		cellSpacing: 0;
		padding: BlInsets empty;
		background: surfaceColor;
		yourself.
	detailScroll := BrScrollPane new
		background: surfaceColor;
		allowMeAndChildrenMouseEvents;
		aptitude: BrScrollPaneAptitude + BrGlamorousWithVerticalScrollbarAptitude;
		hMatchParent;
		vMatchParent;
		content: detailHostElement;
		yourself.

	rootPaneModel := GtTreePagerPaneModel new
		stencil: [ detailScroll ];
		yourself.
	detailPagerModel := GtTreePagerModel new
		paneModel: rootPaneModel;
		yourself.
	detailPagerModel settings numberOfVisibleColumns: 1.
	detailPagerElement := GtTreePager new
		background: surfaceColor;
		pagerModel: detailPagerModel;
		hExact: 380;
		vMatchParent;
		yourself.

	resizer := BrResizer new
		aptitude: BrGlamorousThinBarResizerAptitude;
		beLeft;
		target: detailPagerElement;
		constraintsDo: [ :c | c ignoreByLayout ];
		yourself.
	detailPagerElement addChild: resizer.

	workspaceElement := BrHorizontalPane new
		background: surfaceColor;
		hMatchParent;
		vMatchParent;
		cellSpacing: 0;
		addChild: canvasScrollElement;
		addChild: detailPagerElement;
		yourself.
	self hostElement
		background: surfaceColor;
		hMatchParent;
		vMatchParent;
		addChild: workspaceElement
]


{ #category : 'private - theme' }
CPProcessDesignPresentation >> resolvedThemeColor: aThemeableColor [
	^ aThemeableColor blocResolveColorForTheme: self hostElement theme
]

{ #category : 'private - theme' }
CPProcessDesignPresentation >> workspaceSurfaceColor [
	^ self resolvedThemeColor: self hostElement theme surfaces baseBackground
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
CPProcessDesignPresentation >> canvasScrollElement [
	^ canvasScrollElement
]

{ #category : 'accessing - testing' }
CPProcessDesignPresentation >> detailHostElement [
	^ detailHostElement
]

{ #category : 'accessing - testing' }
CPProcessDesignPresentation >> detailPagerElement [
	^ detailPagerElement
]

{ #category : 'accessing - testing' }
CPProcessDesignPresentation >> detailPagerModel [
	^ detailPagerModel
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
