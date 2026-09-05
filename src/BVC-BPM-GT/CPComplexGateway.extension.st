Extension { #name : 'CPComplexGateway' }

{ #category : '*BVC-BPM-GT' }
CPComplexGateway class >> icon [
	^ [ (FontAwesomeIcons icon: self gatewayTypeIcon) height: 20 ] asStencil
]
