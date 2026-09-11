"I define the Bloc presentation policy implied by BPMNShape isHorizontal for Pools and Lanes.

Presentation-independent offsets and quarter-turn geometry belong to CPPoolLaneGeometry in the BPMN-DI layer. Concrete orientations here configure Bloc layout and orientation-specific interaction ordering."
Class {
	#name : 'CPPoolLaneOrientation',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPPoolLaneOrientation class >> forShape: aShape [
	^ self forHorizontal: aShape isHorizontal
]

{ #category : 'instance creation' }
CPPoolLaneOrientation class >> forHorizontal: isHorizontal [
	^ isHorizontal
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
