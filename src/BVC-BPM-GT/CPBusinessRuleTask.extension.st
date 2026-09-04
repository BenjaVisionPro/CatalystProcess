Extension { #name : 'CPBusinessRuleTask' }

{ #category : '*BVC-BPM-GT' }
CPBusinessRuleTask class >> icon [
	^ [ (FontAwesomeIcons icon: self taskTypeIcon) height: 20 ] asStencil
]
