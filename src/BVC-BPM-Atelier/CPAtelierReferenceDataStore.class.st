"I stage one Process-scoped Data Store Reference and its BPMN DI shape for an existing Definitions-owned Data Store.

I do not create, copy or move the Data Store. The candidate must already be present in the staged Definitions rootElements collection. Its CPDataStoreReference description remains authoritative for validating that the candidate is actually a BPMN Data Store."
Class {
	#name : 'CPAtelierReferenceDataStore',
	#superclass : 'CPAtelierReferenceDefinitionsRootElement',
	#instVars : [
		'dataStore',
		'dataStoreReference',
		'flowContainerContext',
		'documentContext',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReferenceDataStore class >> dataStore: aDataStore bounds: aRectangle flowContainer: aContainer processMemento: aMemento documentContext: aDocumentContext diagramContext: aDiagramContext [
	^ self new
		dataStore: aDataStore;
		dataStoreReference: (CPDataStoreReference new dataStoreRef: aDataStore; yourself);
		bounds: aRectangle;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		documentContext: aDocumentContext;
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierReferenceDataStore >> assess [
	| rootElements flowElements elements shape proposedFlowElements proposedElements |
	documentContext ifNil: [
		^ self rejectedBecause: 'A Definitions-rooted Atelier session is required.' ].
	dataStore ifNil: [
		^ self rejectedBecause: 'A Definitions root element is required.' ].
	bounds ifNil: [
		^ self rejectedBecause: 'Diagram bounds are required.' ].
	flowContainerContext ifNil: [
		^ self rejectedBecause: 'The target flow container is not present in staged state.' ].

	rootElements := documentContext rootElements.
	(rootElements identityIncludes: dataStore) ifFalse: [
		^ self rejectedBecause: 'The referenced Data Store must already belong to these Definitions.' ].

	[ dataStoreReference dataStoreRefDescription validate: dataStore ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	shape := CPShape new
		modelElement: dataStoreReference;
		bounds: bounds;
		yourself.
	[ shape boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	flowElements := flowContainerContext stagedFlowElements.
	proposedFlowElements := flowElements asOrderedCollection copy.
	proposedFlowElements add: dataStoreReference.
	[ flowContainerContext flowElementsDescription validate: proposedFlowElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	elements := diagramContext elements.
	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierReferenceDataStoreAssessment
		dataStore: dataStore
		dataStoreReference: dataStoreReference
		shape: shape
		proposedFlowElements: proposedFlowElements
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierReferenceDataStore >> applyAssessment: anAssessment [
	flowContainerContext writeFlowElements: anAssessment proposedFlowElements.
	diagramContext writeElements: anAssessment proposedDiagramElements
]

{ #category : 'private' }
CPAtelierReferenceDataStore >> rejectedBecause: aString [
	^ CPAtelierReferenceDataStoreAssessment
		dataStore: dataStore
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierReferenceDataStore >> dataStore: anObject [ dataStore := anObject ]

{ #category : 'accessing' }
CPAtelierReferenceDataStore >> flowContainerContext: aContext [ flowContainerContext := aContext ]

{ #category : 'accessing' }
CPAtelierReferenceDataStore >> documentContext: aContext [ documentContext := aContext ]

{ #category : 'accessing' }
CPAtelierReferenceDataStore >> diagramContext: aContext [ diagramContext := aContext ]

{ #category : 'accessing' }
CPAtelierReferenceDataStore >> dataStoreReference: anObject [
	dataStoreReference := anObject
]

{ #category : 'accessing' }
CPAtelierReferenceDataStore >> modelElement [
	^ dataStoreReference
]
