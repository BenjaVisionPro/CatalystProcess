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
CPReadOnlyProcessDiagramEditing >> replaceFlowNode: aFlowNode with: aReplacementNode bounds: proposedBounds flowContainer: aFlowContainer [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> connectFrom: aSourceShape to: aTargetShape waypoints: someWaypoints [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> insertFlowNode: aFlowNode intoSequenceFlow: aSequenceFlow bounds: proposedBounds flowContainer: aFlowContainer [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> remove: someDiagramElements [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> reconnectSequenceFlow: aSequenceFlow source: aSource target: aTarget flowContainer: aFlowContainer [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> setShape: aShape expanded: aBoolean [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> setWaypoints: someWaypoints forEdge: anEdge [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> setLabelSegmentIndex: aSegmentIndex segmentPosition: aSegmentPosition offset: anOffset forEdge: anEdge [
	^ nil
]

