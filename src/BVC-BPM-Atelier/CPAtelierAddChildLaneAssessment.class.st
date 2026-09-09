"I describe adding one Lane one partition level below a parent Lane.

If the parent has no staged child LaneSet, the assessment carries a fresh child LaneSet. Otherwise it carries the existing child LaneSet. In both cases it carries the proposed child-Lane ordering and the new Lane CPShape."
Class {
	#name : 'CPAtelierAddChildLaneAssessment',
	#superclass : 'CFAtelierAssessment',
	#instVars : [
		'parentLane',
		'lane',
		'laneSet',
		'shape',
		'createsLaneSet',
		'proposedLanes',
		'proposedDiagramElements'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> parentLane [ ^ parentLane ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> parentLane: anObject [ parentLane := anObject ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> lane [ ^ lane ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> lane: anObject [ lane := anObject ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> laneSet [ ^ laneSet ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> laneSet: anObject [ laneSet := anObject ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> shape [ ^ shape ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> shape: anObject [ shape := anObject ]
{ #category : 'testing' }
CPAtelierAddChildLaneAssessment >> createsLaneSet [ ^ createsLaneSet ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> createsLaneSet: aBoolean [ createsLaneSet := aBoolean ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> proposedLanes [ ^ proposedLanes ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> proposedLanes: aCollection [ proposedLanes := aCollection ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> proposedDiagramElements [ ^ proposedDiagramElements ]
{ #category : 'accessing' }
CPAtelierAddChildLaneAssessment >> proposedDiagramElements: aCollection [ proposedDiagramElements := aCollection ]
