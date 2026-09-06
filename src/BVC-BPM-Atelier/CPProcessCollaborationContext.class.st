"I resolve the staged definitional Collaboration and its DI from one root Process memento."
Class {
	#name : 'CPProcessCollaborationContext',
	#superclass : 'Object',
	#instVars : [
		'collaboration',
		'collaborationMemento',
		'messageFlowsDescription',
		'messageFlows',
		'diagram',
		'diagramMemento',
		'elementsDescription',
		'elements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessCollaborationContext class >> inRootMemento: aProcessMemento [
	| collaborationDescription collaboration collaborationMemento messageFlowsDescription messageFlows diagramDescription diagram diagramMemento elementsDescription elements |
	collaborationDescription := aProcessMemento magritteDescription
		detect: [ :each | each handlesSelector: #definitionalCollaborationRef ].
	collaboration := aProcessMemento readUsing: collaborationDescription.
	collaboration ifNil: [ ^ nil ].
	collaborationMemento := aProcessMemento
		childMementoFor: collaboration
		inRelation: collaborationDescription.
	messageFlowsDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #messageFlows ].
	messageFlows := collaborationMemento readUsing: messageFlowsDescription.
	diagramDescription := collaborationMemento magritteDescription
		detect: [ :each | each handlesSelector: #diagram ].
	diagram := collaborationMemento readUsing: diagramDescription.
	diagram ifNil: [ ^ nil ].
	diagramMemento := collaborationMemento
		childMementoFor: diagram
		inRelation: diagramDescription.
	elementsDescription := diagramMemento magritteDescription
		detect: [ :each | each handlesSelector: #elements ].
	elements := diagramMemento readUsing: elementsDescription.
	^ self new
		collaboration: collaboration;
		collaborationMemento: collaborationMemento;
		messageFlowsDescription: messageFlowsDescription;
		messageFlows: messageFlows;
		diagram: diagram;
		diagramMemento: diagramMemento;
		elementsDescription: elementsDescription;
		elements: elements;
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
CPProcessCollaborationContext >> messageFlowsDescription [ ^ messageFlowsDescription ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> messageFlowsDescription: anObject [ messageFlowsDescription := anObject ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> messageFlows [ ^ messageFlows ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> messageFlows: anObject [ messageFlows := anObject ]
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
CPProcessCollaborationContext >> elements [ ^ elements ]
{ #category : 'accessing' }
CPProcessCollaborationContext >> elements: anObject [ elements := anObject ]
