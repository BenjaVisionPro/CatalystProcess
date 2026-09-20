Extension { #name : 'CPCompensationStartEvent' }

{ #category : '*BVC-BPM-GT' }
CPCompensationStartEvent class >> icon [
	^ [ (FontAwesomeIcons icon: self eventTypeIcon) height: 20 ] asStencil
]
