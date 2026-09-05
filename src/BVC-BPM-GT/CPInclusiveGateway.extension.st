Extension { #name : 'CPInclusiveGateway' }

{ #category : '*BVC-BPM-GT' }
CPInclusiveGateway class >> icon [
	^ [ (FontAwesomeIcons icon: self gatewayTypeIcon) height: 20 ] asStencil
]
