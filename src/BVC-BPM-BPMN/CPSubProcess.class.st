"I represent an embedded BPMN Sub-Process.

I am both an Activity in my containing flow and a BPMN FlowElementsContainer. I own nested FlowElements and LaneSets. My nested flow elements use the same containment protocol as CPProcess so sequence-flow inverse relations and removal semantics remain local to the Sub-Process."
Class {
	#name : 'CPSubProcess',
	#superclass : 'CPActivity',
	#instVars : [
		'flowElements',
		'laneSets',
		'artifacts',
		'compensable',
		'triggeredByEvent'
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
	laneSets := OrderedCollection new.
	artifacts := OrderedCollection new.
	compensable := false.
	triggeredByEvent := false
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
		CPErrorSubProcess.
		CPCompensationSubProcess.
		CPAdHocSubProcess
	}
]


{ #category : 'accessing' }
CPSubProcess >> artifacts [ ^ artifacts ]

{ #category : 'accessing' }
CPSubProcess >> artifacts: aCollection [
	artifacts copy do: [ :each | (aCollection identityIncludes: each) ifFalse: [ self removeArtifact: each ] ].
	aCollection do: [ :each | self addArtifact: each ]
]

{ #category : 'adding' }
CPSubProcess >> addArtifact: anArtifact [
	(artifacts identityIncludes: anArtifact) ifTrue: [ ^ self ].
	artifacts add: anArtifact.
	anArtifact container: self
]

{ #category : 'removing' }
CPSubProcess >> removeArtifact: anArtifact [
	(artifacts identityIncludes: anArtifact) ifFalse: [ ^ self ].
	artifacts remove: anArtifact.
	anArtifact container == self ifTrue: [ anArtifact container: nil ]
]

{ #category : 'descriptions' }
CPSubProcess >> artifactsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #artifacts; classes: { CPArtifact }; reference: CPArtifact new labelDescription; label: 'Artifacts'; priority: 108; group: 'Relations'; beOrdered; yourself
]


{ #category : 'accessing' }
CPSubProcess >> compensable [
	^ compensable
]

{ #category : 'accessing' }
CPSubProcess >> compensable: aBoolean [
	compensable := aBoolean
]

{ #category : 'descriptions' }
CPSubProcess >> compensableDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #compensable;
		label: 'Compensable';
		priority: 195;
		group: 'Execution';
		yourself
]

{ #category : 'testing' }
CPSubProcess >> hasCustomCompensationHandler [
	^ flowElements anySatisfy: [ :each |
		each isSubProcess and: [ each isForCompensation ] ]
]

{ #category : 'testing' }
CPSubProcess >> usesDefaultCompensationHandler [
	^ compensable and: [ self hasCustomCompensationHandler not ]
]

{ #category : 'testing' }
CPSubProcess >> hasEmbeddedCompensationHandler [
	^ self usesDefaultCompensationHandler or: [ self hasCustomCompensationHandler ]
]

{ #category : 'testing' }
CPSubProcess >> isErrorEventSubProcess [
	^ self isEventSubProcess and: [
		flowElements anySatisfy: [ :each | each isStartEvent and: [ each isErrorStartEvent ] ] ]
]

{ #category : 'testing' }
CPSubProcess >> isEventSubProcess [
	^ triggeredByEvent
]

{ #category : 'accessing' }
CPSubProcess >> triggeredByEvent [
	^ triggeredByEvent
]

{ #category : 'accessing' }
CPSubProcess >> triggeredByEvent: aBoolean [
	triggeredByEvent := aBoolean
]

{ #category : 'descriptions' }
CPSubProcess >> triggeredByEventDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #triggeredByEvent;
		label: 'Triggered by event';
		priority: 190;
		group: 'Execution';
		yourself
]

{ #category : 'validation' }
CPSubProcess >> validateEventSubProcessStructure [
	| sequenceFlows flowNodes |
	self isEventSubProcess ifFalse: [
		self error: 'Event SubProcess structural validation requires an Event SubProcess.' ].
	(self incoming isEmpty and: [ self outgoing isEmpty ]) ifFalse: [
		self error: 'An Event SubProcess cannot be connected to the enclosing normal Sequence Flow.' ].
	self boundaryEventRefs isEmpty ifFalse: [
		self error: 'An Event SubProcess cannot have attached Boundary Events.' ].
	sequenceFlows := flowElements select: [ :each | each isSequenceFlow ].
	sequenceFlows do: [ :eachFlow |
		(eachFlow sourceRef notNil and: [ eachFlow sourceRef container ~~ self ]) ifTrue: [
			self error: 'An Event SubProcess Sequence Flow source must belong to that Event SubProcess.' ].
		(eachFlow targetRef notNil and: [ eachFlow targetRef container ~~ self ]) ifTrue: [
			self error: 'An Event SubProcess Sequence Flow target must belong to that Event SubProcess.' ] ].
	flowNodes := flowElements select: [ :each | each isFlowNode ].
	flowNodes do: [ :eachNode |
		eachNode incoming do: [ :eachFlow |
			eachFlow container == self ifFalse: [
				self error: 'An Event SubProcess FlowNode cannot receive Sequence Flow from outside that Event SubProcess.' ] ].
		eachNode outgoing do: [ :eachFlow |
			eachFlow container == self ifFalse: [
				self error: 'An Event SubProcess FlowNode cannot produce Sequence Flow outside that Event SubProcess.' ] ] ].
	^ self
]
