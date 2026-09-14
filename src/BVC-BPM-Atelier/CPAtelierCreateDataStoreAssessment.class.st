"I describe one assessment of adding a Definitions-owned Data Store, its process-scoped Data Store Reference and its CPShape."
Class {
	#name : 'CPAtelierCreateDataStoreAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'dataStore',
		'dataStoreReference',
		'shape',
		'proposedRootElements',
		'proposedFlowElements',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateDataStoreAssessment class >> dataStore: aDataStore dataStoreReference: aReference shape: aShape proposedRootElements: someRootElements proposedFlowElements: someFlowElements proposedDiagramElements: someElements [
	^ self new
		dataStore: aDataStore;
		dataStoreReference: aReference;
		shape: aShape;
		proposedRootElements: someRootElements;
		proposedFlowElements: someFlowElements;
		proposedDiagramElements: someElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierCreateDataStoreAssessment class >> dataStore: aDataStore rejectedBecause: aString [
	^ self new
		dataStore: aDataStore;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> dataStore [ ^ dataStore ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> dataStore: anObject [ dataStore := anObject ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> dataStoreReference [ ^ dataStoreReference ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> dataStoreReference: anObject [ dataStoreReference := anObject ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> proposedRootElements [ ^ proposedRootElements ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> proposedRootElements: aCollection [ proposedRootElements := aCollection ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> proposedFlowElements [ ^ proposedFlowElements ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierCreateDataStoreAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
