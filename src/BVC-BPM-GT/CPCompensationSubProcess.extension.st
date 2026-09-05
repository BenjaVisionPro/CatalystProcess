Extension { #name : 'CPCompensationSubProcess' }

{ #category : '*BVC-BPM-GT' }
CPCompensationSubProcess class >> icon [
	^ [ (FontAwesomeIcons icon: self subProcessTypeIcon) height: 20 ] asStencil
]
