"I stage one BPMN MessageFlow and its Collaboration DI edge in the root Process transaction.

The caller supplies the proposed Collaboration-coordinate waypoints. Endpoint admissibility remains owned by CPMessageFlowConnectionRules; this operation owns transaction validation and staging."
Class {
	#name : 'CPAtelierConnectMessageFlow',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'source',
		'target',
		'waypoints',
		'processMemento'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierConnectMessageFlow class >> source: aSource target: aTarget waypoints: someWaypoints processMemento: aMemento [
	^ self new
		source: aSource;
		target: aTarget;
		waypoints: someWaypoints;
		processMemento: aMemento;
		yourself
]

{ #category : 'assessing' }
CPAtelierConnectMessageFlow >> assess [
	| collaborationContext collaboration ruleResult messageFlow sourceDescription targetDescription edge proposedMessageFlows proposedElements |
	collaborationContext := self collaborationContext.
	collaborationContext ifNil: [
		^ self rejectedBecause: 'The Process has no staged definitional Collaboration.' ].
	waypoints ifNil: [
		^ self rejectedBecause: 'MessageFlow waypoints are required.' ].
	waypoints size < 2 ifTrue: [
		^ self rejectedBecause: 'A MessageFlow edge requires at least two waypoints.' ].

	collaboration := collaborationContext collaboration.
	ruleResult := CPMessageFlowConnectionRules new
		assessConnectionFrom: source
		to: target
		participants: collaborationContext participants.
	ruleResult isAllowed ifFalse: [
		^ self rejectedBecause: ruleResult message ].

	messageFlow := CPMessageFlow new.
	sourceDescription := messageFlow magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := messageFlow magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	[
		sourceDescription validate: source.
		targetDescription validate: target
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].

	edge := CPEdge new
		modelElement: messageFlow;
		waypoints: waypoints asOrderedCollection;
		yourself.
	proposedMessageFlows := collaborationContext messageFlows asOrderedCollection copy.
	proposedMessageFlows add: messageFlow.
	[
		collaborationContext messageFlowsDescription validate: proposedMessageFlows
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].
	proposedElements := collaborationContext elements asOrderedCollection copy.
	proposedElements add: edge.
	[
		collaborationContext elementsDescription validate: proposedElements
	] on: MAValidationError do: [ :anException |
		^ self rejectedBecause: anException printString ].

	^ CPAtelierConnectMessageFlowAssessment
		source: source
		target: target
		messageFlow: messageFlow
		edge: edge
		proposedMessageFlows: proposedMessageFlows
		proposedDiagramElements: proposedElements
]

{ #category : 'applying' }
CPAtelierConnectMessageFlow >> applyAssessment: anAssessment [
	| context messageFlowMemento sourceDescription targetDescription |
	context := self collaborationContext.
	context collaborationMemento
		write: anAssessment proposedMessageFlows
		using: context messageFlowsDescription.
	messageFlowMemento := context collaborationMemento
		childMementoFor: anAssessment messageFlow
		inRelation: context messageFlowsDescription.
	sourceDescription := messageFlowMemento magritteDescription
		detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := messageFlowMemento magritteDescription
		detect: [ :each | each handlesSelector: #targetRef ].
	messageFlowMemento write: source using: sourceDescription.
	messageFlowMemento write: target using: targetDescription.
	context diagramMemento
		write: anAssessment proposedDiagramElements
		using: context elementsDescription
]

{ #category : 'private - staged state' }
CPAtelierConnectMessageFlow >> collaborationContext [
	^ CPProcessCollaborationContext inRootMemento: processMemento
]
{ #category : 'private' }
CPAtelierConnectMessageFlow >> rejectedBecause: aString [
	^ CPAtelierConnectMessageFlowAssessment
		source: source
		target: target
		rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierConnectMessageFlow >> source: anObject [ source := anObject ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlow >> target: anObject [ target := anObject ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlow >> waypoints: aCollection [ waypoints := aCollection ]
{ #category : 'accessing' }
CPAtelierConnectMessageFlow >> processMemento: aMemento [ processMemento := aMemento ]
