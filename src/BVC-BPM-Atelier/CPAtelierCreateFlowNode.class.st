"I stage creation of one supplied CPFlowNode together with its CPShape depiction.

The palette owns materialisation. I receive the fresh semantic object and proposed bounds, validate the complete staged Process and Diagram relations, and write both relations through their existing Magritte mementos."
Class {
	#name : 'CPAtelierCreateFlowNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNode',
		'bounds',
		'processMemento',
		'flowContainerContext',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateFlowNode class >> flowNode: aFlowNode bounds: aRectangle processMemento: aMemento flowElementsDescription: aFlowElementsDescription diagramContext: aDiagramContext [
	^ self new
		flowNode: aFlowNode;
		bounds: aRectangle;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext
			container: aMemento model
			memento: aMemento
			flowElementsDescription: aFlowElementsDescription);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'instance creation' }
CPAtelierCreateFlowNode class >> flowNode: aFlowNode bounds: aRectangle flowContainer: aContainer processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		flowNode: aFlowNode;
		bounds: aRectangle;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierCreateFlowNode >> assess [
	| flowElements proposedFlowElements diagram elements proposedElements shape boundsDescription diagramContext |
	flowNode ifNil: [ ^ self rejectedBecause: 'A flow node is required.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Diagram bounds are required.' ].
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	flowElements := flowContainerContext stagedFlowElements.
	flowElements ifNil: [ ^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	(flowElements identityIncludes: flowNode) ifTrue: [ ^ self rejectedBecause: 'The flow node is already present in the process.' ].

	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	elements := diagramContext elements.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].

	shape := CPShape new modelElement: flowNode; bounds: bounds; yourself.
	boundsDescription := shape magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	[ boundsDescription validate: bounds ] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedFlowElements := flowElements asOrderedCollection copy.
	proposedFlowElements add: flowNode.
	[ flowContainerContext flowElementsDescription validate: proposedFlowElements ] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ diagramContext validateElements: proposedElements ] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierCreateFlowNodeAssessment
		flowNode: flowNode
		shape: shape
		proposedFlowElements: proposedFlowElements
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierCreateFlowNode >> applyAssessment: anAssessment [
	| diagram diagramContext |
	flowContainerContext writeFlowElements: anAssessment proposedFlowElements.
	diagramContext := self stagedDiagramContext.
	diagramContext writeElements: anAssessment proposedDiagramElements
]

{ #category : 'private' }
CPAtelierCreateFlowNode >> rejectedBecause: aString [
	^ CPAtelierCreateFlowNodeAssessment flowNode: flowNode rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierCreateFlowNode >> flowNode [ ^ flowNode ]
{ #category : 'accessing' }
CPAtelierCreateFlowNode >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierCreateFlowNode >> bounds [ ^ bounds ]
{ #category : 'accessing' }
CPAtelierCreateFlowNode >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierCreateFlowNode >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierCreateFlowNode >> flowContainerContext: aContext [ flowContainerContext := aContext ]
{ #category : 'private - staged state' }
CPAtelierCreateFlowNode >> stagedDiagramContext [
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierCreateFlowNode >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
