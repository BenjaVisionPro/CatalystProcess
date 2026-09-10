"I represent an embedded BPMN Sub-Process.

I am both an Activity in my containing flow and a BPMN FlowElementsContainer. I own nested FlowElements and LaneSets. My nested flow elements use the same containment protocol as CPProcess so sequence-flow inverse relations and removal semantics remain local to the Sub-Process."
Class {
	#name : 'CPSubProcess',
	#superclass : 'CPActivity',
	#instVars : [
		'flowElements',
		'laneSets'
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
	flowElements := OrderedCollection new.
	laneSets := OrderedCollection new
]

{ #category : 'accessing' }
CPSubProcess >> flowElements [
	^ flowElements
]

{ #category : 'accessing' }
CPSubProcess >> flowElements: aCollection [
	| proposed |
	proposed := aCollection asOrderedCollection copy.
	flowElements copy do: [ :each |
		(proposed identityIncludes: each) ifFalse: [ self removeFlowElement: each ] ].
	proposed do: [ :each | self addFlowElement: each ].
	flowElements := proposed
]

{ #category : 'adding' }
CPSubProcess >> addFlowElement: aFlowElement [
	(flowElements includes: aFlowElement) ifFalse: [
		flowElements add: aFlowElement.
		aFlowElement container: self ]
]

{ #category : 'removing' }
CPSubProcess >> removeFlowElement: aFlowElement [
	(flowElements identityIncludes: aFlowElement) ifFalse: [ ^ self ].
	"A committed transfer has already given this element another owner.
	Remove stale source membership without disconnecting the transferred topology."
	aFlowElement container == self ifTrue: [
		aFlowElement prepareForRemovalFrom: self.
		aFlowElement container: nil ].
	flowElements remove: aFlowElement ifAbsent: [ ]
]



{ #category : 'accessing' }
CPSubProcess >> laneSets [
	^ laneSets
]

{ #category : 'accessing' }
CPSubProcess >> laneSets: aCollection [
	laneSets copy do: [ :each | self removeLaneSet: each ].
	aCollection do: [ :each | self addLaneSet: each ]
]

{ #category : 'adding' }
CPSubProcess >> addLaneSet: aLaneSet [
	(laneSets identityIncludes: aLaneSet) ifTrue: [ ^ self ].
	laneSets add: aLaneSet
]

{ #category : 'removing' }
CPSubProcess >> removeLaneSet: aLaneSet [
	laneSets remove: aLaneSet ifAbsent: [ ]
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



{ #category : 'descriptions' }
CPSubProcess >> laneSetsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #laneSets;
		classes: { CPLaneSet };
		reference: CPLaneSet new labelDescription;
		label: 'Lane sets';
		priority: 105;
		group: 'Relations';
		yourself
]

{ #category : 'testing' }
CPSubProcess >> isSubProcess [
	^ true
]


{ #category : 'sub-process type' }
CPSubProcess class >> subProcessTypes [
	^ {
		CPNoneSubProcess.
		CPLoopSubProcess.
		CPMultiInstanceSubProcess.
		CPCompensationSubProcess.
		CPAdHocSubProcess
	}
]
