"I am the explicit Atelier contract for interpreting one existing CPDefinitions root element inside a target Process.

Subclasses materialize the Process-side semantic element without changing the Definitions-owned source. GT may ask modelElement for presentation geometry, then supply bounds before assessment/application."
Class {
	#name : 'CPAtelierReferenceDefinitionsRootElement',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'bounds'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierReferenceDefinitionsRootElement >> bounds [
	^ bounds
]

{ #category : 'accessing' }
CPAtelierReferenceDefinitionsRootElement >> bounds: aRectangle [
	bounds := aRectangle
]

{ #category : 'accessing' }
CPAtelierReferenceDefinitionsRootElement >> modelElement [
	^ self subclassResponsibility
]
