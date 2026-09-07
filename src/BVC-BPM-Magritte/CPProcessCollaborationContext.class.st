"I resolve the staged definitional Collaboration and its DI from one root Process memento.

I own the CPDiagramMementoContext for the Collaboration plane so callers share one staged DI boundary instead of reconstructing diagram/memento/description triples."
Class {
	#name : 'CPProcessCollaborationContext',
	#superclass : 'Object',
	#instVars : [
		'rootProcessMemento',
		'collaboration',
		'collaborationMemento',
		'participantsDescription',
		'messageFlowsDescription',
		'diagramContext'
	],
	#category : 'BVC-BPM-Magritte-Diagram',
	#package : 'BVC-BPM-Magritte',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessCollaborationContext class >> inRootMemento: aProcessMemento [
	| collaborationDescription collaboration collaborationMemento participantsDescription messageFlowsDescription diagramDescription diagram diagramContext |
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
	diagramContext := CPDiagramMementoContext
		diagram: diagram
		inMemento: collaborationMemento
		using: diagramDescription.
	^ self new
		rootProcessMemento: aProcessMemento;
		collaboration: collaboration;
		collaborationMemento: collaborationMemento;
		participantsDescription: participantsDescription;
		messageFlowsDescription: messageFlowsDescription;
		diagramContext: diagramContext;
		yourself
]

{ #category : 'accessing' }
CPProcessCollaborationContext >> rootProcessMemento [ ^ rootProcessMemento ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> rootProcessMemento: aMemento [ rootProcessMemento := aMemento ]

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
CPProcessCollaborationContext >> diagramContext [ ^ diagramContext ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> diagramContext: aDiagramContext [ diagramContext := aDiagramContext ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> diagram [ ^ diagramContext diagram ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> diagramMemento [ ^ diagramContext diagramMemento ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> elementsDescription [ ^ diagramContext elementsDescription ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> elements [
	^ diagramContext elements
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


{ #category : 'staged state' }
CPProcessCollaborationContext >> stagedSourceOf: aMessageFlow [
	| messageFlowMemento description |
	messageFlowMemento := self mementoForMember: aMessageFlow.
	messageFlowMemento ifNil: [ ^ nil ].
	description := messageFlowMemento magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	^ messageFlowMemento readUsing: description
]


{ #category : 'staged state' }
CPProcessCollaborationContext >> stagedTargetOf: aMessageFlow [
	| messageFlowMemento description |
	messageFlowMemento := self mementoForMember: aMessageFlow.
	messageFlowMemento ifNil: [ ^ nil ].
	description := messageFlowMemento magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	^ messageFlowMemento readUsing: description
]


{ #category : 'accessing' }
CPProcessCollaborationContext >> processRefOf: aParticipant [
	| participantMemento description |
	participantMemento := collaborationMemento
		childMementoFor: aParticipant
		inRelation: participantsDescription.
	description := participantMemento magritteDescription
		detect: [ :each | each handlesSelector: #processRef ].
	^ participantMemento readUsing: description
]


{ #category : 'resolving' }
CPProcessCollaborationContext >> participantForEndpoint: anEndpoint [
	| process |
	anEndpoint ifNil: [ ^ nil ].
	anEndpoint isParticipant ifTrue: [
		^ (self participants identityIncludes: anEndpoint)
			ifTrue: [ anEndpoint ]
			ifFalse: [ nil ] ].
	process := self processForEndpoint: anEndpoint.
	^ self participantForProcess: process
]


{ #category : 'resolving' }
CPProcessCollaborationContext >> participantForProcess: aProcess [
	aProcess ifNil: [ ^ nil ].
	^ self participants
		detect: [ :each | (self processRefOf: each) == aProcess ]
		ifNone: [ nil ]
]


{ #category : 'private - resolving' }
CPProcessCollaborationContext >> processForEndpoint: anEndpoint [
	| stagedContext |
	stagedContext := CPProcessFlowContainerContext
		containingFlowElement: anEndpoint
		inRootMemento: rootProcessMemento.
	stagedContext ifNotNil: [ ^ rootProcessMemento model ].
	^ anEndpoint owningProcess
]
