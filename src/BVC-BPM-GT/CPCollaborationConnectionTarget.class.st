"I describe the resolved semantic target of one connection drag coordinated by CPCollaborationVisualElement.

I distinguish a normal SequenceFlow target from a cross-Pool MessageFlow target through explicit constructors and testing messages, avoiding hidden symbol dispatch."
Class {
	#name : 'CPCollaborationConnectionTarget',
	#superclass : 'Object',
	#instVars : [
		'modelElement',
		'sequenceFlowTarget'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPCollaborationConnectionTarget class >> sequenceFlowTo: aFlowNode [
	^ self new
		modelElement: aFlowNode;
		sequenceFlowTarget: true;
		yourself
]

{ #category : 'instance creation' }
CPCollaborationConnectionTarget class >> messageFlowTo: anInteractionNode [
	^ self new
		modelElement: anInteractionNode;
		sequenceFlowTarget: false;
		yourself
]

{ #category : 'accessing' }
CPCollaborationConnectionTarget >> modelElement [
	^ modelElement
]

{ #category : 'accessing' }
CPCollaborationConnectionTarget >> modelElement: anObject [
	modelElement := anObject
]

{ #category : 'testing' }
CPCollaborationConnectionTarget >> isSequenceFlowTarget [
	^ sequenceFlowTarget
]

{ #category : 'testing' }
CPCollaborationConnectionTarget >> isMessageFlowTarget [
	^ sequenceFlowTarget not
]

{ #category : 'private' }
CPCollaborationConnectionTarget >> sequenceFlowTarget: aBoolean [
	sequenceFlowTarget := aBoolean
]
