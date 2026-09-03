Class {
	#name : 'CPEdge',
	#superclass : 'CPDiagramElement',
	#instVars : [
		'waypoints'
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

{ #category : 'testing' }
CPEdge >> isEdge [
	^ true
]
