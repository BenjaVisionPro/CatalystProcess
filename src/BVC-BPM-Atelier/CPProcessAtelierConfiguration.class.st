"I configure Atelier editing intentions for the production CPProcess visual presentation.

The semantic model remains Magritte-described. I retain the exact root diagram description and translate one visual move gesture into CPAtelierMoveShape. Presentation selection remains owned by the CPProcess Magritte container."
Class {
	#name : 'CPProcessAtelierConfiguration',
	#superclass : 'CFAtelierConfiguration',
	#instVars : [
		'diagramDescription'
	],
	#category : 'BVC-BPM-Atelier-Configuration',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Configuration'
}

{ #category : 'instance creation' }
CPProcessAtelierConfiguration class >> forProcessMemento: aProcessMemento [
	| description |
	description := aProcessMemento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	^ self new
		diagramDescription: description;
		yourself
]

{ #category : 'applying' }
CPProcessAtelierConfiguration >> applyEditingTo: anAtelierViewModel [
	super applyEditingTo: anAtelierViewModel.
	anAtelierViewModel presentationDo: [ :aPresentation |
		aPresentation moveShapeOperationFor: [ :aShape :proposedBounds |
			CPAtelierMoveShape
				shape: aShape
				bounds: proposedBounds
				processMemento: aPresentation memento
				diagramDescription: diagramDescription ] ].
	^ anAtelierViewModel
]

{ #category : 'accessing' }
CPProcessAtelierConfiguration >> diagramDescription [
	^ diagramDescription
]

{ #category : 'accessing' }
CPProcessAtelierConfiguration >> diagramDescription: aDescription [
	diagramDescription := aDescription
]
