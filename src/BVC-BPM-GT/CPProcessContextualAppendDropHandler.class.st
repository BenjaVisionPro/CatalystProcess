"I enter Bloc's drop protocol only for drags started by a Process contextual append affordance. This keeps contextual composition distinct from ordinary node dragging and from Atelier palette drags while still using Bloc's native drag/drop dispatch."
Class {
	#name : 'CPProcessContextualAppendDropHandler',
	#superclass : 'BlDropHandler',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'private - testing' }
CPProcessContextualAppendDropHandler >> isContextualAppendDragEvent: aDragEvent [
	| source |
	source := aDragEvent gestureSource.
	source ifNil: [ ^ false ].
	^ source userData includesKey: #processContextualAppendContext
]

{ #category : 'event handling' }
CPProcessContextualAppendDropHandler >> dragEnterEvent: anEvent [
	(self isContextualAppendDragEvent: anEvent) ifTrue: [ super dragEnterEvent: anEvent ]
]
{ #category : 'event handling' }
CPProcessContextualAppendDropHandler >> dragEvent: anEvent [
	(self isContextualAppendDragEvent: anEvent) ifTrue: [ super dragEvent: anEvent ]
]
{ #category : 'event handling' }
CPProcessContextualAppendDropHandler >> dragLeaveEvent: anEvent [
	(self isContextualAppendDragEvent: anEvent) ifTrue: [ super dragLeaveEvent: anEvent ]
]
{ #category : 'event handling' }
CPProcessContextualAppendDropHandler >> dropEvent: anEvent [
	(self isContextualAppendDragEvent: anEvent) ifTrue: [ super dropEvent: anEvent ]
]

{ #category : 'private - testing' }
CPProcessContextualAppendDropHandler >> isContextualAppendItemsEvent: anItemsEvent [
	anItemsEvent items ifEmpty: [ ^ false ].
	^ anItemsEvent items allSatisfy: [ :aDragItem |
		| source |
		source := aDragItem sourceElement.
		source notNil and: [ source userData includesKey: #processContextualAppendContext ] ]
]

{ #category : 'event handling' }
CPProcessContextualAppendDropHandler >> itemsDroppedEvent: anEvent [
	(self isContextualAppendItemsEvent: anEvent) ifTrue: [ super itemsDroppedEvent: anEvent ]
]

{ #category : 'event handling' }
CPProcessContextualAppendDropHandler >> itemsDraggedEvent: anEvent [
	(self isContextualAppendItemsEvent: anEvent) ifTrue: [ super itemsDraggedEvent: anEvent ]
]

{ #category : 'event handling' }
CPProcessContextualAppendDropHandler >> itemsEnteredEvent: anEvent [
	(self isContextualAppendItemsEvent: anEvent) ifTrue: [ super itemsEnteredEvent: anEvent ]
]
