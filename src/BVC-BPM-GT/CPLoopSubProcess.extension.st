Extension { #name : 'CPLoopSubProcess' }

{ #category : '*BVC-BPM-GT' }
CPLoopSubProcess class >> icon [
	^ [ (FontAwesomeIcons icon: self subProcessTypeIcon) height: 20 ] asStencil
]
