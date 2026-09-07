"I describe one assessment of creating a Boundary Event together with its attached Activity and CPShape depiction."
Class {
	#name : 'CPAtelierCreateBoundaryEventAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [ 'boundaryEvent', 'shape', 'activity', 'proposedFlowElements', 'proposedDiagramElements' ],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}
{ #category : 'instance creation' }
CPAtelierCreateBoundaryEventAssessment class >> boundaryEvent: anEvent shape: aShape activity: anActivity proposedFlowElements: someFlowElements proposedDiagramElements: someDiagramElements [
	^ self new boundaryEvent: anEvent; shape: aShape; activity: anActivity; proposedFlowElements: someFlowElements; proposedDiagramElements: someDiagramElements; yourself
]
{ #category : 'instance creation' }
CPAtelierCreateBoundaryEventAssessment class >> boundaryEvent: anEvent rejectedBecause: aString [ ^ self new boundaryEvent: anEvent; rejectionMessage: aString; yourself ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEventAssessment >> boundaryEvent [ ^ boundaryEvent ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEventAssessment >> boundaryEvent: anObject [ boundaryEvent := anObject ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEventAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEventAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEventAssessment >> activity [ ^ activity ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEventAssessment >> activity: anObject [ activity := anObject ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEventAssessment >> proposedFlowElements [ ^ proposedFlowElements ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEventAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEventAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierCreateBoundaryEventAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
