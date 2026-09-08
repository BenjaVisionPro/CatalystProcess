"I adapt Bloc drop handling for Process palette targets.

BlDropHandler consumes every drag that crosses its target. Process nodes are themselves draggable, so I enter the inherited drop protocol only for drags originating from the single enclosing Atelier palette."
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

{ #category : 'private - testing' }
CPProcessPaletteDropHandler >> isPaletteItemsEvent: anItemsEvent [
	anItemsEvent items ifEmpty: [ ^ false ].
	^ anItemsEvent items allSatisfy: [ :aDragItem |
		| source |
		source := aDragItem sourceElement.
		source notNil and: [ source userData includesKey: #atelierPaletteSource ] ]
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> itemsDroppedEvent: anEvent [
	(self isPaletteItemsEvent: anEvent) ifTrue: [ super itemsDroppedEvent: anEvent ]
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> itemsDraggedEvent: anEvent [
	(self isPaletteItemsEvent: anEvent) ifTrue: [ super itemsDraggedEvent: anEvent ]
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> itemsEnteredEvent: anEvent [
	(self isPaletteItemsEvent: anEvent) ifTrue: [ super itemsEnteredEvent: anEvent ]
]
