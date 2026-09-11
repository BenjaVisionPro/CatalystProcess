"I am the explicit non-editable Process diagram editing collaborator. I satisfy the complete editing protocol while answering no operation factories."
Class {
	#name : 'CPReadOnlyProcessDiagramEditing',
	#superclass : 'CPProcessDiagramEditing',
	#category : 'BVC-BPM-GT-Editing',
	#package : 'BVC-BPM-GT',
	#tag : 'Editing'
}


{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> createBoundaryEvent: aBoundaryEvent attachedToShape: anActivityShape bounds: proposedBounds [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> createFlowNode: aFlowNode bounds: proposedBounds inProcessHostedBy: aHostShape [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> createFlowNode: aFlowNode bounds: proposedBounds inProcessHostedBy: aHostShape targetLane: aLane [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> createLane: aLane bounds: proposedBounds [
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
CPReadOnlyProcessDiagramEditing >> reattachBoundaryEvent: aBoundaryEventShape toActivityShape: anActivityShape bounds: proposedBounds [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> replaceShape: aShape with: aReplacementNode bounds: proposedBounds [
	^ nil
]


{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> appendFlowNode: aFlowNode fromShape: aSourceShape bounds: proposedBounds [
	^ nil
]


{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> appendFlowNode: aFlowNode fromShape: aSourceShape bounds: proposedBounds targetLane: aLane [
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
CPReadOnlyProcessDiagramEditing >> reconnectEdge: anEdge sourceShape: aSourceShape targetShape: aTargetShape waypoints: someWaypoints [
	^ nil
]


{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> setBoundaryEventDefinitionClass: aDefinitionClass forShape: aBoundaryEventShape [
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



{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> addChildLane: aLane toParentLane: aParentLane bounds: proposedBounds [
	^ nil
]


{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> assignFlowNode: aFlowNode toLane: aLane [
	^ nil
]


{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> moveFlowNode: aFlowNode shape: aShape bounds: aRectangle fromLane: aSourceLane toLane: aTargetLane [
	^ nil
]



{ #category : 'geometry preview' }
CPReadOnlyProcessDiagramEditing >> resizePreviewForShape: aShape toBounds: proposedBounds [
	^ nil
]


{ #category : 'geometry constraints' }
CPReadOnlyProcessDiagramEditing >> minimumHeightForResizeShape: aShape [
	^ nil
]

{ #category : 'geometry constraints' }
CPReadOnlyProcessDiagramEditing >> minimumWidthForResizeShape: aShape [
	^ nil
]



{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> createLaneSetWithLane: aLane bounds: proposedBounds [
	^ nil
]

{ #category : 'operation factories' }
CPReadOnlyProcessDiagramEditing >> insertLane: aLane relativeTo: aTargetLane after: aBoolean [
	^ nil
]


{ #category : 'participant orientation' }
CPReadOnlyProcessDiagramEditing >> makeParticipantHorizontal: aShape [
	^ nil
]

{ #category : 'participant orientation' }
CPReadOnlyProcessDiagramEditing >> makeParticipantVertical: aShape [
	^ nil
]
