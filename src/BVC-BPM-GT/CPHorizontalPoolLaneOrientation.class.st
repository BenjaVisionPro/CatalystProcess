Class {
	#name : 'CPHorizontalPoolLaneOrientation',
	#superclass : 'CPPoolLaneOrientation',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'testing' }
CPHorizontalPoolLaneOrientation >> isHorizontal [
	^ true
]

{ #category : 'geometry' }
CPHorizontalPoolLaneOrientation >> participantContentOriginOffset [
	^ CPPoolLaneGeometry participantContentOriginOffsetForHorizontal: true
]

{ #category : 'geometry' }
CPHorizontalPoolLaneOrientation >> laneBodyOriginOffset [
	^ CPPoolLaneGeometry laneBodyOriginOffsetForHorizontal: true
]

{ #category : 'building' }
CPHorizontalPoolLaneOrientation >> configureParticipantLabelBand: aBand label: aLabel [
	aBand constraintsDo: [ :c |
		c horizontal exact: self participantContentOriginOffset x.
		c vertical matchParent.
		c frame horizontal alignLeft.
		c frame vertical alignTop ].
	aLabel
		hFitContent;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		transformDo: [ :aTransform | aTransform rotateBy: -90 ]
]

{ #category : 'building' }
CPHorizontalPoolLaneOrientation >> configureParticipantProcessHost: aHost [
	aHost constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent.
		c frame horizontal alignRight.
		c frame vertical alignTop.
		c margin: (BlInsets top: 0 right: 0 bottom: 0 left: self participantContentOriginOffset x) ]
]

{ #category : 'building' }
CPHorizontalPoolLaneOrientation >> configureLaneLabelBand: aBand label: aLabel [
	aBand constraintsDo: [ :c |
		c horizontal exact: self laneBodyOriginOffset x.
		c vertical matchParent.
		c frame horizontal alignLeft.
		c frame vertical alignTop ].
	aLabel
		hFitContent;
		vFitContent;
		constraintsDo: [ :c |
			c frame horizontal alignCenter.
			c frame vertical alignCenter ];
		transformDo: [ :aTransform | aTransform rotateBy: -90 ]
]

{ #category : 'building' }
CPHorizontalPoolLaneOrientation >> configureLaneBodyHost: aHost [
	aHost constraintsDo: [ :c |
		c horizontal matchParent.
		c vertical matchParent.
		c frame horizontal alignRight.
		c frame vertical alignTop.
		c margin: (BlInsets top: 0 right: 0 bottom: 0 left: self laneBodyOriginOffset x) ]
]

{ #category : 'ordering' }
CPHorizontalPoolLaneOrientation >> insertAfterForPoint: aPoint inBounds: bounds [
	^ (bounds bottom - aPoint y) < (aPoint y - bounds top)
]
