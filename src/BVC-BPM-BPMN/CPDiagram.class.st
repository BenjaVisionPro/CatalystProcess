Class {
	#name : 'CPDiagram',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'modelElement',
		'elements'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPDiagram >> initialize [
	super initialize.
	elements := OrderedCollection new
]

{ #category : 'accessing' }
CPDiagram >> modelElement [
	^ modelElement
]

{ #category : 'accessing' }
CPDiagram >> modelElement: anObject [
	modelElement := anObject
]

{ #category : 'accessing' }
CPDiagram >> elements [
	^ elements
]

{ #category : 'accessing' }
CPDiagram >> elements: aCollection [
	elements := aCollection
]

{ #category : 'adding' }
CPDiagram >> addElement: aDiagramElement [
	elements add: aDiagramElement
]

{ #category : 'descriptions' }
CPDiagram >> modelElementDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #modelElement;
		classes: { CPProcess. CPCollaboration };
		reference: CPProcess new labelDescription;
		label: 'Model element';
		priority: 100;
		group: 'Relations';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPDiagram >> elementsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #elements;
		classes: { CPDiagramElement };
		label: 'Elements';
		priority: 110;
		group: 'Diagram';
		yourself
]
