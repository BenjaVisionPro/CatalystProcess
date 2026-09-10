"I represent one BPMN Message Flow between interaction nodes in two separate Participants.

My source and target are BPMN InteractionNodes: Participants, Activities, or Events. Connection admissibility is owned by CPMessageFlowConnectionRules, which resolves each endpoint to its Participant and enforces cross-Pool semantics."
Class {
	#name : 'CPMessageFlow',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'sourceRef',
		'targetRef'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPMessageFlow >> sourceRef [
	^ sourceRef
]

{ #category : 'accessing' }
CPMessageFlow >> sourceRef: anInteractionNode [
	sourceRef := anInteractionNode
]

{ #category : 'accessing' }
CPMessageFlow >> targetRef [
	^ targetRef
]

{ #category : 'accessing' }
CPMessageFlow >> targetRef: anInteractionNode [
	targetRef := anInteractionNode
]

{ #category : 'descriptions' }
CPMessageFlow >> sourceRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #sourceRef;
		classes: { CPParticipant. CPActivity. CPEvent };
		reference: self labelDescription;
		label: 'Source';
		priority: 100;
		group: 'Relations';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPMessageFlow >> targetRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #targetRef;
		classes: { CPParticipant. CPActivity. CPEvent };
		reference: self labelDescription;
		label: 'Target';
		priority: 110;
		group: 'Relations';
		beRequired;
		yourself
]


{ #category : 'testing' }
CPMessageFlow >> isMessageFlow [
	^ true
]
