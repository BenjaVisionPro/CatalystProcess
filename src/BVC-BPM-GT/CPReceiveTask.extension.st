Extension { #name : 'CPReceiveTask' }

{ #category : '*BVC-BPM-GT' }
CPReceiveTask class >> icon [
	^ [ (FontAwesomeIcons icon: self taskTypeIcon) height: 20 ] asStencil
]
