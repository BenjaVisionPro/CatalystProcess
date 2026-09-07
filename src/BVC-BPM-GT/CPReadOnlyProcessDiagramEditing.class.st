"I am the explicit non-editable Process diagram editing collaborator. I satisfy the complete editing protocol while answering no operation factories."
Class {
	#name : 'CPReadOnlyProcessDiagramEditing',
	#superclass : 'CPProcessDiagramEditing',
	#category : 'BVC-BPM-GT-Editing',
	#package : 'BVC-BPM-GT',
	#tag : 'Editing'
}

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> createFlowNode: aFlowNode bounds: proposedBounds inProcessHostedBy: aHostShape [
	^ nil
]


{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> createParticipant: aParticipant bounds: proposedBounds [
	^ nil
]


{ #category : 'testing' }
CPReadOnlyProcessDiagramEditing >> allowsEditing [
	^ false
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> moveShapes: boundsByShape toProcessHostedBy: aHostShape waypointsByEdge: waypointsByEdge [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> resizeShape: aShape toBounds: proposedBounds [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> replaceShape: aShape with: aReplacementNode bounds: proposedBounds [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> connectFrom: aSourceShape to: aTargetShape waypoints: someWaypoints [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> insertFlowNode: aFlowNode intoEdge: anEdge bounds: proposedBounds [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> remove: someDiagramElements [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> reconnectEdge: anEdge sourceShape: aSourceShape targetShape: aTargetShape [
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

