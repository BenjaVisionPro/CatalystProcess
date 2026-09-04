Extension { #name : 'CPScriptTask' }

{ #category : '*BVC-BPM-GT' }
CPScriptTask class >> icon [
	^ [ (FontAwesomeIcons icon: self taskTypeIcon) height: 20 ] asStencil
]
