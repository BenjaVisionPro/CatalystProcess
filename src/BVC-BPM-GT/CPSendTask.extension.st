Extension { #name : 'CPSendTask' }

{ #category : '*BVC-BPM-GT' }
CPSendTask class >> icon [
	^ [ (FontAwesomeIcons icon: self taskTypeIcon) height: 20 ] asStencil
]
