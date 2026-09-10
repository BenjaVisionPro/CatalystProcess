Extension { #name : 'CPProcess' }

{ #category : '*BVC-BPM-Atelier' }
CPProcess >> asAtelier [
	^ (CPProcessAtelierSession
		forProcessMemento: (CFMaMemento model: self)) asViewModel
]
