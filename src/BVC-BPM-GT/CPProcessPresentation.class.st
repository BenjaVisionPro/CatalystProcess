"I am the visual Magritte presentation for a CPProcess.

I compose the Process diagram with Foundation Detail for the currently selected semantic object. Both presentations edit the same CFMaMemento transaction: the diagram uses the root Process memento and Detail uses that root memento or the appropriate embedded child memento."
Class {
	#name : 'CPProcessPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'diagramElement',
		'diagramScrollElement',
		'detailHostElement',
		'detailScrollElement',
		'workspaceElement',
		'selectedModelElement',
		'moveShapeOperationBlock',
		'resizeShapeOperationBlock',
		'createFlowNodeOperationBlock',
		'replaceFlowNodeOperationBlock',
		'connectFlowNodesOperationBlock',
		'insertFlowNodeOperationBlock',
		'removeFlowNodeOperationBlock',
		'removeSequenceFlowOperationBlock',
		'reconnectSequenceFlowOperationBlock',
		'setEdgeWaypointsOperationBlock',
		'setEdgeLabelBoundsOperationBlock'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'private - building' }
CPProcessPresentation >> prepareHostElement [
	| surfaceColor |
	surfaceColor := self workspaceSurfaceColor.

	diagramElement := CPProcessVisualElement new
		selectionChangedDo: [ :aModelElement | self selectModelElement: aModelElement ];
		moveShapeOperationFor: moveShapeOperationBlock;
		resizeShapeOperationFor: resizeShapeOperationBlock;
		createFlowNodeOperationFor: createFlowNodeOperationBlock;
		replaceFlowNodeOperationFor: replaceFlowNodeOperationBlock;
		connectFlowNodesOperationFor: connectFlowNodesOperationBlock;
		insertFlowNodeOperationFor: insertFlowNodeOperationBlock;
		removeFlowNodeOperationFor: removeFlowNodeOperationBlock;
		removeSequenceFlowOperationFor: removeSequenceFlowOperationBlock;
		reconnectSequenceFlowOperationFor: reconnectSequenceFlowOperationBlock;
		setEdgeWaypointsOperationFor: setEdgeWaypointsOperationBlock;
		setEdgeLabelBoundsOperationFor: setEdgeLabelBoundsOperationBlock;
		memento: self memento;
		yourself.

	diagramScrollElement := BrScrollPane new
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

	detailScrollElement := BrScrollPane new
		background: surfaceColor;
		allowMeAndChildrenMouseEvents;
		aptitude: BrScrollPaneAptitude + BrGlamorousWithVerticalScrollbarAptitude;
		hExact: 380;
		vMatchParent;
		content: detailHostElement;
		yourself.

	workspaceElement := BrHorizontalPane new
		background: surfaceColor;
		hMatchParent;
		vMatchParent;
		cellSpacing: 0;
		addChild: diagramScrollElement;
		addChild: detailScrollElement;
		yourself.

	self hostElement
		background: surfaceColor;
		hMatchParent;
		vMatchParent;
		addChild: workspaceElement.

	selectedModelElement := nil
]

