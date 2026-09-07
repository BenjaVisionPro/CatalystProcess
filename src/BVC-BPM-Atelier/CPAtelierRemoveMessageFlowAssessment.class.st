"I describe removal of one staged MessageFlow and its Collaboration DI edge."
Class {
	#name : 'CPAtelierRemoveMessageFlowAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'messageFlow',
		'proposedMessageFlows',
		'proposedDiagramElements',
		'removedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveMessageFlowAssessment class >> messageFlow: aMessageFlow proposedMessageFlows: someMessageFlows proposedDiagramElements: someElements removedDiagramElements: removedElements [
	^ self new
		messageFlow: aMessageFlow;
		proposedMessageFlows: someMessageFlows;
		proposedDiagramElements: someElements;
		removedDiagramElements: removedElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveMessageFlowAssessment class >> rejectedBecause: aString [
	^ self new rejectionMessage: aString; yourself
]


{ #category : 'accessing' }
CPAtelierRemoveMessageFlowAssessment >> messageFlow [ ^ messageFlow ]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlowAssessment >> messageFlow: anObject [ messageFlow := anObject ]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlowAssessment >> proposedMessageFlows [ ^ proposedMessageFlows ]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlowAssessment >> proposedMessageFlows: aCollection [ proposedMessageFlows := aCollection ]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlowAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlowAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlowAssessment >> removedDiagramElements [ ^ removedDiagramElements ]

{ #category : 'accessing' }
CPAtelierRemoveMessageFlowAssessment >> removedDiagramElements: aCollection [ removedDiagramElements := aCollection ]
