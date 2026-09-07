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
CPProcessDiagramEditing >> createParticipantOperation [
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
CPProcessDiagramEditing >> resizeParticipantShapeOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> removeParticipantOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> resizeShapeOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> createFlowNodeOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> replaceFlowNodeOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> connectFlowNodesOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> connectMessageFlowOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> insertFlowNodeOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> removeFlowNodeOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> removeSequenceFlowOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> reconnectSequenceFlowOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> setShapeExpandedOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> setEdgeWaypointsOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> setEdgeLabelPlacementOperation [
	^ self subclassResponsibility
]

