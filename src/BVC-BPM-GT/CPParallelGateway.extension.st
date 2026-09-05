Extension { #name : 'CPParallelGateway' }

{ #category : '*BVC-BPM-GT' }
CPParallelGateway class >> icon [
	^ [ (FontAwesomeIcons icon: self gatewayTypeIcon) height: 20 ] asStencil
]
