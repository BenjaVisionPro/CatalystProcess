"I represent one BPMNDiagram.

I own exactly one CPPlane and zero or more CPLabelStyles. During the staged editor migration, modelElement/elements/addElement: remain compatibility forwarding messages only; they are not Magritte ownership relations."
Class {
	#name : 'CPDiagram',
	#superclass : 'CFIdentifiableObject',
	#instVars : [
		'plane',
		'labelStyles'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPDiagram >> initialize [
	super initialize.
	plane := CPPlane new.
	labelStyles := OrderedCollection new
]

{ #category : 'accessing' }
CPDiagram >> plane [
	^ plane
]

{ #category : 'accessing' }
CPDiagram >> plane: aPlane [
	plane := aPlane
]

{ #category : 'accessing' }
CPDiagram >> labelStyles [
	^ labelStyles
]

{ #category : 'accessing' }
CPDiagram >> labelStyles: aCollection [
	labelStyles := aCollection asOrderedCollection
]

{ #category : 'adding' }
CPDiagram >> addLabelStyle: aLabelStyle [
	labelStyles add: aLabelStyle
]

{ #category : 'removing' }
CPDiagram >> removeLabelStyle: aLabelStyle [
	labelStyles remove: aLabelStyle ifAbsent: [ ]
]

{ #category : 'descriptions' }
CPDiagram >> planeDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #plane;
		classes: { CPPlane };
		reference: CPPlane new identifierDescription;
		label: 'Plane';
		priority: 100;
		group: 'Diagram';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPDiagram >> labelStylesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #labelStyles;
		classes: { CPLabelStyle };
		reference: CPLabelStyle new identifierDescription;
		label: 'Label styles';
		priority: 110;
		group: 'Diagram';
		beOrdered;
		yourself
]

{ #category : 'compatibility - staged editor migration' }
CPDiagram >> modelElement [
	^ plane modelElement
]

{ #category : 'compatibility - staged editor migration' }
CPDiagram >> modelElement: anObject [
	plane modelElement: anObject
]

{ #category : 'compatibility - staged editor migration' }
CPDiagram >> elements [
	^ plane elements
]

{ #category : 'compatibility - staged editor migration' }
CPDiagram >> elements: aCollection [
	plane elements: aCollection
]

{ #category : 'compatibility - staged editor migration' }
CPDiagram >> addElement: aDiagramElement [
	plane addElement: aDiagramElement
]
