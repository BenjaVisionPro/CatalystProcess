"I stage reconnection of one existing CPMessageFlow while preserving its semantic and Collaboration CPEdge identities.

The presentation supplies authored Collaboration-coordinate waypoints because MessageFlow endpoints may be rendered in a hosted Process coordinate plane. I own semantic endpoint validation and coordinated staging of the MessageFlow and its existing Collaboration DI edge."
Class {
	#name : 'CPAtelierReconnectMessageFlow',
	#superclass : 'CFAtelierOperation',
	#instVars : [
		'messageFlow',
		'proposedSource',
		'proposedTarget',
		'proposedWaypoints',
		'processMemento'
	],
	#category : 'BVC-BPM-Atelier-Diagram',
	#package : 'BVC-BPM-Atelier',
	#tag : 'Diagram'
}

{ #category : 'instance creation' }
CPAtelierReconnectMessageFlow class >> messageFlow: aMessageFlow source: aSource target: aTarget waypoints: someWaypoints processMemento: aMemento [
	^ self new
		messageFlow: aMessageFlow;
		proposedSource: aSource;
		proposedTarget: aTarget;
		proposedWaypoints: someWaypoints;
		processMemento: aMemento;
		yourself
]

{ #category : 'assessing' }
CPAtelierReconnectMessageFlow >> assess [
	| context currentSource currentTarget sourceParticipant targetParticipant ruleResult flowMemento sourceDescription targetDescription edgeMatches edge edgeMemento waypointsDescription |
	context := self collaborationContext.
	context ifNil: [ ^ self rejectedBecause: 'The Process has no staged definitional Collaboration.' ].
	messageFlow ifNil: [ ^ self rejectedBecause: 'A MessageFlow is required.' ].
	(context messageFlows identityIncludes: messageFlow) ifFalse: [
		^ self rejectedBecause: 'The MessageFlow does not belong to the staged Collaboration.' ].
	proposedWaypoints ifNil: [ ^ self rejectedBecause: 'Reconnect waypoints are required.' ].
	proposedWaypoints size < 2 ifTrue: [ ^ self rejectedBecause: 'A reconnectable MessageFlow edge requires at least two waypoints.' ].

	currentSource := context stagedSourceOf: messageFlow.
	currentTarget := context stagedTargetOf: messageFlow.
	sourceParticipant := context participantForEndpoint: proposedSource.
	targetParticipant := context participantForEndpoint: proposedTarget.
	ruleResult := CPMessageFlowConnectionRules new
		assessConnectionFrom: proposedSource
		to: proposedTarget
		sourceParticipant: sourceParticipant
		targetParticipant: targetParticipant.
	ruleResult isAllowed ifFalse: [ ^ self rejectedBecause: ruleResult message ].

	flowMemento := context mementoForMember: messageFlow.
	sourceDescription := flowMemento magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := flowMemento magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	[
		sourceDescription validate: proposedSource.
		targetDescription validate: proposedTarget
	] on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].

	edgeMatches := context elements select: [ :each |
		each isEdge and: [ (context diagramContext modelElementOf: each) == messageFlow ] ].
	edgeMatches size = 1 ifFalse: [
		^ self rejectedBecause: 'The MessageFlow requires exactly one staged Collaboration diagram edge.' ].
	edge := edgeMatches first.
	edgeMemento := context diagramMemento childMementoFor: edge inRelation: context elementsDescription.
	waypointsDescription := edgeMemento magritteDescription detect: [ :each | each handlesSelector: #waypoints ].
	[ waypointsDescription validate: proposedWaypoints ]
		on: MAValidationError do: [ :anException | ^ self rejectedBecause: anException printString ].

	^ CPAtelierReconnectMessageFlowAssessment
		messageFlow: messageFlow
		currentSource: currentSource
		currentTarget: currentTarget
		proposedSource: proposedSource
		proposedTarget: proposedTarget
]

{ #category : 'applying' }
CPAtelierReconnectMessageFlow >> applyAssessment: anAssessment [
	| context flowMemento sourceDescription targetDescription edge edgeMemento waypointsDescription |
	context := self collaborationContext.
	flowMemento := context mementoForMember: messageFlow.
	sourceDescription := flowMemento magritteDescription detect: [ :each | each handlesSelector: #sourceRef ].
	targetDescription := flowMemento magritteDescription detect: [ :each | each handlesSelector: #targetRef ].
	flowMemento write: anAssessment proposedSource using: sourceDescription.
	flowMemento write: anAssessment proposedTarget using: targetDescription.
	edge := (context elements select: [ :each |
		each isEdge and: [ (context diagramContext modelElementOf: each) == messageFlow ] ]) first.
	edgeMemento := context diagramMemento childMementoFor: edge inRelation: context elementsDescription.
	waypointsDescription := edgeMemento magritteDescription detect: [ :each | each handlesSelector: #waypoints ].
	edgeMemento write: proposedWaypoints using: waypointsDescription
]

{ #category : 'private - staged state' }
CPAtelierReconnectMessageFlow >> collaborationContext [
	^ CPProcessCollaborationContext inRootMemento: processMemento
]

{ #category : 'private' }
CPAtelierReconnectMessageFlow >> rejectedBecause: aString [
	^ CPAtelierReconnectMessageFlowAssessment messageFlow: messageFlow rejectedBecause: aString
]

{ #category : 'accessing' }
CPAtelierReconnectMessageFlow >> messageFlow: anObject [ messageFlow := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlow >> proposedSource: anObject [ proposedSource := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlow >> proposedTarget: anObject [ proposedTarget := anObject ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlow >> proposedWaypoints: aCollection [ proposedWaypoints := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPAtelierReconnectMessageFlow >> processMemento: aMemento [ processMemento := aMemento ]
