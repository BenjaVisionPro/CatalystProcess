Extension { #name : 'CPNoneSubProcess' }

{ #category : '*BVC-BPM-GT' }
CPNoneSubProcess class >> icon [
	^ [ (FontAwesomeIcons icon: self subProcessTypeIcon) height: 20 ] asStencil
]
