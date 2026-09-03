Extension { #name : 'CPProcess' }

{ #category : '*BVC-BPM-Atelier' }
CPProcess >> asAtelier [
	| memento configuration |
	memento := CFMaMemento model: self.
	configuration := CPProcessAtelierConfiguration forProcessMemento: memento.
	^ (CFAtelierViewModel forObject: self memento: memento)
		configuration: configuration;
		yourself
]
