Class {
	#name : 'CPFlowNode',
	#superclass : 'CPFlowElement',
	#instVars : [
		'incoming',
		'outgoing'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPFlowNode >> initialize [
	super initialize.
	incoming := OrderedCollection new.
	outgoing := OrderedCollection new
]

{ #category : 'accessing' }
CPFlowNode >> incoming [
	^ incoming
]

{ #category : 'accessing' }
CPFlowNode >> outgoing [
	^ outgoing
]

{ #category : 'private - flow' }
CPFlowNode >> addIncoming: aSequenceFlow [
	(incoming includes: aSequenceFlow) ifFalse: [ incoming add: aSequenceFlow ]
]

{ #category : 'private - flow' }
CPFlowNode >> removeIncoming: aSequenceFlow [
	incoming remove: aSequenceFlow ifAbsent: [ ]
]

{ #category : 'private - flow' }
CPFlowNode >> addOutgoing: aSequenceFlow [
	(outgoing includes: aSequenceFlow) ifFalse: [ outgoing add: aSequenceFlow ]
]

{ #category : 'private - flow' }
CPFlowNode >> removeOutgoing: aSequenceFlow [
	outgoing remove: aSequenceFlow ifAbsent: [ ]
]

{ #category : 'descriptions' }
CPFlowNode >> incomingDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #incoming;
		classes: { CPSequenceFlow };
		reference: self labelDescription;
		label: 'Incoming';
		priority: 110;
		group: 'Relations';
		beReadOnly;
		yourself
]

{ #category : 'descriptions' }
CPFlowNode >> outgoingDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #outgoing;
		classes: { CPSequenceFlow };
		reference: self labelDescription;
		label: 'Outgoing';
		priority: 120;
		group: 'Relations';
		beReadOnly;
		yourself
]

{ #category : 'private - containment' }
CPFlowNode >> prepareForRemovalFrom: aContainer [
	incoming copy do: [ :aSequenceFlow | aContainer removeFlowElement: aSequenceFlow ].
	outgoing copy do: [ :aSequenceFlow | aContainer removeFlowElement: aSequenceFlow ]
]

{ #category : 'testing' }
CPFlowNode >> isCallActivity [
	^ false
]

{ #category : 'testing' }
CPFlowNode >> isEvent [
	^ false
]

{ #category : 'testing' }
CPFlowNode >> isActivity [
	^ false
]

{ #category : 'testing' }
CPFlowNode >> isEndEvent [
	^ false
]

{ #category : 'testing' }
CPFlowNode >> isStartEvent [ ^ false ]

{ #category : 'testing' }
CPFlowNode >> isGateway [
	^ false
]

{ #category : 'testing' }
CPFlowNode >> isIntermediateEvent [
	^ false
]


{ #category : 'testing' }
CPFlowNode >> isSubProcess [
	^ false
]
