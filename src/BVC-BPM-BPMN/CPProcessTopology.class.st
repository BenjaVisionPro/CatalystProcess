"I am a resolved view of the semantic topology of one CPProcess. I can represent either committed model topology or staged Atelier topology without depending on Magritte or Atelier."
Class {
	#name : 'CPProcessTopology',
	#superclass : 'Object',
	#instVars : [
		'flowElements',
		'sequenceFlowConnections'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'instance creation' }
CPProcessTopology class >> fromProcess: aProcess [
	| topology |
	topology := self new.
	aProcess flowElements do: [ :each |
		each isSequenceFlow
			ifTrue: [ topology addSequenceFlow: each source: each sourceRef target: each targetRef ]
			ifFalse: [ topology addFlowElement: each ] ].
	^ topology
]

{ #category : 'initialization' }
CPProcessTopology >> initialize [
	super initialize.
	flowElements := OrderedCollection new.
	sequenceFlowConnections := OrderedCollection new
]

{ #category : 'adding' }
CPProcessTopology >> addFlowElement: aFlowElement [
	(flowElements identityIncludes: aFlowElement) ifFalse: [ flowElements add: aFlowElement ]
]

{ #category : 'adding' }
CPProcessTopology >> addSequenceFlow: aSequenceFlow source: aSource target: aTarget [
	self addFlowElement: aSequenceFlow.
	sequenceFlowConnections add: (CPSequenceFlowConnection
		sequenceFlow: aSequenceFlow
		source: aSource
		target: aTarget)
]

{ #category : 'accessing' }
CPProcessTopology >> flowElements [
	^ flowElements
]

{ #category : 'accessing' }
CPProcessTopology >> flowNodes [
	^ flowElements reject: [ :each | each isSequenceFlow ]
]

{ #category : 'accessing' }
CPProcessTopology >> sequenceFlowConnections [
	^ sequenceFlowConnections
]

{ #category : 'testing' }
CPProcessTopology >> includesFlowElement: aFlowElement [
	^ flowElements identityIncludes: aFlowElement
]

{ #category : 'testing' }
CPProcessTopology >> hasSequenceFlowFrom: aSource to: aTarget [
	^ sequenceFlowConnections anySatisfy: [ :each | each connectsFrom: aSource to: aTarget ]
]

{ #category : 'accessing' }
CPProcessTopology >> incomingConnectionsTo: aFlowNode [
	^ sequenceFlowConnections select: [ :each | each target == aFlowNode ]
]

{ #category : 'accessing' }
CPProcessTopology >> outgoingConnectionsFrom: aFlowNode [
	^ sequenceFlowConnections select: [ :each | each source == aFlowNode ]
]
