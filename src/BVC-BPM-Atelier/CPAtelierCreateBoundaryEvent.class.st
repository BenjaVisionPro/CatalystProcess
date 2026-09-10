"I stage one Boundary Event, its Activity attachment and its CPShape as one Process editing intention."
Class {
	#name : 'CPAtelierCreateBoundaryEvent',
	#superclass : 'CFAtelierOperation',
	#instVars : [ 'boundaryEvent', 'activity', 'bounds', 'processMemento', 'flowContainerContext', 'diagramDescription', 'diagramContext' ],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}
{ #category : 'instance creation' }
CPAtelierCreateBoundaryEvent class >> boundaryEvent: anEvent attachedTo: anActivity bounds: aRectangle flowContainer: aContainer processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new boundaryEvent: anEvent; activity: anActivity; bounds: aRectangle; processMemento: aMemento; flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento); diagramDescription: aDiagramDescription; yourself
]
{ #category : 'instance creation' }
CPAtelierCreateBoundaryEvent class >> boundaryEvent: anEvent attachedTo: anActivity bounds: aRectangle flowContainer: aContainer processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		boundaryEvent: anEvent;
		activity: anActivity;
		bounds: aRectangle;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierCreateBoundaryEvent >> assess [
	| flowElements proposedFlowElements diagram diagramContext elements proposedElements shape boundsDescription |
	boundaryEvent ifNil: [ ^ self rejectedBecause: 'A boundary event is required.' ].
	boundaryEvent isBoundaryEvent ifFalse: [ ^ self rejectedBecause: 'The created flow node must be a boundary event.' ].
	activity ifNil: [ ^ self rejectedBecause: 'An attached Activity is required.' ].
	activity isActivity ifFalse: [ ^ self rejectedBecause: 'A boundary event can only attach to an Activity.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Diagram bounds are required.' ].
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	flowElements := flowContainerContext stagedFlowElements.
	(flowElements identityIncludes: activity) ifFalse: [ ^ self rejectedBecause: 'The attached Activity must belong to the target flow container.' ].
	(flowElements identityIncludes: boundaryEvent) ifTrue: [ ^ self rejectedBecause: 'The boundary event is already present in the process.' ].
	boundaryEvent eventDefinitions ifEmpty: [ ^ self rejectedBecause: 'A boundary event requires at least one EventDefinition.' ].

	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	elements := diagramContext elements.
	shape := CPShape new modelElement: boundaryEvent; bounds: bounds; yourself.
	boundsDescription := shape magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	[ boundsDescription validate: bounds ] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].
	proposedFlowElements := flowElements asOrderedCollection copy.
	proposedFlowElements add: boundaryEvent.
	[ flowContainerContext flowElementsDescription validate: proposedFlowElements ] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ diagramContext validateElements: proposedElements ] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].
	^ CPAtelierCreateBoundaryEventAssessment boundaryEvent: boundaryEvent shape: shape activity: activity proposedFlowElements: proposedFlowElements proposedDiagramElements: proposedElements
]
{ #category : 'applying' }
CPAtelierCreateBoundaryEvent >> applyAssessment: anAssessment [
	| eventMemento attachedDescription diagram diagramContext |
	flowContainerContext writeFlowElements: anAssessment proposedFlowElements.
	eventMemento := flowContainerContext childMementoFor: boundaryEvent.
	attachedDescription := eventMemento magritteDescription detect: [ :each | each handlesSelector: #attachedToRef ].
	eventMemento write: activity using: attachedDescription.
	diagramContext := self stagedDiagramContext.
	diagramContext writeElements: anAssessment proposedDiagramElements
]
{ #category : 'private' }
CPAtelierCreateBoundaryEvent >> rejectedBecause: aString [ ^ CPAtelierCreateBoundaryEventAssessment boundaryEvent: boundaryEvent rejectedBecause: aString ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEvent >> boundaryEvent: anObject [ boundaryEvent := anObject ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEvent >> activity: anObject [ activity := anObject ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEvent >> bounds: anObject [ bounds := anObject ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEvent >> processMemento: anObject [ processMemento := anObject ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEvent >> flowContainerContext: anObject [ flowContainerContext := anObject ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEvent >> diagramDescription: anObject [ diagramDescription := anObject ]

{ #category : 'private - staged state' }
CPAtelierCreateBoundaryEvent >> stagedDiagramContext [
	diagramContext ifNotNil: [ ^ diagramContext ].
	diagramContext := self stagedDiagramContext.
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierCreateBoundaryEvent >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
