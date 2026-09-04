"I adapt Bloc drop handling for Process palette replacement targets.

BlDropHandler consumes every drag that crosses its target. Process nodes are themselves draggable, so I only enter the inherited drop protocol when the drag gesture originated from an Atelier palette source."
Class {
	#name : 'CPProcessPaletteDropHandler',
	#superclass : 'BlDropHandler',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'private - testing' }
CPProcessPaletteDropHandler >> isPaletteDragEvent: aDragEvent [
	| source |
	source := aDragEvent gestureSource.
	source ifNil: [ ^ false ].
	^ source userData includesKey: #atelierPaletteSource
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> dragEnterEvent: anEvent [
	(self isPaletteDragEvent: anEvent) ifTrue: [ super dragEnterEvent: anEvent ]
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> dragEvent: anEvent [
	(self isPaletteDragEvent: anEvent) ifTrue: [ super dragEvent: anEvent ]
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> dragLeaveEvent: anEvent [
	(self isPaletteDragEvent: anEvent) ifTrue: [ super dragLeaveEvent: anEvent ]
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> dropEvent: anEvent [
	(self isPaletteDragEvent: anEvent) ifTrue: [ super dropEvent: anEvent ]
]
