"I validate the resolved semantic topology of a CPProcess. My validation describes BPMN well-formedness without deciding whether an incremental Atelier edit may be performed."
Class {
	#name : 'CPProcessValidator',
	#superclass : 'Object',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'validation' }
CPProcessValidator >> validateProcess: aProcess [
	^ self validateTopology: (CPProcessTopology fromProcess: aProcess)
]

{ #category : 'validation' }
CPProcessValidator >> validateTopology: aTopology [
	| result |
	result := CPValidationResult new.
	self validateSequenceFlowsIn: aTopology into: result.
	self validateStartEventsIn: aTopology into: result.
	self validateEndEventsIn: aTopology into: result.
	self validateDuplicateSequenceFlowsIn: aTopology into: result.
	^ result
]

{ #category : 'private - validation' }
CPProcessValidator >> validateSequenceFlowsIn: aTopology into: aResult [
	aTopology sequenceFlowConnections do: [ :connection |
		connection source ifNil: [
			aResult addErrorCode: #sequenceFlowWithoutSource message: 'A sequence flow requires a source flow node.' subject: connection sequenceFlow ].
		connection target ifNil: [
			aResult addErrorCode: #sequenceFlowWithoutTarget message: 'A sequence flow requires a target flow node.' subject: connection sequenceFlow ].
		(connection source notNil and: [ (aTopology includesFlowElement: connection source) not ]) ifTrue: [
			aResult addErrorCode: #sequenceFlowSourceOutsideProcess message: 'A sequence flow source must belong to its process.' subject: connection sequenceFlow ].
		(connection target notNil and: [ (aTopology includesFlowElement: connection target) not ]) ifTrue: [
			aResult addErrorCode: #sequenceFlowTargetOutsideProcess message: 'A sequence flow target must belong to its process.' subject: connection sequenceFlow ] ]
]

{ #category : 'private - validation' }
CPProcessValidator >> validateStartEventsIn: aTopology into: aResult [
	aTopology flowNodes do: [ :node |
		node isStartEvent ifTrue: [
			(aTopology incomingConnectionsTo: node) isEmpty ifFalse: [
				aResult addErrorCode: #startEventHasIncomingSequenceFlow message: 'A start event cannot have an incoming sequence flow.' subject: node ].
			(aTopology outgoingConnectionsFrom: node) isEmpty ifTrue: [
				aResult addErrorCode: #startEventWithoutOutgoingSequenceFlow message: 'A start event requires an outgoing sequence flow.' subject: node ] ] ]
]

{ #category : 'private - validation' }
CPProcessValidator >> validateEndEventsIn: aTopology into: aResult [
	aTopology flowNodes do: [ :node |
		node isEndEvent ifTrue: [
			(aTopology outgoingConnectionsFrom: node) isEmpty ifFalse: [
				aResult addErrorCode: #endEventHasOutgoingSequenceFlow message: 'An end event cannot have an outgoing sequence flow.' subject: node ].
			(aTopology incomingConnectionsTo: node) isEmpty ifTrue: [
				aResult addErrorCode: #endEventWithoutIncomingSequenceFlow message: 'An end event requires an incoming sequence flow.' subject: node ] ] ]
]

{ #category : 'private - validation' }
CPProcessValidator >> validateDuplicateSequenceFlowsIn: aTopology into: aResult [
	| connections |
	connections := aTopology sequenceFlowConnections.
	1 to: connections size do: [ :firstIndex |
		firstIndex + 1 to: connections size do: [ :secondIndex |
			| first second |
			first := connections at: firstIndex.
			second := connections at: secondIndex.
			(first source notNil and: [ first target notNil and: [ second connectsFrom: first source to: first target ] ]) ifTrue: [
				aResult addErrorCode: #duplicateSequenceFlowConnection message: 'Only one sequence flow may directly connect the same source and target nodes in the current Process model.' subject: second sequenceFlow ] ] ]
]
