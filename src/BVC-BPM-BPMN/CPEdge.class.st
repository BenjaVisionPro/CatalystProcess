Class {
	#name : 'CPEdge',
	#superclass : 'CPDiagramElement',
	#instVars : [
		'modelElement',
		'waypoints',
		'label',
		'sourceElement',
		'targetElement',
		'labelSegmentIndex',
		'labelSegmentPosition',
		'labelOffset'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}


{ #category : 'accessing' }
CPEdge >> modelElement [
	^ modelElement
]

{ #category : 'accessing' }
CPEdge >> modelElement: anObject [
	modelElement := anObject
]

{ #category : 'initialization' }
CPEdge >> initialize [
	super initialize.
	waypoints := OrderedCollection new
]

{ #category : 'accessing' }
CPEdge >> waypoints [
	^ waypoints
]

{ #category : 'accessing' }
CPEdge >> waypoints: aCollection [
	waypoints := aCollection asOrderedCollection
]

{ #category : 'adding' }
CPEdge >> addWaypoint: aPoint [
	waypoints add: aPoint
]

{ #category : 'descriptions' }
CPEdge >> modelElementDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #modelElement;
		classes: { CPSequenceFlow. CPMessageFlow };
		reference: CPSequenceFlow new labelDescription;
		label: 'Element';
		priority: 100;
		group: 'Relations';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPEdge >> waypointsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #waypoints;
		classes: { Point };
		label: 'Waypoints';
		priority: 110;
		group: 'Diagram';
		beOrdered;
		yourself
]

{ #category : 'accessing' }
CPEdge >> label [ ^ label ]
{ #category : 'accessing' }
CPEdge >> label: aLabel [ label := aLabel ]
{ #category : 'descriptions' }
CPEdge >> labelDescription [
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

{ #category : 'accessing' }
CPEdge >> sourceElement [ ^ sourceElement ]
{ #category : 'accessing' }
CPEdge >> sourceElement: aDiagramElement [ sourceElement := aDiagramElement ]
{ #category : 'descriptions' }
CPEdge >> sourceElementDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #sourceElement;
		classes: { CPShape. CPEdge };
		reference: CPShape new identifierDescription;
		label: 'Source element';
		priority: 116;
		group: 'Relations';
		yourself
]

{ #category : 'accessing' }
CPEdge >> targetElement [ ^ targetElement ]
{ #category : 'accessing' }
CPEdge >> targetElement: aDiagramElement [ targetElement := aDiagramElement ]
{ #category : 'descriptions' }
CPEdge >> targetElementDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #targetElement;
		classes: { CPShape. CPEdge };
		reference: CPShape new identifierDescription;
		label: 'Target element';
		priority: 117;
		group: 'Relations';
		yourself
]

{ #category : 'accessing' }
CPEdge >> labelSegmentIndex [
	^ labelSegmentIndex
]

{ #category : 'accessing' }
CPEdge >> labelSegmentIndex: anInteger [
	labelSegmentIndex := anInteger
]

{ #category : 'accessing' }
CPEdge >> labelSegmentPosition [
	^ labelSegmentPosition
]

{ #category : 'accessing' }
CPEdge >> labelSegmentPosition: aNumber [
	labelSegmentPosition := aNumber
]

{ #category : 'descriptions' }
CPEdge >> labelSegmentIndexDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #labelSegmentIndex;
		label: 'Label segment';
		priority: 120;
		group: 'Diagram';
		yourself
]

{ #category : 'descriptions' }
CPEdge >> labelSegmentPositionDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #labelSegmentPosition;
		label: 'Label segment position';
		priority: 130;
		group: 'Diagram';
		yourself
]

{ #category : 'accessing' }
CPEdge >> labelOffset [
	^ labelOffset
]

{ #category : 'accessing' }
CPEdge >> labelOffset: aNumber [
	labelOffset := aNumber
]


{ #category : 'descriptions' }
CPEdge >> labelOffsetDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #labelOffset;
		label: 'Label offset';
		priority: 140;
		group: 'Diagram';
		yourself
]

{ #category : 'testing' }
CPEdge >> isEdge [
	^ true
]
