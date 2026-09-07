"I describe one assessment of removing an explicit collection of BPMN DI elements as a single editing intention."
Class {
	#name : 'CPAtelierRemoveDiagramElementsAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'operations',
		'operationAssessments'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierRemoveDiagramElementsAssessment class >> operations: someOperations operationAssessments: someAssessments [
	^ self new
		operations: someOperations;
		operationAssessments: someAssessments;
		yourself
]

{ #category : 'instance creation' }
CPAtelierRemoveDiagramElementsAssessment class >> rejectedBecause: aString [
	^ self new rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierRemoveDiagramElementsAssessment >> operations [
	^ operations
]

{ #category : 'accessing' }
CPAtelierRemoveDiagramElementsAssessment >> operations: someOperations [
	operations := someOperations asArray
]

{ #category : 'accessing' }
CPAtelierRemoveDiagramElementsAssessment >> operationAssessments [
	^ operationAssessments
]

{ #category : 'accessing' }
CPAtelierRemoveDiagramElementsAssessment >> operationAssessments: someAssessments [
	operationAssessments := someAssessments asArray
]
