"I stage replacement of one CPFlowNode with another while preserving the existing diagram shape and every incident Sequence Flow and diagram edge identity.

Assessment resolves the currently staged topology, substitutes the replacement node into every incident connection, and delegates connection legality to CPSequenceFlowConnectionRules. Apply replaces the semantic node in the owning flow container's flowElements, stages the replacement node's inverse incoming/outgoing relations, retargets the existing CPSequenceFlow child mementos, reattaches any Boundary Events owned by the replaced Activity, and stages the existing CPShape>>modelElement relation to the replacement node."
Class {
	#name : 'CPAtelierReplaceFlowNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNode',
		'replacementNode',
		'bounds',
		'processMemento',
		'flowContainerContext',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReplaceFlowNode class >> flowNode: aFlowNode with: aReplacementNode bounds: aRectangle processMemento: aMemento flowElementsDescription: aFlowElementsDescription diagramContext: aDiagramContext [
	^ self new
		flowNode: aFlowNode;
		replacementNode: aReplacementNode;
		bounds: aRectangle;
		processMemento: aMemento;
		flowContainerContext: (CPProcessFlowContainerContext container: aMemento model memento: aMemento flowElementsDescription: aFlowElementsDescription);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReplaceFlowNode class >> flowNode: aFlowNode with: aReplacementNode bounds: aRectangle flowContainer: aContainer processMemento: aMemento diagramContext: aDiagramContext [
	^ self new flowNode: aFlowNode; replacementNode: aReplacementNode; bounds: aRectangle; processMemento: aMemento; flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento); diagramContext: aDiagramContext; yourself
]

{ #category : 'assessing' }
CPAtelierReplaceFlowNode >> assess [
	| flowElements proposedFlowElements incidentFlows attachedBoundaryEvents diagram
	  elements shape shapeMemento modelElementDescription boundsDescription diagramContext |

	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	flowNode ifNil: [ ^ self rejectedBecause: 'A flow node is required.' ].
	replacementNode ifNil: [ ^ self rejectedBecause: 'A replacement flow node is required.' ].
	flowNode == replacementNode ifTrue: [
		^ self rejectedBecause: 'Replacement requires a different flow-node identity.' ].
	flowNode class = replacementNode class ifTrue: [
		^ self rejectedBecause: 'Replacement requires a different flow-node type.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Replacement diagram bounds are required.' ].

	flowElements := flowContainerContext stagedFlowElements.
	flowElements ifNil: [
		^ self rejectedBecause: 'The process has no staged flow-elements collection.' ].
	(flowElements identityIncludes: flowNode) ifFalse: [
		^ self rejectedBecause: 'The replaced flow node does not belong to the staged process.' ].
	(flowElements identityIncludes: replacementNode) ifTrue: [
		^ self rejectedBecause: 'The replacement flow node already belongs to the staged process.' ].

	proposedFlowElements := flowElements species withAll:
		(flowElements collect: [ :each |
			each == flowNode
				ifTrue: [ replacementNode ]
				ifFalse: [ each ] ]).
	[
		flowContainerContext flowElementsDescription validate: proposedFlowElements
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].

	incidentFlows := flowElements select: [ :each |
		each isSequenceFlow and: [
			(self stagedSourceOf: each) == flowNode
				or: [ (self stagedTargetOf: each) == flowNode ] ] ].

	attachedBoundaryEvents := flowNode isActivity
		ifTrue: [ flowContainerContext attachedBoundaryEventsFor: flowNode ]
		ifFalse: [ #() ].
	(attachedBoundaryEvents isNotEmpty and: [ replacementNode isActivity not ]) ifTrue: [
		^ self rejectedBecause: 'An Activity with attached Boundary Events can only be replaced by another Activity.' ].

	incidentFlows do: [ :aSequenceFlow |
		| proposedSource proposedTarget topology ruleResult sourceDescription targetDescription |
		proposedSource := (self stagedSourceOf: aSequenceFlow) == flowNode
			ifTrue: [ replacementNode ]
			ifFalse: [ self stagedSourceOf: aSequenceFlow ].
		proposedTarget := (self stagedTargetOf: aSequenceFlow) == flowNode
			ifTrue: [ replacementNode ]
			ifFalse: [ self stagedTargetOf: aSequenceFlow ].

		topology := self
			proposedTopologyFrom: flowElements
			excludingSequenceFlow: aSequenceFlow.
		ruleResult := CPSequenceFlowConnectionRules new
			assessConnectionFrom: proposedSource
			to: proposedTarget
			in: topology.
		ruleResult isAllowed ifFalse: [
			^ self rejectedBecause: ruleResult message ].

		sourceDescription := aSequenceFlow magritteDescription
			detect: [ :each | each handlesSelector: #sourceRef ].
		targetDescription := aSequenceFlow magritteDescription
			detect: [ :each | each handlesSelector: #targetRef ].
		[
			sourceDescription validate: proposedSource.
			targetDescription validate: proposedTarget
		] on: MAValidationError do: [ :anException |
			^ self rejectedBecause: anException printString ] ].

	diagramContext := self stagedDiagramContext.
	diagram := diagramContext diagram.
	diagram ifNil: [
		^ self rejectedBecause: 'The process has no staged diagram.' ].
	elements := diagramContext elements.
	elements ifNil: [
		^ self rejectedBecause: 'The diagram has no staged elements collection.' ].

	shape := diagramContext shapeForModelElement: flowNode.
	shape ifNil: [
		^ self rejectedBecause: 'The replaced flow node requires exactly one staged diagram shape.' ].
	shapeMemento := diagramContext mementoFor: shape.
	modelElementDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	[
		modelElementDescription validate: replacementNode.
		boundsDescription validate: bounds
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].

	^ CPAtelierReplaceFlowNodeAssessment
		flowNode: flowNode
		replacementNode: replacementNode
		incidentSequenceFlows: incidentFlows
		attachedBoundaryEvents: attachedBoundaryEvents
		shape: shape
		proposedBounds: bounds
		proposedFlowElements: proposedFlowElements
]

{ #category : 'applying' }
CPAtelierReplaceFlowNode >> applyAssessment: anAssessment [
	| incoming outgoing preservedLabel preservedNestedFlowElements diagram shapeMemento modelElementDescription boundsDescription replacementMemento incomingDescription outgoingDescription labelDescription diagramContext |

	incoming := OrderedCollection new.
	outgoing := OrderedCollection new.
	preservedLabel := self stagedLabelOf: flowNode.
	preservedNestedFlowElements := self stagedNestedFlowElementsOf: flowNode.
	anAssessment incidentSequenceFlows do: [ :aSequenceFlow |
		| currentSource currentTarget flowMemento sourceDescription targetDescription |
		currentSource := self stagedSourceOf: aSequenceFlow.
		currentTarget := self stagedTargetOf: aSequenceFlow.
		flowMemento := flowContainerContext childMementoFor: aSequenceFlow.
		sourceDescription := flowMemento magritteDescription
			detect: [ :each | each handlesSelector: #sourceRef ].
		targetDescription := flowMemento magritteDescription
			detect: [ :each | each handlesSelector: #targetRef ].

		currentSource == flowNode ifTrue: [
			flowMemento write: replacementNode using: sourceDescription.
			outgoing add: aSequenceFlow ].
		currentTarget == flowNode ifTrue: [
			flowMemento write: replacementNode using: targetDescription.
			incoming add: aSequenceFlow ] ].

	flowContainerContext writeFlowElements: anAssessment proposedFlowElements.
	replacementMemento := flowContainerContext childMementoFor: replacementNode.
	incomingDescription := replacementMemento magritteDescription
		detect: [ :each | each handlesSelector: #incoming ].
	outgoingDescription := replacementMemento magritteDescription
		detect: [ :each | each handlesSelector: #outgoing ].
	labelDescription := replacementMemento magritteDescription
		detect: [ :each | each handlesSelector: #label ].
	replacementMemento write: preservedLabel using: labelDescription.
	replacementMemento write: incoming using: incomingDescription.
	replacementMemento write: outgoing using: outgoingDescription.
	anAssessment attachedBoundaryEvents do: [ :aBoundaryEvent |
		| boundaryMemento attachedDescription |
		boundaryMemento := flowContainerContext childMementoFor: aBoundaryEvent.
		attachedDescription := boundaryMemento magritteDescription
			detect: [ :each | each handlesSelector: #attachedToRef ].
		boundaryMemento write: replacementNode using: attachedDescription ].
	preservedNestedFlowElements ifNotNil: [
		| nestedDescription |
		nestedDescription := replacementMemento magritteDescription
			detect: [ :each | each handlesSelector: #flowElements ].
		replacementMemento write: preservedNestedFlowElements using: nestedDescription ].

	diagramContext := self stagedDiagramContext.
	shapeMemento := diagramContext mementoFor: anAssessment shape.
	modelElementDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	shapeMemento write: replacementNode using: modelElementDescription.
	shapeMemento write: anAssessment proposedBounds using: boundsDescription.

	flowContainerContext detachChildMementoFor: flowNode.
	flowContainerContext childMementoFor: replacementNode
]

{ #category : 'private - staged topology' }
CPAtelierReplaceFlowNode >> proposedTopologyFrom: flowElements excludingSequenceFlow: excludedSequenceFlow [
	| topology |
	topology := CPProcessTopology new.
	flowElements do: [ :each |
		each isSequenceFlow ifFalse: [
			each == flowNode
				ifTrue: [ topology addFlowElement: replacementNode ]
				ifFalse: [ topology addFlowElement: each ] ] ].
	flowElements do: [ :each |
		(each isSequenceFlow and: [ each ~~ excludedSequenceFlow ]) ifTrue: [
			| source target |
			source := self stagedSourceOf: each.
			target := self stagedTargetOf: each.
			source == flowNode ifTrue: [ source := replacementNode ].
			target == flowNode ifTrue: [ target := replacementNode ].
			topology addSequenceFlow: each source: source target: target ] ].
	^ topology
]

{ #category : 'private - staged state' }
CPAtelierReplaceFlowNode >> stagedLabelOf: aFlowNode [
	| nodeMemento description |
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription
		detect: [ :each | each handlesSelector: #label ].
	^ nodeMemento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierReplaceFlowNode >> stagedSourceOf: aSequenceFlow [
	^ flowContainerContext stagedSourceOf: aSequenceFlow
]

{ #category : 'private - staged state' }
CPAtelierReplaceFlowNode >> stagedTargetOf: aSequenceFlow [
	^ flowContainerContext stagedTargetOf: aSequenceFlow
]


{ #category : 'private' }
CPAtelierReplaceFlowNode >> rejectedBecause: aString [
	^ CPAtelierReplaceFlowNodeAssessment
		flowNode: flowNode
		replacementNode: replacementNode
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierReplaceFlowNode >> flowNode: anObject [ flowNode := anObject ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNode >> replacementNode: anObject [ replacementNode := anObject ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNode >> processMemento: aMemento [ processMemento := aMemento ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNode >> flowContainerContext: aContext [ flowContainerContext := aContext ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNode >> bounds: aRectangle [ bounds := aRectangle ]

{ #category : 'private - staged state' }
CPAtelierReplaceFlowNode >> stagedNestedFlowElementsOf: aFlowNode [
	| nodeMemento description |
	aFlowNode isSubProcess ifFalse: [ ^ nil ].
	nodeMemento := flowContainerContext childMementoFor: aFlowNode.
	description := nodeMemento magritteDescription
		detect: [ :each | each handlesSelector: #flowElements ].
	^ nodeMemento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierReplaceFlowNode >> stagedDiagramContext [
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierReplaceFlowNode >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
