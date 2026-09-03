Class {
	#name : 'CPShape',
	#superclass : 'CPDiagramElement',
	#instVars : [
		'bounds'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

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
