Class {
	#name : 'CPNearestPositionDiamondAnchor',
	#superclass : 'BlNearestPositionAnchor',
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'accessing' }
CPNearestPositionDiamondAnchor class >> label [
	^ 'Diamond'
]

{ #category : 'geometry' }
CPNearestPositionDiamondAnchor >> positionForAnchoredElement: aGeometryElement within: aCommonParent [
	| bounds top right bottom left edges path result |
	bounds := self referenceElement bounds inParent: aCommonParent.
	top := bounds center x @ bounds top.
	right := bounds right @ bounds center y.
	bottom := bounds center x @ bounds bottom.
	left := bounds left @ bounds center y.
	edges := {
		BlLineGeometry from: top to: right.
		BlLineGeometry from: right to: bottom.
		BlLineGeometry from: bottom to: left.
		BlLineGeometry from: left to: top }.
	path := BlLineGeometry
		from: bounds center
		to: (self nearestToElement bounds inParent: aCommonParent) center.
	^ edges
		detect: [ :each |
			result := each intersectionWith: path.
			result isNotNil ]
		ifFound: [ result ]
		ifNone: [ bounds center ]
]
