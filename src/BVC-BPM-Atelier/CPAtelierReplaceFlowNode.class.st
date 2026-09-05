"I stage replacement of one CPFlowNode with another while preserving the existing diagram shape and every incident Sequence Flow and diagram edge identity.

Assessment resolves the currently staged topology, substitutes the replacement node into every incident connection, and delegates connection legality to CPSequenceFlowConnectionRules. Apply replaces the semantic node in CPProcess>>flowElements, stages the replacement node's inverse incoming/outgoing relations, retargets the existing CPSequenceFlow child mementos, and stages the existing CPShape>>modelElement relation to the replacement node."
Class {
	#name : 'CPAtelierReplaceFlowNode',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'flowNode',
		'replacementNode',
		'bounds',
		'processMemento',
		'flowElementsDescription',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReplaceFlowNode class >> flowNode: aFlowNode with: aReplacementNode bounds: aRectangle processMemento: aMemento flowElementsDescription: aFlowElementsDescription diagramDescription: aDiagramDescription [
	^ self new
		flowNode: aFlowNode;
		replacementNode: aReplacementNode;
		bounds: aRectangle;
		processMemento: aMemento;
		flowElementsDescription: aFlowElementsDescription;
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierReplaceFlowNode >> assess [
	| flowElements proposedFlowElements incidentFlows diagram diagramMemento
	  elementsDescription elements shapeMatches shape modelElementDescription boundsDescription |

	flowNode ifNil: [ ^ self rejectedBecause: 'A flow node is required.' ].
	replacementNode ifNil: [ ^ self rejectedBecause: 'A replacement flow node is required.' ].
	flowNode == replacementNode ifTrue: [
		^ self rejectedBecause: 'Replacement requires a different flow-node identity.' ].
	flowNode class = replacementNode class ifTrue: [
		^ self rejectedBecause: 'Replacement requires a different flow-node type.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Replacement diagram bounds are required.' ].

	flowElements := processMemento readUsing: flowElementsDescription.
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
		flowElementsDescription validate: proposedFlowElements
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].

	incidentFlows := flowElements select: [ :each |
		each isSequenceFlow and: [
			(self stagedSourceOf: each) == flowNode
				or: [ (self stagedTargetOf: each) == flowNode ] ] ].

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

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [
		^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramMemento := processMemento
		childMementoFor: diagram
		inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	elements ifNil: [
		^ self rejectedBecause: 'The diagram has no staged elements collection.' ].

	shapeMatches := elements select: [ :each |
		each isShape and: [ (self stagedModelElementOf: each in: diagramMemento elementsDescription: elementsDescription) == flowNode ] ].
	shapeMatches size = 1 ifFalse: [
		^ self rejectedBecause: 'The replaced flow node requires exactly one staged diagram shape.' ].
	shape := shapeMatches first.
	modelElementDescription := shape magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	boundsDescription := shape magritteDescription
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
		shape: shape
		proposedBounds: bounds
		proposedFlowElements: proposedFlowElements
]

{ #category : 'applying' }
CPAtelierReplaceFlowNode >> applyAssessment: anAssessment [
	| incoming outgoing preservedLabel preservedNestedFlowElements diagram diagramMemento elementsDescription shapeMemento modelElementDescription boundsDescription replacementMemento incomingDescription outgoingDescription labelDescription |

	incoming := OrderedCollection new.
	outgoing := OrderedCollection new.
	preservedLabel := self stagedLabelOf: flowNode.
	preservedNestedFlowElements := self stagedNestedFlowElementsOf: flowNode.
	anAssessment incidentSequenceFlows do: [ :aSequenceFlow |
		| currentSource currentTarget flowMemento sourceDescription targetDescription |
		currentSource := self stagedSourceOf: aSequenceFlow.
		currentTarget := self stagedTargetOf: aSequenceFlow.
		flowMemento := processMemento
			childMementoFor: aSequenceFlow
			inRelation: flowElementsDescription.
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

	processMemento write: anAssessment proposedFlowElements using: flowElementsDescription.
	replacementMemento := processMemento
		childMementoFor: replacementNode
		inRelation: flowElementsDescription.
	incomingDescription := replacementMemento magritteDescription
		detect: [ :each | each handlesSelector: #incoming ].
	outgoingDescription := replacementMemento magritteDescription
		detect: [ :each | each handlesSelector: #outgoing ].
	labelDescription := replacementMemento magritteDescription
		detect: [ :each | each handlesSelector: #label ].
	replacementMemento write: preservedLabel using: labelDescription.
	replacementMemento write: incoming using: incomingDescription.
	replacementMemento write: outgoing using: outgoingDescription.
	preservedNestedFlowElements ifNotNil: [
		| nestedDescription |
		nestedDescription := replacementMemento magritteDescription
			detect: [ :each | each handlesSelector: #flowElements ].
		replacementMemento write: preservedNestedFlowElements using: nestedDescription ].

	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento
		childMementoFor: diagram
		inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	shapeMemento := diagramMemento
		childMementoFor: anAssessment shape
		inRelation: elementsDescription.
	modelElementDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	shapeMemento write: replacementNode using: modelElementDescription.
	shapeMemento write: anAssessment proposedBounds using: boundsDescription.

	processMemento detachChildMementoFor: flowNode inRelation: flowElementsDescription.
	processMemento
		childMementoFor: replacementNode
		inRelation: flowElementsDescription
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
	nodeMemento := processMemento
		childMementoFor: aFlowNode
		inRelation: flowElementsDescription.
	description := nodeMemento magritteDescription
		detect: [ :each | each handlesSelector: #label ].
	^ nodeMemento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierReplaceFlowNode >> stagedSourceOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := processMemento
		childMementoFor: aSequenceFlow
		inRelation: flowElementsDescription.
	description := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierReplaceFlowNode >> stagedTargetOf: aSequenceFlow [
	| flowMemento description |
	flowMemento := processMemento
		childMementoFor: aSequenceFlow
		inRelation: flowElementsDescription.
	description := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	^ flowMemento readUsing: description
]

{ #category : 'private - staged state' }
CPAtelierReplaceFlowNode >> stagedModelElementOf: aShape in: aDiagramMemento elementsDescription: anElementsDescription [
	| shapeMemento description |
	shapeMemento := aDiagramMemento
		childMementoFor: aShape
		inRelation: anElementsDescription.
	description := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	^ shapeMemento readUsing: description
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
CPAtelierReplaceFlowNode >> flowElementsDescription: aDescription [ flowElementsDescription := aDescription ]

{ #category : 'accessing' }
CPAtelierReplaceFlowNode >> diagramDescription: aDescription [ diagramDescription := aDescription ]


{ #category : 'accessing' }
CPAtelierReplaceFlowNode >> bounds: aRectangle [ bounds := aRectangle ]

{ #category : 'private - staged state' }
CPAtelierReplaceFlowNode >> stagedNestedFlowElementsOf: aFlowNode [
	| nodeMemento description |
	aFlowNode isSubProcess ifFalse: [ ^ nil ].
	nodeMemento := processMemento
		childMementoFor: aFlowNode
		inRelation: flowElementsDescription.
	description := nodeMemento magritteDescription
		detect: [ :each | each handlesSelector: #flowElements ].
	^ nodeMemento readUsing: description
]

