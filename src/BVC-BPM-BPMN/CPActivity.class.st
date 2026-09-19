Class {
	#name : 'CPActivity',
	#superclass : 'CPFlowNode',
	#instVars : [
		'ioSpecification',
		'properties',
		'dataInputAssociations',
		'dataOutputAssociations',
		'loopCharacteristics'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPActivity >> isActivity [
	^ true
]


{ #category : 'message flow' }
CPActivity >> canBeMessageFlowEndpoint [
	^ true
]


{ #category : 'initialization' }
CPActivity >> initialize [
	super initialize.
	properties := OrderedCollection new.
	dataInputAssociations := OrderedCollection new.
	dataOutputAssociations := OrderedCollection new
]

{ #category : 'accessing' }
CPActivity >> ioSpecification [ ^ ioSpecification ]
{ #category : 'accessing' }
CPActivity >> ioSpecification: aSpecification [ ioSpecification := aSpecification ]
{ #category : 'accessing' }
CPActivity >> properties [ ^ properties ]
{ #category : 'accessing' }
CPActivity >> properties: aCollection [ properties := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPActivity >> dataInputAssociations [ ^ dataInputAssociations ]
{ #category : 'accessing' }
CPActivity >> dataInputAssociations: aCollection [ dataInputAssociations := aCollection asOrderedCollection ]
{ #category : 'accessing' }
CPActivity >> dataOutputAssociations [ ^ dataOutputAssociations ]
{ #category : 'accessing' }
CPActivity >> dataOutputAssociations: aCollection [ dataOutputAssociations := aCollection asOrderedCollection ]

{ #category : 'descriptions' }
CPActivity >> ioSpecificationDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #ioSpecification;
		classes: { CPInputOutputSpecification };
		reference: CPInputOutputSpecification new identifierDescription;
		label: 'Input/output specification';
		priority: 140;
		group: 'Data';
		yourself
]
{ #category : 'descriptions' }
CPActivity >> propertiesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #properties; classes: { CPProperty }; reference: CPProperty new labelDescription; label: 'Properties'; priority: 150; group: 'Data'; beOrdered; yourself
]
{ #category : 'descriptions' }
CPActivity >> dataInputAssociationsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #dataInputAssociations; classes: { CPDataInputAssociation }; reference: CPDataInputAssociation new identifierDescription; label: 'Input associations'; priority: 160; group: 'Data'; beOrdered; yourself
]
{ #category : 'descriptions' }
CPActivity >> dataOutputAssociationsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #dataOutputAssociations; classes: { CPDataOutputAssociation }; reference: CPDataOutputAssociation new identifierDescription; label: 'Output associations'; priority: 170; group: 'Data'; beOrdered; yourself
]


{ #category : 'data' }
CPActivity >> dataAssociationDescriptions [
	^ { self dataInputAssociationsDescription. self dataOutputAssociationsDescription }
]

{ #category : 'accessing' }
CPActivity >> loopCharacteristics [
	^ loopCharacteristics
]

{ #category : 'accessing' }
CPActivity >> loopCharacteristics: aLoopCharacteristics [
	loopCharacteristics := aLoopCharacteristics
]

{ #category : 'descriptions' }
CPActivity >> loopCharacteristicsDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #loopCharacteristics;
		classes: { CPLoopCharacteristics };
		reference: CPLoopCharacteristics new identifierDescription;
		label: 'Loop characteristics';
		priority: 180;
		group: 'Execution';
		yourself
]
