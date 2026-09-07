"I define the Process diagram editing-operation factory contract used by the GT presentation layer.

The presentation and its Process/Collaboration visual surfaces share one instance of me. Concrete editing integrations answer semantic operations for the current staged transaction. Movement is expressed as one diagram intention. Concrete editing integrations resolve current staged semantics and choose ordinary movement, containment transfer, or Participant movement without exposing those distinctions to GT."
Class {
	#name : 'CPProcessDiagramEditing',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Editing',
	#package : 'BVC-BPM-GT',
	#tag : 'Editing'
}

{ #category : 'operation factories' }
CPProcessDiagramEditing >> create: aModelElement bounds: proposedBounds flowContainer: aFlowContainer [
	^ self subclassResponsibility
]


{ #category : 'testing' }
CPProcessDiagramEditing >> allowsEditing [
	^ true
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> moveShapes: boundsByShape toFlowContainer: aFlowContainer waypointsByEdge: waypointsByEdge [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> resizeShape: aShape toBounds: proposedBounds [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> replaceShape: aShape with: aReplacementNode bounds: proposedBounds [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> connectFrom: aSourceShape to: aTargetShape waypoints: someWaypoints [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> insertFlowNode: aFlowNode intoEdge: anEdge bounds: proposedBounds [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> remove: someDiagramElements [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> reconnectEdge: anEdge sourceShape: aSourceShape targetShape: aTargetShape [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> setShape: aShape expanded: aBoolean [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> setWaypoints: someWaypoints forEdge: anEdge [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> setLabelSegmentIndex: aSegmentIndex segmentPosition: aSegmentPosition offset: anOffset forEdge: anEdge [
	^ self subclassResponsibility
]

