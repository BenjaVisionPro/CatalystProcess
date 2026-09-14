Class {
	#name : 'CPFlowElement',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'container'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPFlowElement >> container [
	^ container
]

{ #category : 'accessing' }
CPFlowElement >> container: anObject [
	container := anObject
]

{ #category : 'descriptions' }
CPFlowElement >> containerDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #container;
		classes: { CPProcess. CPSubProcess };
		reference: CPProcess new labelDescription;
		label: 'Container';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'private - containment' }
CPFlowElement >> prepareForRemovalFrom: aContainer [
]


{ #category : 'testing' }
CPFlowElement >> isSequenceFlow [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isTask [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isSubProcess [
	^ false
]


{ #category : 'testing' }
CPFlowElement >> isParticipant [
	^ false
]

{ #category : 'message flow' }
CPFlowElement >> canBeMessageFlowEndpoint [
	^ false
]

{ #category : 'containment' }
CPFlowElement >> owningProcess [
	container ifNil: [ ^ nil ].
	^ container isSubProcess
		ifTrue: [ container owningProcess ]
		ifFalse: [ container ]
]


{ #category : 'testing' }
CPFlowElement >> isFlowNode [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isCallActivity [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isEvent [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isActivity [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isEndEvent [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isStartEvent [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isGateway [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isIntermediateEvent [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isBoundaryEvent [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isDataObjectReference [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isDataReference [
	^ false
]



{ #category : 'testing' }
CPFlowElement >> isDataAssociation [
	^ false
]

{ #category : 'testing' }
CPFlowElement >> isDataStoreReference [
	^ false
]


{ #category : 'testing' }
CPFlowElement >> isDataObject [
	^ false
]


{ #category : 'data' }
CPFlowElement >> dataAssociationDescriptions [
	^ #()
]


{ #category : 'testing' }
CPFlowElement >> isMessageFlow [
	^ false
]
