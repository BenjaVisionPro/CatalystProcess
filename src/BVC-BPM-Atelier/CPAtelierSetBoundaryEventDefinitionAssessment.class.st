Class {
	#name : 'CPAtelierSetBoundaryEventDefinitionAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'boundaryEvent',
		'currentDefinitionClass',
		'proposedDefinitionClass'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierSetBoundaryEventDefinitionAssessment class >> boundaryEvent: aBoundaryEvent currentDefinitionClass: currentClass proposedDefinitionClass: proposedClass [
	^ self new
		boundaryEvent: aBoundaryEvent;
		currentDefinitionClass: currentClass;
		proposedDefinitionClass: proposedClass;
		yourself
]

{ #category : 'instance creation' }
CPAtelierSetBoundaryEventDefinitionAssessment class >> boundaryEvent: aBoundaryEvent currentDefinitionClass: currentClass proposedDefinitionClass: proposedClass rejectedBecause: aString [
	^ self new
		boundaryEvent: aBoundaryEvent;
		currentDefinitionClass: currentClass;
		proposedDefinitionClass: proposedClass;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierSetBoundaryEventDefinitionAssessment >> boundaryEvent [ ^ boundaryEvent ]
{ #category : 'accessing' }
CPAtelierSetBoundaryEventDefinitionAssessment >> boundaryEvent: anObject [ boundaryEvent := anObject ]
{ #category : 'accessing' }
CPAtelierSetBoundaryEventDefinitionAssessment >> currentDefinitionClass [ ^ currentDefinitionClass ]
{ #category : 'accessing' }
CPAtelierSetBoundaryEventDefinitionAssessment >> currentDefinitionClass: aClass [ currentDefinitionClass := aClass ]
{ #category : 'accessing' }
CPAtelierSetBoundaryEventDefinitionAssessment >> proposedDefinitionClass [ ^ proposedDefinitionClass ]
{ #category : 'accessing' }
CPAtelierSetBoundaryEventDefinitionAssessment >> proposedDefinitionClass: aClass [ proposedDefinitionClass := aClass ]
