"I describe one assessment of adding a process-scoped Data Object, its Data Object Reference and the CPShape that depicts that reference."
Class {
	#name : 'CPAtelierCreateDataObjectAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'dataObject',
		'dataObjectReference',
		'shape',
		'proposedFlowElements',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateDataObjectAssessment class >> dataObject: aDataObject dataObjectReference: aReference shape: aShape proposedFlowElements: someFlowElements proposedDiagramElements: someElements [
	^ self new
		dataObject: aDataObject;
		dataObjectReference: aReference;
		shape: aShape;
		proposedFlowElements: someFlowElements;
		proposedDiagramElements: someElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierCreateDataObjectAssessment class >> dataObject: aDataObject rejectedBecause: aString [
	^ self new
		dataObject: aDataObject;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierCreateDataObjectAssessment >> dataObject [ ^ dataObject ]
{ #category : 'accessing' }
CPAtelierCreateDataObjectAssessment >> dataObject: anObject [ dataObject := anObject ]
{ #category : 'accessing' }
CPAtelierCreateDataObjectAssessment >> dataObjectReference [ ^ dataObjectReference ]
{ #category : 'accessing' }
CPAtelierCreateDataObjectAssessment >> dataObjectReference: anObject [ dataObjectReference := anObject ]
{ #category : 'accessing' }
CPAtelierCreateDataObjectAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierCreateDataObjectAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'accessing' }
CPAtelierCreateDataObjectAssessment >> proposedFlowElements [ ^ proposedFlowElements ]
{ #category : 'accessing' }
CPAtelierCreateDataObjectAssessment >> proposedFlowElements: aCollection [ proposedFlowElements := aCollection ]
{ #category : 'accessing' }
CPAtelierCreateDataObjectAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierCreateDataObjectAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
