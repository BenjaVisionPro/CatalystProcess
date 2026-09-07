"I describe one staged Boundary Event reattachment and its authored DI movement."
Class {
	#name : 'CPAtelierReattachBoundaryEventAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [ 'boundaryEvent', 'activity', 'shape', 'currentBounds', 'proposedBounds', 'delta' ],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReattachBoundaryEventAssessment class >> boundaryEvent: anEvent activity: anActivity shape: aShape currentBounds: currentBounds proposedBounds: proposedBounds delta: delta [
	^ self new
		boundaryEvent: anEvent;
		activity: anActivity;
		shape: aShape;
		currentBounds: currentBounds;
		proposedBounds: proposedBounds;
		delta: delta;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReattachBoundaryEventAssessment class >> boundaryEvent: anEvent rejectedBecause: aString [
	^ self new boundaryEvent: anEvent; rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> boundaryEvent [ ^ boundaryEvent ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> boundaryEvent: anObject [ boundaryEvent := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> activity [ ^ activity ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> activity: anObject [ activity := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> currentBounds [ ^ currentBounds ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> currentBounds: anObject [ currentBounds := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> proposedBounds [ ^ proposedBounds ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> proposedBounds: anObject [ proposedBounds := anObject ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> delta [ ^ delta ]
{ #category : 'accessing' }
CPAtelierReattachBoundaryEventAssessment >> delta: anObject [ delta := anObject ]
