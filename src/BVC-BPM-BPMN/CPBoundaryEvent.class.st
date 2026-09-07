"I represent a BPMN Boundary Event attached to one Activity. My EventDefinitions identify the caught trigger; cancelActivity distinguishes interrupting from non-interrupting handling."
Class {
	#name : 'CPBoundaryEvent',
	#superclass : 'CPIntermediateEvent',
	#instVars : [
		'attachedToRef',
		'cancelActivity',
		'eventDefinitions'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPBoundaryEvent >> initialize [
	super initialize.
	cancelActivity := true.
	eventDefinitions := OrderedCollection new
]

{ #category : 'accessing' }
CPBoundaryEvent >> attachedToRef [ ^ attachedToRef ]
{ #category : 'accessing' }
CPBoundaryEvent >> attachedToRef: anActivity [ attachedToRef := anActivity ]
{ #category : 'accessing' }
CPBoundaryEvent >> cancelActivity [ ^ cancelActivity ]
{ #category : 'accessing' }
CPBoundaryEvent >> cancelActivity: aBoolean [ cancelActivity := aBoolean ]
{ #category : 'accessing' }
CPBoundaryEvent >> eventDefinitions [ ^ eventDefinitions ]
{ #category : 'accessing' }
CPBoundaryEvent >> eventDefinitions: aCollection [ eventDefinitions := aCollection ]

{ #category : 'descriptions' }
CPBoundaryEvent >> attachedToRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #attachedToRef;
		classes: { CPActivity };
		reference: self labelDescription;
		label: 'Attached to';
		priority: 105;
		group: 'Relations';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPBoundaryEvent >> cancelActivityDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #cancelActivity;
		label: 'Interrupt activity';
		priority: 115;
		group: 'Event';
		yourself
]

{ #category : 'descriptions' }
CPBoundaryEvent >> eventDefinitionsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #eventDefinitions;
		classes: { CPEventDefinition };
		reference: CPEventDefinition new eventTypeLabelDescription;
		label: 'Event definitions';
		priority: 125;
		group: 'Event';
		beReadOnly;
		yourself
]

{ #category : 'testing' }
CPBoundaryEvent >> isBoundaryEvent [ ^ true ]

{ #category : 'event type' }
CPBoundaryEvent class >> eventDefinitionTypes [
	^ { CPMessageEventDefinition. CPTimerEventDefinition. CPErrorEventDefinition. CPConditionalEventDefinition. CPSignalEventDefinition }
]

{ #category : 'defaults' }
CPBoundaryEvent class >> defaultIcon [ ^ #circleDot ]