{ #category : 'private - selection' }
CPProcessPresentation >> selectModelElement: aModelElement [
	| selectedMemento detailElement |
	selectedModelElement := aModelElement.
	aModelElement ifNil: [
		detailHostElement removeChildren.
		^ self ].
	selectedMemento := self mementoForModelElement: aModelElement.
	detailElement := self
		newDetailElementFor: aModelElement
		memento: selectedMemento.
	detailHostElement
		removeChildren;
		addChild: detailElement
]

{ #category : 'private - selection' }
CPProcessPresentation >> mementoForModelElement: aModelElement [
	| flowElementsDescription flowElements |
	aModelElement == self memento model ifTrue: [ ^ self memento ].

	flowElementsDescription := self memento magritteDescription
		detect: [ :each | each handlesSelector: #flowElements ].
	flowElements := self memento readUsing: flowElementsDescription.
	(flowElements identityIncludes: aModelElement) ifFalse: [
		self error: 'Selected model element is not part of the staged process flowElements relation' ].
	^ self memento
		childMementoFor: aModelElement
		inRelation: flowElementsDescription
]

{ #category : 'private - selection' }
CPProcessPresentation >> newDetailElementFor: aModelElement memento: aMemento [
	| viewModel |
	viewModel := CFMaViewModel forObject: aModelElement memento: aMemento.
	viewModel
		ignoreImplicitActions;
		elementBuilderDo: [ CFMaDetailPresentation new ].
	^ viewModel asElement
]

{ #category : 'private - theme' }
CPProcessPresentation >> resolvedThemeColor: aThemeableColor [
	^ aThemeableColor blocResolveColorForTheme: self hostElement theme
]

{ #category : 'private - theme' }
CPProcessPresentation >> workspaceSurfaceColor [
	^ self resolvedThemeColor: self hostElement theme surfaces baseBackground
]

{ #category : 'visiting-description' }
CPProcessPresentation >> visitContainer: aDescription [
	"The Process diagram is the visual representation of the root description.
	Its semantic descriptions remain available to the memento and to complementary
	presentations such as Foundation Detail."
	aDescription == self objectDescription ifTrue: [ ^ self ].
	^ super visitContainer: aDescription
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> diagramElement [
	^ diagramElement
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> detailHostElement [
	^ detailHostElement
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> selectedModelElement [
	^ selectedModelElement
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> workspaceElement [
	^ workspaceElement
]

{ #category : 'configuration' }
CPProcessPresentation >> moveShapeOperationFor: aBlock [
	moveShapeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessPresentation >> synchronizeEditingConfiguration [
	diagramElement ifNil: [ ^ self ].
	diagramElement
		moveShapeOperationFor: moveShapeOperationBlock;
		resizeShapeOperationFor: resizeShapeOperationBlock;
		createFlowNodeOperationFor: createFlowNodeOperationBlock;
		replaceFlowNodeOperationFor: replaceFlowNodeOperationBlock;
		connectFlowNodesOperationFor: connectFlowNodesOperationBlock;
		insertFlowNodeOperationFor: insertFlowNodeOperationBlock;
		removeFlowNodeOperationFor: removeFlowNodeOperationBlock;
		removeSequenceFlowOperationFor: removeSequenceFlowOperationBlock;
		reconnectSequenceFlowOperationFor: reconnectSequenceFlowOperationBlock;
		setEdgeWaypointsOperationFor: setEdgeWaypointsOperationBlock;
		setEdgeLabelBoundsOperationFor: setEdgeLabelBoundsOperationBlock.
	diagramElement refresh
]

{ #category : 'configuration' }
CPProcessPresentation >> createFlowNodeOperationFor: aBlock [ createFlowNodeOperationBlock := aBlock ]
{ #category : 'configuration' }
CPProcessPresentation >> replaceFlowNodeOperationFor: aBlock [ replaceFlowNodeOperationBlock := aBlock ]

{ #category : 'configuration' }
CPProcessPresentation >> connectFlowNodesOperationFor: aBlock [ connectFlowNodesOperationBlock := aBlock ]

{ #category : 'configuration' }
CPProcessPresentation >> removeFlowNodeOperationFor: aBlock [ removeFlowNodeOperationBlock := aBlock ]

{ #category : 'configuration' }
CPProcessPresentation >> removeSequenceFlowOperationFor: aBlock [ removeSequenceFlowOperationBlock := aBlock ]


{ #category : 'configuration' }
CPProcessPresentation >> reconnectSequenceFlowOperationFor: aBlock [
	reconnectSequenceFlowOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessPresentation >> setEdgeWaypointsOperationFor: aBlock [
	setEdgeWaypointsOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessPresentation >> insertFlowNodeOperationFor: aBlock [
	insertFlowNodeOperationBlock := aBlock
]


{ #category : 'configuration' }
CPProcessPresentation >> resizeShapeOperationFor: aBlock [
	resizeShapeOperationBlock := aBlock
]

{ #category : 'configuration' }
CPProcessPresentation >> setEdgeLabelBoundsOperationFor: aBlock [
	setEdgeLabelBoundsOperationBlock := aBlock
]
