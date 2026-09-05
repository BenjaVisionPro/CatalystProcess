"I stage reconnection of an existing CPSequenceFlow while preserving its semantic and diagram identities.

I assess the proposed endpoints against the same Process-owned sequence-flow rules used for creation. The current flow is omitted from the topology used for duplicate detection. On apply I stage the endpoint references, both inverse relations, and the existing CPEdge waypoints."
Class {
	#name : 'CPAtelierReconnectSequenceFlow',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'sequenceFlow',
		'proposedSource',
		'proposedTarget',
		'processMemento',
		'flowElementsDescription',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReconnectSequenceFlow class >> sequenceFlow: aSequenceFlow source: aSource target: aTarget processMemento: aMemento flowElementsDescription: aFlowElementsDescription diagramDescription: aDiagramDescription [
	^ self new
		sequenceFlow: aSequenceFlow;
		proposedSource: aSource;
		proposedTarget: aTarget;
		processMemento: aMemento;
		flowElementsDescription: aFlowElementsDescription;
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierReconnectSequenceFlow >> assess [
	| flowElements currentSource currentTarget topology ruleResult
	  diagram diagramMemento elementsDescription elements sourceShape targetShape
	  edgeMatches edge sourceDescription targetDescription |

	sequenceFlow ifNil: [ ^ self rejectedBecause: 'A sequence flow is required.' ].
	flowElements := processMemento readUsing: flowElementsDescription.
	flowElements ifNil: [ ^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	(flowElements identityIncludes: sequenceFlow) ifFalse: [
		^ self rejectedBecause: 'The sequence flow does not belong to the staged process.' ].

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
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
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
	(edge waypointsDescription validate: edge waypoints)
		ifNotNil: [ :ignored | ignored ].

	^ CPAtelierReconnectSequenceFlowAssessment
		sequenceFlow: sequenceFlow
		currentSource: currentSource
		currentTarget: currentTarget
		proposedSource: proposedSource
		proposedTarget: proposedTarget
]

{ #category : 'applying' }
CPAtelierReconnectSequenceFlow >> applyAssessment: anAssessment [
	| flowMemento sourceDescription targetDescription
	  diagram diagramMemento elementsDescription elements edge
	  edgeMemento waypointsDescription sourceShape targetShape
	  sourceBounds targetBounds proposedWaypoints |

	flowMemento := processMemento
		childMementoFor: sequenceFlow
		inRelation: flowElementsDescription.
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

	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.

	edge := (elements select: [
		:each | each isEdge and: [ each modelElement == sequenceFlow ] ]) first.
	sourceShape := self
		shapeFor: anAssessment proposedSource
		in: elements
		diagramMemento: diagramMemento
		elementsDescription: elementsDescription.
	targetShape := self
		shapeFor: anAssessment proposedTarget
		in: elements
		diagramMemento: diagramMemento
		elementsDescription: elementsDescription.
	sourceBounds := self
		stagedBoundsOf: sourceShape
		in: diagramMemento
		elementsDescription: elementsDescription.
	targetBounds := self
		stagedBoundsOf: targetShape
		in: diagramMemento
		elementsDescription: elementsDescription.

	edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
	waypointsDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	proposedWaypoints := (edgeMemento readUsing: waypointsDescription) species
		with: sourceBounds center
		with: targetBounds center.
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
	| flowMemento description |
	flowMemento := processMemento
		childMementoFor: aSequenceFlow
		inRelation: flowElementsDescription.
	description := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stagedTargetOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := processMemento
		childMementoFor: aSequenceFlow
		inRelation: flowElementsDescription.
	description := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stageIncomingIncluding: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	current := nodeMemento readUsing: description.
	(current identityIncludes: aSequenceFlow) ifTrue: [ ^ self ].
	proposed := current species withAll: current.
	proposed add: aSequenceFlow.
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stageIncomingWithout: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	current := nodeMemento readUsing: description.
	proposed := current species withAll: (current reject: [ :each | each == aSequenceFlow ]).
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stageOutgoingIncluding: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := nodeMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	current := nodeMemento readUsing: description.
	(current identityIncludes: aSequenceFlow) ifTrue: [ ^ self ].
	proposed := current species withAll: current.
	proposed add: aSequenceFlow.
	nodeMemento write: proposed using: description
]

{ #category : 'private - staged topology' }
CPAtelierReconnectSequenceFlow >> stageOutgoingWithout: aSequenceFlow for: aFlowNode [
	| nodeMemento description current proposed |
	aFlowNode ifNil: [ ^ self ].
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
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
CPAtelierReconnectSequenceFlow >> flowElementsDescription: aDescription [ flowElementsDescription := aDescription ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> diagramDescription: aDescription [ diagramDescription := aDescription ]
