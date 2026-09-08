"I adapt Bloc drop handling for Process palette targets.

BlDropHandler consumes every drag that crosses its target. Process nodes are themselves draggable, so I enter the inherited drop protocol only for drags originating from the single enclosing Atelier palette."
Class {
	#name : 'CPProcessPaletteDropHandler',
	#superclass : 'BlDropHandler',
	#instVars : [
		'dragLeavePredicate'
	],
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
	(self isPaletteDragEvent: anEvent) ifFalse: [ ^ self ].
	dragLeavePredicate ifNotNil: [
		(dragLeavePredicate value: anEvent) ifFalse: [ ^ self ] ].
	super dragLeaveEvent: anEvent
]

{ #category : 'configuration' }
CPProcessPaletteDropHandler >> handleDragLeaveWhen: aBlock [
	"Only forward a raw palette drag-leave to BlDropHandler when aBlock
	 answers true. Composite drop targets use this to distinguish leaving
	 their geometry from Bloc merely repicking one of their children."
	dragLeavePredicate := aBlock
]

{ #category : 'event handling' }
CPProcessPaletteDropHandler >> dropEvent: anEvent [
	(self isPaletteDragEvent: anEvent) ifTrue: [ super dropEvent: anEvent ]
]
