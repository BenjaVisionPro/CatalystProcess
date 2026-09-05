Class {
	#name : 'CPEdge',
	#superclass : 'CPDiagramElement',
	#instVars : [
		'waypoints',
		'labelPathPosition',
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
CPEdge >> labelPathPosition [
	^ labelPathPosition
]

{ #category : 'accessing' }
CPEdge >> labelPathPosition: aNumber [
	labelPathPosition := aNumber
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
CPEdge >> labelPathPositionDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #labelPathPosition;
		label: 'Label path position';
		priority: 120;
		group: 'Diagram';
		yourself
]

{ #category : 'descriptions' }
CPEdge >> labelOffsetDescription [
	<magritteDescription>
	^ MANumberDescription new
		accessor: #labelOffset;
		label: 'Label offset';
		priority: 130;
		group: 'Diagram';
		yourself
]

{ #category : 'testing' }
CPEdge >> isEdge [
	^ true
]
