"
I reconnect an existing staged CPSequenceFlow while preserving its identity and
the identity of its CPEdge depiction.

I stage the endpoint change and the derived incoming/outgoing topology in the
same transaction.  I use CPSequenceFlowConnectionRules for the proposed
connection, exactly as creation does.
"
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
	#category : 'BVC-BPM-Atelier-Operations',
	#package : 'BVC-BPM-Atelier'
}

{ #category : 'instance creation' }
CPAtelierReconnectSequenceFlow class >> sequenceFlow: aSequenceFlow source: aSource target: aTarget in: aProcessMemento flowElementsDescription: aFlowElementsDescription diagramDescription: aDiagramDescription [
	^ self new
		sequenceFlow: aSequenceFlow;
		proposedSource: aSource;
		proposedTarget: aTarget;
		processMemento: aProcessMemento;
		flowElementsDescription: aFlowElementsDescription;
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> sequenceFlow: anObject [ sequenceFlow := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> proposedSource: anObject [ proposedSource := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> proposedTarget: anObject [ proposedTarget := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> processMemento: anObject [ processMemento := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> flowElementsDescription: anObject [ flowElementsDescription := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectSequenceFlow >> diagramDescription: anObject [ diagramDescription := anObject ]

{ #category : 'assessing' }
CPAtelierReconnectSequenceFlow >> assess [
	| assessment topology ruleAssessment |
	assessment := CPAtelierReconnectSequenceFlowAssessment new
		sequenceFlow: sequenceFlow;
		newSource: proposedSource;
		newTarget: proposedTarget;
		yourself.

	topology := CPProcessTopology
		fromMemento: processMemento
		flowElementsDescription: flowElementsDescription.

	ruleAssessment := CPSequenceFlowConnectionRules new
		assessConnectionFrom: proposedSource
		to: proposedTarget
		in: topology
		ignoring: sequenceFlow.

	ruleAssessment isApplicable
		ifFalse: [ ^ assessment beInapplicableBecause: ruleAssessment reason ].
	^ assessment beApplicable
]

{ #category : 'applying' }
CPAtelierReconnectSequenceFlow >> applyAssessment: anAssessment [
	| flowMemento sourceDescription targetDescription oldSource oldTarget |
	flowMemento := processMemento
		childMementoFor: sequenceFlow
		inRelation: flowElementsDescription.
	sourceDescription := sequenceFlow sourceRefDescription.
	targetDescription := sequenceFlow targetRefDescription.
	oldSource := flowMemento readUsing: sourceDescription.
	oldTarget := flowMemento readUsing: targetDescription.

	oldSource == proposedSource ifFalse: [
		self stage: sequenceFlow removedFromOutgoingOf: oldSource.
		self stage: sequenceFlow addedToOutgoingOf: proposedSource.
		flowMemento write: proposedSource using: sourceDescription ].
	oldTarget == proposedTarget ifFalse: [
		self stage: sequenceFlow removedFromIncomingOf: oldTarget.
		self stage: sequenceFlow addedToIncomingOf: proposedTarget.
		flowMemento write: proposedTarget using: targetDescription ].

	self stageEdgeEndpointsFrom: proposedSource to: proposedTarget.
	^ anAssessment
]

{ #category : 'private - topology' }
CPAtelierReconnectSequenceFlow >> stage: aSequenceFlow addedToIncomingOf: aFlowNode [
	| nodeMemento description values |
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := aFlowNode incomingDescription.
	values := (nodeMemento readUsing: description) copy.
	(values includes: aSequenceFlow) ifFalse: [ values add: aSequenceFlow ].
	nodeMemento write: values using: description
]

{ #category : 'private - topology' }
CPAtelierReconnectSequenceFlow >> stage: aSequenceFlow addedToOutgoingOf: aFlowNode [
	| nodeMemento description values |
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := aFlowNode outgoingDescription.
	values := (nodeMemento readUsing: description) copy.
	(values includes: aSequenceFlow) ifFalse: [ values add: aSequenceFlow ].
	nodeMemento write: values using: description
]

{ #category : 'private - topology' }
CPAtelierReconnectSequenceFlow >> stage: aSequenceFlow removedFromIncomingOf: aFlowNode [
	| nodeMemento description values |
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := aFlowNode incomingDescription.
	values := (nodeMemento readUsing: description) copy.
	values remove: aSequenceFlow ifAbsent: [ ].
	nodeMemento write: values using: description
]

{ #category : 'private - topology' }
CPAtelierReconnectSequenceFlow >> stage: aSequenceFlow removedFromOutgoingOf: aFlowNode [
	| nodeMemento description values |
	nodeMemento := processMemento childMementoFor: aFlowNode inRelation: flowElementsDescription.
	description := aFlowNode outgoingDescription.
	values := (nodeMemento readUsing: description) copy.
	values remove: aSequenceFlow ifAbsent: [ ].
	nodeMemento write: values using: description
]

{ #category : 'private - diagram' }
CPAtelierReconnectSequenceFlow >> stageEdgeEndpointsFrom: aSource to: aTarget [
	| diagram diagramMemento elementsDescription edges sourceShape targetShape edge edgeMemento waypointsDescription points |
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagram elementsDescription.
	edges := (diagramMemento readUsing: elementsDescription)
		select: [ :each | each isEdge and: [ each modelElement == sequenceFlow ] ].
	edges size = 1 ifFalse: [ ^ self ].
	sourceShape := (diagramMemento readUsing: elementsDescription)
		detect: [ :each | each isShape and: [ each modelElement == aSource ] ].
	targetShape := (diagramMemento readUsing: elementsDescription)
		detect: [ :each | each isShape and: [ each modelElement == aTarget ] ].
	edge := edges first.
	edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
	waypointsDescription := edge waypointsDescription.
	points := OrderedCollection
		with: sourceShape bounds center
		with: targetShape bounds center.
	edgeMemento write: points using: waypointsDescription
]
