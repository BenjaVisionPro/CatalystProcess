"I represent a BPMN Collaboration used by a Process as its definitional Collaboration.

I own the Participants that define the interacting Pools and the MessageFlows exchanged between their interaction nodes. The Process references me through definitionalCollaborationRef; I am not a FlowElement and do not belong to the Process flowElements collection."
Class {
	#name : 'CPCollaboration',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'participants',
		'messageFlows',
		'diagram'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPCollaboration >> initialize [
	super initialize.
	participants := OrderedCollection new.
	messageFlows := OrderedCollection new
]

{ #category : 'accessing' }
CPCollaboration >> participants [
	^ participants
]

{ #category : 'accessing' }
CPCollaboration >> participants: aCollection [
	participants := aCollection asOrderedCollection
]

{ #category : 'adding' }
CPCollaboration >> addParticipant: aParticipant [
	(participants identityIncludes: aParticipant) ifFalse: [
		participants add: aParticipant ]
]

{ #category : 'removing' }
CPCollaboration >> removeParticipant: aParticipant [
	participants remove: aParticipant ifAbsent: [ ]
]

{ #category : 'accessing' }
CPCollaboration >> messageFlows [
	^ messageFlows
]

{ #category : 'accessing' }
CPCollaboration >> messageFlows: aCollection [
	messageFlows := aCollection asOrderedCollection
]

{ #category : 'adding' }
CPCollaboration >> addMessageFlow: aMessageFlow [
	(messageFlows identityIncludes: aMessageFlow) ifFalse: [
		messageFlows add: aMessageFlow ]
]

{ #category : 'removing' }
CPCollaboration >> removeMessageFlow: aMessageFlow [
	messageFlows remove: aMessageFlow ifAbsent: [ ]
]

{ #category : 'descriptions' }
CPCollaboration >> participantsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #participants;
		classes: { CPParticipant };
		reference: CPParticipant new labelDescription;
		label: 'Participants';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'descriptions' }
CPCollaboration >> messageFlowsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #messageFlows;
		classes: { CPMessageFlow };
		reference: CPMessageFlow new labelDescription;
		label: 'Message flows';
		priority: 110;
		group: 'Relations';
		yourself
]

{ #category : 'resolving' }
CPCollaboration >> participantForEndpoint: anEndpoint [
	anEndpoint ifNil: [ ^ nil ].
	anEndpoint isParticipant ifTrue: [
		^ (participants identityIncludes: anEndpoint)
			ifTrue: [ anEndpoint ]
			ifFalse: [ nil ] ].
	^ self participantForProcess: anEndpoint owningProcess
]

{ #category : 'resolving' }
CPCollaboration >> participantForProcess: aProcess [
	aProcess ifNil: [ ^ nil ].
	^ participants
		detect: [ :each | each processRef == aProcess ]
		ifNone: [ nil ]
]


{ #category : 'accessing' }
CPCollaboration >> diagram [
	^ diagram
]

{ #category : 'accessing' }
CPCollaboration >> diagram: aDiagram [
	diagram := aDiagram.
	diagram ifNotNil: [ :aCollaborationDiagram |
		aCollaborationDiagram modelElement: self ]
]

{ #category : 'descriptions' }
CPCollaboration >> diagramDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #diagram;
		classes: { CPDiagram };
		label: 'Diagram';
		priority: 120;
		group: 'Diagram';
		yourself
]
