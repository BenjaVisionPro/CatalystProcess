"I represent a BPMN Boundary Event attached to one Activity. My EventDefinitions identify the caught trigger; cancelActivity distinguishes interrupting from non-interrupting handling."
Class {
	#name : 'CPBoundaryEvent',
	#superclass : 'CPCatchEvent',
	#instVars : [
		'attachedToRef',
		'cancelActivity'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPBoundaryEvent >> initialize [
	super initialize.
	cancelActivity := true
]

{ #category : 'accessing' }
CPBoundaryEvent >> attachedToRef [ ^ attachedToRef ]
{ #category : 'accessing' }
CPBoundaryEvent >> attachedToRef: anActivity [ attachedToRef := anActivity ]
{ #category : 'accessing' }
CPBoundaryEvent >> cancelActivity [ ^ cancelActivity ]
{ #category : 'accessing' }
CPBoundaryEvent >> cancelActivity: aBoolean [ cancelActivity := aBoolean ]
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

{ #category : 'testing' }
CPBoundaryEvent >> isBoundaryEvent [ ^ true ]

{ #category : 'testing' }
CPBoundaryEvent >> isIntermediateEvent [ ^ true ]

{ #category : 'event type' }
CPBoundaryEvent class >> eventDefinitionTypes [
	^ { CPTimerEventDefinition. CPErrorEventDefinition. CPMessageEventDefinition. CPEscalationEventDefinition. CPConditionalEventDefinition }
]

{ #category : 'defaults' }
CPBoundaryEvent class >> defaultIcon [ ^ #circleDot ]
