"I stage removal of one CPFlowNode, its shape, and all staged incident sequence flows and edges."
Class {
	#name : 'CPAtelierRemoveFlowNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNode',
		'processMemento',
		'flowContainerContext',
		'diagramDescription'
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

{ #category : 'assessing' }
CPAtelierRemoveFlowNode >> assess [
	| flowElements incidentFlows proposedFlowElements diagram diagramMemento elementsDescription elements removedDiagramElements proposedElements |
	flowNode ifNil: [ ^ self rejectedBecause: 'A flow node is required.' ].
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	flowElements := flowContainerContext stagedFlowElements.
	flowElements ifNil: [ ^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	(flowElements identityIncludes: flowNode) ifFalse: [ ^ self rejectedBecause: 'The flow node does not belong to the staged process.' ].

	incidentFlows := flowElements select: [ :each |
		each isSequenceFlow and: [
			(self stagedSourceOf: each) == flowNode
				or: [ (self stagedTargetOf: each) == flowNode ] ] ].
	proposedFlowElements := flowElements species withAll: (flowElements reject: [ :each |
		each == flowNode or: [ incidentFlows identityIncludes: each ] ]).

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].
	removedDiagramElements := elements select: [ :each |
		(each isShape and: [
			(self
				stagedModelElementOf: each
				in: diagramMemento
				elementsDescription: elementsDescription) == flowNode ])
			or: [ each isEdge and: [ incidentFlows identityIncludes: each modelElement ] ] ].
	(removedDiagramElements anySatisfy: [ :each |
		each isShape and: [
			(self
				stagedModelElementOf: each
				in: diagramMemento
				elementsDescription: elementsDescription) == flowNode ] ])
		ifFalse: [ ^ self rejectedBecause: 'The flow node has no staged diagram shape.' ].
	proposedElements := elements species withAll: (elements reject: [ :each | removedDiagramElements identityIncludes: each ]).

	[ flowContainerContext flowElementsDescription validate: proposedFlowElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].
	[ elementsDescription validate: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierRemoveFlowNodeAssessment
		flowNode: flowNode
		removedSequenceFlows: incidentFlows
		removedDiagramElements: removedDiagramElements
		proposedFlowElements: proposedFlowElements
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierRemoveFlowNode >> applyAssessment: anAssessment [
	| incidentTopology diagram diagramMemento elementsDescription |
	incidentTopology := anAssessment removedSequenceFlows collect: [ :aSequenceFlow |
		{ aSequenceFlow. self stagedSourceOf: aSequenceFlow. self stagedTargetOf: aSequenceFlow } ].

	flowContainerContext writeFlowElements: anAssessment proposedFlowElements.
	incidentTopology do: [ :each |
		| aSequenceFlow source target |
		aSequenceFlow := each first.
		source := each second.
		target := each third.
		source == flowNode ifFalse: [ self stageOutgoingWithout: aSequenceFlow for: source ].
		target == flowNode ifFalse: [ self stageIncomingWithout: aSequenceFlow for: target ] ].

	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription detect: [ :each | each handlesSelector: #elements ].
	diagramMemento write: anAssessment proposedDiagramElements using: elementsDescription.
	flowContainerContext detachChildMementoFor: flowNode.
	anAssessment removedSequenceFlows do: [ :aSequenceFlow |
		flowContainerContext detachChildMementoFor: aSequenceFlow ].
	anAssessment removedDiagramElements do: [ :aDiagramElement |
		diagramMemento detachChildMementoFor: aDiagramElement inRelation: elementsDescription ]
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
	| flowMemento description |
	flowMemento := flowContainerContext childMementoFor: aSequenceFlow.
	description := flowMemento magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierRemoveFlowNode >> stagedTargetOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := flowContainerContext childMementoFor: aSequenceFlow.
	description := flowMemento magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierRemoveFlowNode >> stagedModelElementOf: aShape in: aDiagramMemento elementsDescription: anElementsDescription [
	| shapeMemento description |
	shapeMemento := aDiagramMemento childMementoFor: aShape inRelation: anElementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	^ shapeMemento readUsing: description
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
