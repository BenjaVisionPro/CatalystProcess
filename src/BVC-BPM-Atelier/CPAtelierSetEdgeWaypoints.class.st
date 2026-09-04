Class {
	#name : 'CPAtelierSetEdgeWaypoints',
	#superclass : 'CFAtelierOperation',
	#instVars : [ 'edge', 'waypoints', 'processMemento', 'diagramDescription' ],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetEdgeWaypoints class >> edge: anEdge waypoints: somePoints processMemento: aMemento diagramDescription: aDescription [
	^ self new edge: anEdge; waypoints: somePoints; processMemento: aMemento; diagramDescription: aDescription; yourself
]

{ #category : 'assessing' }
CPAtelierSetEdgeWaypoints >> assess [
	| diagram diagramMemento elementsDescription elements occurrences edgeMemento waypointsDescription currentWaypoints proposed |
	edge ifNil: [ ^ self rejectedWithCurrentWaypoints: nil because: 'A diagram edge is required.' ].
	waypoints ifNil: [ ^ self rejectedWithCurrentWaypoints: nil because: 'Edge waypoints are required.' ].
	waypoints size < 2 ifTrue: [ ^ self rejectedWithCurrentWaypoints: nil because: 'An edge requires at least two waypoints.' ].
	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedWithCurrentWaypoints: nil because: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	occurrences := elements count: [ :each | each == edge ].
	occurrences = 1 ifFalse: [ ^ self rejectedWithCurrentWaypoints: nil because: 'The edge must occur exactly once in the staged diagram.' ].
	edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
	waypointsDescription := edgeMemento magritteDescription detect: [ :each | each handlesSelector: #waypoints ].
	currentWaypoints := edgeMemento readUsing: waypointsDescription.
	proposed := waypoints asOrderedCollection.
	currentWaypoints = proposed ifTrue: [ ^ self rejectedWithCurrentWaypoints: currentWaypoints because: 'The edge already has the requested waypoints.' ].
	[ waypointsDescription validate: proposed ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedWithCurrentWaypoints: currentWaypoints because: anException printString ].
	^ CPAtelierSetEdgeWaypointsAssessment edge: edge currentWaypoints: currentWaypoints proposedWaypoints: proposed
]

{ #category : 'applying' }
CPAtelierSetEdgeWaypoints >> applyAssessment: anAssessment [
	| diagram diagramMemento elementsDescription edgeMemento waypointsDescription |
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription detect: [ :each | each handlesSelector: #elements ].
	edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
	waypointsDescription := edgeMemento magritteDescription detect: [ :each | each handlesSelector: #waypoints ].
	edgeMemento write: anAssessment proposedWaypoints using: waypointsDescription
]

{ #category : 'private' }
CPAtelierSetEdgeWaypoints >> rejectedWithCurrentWaypoints: currentWaypoints because: aString [
	^ CPAtelierSetEdgeWaypointsAssessment edge: edge currentWaypoints: currentWaypoints proposedWaypoints: waypoints rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierSetEdgeWaypoints >> edge: anObject [ edge := anObject ]
{ #category : 'accessing' }
CPAtelierSetEdgeWaypoints >> waypoints: aCollection [ waypoints := aCollection ]
{ #category : 'accessing' }
CPAtelierSetEdgeWaypoints >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierSetEdgeWaypoints >> diagramDescription: aDescription [ diagramDescription := aDescription ]
