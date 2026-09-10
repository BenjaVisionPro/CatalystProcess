"I define the Process diagram editing-operation factory contract used by the GT presentation layer.

The presentation and its Process/Collaboration visual surfaces share one instance of me. My editing boundary is expressed in BPMN DI identities wherever an existing depiction identifies the edited object or target. A nested Process target is identified by its hosting CPShape; nil identifies the root Process surface. Concrete editing integrations resolve current staged semantics and choose ordinary movement, containment transfer, Participant movement, or edge-family-specific reconnect semantics without exposing those distinctions to GT. Reconnect carries presentation-authored waypoints because an edge may live in a different DI coordinate plane from its semantic endpoints."
Class {
	#name : 'CPProcessDiagramEditing',
	#superclass : 'Object',
	#category : 'BVC-BPM-GT-Editing',
	#package : 'BVC-BPM-GT',
	#tag : 'Editing'
}


{ #category : 'operation factories' }
CPProcessDiagramEditing >> createBoundaryEvent: aBoundaryEvent attachedToShape: anActivityShape bounds: proposedBounds [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> createFlowNode: aFlowNode bounds: proposedBounds inProcessHostedBy: aHostShape [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> createLane: aLane bounds: proposedBounds [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> createLaneSetWithLane: aLane bounds: proposedBounds [
	^ self subclassResponsibility
]


{ #category : 'operation factories' }
CPProcessDiagramEditing >> createParticipant: aParticipant bounds: proposedBounds [
	^ self subclassResponsibility
]


{ #category : 'testing' }
CPProcessDiagramEditing >> allowsEditing [
	^ true
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> moveShapes: boundsByShape toProcessHostedBy: aHostShape waypointsByEdge: waypointsByEdge [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> resizeShape: aShape toBounds: proposedBounds [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> reattachBoundaryEvent: aBoundaryEventShape toActivityShape: anActivityShape bounds: proposedBounds [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> replaceShape: aShape with: aReplacementNode bounds: proposedBounds [
	^ self subclassResponsibility
]


{ #category : 'operation factories' }
CPProcessDiagramEditing >> appendFlowNode: aFlowNode fromShape: aSourceShape bounds: proposedBounds [
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
CPProcessDiagramEditing >> reconnectEdge: anEdge sourceShape: aSourceShape targetShape: aTargetShape waypoints: someWaypoints [
	^ self subclassResponsibility
]


{ #category : 'operation factories' }
CPProcessDiagramEditing >> setBoundaryEventDefinitionClass: aDefinitionClass forShape: aBoundaryEventShape [
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



{ #category : 'operation factories' }
CPProcessDiagramEditing >> insertLane: aLane relativeTo: aTargetLane after: aBoolean [
	^ self subclassResponsibility
]


{ #category : 'operation factories' }
CPProcessDiagramEditing >> addChildLane: aLane toParentLane: aParentLane bounds: proposedBounds [
	^ self subclassResponsibility
]


{ #category : 'operation factories' }
CPProcessDiagramEditing >> assignFlowNode: aFlowNode toLane: aLane [
	^ self subclassResponsibility
]


{ #category : 'operation factories' }
CPProcessDiagramEditing >> moveFlowNode: aFlowNode shape: aShape bounds: aRectangle fromLane: aSourceLane toLane: aTargetLane [
	^ self subclassResponsibility
]
