Extension { #name : 'CPServiceTask' }

{ #category : '*BVC-BPM-GT' }
CPServiceTask class >> icon [
	^ [ (CPBpmnIcons icon: self defaultIcon) height: 20 ] asStencil
]
