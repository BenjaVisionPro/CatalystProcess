"I represent a BPMN Intermediate Throw Event used in normal flow."
Class {
	#name : 'CPIntermediateThrowEvent',
	#superclass : 'CPThrowEvent',
	#category : 'BVC-BPM-BPMN',
	#package : 'BVC-BPM-BPMN'
}

{ #category : 'testing' }
CPIntermediateThrowEvent >> isIntermediateEvent [ ^ true ]

{ #category : 'defaults' }
CPIntermediateThrowEvent class >> defaultIcon [ ^ #intermediateEvent ]
