"I describe one assessment of adding a fresh BPMN Lane and its CPShape to the staged root Process."
Class {
	#name : 'CPAtelierCreateLaneAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'lane',
		'laneSet',
		'shape',
		'createsLaneSet',
		'proposedLaneSets',
		'proposedLanes',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierCreateLaneAssessment class >> lane: aLane laneSet: aLaneSet shape: aShape createsLaneSet: aBoolean proposedLaneSets: someLaneSets proposedLanes: someLanes proposedDiagramElements: someElements [
	^ self new
		lane: aLane;
		laneSet: aLaneSet;
		shape: aShape;
		createsLaneSet: aBoolean;
		proposedLaneSets: someLaneSets;
		proposedLanes: someLanes;
		proposedDiagramElements: someElements;
		yourself
]

{ #category : 'instance creation' }
CPAtelierCreateLaneAssessment class >> lane: aLane rejectedBecause: aString [
	^ self new lane: aLane; rejectionMessage: aString; yourself
]

{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> lane [ ^ lane ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> lane: anObject [ lane := anObject ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> laneSet [ ^ laneSet ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> laneSet: anObject [ laneSet := anObject ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'testing' }
CPAtelierCreateLaneAssessment >> createsLaneSet [ ^ createsLaneSet ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> createsLaneSet: aBoolean [ createsLaneSet := aBoolean ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> proposedLaneSets [ ^ proposedLaneSets ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> proposedLaneSets: aCollection [ proposedLaneSets := aCollection ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> proposedLanes [ ^ proposedLanes ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> proposedLanes: aCollection [ proposedLanes := aCollection ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierCreateLaneAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
