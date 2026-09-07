"I resolve the staged definitional Collaboration and its DI from one root Process memento."
Class {
	#name : 'CPProcessCollaborationContext',
	#superclass : 'Object',
	#instVars : [
		'collaboration',
		'collaborationMemento',
		'participantsDescription',
		'messageFlowsDescription',
		'diagram',
		'diagramMemento',
		'elementsDescription'
	],
	#category : 'BVC-BPM-Magritte-Diagram',
	#package : 'BVC-BPM-Magritte',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessCollaborationContext class >> inRootMemento: aProcessMemento [
	| collaborationDescription collaboration collaborationMemento participantsDescription messageFlowsDescription diagramDescription diagram diagramMemento elementsDescription |
	collaborationDescription := aProcessMemento magritteDescription
		detect: [ :each | each handlesSelector: #definitionalCollaborationRef ].
	collaboration := aProcessMemento readUsing: collaborationDescription.
	collaboration ifNil: [ ^ nil ].
	collaborationMemento := aProcessMemento
		childMementoFor: collaboration
		inRelation: collaborationDescription.
	participantsDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #participants ].
	messageFlowsDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #messageFlows ].
	diagramDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	diagram := collaborationMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ nil ].
	diagramMemento := collaborationMemento
		childMementoFor: diagram
		inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	^ self new
		collaboration: collaboration;
		collaborationMemento: collaborationMemento;
		participantsDescription: participantsDescription;
		messageFlowsDescription: messageFlowsDescription;
		diagram: diagram;
		diagramMemento: diagramMemento;
		elementsDescription: elementsDescription;
		yourself
]

{ #category : 'accessing' }
CPProcessCollaborationContext >> collaboration [ ^ collaboration ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> collaboration: anObject [ collaboration := anObject ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> collaborationMemento [ ^ collaborationMemento ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> collaborationMemento: anObject [ collaborationMemento := anObject ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> participantsDescription [ ^ participantsDescription ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> participantsDescription: anObject [ participantsDescription := anObject ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> participants [
	^ collaborationMemento readUsing: participantsDescription
]

{ #category : 'accessing' }
CPProcessCollaborationContext >> messageFlowsDescription [ ^ messageFlowsDescription ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> messageFlowsDescription: anObject [ messageFlowsDescription := anObject ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> messageFlows [
	^ collaborationMemento readUsing: messageFlowsDescription
]
{ #category : 'accessing' }
CPProcessCollaborationContext >> diagram [ ^ diagram ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> diagram: anObject [ diagram := anObject ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> diagramMemento [ ^ diagramMemento ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> diagramMemento: anObject [ diagramMemento := anObject ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> elementsDescription [ ^ elementsDescription ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> elementsDescription: anObject [ elementsDescription := anObject ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> elements [
	^ diagramMemento readUsing: elementsDescription
]


{ #category : 'resolving' }
CPProcessCollaborationContext >> mementoForMember: aModelElement [
	(self participants identityIncludes: aModelElement) ifTrue: [
		^ collaborationMemento
			childMementoFor: aModelElement
			inRelation: participantsDescription ].
	(self messageFlows identityIncludes: aModelElement) ifTrue: [
		^ collaborationMemento
			childMementoFor: aModelElement
			inRelation: messageFlowsDescription ].
	^ nil
]
