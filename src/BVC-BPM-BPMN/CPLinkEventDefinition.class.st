"I represent the BPMN Link Event Definition that connects source Link throw Events to one target Link catch Event within one Process level."
Class {
	#name : 'CPLinkEventDefinition',
	#superclass : 'CPEventDefinition',
	#instVars : [
		'name',
		'sources',
		'target'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPLinkEventDefinition >> initialize [
	super initialize.
	sources := OrderedCollection new
]

{ #category : 'event type' }
CPLinkEventDefinition class >> eventTypeLabel [ ^ 'Link' ]

{ #category : 'event type' }
CPLinkEventDefinition class >> eventTypeIcon [ ^ #link ]

{ #category : 'accessing' }
CPLinkEventDefinition >> name [ ^ name ]

{ #category : 'accessing' }
CPLinkEventDefinition >> name: aString [ name := aString ]

{ #category : 'accessing' }
CPLinkEventDefinition >> sources [ ^ sources ]

{ #category : 'accessing' }
CPLinkEventDefinition >> sources: aCollection [ sources := aCollection asOrderedCollection ]

{ #category : 'accessing' }
CPLinkEventDefinition >> target [ ^ target ]

{ #category : 'accessing' }
CPLinkEventDefinition >> target: aLinkEventDefinition [ target := aLinkEventDefinition ]

{ #category : 'descriptions' }
CPLinkEventDefinition >> nameDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #name;
		label: 'Name';
		priority: 100;
		group: 'Link';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPLinkEventDefinition >> sourcesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #sources;
		classes: { CPLinkEventDefinition };
		reference: CPLinkEventDefinition new identifierDescription;
		label: 'Sources';
		priority: 110;
		group: 'Link';
		beOrdered;
		yourself
]

{ #category : 'descriptions' }
CPLinkEventDefinition >> targetDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #target;
		classes: { CPLinkEventDefinition };
		reference: CPLinkEventDefinition new identifierDescription;
		label: 'Target';
		priority: 120;
		group: 'Link';
		yourself
]
