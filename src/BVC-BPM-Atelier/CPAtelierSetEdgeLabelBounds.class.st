Class {
	#name : 'CPAtelierSetEdgeLabelBounds',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'edge',
		'bounds',
		'processMemento',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetEdgeLabelBounds class >> edge: anEdge bounds: aRectangle processMemento: aMemento diagramDescription: aDescription [
	^ self new
		edge: anEdge;
		bounds: aRectangle;
		processMemento: aMemento;
		diagramDescription: aDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierSetEdgeLabelBounds >> assess [
	| diagram diagramMemento elementsDescription elements edgeMemento description currentBounds |
	edge ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'A diagram edge is required.' ].
	bounds ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'Label bounds are required.' ].
	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ self rejectedWithCurrentBounds: nil because: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	(elements identityIncludes: edge) ifFalse: [
		^ self rejectedWithCurrentBounds: nil because: 'The edge does not belong to the staged diagram.' ].
	edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelBounds ].
	currentBounds := edgeMemento readUsing: description.
	currentBounds = bounds ifTrue: [
		^ self rejectedWithCurrentBounds: currentBounds because: 'The edge label already has the requested bounds.' ].
	[ description validate: bounds ]
		on: MAValidationError
		do: [ :anException |
			^ self rejectedWithCurrentBounds: currentBounds because: anException printString ].
	^ CPAtelierSetEdgeLabelBoundsAssessment
		edge: edge
		currentBounds: currentBounds
		proposedBounds: bounds
]

{ #category : 'applying' }
CPAtelierSetEdgeLabelBounds >> applyAssessment: anAssessment [
	| diagram diagramMemento elementsDescription edgeMemento description |
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	edgeMemento := diagramMemento childMementoFor: edge inRelation: elementsDescription.
	description := edgeMemento magritteDescription
		detect: [ :each | each handlesSelector: #labelBounds ].
	edgeMemento write: anAssessment proposedBounds using: description
]

{ #category : 'private' }
CPAtelierSetEdgeLabelBounds >> rejectedWithCurrentBounds: currentBounds because: aString [
	^ CPAtelierSetEdgeLabelBoundsAssessment
		edge: edge
		currentBounds: currentBounds
		proposedBounds: bounds
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierSetEdgeLabelBounds >> edge: anEdge [ edge := anEdge ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelBounds >> bounds: aRectangle [ bounds := aRectangle ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelBounds >> processMemento: aMemento [ processMemento := aMemento ]
{ #category : 'accessing' }
CPAtelierSetEdgeLabelBounds >> diagramDescription: aDescription [ diagramDescription := aDescription ]
