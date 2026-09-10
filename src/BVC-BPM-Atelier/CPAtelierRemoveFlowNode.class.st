"I stage removal of one CPFlowNode, its shape, and all staged incident sequence flows and edges."
Class {
	#name : 'CPAtelierRemoveFlowNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNode',
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
CPAtelierRemoveFlowNode class >> flowNode: aFlowNode processMemento: aMemento flowElementsDescription: aFlowElementsDescription diagramDescription: aDiagramDescription [
	^ self new
		flowNode: aFlowNode;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext
			container: aMemento model
			memento: aMemento
			flowElementsDescription: aFlowElementsDescription);
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveFlowNode class >> flowNode: aFlowNode flowContainer: aContainer processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new
		flowNode: aFlowNode;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext
			forContainer: aContainer
			inRootMemento: aMemento);
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveFlowNode class >> flowNode: aFlowNode flowContainer: aContainer processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		flowNode: aFlowNode;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierRemoveFlowNode >> assess [
	| flowElements removedFlowNodes incidentFlows proposedFlowElements diagram elements removedDiagramElements proposedElements diagramContext |
	flowNode ifNil: [ ^ self rejectedBecause: 'A flow node is required.' ].
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	flowElements := flowContainerContext stagedFlowElements.
	flowElements ifNil: [ ^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	(flowElements identityIncludes: flowNode) ifFalse: [ ^ self rejectedBecause: 'The flow node does not belong to the staged process.' ].

	removedFlowNodes := IdentitySet with: flowNode.
	flowNode isActivity ifTrue: [
		removedFlowNodes addAll: (flowContainerContext attachedBoundaryEventsFor: flowNode) ].
	incidentFlows := flowElements select: [ :each |
		each isSequenceFlow and: [
			(removedFlowNodes includes: (self stagedSourceOf: each))
				or: [ removedFlowNodes includes: (self stagedTargetOf: each) ] ] ].
	proposedFlowElements := flowElements species withAll: (flowElements reject: [ :each |
		(removedFlowNodes includes: each) or: [ incidentFlows identityIncludes: each ] ]).

	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	elements := diagramContext elements.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].
	removedDiagramElements := elements select: [ :each |
		(each isShape and: [
			removedFlowNodes includes: (diagramContext modelElementOf: each) ])
			or: [ each isEdge and: [ incidentFlows identityIncludes: (diagramContext modelElementOf: each) ] ] ].
	removedFlowNodes do: [ :aRemovedFlowNode |
		(removedDiagramElements anySatisfy: [ :each |
			each isShape and: [
				(diagramContext modelElementOf: each) == aRemovedFlowNode ] ])
			ifFalse: [ ^ self rejectedBecause: 'Every removed flow node must have a staged diagram shape.' ] ].
	proposedElements := elements species withAll: (elements reject: [ :each | removedDiagramElements identityIncludes: each ]).

	[ flowContainerContext flowElementsDescription validate: proposedFlowElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierRemoveFlowNodeAssessment
		flowNode: flowNode
		removedFlowNodes: removedFlowNodes
		removedSequenceFlows: incidentFlows
		removedDiagramElements: removedDiagramElements
		proposedFlowElements: proposedFlowElements
		proposedDiagramElements: proposedElements
]


{ #category : 'applying' }
CPAtelierRemoveFlowNode >> applyAssessment: anAssessment [
	| incidentTopology removedFlowNodes diagram diagramContext |
	removedFlowNodes := anAssessment removedFlowNodes.
	incidentTopology := anAssessment removedSequenceFlows collect: [ :aSequenceFlow |
		{ aSequenceFlow. self stagedSourceOf: aSequenceFlow. self stagedTargetOf: aSequenceFlow } ].

	flowContainerContext writeFlowElements: anAssessment proposedFlowElements.
	incidentTopology do: [ :each |
		| aSequenceFlow source target |
		aSequenceFlow := each first.
		source := each second.
		target := each third.
		(removedFlowNodes includes: source) ifFalse: [ self stageOutgoingWithout: aSequenceFlow for: source ].
		(removedFlowNodes includes: target) ifFalse: [ self stageIncomingWithout: aSequenceFlow for: target ] ].

	diagramContext := self stagedDiagramContext.
	diagramContext writeElements: anAssessment proposedDiagramElements.
	removedFlowNodes do: [ :aRemovedFlowNode |
		flowContainerContext detachChildMementoFor: aRemovedFlowNode ].
	anAssessment removedSequenceFlows do: [ :aSequenceFlow |
		flowContainerContext detachChildMementoFor: aSequenceFlow ].
	anAssessment removedDiagramElements do: [ :aDiagramElement |
		diagramContext detachElement: aDiagramElement ]
]


{ #category : 'private - staged topology' }
CPAtelierRemoveFlowNode >> stageIncomingWithout: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	current := nodeMemento readUsing: description.
	proposed := current species withAll: (current reject: [ :each | each == aSequenceFlow ]).
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged topology' }
CPAtelierRemoveFlowNode >> stageOutgoingWithout: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	current := nodeMemento readUsing: description.
	proposed := current species withAll: (current reject: [ :each | each == aSequenceFlow ]).
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged state' }
CPAtelierRemoveFlowNode >> stagedSourceOf: aSequenceFlow [
	^ flowContainerContext stagedSourceOf: aSequenceFlow
]

{ #category : 'private - staged state' }
CPAtelierRemoveFlowNode >> stagedTargetOf: aSequenceFlow [
	^ flowContainerContext stagedTargetOf: aSequenceFlow
]


{ #category : 'private' }
CPAtelierRemoveFlowNode >> rejectedBecause: aString [
	^ CPAtelierRemoveFlowNodeAssessment flowNode: flowNode rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierRemoveFlowNode >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNode >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNode >> flowContainerContext: aContext [ flowContainerContext := aContext ]
{ #category : 'accessing' }
CPAtelierRemoveFlowNode >> diagramDescription: aDescription [ diagramDescription := aDescription ]

{ #category : 'private - staged state' }
CPAtelierRemoveFlowNode >> stagedDiagramContext [
	diagramContext ifNotNil: [ ^ diagramContext ].
	diagramContext := self stagedDiagramContext.
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierRemoveFlowNode >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
