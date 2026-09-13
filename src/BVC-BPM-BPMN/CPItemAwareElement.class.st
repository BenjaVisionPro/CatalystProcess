"I provide the common BPMN item-aware state for item-aware elements whose BPMN inheritance does not require another semantic superclass."
Class {
	#name : 'CPItemAwareElement',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'itemSubjectRef',
		'dataState'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPItemAwareElement >> itemSubjectRef [
	^ itemSubjectRef
]

{ #category : 'accessing' }
CPItemAwareElement >> itemSubjectRef: anItemDefinition [
	itemSubjectRef := anItemDefinition
]

{ #category : 'accessing' }
CPItemAwareElement >> dataState [
	^ dataState
]

{ #category : 'accessing' }
CPItemAwareElement >> dataState: aDataState [
	dataState := aDataState
]

{ #category : 'accessing' }
CPItemAwareElement >> structureRef [
	^ itemSubjectRef ifNotNil: [ itemSubjectRef structureRef ]
]

{ #category : 'descriptions' }
CPItemAwareElement >> itemSubjectRefDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #itemSubjectRef;
		classes: { CPItemDefinition };
		reference: CPItemDefinition new identifierDescription;
		label: 'Item definition';
		priority: 100;
		group: 'Data';
		yourself
]

{ #category : 'descriptions' }
CPItemAwareElement >> dataStateDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #dataState;
		classes: { CPDataState };
		reference: CPDataState new labelDescription;
		label: 'State';
		priority: 110;
		group: 'Data';
		yourself
]
