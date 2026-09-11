Class {
	#name : 'CPShape',
	#superclass : 'CPDiagramElement',
	#instVars : [
		'modelElement',
		'bounds',
		'label',
		'isExpanded',
		'isHorizontal'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}



{ #category : 'accessing' }
CPShape >> modelElement [
	^ modelElement
]

{ #category : 'accessing' }
CPShape >> modelElement: anObject [
	modelElement := anObject
]

{ #category : 'initialization' }
CPShape >> initialize [
	super initialize.
	isExpanded := false.
	isHorizontal := true
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
		classes: { CPFlowNode. CPParticipant. CPLane };
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


{ #category : 'accessing' }
CPShape >> label [
	^ label
]

{ #category : 'accessing' }
CPShape >> label: aLabel [
	label := aLabel
]

{ #category : 'descriptions' }
CPShape >> labelDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #label;
		classes: { CPLabel };
		reference: CPLabel new identifierDescription;
		label: 'Label';
		priority: 115;
		group: 'Diagram';
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


{ #category : 'accessing' }
CPShape >> isHorizontal [
	^ isHorizontal ifNil: [ true ]
]

{ #category : 'accessing' }
CPShape >> isHorizontal: aBoolean [
	isHorizontal := aBoolean
]

{ #category : 'descriptions' }
CPShape >> isHorizontalDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #isHorizontal;
		label: 'Horizontal';
		priority: 125;
		group: 'Diagram';
		yourself
]
