"I represent a BPMN Call Activity that invokes another callable Process.

In the current Catalyst Process model the callable element is a CPProcess. Global Tasks are not yet modeled, so calledElement deliberately exposes the process-valued subset that the semantic model can currently represent."
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
CPCallActivity >> calledElement: aProcess [
	calledElement := aProcess
]

{ #category : 'descriptions' }
CPCallActivity >> calledElementDescription [
	<magritteDescription>
	^ MAToOneRelationDescription new
		accessor: #calledElement;
		classes: { CPProcess };
		reference: CPProcess new labelDescription;
		label: 'Called element';
		priority: 100;
		group: 'Call';
		yourself
]

{ #category : 'testing' }
CPCallActivity >> isCallActivity [
	^ true
]
