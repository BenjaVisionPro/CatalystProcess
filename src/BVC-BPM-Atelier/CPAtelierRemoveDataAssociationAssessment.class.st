"I describe one assessment of removing a staged BPMN DataAssociation and every Process-diagram CPEdge that depicts it."
Class {
	#name : 'CPAtelierRemoveDataAssociationAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'dataAssociation',
		'proposedAssociations',
		'proposedDiagramElements',
		'removedEdges'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveDataAssociationAssessment class >> dataAssociation: anAssociation proposedAssociations: someAssociations proposedDiagramElements: someDiagramElements removedEdges: someEdges [
	^ self new
		dataAssociation: anAssociation;
		proposedAssociations: someAssociations;
		proposedDiagramElements: someDiagramElements;
		removedEdges: someEdges;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveDataAssociationAssessment class >> dataAssociation: anAssociation rejectedBecause: aString [
	^ self new
		dataAssociation: anAssociation;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociationAssessment >> dataAssociation [ ^ dataAssociation ]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociationAssessment >> dataAssociation: anObject [ dataAssociation := anObject ]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociationAssessment >> proposedAssociations [ ^ proposedAssociations ]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociationAssessment >> proposedAssociations: aCollection [ proposedAssociations := aCollection ]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociationAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociationAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociationAssessment >> removedEdges [ ^ removedEdges ]

{ #category : 'accessing' }
CPAtelierRemoveDataAssociationAssessment >> removedEdges: aCollection [ removedEdges := aCollection ]
