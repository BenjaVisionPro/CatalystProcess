"I stage creation of one reusable BPMN Data Store, one process-scoped Data Store Reference and the CPShape depicting that reference.

The Data Store is a Definitions root element. The reference is a FlowElement in the target Process/Sub-Process. All three writes are assessed before any staged state changes."
Class {
	#name : 'CPAtelierCreateDataStore',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'dataStore',
		'bounds',
		'documentContext',
		'flowContainerContext',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateDataStore class >> dataStore: aDataStore bounds: aRectangle flowContainer: aContainer processMemento: aMemento documentContext: aDocumentContext diagramContext: aDiagramContext [
	^ self new
		dataStore: aDataStore;
		bounds: aRectangle;
		documentContext: aDocumentContext;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierCreateDataStore >> assess [
	| rootElements flowElements elements dataStoreReference shape proposedRootElements proposedFlowElements proposedElements |
	dataStore ifNil: [ ^ self rejectedBecause: 'A Data Store is required.' ].
	documentContext ifNil: [ ^ self rejectedBecause: 'Data Store creation requires a Definitions-rooted Atelier session.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Diagram bounds are required.' ].
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].

	rootElements := documentContext rootElements.
	(rootElements identityIncludes: dataStore) ifTrue: [
		^ self rejectedBecause: 'The Data Store is already present in Definitions.' ].
	flowElements := flowContainerContext stagedFlowElements.
	elements := diagramContext elements.

	dataStoreReference := CPDataStoreReference new
		dataStoreRef: dataStore;
		yourself.
	shape := CPShape new
		modelElement: dataStoreReference;
		bounds: bounds;
		yourself.
	[ shape boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedRootElements := rootElements asOrderedCollection copy.
	proposedRootElements add: dataStore.
	[ documentContext validateRootElements: proposedRootElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedFlowElements := flowElements asOrderedCollection copy.
	proposedFlowElements add: dataStoreReference.
	[ flowContainerContext flowElementsDescription validate: proposedFlowElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierCreateDataStoreAssessment
		dataStore: dataStore
		dataStoreReference: dataStoreReference
		shape: shape
		proposedRootElements: proposedRootElements
		proposedFlowElements: proposedFlowElements
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierCreateDataStore >> applyAssessment: anAssessment [
	documentContext writeRootElements: anAssessment proposedRootElements.
	flowContainerContext writeFlowElements: anAssessment proposedFlowElements.
	diagramContext writeElements: anAssessment proposedDiagramElements
]

{ #category : 'private' }
CPAtelierCreateDataStore >> rejectedBecause: aString [
	^ CPAtelierCreateDataStoreAssessment
		dataStore: dataStore
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierCreateDataStore >> dataStore: anObject [ dataStore := anObject ]
{ #category : 'accessing' }
CPAtelierCreateDataStore >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierCreateDataStore >> documentContext: aContext [ documentContext := aContext ]
{ #category : 'accessing' }
CPAtelierCreateDataStore >> flowContainerContext: aContext [ flowContainerContext := aContext ]
{ #category : 'accessing' }
CPAtelierCreateDataStore >> diagramContext: aContext [ diagramContext := aContext ]
