Class {
	#name : 'CPActivity',
	#superclass : 'CPFlowNode',
	#instVars : [
		'ioSpecification',
		'properties',
		'dataInputAssociations',
		'dataOutputAssociations',
		'loopCharacteristics',
		'isForCompensation',
		'startQuantity',
		'completionQuantity',
		'default',
		'boundaryEventRefs',
		'resources'
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
	dataOutputAssociations := OrderedCollection new.
	isForCompensation := false.
	startQuantity := 1.
	completionQuantity := 1.
	boundaryEventRefs := OrderedCollection new.
	resources := OrderedCollection new
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


{ #category : 'accessing' }
CPActivity >> isForCompensation [ ^ isForCompensation ]
{ #category : 'accessing' }
CPActivity >> isForCompensation: aBoolean [ isForCompensation := aBoolean ]
{ #category : 'accessing' }
CPActivity >> startQuantity [ ^ startQuantity ]
{ #category : 'accessing' }
CPActivity >> startQuantity: anInteger [ startQuantity := anInteger ]
{ #category : 'accessing' }
CPActivity >> completionQuantity [ ^ completionQuantity ]
{ #category : 'accessing' }
CPActivity >> completionQuantity: anInteger [ completionQuantity := anInteger ]
{ #category : 'accessing' }
CPActivity >> default [ ^ default ]
{ #category : 'accessing' }
CPActivity >> default: aSequenceFlow [ default := aSequenceFlow ]

{ #category : 'testing' }
CPActivity >> isDefaultFlow: aSequenceFlow [ ^ default == aSequenceFlow ]

{ #category : 'validation' }
CPActivity >> hasValidDefaultFlow [ ^ default isNil or: [ self outgoing identityIncludes: default ] ]

{ #category : 'descriptions' }
CPActivity >> isForCompensationDescription [
	<magritteDescription>
	^ MABooleanDescription new accessor: #isForCompensation; label: 'For compensation'; priority: 190; group: 'Execution'; yourself
]
{ #category : 'descriptions' }
CPActivity >> startQuantityDescription [
	<magritteDescription>
	^ MANumberDescription new accessor: #startQuantity; label: 'Start quantity'; priority: 200; group: 'Execution'; yourself
]
{ #category : 'descriptions' }
CPActivity >> completionQuantityDescription [
	<magritteDescription>
	^ MANumberDescription new accessor: #completionQuantity; label: 'Completion quantity'; priority: 210; group: 'Execution'; yourself
]
{ #category : 'descriptions' }
CPActivity >> defaultDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new accessor: #default; classes: { CPSequenceFlow }; reference: CPSequenceFlow new labelDescription; label: 'Default'; priority: 130; group: 'Relations'; yourself
]


{ #category : 'accessing' }
CPActivity >> boundaryEventRefs [
	^ boundaryEventRefs
]

{ #category : 'private - events' }
CPActivity >> addBoundaryEvent: aBoundaryEvent [
	(boundaryEventRefs identityIncludes: aBoundaryEvent) ifFalse: [ boundaryEventRefs add: aBoundaryEvent ]
]

{ #category : 'private - events' }
CPActivity >> removeBoundaryEvent: aBoundaryEvent [
	boundaryEventRefs remove: aBoundaryEvent ifAbsent: [ ]
]

{ #category : 'descriptions' }
CPActivity >> boundaryEventRefsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #boundaryEventRefs;
		classes: { CPBoundaryEvent };
		reference: CPBoundaryEvent new labelDescription;
		label: 'Boundary events';
		priority: 125;
		group: 'Relations';
		beReadOnly;
		yourself
]


{ #category : 'accessing' }
CPActivity >> resources [ ^ resources ]
{ #category : 'accessing' }
CPActivity >> resources: aCollection [ resources := aCollection asOrderedCollection ]
{ #category : 'descriptions' }
CPActivity >> resourcesDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new accessor: #resources; classes: { CPResourceRole }; reference: CPResourceRole new identifierDescription; label: 'Resources'; priority: 185; group: 'Execution'; beModifiable; beOrdered; newItemClassStencil: [ :aClass | aClass new ]; yourself
]

{ #category : 'testing' }
CPActivity >> isActivity [
	^ true
]

{ #category : 'testing' }
CPActivity >> hasEmbeddedCompensationHandler [
	^ false
]


{ #category : 'testing' }
CPActivity >> hasCustomCompensationHandler [
	^ false
]

{ #category : 'testing' }
CPActivity >> usesDefaultCompensationHandler [
	^ false
]
