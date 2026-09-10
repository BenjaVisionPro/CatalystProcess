"I atomically reattach one existing Boundary Event to another Activity in the same staged flow container and move its DI shape to the authored host-border position. Incident SequenceFlow endpoint waypoints follow the Boundary Event movement."
Class {
	#name : 'CPAtelierReattachBoundaryEvent',
	#superclass : 'CFAtelierOperation',
	#instVars : [ 'boundaryEvent', 'activity', 'shape', 'bounds', 'processMemento', 'flowContainerContext', 'diagramDescription', 'diagramContext' ],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReattachBoundaryEvent class >> boundaryEvent: anEvent shape: aShape attachedTo: anActivity bounds: aRectangle flowContainer: aContainer processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new
		boundaryEvent: anEvent;
		shape: aShape;
		activity: anActivity;
		bounds: aRectangle;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReattachBoundaryEvent class >> boundaryEvent: anEvent shape: aShape attachedTo: anActivity bounds: aRectangle flowContainer: aContainer processMemento: aMemento diagramContext: aDiagramContext [
	^ self new boundaryEvent: anEvent; shape: aShape; activity: anActivity; bounds: aRectangle; processMemento: aMemento; flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento); diagramContext: aDiagramContext; yourself
]

{ #category : 'assessing' }
CPAtelierReattachBoundaryEvent >> assess [
	| flowElements diagram diagramContext elements shapeMemento boundsDescription currentBounds delta currentActivity |
	boundaryEvent ifNil: [ ^ self rejectedBecause: 'A boundary event is required.' ].
	boundaryEvent isBoundaryEvent ifFalse: [ ^ self rejectedBecause: 'The edited flow node must be a boundary event.' ].
	activity ifNil: [ ^ self rejectedBecause: 'An attached Activity is required.' ].
	activity isActivity ifFalse: [ ^ self rejectedBecause: 'A boundary event can only attach to an Activity.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Diagram bounds are required.' ].
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The flow container is not present in staged state.' ].
	flowElements := flowContainerContext stagedFlowElements.
	(flowElements identityIncludes: boundaryEvent) ifFalse: [ ^ self rejectedBecause: 'The boundary event must belong to the flow container.' ].
	(flowElements identityIncludes: activity) ifFalse: [ ^ self rejectedBecause: 'The attached Activity must belong to the same flow container.' ].

	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	elements := diagramContext elements.
	(elements count: [ :each | each == shape ]) = 1 ifFalse: [ ^ self rejectedBecause: 'The boundary event shape must occur exactly once in the diagram.' ].
	(diagramContext modelElementOf: shape) == boundaryEvent ifFalse: [ ^ self rejectedBecause: 'The supplied shape does not depict the boundary event.' ].
	shapeMemento := diagramContext mementoFor: shape.
	boundsDescription := shapeMemento magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	[ boundsDescription validate: bounds ] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].
	currentBounds := shapeMemento readUsing: boundsDescription.
	delta := bounds origin - currentBounds origin.
	currentActivity := flowContainerContext stagedAttachedToOf: boundaryEvent.
	(currentActivity == activity and: [ delta isZero ]) ifTrue: [ ^ self rejectedBecause: 'The boundary event is already attached at the requested bounds.' ].
	^ CPAtelierReattachBoundaryEventAssessment
		boundaryEvent: boundaryEvent
		activity: activity
		shape: shape
		currentBounds: currentBounds
		proposedBounds: bounds
		delta: delta
]

{ #category : 'applying' }
CPAtelierReattachBoundaryEvent >> applyAssessment: anAssessment [
	| eventMemento attachedDescription diagram diagramContext shapeMemento boundsDescription |
	eventMemento := flowContainerContext childMementoFor: boundaryEvent.
	attachedDescription := eventMemento magritteDescription detect: [ :each | each handlesSelector: #attachedToRef ].
	eventMemento write: activity using: attachedDescription.

	diagramContext := self stagedDiagramContext.
	shapeMemento := diagramContext mementoFor: shape.
	boundsDescription := shapeMemento magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	shapeMemento write: anAssessment proposedBounds using: boundsDescription.
	anAssessment delta isZero ifFalse: [
		diagramContext elements do: [ :each |
			each isEdge ifTrue: [ self translateEdgeEndpoint: each by: anAssessment delta in: diagramContext ] ] ]
]

{ #category : 'private - applying' }
CPAtelierReattachBoundaryEvent >> translateEdgeEndpoint: anEdge by: delta in: diagramContext [
	| sequenceFlow sourceMoves targetMoves edgeMemento waypointsDescription waypoints translated |
	sequenceFlow := diagramContext modelElementOf: anEdge.
	(sequenceFlow notNil and: [ sequenceFlow isSequenceFlow ]) ifFalse: [ ^ self ].
	sourceMoves := (flowContainerContext stagedSourceOf: sequenceFlow) == boundaryEvent.
	targetMoves := (flowContainerContext stagedTargetOf: sequenceFlow) == boundaryEvent.
	(sourceMoves or: [ targetMoves ]) ifFalse: [ ^ self ].
	edgeMemento := diagramContext mementoFor: anEdge.
	waypointsDescription := edgeMemento magritteDescription detect: [ :each | each handlesSelector: #waypoints ].
	waypoints := edgeMemento readUsing: waypointsDescription.
	waypoints ifEmpty: [ ^ self ].
	translated := waypoints asOrderedCollection copy.
	sourceMoves ifTrue: [ translated at: 1 put: translated first + delta ].
	targetMoves ifTrue: [ translated at: translated size put: translated last + delta ].
	edgeMemento write: translated using: waypointsDescription
]

{ #category : 'private' }
CPAtelierReattachBoundaryEvent >> rejectedBecause: aString [
	^ CPAtelierReattachBoundaryEventAssessment boundaryEvent: boundaryEvent rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierReattachBoundaryEvent >> boundaryEvent: anObject [ boundaryEvent := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEvent >> activity: anObject [ activity := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEvent >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEvent >> bounds: anObject [ bounds := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEvent >> processMemento: anObject [ processMemento := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEvent >> flowContainerContext: anObject [ flowContainerContext := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEvent >> diagramDescription: anObject [ diagramDescription := anObject ]

{ #category : 'private - staged state' }
CPAtelierReattachBoundaryEvent >> stagedDiagramContext [
	diagramContext ifNotNil: [ ^ diagramContext ].
	diagramContext := CPDiagramMementoContext
		diagram: (processMemento readUsing: diagramDescription)
		inMemento: processMemento
		using: diagramDescription.
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierReattachBoundaryEvent >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
