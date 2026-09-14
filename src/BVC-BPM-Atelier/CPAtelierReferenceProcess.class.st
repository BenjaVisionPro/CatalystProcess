"I interpret an existing Definitions-owned Process as a BPMN Call Activity in another Process.

The source Process remains a Definitions root element. I create a fresh CPCallActivity whose calledElement references that Process and delegate normal FlowNode/DI staging to CPAtelierCreateFlowNode."
Class {
	#name : 'CPAtelierReferenceProcess',
	#superclass : 'CPAtelierReferenceDefinitionsRootElement',
	#instVars : [
		'process',
		'callActivity',
		'flowContainer',
		'processMemento',
		'documentContext',
		'diagramContext',
		'createOperation'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReferenceProcess class >> process: aProcess flowContainer: aContainer processMemento: aMemento documentContext: aDocumentContext diagramContext: aDiagramContext [
	^ self new
		process: aProcess;
		callActivity: (CPCallActivity new
			label: aProcess label;
			calledElement: aProcess;
			yourself);
		flowContainer: aContainer;
		processMemento: aMemento;
		documentContext: aDocumentContext;
		diagramContext: aDiagramContext;
		yourself
]

{ #category : 'assessing' }
CPAtelierReferenceProcess >> assess [
	| rootElements assessment |
	documentContext ifNil: [ ^ self rejectedBecause: 'A Definitions-rooted Atelier session is required.' ].
	process ifNil: [ ^ self rejectedBecause: 'A Definitions root element is required.' ].
	bounds ifNil: [ ^ self rejectedBecause: 'Diagram bounds are required.' ].
	flowContainer ifNil: [ ^ self rejectedBecause: 'The target flow container is not present in staged state.' ].

	rootElements := documentContext rootElements.
	(rootElements identityIncludes: process) ifFalse: [
		^ self rejectedBecause: 'The called Process must already belong to these Definitions.' ].
	[ callActivity calledElementDescription validate: process ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	createOperation := CPAtelierCreateFlowNode
		flowNode: callActivity
		bounds: bounds
		flowContainer: flowContainer
		processMemento: processMemento
		diagramContext: diagramContext.
	assessment := createOperation assess.
	assessment isApplicable ifFalse: [
		^ self rejectedBecause: assessment rejectionMessage ].
	^ CPAtelierReferenceProcessAssessment
		process: process
		callActivity: callActivity
		createAssessment: assessment
]

{ #category : 'applying' }
CPAtelierReferenceProcess >> applyAssessment: anAssessment [
	createOperation applyAssessment: anAssessment createAssessment
]

{ #category : 'private' }
CPAtelierReferenceProcess >> rejectedBecause: aString [
	^ CPAtelierReferenceProcessAssessment
		process: process
		callActivity: callActivity
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierReferenceProcess >> modelElement [ ^ callActivity ]
{ #category : 'accessing' }
CPAtelierReferenceProcess >> process: anObject [ process := anObject ]
{ #category : 'accessing' }
CPAtelierReferenceProcess >> callActivity: anObject [ callActivity := anObject ]
{ #category : 'accessing' }
CPAtelierReferenceProcess >> flowContainer: anObject [ flowContainer := anObject ]
{ #category : 'accessing' }
CPAtelierReferenceProcess >> processMemento: anObject [ processMemento := anObject ]
{ #category : 'accessing' }
CPAtelierReferenceProcess >> documentContext: anObject [ documentContext := anObject ]
{ #category : 'accessing' }
CPAtelierReferenceProcess >> diagramContext: anObject [ diagramContext := anObject ]
