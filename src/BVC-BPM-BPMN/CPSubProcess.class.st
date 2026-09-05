"I represent an embedded BPMN Sub-Process.

I am both an Activity in my containing flow and a container of my own FlowElements. My nested flow elements use the same containment protocol as CPProcess so sequence-flow inverse relations and removal semantics remain local to the Sub-Process."
Class {
	#name : 'CPSubProcess',
	#superclass : 'CPActivity',
	#instVars : [
		'flowElements'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'defaults' }
CPSubProcess class >> defaultIcon [
	^ #subProcess
]

{ #category : 'initialization' }
CPSubProcess >> initialize [
	super initialize.
	flowElements := OrderedCollection new
]

{ #category : 'accessing' }
CPSubProcess >> flowElements [
	^ flowElements
]

{ #category : 'accessing' }
CPSubProcess >> flowElements: aCollection [
	flowElements copy do: [ :each | self removeFlowElement: each ].
	aCollection do: [ :each | self addFlowElement: each ]
]

{ #category : 'adding' }
CPSubProcess >> addFlowElement: aFlowElement [
	(flowElements includes: aFlowElement) ifFalse: [
		flowElements add: aFlowElement.
		aFlowElement container: self ]
]

{ #category : 'removing' }
CPSubProcess >> removeFlowElement: aFlowElement [
	(flowElements includes: aFlowElement) ifFalse: [ ^ self ].
	aFlowElement prepareForRemovalFrom: self.
	flowElements remove: aFlowElement.
	aFlowElement container: nil
]

{ #category : 'descriptions' }
CPSubProcess >> flowElementsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #flowElements;
		classes: { CPFlowElement };
		reference: self labelDescription;
		label: 'Flow elements';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'testing' }
CPSubProcess >> isSubProcess [
	^ true
]
