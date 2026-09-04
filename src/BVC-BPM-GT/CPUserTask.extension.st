Extension { #name : 'CPUserTask' }

{ #category : '*BVC-BPM-GT' }
CPUserTask class >> icon [
	^ [ (CPBpmnIcons icon: self defaultIcon) height: 20 ] asStencil
]
