"I describe one assessed BPMN Data Association between a depicted Data Object Reference and a Catch/Throw Event."
Class {
	#name : 'CPAtelierConnectEventDataAssociationAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'dataReference',
		'event',
		'association',
		'dataItem',
		'set',
		'edge',
		'catchAssociation',
		'proposedDataItems',
		'proposedSetRefs',
		'proposedAssociations',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierConnectEventDataAssociationAssessment class >> dataReference: aReference event: anEvent association: anAssociation dataItem: anItem set: aSet edge: anEdge catchAssociation: isCatch proposedDataItems: someItems proposedSetRefs: someRefs proposedAssociations: someAssociations proposedDiagramElements: someElements [
	^ self new
		dataReference: aReference;
		event: anEvent;
		association: anAssociation;
		dataItem: anItem;
		set: aSet;
		edge: anEdge;
		catchAssociation: isCatch;
		proposedDataItems: someItems;
		proposedSetRefs: someRefs;
		proposedAssociations: someAssociations;
		proposedDiagramElements: someElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierConnectEventDataAssociationAssessment class >> dataReference: aReference event: anEvent rejectedBecause: aString [
	^ self new
		dataReference: aReference;
		event: anEvent;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> dataReference [ ^ dataReference ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> dataReference: anObject [ dataReference := anObject ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> event [ ^ event ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> event: anObject [ event := anObject ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> association [ ^ association ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> association: anObject [ association := anObject ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> dataItem [ ^ dataItem ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> dataItem: anObject [ dataItem := anObject ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> set [ ^ set ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> set: anObject [ set := anObject ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> catchAssociation [ ^ catchAssociation ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> catchAssociation: aBoolean [ catchAssociation := aBoolean ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> proposedDataItems [ ^ proposedDataItems ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> proposedDataItems: aCollection [ proposedDataItems := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> proposedSetRefs [ ^ proposedSetRefs ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> proposedSetRefs: aCollection [ proposedSetRefs := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> proposedAssociations [ ^ proposedAssociations ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> proposedAssociations: aCollection [ proposedAssociations := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierConnectEventDataAssociationAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
