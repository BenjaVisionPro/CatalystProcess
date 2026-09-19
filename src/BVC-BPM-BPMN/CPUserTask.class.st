Class {
	#name : 'CPUserTask',
	#superclass : 'CPTask',
	#instVars : [
		'implementation',
		'renderings'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'initialization' }
CPUserTask >> initialize [
	super initialize.
	implementation := '##unspecified'.
	renderings := OrderedCollection new
]

{ #category : 'accessing' }
CPUserTask >> implementation [ ^ implementation ]

{ #category : 'accessing' }
CPUserTask >> implementation: aString [ implementation := aString ]

{ #category : 'accessing' }
CPUserTask >> renderings [ ^ renderings ]

{ #category : 'accessing' }
CPUserTask >> renderings: aCollection [ renderings := aCollection asOrderedCollection ]

{ #category : 'descriptions' }
CPUserTask >> implementationDescription [
	<magritteDescription>
	^ MAStringDescription new
		accessor: #implementation;
		label: 'Implementation';
		priority: 100;
		group: 'Execution';
		beRequired;
		yourself
]

{ #category : 'descriptions' }
CPUserTask >> renderingsDescription [
	<magritteDescription>
	^ MAToManyRelationDescription new
		accessor: #renderings;
		classes: { CPRendering };
		reference: CPRendering new identifierDescription;
		label: 'Renderings';
		priority: 110;
		group: 'Execution';
		beModifiable;
		beOrdered;
		newItemClassStencil: [ :aClass | aClass new ];
		yourself
]

{ #category : 'task type' }
CPUserTask class >> taskTypeLabel [ ^ 'User' ]

{ #category : 'task type' }
CPUserTask class >> taskTypeIcon [ ^ #user ]

{ #category : 'defaults' }
CPUserTask class >> defaultIcon [ ^ self taskTypeIcon ]
