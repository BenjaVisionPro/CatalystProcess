"I represent removal of one explicit diagram selection as one Process editing intention.

I receive BPMN DI identities, resolve their current staged semantic elements and containment, suppress redundant SequenceFlow removals when a selected FlowNode already removes the incident flow, and delegate the actual staged mutations to the existing focused remove operations. Participant removal likewise owns its incident MessageFlow removal, so an explicitly selected incident MessageFlow is not removed twice."
Class {
	#name : 'CPAtelierRemoveDiagramElements',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'diagramElements',
		'processMemento',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveDiagramElements class >> diagramElements: someDiagramElements processMemento: aMemento diagramDescription: aDescription [
	^ self new
		diagramElements: someDiagramElements;
		processMemento: aMemento;
		diagramDescription: aDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierRemoveDiagramElements >> assess [
	| participantOperations flowOperations operations participantAssessments flowAssessments operationAssessments rejectedAssessment unsupportedMessageFlows |
	diagramElements ifEmpty: [
		^ CPAtelierRemoveDiagramElementsAssessment rejectedBecause: 'At least one diagram element is required.' ].

	participantOperations := self participantRemovalOperations.
	flowOperations := self flowRemovalOperations.
	operations := participantOperations , flowOperations.
	participantAssessments := participantOperations collect: [ :anOperation | anOperation assess ].
	flowAssessments := flowOperations collect: [ :anOperation | anOperation assess ].
	operationAssessments := participantAssessments , flowAssessments.
	rejectedAssessment := operationAssessments
		detect: [ :anAssessment | anAssessment isApplicable not ]
		ifNone: [ nil ].
	rejectedAssessment ifNotNil: [
		^ CPAtelierRemoveDiagramElementsAssessment
			rejectedBecause: rejectedAssessment rejectionMessage ].

	unsupportedMessageFlows := self selectedMessageFlows reject: [ :aMessageFlow |
		participantAssessments anySatisfy: [ :anAssessment |
			anAssessment removedMessageFlows identityIncludes: aMessageFlow ] ].
	unsupportedMessageFlows ifNotEmpty: [
		^ CPAtelierRemoveDiagramElementsAssessment
			rejectedBecause: 'Removing a MessageFlow directly is not implemented yet.' ].

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
	collaborationDiagramContext := CPDiagramMementoContext
		diagram: collaborationContext diagram
		memento: collaborationContext diagramMemento
		elementsDescription: collaborationContext elementsDescription.
	diagramElements do: [ :aDiagramElement |
		(collaborationContext elements identityIncludes: aDiagramElement) ifTrue: [
			| modelElement |
			modelElement := collaborationDiagramContext modelElementOf: aDiagramElement.
			(modelElement notNil and: [ modelElement isParticipant ]) ifTrue: [
				operations add: (CPAtelierRemoveParticipant
					participant: modelElement
					processMemento: processMemento) ] ] ].
	^ operations
]

{ #category : 'private - resolving' }
CPAtelierRemoveDiagramElements >> flowRemovalOperations [
	| operations processDiagramContext selectedNodes selectedSequenceFlows |
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

	selectedNodes do: [ :aFlowNode |
		| context |
		context := CPProcessFlowContainerContext
			containingFlowElement: aFlowNode
			inRootMemento: processMemento.
		context ifNotNil: [
			operations add: (CPAtelierRemoveFlowNode
				flowNode: aFlowNode
				flowContainer: context container
				processMemento: processMemento
				diagramDescription: diagramDescription) ] ].

	selectedSequenceFlows do: [ :aSequenceFlow |
		(self sequenceFlow: aSequenceFlow isIncidentToAny: selectedNodes) ifFalse: [
			| context |
			context := CPProcessFlowContainerContext
				containingFlowElement: aSequenceFlow
				inRootMemento: processMemento.
			context ifNotNil: [
				operations add: (CPAtelierRemoveSequenceFlow
					sequenceFlow: aSequenceFlow
					flowContainer: context container
					processMemento: processMemento
					diagramDescription: diagramDescription) ] ] ].
	^ operations
]

{ #category : 'private - resolving' }
CPAtelierRemoveDiagramElements >> selectedMessageFlows [
	| context diagramContext |
	context := CPProcessCollaborationContext inRootMemento: processMemento.
	context ifNil: [ ^ #() ].
	diagramContext := CPDiagramMementoContext
		diagram: context diagram
		memento: context diagramMemento
		elementsDescription: context elementsDescription.
	^ diagramElements
		select: [ :aDiagramElement |
			(context elements identityIncludes: aDiagramElement)
				and: [ aDiagramElement isEdge ] ]
		thenCollect: [ :anEdge | diagramContext modelElementOf: anEdge ]
]

{ #category : 'private - resolving' }
CPAtelierRemoveDiagramElements >> processDiagramContext [
	| diagram diagramMemento elementsDescription |
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	^ CPDiagramMementoContext
		diagram: diagram
		memento: diagramMemento
		elementsDescription: elementsDescription
]

{ #category : 'private - resolving' }
CPAtelierRemoveDiagramElements >> sequenceFlow: aSequenceFlow isIncidentToAny: someFlowNodes [
	| context flowMemento sourceDescription targetDescription source target |
	context := CPProcessFlowContainerContext
		containingFlowElement: aSequenceFlow
		inRootMemento: processMemento.
	context ifNil: [ ^ false ].
	flowMemento := context childMementoFor: aSequenceFlow.
	sourceDescription := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := flowMemento magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	source := flowMemento readUsing: sourceDescription.
	target := flowMemento readUsing: targetDescription.
	^ (someFlowNodes identityIncludes: source)
		or: [ someFlowNodes identityIncludes: target ]
]

{ #category : 'accessing' }
CPAtelierRemoveDiagramElements >> diagramElements: someDiagramElements [
	diagramElements := someDiagramElements asArray
]

{ #category : 'accessing' }
CPAtelierRemoveDiagramElements >> processMemento: aMemento [
	processMemento := aMemento
]

{ #category : 'accessing' }
CPAtelierRemoveDiagramElements >> diagramDescription: aDescription [
	diagramDescription := aDescription
]
