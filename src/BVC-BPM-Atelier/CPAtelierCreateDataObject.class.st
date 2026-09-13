"I stage creation of one process-scoped BPMN Data Object together with a Data Object Reference and the CPShape that depicts the reference.

The palette materialises the backing Data Object. BPMN DI depicts a DataObjectReference, so I create that reference as part of the same assessed semantic intention and stage both semantic elements before staging the shape."
Class {
	#name : 'CPAtelierCreateDataObject',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'dataObject',
		'bounds',
		'flowContainerContext',
		'diagramContext'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateDataObject class >> dataObject: aDataObject bounds: aRectangle flowContainer: aContainer processMemento: aMemento diagramContext: aDiagramContext [
	^ self new
		dataObject: aDataObject;
		bounds: aRectangle;
		flowContainerContext: (CPProcessFlowContainerContext forContainer: aContainer inRootMemento: aMemento);
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierCreateDataObject >> assess [
	| flowElements elements dataObjectReference shape proposedFlowElements proposedElements |
	dataObject ifNil: [ ^ self rejectedBecause: 'A Data Object is required.' ].
	dataObject isDataObject ifFalse: [ ^ self rejectedBecause: 'Only a Data Object can be created by this operation.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Diagram bounds are required.' ].
	flowContainerContext ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].
	flowElements := flowContainerContext stagedFlowElements.
	(flowElements identityIncludes: dataObject) ifTrue: [ ^ self rejectedBecause: 'The Data Object is already present in the flow container.' ].
	elements := diagramContext elements.
	elements ifNil: [ ^ self rejectedBecause: 'The diagram has no staged elements collection.' ].

	dataObjectReference := CPDataObjectReference new
		dataObjectRef: dataObject;
		yourself.
	shape := CPShape new
		modelElement: dataObjectReference;
		bounds: bounds;
		yourself.
	[ shape boundsDescription validate: bounds ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedFlowElements := flowElements asOrderedCollection copy.
	proposedFlowElements
		add: dataObject;
		add: dataObjectReference.
	[ flowContainerContext flowElementsDescription validate: proposedFlowElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	proposedElements := elements asOrderedCollection copy.
	proposedElements add: shape.
	[ diagramContext validateElements: proposedElements ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierCreateDataObjectAssessment
		dataObject: dataObject
		dataObjectReference: dataObjectReference
		shape: shape
		proposedFlowElements: proposedFlowElements
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierCreateDataObject >> applyAssessment: anAssessment [
	flowContainerContext writeFlowElements: anAssessment proposedFlowElements.
	diagramContext writeElements: anAssessment proposedDiagramElements
]

{ #category : 'private' }
CPAtelierCreateDataObject >> rejectedBecause: aString [
	^ CPAtelierCreateDataObjectAssessment
		dataObject: dataObject
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierCreateDataObject >> dataObject: anObject [ dataObject := anObject ]
{ #category : 'accessing' }
CPAtelierCreateDataObject >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierCreateDataObject >> flowContainerContext: aContext [ flowContainerContext := aContext ]
{ #category : 'accessing' }
CPAtelierCreateDataObject >> diagramContext: aContext [ diagramContext := aContext ]
