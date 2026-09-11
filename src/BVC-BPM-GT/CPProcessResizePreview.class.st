"I carry one coherent, read-only Process resize preview from the editing layer to the GT presentation.

All geometry in me comes from one assessment of the same proposed Participant bounds: Lane bounds, FlowNode bounds, and Sequence Flow waypoints."
Class {
	#name : 'CPProcessResizePreview',
	#superclass : 'Object',
	#instVars : [
		'laneBoundsByShape',
		'flowNodeBoundsByShape',
		'waypointsByEdge'
	],
	#category : 'BVC-BPM-GT-Editing',
	#package : 'BVC-BPM-GT',
	#tag : 'Editing'
}

{ #category : 'instance creation' }
CPProcessResizePreview class >> laneBoundsByShape: laneBounds flowNodeBoundsByShape: flowNodeBounds waypointsByEdge: edgeWaypoints [
	^ self new
		laneBoundsByShape: laneBounds;
		flowNodeBoundsByShape: flowNodeBounds;
		waypointsByEdge: edgeWaypoints;
		yourself
]

{ #category : 'accessing' }
CPProcessResizePreview >> laneBoundsByShape [
	^ laneBoundsByShape
]

{ #category : 'accessing' }
CPProcessResizePreview >> laneBoundsByShape: aDictionary [
	laneBoundsByShape := aDictionary
]

{ #category : 'accessing' }
CPProcessResizePreview >> flowNodeBoundsByShape [
	^ flowNodeBoundsByShape
]

{ #category : 'accessing' }
CPProcessResizePreview >> flowNodeBoundsByShape: aDictionary [
	flowNodeBoundsByShape := aDictionary
]

{ #category : 'accessing' }
CPProcessResizePreview >> waypointsByEdge [
	^ waypointsByEdge
]

{ #category : 'accessing' }
CPProcessResizePreview >> waypointsByEdge: aDictionary [
	waypointsByEdge := aDictionary
]
