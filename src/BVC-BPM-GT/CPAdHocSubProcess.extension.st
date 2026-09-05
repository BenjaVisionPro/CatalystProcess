Extension { #name : 'CPAdHocSubProcess' }

{ #category : '*BVC-BPM-GT' }
CPAdHocSubProcess class >> icon [
	^ [ (FontAwesomeIcons icon: self subProcessTypeIcon) height: 20 ] asStencil
]
