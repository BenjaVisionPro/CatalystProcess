"I report this Process drop surface's own BlDropDelegate acceptance back to its handler.

BlItemsEnteredEvent is dispatched on the target element and is therefore shared by every handler on that element. The delegate is the only source that can tell one handler whether its own acceptConditions accepted the current drag item."
Class {
	#name : 'CPProcessPaletteDropDelegate',
	#superclass : 'BlDropDelegate',
	#instVars : [ 'handler' ],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPProcessPaletteDropDelegate >> handler: anObject [
	handler := anObject
]

{ #category : 'testing' }
CPProcessPaletteDropDelegate >> shouldAccept: aDragItem in: anElement [
	| result |
	result := super shouldAccept: aDragItem in: anElement.
	handler ifNotNil: [ handler acceptanceChanged: result ].
	^ result
]
