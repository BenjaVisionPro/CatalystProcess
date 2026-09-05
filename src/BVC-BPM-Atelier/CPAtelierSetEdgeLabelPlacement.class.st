Class {
	#name : 'CPAtelierSetEdgeLabelPlacement',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'edge',
		'pathPosition',
		'offset',
		'processMemento',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetEdgeLabelPlacement class >> edge: anEdge pathPosition: aPathPosition offset: anOffset processMemento: aMemento diagramDescription: aDescription [
	^ self new
		edge: anEdge;
		pathPosition: aPathPosition;
		offset: anOffset;
		processMemento: aMemento;
		diagramDescription: aDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierSetEdgeLabelPlacement >> assess [
	| diagram diagramMemento elementsDescription elements edgeMemento positionDescription offsetDescription currentPosition currentOffset |
	edge ifNil: [ ^ self rejectedBecause: 'A diagram edge is required.' ].
	pathPosition ifNil: [ ^ self rejectedBecause: 'A label path position is required.' ].
	offset ifNil: [ ^ self rejectedBecause: 'A label offset is required.' ].
	(pathPosition between: 0.0 and: 1.0) ifFalse: [
		^ self rejectedBecause: 'Label path position must be between 0 and 1.' ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	(elements identityIncludes: edge) ifFalse: [
		^ self rejectedBecause: 'The edge does not belong to the staged diagram.' ].

	edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
	positionDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelPathPosition ].
	offsetDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelOffset ].
	currentPosition := edgeMemento readUsing: positionDescription.
	currentOffset := edgeMemento readUsing: offsetDescription.

	[ positionDescription validate: pathPosition.
	  offsetDescription validate: offset ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierSetEdgeLabelPlacementAssessment
		edge: edge
		currentPathPosition: currentPosition
		currentOffset: currentOffset
		proposedPathPosition: pathPosition
		proposedOffset: offset
]

{ #category : 'applying' }
CPAtelierSetEdgeLabelPlacement >> applyAssessment: anAssessment [
	| diagram diagramMemento elementsDescription edgeMemento positionDescription offsetDescription |
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
	positionDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelPathPosition ].
	offsetDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelOffset ].
	edgeMemento write: anAssessment proposedPathPosition using: positionDescription.
	edgeMemento write: anAssessment proposedOffset using: offsetDescription
]

{ #category : 'private' }
CPAtelierSetEdgeLabelPlacement >> rejectedBecause: aString [
	^ CPAtelierSetEdgeLabelPlacementAssessment
		edge: edge
		currentPathPosition: nil
		currentOffset: nil
		proposedPathPosition: pathPosition
		proposedOffset: offset
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> edge: anEdge [ edge := anEdge ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> pathPosition: aNumber [ pathPosition := aNumber ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> offset: aNumber [ offset := aNumber ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> diagramDescription: aDescription [ diagramDescription := aDescription ]
