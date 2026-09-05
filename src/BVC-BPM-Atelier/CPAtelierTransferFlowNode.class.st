"I transfer one existing flow node between staged Process/Sub-Process flow containers and move its CPShape atomically.

A single-node transfer is applicable only when the node has no staged incoming or outgoing Sequence Flows. Existing Sequence Flows cannot cross a flow-container boundary; moving connected topology requires an explicit topology-transfer intention."
Class {
	#name : 'CPAtelierTransferFlowNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNode',
		'targetContainer',
		'proposedBounds',
		'processMemento',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierTransferFlowNode class >> flowNode: aFlowNode targetContainer: aTargetContainer bounds: aRectangle processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new
		flowNode: aFlowNode;
		targetContainer: aTargetContainer;
		proposedBounds: aRectangle;
		processMemento: aMemento;
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierTransferFlowNode >> assess [
	| sourceContext targetContext sourceElements targetElements sourceMemento
	  incomingDescription outgoingDescription incoming outgoing labelDescription stagedLabel
	  nestedElements diagram diagramMemento elementsDescription elements shape shapeMemento
	  boundsDescription currentBounds proposedSource proposedTarget |

	flowNode ifNil: [ ^ self rejectedBecause: 'A flow node is required.' ].
	targetContainer ifNil: [ ^ self rejectedBecause: 'A target flow container is required.' ].
	proposedBounds ifNil: [ ^ self rejectedBecause: 'Proposed diagram bounds are required.' ].

	sourceContext := CPProcessFlowContainerContext containingFlowElement: flowNode inRootMemento: processMemento.
	sourceContext ifNil: [ ^ self rejectedBecause: 'The flow node is not present in staged flow-container state.' ].
	targetContext := CPProcessFlowContainerContext forContainer: targetContainer inRootMemento: processMemento.
	targetContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	sourceContext container == targetContext container ifTrue: [
		^ self rejectedBecause: 'The flow node already belongs to the target flow container.' ].
	flowNode == targetContainer ifTrue: [
		^ self rejectedBecause: 'A Sub-Process cannot contain itself.' ].
	flowNode isSubProcess ifTrue: [
		| childContext |
		childContext := sourceContext childContextForSubProcess: flowNode.
		(childContext contextForContainer: targetContainer) ifNotNil: [
			^ self rejectedBecause: 'A Sub-Process cannot be moved into one of its descendants.' ] ].

	sourceElements := sourceContext stagedFlowElements.
	targetElements := targetContext stagedFlowElements.
	(sourceElements identityIncludes: flowNode) ifFalse: [
		^ self rejectedBecause: 'The source flow container does not contain the flow node.' ].
	(targetElements identityIncludes: flowNode) ifTrue: [
		^ self rejectedBecause: 'The target flow container already contains the flow node.' ].

	sourceMemento := sourceContext childMementoFor: flowNode.
	incomingDescription := sourceMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	outgoingDescription := sourceMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	incoming := sourceMemento readUsing: incomingDescription.
	outgoing := sourceMemento readUsing: outgoingDescription.
	(incoming isEmpty and: [ outgoing isEmpty ]) ifFalse: [
		^ self rejectedBecause: 'A connected flow node requires topology transfer with its Sequence Flows.' ].

	labelDescription := sourceMemento magritteDescription detect: [ :each | each handlesSelector: #label ].
	stagedLabel := sourceMemento readUsing: labelDescription.
	nestedElements := flowNode isSubProcess
		ifTrue: [
			| description |
			description := sourceMemento magritteDescription detect: [ :each | each handlesSelector: #flowElements ].
			sourceMemento readUsing: description ]
		ifFalse: [ nil ].

	proposedSource := sourceElements asOrderedCollection copy.
	proposedSource remove: flowNode ifAbsent: [
		^ self rejectedBecause: 'The source flow container does not contain the flow node.' ].
	proposedTarget := targetElements asOrderedCollection copy.
	proposedTarget add: flowNode.
	[
		sourceContext flowElementsDescription validate: proposedSource.
		targetContext flowElementsDescription validate: proposedTarget
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	shape := self shapeFor: flowNode in: elements diagramMemento: diagramMemento elementsDescription: elementsDescription.
	shape ifNil: [ ^ self rejectedBecause: 'The transferred flow node requires exactly one diagram shape.' ].
	shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
	boundsDescription := shapeMemento magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	currentBounds := shapeMemento readUsing: boundsDescription.
	[ boundsDescription validate: proposedBounds ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierTransferFlowNodeAssessment
		flowNode: flowNode
		shape: shape
		sourceContainer: sourceContext container
		targetContainer: targetContext container
		proposedSourceFlowElements: proposedSource
		proposedTargetFlowElements: proposedTarget
		currentBounds: currentBounds
		proposedBounds: proposedBounds
		stagedLabel: stagedLabel
		stagedNestedFlowElements: nestedElements
]

{ #category : 'applying' }
CPAtelierTransferFlowNode >> applyAssessment: anAssessment [
	| sourceContext targetContext targetMemento labelDescription containerDescription
	  incomingDescription outgoingDescription diagram diagramMemento elementsDescription
	  shapeMemento boundsDescription |

	sourceContext := CPProcessFlowContainerContext forContainer: anAssessment sourceContainer inRootMemento: processMemento.
	targetContext := CPProcessFlowContainerContext forContainer: anAssessment targetContainer inRootMemento: processMemento.
	sourceContext writeFlowElements: anAssessment proposedSourceFlowElements.
	targetContext writeFlowElements: anAssessment proposedTargetFlowElements.

	targetMemento := targetContext childMementoFor: flowNode.
	labelDescription := targetMemento magritteDescription detect: [ :each | each handlesSelector: #label ].
	containerDescription := targetMemento magritteDescription detect: [ :each | each handlesSelector: #container ].
	incomingDescription := targetMemento magritteDescription detect: [ :each | each handlesSelector: #incoming ].
	outgoingDescription := targetMemento magritteDescription detect: [ :each | each handlesSelector: #outgoing ].
	targetMemento write: anAssessment stagedLabel using: labelDescription.
	targetMemento write: anAssessment targetContainer using: containerDescription.
	targetMemento write: OrderedCollection new using: incomingDescription.
	targetMemento write: OrderedCollection new using: outgoingDescription.
	anAssessment stagedNestedFlowElements ifNotNil: [ :nested |
		| nestedDescription |
		nestedDescription := targetMemento magritteDescription detect: [ :each | each handlesSelector: #flowElements ].
		targetMemento write: nested using: nestedDescription ].

	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription detect: [ :each | each handlesSelector: #elements ].
	shapeMemento := diagramMemento childMementoFor: anAssessment shape inRelation: elementsDescription.
	boundsDescription := shapeMemento magritteDescription detect: [ :each | each handlesSelector: #bounds ].
	shapeMemento write: anAssessment proposedBounds using: boundsDescription
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNode >> shapeFor: aFlowNode in: elements diagramMemento: diagramMemento elementsDescription: elementsDescription [
	| matches |
	matches := elements select: [ :each |
		each isShape and: [
			(self stagedModelElementOf: each in: diagramMemento elementsDescription: elementsDescription) == aFlowNode ] ].
	^ matches size = 1 ifTrue: [ matches first ] ifFalse: [ nil ]
]

{ #category : 'private - staged state' }
CPAtelierTransferFlowNode >> stagedModelElementOf: aShape in: diagramMemento elementsDescription: elementsDescription [
	| shapeMemento description |
	shapeMemento := diagramMemento childMementoFor: aShape inRelation: elementsDescription.
	description := shapeMemento magritteDescription detect: [ :each | each handlesSelector: #modelElement ].
	^ shapeMemento readUsing: description
]

{ #category : 'private' }
CPAtelierTransferFlowNode >> rejectedBecause: aString [
	^ CPAtelierTransferFlowNodeAssessment flowNode: flowNode rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierTransferFlowNode >> flowNode: anObject [ flowNode := anObject ]
{ #category : 'accessing' }
CPAtelierTransferFlowNode >> targetContainer: anObject [ targetContainer := anObject ]
{ #category : 'accessing' }
CPAtelierTransferFlowNode >> proposedBounds: aRectangle [ proposedBounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierTransferFlowNode >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierTransferFlowNode >> diagramDescription: aDescription [ diagramDescription := aDescription ]
