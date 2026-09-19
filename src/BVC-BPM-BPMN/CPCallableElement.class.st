"I represent a BPMN CallableElement: a reusable definition with an input/output contract and optional service interfaces."
Class {
	#name : 'CPCallableElement',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'supportedInterfaceRefs',
		'ioSpecification',
		'ioBindings'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPCallableElement >> initialize [
	super initialize.
	supportedInterfaceRefs := OrderedCollection new.
	ioBindings := OrderedCollection new
]

{ #category : 'accessing' }
CPCallableElement >> supportedInterfaceRefs [ ^ supportedInterfaceRefs ]

{ #category : 'accessing' }
CPCallableElement >> supportedInterfaceRefs: aCollection [ supportedInterfaceRefs := aCollection asOrderedCollection ]

{ #category : 'accessing' }
CPCallableElement >> ioSpecification [ ^ ioSpecification ]

{ #category : 'accessing' }
CPCallableElement >> ioSpecification: aSpecification [ ioSpecification := aSpecification ]

{ #category : 'accessing' }
CPCallableElement >> ioBindings [ ^ ioBindings ]

{ #category : 'accessing' }
CPCallableElement >> ioBindings: aCollection [ ioBindings := aCollection asOrderedCollection ]

{ #category : 'descriptions' }
CPCallableElement >> supportedInterfaceRefsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #supportedInterfaceRefs;
		classes: { CPInterface };
		reference: CPInterface new labelDescription;
		label: 'Supported interfaces';
		priority: 120;
		group: 'Interface';
		beOrdered;
		yourself
]

{ #category : 'descriptions' }
CPCallableElement >> ioSpecificationDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #ioSpecification;
		classes: { CPInputOutputSpecification };
		reference: CPInputOutputSpecification new identifierDescription;
		label: 'Input/output specification';
		priority: 130;
		group: 'Data';
		yourself
]

{ #category : 'descriptions' }
CPCallableElement >> ioBindingsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #ioBindings;
		classes: { CPInputOutputBinding };
		reference: CPInputOutputBinding new identifierDescription;
		label: 'Input/output bindings';
		priority: 140;
		group: 'Interface';
		beOrdered;
		yourself
]
