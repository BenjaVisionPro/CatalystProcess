"I represent a BPMN Call Activity that invokes another callable Process.

The called element is a BPMN CallableElement. A Call Activity transfers control to that reusable definition and uses the Activity input/output contract to exchange data with it."
Class {
	#name : 'CPCallActivity',
	#superclass : 'CPActivity',
	#instVars : [
		'calledElement'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'defaults' }
CPCallActivity class >> defaultIcon [
	^ #callActivity
]

{ #category : 'accessing' }
CPCallActivity >> calledElement [
	^ calledElement
]

{ #category : 'accessing' }
CPCallActivity >> calledElement: aCallableElement [
	calledElement := aCallableElement
]

{ #category : 'descriptions' }
CPCallActivity >> calledElementDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #calledElement;
		classes: { CPCallableElement };
		reference: CPCallableElement new labelDescription;
		label: 'Called element';
		priority: 100;
		group: 'Call';
		yourself
]

{ #category : 'testing' }
CPCallActivity >> isCallActivity [
	^ true
]
