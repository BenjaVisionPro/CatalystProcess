"I atomically transfer a closed selection of FlowNodes between staged Process/Sub-Process containers.

I include every SequenceFlow whose source and target are both in the selection. I reject the transfer when a SequenceFlow crosses the selection boundary because SequenceFlow cannot cross a flow-container boundary. The presentation supplies target-local shape bounds and target-local edge waypoints; I own semantic containment and the coordinated BPMN-DI write."
Class {
	#name : 'CPAtelierTransferFlowNodes',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNodes',
		'targetContainer',
		'proposedBoundsByFlowNode',
		'proposedWaypointsBySequenceFlow',
		'processMemento',
		'diagramDescription'
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

{ #category : 'assessing' }
CPAtelierTransferFlowNodes >> assess [
	| nodes nodeSet sourceContext targetContext sourceElements targetElements internalFlows boundaryFlows
	  proposedSource proposedTarget diagram diagramMemento elementsDescription elements shapesByNode edgesByFlow
	  stagedNodeState stagedFlowState |

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

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.

	shapesByNode := IdentityDictionary new.
	nodes do: [ :each |
		| shape shapeMemento boundsDescription proposed |
		shape := self
			shapeFor: each
			in: elements
			diagramMemento: diagramMemento
			elementsDescription: elementsDescription.
		shape ifNil: [ ^ self rejectedBecause: 'Every transferred FlowNode requires exactly one diagram shape.' ].
		shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
		boundsDescription := shapeMemento magritteDescription detect: [ :description | description handlesSelector: #bounds ].
		proposed := proposedBoundsByFlowNode at: each.
		[ boundsDescription validate: proposed ]
			on: MAValidationError
			do: [ :anException | ^ self rejectedBecause: anException printString ].
		shapesByNode at: each put: shape ].

	edgesByFlow := IdentityDictionary new.
	internalFlows do: [ :each |
		| edge edgeMemento waypointsDescription proposed |
		edge := self
			edgeFor: each
			in: elements
			diagramMemento: diagramMemento
			elementsDescription: elementsDescription.
		edge ifNil: [ ^ self rejectedBecause: 'Every transferred SequenceFlow requires exactly one diagram edge.' ].
		edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
		waypointsDescription := edgeMemento magritteDescription detect: [ :description | description handlesSelector: #waypoints ].
		proposed := proposedWaypointsBySequenceFlow at: each.
		[ waypointsDescription validate: proposed ]
			on: MAValidationError
			do: [ :anException | ^ self rejectedBecause: anException printString ].
		edgesByFlow at: each put: edge ].

	stagedNodeState := IdentityDictionary new.
	nodes do: [ :each |
		stagedNodeState at: each put: (self stagedStateForNode: each in: sourceContext) ].
	stagedFlowState := IdentityDictionary new.
	internalFlows do: [ :each |
		stagedFlowState at: each put: (self stagedStateForSequenceFlow: each in: sourceContext) ].

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
		stagedNodeState: stagedNodeState;
		stagedFlowState: stagedFlowState;
		yourself
]

{ #category : 'applying' }
CPAtelierTransferFlowNodes >> applyAssessment: anAssessment [
	| sourceContext targetContext diagram diagramMemento elementsDescription |
	sourceContext := CPProcessFlowContainerContext
		forContainer: anAssessment sourceContainer
		inRootMemento: processMemento.
	targetContext := CPProcessFlowContainerContext
		forContainer: anAssessment targetContainer
		inRootMemento: processMemento.

	sourceContext writeFlowElements: anAssessment proposedSourceFlowElements.
	targetContext writeFlowElements: anAssessment proposedTargetFlowElements.

	anAssessment flowNodes do: [ :each |
		self
			restoreNode: each
			state: (anAssessment stagedNodeState at: each)
			in: targetContext
			targetContainer: anAssessment targetContainer ].
	anAssessment sequenceFlows do: [ :each |
		self
			restoreSequenceFlow: each
			state: (anAssessment stagedFlowState at: each)
			in: targetContext
			targetContainer: anAssessment targetContainer ].

	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	anAssessment shapesByFlowNode keysAndValuesDo: [ :aFlowNode :aShape |
		| shapeMemento boundsDescription |
		shapeMemento := diagramMemento childMementoFor: aShape inRelation: elementsDescription.
		boundsDescription := shapeMemento magritteDescription
			detect: [ :each | each handlesSelector: #bounds ].
		shapeMemento
			write: (anAssessment proposedBoundsByFlowNode at: aFlowNode)
			using: boundsDescription ].
	anAssessment edgesBySequenceFlow keysAndValuesDo: [ :aSequenceFlow :anEdge |
		| edgeMemento waypointsDescription |
		edgeMemento := diagramMemento childMementoFor: anEdge inRelation: elementsDescription.
		waypointsDescription := edgeMemento magritteDescription
			detect: [ :each | each handlesSelector: #waypoints ].
		edgeMemento
			write: (anAssessment proposedWaypointsBySequenceFlow at: aSequenceFlow)
			using: waypointsDescription ].

	anAssessment flowNodes do: [ :each | sourceContext detachChildMementoFor: each ].
	anAssessment sequenceFlows do: [ :each | sourceContext detachChildMementoFor: each ]
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> stagedSourceOf: aSequenceFlow in: aContext [
	| memento description |
	memento := aContext childMementoFor: aSequenceFlow.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	^ memento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> stagedTargetOf: aSequenceFlow in: aContext [
	| memento description |
	memento := aContext childMementoFor: aSequenceFlow.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	^ memento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> stagedStateForNode: aFlowNode in: aContext [
	| memento state |
	memento := aContext childMementoFor: aFlowNode.
	state := Dictionary new.
	self copySelector: #label from: memento into: state.
	self copySelector: #incoming from: memento into: state.
	self copySelector: #outgoing from: memento into: state.
	aFlowNode isCallActivity ifTrue: [
		self copySelector: #calledElement from: memento into: state ].
	aFlowNode isSubProcess ifTrue: [
		self copySelector: #flowElements from: memento into: state ].
	^ state
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> stagedStateForSequenceFlow: aSequenceFlow in: aContext [
	| memento state |
	memento := aContext childMementoFor: aSequenceFlow.
	state := Dictionary new.
	self copySelector: #label from: memento into: state.
	self copySelector: #sourceRef from: memento into: state.
	self copySelector: #targetRef from: memento into: state.
	^ state
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> copySelector: aSelector from: aMemento into: aDictionary [
	| description |
	description := aMemento magritteDescription
		detect: [ :each | each handlesSelector: aSelector ].
	aDictionary at: aSelector put: (aMemento readUsing: description)
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> restoreNode: aFlowNode state: state in: aContext targetContainer: aTargetContainer [
	| memento |
	memento := aContext childMementoFor: aFlowNode.
	self writeSelector: #label value: (state at: #label) to: memento.
	self writeSelector: #container value: aTargetContainer to: memento.
	self writeSelector: #incoming value: (state at: #incoming) to: memento.
	self writeSelector: #outgoing value: (state at: #outgoing) to: memento.
	aFlowNode isCallActivity ifTrue: [
		self writeSelector: #calledElement value: (state at: #calledElement) to: memento ].
	aFlowNode isSubProcess ifTrue: [
		self writeSelector: #flowElements value: (state at: #flowElements) to: memento ]
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> restoreSequenceFlow: aSequenceFlow state: state in: aContext targetContainer: aTargetContainer [
	| memento |
	memento := aContext childMementoFor: aSequenceFlow.
	self writeSelector: #label value: (state at: #label) to: memento.
	self writeSelector: #container value: aTargetContainer to: memento.
	self writeSelector: #sourceRef value: (state at: #sourceRef) to: memento.
	self writeSelector: #targetRef value: (state at: #targetRef) to: memento
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNodes >> writeSelector: aSelector value: aValue to: aMemento [
	| description |
	description := aMemento magritteDescription
		detect: [ :each | each handlesSelector: aSelector ].
	aMemento write: aValue using: description
]

{ #category : 'private - diagram' }
CPAtelierTransferFlowNodes >> shapeFor: aFlowNode in: elements diagramMemento: diagramMemento elementsDescription: elementsDescription [
	| matches |
	matches := elements select: [ :each |
		each isShape and: [
			(self stagedModelElementOf: each in: diagramMemento elementsDescription: elementsDescription) == aFlowNode ] ].
	^ matches size = 1 ifTrue: [ matches first ] ifFalse: [ nil ]
]

{ #category : 'private - diagram' }
CPAtelierTransferFlowNodes >> edgeFor: aSequenceFlow in: elements diagramMemento: diagramMemento elementsDescription: elementsDescription [
	| matches |
	matches := elements select: [ :each |
		each isEdge and: [
			(self stagedModelElementOf: each in: diagramMemento elementsDescription: elementsDescription) == aSequenceFlow ] ].
	^ matches size = 1 ifTrue: [ matches first ] ifFalse: [ nil ]
]

{ #category : 'private - diagram' }
CPAtelierTransferFlowNodes >> stagedModelElementOf: aDiagramElement in: diagramMemento elementsDescription: elementsDescription [
	| memento description |
	memento := diagramMemento childMementoFor: aDiagramElement inRelation: elementsDescription.
	description := memento magritteDescription detect: [ :each | each handlesSelector: #modelElement ].
	^ memento readUsing: description
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
