"I describe one assessment of introducing a fresh process design node into a process design through its current Magritte editing state.

I am deliberately BPM-specific. I retain the observed and proposed nodes plus the fresh candidate and its requested position so a BPM presentation can preview exactly what was assessed. I do not mutate the design, memento or candidate."
Class {
	#name : 'CPAtelierCreateNodeAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'nodes',
		'proposedNodes',
		'node',
		'position'
	],
	#category : 'BVC-BPM-Atelier-Creation',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Creation'
}

{ #category : 'instance creation' }
CPAtelierCreateNodeAssessment class >> nodes: nodes proposedNodes: proposedNodes node: aNode position: aPoint [
	^ self new
		nodes: nodes;
		proposedNodes: proposedNodes;
		node: aNode;
		position: aPoint;
		yourself
]

{ #category : 'instance creation' }
CPAtelierCreateNodeAssessment class >> nodes: nodes node: aNode position: aPoint rejectedBecause: aString [
	^ self new
		nodes: nodes;
		node: aNode;
		position: aPoint;
		rejectionMessage: aString;
		yourself
]

{ #category : 'accessing' }
CPAtelierCreateNodeAssessment >> node [ ^ node ]
{ #category : 'accessing' }
CPAtelierCreateNodeAssessment >> node: anObject [ node := anObject ]
{ #category : 'accessing' }
CPAtelierCreateNodeAssessment >> nodes [ ^ nodes ]
{ #category : 'accessing' }
CPAtelierCreateNodeAssessment >> nodes: aCollection [ nodes := aCollection ]
{ #category : 'accessing' }
CPAtelierCreateNodeAssessment >> position [ ^ position ]
{ #category : 'accessing' }
CPAtelierCreateNodeAssessment >> position: aPoint [ position := aPoint ]
{ #category : 'accessing' }
CPAtelierCreateNodeAssessment >> proposedNodes [ ^ proposedNodes ]
{ #category : 'accessing' }
CPAtelierCreateNodeAssessment >> proposedNodes: aCollection [ proposedNodes := aCollection ]
