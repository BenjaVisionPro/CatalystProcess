Extension { #name : 'CPProcess' }

{ #category : '*BVC-BPM-Atelier' }
CPProcess >> asAtelier [
	"Compatibility navigation entry while callers are migrated to CPDefinitions. Even this bridge now enters through a Definitions-rooted transaction; the legacy Process-owned diagram relation is used only to recover the depiction that old callers cannot yet supply explicitly."
	| definitions currentDiagram |
	currentDiagram := self diagram.
	definitions := CPDefinitions new
		addRootElement: self;
		yourself.
	currentDiagram ifNotNil: [ definitions addDiagram: currentDiagram ].
	^ currentDiagram
		ifNil: [ (CPProcessAtelierSession
			forDefinitions: definitions
			process: self
			diagram: nil) asViewModel ]
		ifNotNil: [ definitions
			asAtelierForProcess: self
			diagram: currentDiagram ]
]
