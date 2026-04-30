Class {
	#name : 'CPProcessDesignValidator',
	#superclass : 'Object',
	#category : 'BVC-BPM-Design',
	#package : 'BVC-BPM-Design'
}

{ #category : 'validation' }
CPProcessDesignValidator >> validateDesign: aDesign [
	| result |
	result := CPValidationResult new.
	self validateStartNodesOf: aDesign into: result.
	self validateEndNodesOf: aDesign into: result.
	self validateEdgesOf: aDesign into: result.
	self validateFlowOf: aDesign into: result.
	self validateReachabilityOf: aDesign into: result.
	^ result
]

{ #category : 'validation' }
CPProcessDesignValidator >> validateStartNodesOf: aDesign into: aResult [
	aDesign startNodes size = 1 ifFalse: [
		aResult addErrorCode: #invalidStartNodeCount message: 'A milestone-one design must have exactly one start node.' subject: aDesign ]
]

{ #category : 'validation' }
CPProcessDesignValidator >> validateEndNodesOf: aDesign into: aResult [
	aDesign endNodes isEmpty ifTrue: [
		aResult addErrorCode: #missingEndNode message: 'A process design must have at least one end node.' subject: aDesign ]
]

{ #category : 'validation' }
CPProcessDesignValidator >> validateEdgesOf: aDesign into: aResult [
	aDesign edges do: [ :edge |
		(edge sourceNode isNil or: [ edge targetNode isNil ]) ifTrue: [
			aResult addErrorCode: #invalidEdge message: 'Every edge must have a source and target node.' subject: edge ].
		(edge sourceNode notNil and: [ (aDesign nodes includes: edge sourceNode) not ]) ifTrue: [
			aResult addErrorCode: #edgeSourceOutsideDesign message: 'Edge source node must belong to the design.' subject: edge ].
		(edge targetNode notNil and: [ (aDesign nodes includes: edge targetNode) not ]) ifTrue: [
			aResult addErrorCode: #edgeTargetOutsideDesign message: 'Edge target node must belong to the design.' subject: edge ] ]
]

{ #category : 'validation' }
CPProcessDesignValidator >> validateFlowOf: aDesign into: aResult [
	aDesign nodes do: [ :node |
		node isEndNode ifFalse: [
			(aDesign edges anySatisfy: [ :edge | edge sourceNode == node ]) ifFalse: [
				aResult addErrorCode: #missingOutgoingFlow message: 'Every non-end node must have outgoing flow.' subject: node ] ].
		node isStartNode ifFalse: [
			(aDesign edges anySatisfy: [ :edge | edge targetNode == node ]) ifFalse: [
				aResult addErrorCode: #missingIncomingFlow message: 'Every non-start node must have incoming flow.' subject: node ] ] ]
]

{ #category : 'validation' }
CPProcessDesignValidator >> validateReachabilityOf: aDesign into: aResult [
	| visited frontier |
	aDesign startNodes isEmpty ifTrue: [ ^ self ].
	visited := OrderedCollection new.
	frontier := OrderedCollection with: aDesign startNodes first.
	[ frontier isEmpty ] whileFalse: [
		| node |
		node := frontier removeFirst.
		(visited includes: node) ifFalse: [
			visited add: node.
			(aDesign edges select: [ :edge | edge sourceNode == node ]) do: [ :edge | frontier add: edge targetNode ] ] ].
	aDesign nodes do: [ :node |
		(visited includes: node) ifFalse: [
			aResult addErrorCode: #unreachableNode message: 'Every node must be reachable from the start node.' subject: node ] ]
]

