"I represent the rendered polyline geometry used to place one edge label.

I contain only path-relative presentation calculations. CPProcessVisualElement resolves diagram-dependent rendered points and staged BPMN-DI values, then asks me to translate between segment placement, path fraction, offset, and the nearest point on that path."
Class {
	#name : 'CPProcessEdgeLabelPath',
	#superclass : 'Object',
	#instVars : [ 'points' ],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPProcessEdgeLabelPath class >> points: somePoints [
	^ self new points: somePoints
]

{ #category : 'initialization' }
CPProcessEdgeLabelPath >> points: somePoints [ points := somePoints ]

{ #category : 'placement' }
CPProcessEdgeLabelPath >> defaultSegmentIndex [
	^ ((points size - 1) / 2.0) ceiling
]

{ #category : 'placement' }
CPProcessEdgeLabelPath >> placementAtSegmentIndex: aSegmentIndex segmentPosition: aSegmentPosition offset: anOffset [
	| effectiveIndex start finish vector length tangent normal point |
	effectiveIndex := (aSegmentIndex max: 1) min: points size - 1.
	start := points at: effectiveIndex.
	finish := points at: effectiveIndex + 1.
	vector := finish - start.
	length := vector r.
	length isZero ifTrue: [ tangent := 1.0 @ 0.0 ] ifFalse: [ tangent := vector / length ].
	normal := tangent y negated @ tangent x.
	point := start + (vector * ((aSegmentPosition max: 0.0) min: 1.0)).
	^ { point + (normal * anOffset). tangent }
]

{ #category : 'placement' }
CPProcessEdgeLabelPath >> nearestPlacementTo: aPoint [
	| bestDistance bestSegment bestPosition bestPoint bestTangent maximumOffset rawOffset clampedOffset normal |
	bestDistance := Float infinity.
	bestSegment := 1.
	bestPosition := 0.5.
	bestPoint := points first.
	bestTangent := 1.0 @ 0.0.
	1 to: points size - 1 do: [ :index |
		| start finish vector lengthSquared length parameter projected distance tangent |
		start := points at: index.
		finish := points at: index + 1.
		vector := finish - start.
		lengthSquared := vector dotProduct: vector.
		lengthSquared isZero ifFalse: [
			parameter := ((aPoint - start) dotProduct: vector) / lengthSquared.
			parameter := (parameter max: 0.0) min: 1.0.
			projected := start + (vector * parameter).
			distance := (aPoint - projected) r.
			distance < bestDistance ifTrue: [
				bestDistance := distance.
				bestSegment := index.
				bestPosition := parameter.
				bestPoint := projected.
				length := lengthSquared sqrt.
				tangent := vector / length.
				bestTangent := tangent ] ] ].
	normal := bestTangent y negated @ bestTangent x.
	rawOffset := (aPoint - bestPoint) dotProduct: normal.
	maximumOffset := 40.0.
	clampedOffset := (rawOffset max: maximumOffset negated) min: maximumOffset.
	^ { bestSegment. bestPosition. clampedOffset. bestPoint + (normal * clampedOffset) }
]

{ #category : 'placement' }
CPProcessEdgeLabelPath >> pathFractionForSegmentIndex: aSegmentIndex segmentPosition: aSegmentPosition [
	| effectiveIndex totalLength traversed |
	effectiveIndex := (aSegmentIndex max: 1) min: points size - 1.
	totalLength := 0.0.
	1 to: points size - 1 do: [ :index | totalLength := totalLength + ((points at: index + 1) - (points at: index)) r ].
	totalLength isZero ifTrue: [ ^ 0.5 ].
	traversed := 0.0.
	1 to: effectiveIndex - 1 do: [ :index | traversed := traversed + ((points at: index + 1) - (points at: index)) r ].
	traversed := traversed + ((((points at: effectiveIndex + 1) - (points at: effectiveIndex)) r) * aSegmentPosition).
	^ traversed / totalLength
]

{ #category : 'placement' }
CPProcessEdgeLabelPath >> segmentPlacementAtFraction: aPathFraction [
	| totalLength targetDistance traversed |
	totalLength := 0.0.
	1 to: points size - 1 do: [ :index | totalLength := totalLength + ((points at: index + 1) - (points at: index)) r ].
	totalLength isZero ifTrue: [ ^ { 1. 0.5 } ].
	targetDistance := totalLength * ((aPathFraction max: 0.0) min: 1.0).
	traversed := 0.0.
	1 to: points size - 1 do: [ :index |
		| segmentLength |
		segmentLength := ((points at: index + 1) - (points at: index)) r.
		traversed + segmentLength >= targetDistance ifTrue: [
			segmentLength isZero ifTrue: [ ^ { index. 0.0 } ].
			^ { index. (targetDistance - traversed) / segmentLength } ].
		traversed := traversed + segmentLength ].
	^ { points size - 1. 1.0 }
]
