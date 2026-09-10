Extension { #name : 'CPProcess' }

{ #category : '*BVC-BPM-Atelier' }
CPProcess >> asAtelier [
	"Compatibility entry while existing Process-oriented navigation is migrated to the canonical CPDefinitions entry. Keep the configured Process palette and editing adapter rather than falling through to Foundation's generic Atelier entry."
	^ (CPProcessAtelierSession
		forProcessMemento: (CFMaMemento model: self)) asViewModel
]
