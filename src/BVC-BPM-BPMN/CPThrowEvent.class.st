"I represent the common BPMN semantics of Events that throw results. I own the event-definition results and the data consumed by a throw Event."
Class {
	#name : 'CPThrowEvent',
	#superclass : 'CPEvent',
	#instVars : [
		'eventDefinitionRefs',
		'eventDefinitions',
		'dataInputs',
		'inputSet',
		'dataInputAssociations'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPThrowEvent >> initialize [
	super initialize.
	eventDefinitionRefs := OrderedCollection new.
	eventDefinitions := OrderedCollection new.
	dataInputs := OrderedCollection new.
	dataInputAssociations := OrderedCollection new
]

{ #category : 'testing' }
CPThrowEvent >> isThrowEvent [ ^ true ]

{ #category : 'accessing' }
CPThrowEvent >> eventDefinitionRefs [ ^ eventDefinitionRefs ]

{ #category : 'accessing' }
CPThrowEvent >> eventDefinitionRefs: aCollection [ eventDefinitionRefs := aCollection asOrderedCollection ]

{ #category : 'accessing' }
CPThrowEvent >> eventDefinitions [ ^ eventDefinitions ]

{ #category : 'accessing' }
CPThrowEvent >> eventDefinitions: aCollection [ eventDefinitions := aCollection asOrderedCollection ]

{ #category : 'accessing' }
CPThrowEvent >> dataInputs [ ^ dataInputs ]

{ #category : 'accessing' }
CPThrowEvent >> dataInputs: aCollection [ dataInputs := aCollection asOrderedCollection ]

{ #category : 'accessing' }
CPThrowEvent >> inputSet [ ^ inputSet ]

{ #category : 'accessing' }
CPThrowEvent >> inputSet: anInputSet [ inputSet := anInputSet ]

{ #category : 'accessing' }
CPThrowEvent >> dataInputAssociations [ ^ dataInputAssociations ]

{ #category : 'accessing' }
CPThrowEvent >> dataInputAssociations: aCollection [ dataInputAssociations := aCollection asOrderedCollection ]

{ #category : 'descriptions' }
CPThrowEvent >> eventDefinitionRefsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #eventDefinitionRefs;
		classes: { CPEventDefinition };
		reference: CPEventDefinition new eventTypeLabelDescription;
		label: 'Event definition references';
		priority: 150;
		group: 'Event';
		beOrdered;
		yourself
]

{ #category : 'descriptions' }
CPThrowEvent >> eventDefinitionsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #eventDefinitions;
		classes: { CPEventDefinition };
		reference: CPEventDefinition new eventTypeLabelDescription;
		label: 'Event definitions';
		priority: 160;
		group: 'Event';
		beOrdered;
		yourself
]

{ #category : 'descriptions' }
CPThrowEvent >> dataInputsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #dataInputs;
		classes: { CPDataInput };
		reference: CPDataInput new labelDescription;
		label: 'Data inputs';
		priority: 170;
		group: 'Data';
		beOrdered;
		yourself
]

{ #category : 'descriptions' }
CPThrowEvent >> inputSetDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #inputSet;
		classes: { CPInputSet };
		reference: CPInputSet new labelDescription;
		label: 'Input set';
		priority: 180;
		group: 'Data';
		yourself
]

{ #category : 'descriptions' }
CPThrowEvent >> dataInputAssociationsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #dataInputAssociations;
		classes: { CPDataInputAssociation };
		reference: CPDataInputAssociation new identifierDescription;
		label: 'Data input associations';
		priority: 190;
		group: 'Data';
		beOrdered;
		yourself
]
