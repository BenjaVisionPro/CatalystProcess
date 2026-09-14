"I represent the common BPMN semantics of Events that catch triggers. I own the event-definition triggers and the data produced by a catch Event."
Class {
	#name : 'CPCatchEvent',
	#superclass : 'CPEvent',
	#instVars : [
		'eventDefinitionRefs',
		'eventDefinitions',
		'dataOutputs',
		'outputSet',
		'dataOutputAssociations',
		'parallelMultiple'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPCatchEvent >> initialize [
	super initialize.
	eventDefinitionRefs := OrderedCollection new.
	eventDefinitions := OrderedCollection new.
	dataOutputs := OrderedCollection new.
	dataOutputAssociations := OrderedCollection new.
	parallelMultiple := false
]

{ #category : 'testing' }
CPCatchEvent >> isCatchEvent [ ^ true ]

{ #category : 'accessing' }
CPCatchEvent >> eventDefinitionRefs [ ^ eventDefinitionRefs ]

{ #category : 'accessing' }
CPCatchEvent >> eventDefinitionRefs: aCollection [ eventDefinitionRefs := aCollection asOrderedCollection ]

{ #category : 'accessing' }
CPCatchEvent >> eventDefinitions [ ^ eventDefinitions ]

{ #category : 'accessing' }
CPCatchEvent >> eventDefinitions: aCollection [ eventDefinitions := aCollection asOrderedCollection ]

{ #category : 'accessing' }
CPCatchEvent >> dataOutputs [ ^ dataOutputs ]

{ #category : 'accessing' }
CPCatchEvent >> dataOutputs: aCollection [ dataOutputs := aCollection asOrderedCollection ]

{ #category : 'accessing' }
CPCatchEvent >> outputSet [ ^ outputSet ]

{ #category : 'accessing' }
CPCatchEvent >> outputSet: anOutputSet [ outputSet := anOutputSet ]

{ #category : 'accessing' }
CPCatchEvent >> dataOutputAssociations [ ^ dataOutputAssociations ]

{ #category : 'accessing' }
CPCatchEvent >> dataOutputAssociations: aCollection [ dataOutputAssociations := aCollection asOrderedCollection ]

{ #category : 'accessing' }
CPCatchEvent >> parallelMultiple [ ^ parallelMultiple ]

{ #category : 'accessing' }
CPCatchEvent >> parallelMultiple: aBoolean [ parallelMultiple := aBoolean ]

{ #category : 'descriptions' }
CPCatchEvent >> eventDefinitionRefsDescription [
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
CPCatchEvent >> eventDefinitionsDescription [
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
CPCatchEvent >> dataOutputsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #dataOutputs;
		classes: { CPDataOutput };
		reference: CPDataOutput new labelDescription;
		label: 'Data outputs';
		priority: 170;
		group: 'Data';
		beOrdered;
		yourself
]

{ #category : 'descriptions' }
CPCatchEvent >> outputSetDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #outputSet;
		classes: { CPOutputSet };
		reference: CPOutputSet new labelDescription;
		label: 'Output set';
		priority: 180;
		group: 'Data';
		yourself
]

{ #category : 'descriptions' }
CPCatchEvent >> dataOutputAssociationsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #dataOutputAssociations;
		classes: { CPDataOutputAssociation };
		reference: CPDataOutputAssociation new identifierDescription;
		label: 'Data output associations';
		priority: 190;
		group: 'Data';
		beOrdered;
		yourself
]

{ #category : 'descriptions' }
CPCatchEvent >> parallelMultipleDescription [
	<magritteDescription>
	^ MABooleanDescription new
		accessor: #parallelMultiple;
		label: 'Parallel multiple';
		priority: 200;
		group: 'Event';
		yourself
]


{ #category : 'data' }
CPCatchEvent >> dataAssociationDescriptions [
	^ { self dataOutputAssociationsDescription }
]
