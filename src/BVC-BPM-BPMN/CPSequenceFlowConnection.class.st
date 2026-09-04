"I represent one resolved sequence-flow connection in a CPProcessTopology. I keep the semantic CPSequenceFlow together with the source and target resolved for the topology being assessed."
Class {
	#name : 'CPSequenceFlowConnection',
	#superclass : 'Object',
	#instVars : [
		'sequenceFlow',
		'source',
		'target'
	],
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'instance creation' }
CPSequenceFlowConnection class >> sequenceFlow: aSequenceFlow source: aSource target: aTarget [
	^ self new
		sequenceFlow: aSequenceFlow;
		source: aSource;
		target: aTarget;
		yourself
]

{ #category : 'accessing' }
CPSequenceFlowConnection >> sequenceFlow [
	^ sequenceFlow
]

{ #category : 'accessing' }
CPSequenceFlowConnection >> sequenceFlow: anObject [
	sequenceFlow := anObject
]

{ #category : 'accessing' }
CPSequenceFlowConnection >> source [
	^ source
]

{ #category : 'accessing' }
CPSequenceFlowConnection >> source: anObject [
	source := anObject
]

{ #category : 'accessing' }
CPSequenceFlowConnection >> target [
	^ target
]

{ #category : 'accessing' }
CPSequenceFlowConnection >> target: anObject [
	target := anObject
]

{ #category : 'testing' }
CPSequenceFlowConnection >> connectsFrom: aSource to: aTarget [
	^ source == aSource and: [ target == aTarget ]
]
