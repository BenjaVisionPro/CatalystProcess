Class {
	#name : 'CPEdge',
	#superclass : 'CPDiagramElement',
	#instVars : [
		'waypoints',
		'labelBounds'
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
CPEdge >> labelBounds [
	^ labelBounds
]

{ #category : 'accessing' }
CPEdge >> labelBounds: aRectangle [
	labelBounds := aRectangle
]

{ #category : 'descriptions' }
CPEdge >> labelBoundsDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #labelBounds;
		classes: { Rectangle };
		label: 'Label bounds';
		priority: 120;
		group: 'Diagram';
		yourself
]

{ #category : 'testing' }
CPEdge >> isEdge [
	^ true
]
