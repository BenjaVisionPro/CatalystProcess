"
I describe one assessment of reconnecting one endpoint of a staged CPSequenceFlow.

The operation preserves the CPSequenceFlow and CPEdge identities.  Connection
admissibility is delegated to the same Process-owned rules used when creating
a new sequence flow.
"
Class {
	#name : 'CPAtelierReconnectSequenceFlowAssessment',
	#superclass : 'CFAtelierOperationAssessment',
	#instVars : [
		'sequenceFlow',
		'newSource',
		'newTarget'
	],
	#category : 'BVC-BPM-Atelier-Assessments',
	#package : 'BVC-BPM-Atelier'
}

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> newSource [
	^ newSource
]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> newSource: aFlowNode [
	newSource := aFlowNode
]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> newTarget [
	^ newTarget
]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> newTarget: aFlowNode [
	newTarget := aFlowNode
]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> sequenceFlow [
	^ sequenceFlow
]

{ #category : 'accessing' }
CPAtelierReconnectSequenceFlowAssessment >> sequenceFlow: aSequenceFlow [
	sequenceFlow := aSequenceFlow
]
