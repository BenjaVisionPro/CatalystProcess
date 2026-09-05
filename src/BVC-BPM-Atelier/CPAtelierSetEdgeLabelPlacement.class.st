Class {
	#name : 'CPAtelierSetEdgeLabelPlacement',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'edge',
		'segmentIndex',
		'segmentPosition',
		'offset',
		'processMemento',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetEdgeLabelPlacement class >> edge: anEdge segmentIndex: aSegmentIndex segmentPosition: aSegmentPosition offset: anOffset processMemento: aMemento diagramDescription: aDescription [
	^ self new
		edge: anEdge;
		segmentIndex: aSegmentIndex;
		segmentPosition: aSegmentPosition;
		offset: anOffset;
		processMemento: aMemento;
		diagramDescription: aDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierSetEdgeLabelPlacement >> assess [
	| diagram diagramMemento elementsDescription elements edgeMemento segmentDescription positionDescription offsetDescription currentSegment currentPosition currentOffset waypointsDescription waypoints segmentCount |
	edge ifNil: [ ^ self rejectedBecause: 'A diagram edge is required.' ].
	segmentIndex ifNil: [ ^ self rejectedBecause: 'A label segment is required.' ].
	segmentPosition ifNil: [ ^ self rejectedBecause: 'A label segment position is required.' ].
	offset ifNil: [ ^ self rejectedBecause: 'A label offset is required.' ].
	(segmentPosition between: 0.0 and: 1.0) ifFalse: [
		^ self rejectedBecause: 'Label segment position must be between 0 and 1.' ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedBecause: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	(elements identityIncludes: edge) ifFalse: [
		^ self rejectedBecause: 'The edge does not belong to the staged diagram.' ].

	edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
	waypointsDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #waypoints ].
	waypoints := edgeMemento readUsing: waypointsDescription.
	segmentCount := waypoints size - 1.
	(segmentIndex between: 1 and: segmentCount) ifFalse: [
		^ self rejectedBecause: 'Label segment is outside the edge path.' ].

	segmentDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelSegmentIndex ].
	positionDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelSegmentPosition ].
	offsetDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelOffset ].

	currentSegment := edgeMemento readUsing: segmentDescription.
	currentPosition := edgeMemento readUsing: positionDescription.
	currentOffset := edgeMemento readUsing: offsetDescription.

	[ segmentDescription validate: segmentIndex.
	  positionDescription validate: segmentPosition.
	  offsetDescription validate: offset ]
		on: MAValidationError
		do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierSetEdgeLabelPlacementAssessment
		edge: edge
		currentSegmentIndex: currentSegment
		currentSegmentPosition: currentPosition
		currentOffset: currentOffset
		proposedSegmentIndex: segmentIndex
		proposedSegmentPosition: segmentPosition
		proposedOffset: offset
]

{ #category : 'applying' }
CPAtelierSetEdgeLabelPlacement >> applyAssessment: anAssessment [
	| diagram diagramMemento elementsDescription edgeMemento segmentDescription positionDescription offsetDescription |
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
	segmentDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelSegmentIndex ].
	positionDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelSegmentPosition ].
	offsetDescription := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelOffset ].
	edgeMemento write: anAssessment proposedSegmentIndex using: segmentDescription.
	edgeMemento write: anAssessment proposedSegmentPosition using: positionDescription.
	edgeMemento write: anAssessment proposedOffset using: offsetDescription
]

{ #category : 'private' }
CPAtelierSetEdgeLabelPlacement >> rejectedBecause: aString [
	^ CPAtelierSetEdgeLabelPlacementAssessment
		edge: edge
		currentSegmentIndex: nil
		currentSegmentPosition: nil
		currentOffset: nil
		proposedSegmentIndex: segmentIndex
		proposedSegmentPosition: segmentPosition
		proposedOffset: offset
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> edge: anEdge [ edge := anEdge ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> segmentIndex: anInteger [ segmentIndex := anInteger ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> segmentPosition: aNumber [ segmentPosition := aNumber ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> offset: aNumber [ offset := aNumber ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelPlacement >> diagramDescription: aDescription [ diagramDescription := aDescription ]
