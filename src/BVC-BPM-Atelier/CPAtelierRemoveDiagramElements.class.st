"I represent removal of one explicit diagram selection as one Process editing intention.

I receive BPMN DI identities, resolve their current staged semantic elements and containment, suppress redundant SequenceFlow removals when a selected FlowNode already removes the incident flow, and delegate the actual staged mutations to the existing focused remove operations. Participant removal likewise owns its incident MessageFlow removal, so an explicitly selected incident MessageFlow is not removed twice."
Class {
	#name : 'CPAtelierRemoveDiagramElements',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'diagramElements',
		'processMemento',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveDiagramElements class >> diagramElements: someDiagramElements processMemento: aMemento diagramContext: aDiagramContext [
	^ self new diagramElements: someDiagramElements; processMemento: aMemento; diagramContext: aDiagramContext; yourself
]

{ #category : 'assessing' }
CPAtelierRemoveDiagramElements >> assess [
	| participantOperations flowOperations messageFlowOperations operations operationAssessments rejectedAssessment |
	diagramElements ifEmpty: [
		^ CPAtelierRemoveDiagramElementsAssessment rejectedBecause: 'At least one diagram element is required.' ].

	participantOperations := self participantRemovalOperations.
	flowOperations := self flowRemovalOperations.
	messageFlowOperations := self messageFlowRemovalOperationsExcludingThoseOwnedBy: participantOperations.
	operations := participantOperations , flowOperations , messageFlowOperations.
	operationAssessments := operations collect: [ :anOperation | anOperation assess ].
	rejectedAssessment := operationAssessments
		detect: [ :anAssessment | anAssessment isApplicable not ]
		ifNone: [ nil ].
	rejectedAssessment ifNotNil: [
		^ CPAtelierRemoveDiagramElementsAssessment
			rejectedBecause: rejectedAssessment rejectionMessage ].

	operations ifEmpty: [
		^ CPAtelierRemoveDiagramElementsAssessment rejectedBecause: 'The selected diagram elements are not removable.' ].
	^ CPAtelierRemoveDiagramElementsAssessment
		operations: operations
		operationAssessments: operationAssessments
]

{ #category : 'applying' }
CPAtelierRemoveDiagramElements >> applyAssessment: anAssessment [
	anAssessment operations do: [ :anOperation | anOperation apply ]
]

{ #category : 'private - resolving' }
CPAtelierRemoveDiagramElements >> participantRemovalOperations [
	| operations collaborationContext collaborationDiagramContext |
	operations := OrderedCollection new.
	collaborationContext := CPProcessCollaborationContext inRootMemento: processMemento.
	collaborationContext ifNil: [ ^ operations ].
	collaborationDiagramContext := collaborationContext diagramContext.
	diagramElements do: [ :aDiagramElement |
		((collaborationContext elements identityIncludes: aDiagramElement)
			and: [ aDiagramElement isShape ]) ifTrue: [
			| participant |
			participant := collaborationDiagramContext modelElementOf: aDiagramElement.
			(participant notNil and: [
				collaborationContext participants identityIncludes: participant ]) ifTrue: [
				operations add: (CPAtelierRemoveParticipant
					participant: participant
					processMemento: processMemento) ] ] ].
	^ operations
]

{ #category : 'private - resolving' }
CPAtelierRemoveDiagramElements >> flowRemovalOperations [
	| operations processDiagramContext selectedNodes operationOwnerNodes selectedSequenceFlows |
	operations := OrderedCollection new.
	processDiagramContext := self processDiagramContext.
	selectedNodes := IdentitySet new.
	selectedSequenceFlows := IdentitySet new.
	diagramElements do: [ :aDiagramElement |
		(processDiagramContext elements identityIncludes: aDiagramElement) ifTrue: [
			| modelElement |
			modelElement := processDiagramContext modelElementOf: aDiagramElement.
			modelElement ifNotNil: [
				aDiagramElement isShape
					ifTrue: [ selectedNodes add: modelElement ]
					ifFalse: [
						modelElement isSequenceFlow ifTrue: [
							selectedSequenceFlows add: modelElement ] ] ] ] ].

	operationOwnerNodes := selectedNodes copy.
	selectedNodes do: [ :aFlowNode |
		aFlowNode isActivity ifTrue: [
			| context |
			context := CPProcessFlowContainerContext
				containingFlowElement: aFlowNode
				inRootMemento: processMemento.
			context ifNotNil: [
				operationOwnerNodes addAll: (context attachedBoundaryEventsFor: aFlowNode) ] ] ].

	selectedNodes do: [ :aFlowNode |
		| context isOwnedBySelectedActivity |
		isOwnedBySelectedActivity := aFlowNode isBoundaryEvent and: [
			| boundaryContext attachedActivity |
			boundaryContext := CPProcessFlowContainerContext
				containingFlowElement: aFlowNode
				inRootMemento: processMemento.
			attachedActivity := boundaryContext ifNotNil: [ boundaryContext stagedAttachedToOf: aFlowNode ].
			attachedActivity notNil and: [ selectedNodes includes: attachedActivity ] ].
		isOwnedBySelectedActivity ifFalse: [
			context := CPProcessFlowContainerContext
				containingFlowElement: aFlowNode
				inRootMemento: processMemento.
			context ifNotNil: [
				operations add: (CPAtelierRemoveFlowNode
					flowNode: aFlowNode
					flowContainer: context container
					processMemento: processMemento
					diagramContext: self stagedDiagramContext) ] ] ].

	selectedSequenceFlows do: [ :aSequenceFlow |
		(self sequenceFlow: aSequenceFlow isIncidentToAny: operationOwnerNodes) ifFalse: [
			| context |
			context := CPProcessFlowContainerContext
				containingFlowElement: aSequenceFlow
				inRootMemento: processMemento.
			context ifNotNil: [
				operations add: (CPAtelierRemoveSequenceFlow
					sequenceFlow: aSequenceFlow
					flowContainer: context container
					processMemento: processMemento
					diagramContext: self stagedDiagramContext) ] ] ].
	^ operations
]


{ #category : 'private - resolving' }
CPAtelierRemoveDiagramElements >> messageFlowRemovalOperationsExcludingThoseOwnedBy: participantOperations [
	| context diagramContext participantAssessments ownedMessageFlows operations |
	context := CPProcessCollaborationContext inRootMemento: processMemento.
	context ifNil: [ ^ #() ].
	diagramContext := context diagramContext.
	participantAssessments := participantOperations collect: [ :anOperation | anOperation assess ].
	ownedMessageFlows := IdentitySet new.
	participantAssessments do: [ :anAssessment |
		anAssessment isApplicable ifTrue: [
			ownedMessageFlows addAll: anAssessment removedMessageFlows ] ].
	operations := OrderedCollection new.
	diagramElements do: [ :aDiagramElement |
		((context elements identityIncludes: aDiagramElement)
			and: [ aDiagramElement isEdge ]) ifTrue: [
			| messageFlow |
			messageFlow := diagramContext modelElementOf: aDiagramElement.
			(messageFlow notNil and: [
				(context messageFlows identityIncludes: messageFlow)
					and: [ (ownedMessageFlows identityIncludes: messageFlow) not ] ])
				ifTrue: [
					operations add: (CPAtelierRemoveMessageFlow
						messageFlow: messageFlow
						processMemento: processMemento) ] ] ].
	^ operations
]

{ #category : 'private - resolving' }
CPAtelierRemoveDiagramElements >> processDiagramContext [
	^ self stagedDiagramContext
]

{ #category : 'private - resolving' }
CPAtelierRemoveDiagramElements >> sequenceFlow: aSequenceFlow isIncidentToAny: someFlowNodes [
	| context |
	context := CPProcessFlowContainerContext
		containingFlowElement: aSequenceFlow
		inRootMemento: processMemento.
	context ifNil: [ ^ false ].
	^ (someFlowNodes identityIncludes: (context stagedSourceOf: aSequenceFlow))
		or: [ someFlowNodes identityIncludes: (context stagedTargetOf: aSequenceFlow) ]
]

{ #category : 'accessing' }
CPAtelierRemoveDiagramElements >> diagramElements: someDiagramElements [
	diagramElements := someDiagramElements asArray
]

{ #category : 'accessing' }
CPAtelierRemoveDiagramElements >> processMemento: aMemento [
	processMemento := aMemento
]

{ #category : 'private - staged state' }
CPAtelierRemoveDiagramElements >> stagedDiagramContext [
	^ diagramContext
]

{ #category : 'accessing' }
CPAtelierRemoveDiagramElements >> diagramContext: aDiagramContext [
	diagramContext := aDiagramContext
]
