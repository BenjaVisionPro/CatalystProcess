"I adapt Bloc drop handling for Process palette targets.

BlDropHandler consumes every drag that crosses its target. Process nodes are themselves draggable, so I enter the inherited drop protocol only for drags originating from the single enclosing Atelier palette.

I do not cache delegate acceptance from BlItemsEnteredEvent. Bloc dispatches that event on the target element, so every BlDropHandler installed on that element receives it regardless of which delegate produced it. Process therefore installs one palette drop handler per concrete element drop surface and composes competing meanings inside that handler."
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
