Extension { #name : 'CPIntermediateEvent' }

{ #category : '*BVC-BPM-GT' }
CPIntermediateEvent class >> icon [
	^ [ (CPBpmnIcons icon: self defaultIcon) height: 20 ] asStencil
]
