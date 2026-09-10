"I represent the single BPMNPlane owned by a CPDiagram.

I directly own the ordered diagram elements for one BPMN depiction. Their order is the BPMN-DI z-order. Shape bounds, edge waypoints and label bounds are expressed in my coordinate space even when the Bloc presentation nests their visuals."
Class {
	#name : 'CPPlane',
	#superclass : 'CPDiagramElement',
	#instVars : [
		'modelElement',
		'elements'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPPlane >> initialize [
	super initialize.
	elements := OrderedCollection new
]

{ #category : 'accessing' }
CPPlane >> modelElement [
	^ modelElement
]

{ #category : 'accessing' }
CPPlane >> modelElement: anObject [
	modelElement := anObject
]

{ #category : 'accessing' }
CPPlane >> elements [
	^ elements
]

{ #category : 'accessing' }
CPPlane >> elements: aCollection [
	elements := aCollection asOrderedCollection
]

{ #category : 'adding' }
CPPlane >> addElement: aDiagramElement [
	elements add: aDiagramElement
]

{ #category : 'removing' }
CPPlane >> removeElement: aDiagramElement [
	elements remove: aDiagramElement ifAbsent: [ ]
]

{ #category : 'descriptions' }
CPPlane >> modelElementDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #modelElement;
		classes: { CPProcess. CPSubProcess. CPCollaboration };
		reference: CPProcess new labelDescription;
		label: 'Model element';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPPlane >> elementsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #elements;
		classes: { CPShape. CPEdge };
		label: 'Elements';
		priority: 110;
		group: 'Diagram';
		beOrdered;
		yourself
]
