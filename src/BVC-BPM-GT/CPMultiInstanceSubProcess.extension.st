Extension { #name : 'CPMultiInstanceSubProcess' }

{ #category : '*BVC-BPM-GT' }
CPMultiInstanceSubProcess class >> icon [
	^ [ (FontAwesomeIcons icon: self subProcessTypeIcon) height: 20 ] asStencil
]
