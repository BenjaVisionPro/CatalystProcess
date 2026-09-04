Extension { #name : 'CPManualTask' }

{ #category : '*BVC-BPM-GT' }
CPManualTask class >> icon [
	^ [ (FontAwesomeIcons icon: self taskTypeIcon) height: 20 ] asStencil
]
