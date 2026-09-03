"I describe one assessment of repositioning an existing process design node through the current Process editing transaction.

I retain the node's authoritative staged position and the requested position so a BPM presentation can preview the exact intention that was assessed. I do not mutate the node or create child editing state during assessment."
Class {
	#name : 'CPAtelierPositionNodeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'node',
		'currentPosition',
		'proposedPosition'
	],
	#category : 'BVC-BPM-Atelier-Positioning',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Positioning'
}

{ #category : 'instance creation' }
CPAtelierPositionNodeAssessment class >> node: aNode currentPosition: aCurrentPosition proposedPosition: aProposedPosition [
	^ self new
		node: aNode;
		currentPosition: aCurrentPosition;
		proposedPosition: aProposedPosition;
		yourself
]

{ #category : 'instance creation' }
CPAtelierPositionNodeAssessment class >> node: aNode currentPosition: aCurrentPosition proposedPosition: aProposedPosition rejectedBecause: aString [
	^ self new
		node: aNode;
		currentPosition: aCurrentPosition;
		proposedPosition: aProposedPosition;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierPositionNodeAssessment >> node [ ^ node ]
{ #category : 'accessing' }
CPAtelierPositionNodeAssessment >> node: anObject [ node := anObject ]
{ #category : 'accessing' }
CPAtelierPositionNodeAssessment >> currentPosition [ ^ currentPosition ]
{ #category : 'accessing' }
CPAtelierPositionNodeAssessment >> currentPosition: aPoint [ currentPosition := aPoint ]
{ #category : 'accessing' }
CPAtelierPositionNodeAssessment >> proposedPosition [ ^ proposedPosition ]
{ #category : 'accessing' }
CPAtelierPositionNodeAssessment >> proposedPosition: aPoint [ proposedPosition := aPoint ]
