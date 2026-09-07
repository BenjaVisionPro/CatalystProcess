"I am the explicit non-editable Process diagram editing collaborator. I satisfy the complete editing protocol while answering no operation factories."
Class {
	#name : 'CPReadOnlyProcessDiagramEditing',
	#superclass : 'CPProcessDiagramEditing',
	#category : 'BVC-BPM-GT-Editing',
	#package : 'BVC-BPM-GT',
	#tag : 'Editing'
}

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> create: aModelElement bounds: proposedBounds flowContainer: aFlowContainer [
	^ nil
]


{ #category : 'testing' }
CPReadOnlyProcessDiagramEditing >> allowsEditing [
	^ false
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> moveShapes: boundsByShape toFlowContainer: aFlowContainer waypointsByEdge: waypointsByEdge [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> resizeShape: aShape toBounds: proposedBounds [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> replaceFlowNodeOperation [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> connectFrom: aSourceShape to: aTargetShape waypoints: someWaypoints [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> insertFlowNodeOperation [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> remove: someDiagramElements [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> reconnectSequenceFlowOperation [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> setShapeExpandedOperation [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> setEdgeWaypointsOperation [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> setEdgeLabelPlacementOperation [
	^ nil
]

