"I stage removal of one BPMN DataAssociation from its owning Activity/Event relation together with every Process-diagram CPEdge that depicts it."
Class {
	#name : 'CPAtelierRemoveDataAssociation',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'dataAssociation',
		'processMemento',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveDataAssociation class >> dataAssociation: anAssociation processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		dataAssociation: anAssociation;
		processMemento: aMemento;
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierRemoveDataAssociation >> assess [
	| rootContext associationContext associations proposedAssociations elements removedEdges proposedElements |
	dataAssociation ifNil: [
		^ self rejectedBecause: 'A Data Association is required.' ].
	rootContext := CPProcessFlowContainerContext rootFor: processMemento.
	associationContext := rootContext dataAssociationContextFor: dataAssociation.
	associationContext ifNil: [
		^ self rejectedBecause: 'The Data Association is not owned by the staged Process.' ].

	associations := associationContext stagedAssociations.
	proposedAssociations := associations species withAll:
		(associations reject: [ :each | each == dataAssociation ]).
	[
		associationContext validateAssociations: proposedAssociations
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].

	elements := diagramContext elements.
	removedEdges := elements select: [ :each |
		each isEdge and: [
			(diagramContext modelElementOf: each) == dataAssociation ] ].
	proposedElements := elements species withAll:
		(elements reject: [ :each | removedEdges identityIncludes: each ]).
	[
		diagramContext validateElements: proposedElements
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].

	^ CPAtelierRemoveDataAssociationAssessment
		dataAssociation: dataAssociation
		proposedAssociations: proposedAssociations
		proposedDiagramElements: proposedElements
		removedEdges: removedEdges
]

{ #category : 'applying' }
CPAtelierRemoveDataAssociation >> applyAssessment: anAssessment [
	| rootContext associationContext |
	rootContext := CPProcessFlowContainerContext rootFor: processMemento.
	associationContext := rootContext dataAssociationContextFor: dataAssociation.
	associationContext ifNil: [ ^ self ].
	associationContext writeAssociations: anAssessment proposedAssociations.
	diagramContext writeElements: anAssessment proposedDiagramElements.
	associationContext detachAssociationMemento.
	anAssessment removedEdges do: [ :anEdge |
		diagramContext detachElement: anEdge ]
]

{ #category : 'private' }
CPAtelierRemoveDataAssociation >> rejectedBecause: aString [
	^ CPAtelierRemoveDataAssociationAssessment
		dataAssociation: dataAssociation
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociation >> dataAssociation: anObject [ dataAssociation := anObject ]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociation >> processMemento: aMemento [ processMemento := aMemento ]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociation >> diagramContext: aContext [ diagramContext := aContext ]
