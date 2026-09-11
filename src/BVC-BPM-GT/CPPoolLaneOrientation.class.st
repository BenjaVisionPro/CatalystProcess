"I define the presentation/editing geometry implied by BPMNShape isHorizontal for Pools and Lanes.

Concrete orientations expose explicit geometry messages so GT and Atelier do not scatter boolean or symbol dispatch."
Class {
	#name : 'CPPoolLaneOrientation',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPPoolLaneOrientation class >> forShape: aShape [
	^ aShape isHorizontal
		ifTrue: [ CPHorizontalPoolLaneOrientation new ]
		ifFalse: [ CPVerticalPoolLaneOrientation new ]
]

{ #category : 'testing' }
CPPoolLaneOrientation >> isHorizontal [
	^ self subclassResponsibility
]

{ #category : 'geometry' }
CPPoolLaneOrientation >> participantContentOriginOffset [
	^ self subclassResponsibility
]

{ #category : 'geometry' }
CPPoolLaneOrientation >> laneBodyOriginOffset [
	^ self subclassResponsibility
]

{ #category : 'building' }
CPPoolLaneOrientation >> configureParticipantLabelBand: aBand label: aLabel [
	self subclassResponsibility
]

{ #category : 'building' }
CPPoolLaneOrientation >> configureParticipantProcessHost: aHost [
	self subclassResponsibility
]

{ #category : 'building' }
CPPoolLaneOrientation >> configureLaneLabelBand: aBand label: aLabel [
	self subclassResponsibility
]

{ #category : 'building' }
CPPoolLaneOrientation >> configureLaneBodyHost: aHost [
	self subclassResponsibility
]

{ #category : 'ordering' }
CPPoolLaneOrientation >> insertAfterForPoint: aPoint inBounds: bounds [
	^ self subclassResponsibility
]
