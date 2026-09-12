"I expose a rendered Process-edge segment's target point as a Foundation Motion property.

During orientation Motion temporarily replaces the segment's live docking anchor with an absolute anchor so the visible endpoint can converge on the authoritative post-orientation docking point. The terminal diagram rebuild restores ordinary live anchors."
Class {
	#name : 'CPProcessEdgeToPointMotionProperty',
	#superclass : 'CFMotionProperty',
	#classInstVars : [ 'uniqueInstance' ],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessEdgeToPointMotionProperty class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : 'accessing' }
CPProcessEdgeToPointMotionProperty >> currentPresentationOf: aLineElement [
	^ aLineElement toPosition
]

{ #category : 'accessing' }
CPProcessEdgeToPointMotionProperty >> apply: aPoint to: aLineElement [
	aLineElement toAnchor: (BlAbsolutePositionAnchor position: aPoint)
]
