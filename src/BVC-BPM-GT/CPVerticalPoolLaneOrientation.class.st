Class {
	#name : 'CPVerticalPoolLaneOrientation',
	#superclass : 'CPPoolLaneOrientation',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'testing' }
CPVerticalPoolLaneOrientation >> isHorizontal [
	^ false
]

{ #category : 'geometry' }
CPVerticalPoolLaneOrientation >> participantContentOriginOffset [
	^ 0 @ 36
]

{ #category : 'geometry' }
CPVerticalPoolLaneOrientation >> laneBodyOriginOffset [
	^ 0 @ 30
]

{ #category : 'building' }
CPVerticalPoolLaneOrientation >> configureParticipantLabelBand: aBand label: aLabel [
	aBand constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical exact: self participantContentOriginOffset y.
		c frame horizontal alignLeft.
		c frame vertical alignTop ].
	aLabel
		hFitContent;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ]
]

{ #category : 'building' }
CPVerticalPoolLaneOrientation >> configureParticipantProcessHost: aHost [
	aHost constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent.
		c frame horizontal alignLeft.
		c frame vertical alignBottom.
		c margin: (BlInsets top: self participantContentOriginOffset y right: 0 bottom: 0 left: 0) ]
]

{ #category : 'building' }
CPVerticalPoolLaneOrientation >> configureLaneLabelBand: aBand label: aLabel [
	aBand constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical exact: self laneBodyOriginOffset y.
		c frame horizontal alignLeft.
		c frame vertical alignTop ].
	aLabel
		hFitContent;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ]
]

{ #category : 'building' }
CPVerticalPoolLaneOrientation >> configureLaneBodyHost: aHost [
	aHost constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent.
		c frame horizontal alignLeft.
		c frame vertical alignBottom.
		c margin: (BlInsets top: self laneBodyOriginOffset y right: 0 bottom: 0 left: 0) ]
]

{ #category : 'ordering' }
CPVerticalPoolLaneOrientation >> insertAfterForPoint: aPoint inBounds: bounds [
	^ (bounds right - aPoint x) < (aPoint x - bounds left)
]
