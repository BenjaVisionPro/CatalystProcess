"I describe one assessment of connecting a depicted Data Object Reference to or from an Activity through the Activity's BPMN input/output contract."
Class {
	#name : 'CPAtelierConnectDataAssociationAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'dataReference',
		'activity',
		'association',
		'dataItem',
		'ioSpecification',
		'set',
		'edge',
		'inputAssociation',
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
CPAtelierConnectDataAssociationAssessment class >> dataReference: aReference activity: anActivity association: anAssociation dataItem: anItem ioSpecification: aSpecification set: aSet edge: anEdge inputAssociation: isInput proposedDataItems: someItems proposedSetRefs: someRefs proposedAssociations: someAssociations proposedDiagramElements: someElements [
	^ self new
		dataReference: aReference;
		activity: anActivity;
		association: anAssociation;
		dataItem: anItem;
		ioSpecification: aSpecification;
		set: aSet;
		edge: anEdge;
		inputAssociation: isInput;
		proposedDataItems: someItems;
		proposedSetRefs: someRefs;
		proposedAssociations: someAssociations;
		proposedDiagramElements: someElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierConnectDataAssociationAssessment class >> dataReference: aReference activity: anActivity rejectedBecause: aString [
	^ self new
		dataReference: aReference;
		activity: anActivity;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> dataReference [ ^ dataReference ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> dataReference: anObject [ dataReference := anObject ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> activity [ ^ activity ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> activity: anObject [ activity := anObject ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> association [ ^ association ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> association: anObject [ association := anObject ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> dataItem [ ^ dataItem ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> dataItem: anObject [ dataItem := anObject ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> ioSpecification [ ^ ioSpecification ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> ioSpecification: anObject [ ioSpecification := anObject ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> set [ ^ set ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> set: anObject [ set := anObject ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> edge [ ^ edge ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> inputAssociation [ ^ inputAssociation ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> inputAssociation: aBoolean [ inputAssociation := aBoolean ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> proposedDataItems [ ^ proposedDataItems ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> proposedDataItems: aCollection [ proposedDataItems := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> proposedSetRefs [ ^ proposedSetRefs ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> proposedSetRefs: aCollection [ proposedSetRefs := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> proposedAssociations [ ^ proposedAssociations ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> proposedAssociations: aCollection [ proposedAssociations := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierConnectDataAssociationAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
