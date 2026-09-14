"I describe the resolved semantic target of one connection drag coordinated by CPCollaborationVisualElement.

I distinguish a Process-local connection target from a cross-Pool MessageFlow target through explicit constructors and testing messages, avoiding hidden symbol dispatch."
Class {
	#name : 'CPCollaborationConnectionTarget',
	#superclass : 'Object',
	#instVars : [
		'modelElement',
		'processTarget'
	],
	#category : 'BVC-BPM-GT-Diagram',
	#package : 'BVC-BPM-GT',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPCollaborationConnectionTarget class >> processTo: aModelElement [
	^ self new
		modelElement: aModelElement;
		processTarget: true;
		yourself
]

{ #category : 'instance creation' }
CPCollaborationConnectionTarget class >> messageFlowTo: anInteractionNode [
	^ self new
		modelElement: anInteractionNode;
		processTarget: false;
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
CPCollaborationConnectionTarget >> isProcessTarget [
	^ processTarget
]

{ #category : 'testing' }
CPCollaborationConnectionTarget >> isMessageFlowTarget [
	^ processTarget not
]

{ #category : 'private' }
CPCollaborationConnectionTarget >> processTarget: aBoolean [
	processTarget := aBoolean
]
