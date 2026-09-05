"I stage the BPMN DI expanded/collapsed depiction state and corresponding bounds of one CPShape.

Expansion is diagram state. For CPSubProcess I stage the expanded or collapsed geometry together with isExpanded so the depiction changes atomically. The semantic CPSubProcess remains the same object with the same contained flow elements."
Class {
	#name : 'CPAtelierSetShapeExpanded',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'shape',
		'expanded',
		'processMemento',
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetShapeExpanded class >> shape: aShape expanded: aBoolean processMemento: aMemento diagramDescription: aDiagramDescription [
	^ self new
		shape: aShape;
		expanded: aBoolean;
		processMemento: aMemento;
		diagramDescription: aDiagramDescription;
		yourself
]

{ #category : 'assessing' }
CPAtelierSetShapeExpanded >> assess [
	| diagram diagramMemento elementsDescription elements shapeMemento
	  expandedDescription boundsDescription modelDescription modelElement
	  currentExpanded currentBounds proposedBounds proposedExtent |

	shape ifNil: [
		^ self rejectedWithCurrentExpanded: nil currentBounds: nil proposedBounds: nil because: 'A diagram shape is required.' ].
	(expanded == true or: [ expanded == false ]) ifFalse: [
		^ self rejectedWithCurrentExpanded: nil currentBounds: nil proposedBounds: nil because: 'Expanded state must be Boolean.' ].

	diagram := processMemento readUsing: diagramDescription.
	diagram ifNil: [
		^ self rejectedWithCurrentExpanded: nil currentBounds: nil proposedBounds: nil because: 'The process has no staged diagram.' ].
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	(elements identityIncludes: shape) ifFalse: [
		^ self rejectedWithCurrentExpanded: nil currentBounds: nil proposedBounds: nil because: 'The shape does not belong to the staged diagram.' ].

	shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
	modelDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #modelElement ].
	modelElement := shapeMemento readUsing: modelDescription.
	(modelElement isSubProcess or: [ modelElement isCallActivity ]) ifFalse: [
		^ self rejectedWithCurrentExpanded: nil currentBounds: nil proposedBounds: nil because: 'Only expandable BPMN activities can carry expanded depiction state.' ].

	expandedDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #isExpanded ].
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	currentExpanded := shapeMemento readUsing: expandedDescription.
	currentBounds := shapeMemento readUsing: boundsDescription.
	currentExpanded = expanded ifTrue: [
		^ self
			rejectedWithCurrentExpanded: currentExpanded
			currentBounds: currentBounds
			proposedBounds: currentBounds
			because: 'The shape already has the requested expanded state.' ].

	proposedExtent := modelElement isSubProcess
		ifTrue: [
			expanded
				ifTrue: [ 360 @ 180 ]
				ifFalse: [ 132 @ 54 ] ]
		ifFalse: [ currentBounds extent ].
	proposedBounds := (currentBounds center - (proposedExtent / 2))
		extent: proposedExtent.

	[
		expandedDescription validate: expanded.
		boundsDescription validate: proposedBounds
	] on: MAValidationError do: [ :anException |
		^ self
			rejectedWithCurrentExpanded: currentExpanded
			currentBounds: currentBounds
			proposedBounds: proposedBounds
			because: anException printString ].

	^ CPAtelierSetShapeExpandedAssessment
		shape: shape
		currentExpanded: currentExpanded
		proposedExpanded: expanded
		currentBounds: currentBounds
		proposedBounds: proposedBounds
]

{ #category : 'applying' }
CPAtelierSetShapeExpanded >> applyAssessment: anAssessment [
	| diagram diagramMemento elementsDescription shapeMemento expandedDescription boundsDescription |
	diagram := processMemento readUsing: diagramDescription.
	diagramMemento := processMemento childMementoFor: diagram inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	shapeMemento := diagramMemento childMementoFor: shape inRelation: elementsDescription.
	expandedDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #isExpanded ].
	boundsDescription := shapeMemento magritteDescription
		detect: [ :each | each handlesSelector: #bounds ].
	shapeMemento write: anAssessment proposedExpanded using: expandedDescription.
	shapeMemento write: anAssessment proposedBounds using: boundsDescription
]

{ #category : 'private' }
CPAtelierSetShapeExpanded >> rejectedWithCurrentExpanded: currentExpanded currentBounds: currentBounds proposedBounds: proposedBounds because: aString [
	^ CPAtelierSetShapeExpandedAssessment
		shape: shape
		currentExpanded: currentExpanded
		proposedExpanded: expanded
		currentBounds: currentBounds
		proposedBounds: proposedBounds
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierSetShapeExpanded >> shape: anObject [ shape := anObject ]

{ #category : 'accessing' }
CPAtelierSetShapeExpanded >> expanded: aBoolean [ expanded := aBoolean ]

{ #category : 'accessing' }
CPAtelierSetShapeExpanded >> processMemento: aMemento [ processMemento := aMemento ]

{ #category : 'accessing' }
CPAtelierSetShapeExpanded >> diagramDescription: aDescription [ diagramDescription := aDescription ]
