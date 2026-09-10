"I stage removal of one CPSequenceFlow and its diagram depiction from a CPProcess transaction."
Class {
	#name : 'CPAtelierRemoveSequenceFlow',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'sequenceFlow',
		'processMemento',
		'flowContainerContext',
		'diagramDescription',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveSequenceFlow class >> sequenceFlow: aSequenceFlow processMemento: aMemento flowElementsDescription: aFlowElementsDescription diagramDescription: aDiagramDescription [
	^ self new
		sequenceFlow: aSequenceFlow;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext
			container: aMemento model
			memento: aMemento
			flowElementsDescription: aFlowElementsDescription);
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveSequenceFlow class >> sequenceFlow: aSequenceFlow flowContainer: aContainer processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new
		sequenceFlow: aSequenceFlow;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext
			forContainer: aContainer
			inRootMemento: aMemento);
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveSequenceFlow class >> sequenceFlow: aSequenceFlow flowContainer: aContainer processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		sequenceFlow: aSequenceFlow;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierRemoveSequenceFlow >> assess [
	| flowElements proposedFlowElements diagram elements removedEdges proposedElements diagramContext |
	sequenceFlow ifNil: [ ^ self rejectedBecause: 'A sequence flow is required.' ].
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	flowElements := flowContainerContext stagedFlowElements.
	flowElements ifNil: [ ^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	(flowElements identityIncludes: sequenceFlow) ifFalse: [ ^ self rejectedBecause: 'The sequence flow does not belong to the staged process.' ].

	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	elements := diagramContext elements.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].
	removedEdges := diagramContext edgesForModelElement: sequenceFlow.
	removedEdges isEmpty ifTrue: [ ^ self rejectedBecause: 'The sequence flow has no staged diagram edge.' ].

	proposedFlowElements := flowElements species withAll: (flowElements reject: [ :each | each == sequenceFlow ]).
	proposedElements := elements species withAll: (elements reject: [ :each | removedEdges identityIncludes: each ]).
	[ flowContainerContext flowElementsDescription validate: proposedFlowElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierRemoveSequenceFlowAssessment
		sequenceFlow: sequenceFlow
		proposedFlowElements: proposedFlowElements
		proposedDiagramElements: proposedElements
		removedEdges: removedEdges
]

{ #category : 'applying' }
CPAtelierRemoveSequenceFlow >> applyAssessment: anAssessment [
	| source target diagram diagramContext |
	source := self stagedSourceOf: sequenceFlow.
	target := self stagedTargetOf: sequenceFlow.

	flowContainerContext writeFlowElements: anAssessment proposedFlowElements.
	self stageOutgoingWithout: sequenceFlow for: source.
	self stageIncomingWithout: sequenceFlow for: target.

	diagramContext := self stagedDiagramContext.
	diagramContext writeElements: anAssessment proposedDiagramElements.
	flowContainerContext detachChildMementoFor: sequenceFlow.
	anAssessment removedEdges do: [ :anEdge |
		diagramContext detachElement: anEdge ]
]

{ #category : 'private - staged topology' }
CPAtelierRemoveSequenceFlow >> stageIncomingWithout: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	current := nodeMemento readUsing: description.
	proposed := current species withAll: (current reject: [ :each | each == aSequenceFlow ]).
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged topology' }
CPAtelierRemoveSequenceFlow >> stageOutgoingWithout: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	current := nodeMemento readUsing: description.
	proposed := current species withAll: (current reject: [ :each | each == aSequenceFlow ]).
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged topology' }
CPAtelierRemoveSequenceFlow >> stagedSourceOf: aSequenceFlow [
	^ flowContainerContext stagedSourceOf: aSequenceFlow
]

{ #category : 'private - staged topology' }
CPAtelierRemoveSequenceFlow >> stagedTargetOf: aSequenceFlow [
	^ flowContainerContext stagedTargetOf: aSequenceFlow
]

{ #category : 'private' }
CPAtelierRemoveSequenceFlow >> rejectedBecause: aString [
	^ CPAtelierRemoveSequenceFlowAssessment sequenceFlow: sequenceFlow rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierRemoveSequenceFlow >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlow >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlow >> flowContainerContext: aContext [ flowContainerContext := aContext ]
{ #category : 'accessing' }
CPAtelierRemoveSequenceFlow >> diagramDescription: aDescription [ diagramDescription := aDescription ]

{ #category : 'private - staged state' }
CPAtelierRemoveSequenceFlow >> stagedDiagramContext [
	diagramContext ifNotNil: [ ^ diagramContext ].
	diagramContext := self stagedDiagramContext.
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierRemoveSequenceFlow >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
