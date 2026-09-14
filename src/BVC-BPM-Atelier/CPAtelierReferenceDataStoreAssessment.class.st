"I describe one assessment of referencing an existing Definitions-owned Data Store from a Process."
Class {
	#name : 'CPAtelierReferenceDataStoreAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'dataStore',
		'dataStoreReference',
		'shape',
		'proposedFlowElements',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReferenceDataStoreAssessment class >> dataStore: aDataStore dataStoreReference: aReference shape: aShape proposedFlowElements: someFlowElements proposedDiagramElements: someElements [
	^ self new
		dataStore: aDataStore;
		dataStoreReference: aReference;
		shape: aShape;
		proposedFlowElements: someFlowElements;
		proposedDiagramElements: someElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReferenceDataStoreAssessment class >> dataStore: aDataStore rejectedBecause: aString [
	^ self new
		dataStore: aDataStore;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierReferenceDataStoreAssessment >> dataStore [ ^ dataStore ]

{ #category : 'accessing' }
CPAtelierReferenceDataStoreAssessment >> dataStore: anObject [ dataStore := anObject ]

{ #category : 'accessing' }
CPAtelierReferenceDataStoreAssessment >> dataStoreReference [ ^ dataStoreReference ]

{ #category : 'accessing' }
CPAtelierReferenceDataStoreAssessment >> dataStoreReference: anObject [ dataStoreReference := anObject ]

{ #category : 'accessing' }
CPAtelierReferenceDataStoreAssessment >> shape [ ^ shape ]

{ #category : 'accessing' }
CPAtelierReferenceDataStoreAssessment >> shape: anObject [ shape := anObject ]

{ #category : 'accessing' }
CPAtelierReferenceDataStoreAssessment >> proposedFlowElements [ ^ proposedFlowElements ]

{ #category : 'accessing' }
CPAtelierReferenceDataStoreAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]

{ #category : 'accessing' }
CPAtelierReferenceDataStoreAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]

{ #category : 'accessing' }
CPAtelierReferenceDataStoreAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
