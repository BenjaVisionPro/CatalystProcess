Extension { #name : 'CPEventBasedGateway' }

{ #category : '*BVC-BPM-GT' }
CPEventBasedGateway class >> icon [
	^ [ (FontAwesomeIcons icon: self gatewayTypeIcon) height: 20 ] asStencil
]
