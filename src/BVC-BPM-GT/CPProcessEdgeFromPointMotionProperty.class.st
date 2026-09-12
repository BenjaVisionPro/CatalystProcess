"I expose a rendered Process-edge segment's source point as a Foundation Motion property.

During orientation Motion temporarily replaces the segment's live docking anchor with an absolute anchor so the visible endpoint can converge on the authoritative post-orientation docking point. The terminal diagram rebuild restores ordinary live anchors."
Class {
	#name : 'CPProcessEdgeFromPointMotionProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessEdgeFromPointMotionProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CPProcessEdgeFromPointMotionProperty >> currentPresentationOf: aLineElement [
	^ aLineElement fromPosition
]

{ #category : 'accessing' }
CPProcessEdgeFromPointMotionProperty >> apply: aPoint to: aLineElement [
	aLineElement fromAnchor: (BlAbsolutePositionAnchor position: aPoint)
]
