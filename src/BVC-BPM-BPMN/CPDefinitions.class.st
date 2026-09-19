"I represent one BPMN Definitions document.

I structurally own the root semantic elements and BPMN diagrams that participate in one interchange document. References between those objects do not establish additional ownership."
Class {
	#name : 'CPDefinitions',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'targetNamespace',
		'expressionLanguage',
		'rootElements',
		'diagrams'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPDefinitions >> initialize [
	super initialize.
	rootElements := OrderedCollection new.
	diagrams := OrderedCollection new
]

{ #category : 'accessing' }
CPDefinitions >> targetNamespace [
	^ targetNamespace
]

{ #category : 'accessing' }
CPDefinitions >> targetNamespace: aString [
	targetNamespace := aString
]

{ #category : 'accessing' }
CPDefinitions >> expressionLanguage [
	^ expressionLanguage
]

{ #category : 'accessing' }
CPDefinitions >> expressionLanguage: aString [
	expressionLanguage := aString
]

{ #category : 'descriptions' }
CPDefinitions >> expressionLanguageDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #expressionLanguage;
		label: 'Expression language';
		priority: 30;
		yourself
]

{ #category : 'accessing' }
CPDefinitions >> rootElements [
	^ rootElements
]

{ #category : 'accessing' }
CPDefinitions >> rootElements: aCollection [
	rootElements := aCollection asOrderedCollection
]

{ #category : 'adding' }
CPDefinitions >> addRootElement: aRootElement [
	(rootElements identityIncludes: aRootElement) ifFalse: [
		rootElements add: aRootElement ]
]

{ #category : 'removing' }
CPDefinitions >> removeRootElement: aRootElement [
	rootElements remove: aRootElement ifAbsent: [ ]
]

{ #category : 'accessing' }
CPDefinitions >> diagrams [
	^ diagrams
]

{ #category : 'accessing' }
CPDefinitions >> diagrams: aCollection [
	diagrams := aCollection asOrderedCollection
]

{ #category : 'adding' }
CPDefinitions >> addDiagram: aDiagram [
	(diagrams identityIncludes: aDiagram) ifFalse: [
		diagrams add: aDiagram ]
]

{ #category : 'removing' }
CPDefinitions >> removeDiagram: aDiagram [
	diagrams remove: aDiagram ifAbsent: [ ]
]

{ #category : 'descriptions' }
CPDefinitions >> targetNamespaceDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #targetNamespace;
		label: 'Target namespace';
		priority: 20;
		beRequired;
		cfSerializable: true;
		yourself
]

{ #category : 'descriptions' }
CPDefinitions >> rootElementsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #rootElements;
		classes: { CPProcess. CPCollaboration. CPItemDefinition. CPDataStore. CPMessage. CPError. CPInterface };
		reference: self identifierDescription;
		label: 'Root elements';
		priority: 100;
		group: 'Relations';
		beModifiable;
		beOrdered;
		newItemClassStencil: [ :aClass | aClass new ];
		yourself
]

{ #category : 'descriptions' }
CPDefinitions >> diagramsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #diagrams;
		classes: { CPDiagram };
		reference: CPDiagram new identifierDescription;
		label: 'Diagrams';
		priority: 110;
		group: 'Diagram';
		beOrdered;
		yourself
]

{ #category : 'accessing - presentation' }
CPDefinitions class >> defaultIcon [
	^ #chartNetwork
]

