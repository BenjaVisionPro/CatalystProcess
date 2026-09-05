Class {
	#name : 'CPShape',
	#superclass : 'CPDiagramElement',
	#instVars : [
		'bounds',
		'isExpanded'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}


{ #category : 'initialization' }
CPShape >> initialize [
	super initialize.
	isExpanded := false
]

{ #category : 'accessing' }
CPShape >> bounds [
	^ bounds
]

{ #category : 'accessing' }
CPShape >> bounds: aRectangle [
	bounds := aRectangle
]

{ #category : 'descriptions' }
CPShape >> modelElementDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #modelElement;
		classes: { CPFlowNode };
		reference: CPFlowNode new labelDescription;
		label: 'Element';
		priority: 100;
		group: 'Relations';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPShape >> boundsDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #bounds;
		classes: { Rectangle };
		label: 'Bounds';
		priority: 110;
		group: 'Diagram';
		beRequired;
		yourself
]

{ #category : 'testing' }
CPShape >> isShape [
	^ true
]


{ #category : 'accessing' }
CPShape >> isExpanded [
	^ isExpanded
]

{ #category : 'accessing' }
CPShape >> isExpanded: aBoolean [
	isExpanded := aBoolean
]

{ #category : 'descriptions' }
CPShape >> isExpandedDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #isExpanded;
		label: 'Expanded';
		priority: 120;
		group: 'Diagram';
		yourself
]
