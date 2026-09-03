Extension { #name : 'CPProcessDesign' }

{ #category : '*BVC-BPM-Atelier' }
CPProcessDesign >> asAtelier [
	| memento configuration |
	memento := CPProcessDesignMemento model: self.
	configuration := CPAtelierConfiguration forProcessMemento: memento.
	^ (CFAtelierViewModel forObject: self memento: memento)
		configuration: configuration;
		yourself
]
