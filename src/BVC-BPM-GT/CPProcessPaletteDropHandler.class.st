"I adapt Bloc drop handling for Process palette targets.

BlDropHandler consumes every drag that crosses its target. Process nodes are themselves draggable, so I enter the inherited drop protocol only for drags originating from the single enclosing Atelier palette."
Class {
	#name : 'CPProcessPaletteDropHandler',
	#superclass : 'BlDropHandler',
	#instVars : [
		'acceptsCurrentDrag'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}


{ #category : 'initialization' }
CPProcessPaletteDropHandler >> initialize [
	super initialize.
	acceptsCurrentDrag := false
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> itemsEnteredEvent: anEvent [
	acceptsCurrentDrag := anEvent mayAcceptItems.
	super itemsEnteredEvent: anEvent
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> itemsLeftEvent: anEvent [
	acceptsCurrentDrag := false.
	super itemsLeftEvent: anEvent
]

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
	((self isPaletteDragEvent: anEvent) and: [ acceptsCurrentDrag ])
		ifTrue: [ super dragEvent: anEvent ]
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> dragLeaveEvent: anEvent [
	(self isPaletteDragEvent: anEvent) ifTrue: [ super dragLeaveEvent: anEvent ]
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> dropEvent: anEvent [
	((self isPaletteDragEvent: anEvent) and: [ acceptsCurrentDrag ])
		ifTrue: [ super dropEvent: anEvent ]
]
