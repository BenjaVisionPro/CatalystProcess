Extension { #name : 'CPUserTask' }

{ #category : '*BVC-BPM-GT' }
CPUserTask class >> icon [
	^ [ (FontAwesomeIcons icon: self taskTypeIcon) height: 20 ] asStencil
]
