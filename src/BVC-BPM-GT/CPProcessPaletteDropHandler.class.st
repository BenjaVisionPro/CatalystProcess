"I adapt Bloc drop handling for Process palette targets.

BlDropHandler consumes every drag that crosses its target. Process nodes are themselves draggable, so I enter the inherited drop protocol only for drags originating from the single enclosing Atelier palette.

I do not cache delegate acceptance from BlItemsEnteredEvent. Bloc dispatches that event on the target element, so every BlDropHandler installed on that element receives it regardless of which delegate produced it. Process therefore installs one palette drop handler per concrete element drop surface and composes competing meanings inside that handler."
Class {
	#name : 'CPProcessPaletteDropHandler',
	#superclass : 'BlDropHandler',
	#instVars : [ 'acceptsCurrentDrag' ],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'initialization' }
CPProcessPaletteDropHandler >> initialize [
	super initialize.
	acceptsCurrentDrag := false
]

{ #category : 'private - acceptance' }
CPProcessPaletteDropHandler >> acceptanceChanged: aBoolean [
	acceptsCurrentDrag := aBoolean
]

{ #category : 'accessing' }
CPProcessPaletteDropHandler >> createDropDelegate [
	^ CPProcessPaletteDropDelegate new
		acceptConditions: acceptConditions;
		handler: self;
		yourself
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
		ifTrue: [
			super dropEvent: anEvent.
			acceptsCurrentDrag := false ]
]
