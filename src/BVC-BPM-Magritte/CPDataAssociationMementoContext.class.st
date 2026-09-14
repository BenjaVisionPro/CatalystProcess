"I resolve one staged BPMN DataAssociation through the FlowElement relation that owns it.

The owning Activity/Event keeps the semantic association. The Process diagram keeps its CPEdge separately. This context exposes the relation-scoped memento state without teaching diagram operations about concrete Activity/Event classes."
Class {
	#name : 'CPDataAssociationMementoContext',
	#superclass : 'Object',
	#instVars : [
		'association',
		'owner',
		'ownerMemento',
		'relationDescription'
	],
	#category : 'BVC-BPM-Magritte',
	#package : 'BVC-BPM-Magritte'
}

{ #category : 'instance creation' }
CPDataAssociationMementoContext class >> association: anAssociation owner: anOwner ownerMemento: aMemento relationDescription: aDescription [
	^ self new
		association: anAssociation;
		owner: anOwner;
		ownerMemento: aMemento;
		relationDescription: aDescription;
		yourself
]

{ #category : 'staged state' }
CPDataAssociationMementoContext >> stagedAssociations [
	^ ownerMemento readUsing: relationDescription
]

{ #category : 'staged state' }
CPDataAssociationMementoContext >> associationMemento [
	^ ownerMemento
		childMementoFor: association
		inRelation: relationDescription
]

{ #category : 'staged state' }
CPDataAssociationMementoContext >> writeAssociations: aCollection [
	ownerMemento write: aCollection using: relationDescription
]

{ #category : 'staged state' }
CPDataAssociationMementoContext >> validateAssociations: aCollection [
	relationDescription validate: aCollection
]

{ #category : 'staged state' }
CPDataAssociationMementoContext >> detachAssociationMemento [
	ownerMemento
		detachChildMementoFor: association
		inRelation: relationDescription
]

{ #category : 'accessing' }
CPDataAssociationMementoContext >> association [ ^ association ]

{ #category : 'accessing' }
CPDataAssociationMementoContext >> association: anObject [ association := anObject ]

{ #category : 'accessing' }
CPDataAssociationMementoContext >> owner [ ^ owner ]

{ #category : 'accessing' }
CPDataAssociationMementoContext >> owner: anObject [ owner := anObject ]

{ #category : 'accessing' }
CPDataAssociationMementoContext >> ownerMemento [ ^ ownerMemento ]

{ #category : 'accessing' }
CPDataAssociationMementoContext >> ownerMemento: anObject [ ownerMemento := anObject ]

{ #category : 'accessing' }
CPDataAssociationMementoContext >> relationDescription [ ^ relationDescription ]

{ #category : 'accessing' }
CPDataAssociationMementoContext >> relationDescription: anObject [ relationDescription := anObject ]
