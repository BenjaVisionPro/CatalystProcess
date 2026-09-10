"I atomically transfer a closed selection of FlowNodes between staged Process/Sub-Process containers.

I include every SequenceFlow whose source and target are both in the selection. I reject the transfer when a SequenceFlow crosses the selection boundary because SequenceFlow cannot cross a flow-container boundary. The presentation supplies the proposed shape bounds and edge waypoints for this depiction; I own semantic containment and the coordinated BPMN-DI write."
Class {
	#name : 'CPAtelierTransferFlowNodes',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNodes',
		'targetContainer',
		'proposedBoundsByFlowNode',
		'proposedWaypointsBySequenceFlow',
		'processMemento',
		'diagramDescription',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierTransferFlowNodes class >> flowNodes: someFlowNodes targetContainer: aTargetContainer boundsByFlowNode: boundsByFlowNode waypointsBySequenceFlow: waypointsBySequenceFlow processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new
		flowNodes: someFlowNodes;
		targetContainer: aTargetContainer;
		proposedBoundsByFlowNode: boundsByFlowNode;
		proposedWaypointsBySequenceFlow: waypointsBySequenceFlow;
		processMemento: aMemento;
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'instance creation' }
CPAtelierTransferFlowNodes class >> flowNodes: someFlowNodes targetContainer: aTargetContainer boundsByFlowNode: boundsByFlowNode waypointsBySequenceFlow: waypointsBySequenceFlow processMemento: aMemento diagramContext: aDiagramContext [
	^ self new flowNodes: someFlowNodes; targetContainer: aTargetContainer; boundsByFlowNode: boundsByFlowNode; waypointsBySequenceFlow: waypointsBySequenceFlow; processMemento: aMemento; diagramContext: aDiagramContext; yourself
]

