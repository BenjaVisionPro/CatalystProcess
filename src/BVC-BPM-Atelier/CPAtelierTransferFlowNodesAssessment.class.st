"I describe one accepted or rejected transfer of a closed group of FlowNodes and their internal SequenceFlows between staged flow containers."
Class {
	#name : 'CPAtelierTransferFlowNodesAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'flowNodes',
		'sequenceFlows',
		'sourceContainer',
		'targetContainer',
		'proposedSourceFlowElements',
		'proposedTargetFlowElements',
		'shapesByFlowNode',
		'edgesBySequenceFlow',
		'proposedBoundsByFlowNode',
		'proposedWaypointsBySequenceFlow',
		'stagedNodeState',
		'stagedFlowState'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierTransferFlowNodesAssessment class >> flowNodes: someFlowNodes rejectedBecause: aString [
	^ self new
		flowNodes: someFlowNodes;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> flowNodes [ ^ flowNodes ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> flowNodes: aCollection [ flowNodes := aCollection ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> sequenceFlows [ ^ sequenceFlows ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> sequenceFlows: aCollection [ sequenceFlows := aCollection ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> sourceContainer [ ^ sourceContainer ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> sourceContainer: anObject [ sourceContainer := anObject ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> targetContainer [ ^ targetContainer ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> targetContainer: anObject [ targetContainer := anObject ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> proposedSourceFlowElements [ ^ proposedSourceFlowElements ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> proposedSourceFlowElements: aCollection [ proposedSourceFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> proposedTargetFlowElements [ ^ proposedTargetFlowElements ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> proposedTargetFlowElements: aCollection [ proposedTargetFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> shapesByFlowNode [ ^ shapesByFlowNode ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> shapesByFlowNode: aDictionary [ shapesByFlowNode := aDictionary ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> edgesBySequenceFlow [ ^ edgesBySequenceFlow ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> edgesBySequenceFlow: aDictionary [ edgesBySequenceFlow := aDictionary ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> proposedBoundsByFlowNode [ ^ proposedBoundsByFlowNode ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> proposedBoundsByFlowNode: aDictionary [ proposedBoundsByFlowNode := aDictionary ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> proposedWaypointsBySequenceFlow [ ^ proposedWaypointsBySequenceFlow ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> proposedWaypointsBySequenceFlow: aDictionary [ proposedWaypointsBySequenceFlow := aDictionary ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> stagedNodeState [ ^ stagedNodeState ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> stagedNodeState: aDictionary [ stagedNodeState := aDictionary ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> stagedFlowState [ ^ stagedFlowState ]
{ #category : 'accessing' }
CPAtelierTransferFlowNodesAssessment >> stagedFlowState: aDictionary [ stagedFlowState := aDictionary ]
