"I represent a BPMN Participant, depicted as a Pool in a Collaboration.

My optional processRef identifies the Process displayed within the Pool. A nil processRef represents a black-box Participant."
Class {
	#name : 'CPParticipant',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'processRef'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPParticipant >> processRef [
	^ processRef
]

{ #category : 'accessing' }
CPParticipant >> processRef: aProcess [
	processRef := aProcess
]

{ #category : 'descriptions' }
CPParticipant >> processRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #processRef;
		classes: { CPProcess };
		reference: CPProcess new labelDescription;
		label: 'Process';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'testing' }
CPParticipant >> isParticipant [
	^ true
]

{ #category : 'message flow' }
CPParticipant >> canBeMessageFlowEndpoint [
	^ true
]
