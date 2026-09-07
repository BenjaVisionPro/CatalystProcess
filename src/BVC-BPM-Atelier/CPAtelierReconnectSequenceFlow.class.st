"I stage reconnection of an existing CPSequenceFlow while preserving its semantic and diagram identities.

I assess the proposed endpoints against the same flow-container sequence-flow rules used for creation. The current flow is omitted from the topology used for duplicate detection. On apply I stage the endpoint references, both inverse relations, and the existing CPEdge waypoints."
Class {
	#name : 'CPAtelierReconnectSequenceFlow',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'sequenceFlow',
		'proposedSource',
		'proposedTarget',
		'proposedWaypoints',
		'processMemento',
		'flowContainerContext',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReconnectSequenceFlow class >> sequenceFlow: aSequenceFlow source: aSource target: aTarget waypoints: someWaypoints processMemento: aMemento flowElementsDescription: aFlowElementsDescription diagramDescription: aDiagramDescription [
	^ self new
		sequenceFlow: aSequenceFlow;
		proposedSource: aSource;
		proposedTarget: aTarget;
		proposedWaypoints: someWaypoints;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext container: aMemento model memento: aMemento flowElementsDescription: aFlowElementsDescription);
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReconnectSequenceFlow class >> sequenceFlow: aSequenceFlow source: aSource target: aTarget waypoints: someWaypoints flowContainer: aContainer processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new
		sequenceFlow: aSequenceFlow;
		proposedSource: aSource;
		proposedTarget: aTarget;
		proposedWaypoints: someWaypoints;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierReconnectSequenceFlow >> assess [
	| flowElements currentSource currentTarget topology ruleResult
	  diagram diagramMemento elementsDescription elements sourceShape targetShape
	  edgeMatches edge sourceDescription targetDescription diagramContext |

	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	sequenceFlow ifNil: [ ^ self rejectedBecause: 'A sequence flow is required.' ].
	proposedWaypoints ifNil: [ ^ self rejectedBecause: 'Reconnect waypoints are required.' ].
	proposedWaypoints size < 2 ifTrue: [ ^ self rejectedBecause: 'A reconnectable sequence-flow edge requires at least two waypoints.' ].
	flowElements := flowContainerContext stagedFlowElements.
	flowElements ifNil: [ ^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	(flowElements identityIncludes: sequenceFlow) ifFalse: [
		^ self rejectedBecause: 'The sequence flow does not belong to the staged flow container.' ].
	(flowElements identityIncludes: proposedSource) ifFalse: [
		^ self rejectedBecause: 'The proposed source does not belong to the staged flow container.' ].
	(flowElements identityIncludes: proposedTarget) ifFalse: [
		^ self rejectedBecause: 'The proposed target does not belong to the staged flow container.' ].

	currentSource := self stagedSourceOf: sequenceFlow.
	currentTarget := self stagedTargetOf: sequenceFlow.

	topology := self stagedTopologyFrom: flowElements excluding: sequenceFlow.
	ruleResult := CPSequenceFlowConnectionRules new
		assessConnectionFrom: proposedSource
		to: proposedTarget
		in: topology.
	ruleResult isAllowed ifFalse: [
		^ self rejectedBecause: ruleResult message ].

	sourceDescription := sequenceFlow magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := sequenceFlow magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	[
		sourceDescription validate: proposedSource.
		targetDescription validate: proposedTarget
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: processMemento
		using: diagramDescription.
	diagramMemento := diagramContext diagramMemento.
	elementsDescription := diagramContext elementsDescription.
	elements := diagramMemento readUsing: elementsDescription.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].

	sourceShape := self
		shapeFor: proposedSource
		in: elements
		diagramMemento: diagramMemento
		elementsDescription: elementsDescription.
	targetShape := self
		shapeFor: proposedTarget
		in: elements
		diagramMemento: diagramMemento
		elementsDescription: elementsDescription.
	(sourceShape isNil or: [ targetShape isNil ]) ifTrue: [
		^ self rejectedBecause: 'Both connection endpoints require diagram shapes.' ].

	((self stagedBoundsOf: sourceShape in: diagramMemento elementsDescription: elementsDescription) isNil
		or: [
			(self stagedBoundsOf: targetShape in: diagramMemento elementsDescription: elementsDescription) isNil ])
		ifTrue: [
			^ self rejectedBecause: 'Both connection endpoint shapes require staged bounds.' ].

	edgeMatches := elements select: [
		:each | each isEdge and: [ each modelElement == sequenceFlow ] ].
	edgeMatches size = 1 ifFalse: [
		^ self rejectedBecause: 'The sequence flow requires exactly one staged diagram edge.' ].
	edge := edgeMatches first.
	[ edge waypointsDescription validate: proposedWaypoints ]
		on: MAValidationError do: [ :anException |
			^ self rejectedBecause: anException printString ].

	^ CPAtelierReconnectSequenceFlowAssessment
		sequenceFlow: sequenceFlow
		currentSource: currentSource
		currentTarget: currentTarget
		proposedSource: proposedSource
		proposedTarget: proposedTarget
]

{ #category : 'applying' }
CPAtelierReconnectSequenceFlow >> applyAssessment: anAssessment [
	| flowMemento sourceDescription targetDescription diagramContext edgeMatches edge edgeMemento waypointsDescription |

	flowMemento := flowContainerContext childMementoFor: sequenceFlow.
	sourceDescription := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].

	anAssessment currentSource == anAssessment proposedSource ifFalse: [
		self stageOutgoingWithout: sequenceFlow for: anAssessment currentSource.
		self stageOutgoingIncluding: sequenceFlow for: anAssessment proposedSource.
		flowMemento write: anAssessment proposedSource using: sourceDescription ].

	anAssessment currentTarget == anAssessment proposedTarget ifFalse: [
		self stageIncomingWithout: sequenceFlow for: anAssessment currentTarget.
		self stageIncomingIncluding: sequenceFlow for: anAssessment proposedTarget.
		flowMemento write: anAssessment proposedTarget using: targetDescription ].

	diagramContext := CPDiagramMementoContext
		diagram: (processMemento readUsing: diagramDescription)
		inMemento: processMemento
		using: diagramDescription.
	edgeMatches := diagramContext elements select: [
		:each | each isEdge and: [ (diagramContext modelElementOf: each) == sequenceFlow ] ].
	edge := edgeMatches first.
	edgeMemento := diagramContext diagramMemento
		childMementoFor: edge
		inRelation: diagramContext elementsDescription.
	waypointsDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	edgeMemento write: proposedWaypoints using: waypointsDescription
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stagedTopologyFrom: flowElements excluding: excludedSequenceFlow [
	| topology |
	topology := CPProcessTopology new.
	flowElements do: [ :each |
		each == excludedSequenceFlow ifFalse: [
			each isSequenceFlow
				ifTrue: [
					topology
						addSequenceFlow: each
						source: (self stagedSourceOf: each)
						target: (self stagedTargetOf: each) ]
				ifFalse: [ topology addFlowElement: each ] ] ].
	"Keep the endpoints themselves in topology even when the excluded flow is
	the only object that referenced them."
	flowElements do: [ :each |
		each isSequenceFlow ifFalse: [ topology addFlowElement: each ] ].
	^ topology
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stagedSourceOf: aSequenceFlow [
	^ flowContainerContext stagedSourceOf: aSequenceFlow
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stagedTargetOf: aSequenceFlow [
	^ flowContainerContext stagedTargetOf: aSequenceFlow
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stageIncomingIncluding: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	current := nodeMemento readUsing: description.
	(current identityIncludes: aSequenceFlow) ifTrue: [ ^ self ].
	proposed := current asOrderedCollection copy.
	proposed add: aSequenceFlow.
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stageIncomingWithout: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	current := nodeMemento readUsing: description.
	proposed := current species withAll: (current reject: [ :each | each == aSequenceFlow ]).
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stageOutgoingIncluding: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	current := nodeMemento readUsing: description.
	(current identityIncludes: aSequenceFlow) ifTrue: [ ^ self ].
	proposed := current asOrderedCollection copy.
	proposed add: aSequenceFlow.
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stageOutgoingWithout: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	current := nodeMemento readUsing: description.
	proposed := current species withAll: (current reject: [ :each | each == aSequenceFlow ]).
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged state' }
CPAtelierReconnectSequenceFlow >> stagedBoundsOf: aShape in: diagramMemento elementsDescription: elementsDescription [
	| shapeMemento description |
	shapeMemento := diagramMemento childMementoFor: aShape inRelation: elementsDescription.
	description := shapeMemento magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	^ shapeMemento readUsing: description
]

{ #category : 'private' }
CPAtelierReconnectSequenceFlow >> shapeFor: aFlowNode in: elements diagramMemento: aDiagramMemento elementsDescription: anElementsDescription [
	| matches |
	matches := elements select: [ :each |
		each isShape and: [
			(self
				stagedModelElementOf: each
				in: aDiagramMemento
				elementsDescription: anElementsDescription) == aFlowNode ] ].
	^ matches size = 1
		ifTrue: [ matches first ]
		ifFalse: [ nil ]
]

{ #category : 'private - staged state' }
CPAtelierReconnectSequenceFlow >> stagedModelElementOf: aShape in: aDiagramMemento elementsDescription: anElementsDescription [
	| shapeMemento description |
	shapeMemento := aDiagramMemento childMementoFor: aShape inRelation: anElementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	^ shapeMemento readUsing: description
]

{ #category : 'private' }
CPAtelierReconnectSequenceFlow >> rejectedBecause: aString [
	^ CPAtelierReconnectSequenceFlowAssessment
		sequenceFlow: sequenceFlow
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> proposedSource: anObject [ proposedSource := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> proposedTarget: anObject [ proposedTarget := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> flowContainerContext: aContext [ flowContainerContext := aContext ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> diagramDescription: aDescription [ diagramDescription := aDescription ]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> proposedWaypoints: aCollection [ proposedWaypoints := aCollection asOrderedCollection ]