{ #category : 'assessing' }
CPAtelierTransferFlowNodes >> assess [
	| nodes nodeSet sourceContext targetContext sourceElements targetElements internalFlows boundaryFlows
	  proposedSource proposedTarget diagram elements shapesByNode edgesByFlow
	  diagramContext |

	flowNodes ifNil: [ ^ self rejectedBecause: 'At least one flow node is required.' ].
	nodes := flowNodes asOrderedCollection.
	nodes ifEmpty: [ ^ self rejectedBecause: 'At least one flow node is required.' ].
	(nodes allSatisfy: [ :each | each isSequenceFlow not ]) ifFalse: [
		^ self rejectedBecause: 'Only FlowNodes can be transferred directly.' ].
	targetContainer ifNil: [ ^ self rejectedBecause: 'A target flow container is required.' ].
	proposedBoundsByFlowNode ifNil: [ ^ self rejectedBecause: 'Proposed node bounds are required.' ].
	proposedWaypointsBySequenceFlow ifNil: [ ^ self rejectedBecause: 'Proposed SequenceFlow waypoints are required.' ].

	sourceContext := CPProcessFlowContainerContext
		containingFlowElement: nodes first
		inRootMemento: processMemento.
	sourceContext ifNil: [ ^ self rejectedBecause: 'The selection is not present in staged flow-container state.' ].
	(nodes allSatisfy: [ :each |
		| eachContext |
		eachContext := CPProcessFlowContainerContext
			containingFlowElement: each
			inRootMemento: processMemento.
		eachContext notNil and: [
			eachContext container == sourceContext container ] ]) ifFalse: [
		^ self rejectedBecause: 'All transferred FlowNodes must belong to the same source flow container.' ].

	targetContext := CPProcessFlowContainerContext
		forContainer: targetContainer
		inRootMemento: processMemento.
	targetContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	sourceContext container == targetContext container ifTrue: [
		^ self rejectedBecause: 'The selection already belongs to the target flow container.' ].

	nodes do: [ :each |
		each == targetContainer ifTrue: [
			^ self rejectedBecause: 'A Sub-Process cannot contain itself.' ].
		each isSubProcess ifTrue: [
			| childContext |
			childContext := sourceContext childContextForSubProcess: each.
			(childContext contextForContainer: targetContainer) ifNotNil: [
				^ self rejectedBecause: 'A Sub-Process cannot be moved into one of its descendants.' ] ] ].

	sourceElements := sourceContext stagedFlowElements.
	targetElements := targetContext stagedFlowElements.
	(nodes allSatisfy: [ :each | sourceElements identityIncludes: each ]) ifFalse: [
		^ self rejectedBecause: 'Every transferred FlowNode must be directly owned by the source flow container.' ].
	(nodes anySatisfy: [ :each | targetElements identityIncludes: each ]) ifTrue: [
		^ self rejectedBecause: 'The target flow container already contains a transferred FlowNode.' ].

	nodeSet := IdentitySet new.
	nodes do: [ :each | nodeSet add: each ].
	internalFlows := sourceElements select: [ :each |
		each isSequenceFlow and: [
			(nodeSet includes: (self stagedSourceOf: each in: sourceContext))
				and: [ nodeSet includes: (self stagedTargetOf: each in: sourceContext) ] ] ].
	boundaryFlows := sourceElements select: [ :each |
		each isSequenceFlow and: [
			(nodeSet includes: (self stagedSourceOf: each in: sourceContext))
				~= (nodeSet includes: (self stagedTargetOf: each in: sourceContext)) ] ].
	boundaryFlows ifNotEmpty: [
		^ self rejectedBecause: 'The selection has SequenceFlows crossing its transfer boundary.' ].

	(proposedBoundsByFlowNode keys allSatisfy: [ :each | nodeSet includes: each ]) ifFalse: [
		^ self rejectedBecause: 'Proposed bounds contain a FlowNode outside the transfer selection.' ].
	(nodes allSatisfy: [ :each | proposedBoundsByFlowNode includesKey: each ]) ifFalse: [
		^ self rejectedBecause: 'Every transferred FlowNode requires proposed bounds.' ].
	(internalFlows allSatisfy: [ :each | proposedWaypointsBySequenceFlow includesKey: each ]) ifFalse: [
		^ self rejectedBecause: 'Every transferred SequenceFlow requires proposed waypoints.' ].

	proposedSource := sourceElements asOrderedCollection copy.
	nodes do: [ :each | proposedSource remove: each ].
	internalFlows do: [ :each | proposedSource remove: each ].
	proposedTarget := targetElements asOrderedCollection copy.
	nodes do: [ :each | proposedTarget add: each ].
	internalFlows do: [ :each | proposedTarget add: each ].
	[
		sourceContext flowElementsDescription validate: proposedSource.
		targetContext flowElementsDescription validate: proposedTarget
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].

	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	elements := diagramContext elements.

	shapesByNode := IdentityDictionary new.
	nodes do: [ :each |
		| shape shapeMemento boundsDescription proposed |
		shape := diagramContext shapeForModelElement: each.
		shape ifNil: [ ^ self rejectedBecause: 'Every transferred FlowNode requires exactly one diagram shape.' ].
		shapeMemento := diagramContext mementoFor: shape.
		boundsDescription := shapeMemento magritteDescription detect: [ :description | description handlesSelector: #bounds ].
		proposed := proposedBoundsByFlowNode at: each.
		[ boundsDescription validate: proposed ]
			on: MAValidationError
			do: [ :anException | ^ self rejectedBecause: anException printString ].
		shapesByNode at: each put: shape ].

	edgesByFlow := IdentityDictionary new.
	internalFlows do: [ :each |
		| edge edgeMemento waypointsDescription proposed |
		edge := diagramContext edgeForModelElement: each.
		edge ifNil: [ ^ self rejectedBecause: 'Every transferred SequenceFlow requires exactly one diagram edge.' ].
		edgeMemento := diagramContext mementoFor: edge.
		waypointsDescription := edgeMemento magritteDescription detect: [ :description | description handlesSelector: #waypoints ].
		proposed := proposedWaypointsBySequenceFlow at: each.
		[ waypointsDescription validate: proposed ]
			on: MAValidationError
			do: [ :anException | ^ self rejectedBecause: anException printString ].
		edgesByFlow at: each put: edge ].

	^ CPAtelierTransferFlowNodesAssessment new
		flowNodes: nodes;
		sequenceFlows: internalFlows;
		sourceContainer: sourceContext container;
		targetContainer: targetContext container;
		proposedSourceFlowElements: proposedSource;
		proposedTargetFlowElements: proposedTarget;
		shapesByFlowNode: shapesByNode;
		edgesBySequenceFlow: edgesByFlow;
		proposedBoundsByFlowNode: proposedBoundsByFlowNode;
		proposedWaypointsBySequenceFlow: proposedWaypointsBySequenceFlow;
		yourself
]

{ #category : 'applying' }
CPAtelierTransferFlowNodes >> applyAssessment: anAssessment [
	| sourceContext targetContext diagram diagramContext |
	sourceContext := CPProcessFlowContainerContext
		forContainer: anAssessment sourceContainer
		inRootMemento: processMemento.
	targetContext := CPProcessFlowContainerContext
		forContainer: anAssessment targetContainer
		inRootMemento: processMemento.

	(anAssessment flowNodes, anAssessment sequenceFlows) do: [ :each |
		sourceContext transferChildMementoFor: each to: targetContext inRootMemento: processMemento ].
	sourceContext writeFlowElements: anAssessment proposedSourceFlowElements.
	targetContext writeFlowElements: anAssessment proposedTargetFlowElements.

	diagramContext := self stagedDiagramContext.
	anAssessment shapesByFlowNode keysAndValuesDo: [ :aFlowNode :aShape |
		| shapeMemento boundsDescription |
		shapeMemento := diagramContext mementoFor: aShape.
		boundsDescription := shapeMemento magritteDescription
			detect: [ :each | each handlesSelector: #bounds ].
		shapeMemento
			write: (anAssessment proposedBoundsByFlowNode at: aFlowNode)
			using: boundsDescription ].
	anAssessment edgesBySequenceFlow keysAndValuesDo: [ :aSequenceFlow :anEdge |
		| edgeMemento waypointsDescription |
		edgeMemento := diagramContext mementoFor: anEdge.
		waypointsDescription := edgeMemento magritteDescription
			detect: [ :each | each handlesSelector: #waypoints ].
		edgeMemento
			write: (anAssessment proposedWaypointsBySequenceFlow at: aSequenceFlow)
			using: waypointsDescription ]
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> stagedSourceOf: aSequenceFlow in: aContext [
	^ aContext stagedSourceOf: aSequenceFlow
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> stagedTargetOf: aSequenceFlow in: aContext [
	^ aContext stagedTargetOf: aSequenceFlow
]





{ #category : 'private' }
CPAtelierTransferFlowNodes >> rejectedBecause: aString [
	^ CPAtelierTransferFlowNodesAssessment
		flowNodes: flowNodes
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierTransferFlowNodes >> flowNodes: aCollection [ flowNodes := aCollection ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodes >> targetContainer: anObject [ targetContainer := anObject ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodes >> proposedBoundsByFlowNode: aDictionary [ proposedBoundsByFlowNode := aDictionary ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodes >> proposedWaypointsBySequenceFlow: aDictionary [ proposedWaypointsBySequenceFlow := aDictionary ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodes >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodes >> diagramDescription: aDescription [ diagramDescription := aDescription ]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> stagedDiagramContext [
	diagramContext ifNotNil: [ ^ diagramContext ].
	diagramContext := CPDiagramMementoContext
		diagram: (processMemento readUsing: diagramDescription)
		inMemento: processMemento
		using: diagramDescription.
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierTransferFlowNodes >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
