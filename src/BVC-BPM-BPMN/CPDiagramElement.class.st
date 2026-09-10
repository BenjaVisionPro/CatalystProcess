"I am the common identifiable BPMN-DI diagram element state.

Semantic model references belong to the concrete DI elements that define them (CPPlane, CPShape and CPEdge), not to every diagram element."
Class {
	#name : 'CPDiagramElement',
	#superclass : 'CFIdentifiableObject',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPDiagramElement >> isShape [
	^ false
]

{ #category : 'testing' }
CPDiagramElement >> isEdge [
	^ false
]
