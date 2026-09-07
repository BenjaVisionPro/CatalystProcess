"I define the Process diagram editing-operation factory contract used by the GT presentation layer.

The presentation and its Process/Collaboration visual surfaces share one instance of me. Concrete editing integrations answer semantic operations for the current staged transaction. During this migration pass the protocol deliberately mirrors the existing operation distinctions one-for-one; later passes collapse distinctions such as move versus transfer behind domain-shaped editing intentions."
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

{ #category : 'operation factories' }
CPProcessDiagramEditing >> moveParticipantShapeOperation [
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
CPProcessDiagramEditing >> moveShapeOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> transferFlowNodeOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> transferFlowNodesOperation [
	^ self subclassResponsibility
]

{ #category : 'operation factories' }
CPProcessDiagramEditing >> moveShapesOperation [
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

