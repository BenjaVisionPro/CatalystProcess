"I am the Foundation Magritte editing transaction for a CPProcessDesign.

I keep Process lifecycle metadata at the Process layer: a successful commit that actually contains staged Process edits advances updatedAt. A commit with no staged changes and reset do not touch updatedAt. All embedded-object transaction behaviour remains inherited from CFMaMemento."
Class {
	#name : 'CPProcessDesignMemento',
	#superclass : 'CFMaMemento',
	#category : 'BVC-BPM-Atelier-Editing',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Editing'
}

{ #category : 'actions' }
CPProcessDesignMemento >> commit [
	| wasChanged result |
	wasChanged := self hasChangesToCommit.
	result := super commit.
	wasChanged ifTrue: [ self model updatedAt: DateAndTime now ].
	^ result
]


{ #category : 'private - children' }
CPProcessDesignMemento >> newChildMementoFor: anObject [
	"Process lifecycle metadata belongs only to the root Process transaction. Embedded
	nodes and edges participate through ordinary Foundation child mementos."
	^ CFMaMemento model: anObject
]
