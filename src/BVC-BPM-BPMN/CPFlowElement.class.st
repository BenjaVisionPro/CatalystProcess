Class {
	#name : 'CPFlowElement',
	#superclass : 'CFLabelledObject',
	#instVars : [
		'container'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'accessing' }
CPFlowElement >> container [
	^ container
]

{ #category : 'accessing' }
CPFlowElement >> container: anObject [
	container := anObject
]

{ #category : 'descriptions' }
CPFlowElement >> containerDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #container;
		classes: { CPProcess };
		reference: CPProcess new labelDescription;
		label: 'Container';
		priority: 100;
		group: 'Relations';
		yourself
]

{ #category : 'private - containment' }
CPFlowElement >> prepareForRemovalFrom: aContainer [
]
