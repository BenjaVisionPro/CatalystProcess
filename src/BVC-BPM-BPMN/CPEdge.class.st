Class {
	#name : 'CPEdge',
	#superclass : 'CPDiagramElement',
	#instVars : [
		'waypoints',
		'labelSegmentIndex',
		'labelSegmentPosition',
		'labelOffset'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

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
	waypoints := aCollection
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
		classes: { CPSequenceFlow };
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
	^ MAToOneRelationDescription new
		accessor: #labelOffset;
		classes: { Point };
		label: 'Label offset';
		priority: 140;
		group: 'Diagram';
		yourself
]

{ #category : 'testing' }
CPEdge >> isEdge [
	^ true
]
