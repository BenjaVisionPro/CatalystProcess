"I stage one sequence-flow connection between two existing CPFlowNode objects and add its CPEdge depiction.

Source and target are written through the fresh CPSequenceFlow child memento, so assessing and staging do not mutate the existing nodes' inverse collections."
Class {
	#name : 'CPAtelierConnectFlowNodes',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'source',
		'target',
		'processMemento',
		'flowElementsDescription',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierConnectFlowNodes class >> source: aSource target: aTarget processMemento: aMemento flowElementsDescription: aFlowElementsDescription diagramDescription: aDiagramDescription [
	^ self new source: aSource; target: aTarget; processMemento: aMemento; flowElementsDescription: aFlowElementsDescription; diagramDescription: aDiagramDescription; yourself
]

{ #category : 'assessing' }
CPAtelierConnectFlowNodes >> assess [
	| flowElements topology ruleResult diagram diagramMemento elementsDescription elements sourceShape targetShape sequenceFlow edge proposedFlowElements proposedElements sourceDescription targetDescription |
	flowElements := processMemento readUsing: flowElementsDescription.
	flowElements ifNil: [ ^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	topology := self stagedTopologyFrom: flowElements.
	ruleResult := CPSequenceFlowConnectionRules new assessConnectionFrom: source to: target in: topology.
	ruleResult isAllowed ifFalse: [ ^ self rejectedBecause: ruleResult message ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].
	sourceShape := self
		shapeFor: source
		in: elements
		diagramMemento: diagramMemento
		elementsDescription: elementsDescription.
	targetShape := self
		shapeFor: target
		in: elements
		diagramMemento: diagramMemento
		elementsDescription: elementsDescription.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [ ^ self rejectedBecause: 'Both connection endpoints require diagram shapes.' ].
	((self stagedBoundsOf: sourceShape in: diagramMemento elementsDescription: elementsDescription) isNil
		or: [ (self stagedBoundsOf: targetShape in: diagramMemento elementsDescription: elementsDescription) isNil ]) ifTrue: [
		^ self rejectedBecause: 'Both connection endpoint shapes require staged bounds.' ].

	sequenceFlow := CPSequenceFlow new.
	sourceDescription := sequenceFlow magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := sequenceFlow magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	[ sourceDescription validate: source. targetDescription validate: target ] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].

	edge := CPEdge new modelElement: sequenceFlow; yourself.
	edge
		addWaypoint: (self stagedBoundsOf: sourceShape in: diagramMemento elementsDescription: elementsDescription) center;
		addWaypoint: (self stagedBoundsOf: targetShape in: diagramMemento elementsDescription: elementsDescription) center.
	proposedFlowElements := flowElements asOrderedCollection copy.
	proposedFlowElements add: sequenceFlow.
	[ flowElementsDescription validate: proposedFlowElements ] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: edge.
	[ elementsDescription validate: proposedElements ] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierConnectFlowNodesAssessment source: source target: target sequenceFlow: sequenceFlow edge: edge proposedFlowElements: proposedFlowElements proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierConnectFlowNodes >> applyAssessment: anAssessment [
	| flowMemento sourceDescription targetDescription diagram diagramMemento elementsDescription |
	processMemento write: anAssessment proposedFlowElements using: flowElementsDescription.
	flowMemento := processMemento childMementoFor: anAssessment sequenceFlow inRelation: flowElementsDescription.
	sourceDescription := flowMemento magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := flowMemento magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	flowMemento write: source using: sourceDescription.
	flowMemento write: target using: targetDescription.
	self stageOutgoingIncluding: anAssessment sequenceFlow for: source.
	self stageIncomingIncluding: anAssessment sequenceFlow for: target.
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription detect: [ :each | each handlesSelector: #elements ].
	diagramMemento write: anAssessment proposedDiagramElements using: elementsDescription
]

{ #category : 'private - staged topology' }
CPAtelierConnectFlowNodes >> stageIncomingIncluding: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	current := nodeMemento readUsing: description.
	(current identityIncludes: aSequenceFlow) ifTrue: [ ^ self ].
	proposed := current asOrderedCollection copy.
	proposed add: aSequenceFlow.
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged topology' }
CPAtelierConnectFlowNodes >> stageOutgoingIncluding: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	current := nodeMemento readUsing: description.
	(current identityIncludes: aSequenceFlow) ifTrue: [ ^ self ].
	proposed := current asOrderedCollection copy.
	proposed add: aSequenceFlow.
	nodeMemento write: proposed using: description
]


{ #category : 'private - staged topology' }
CPAtelierConnectFlowNodes >> stagedTopologyFrom: flowElements [
	| topology |
	topology := CPProcessTopology new.
	flowElements do: [ :each |
		each isSequenceFlow
			ifTrue: [ topology
				addSequenceFlow: each
				source: (self stagedSourceOf: each)
				target: (self stagedTargetOf: each) ]
			ifFalse: [ topology addFlowElement: each ] ].
	^ topology
]

{ #category : 'private - staged topology' }
CPAtelierConnectFlowNodes >> stagedSourceOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := processMemento childMementoFor: aSequenceFlow inRelation: flowElementsDescription.
	description := flowMemento magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged topology' }
CPAtelierConnectFlowNodes >> stagedTargetOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := processMemento childMementoFor: aSequenceFlow inRelation: flowElementsDescription.
	description := flowMemento magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierConnectFlowNodes >> stagedBoundsOf: aShape in: diagramMemento elementsDescription: elementsDescription [
	| shapeMemento description |
	shapeMemento := diagramMemento childMementoFor: aShape inRelation: elementsDescription.
	description := shapeMemento magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	^ shapeMemento readUsing: description
]

{ #category : 'private' }
CPAtelierConnectFlowNodes >> shapeFor: aFlowNode in: elements diagramMemento: aDiagramMemento elementsDescription: anElementsDescription [
	| matches |
	matches := elements select: [ :each |
		each isShape and: [
			(self
				stagedModelElementOf: each
				in: aDiagramMemento
				elementsDescription: anElementsDescription) == aFlowNode ] ].
	^ matches size = 1 ifTrue: [ matches first ] ifFalse: [ nil ]
]

{ #category : 'private - staged state' }
CPAtelierConnectFlowNodes >> stagedModelElementOf: aShape in: aDiagramMemento elementsDescription: anElementsDescription [
	| shapeMemento description |
	shapeMemento := aDiagramMemento childMementoFor: aShape inRelation: anElementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	^ shapeMemento readUsing: description
]
{ #category : 'private' }
CPAtelierConnectFlowNodes >> rejectedBecause: aString [ ^ CPAtelierConnectFlowNodesAssessment source: source target: target rejectedBecause: aString ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodes >> source: anObject [ source := anObject ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodes >> target: anObject [ target := anObject ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodes >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodes >> flowElementsDescription: aDescription [ flowElementsDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierConnectFlowNodes >> diagramDescription: aDescription [ diagramDescription := aDescription ]
