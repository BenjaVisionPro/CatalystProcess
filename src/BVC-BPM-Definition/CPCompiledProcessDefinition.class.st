Class {
	#name : 'CPCompiledProcessDefinition',
	#superclass : 'CFObject',
	#instVars : [
		'definition',
		'startNode',
		'nodesByIdentifier',
		'outgoingTransitionsByNodeIdentifier',
		'incomingTransitionsByNodeIdentifier'
	],
	#category : 'BVC-BPM-Definition',
	#package : 'BVC-BPM-Definition'
}

{ #category : 'accessing' }
CPCompiledProcessDefinition >> definition [
	^ definition
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> definition: anObject [
	definition := anObject
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> startNode [
	^ startNode
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> startNode: anObject [
	startNode := anObject
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> nodesByIdentifier [
	^ nodesByIdentifier
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> nodesByIdentifier: anObject [
	nodesByIdentifier := anObject
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> outgoingTransitionsByNodeIdentifier [
	^ outgoingTransitionsByNodeIdentifier
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> outgoingTransitionsByNodeIdentifier: anObject [
	outgoingTransitionsByNodeIdentifier := anObject
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> incomingTransitionsByNodeIdentifier [
	^ incomingTransitionsByNodeIdentifier
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> incomingTransitionsByNodeIdentifier: anObject [
	incomingTransitionsByNodeIdentifier := anObject
]

{ #category : 'initialization' }
CPCompiledProcessDefinition >> initialize [
	super initialize.
	nodesByIdentifier := Dictionary new.
	outgoingTransitionsByNodeIdentifier := Dictionary new.
	incomingTransitionsByNodeIdentifier := Dictionary new
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> nodeAtIdentifier: anIdentifier [
	^ nodesByIdentifier at: anIdentifier ifAbsent: [ nil ]
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> outgoingTransitionsFrom: aNodeDefinition [
	^ outgoingTransitionsByNodeIdentifier at: aNodeDefinition identifier ifAbsent: [ #() ]
]

{ #category : 'accessing' }
CPCompiledProcessDefinition >> incomingTransitionsTo: aNodeDefinition [
	^ incomingTransitionsByNodeIdentifier at: aNodeDefinition identifier ifAbsent: [ #() ]
]

{ #category : 'building' }
CPCompiledProcessDefinition >> indexDefinition [
	nodesByIdentifier := Dictionary new.
	outgoingTransitionsByNodeIdentifier := Dictionary new.
	incomingTransitionsByNodeIdentifier := Dictionary new.
	definition nodes do: [ :node | nodesByIdentifier at: node identifier put: node ].
	definition transitions do: [ :transition |
		(outgoingTransitionsByNodeIdentifier at: transition sourceNode identifier ifAbsentPut: [ OrderedCollection new ]) add: transition.
		(incomingTransitionsByNodeIdentifier at: transition targetNode identifier ifAbsentPut: [ OrderedCollection new ]) add: transition ].
	startNode := definition nodes detect: [ :node | node isStartNode ] ifNone: [ nil ]
]

