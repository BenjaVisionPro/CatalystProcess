"I describe one assessment of referencing an existing Definitions Process through a new Call Activity."
Class {
	#name : 'CPAtelierReferenceProcessAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'process',
		'callActivity',
		'createAssessment'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReferenceProcessAssessment class >> process: aProcess callActivity: anActivity createAssessment: anAssessment [
	^ self new
		process: aProcess;
		callActivity: anActivity;
		createAssessment: anAssessment;
		yourself
]

{ #category : 'instance creation' }
CPAtelierReferenceProcessAssessment class >> process: aProcess callActivity: anActivity rejectedBecause: aString [
	^ self new process: aProcess; callActivity: anActivity; rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierReferenceProcessAssessment >> process [ ^ process ]
{ #category : 'accessing' }
CPAtelierReferenceProcessAssessment >> process: anObject [ process := anObject ]
{ #category : 'accessing' }
CPAtelierReferenceProcessAssessment >> callActivity [ ^ callActivity ]
{ #category : 'accessing' }
CPAtelierReferenceProcessAssessment >> callActivity: anObject [ callActivity := anObject ]
{ #category : 'accessing' }
CPAtelierReferenceProcessAssessment >> createAssessment [ ^ createAssessment ]
{ #category : 'accessing' }
CPAtelierReferenceProcessAssessment >> createAssessment: anObject [ createAssessment := anObject ]
