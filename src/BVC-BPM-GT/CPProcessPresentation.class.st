"I am the visual Magritte presentation for a CPProcess.

I render the process's staged diagram using ordinary Bloc elements. I am a sibling of Foundation Detail: Detail remains the form-oriented editor while I provide the spatial Process representation over the same Magritte/memento model."
Class {
	#name : 'CPProcessPresentation',
	#superclass : 'CFMaPresentation',
	#instVars : [
		'diagramElement'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'private - building' }
CPProcessPresentation >> prepareHostElement [
	diagramElement := CPProcessVisualElement new
		memento: self memento;
		yourself.
	self hostElement
		hMatchParent;
		vMatchParent;
		addChild: diagramElement
]

{ #category : 'visiting-description' }
CPProcessPresentation >> visitContainer: aDescription [
	"The Process diagram is the visual representation of the root description.
	Its semantic descriptions remain available to the memento and to other
	presentations such as Foundation Detail."
	aDescription == self objectDescription ifTrue: [ ^ self ].
	^ super visitContainer: aDescription
]

{ #category : 'accessing - testing' }
CPProcessPresentation >> diagramElement [
	^ diagramElement
]
